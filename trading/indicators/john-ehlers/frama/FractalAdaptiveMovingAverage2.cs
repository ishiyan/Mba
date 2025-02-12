using System;
using System.Globalization;
using System.Runtime.Serialization;
using System.Text;

using Mbst.Core;
using Mbst.Numerics;

namespace Mbst.Indicators
{
    /// <summary>
    /// 
    /// <para />
    /// </summary>
    [DataContract]
    public sealed class FractalAdaptiveMovingAverage2 : Indicator, ILineIndicator
    {
        #region Members and accessors
        #region Length
        [DataMember]
        private readonly int length;
        /// <summary>
        /// The length, <c>ℓ</c>, (the number of time periods) of the Fractal Adaptive Moving Average. Must be an even number.
        /// </summary>
        public int Length { get { return length; } }
        #endregion

        #region Value
        [DataMember]
        private double value = double.NaN;
        /// <summary>
        /// The current value of the Fractal Adaptive Moving Average or <c>NaN</c> if not primed.
        /// </summary>
        public double Value { get { lock (updateLock) { return primed ? value : double.NaN; } } }
        #endregion

        #region ValueFacade
        /// <summary>
        /// A line indicator façade to expose a value of the fractal dimension as a separate line indicator with a fictious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the fractal dimensionassumes from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade ValueFacade
        {
            get
            {
                return new LineIndicatorFacade(frama, moniker, framaFull, () => IsPrimed, () => Value);
            }
        }
        #endregion

        #region FractalDimension
        [DataMember]
        private double fractalDimension = double.NaN;
        /// <summary>
        /// The current value of the fractal dimension ⋲[1, 2) or <c>NaN</c> if not primed.
        /// </summary>
        public double FractalDimension { get { lock (updateLock) { return primed ? fractalDimension : double.NaN; } } }
        #endregion

        #region FractalDimensionFacade
        /// <summary>
        /// A line indicator façade to expose a value of the fractal dimension as a separate line indicator with a fictious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the fractal dimensionassumes from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade FractalDimensionFacade
        {
            get
            {
                const string suffix = "Dim";
                return new LineIndicatorFacade(string.Concat(frama, suffix), string.Concat(moniker, suffix),
                    string.Concat(framaFull, " (fractal dimension)"), () => IsPrimed, () => FractalDimension);
            }
        }
        #endregion

        [DataMember]
        private readonly int lengthMinOne;
        [DataMember]
        private readonly int halfLength;
        [DataMember]
        private readonly int halfLengthMinOne;
        [DataMember]
        private int circularBufferIndex;
        [DataMember]
        private int circularBufferCount;
        [DataMember]
        private readonly double[] highCircularBuffer;
        [DataMember]
        private readonly double[] lowCircularBuffer;

        private const string frama = "frama";
        private const string framaFull = "Fractal Adaptive Moving Average";
        private const string argumentLength = "length";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="FractalAdaptiveMovingAverage"/> class.
        /// </summary>
        /// <param name="length">The length, <c>ℓ</c>, (the number of time periods) of the Fractal Adaptive Moving Average. Must be an even number (otherwise, it will be incremented). The default value used by original indicator is 16.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The original indicator uses the median price (high+low)/2, which is the default.</param>
        public FractalAdaptiveMovingAverage2(int length = 16, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : base(frama, framaFull, ohlcvComponent)
        {
            if (2 > length)
                throw new ArgumentOutOfRangeException(argumentLength);
            if (0 != length % 2)
                ++length;
            this.length = length;
            lengthMinOne = length - 1;
            halfLength = length / 2;
            halfLengthMinOne = halfLength - 1;
            highCircularBuffer = new double[length];
            lowCircularBuffer = new double[length];
            moniker = string.Concat(frama, "(", length.ToString(CultureInfo.InvariantCulture), ")");
        }
        #endregion

        #region Reset
        /// <summary>
        /// Resets the indicator.
        /// </summary>
        public override void Reset()
        {
            lock (updateLock)
            {
                primed = false;
                value = double.NaN;
                fractalDimension = double.NaN;
                circularBufferIndex = 0;
                circularBufferCount = 0;
            }
        }
        #endregion

        #region Update
        private double Update(double sample, double sampleHigh, double sampleLow)
        {
            if (double.IsNaN(sampleHigh) || double.IsNaN(sampleLow))
                return double.NaN;
            if (sampleHigh < sampleLow)
            {
                double temp = sampleLow;
                sampleLow = sampleHigh;
                sampleHigh = temp;
            }
            lock (updateLock)
            {
                int index = circularBufferIndex;
                if (++circularBufferIndex > lengthMinOne)
                    circularBufferIndex = 0;
                lowCircularBuffer[index] = sampleLow;
                highCircularBuffer[index] = sampleHigh;
                if (primed)
                {
                    fractalDimension = EstimateFractalDimension(index);
                    double alpha = EstimateAlpha();
                    value += (sample - value) * alpha;
                }
                else
                {
                    if (lengthMinOne == ++circularBufferCount)
                    {
                        fractalDimension = EstimateFractalDimension(index);
                        double alpha = EstimateAlpha();
                        value += (sample - value) * alpha;
                        primed = true;
                    }
                    else
                    {
                        value = sample;
                        return double.NaN;
                    }
                }
                return value;
            }
        }

        /// <summary>
        /// Updates the value of the Fractal Adaptive Moving Average indicator.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public double Update(double sample)
        {
            return Update(sample, sample, sample);
        }

        /// <summary>
        /// Updates the value of the Fractal Adaptive Moving Average indicator.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Scalar scalar)
        {
            double sample = scalar.Value;
            return new Scalar(scalar.Time, Update(sample, sample, sample));
        }

        /// <summary>
        /// Updates the value of the Fractal Adaptive Moving Average indicator.
        /// </summary>
        /// <param name="ohlcv">A new ohlcv.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Ohlcv ohlcv)
        {
            return new Scalar(ohlcv.Time, Update(ohlcv.Component(ohlcvComponent), ohlcv.High, ohlcv.Low));
        }
        #endregion

        #region EstimateFractalDimension
        private double EstimateFractalDimension(int index)
        {
            double minLow = lowCircularBuffer[index];
            double maxHigh = highCircularBuffer[index];
            for (int i = 0; i < halfLengthMinOne; ++i)
            {
                if (index == 0)
                    index = lengthMinOne;
                else
                    --index;
                double temp = lowCircularBuffer[index];
                if (minLow > temp)
                    minLow = temp;
                temp = highCircularBuffer[index];
                if (maxHigh < temp)
                    maxHigh = temp;
            }
            double highLowRangeHalf = maxHigh - minLow;
            double minLowSecondHalf = double.MaxValue;
            double maxHighSecondHalf = double.MinValue;
            for (int i = 0; i < halfLength; ++i)
            {
                if (index == 0)
                    index = lengthMinOne;
                else
                    --index;
                double temp = lowCircularBuffer[index];
                if (minLow > temp)
                    minLow = temp;
                if (minLowSecondHalf > temp)
                    minLowSecondHalf = temp;
                temp = highCircularBuffer[index];
                if (maxHigh < temp)
                    maxHigh = temp;
                if (maxHighSecondHalf < temp)
                    maxHighSecondHalf = temp;
            }
            highLowRangeHalf += maxHighSecondHalf - minLowSecondHalf;
            return (Math.Log(highLowRangeHalf / halfLength) - Math.Log((maxHigh - minLow) / length)) * Constants.Log2E;
        }
        #endregion

        #region EstimateAlpha
        private double EstimateAlpha()
        {
            // We use the fractal dimension to dynamically change the alpha of an exponential moving average.
            // The fractal dimension varies over the range from 1 to 2.
            // Since the prices are log-normal, it seems reasonable to use an exponential function to relate the fractal dimension to alpha.
            double alpha = Math.Exp(-4.6 * (fractalDimension - 1));

            // When the fractal dimension is 1, the exponent is zero – which means that alpha is 1, and
            // the output of the exponential moving average is equal to the input.

            // Limit alpha to vary only from 0.01 to 1.
            if (alpha < 0.01)
                alpha = 0.01;
            else if (alpha > 1d)
                alpha = 1d;
            return alpha;
        }
        #endregion

        #region Overrides
        /// <summary>
        /// Returns the string that represents this object.
        /// </summary>
        /// <returns>Returns the string that represents this object.</returns>
        public override string ToString()
        {
            double d, v; bool p;
            lock (updateLock)
            {
                p = primed;
                v = value;
                d = fractalDimension;
            }
            var sb = new StringBuilder();
            sb.Append("[M:");
            sb.Append(moniker);
            sb.Append(" P:");
            sb.Append(p);
            sb.Append(" V:");
            sb.Append(v);
            sb.Append(" D:");
            sb.Append(d);
            sb.Append("]");
            return sb.ToString();
        }
        #endregion
    }
}
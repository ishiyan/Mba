using System;
using System.Globalization;
using Mbs.Numerics;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// Fractal Adaptive Moving Average is an .
    /// <para />
    /// </summary>
    public sealed class FractalAdaptiveMovingAverage : Indicator, ILineIndicator
    {
        #region Members and accessors

        /// <summary>
        /// The length, <c>ℓ</c>, (the number of time periods) of the Fractal Adaptive Moving Average. Must be an even number.
        /// </summary>
        public int Length { get; }

        private double value = double.NaN;
        /// <summary>
        /// The current value of the Fractal Adaptive Moving Average or <c>NaN</c> if not primed.
        /// </summary>
        public double Value { get { lock (updateLock) { return primed ? value : double.NaN; } } }

        /// <summary>
        /// A line indicator façade to expose a value of the fractal dimension as a separate line indicator with a fictitious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the fractal dimension assumes from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade ValueFacade => new LineIndicatorFacade(Frama, Moniker, FramaFull, () => IsPrimed, () => Value);

        private double fractalDimension = double.NaN;
        /// <summary>
        /// The current value of the fractal dimension ⋲[1, 2) or <c>NaN</c> if not primed.
        /// </summary>
        public double FractalDimension { get { lock (updateLock) { return primed ? fractalDimension : double.NaN; } } }

        /// <summary>
        /// A line indicator façade to expose a value of the fractal dimension as a separate line indicator with a fictitious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the fractal dimension from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade FractalDimensionFacade
        {
            get
            {
                const string suffix = "Dim";
                return new LineIndicatorFacade(string.Concat(Frama, suffix), string.Concat(Moniker, suffix),
                    string.Concat(FramaFull, " (fractal dimension)"), () => IsPrimed, () => FractalDimension);
            }
        }

        private readonly int lengthMinOne;
        private readonly int halfLength;
        private readonly int halfLengthMinOne;
        private int circularBufferIndex;
        private int circularBufferCount;
        private readonly double[] highCircularBuffer;
        private readonly double[] lowCircularBuffer;

        private const string Frama = "frama";
        private const string FramaFull = "Fractal Adaptive Moving Average";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="FractalAdaptiveMovingAverage"/> class.
        /// </summary>
        /// <param name="length">The length, <c>ℓ</c>, (the number of time periods) of the Fractal Adaptive Moving Average. Must be an even number (otherwise, it will be incremented). The default value used by original indicator is 16.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The original indicator uses the median price (high+low)/2, which is the default.</param>
        public FractalAdaptiveMovingAverage(int length = 16, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : base(Frama, FramaFull, ohlcvComponent)
        {
            if (2 > length)
                throw new ArgumentOutOfRangeException(nameof(length));
            if (0 != length % 2)
                ++length;
            this.Length = length;
            lengthMinOne = length - 1;
            halfLength = length / 2;
            halfLengthMinOne = halfLength - 1;
            highCircularBuffer = new double[length];
            lowCircularBuffer = new double[length];
            Moniker = string.Concat(Frama, "(", length.ToString(CultureInfo.InvariantCulture), ")");
        }
        #endregion

        #region Reset
        /// <inheritdoc />
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
            return new Scalar(ohlcv.Time, Update(ohlcv.Component(OhlcvComponent), ohlcv.High, ohlcv.Low));
        }
        #endregion

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
            return (Math.Log(highLowRangeHalf / halfLength) - Math.Log((maxHigh - minLow) / Length)) * Constants.Log2E;
        }

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
    }
}
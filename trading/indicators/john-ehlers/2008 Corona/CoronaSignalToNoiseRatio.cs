using System;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// The Corona Signal to Noise Ratio is a measure of the cycle amplitude relative to noise.
    /// <para />
    /// The "noise" is chosen to be the average bar height because there is not much trade information within the bar.
    /// <para />
    /// The vertical scale of the indicator is from 1 dB to 11 dB. The Signal to Noise Ratio starts
    /// to develop a “corona” below 4 dB, warning you that the ratio may become too low to safely
    /// swing trade on the basis of the cycle alone.
    /// </summary>
    public sealed class CoronaSignalToNoiseRatio : Indicator, IHeatMapIndicator
    {
        #region Members and accessors
        private const int HighLowMedianIndex = 2;
        private const int HighLowBufferSize = 5;
        private const int HighLowBufferSizeMinOne = HighLowBufferSize - 1;

        private readonly int rasterLength;
        private readonly double rasterStep;
        private bool isStarted;
        private readonly double[] highLowBuffer = new double[HighLowBufferSize];
        private double noisePrevious;
        private double averageSamplePrevious;
        private double signalPrevious;

        /// <summary>
        /// Serialization is not needed.
        /// </summary>
        private readonly double[] highLowBufferSorted = new double[HighLowBufferSize];

        /// <summary>
        /// The maximal raster value of the heat-map.
        /// </summary>
        private readonly double maxRasterValue;

        /// <summary>
        /// The middle raster value of the heat-map.
        /// </summary>
        private readonly double midRasterValue;

        /// <summary>
        /// The heat-map scaled to [0, maxRasterValue].
        /// </summary>
        private readonly double[] raster;

        /// <summary>
        /// The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        public double MinParameterValue { get; }

        /// <summary>
        /// The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        public double MaxParameterValue { get; }

        private double signalToNoiseRatio = double.NaN;

        /// <summary>
        /// The current value of the Corona signal to noise ratio in the range of [MinParameterValue, MaxParameterValue] or <c>NaN</c> if not primed.
        /// </summary>
        public double SignalToNoiseRatio { get { lock (updateLock) { return primed ? signalToNoiseRatio : double.NaN; } } }

        /// <summary>
        /// A line indicator façade to expose a value of the SignalToNoiseRatio as a separate line indicator with a fictitious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the SignalToNoiseRatio from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade SignalToNoiseRatioFacade => new LineIndicatorFacade(CsnrName, CsnrMoniker, CsnrDescription, () => IsPrimed, () => SignalToNoiseRatio);

        private readonly bool isSlave;
        private readonly Corona corona;

        private const string CsnrHeatMapName = "CoronaSignalToNoiseRatioHeatmap";
        private const string CsnrHeatMapDescription = "Crona signal to noise ratio heatmap";
        private const string CsnrHeatMapMoniker = "CoronaSNR(h)";

        private const string CsnrName = "CoronaSignalToNoiseRatio";
        private const string CsnrDescription = "Crona signal to noise ratio";
        private const string CsnrMoniker = "CoronaSNR";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="rasterLength">The number of elements in the heat-map raster. The default value is 50.</param>
        /// <param name="maxRasterValue">The maximal raster value of the heat-map. The default value is 20.</param>
        /// <param name="minParameterValue">The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is 1.</param>
        /// <param name="maxParameterValue">The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is 11.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The original indicator uses the median price (high+low)/2, which is the default.</param>
        /// <param name="highPassFilterCutoff">The high-pass filter cutoff (de-trending period). Suggested values are 20, 30, 100.</param>
        /// <param name="minimalPeriod">The minimal period. The default value is 6.</param>
        /// <param name="maximalPeriod">The maximal period. The default value is 30.</param>
        public CoronaSignalToNoiseRatio(int rasterLength = 50, double maxRasterValue = 20, double minParameterValue = 1, double maxParameterValue = 11,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice,
            int highPassFilterCutoff = 30, int minimalPeriod = 6, int maximalPeriod = 30)
            : this(null, rasterLength, maxRasterValue,
            minParameterValue, maxParameterValue, ohlcvComponent, highPassFilterCutoff, minimalPeriod, maximalPeriod)
        {
        }

        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="coronaSpectrum">The parent <c>CoronaSpectrum</c> instance to re-use the corona engine.</param>
        /// <param name="rasterLength">The number of elements in the heat-map raster. The default value is 50.</param>
        /// <param name="maxRasterValue">The maximal raster value of the heat-map. The default value is 20.</param>
        /// <param name="minParameterValue">The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is 1.</param>
        /// <param name="maxParameterValue">The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is 11.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The original indicator uses the median price (high+low)/2, which is the default.</param>
        public CoronaSignalToNoiseRatio(CoronaSpectrum coronaSpectrum, int rasterLength = 50, double maxRasterValue = 20, double minParameterValue = 1, double maxParameterValue = 11,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(coronaSpectrum.Corona, rasterLength, maxRasterValue, minParameterValue, maxParameterValue, ohlcvComponent, 30, 6, 30)
        {
        }

        private CoronaSignalToNoiseRatio(Corona corona, int rasterLength, double maxRasterValue, double minParameterValue, double maxParameterValue,
            OhlcvComponent ohlcvComponent, int highPassFilterCutoff, int minimalPeriod, int maximalPeriod)
            : base(CsnrHeatMapName, CsnrHeatMapDescription, ohlcvComponent)
        {
            Moniker = CsnrHeatMapMoniker;
            if (null == corona)
                this.corona = new Corona(highPassFilterCutoff, minimalPeriod, maximalPeriod);
            else
            {
                this.corona = corona;
                isSlave = true;
            }
            this.rasterLength = rasterLength;
            this.maxRasterValue = maxRasterValue;
            MinParameterValue = minParameterValue;
            MaxParameterValue = maxParameterValue;
            midRasterValue = maxRasterValue / 2;
            rasterStep = maxRasterValue / rasterLength;
            raster = new double[rasterLength];
            for (int i = 0; i < rasterLength; ++i)
                raster[i] = 0;
        }
        #endregion

        #region Reset
        /// <inheritdoc />
        public override void Reset()
        {
            lock (updateLock)
            {
                primed = false;
                isStarted = false;
                averageSamplePrevious = 0;
                signalPrevious = 0;
                noisePrevious = 0;
                signalToNoiseRatio = double.NaN;
                for (int i = 0; i < rasterLength; ++i)
                    raster[i] = 0;
                if (!isSlave)
                    corona.Reset();
            }
        }
        #endregion

        #region Update
        private HeatMap Update(double sample, double sampleLow, double sampleHigh, DateTime dateTime)
        {
            if (double.IsNaN(sample))
                return null;
            primed = isSlave ? corona.IsPrimed : corona.Update(sample);
            if (!isStarted)
            {
                averageSamplePrevious = sample;
                highLowBuffer[HighLowBufferSizeMinOne] = sampleHigh - sampleLow;
                isStarted = true;
                return null;
            }
            double maxAmplitudeSquared = corona.MaximalAmplitudeSquared;

            double averageSample = 0.1 * sample + 0.9 * averageSamplePrevious;
            averageSamplePrevious = averageSample;
            if (Math.Abs(averageSample) > double.Epsilon || maxAmplitudeSquared > 0)
                signalPrevious = 0.2 * Math.Sqrt(maxAmplitudeSquared) + 0.9 * signalPrevious;
            for (int i = 0; i < HighLowBufferSizeMinOne; )
                highLowBuffer[i] = highLowBuffer[++i];
            highLowBuffer[HighLowBufferSizeMinOne] = sampleHigh - sampleLow;
            double ratio = 0;
            if (Math.Abs(averageSample) > double.Epsilon)
            {
                for (int i = 0; i < HighLowBufferSize; ++i)
                    highLowBufferSorted[i] = highLowBuffer[i];
                Array.Sort(highLowBufferSorted);
                noisePrevious = 0.1 * highLowBufferSorted[HighLowMedianIndex] + 0.9 * noisePrevious;
                if (Math.Abs(noisePrevious) > double.Epsilon)
                {
                    ratio = 20 * Math.Log10(signalPrevious / noisePrevious) + 3.5;
                    if (ratio < 0)// <1
                        ratio = 0;
                    else if (ratio > 10)
                        ratio = 10;
                    // ∈ [0, 1].
                    ratio /= 10;
                }
            }
            signalToNoiseRatio = (MaxParameterValue - MinParameterValue) * ratio + MinParameterValue;
            // width ∈ [0, 0.2].
            double width = ratio > 0.5 ? 0 : (0.2 - 0.4 * ratio);
            var ratioScaledToRasterLength = (int)Math.Round(ratio * rasterLength);
            double ratioScaledToMaxRasterValue = ratio * maxRasterValue;
            for (int i = 0; i < rasterLength; ++i)
            //Parallel.For(0, rasterLength, i =>
            {
                double value = raster[i];
                if (i == ratioScaledToRasterLength)
                    value *= 0.5;
                else
                {
                    double argument = ratioScaledToMaxRasterValue - rasterStep * i;
                    argument /= width;
                    if (i < ratioScaledToRasterLength)
                        value = 0.5 * (Math.Pow(argument, 0.8) + value);
                    else
                    {
                        argument = -argument;
                        if (argument > 1)
                            value = 0.5 * (Math.Pow(argument, 0.8) + value);
                        else
                            value = maxRasterValue;
                    }
                }
                if (value < 0)
                    value = 0;
                else if (value > maxRasterValue)
                    value = maxRasterValue;
                if (ratio > 0.5)
                    value = maxRasterValue;
                raster[i] = value;
            }//);

            double[] intensity;
            if (primed)
            {
                intensity = new double[rasterLength];//+1
                // Min raster value is zero.
                for (int i = 0; i < rasterLength; ++i)
                {
                    double value = raster[i];
                    intensity[i] = value;
                }
            }
            else
            {
                intensity = null;
            }
            return new HeatMap(dateTime, intensity);
        }

        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="ohlcv">A new ohlcv.</param>
        /// <returns>The new heat-map column of the indicator or <c>null</c>.</returns>
        public HeatMap Update(Ohlcv ohlcv)
        {
            lock (updateLock)
            {
                return Update(ohlcv.Component(OhlcvComponent), ohlcv.Low, ohlcv.High, ohlcv.Time);
            }
        }

        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new heat-map column of the indicator or <c>null</c>.</returns>
        public HeatMap Update(Scalar scalar)
        {
            lock (updateLock)
            {
                double value = scalar.Value;
                return Update(value, value, value, scalar.Time);
            }
        }
        #endregion
    }
}
using System;
using Mbs.Numerics;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// The basis of the trend strength Corona indicator is the slope of the momentum
    /// taken over a full dominant cycle period. The trend slope is normalized to the
    /// amplitude of the dominant cycle, and is scaled to range from -10 to +10.
    /// <para />
    /// A value of +2 means the trend up-slope is twice the cycle amplitude.
    /// A value of -2 means the trend down-slope is twice the cycle amplitude.
    /// It is prudent to not trade the trend if the indicator is within the range from -2 to +2.
    /// Therefore, when the indicator is in this range you will see it develop its “corona”.
    /// </summary>
    public sealed class CoronaTrendVigor : Indicator, IHeatMapIndicator
    {
        #region Members and accessors

        private double bandPassPrevious;
        private double bandPassPrevious2;
        private double samplePrevious;
        private double samplePrevious2;
        private readonly int sampleBufferLastIndex;
        private readonly int sampleBufferLength;
        private readonly double[] sampleBuffer;

        private readonly int rasterLength;
        private readonly double rasterStep;
        private int sampleCount;

        /// <summary>
        /// The previous value of the trend vigor ratio scaled to range [-10, 10].
        /// </summary>
        private double ratioPrevious;

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

        private double trendVigor = double.NaN;

        /// <summary>
        /// The current value of the Corona trend vigor in the range of [MinParameterValue, MaxParameterValue] or <c>NaN</c> if not primed.
        /// </summary>
        public double TrendVigor { get { lock (updateLock) { return primed ? trendVigor : double.NaN; } } }

        /// <summary>
        /// A line indicator façade to expose a value of the TrendVigor as a separate line indicator with a fictitious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the TrendVigor from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade TrendVigorFacade => new LineIndicatorFacade(CtvName, CtvMoniker, CtvDescription, () => IsPrimed, () => TrendVigor);

        private readonly bool isSlave;
        private readonly Corona corona;

        private const string CtvHeatMapName = "CoronaTrendVigorHeatmap";
        private const string CtvHeatMapDescription = "Crona trend vigor heatmap";
        private const string CtvHeatMapMoniker = "CoronaTV(h)";

        private const string CtvName = "CoronaTrendVigor";
        private const string CtvDescription = "Crona trend vigor";
        private const string CtvMoniker = "CoronaTV";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="rasterLength">The number of elements in the heat-map raster. The default value is 50.</param>
        /// <param name="maxRasterValue">The maximal raster value of the heat-map. The default value is 20.</param>
        /// <param name="minParameterValue">The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is -10.</param>
        /// <param name="maxParameterValue">The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is 10.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The original indicator uses the median price (high+low)/2, which is the default.</param>
        /// <param name="highPassFilterCutoff">The high-pass filter cutoff (de-trending period). Suggested values are 20, 30, 100.</param>
        /// <param name="minimalPeriod">The minimal period. The default value is 6.</param>
        /// <param name="maximalPeriod">The maximal period. The default value is 30.</param>
        public CoronaTrendVigor(int rasterLength = 50, double maxRasterValue = 20,
            double minParameterValue = -10, double maxParameterValue = 10,
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
        /// <param name="minParameterValue">The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is -10.</param>
        /// <param name="maxParameterValue">The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is 10.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The original indicator uses the median price (high+low)/2, which is the default.</param>
        public CoronaTrendVigor(CoronaSpectrum coronaSpectrum,
            int rasterLength = 50, double maxRasterValue = 20, double minParameterValue = -10, double maxParameterValue = 10,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(coronaSpectrum.Corona, rasterLength, maxRasterValue,
            minParameterValue, maxParameterValue, ohlcvComponent, 30, 6, 30)
        {
        }

        private CoronaTrendVigor(Corona corona, int rasterLength, double maxRasterValue, double minParameterValue, double maxParameterValue,
            OhlcvComponent ohlcvComponent, int highPassFilterCutoff, int minimalPeriod, int maximalPeriod)
            : base(CtvHeatMapName, CtvHeatMapDescription, ohlcvComponent)
        {
            Moniker = CtvHeatMapMoniker;
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
            sampleBufferLength = this.corona.MaximalPeriodTimesTwo;
            sampleBuffer = new double[sampleBufferLength];
            sampleBufferLastIndex = sampleBufferLength - 1;
            for (int i = 0; i < sampleBufferLength; ++i)
                sampleBuffer[i] = 0;
        }
        #endregion

        #region Reset
        /// <inheritdoc />
        public override void Reset()
        {
            lock (updateLock)
            {
                primed = false;
                sampleCount = 0;
                samplePrevious = 0;
                samplePrevious2 = 0;
                bandPassPrevious = 0;
                bandPassPrevious2 = 0;
                ratioPrevious = 0;
                trendVigor = double.NaN;
                for (int i = 0; i < rasterLength; ++i)
                    raster[i] = 0;
                for (int i = 0; i < sampleBufferLength; ++i)
                    sampleBuffer[i] = 0;
                if (!isSlave)
                    corona.Reset();
            }
        }
        #endregion

        #region Update
        private HeatMap Update(double sample, DateTime dateTime)
        {
            if (double.IsNaN(sample))
                return null;
            primed = isSlave ? corona.IsPrimed : corona.Update(sample);
            if (1 == ++sampleCount)
            {
                samplePrevious = sample;
                sampleBuffer[sampleBufferLastIndex] = sample;
                return null;
            }

            // Filter bandpass InPhase component.
            double omega = Constants.TwoPi / corona.DominantCycleMedian;
            double beta2 = Math.Cos(omega);
            double gamma2 = 1 / Math.Cos(omega * 2 * 0.1);
            double alpha2 = gamma2 - Math.Sqrt(gamma2 * gamma2 - 1);
            double bandPass = 0.5 * (1 - alpha2) * (sample - samplePrevious2) + beta2 * (1 + alpha2) * bandPassPrevious - alpha2 * bandPassPrevious2;
            // Quadrature component is derivative of InPhase component divided by omega.
            double quadrature2 = (bandPass - bandPassPrevious) / omega;
            bandPassPrevious2 = bandPassPrevious;
            bandPassPrevious = bandPass;
            samplePrevious2 = samplePrevious;
            samplePrevious = sample;

            for (int i = 0; i < sampleBufferLastIndex; )
                sampleBuffer[i] = sampleBuffer[++i];
            sampleBuffer[sampleBufferLastIndex] = sample;
            // Pythagorean theorem to establish cycle amplitude.
            double amplitude2 = Math.Sqrt(bandPass * bandPass + quadrature2 * quadrature2);
            // Trend amplitude taken over the cycle period.
            var cyclePeriod = (int)(corona.DominantCycleMedian - 1);
            if (cyclePeriod < sampleBufferLength)
                cyclePeriod = sampleBufferLength;
            if (cyclePeriod > sampleBufferLength)
                cyclePeriod = sampleBufferLength;
            double trend = sample - sampleBuffer[sampleBufferLength - Math.Min(cyclePeriod, sampleCount)];
            double ratio = (Math.Abs(trend) > double.Epsilon && amplitude2 > double.Epsilon) ?
                (0.33 * trend / amplitude2 + 0.67 * ratioPrevious) : 0;
            if (ratio > 10)
                ratio = 10;
            if (ratio < -10)
                ratio = -10;
            ratioPrevious = ratio;
            // ratio ∈ [-10, 10], vigor ∈ [0, 1].
            double vigor = 0.05 * (ratio + 10);
            double width;
            if (vigor >= 0.3 && vigor < 0.5)
                width = vigor - (0.3 - 0.01);
            else if (vigor >= 0.5 && vigor <= 0.7)
                width = (0.7 + 0.01) - vigor;
            else
                width = 0.01;
            trendVigor = (MaxParameterValue - MinParameterValue) * vigor + MinParameterValue;
            var vigorScaledToRasterLength = (int)Math.Round(rasterLength * vigor);
            double vigorScaledToMaxRasterValue = vigor * maxRasterValue;
            for (int i = 0; i < rasterLength; ++i)
            //Parallel.For(0, rasterLength, i =>
            {
                double value = raster[i];
                if (i == vigorScaledToRasterLength)
                    value *= 0.5;
                else
                {
                    double argument = vigorScaledToMaxRasterValue - rasterStep * i;
                    if (i > vigorScaledToRasterLength)
                        argument = -argument;
                    value = 0.8 * (Math.Pow(argument / width, 0.85) + 0.2 * value);
                }
                if (value < 0)
                    value = 0;
                else if (value > maxRasterValue || vigor < 0.3 || vigor > 0.7)
                    value = maxRasterValue;
                raster[i] = value;
            }//);
            double[] intensity;
            if (primed)
            {
                intensity = new double[rasterLength];//+1
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
                return Update(ohlcv.Component(OhlcvComponent), ohlcv.Time);
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
                return Update(scalar.Value, scalar.Time);
            }
        }
        #endregion
    }
}
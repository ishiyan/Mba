using System;
using System.Collections.Generic;

using Mbs.Numerics;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// The Corona swing position is estimated by correlating the prices with a perfect sine wave
    /// having the dominant cycle period. This correlation produces a smooth waveform that lets us
    /// better estimate the swing position and impending turning points.
    /// <para />
    /// The vertical axis is on an arbitrary scale from -5 to 5.
    /// Since the purpose of this indicator is to anticipate the turning points,
    /// regions near the minimum and maximum are the strongest.
    /// <para />
    /// The indicator develops a “corona” near the center of the range – signifying that a turning point is not imminent.
    /// You will also notice a corona being displayed when the market is in a trend and there is very little cyclic swing.
    /// </summary>
    public sealed class CoronaSwingPosition : Indicator, IHeatMapIndicator
    {
        #region Members and accessors
        private const int MaxLeadListCount = 50;
        private const int MaxPositionListCount = 20;

        private readonly List<double> leadList = new List<double>(MaxLeadListCount);
        private readonly List<double> positionList = new List<double>(MaxPositionListCount);

        private readonly int rasterLength;
        private readonly double rasterStep;
        private bool isStarted;
        private double bandPassPrevious;
        private double bandPassPrevious2;
        private double samplePrevious;
        private double samplePrevious2;

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

        private double swingPosition = double.NaN;

        /// <summary>
        /// The current value of the Corona swing position in the range of [MinParameterValue, MaxParameterValue] or <c>NaN</c> if not primed.
        /// </summary>
        public double SwingPosition { get { lock (updateLock) { return primed ? swingPosition : double.NaN; } } }

        /// <summary>
        /// A line indicator façade to expose a value of the SwingPosition as a separate line indicator with a fictitious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the SwingPosition from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade SwingPositionFacade => new LineIndicatorFacade(CspName, CspMoniker, CspDescription, () => IsPrimed, () => SwingPosition);

        private readonly bool isSlave;
        private readonly Corona corona;

        private const string CspHeatMapName = "CoronaSwingPositionHeatmap";
        private const string CspHeatMapDescription = "Corona swing position heatmap";
        private const string CspHeatMapMoniker = "CoronaSP(h)";
        private const string CspName = "CoronaSwingPosition";
        private const string CspDescription = "Crona swing position";
        private const string CspMoniker = "CoronaSP";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="rasterLength">The number of elements in the heat-map raster. The default value is 50.</param>
        /// <param name="maxRasterValue">The maximal raster value of the heat-map. The default value is 20.</param>
        /// <param name="minParameterValue">The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is -5.</param>
        /// <param name="maxParameterValue">The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is 5.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The original indicator uses the median price (high+low)/2, which is the default.</param>
        /// <param name="highPassFilterCutoff">The high-pass filter cutoff (de-trending period). Suggested values are 20, 30, 100.</param>
        /// <param name="minimalPeriod">The minimal period. The default value is 6.</param>
        /// <param name="maximalPeriod">The maximal period. The default value is 30.</param>
        public CoronaSwingPosition(int rasterLength = 50, double maxRasterValue = 20,
            double minParameterValue = -5, double maxParameterValue = 5,
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
        /// <param name="minParameterValue">The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is -5.</param>
        /// <param name="maxParameterValue">The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns. The default value is 5.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The original indicator uses the median price (high+low)/2, which is the default.</param>
        public CoronaSwingPosition(CoronaSpectrum coronaSpectrum,
            int rasterLength = 50, double maxRasterValue = 20, double minParameterValue = -5, double maxParameterValue = 5,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(coronaSpectrum.Corona, rasterLength, maxRasterValue,
            minParameterValue, maxParameterValue, ohlcvComponent, 30, 6, 30)
        {
        }

        private CoronaSwingPosition(Corona corona, int rasterLength, double maxRasterValue, double minParameterValue, double maxParameterValue,
            OhlcvComponent ohlcvComponent,
            int highPassFilterCutoff, int minimalPeriod, int maximalPeriod)
            : base(CspHeatMapName, CspHeatMapDescription, ohlcvComponent)
        {
            Moniker = CspHeatMapMoniker;
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
                samplePrevious = 0;
                samplePrevious2 = 0;
                bandPassPrevious = 0;
                bandPassPrevious2 = 0;
                swingPosition = double.NaN;
                for (int i = 0; i < rasterLength; ++i)
                    raster[i] = 0;
                leadList.Clear();
                positionList.Clear();
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
            if (!isStarted)
            {
                samplePrevious = sample;
                isStarted = true;
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

            // Swing position calculation.
            double lead60 = 0.5 * bandPassPrevious2 + 0.866 * quadrature2;
            UpdatePhaseList(leadList, MaxLeadListCount, lead60, out var lowest, out var highest);
            // The value will be in range [0, 1].
            double position = highest - lowest;
            // The value of the swing position is not negative, so the absolute value is not necessary.
            if (position > double.Epsilon)
                position = (lead60 - lowest) / position;
            UpdatePhaseList(positionList, MaxPositionListCount, position, out lowest, out highest);
            highest -= lowest;
            double width = highest > 0.85 ? 0.01 : (0.15 * highest);
            swingPosition = (MaxParameterValue - MinParameterValue) * position + MinParameterValue;
            var positionScaledToRasterLength = (int)Math.Round(position * rasterLength);
            double positionScaledToMaxRasterValue = position * maxRasterValue;
            for (int i = 0; i < rasterLength; ++i)
            //Parallel.For(0, rasterLength, i =>
            {
                double value = raster[i];
                if (i == positionScaledToRasterLength)
                    value *= 0.5;
                else
                {
                    double argument = positionScaledToMaxRasterValue - rasterStep * i;
                    if (i > positionScaledToRasterLength)
                        argument = -argument;
                    value = 0.5 * (Math.Pow(argument / width, 0.95) + 0.5 * value);
                }
                if (value < 0)
                    value = 0;
                else if (value > maxRasterValue)
                    value = maxRasterValue;
                if (highest > 0.8)
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

        private void UpdatePhaseList(List<double> list, int maximalCount, double lead, out double lowest, out double highest)
        {
            // Keep no more than maximal allowed number of elements.
            if (list.Count >= maximalCount)
                list.RemoveAt(0);
            list.Add(lead);

            lowest = lead;
            highest = lead;
            foreach (var value in list)
            {
                if (lowest > value)
                    lowest = value;
                if (highest < value)
                    highest = value;
            }
        }
    }
}
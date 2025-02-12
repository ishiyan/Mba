using System;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// The Corona Spectrum measures cyclic activity over a cycle period range (default from 6 bars to 30 bars)
    /// in a bank of contiguous filters.
    /// <para />
    /// Longer cycle periods are not considered because they can be considered trend segments. Shorter cycle
    /// periods are not considered because of the aliasing noise encountered with the data sampling process.
    /// <para />
    /// The amplitude of each filter output is compared to the strongest signal and the result is displayed
    /// over an amplitude range of 20 decibels in the form of a heat-map.
    /// <para />
    /// The filter having the strongest output is selected as the current dominant cycle period.
    /// <para />
    /// See “Measuring Cycle Periods” in the March 2008 issue of Stocks &amp; Commodities Magazine.
    /// </summary>
    public sealed class CoronaSpectrum : Indicator, IHeatMapIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        public double MinParameterValue { get; }

        /// <summary>
        /// The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        public double MaxParameterValue { get; }

        /// <summary>
        /// The middle raster value of the heat-map.
        /// </summary>
        private readonly double midRasterValue;

        /// <summary>
        /// The current value of the Corona dominant cycle or <c>NaN</c> if not primed.
        /// </summary>
        public double DominantCycle { get { lock (updateLock) { return primed ? Corona.DominantCycle : double.NaN; } } }

        /// <summary>
        /// The current value of the Corona dominant cycle median or <c>NaN</c> if not primed.
        /// </summary>
        public double DominantCycleMedian { get { lock (updateLock) { return primed ? Corona.DominantCycleMedian : double.NaN; } } }

        /// <summary>
        /// A line indicator façade to expose a value of the DominantCycle as a separate line indicator with a fictitious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the DominantCycle from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade DominantCycleFacade => new LineIndicatorFacade(CdcName, CdcMoniker, CdcDescription, () => IsPrimed, () => DominantCycle);

        /// <summary>
        /// A line indicator façade to expose a value of the DominantCycleMedian as a separate line indicator with a fictitious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the DominantCycleMedian from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade DominantCycleMedianFacade => new LineIndicatorFacade(CdcmName, CdcmMoniker, CdcmDescription, () => IsPrimed, () => DominantCycleMedian);

        /// <summary>
        /// The associated corona engine.
        /// </summary>
        internal Corona Corona { get; }

        private const string CsName = "CoronaSpectrum";
        private const string CsDescription = "Crona spectrum heatmap";
        private const string CsMoniker = "CoronaS";

        private const string CdcName = "CoronaDominantCycle";
        private const string CdcDescription = "Crona dominant cycle";
        private const string CdcMoniker = "CoronaDC";

        private const string CdcmName = "CoronaDominantCycleMedian";
        private const string CdcmDescription = "Crona dominant cycle median";
        private const string CdcmMoniker = "CoronaDCM";

        private readonly double parameterRange;
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="minRasterValue">The minimal raster value of the heat-map. The default value is 6.</param>
        /// <param name="maxRasterValue">The maximal raster value of the heat-map. The default value is 20.</param>
        /// <param name="minParameterValue">The minimum ordinate (parameter) value of the heat-map, representing the minimal period. This value is the same for all heat-map columns. The default value is 6.</param>
        /// <param name="maxParameterValue">The maximum ordinate (parameter) value of the heat-map, representing the maximal period. This value is the same for all heat-map columns. The default value is 30.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The original indicator uses the median price (high+low)/2, which is the default.</param>
        /// <param name="highPassFilterCutoff">The high-pass filter cutoff (de-trending period). Suggested values are 20, 30, 100.</param>
        public CoronaSpectrum(double minRasterValue = 6, double maxRasterValue = 20, double minParameterValue = 6, double maxParameterValue = 30,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice, int highPassFilterCutoff = 30)
            : base(CsName, CsDescription, ohlcvComponent)
        {
            Moniker = CsMoniker;
            minParameterValue = Math.Ceiling(minParameterValue);
            maxParameterValue = Math.Floor(maxParameterValue);
            parameterRange = (maxParameterValue - minParameterValue);
            Corona = new Corona(highPassFilterCutoff, (int)minParameterValue, (int)maxParameterValue, minRasterValue, maxRasterValue);

            this.MinParameterValue = minParameterValue;
            this.MaxParameterValue = maxParameterValue;

            midRasterValue = 10;// maxRasterValue / 2;
        }
        #endregion

        #region Reset
        /// <inheritdoc />
        public override void Reset()
        {
            lock (updateLock)
            {
                primed = false;
                Corona.Reset();
            }
        }
        #endregion

        #region Update
        private HeatMap Update(double sample, DateTime dateTime)
        {
            if (double.IsNaN(sample))
                return null;
            primed = Corona.Update(sample);
            double[] intensity;
            if (primed)
            {
                intensity = new double[Corona.FilterBankLength];//+1
                int min = Corona.MinimalPeriodTimesTwo;
                int max = Corona.MaximalPeriodTimesTwo;
                for (int i = min; i <= max; ++i)
                {
                    double value = Corona.FilterBank[i - min].Decibels;
                    intensity[i - min] = value;
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
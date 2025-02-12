using System;
using System.Globalization;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// </summary>
    public sealed class CombBandPassSpectrum : Indicator, IHeatMapIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        public double MinParameterValue => estimator.MinPeriod;

        /// <summary>
        /// The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        public double MaxParameterValue => estimator.MaxPeriod;

        /// <summary>
        /// The length (the number of time periods) of the sample window.
        /// This also determines the maximum spectrum period.
        /// </summary>
        public int Length => estimator.Length;

        private int windowCount;
        private readonly CombBandPassSpectrumEstimator estimator;
        private readonly int lastIndex;
        private readonly double parameterRange;
        private readonly bool floatingNormalization;

        private const string Cbps = "cbps";
        private const string CbpsFull = "Comb BandPass Spectrum";
        private const string ArgumentLength = "length";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="length">The number of time periods in the spectrum window.</param>
        /// <param name="minPeriod">The minimum period to calculate, must be less than <c>length</c>.</param>
        /// <param name="isSpectralDilationCompensation">Specifies if the spectral dilation should be compensated.</param>
        /// <param name="isAutomaticGainControl">Specifies if the <c>fast attack − slow decay</c> automatic gain control should be used.</param>
        /// <param name="automaticGainControlDecayFactor">Specifies the decay factor for the <c>fast attack − slow decay</c> automatic gain control.</param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        /// <param name="floatingNormalization">Specifies if to use the floating normalization.</param>
        public CombBandPassSpectrum(int length = 48, int minPeriod = 10, bool isSpectralDilationCompensation = true,
            bool isAutomaticGainControl = true, double automaticGainControlDecayFactor = 0.991,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice, bool floatingNormalization = true)
            : base(Cbps, CbpsFull, ohlcvComponent)
        {
            if (2 > length)
                throw new ArgumentOutOfRangeException(ArgumentLength);
            estimator = new CombBandPassSpectrumEstimator(length, minPeriod,
                isSpectralDilationCompensation, isAutomaticGainControl, automaticGainControlDecayFactor);
            lastIndex = estimator.Length - 1;
            Moniker = string.Concat(Cbps, length.ToString(CultureInfo.InvariantCulture));
            parameterRange = estimator.MaxPeriod - estimator.MinPeriod;

            this.floatingNormalization = floatingNormalization;
        }
        #endregion

        #region Reset
        /// <inheritdoc />
        public override void Reset()
        {
            lock (updateLock)
            {
                primed = false;
                windowCount = 0;
                estimator.Reset();
            }
        }
        #endregion

        #region Update
        private HeatMap Update(double sample, DateTime dateTime)
        {
            if (double.IsNaN(sample))
                return null;
            double[] window = estimator.InputSeries;
            if (primed)
            {
                Array.Copy(window, 1, window, 0, lastIndex);
                //for (int i = 0; i < lastIndex; )
                //    window[i] = window[++i];
                window[lastIndex] = sample;
            }
            else // Not primed.
            {
                window[windowCount] = sample;
                if (estimator.Length == ++windowCount)
                    primed = true;
            }
            double[] intensity;
            if (primed)
            {
                estimator.Calculate();
                int lengthSpectrum = estimator.LengthSpectrum;
                intensity = new double[lengthSpectrum];
                double min = estimator.SpectrumMin;
                double max = estimator.SpectrumMax;
                double spectrumRange = max - min;
                if (!floatingNormalization)
                {
                    min = 0;
                    spectrumRange = max;
                }
                window = estimator.Spectrum;
                for (int i = 0; i < lengthSpectrum; ++i)
                {
                    double value = (window[i] - min) / spectrumRange;
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

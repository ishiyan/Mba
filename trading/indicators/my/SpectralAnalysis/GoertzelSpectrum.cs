using System;
using System.Globalization;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

namespace Mbs.Trading.Indicators.SpectralAnalysis
{
    /// <summary>
    /// Displays a spectrum power heat-map of the cyclic activity over a cycle period range using the Goertzel algorithm.
    /// </summary>
    public sealed class GoertzelSpectrum : Indicator, IHeatMapIndicator
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
        /// This determines the minimum and maximum spectrum periods.
        /// </summary>
        public int Length => estimator.Length;

        /// <summary>
        /// If the first or the second order algorithm is used.
        /// </summary>
        public bool IsFirstOrder => estimator.IsFirstOrder;

        /// <summary>
        /// If the spectral dilation compensation is used.
        /// </summary>
        public bool IsSpectralDilationCompensation => estimator.IsSpectralDilationCompensation;

        /// <summary>
        /// An automatic gain control decay factor.
        /// </summary>
        public double AutomaticGainControlDecayFactor => estimator.AutomaticGainControlDecayFactor;

        /// <summary>
        /// If the <c>fast attack − slow decay</c> automatic gain control is used.
        /// </summary>
        public bool IsAutomaticGainControl => estimator.IsAutomaticGainControl;

        /// <summary>
        /// The spectrum resolution (positive number).
        /// A value of 10 means that spectrum is evaluated at every 0.1 of periods amplitude.
        /// </summary>
        public int SpectrumResolution => estimator.SpectrumResolution;

        private int windowCount;
        private readonly GoertzelSpectrumEstimator estimator;
        private readonly int lastIndex;
        private readonly double parameterRange;
        private readonly bool floatingNormalization;

        private const string Gtz = "goertzel";
        private const string GtzFull = "Goertzel Spectrum";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="length">The number of time periods in the spectrum window.</param>
        /// <param name="minPeriod">The minimum period to calculate, must be less than the <c>maxPeriod</c>.</param>
        /// <param name="maxPeriod">The maximum period to calculate, must be less than or equal to 2 * length.</param>
        /// <param name="spectrumResolution">The spectrum resolution (positive number). A value of 10 means that spectrum is evaluated at every 0.1 of periods amplitude.</param>
        /// <param name="isFirstOrder">Specifies if the first or the second order algorithm should be used.</param>
        /// <param name="isSpectralDilationCompensation">Specifies if the spectral dilation should be compensated.</param>
        /// <param name="isAutomaticGainControl">Specifies if the <c>fast attack − slow decay</c> automatic gain control should be used.</param>
        /// <param name="automaticGainControlDecayFactor">Specifies the decay factor for the <c>fast attack − slow decay</c> automatic gain control.</param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        /// <param name="floatingNormalization">Specifies if to use the floating normalization.</param>
        public GoertzelSpectrum(int length = 64, double minPeriod = 2, double maxPeriod = 64, int spectrumResolution = 1, bool isFirstOrder = false,
            bool isSpectralDilationCompensation = true, bool isAutomaticGainControl = true, double automaticGainControlDecayFactor = 0.991,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice,
            bool floatingNormalization = true)
            : base(Gtz, GtzFull, ohlcvComponent)
        {
            if (2 > length)
                throw new ArgumentOutOfRangeException(nameof(length));
            estimator = new GoertzelSpectrumEstimator(length, minPeriod, maxPeriod, spectrumResolution, isFirstOrder,
                isSpectralDilationCompensation, isAutomaticGainControl, automaticGainControlDecayFactor);
            lastIndex = estimator.Length - 1;
            Moniker = string.Concat(Gtz, length.ToString(CultureInfo.InvariantCulture));
            parameterRange = estimator.MaxPeriod - estimator.MinPeriod;

            this.floatingNormalization = floatingNormalization;
        }
        #endregion

        #region Reset
        /// <inheritdoc />
        public override void Reset()
        {
            lock (Lock)
            {
                Primed = false;
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
            if (Primed)
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
                    Primed = true;
            }
            double[] intensity;
            if (Primed)
            {
                estimator.Calculate();
                int lengthSpectrum = estimator.LengthSpectrum;
                intensity = new double[lengthSpectrum];
                double min = floatingNormalization ? estimator.SpectrumMin : 0;
                double max = estimator.SpectrumMax;
                double spectrumRange = max - min;
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
            lock (Lock)
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
            lock (Lock)
            {
                return Update(scalar.Value, scalar.Time);
            }
        }
        #endregion
    }
}

using System;
using System.Globalization;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// </summary>
    public sealed class DiscreteFourierTransformSpectrum : Indicator, IHeatMapIndicator
    {
        #region Members and accessors
        /// <inheritdoc />
        public double MinParameterValue => estimator.MinPeriod;

        /// <inheritdoc />
        public double MaxParameterValue => estimator.MaxPeriod;

        /// <summary>
        /// The length (the number of time periods) of the sample window.
        /// This also determines the maximum spectrum period.
        /// </summary>
        public int Length => estimator.Length;

        private int windowCount;
        private readonly DiscreteFourierTransformSpectrumEstimator estimator;
        private readonly int lastIndex;
        private readonly bool floatingNormalization;

        private const string DftPs = "psDft";
        private const string DftPsFull = "Power spectrum estimation based on discrete Fourier transform";
        private const string ArgumentLength = "length";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="length">The number of time periods in the spectrum window.</param>
        /// <param name="minPeriod">The minimum period to calculate, must be less than <c>length</c>.</param>
        /// <param name="maxPeriod">The maximum period to calculate, must be less than or equal to 2 * length.</param>
        /// <param name="spectrumResolution">The spectrum resolution (positive number). A value of 10 means that spectrum is evaluated at every 0.1 of periods amplitude.</param>
        /// <param name="isSpectralDilationCompensation">Specifies if the spectral dilation should be compensated.</param>
        /// <param name="isAutomaticGainControl">Specifies if the <c>fast attack − slow decay</c> automatic gain control should be used.</param>
        /// <param name="automaticGainControlDecayFactor">Specifies the decay factor for the <c>fast attack − slow decay</c> automatic gain control.</param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        /// <param name="floatingNormalization">Specifies if to use the floating normalization.</param>
        public DiscreteFourierTransformSpectrum(int length = 48, int minPeriod = 10, int maxPeriod = 48, int spectrumResolution = 1,
            bool isSpectralDilationCompensation = true, bool isAutomaticGainControl = true, double automaticGainControlDecayFactor = 0.995,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice, bool floatingNormalization = true)
            : base(DftPs, DftPsFull, ohlcvComponent)
        {
            if (2 > length)
                throw new ArgumentOutOfRangeException(ArgumentLength);
            estimator = new DiscreteFourierTransformSpectrumEstimator(length, minPeriod, maxPeriod, spectrumResolution,
                isSpectralDilationCompensation, isAutomaticGainControl, automaticGainControlDecayFactor);
            lastIndex = estimator.Length - 1;
            Moniker = string.Concat(DftPs, length.ToString(CultureInfo.InvariantCulture));
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

        /// <inheritdoc />
        public HeatMap Update(Scalar scalar)
        {
            lock (updateLock)
            {
                return Update(scalar.Value, scalar.Time);
            }
        }

        /// <inheritdoc />
        public HeatMap Update(Ohlcv ohlcv)
        {
            lock (updateLock)
            {
                return Update(ohlcv.Component(OhlcvComponent), ohlcv.Time);
            }
        }
        #endregion
    }
}

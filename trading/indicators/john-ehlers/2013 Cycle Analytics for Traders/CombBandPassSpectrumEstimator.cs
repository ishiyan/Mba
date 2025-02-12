using System;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// Implements a comb band pass filter to estimate the spectrum.
    /// </summary>
    internal sealed class CombBandPassSpectrumEstimator
    {
        #region Members and accessors
        /// <summary>
        /// The length of the input series window.
        /// </summary>
        public readonly int Length;

        /// <summary>
        /// The length of the spectrum, <c>MaxPeriod - MinPeriod</c>.
        /// </summary>
        public readonly int LengthSpectrum;

        /// <summary>
        /// The minimal period.
        /// The minimal value, 2, corresponds to the Nyquist (the maximum representable) frequency.
        /// </summary>
        public readonly double MinPeriod;

        /// <summary>
        /// The maximal period is equal to the observed time lapse (Length).
        /// </summary>
        public readonly double MaxPeriod;

        /// <summary>
        /// An array of length <c>Length</c> containing input series window.
        /// </summary>
        public readonly double[] InputSeries;

        /// <summary>
        /// An array of length <c>LengthSpectrum</c> containing the estimated spectrum.
        /// </summary>
        public readonly double[] Spectrum;

        /// <summary>
        /// A minimum value of the estimated spectrum.
        /// </summary>
        public double SpectrumMin;

        /// <summary>
        /// A maximum value of the estimated spectrum.
        /// </summary>
        public double SpectrumMax;

        /// <summary>
        /// An automatic gain control decay factor.
        /// </summary>
        public readonly double AutomaticGainControlDecayFactor;

        /// <summary>
        /// If the <c>fast attack − slow decay</c> automatic gain control is used.
        /// </summary>
        public readonly bool IsAutomaticGainControl;

        /// <summary>
        /// If the spectral dilation compensation is used.
        /// </summary>
        public readonly bool IsSpectralDilationCompensation;

        /// <summary>
        /// An array of length <c>LengthSpectrum</c> containing the frequencies corresponding to the estimated spectrum.
        /// </summary>
        public readonly double[] Frequency;

        /// <summary>
        /// An array of length <c>LengthSpectrum</c> containing the periods corresponding to the estimated spectrum.
        /// </summary>
        public readonly double[] Period;

        private readonly double[][] frequencySinOmega;
        private readonly double[][] frequencyCosOmega;
        private readonly int maxOmegaLength;
        private double previousSpectrumMax;
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="length">The length of the input series window. This determines also the maximum period to calculate.</param>
        /// <param name="minPeriod">The minimum period to calculate, must be less than <c>length</c>.</param>
        /// <param name="isSpectralDilationCompensation">Specifies if the spectral dilation should be compensated.</param>
        /// <param name="isAutomaticGainControl">Specifies if the <c>fast attack − slow decay</c> automatic gain control should be used.</param>
        /// <param name="automaticGainControlDecayFactor">Specifies the decay factor for the <c>fast attack − slow decay</c> automatic gain control.</param>
        public CombBandPassSpectrumEstimator(int length = 48, int minPeriod = 10,
            bool isSpectralDilationCompensation = true, bool isAutomaticGainControl = true, double automaticGainControlDecayFactor = 0.991)
        {
            if (2 > length)
                length = 2;
            Length = length;
            if (2 > minPeriod)
                minPeriod = 2;
            if (length <= minPeriod)
                minPeriod = length - 1;
            MinPeriod = minPeriod;
            MaxPeriod = length;
            maxOmegaLength =length;
            LengthSpectrum = length - minPeriod;
            IsSpectralDilationCompensation = isSpectralDilationCompensation;
            IsAutomaticGainControl = isAutomaticGainControl;
            AutomaticGainControlDecayFactor = automaticGainControlDecayFactor;
            InputSeries = new double[length];
            Spectrum = new double[LengthSpectrum];
            Frequency = new double[LengthSpectrum];
            frequencySinOmega = new double[LengthSpectrum][];
            frequencyCosOmega = new double[LengthSpectrum][];
            Period = new double[LengthSpectrum];

            // Frequency is calculated so that we can plot the spectrum as a funcion of period's length,
            // starting from the MaxPeriod down to the MinPeriod.
            for (int i = 0; i < LengthSpectrum; ++i)
            {
                double period = MaxPeriod - i;
                //double period = MinPeriod + i;
                Period[i] = period;
                double frequency = Math.PI * 2 / period;
                Frequency[i] = frequency;
                var sinOmega = new double[maxOmegaLength];
                var cosOmega = new double[maxOmegaLength];
                frequencySinOmega[i] = sinOmega;
                frequencyCosOmega[i] = cosOmega;
                for (int j = 0; j < maxOmegaLength; ++j)
                {
                    //double omega = -(j + 1) * frequency;
                    double omega = j * frequency;
                    sinOmega[j] = Math.Sin(omega);
                    cosOmega[j] = Math.Cos(omega);
                }
                if (isSpectralDilationCompensation)
                {
                    for (int j = 0; j < maxOmegaLength; ++j)
                    {
                        sinOmega[j] /= period;
                        cosOmega[j] /= period;
                    }
                }
            }
        }
        #endregion

        #region Calculate
        /// <summary>
        /// Calculates the DFT power spectrum estimation of the <c>InputSeries</c>.
        /// </summary>
        public void Calculate()
        {
            SpectrumMin = double.MaxValue;
            SpectrumMax = IsAutomaticGainControl ? AutomaticGainControlDecayFactor * previousSpectrumMax : double.MinValue;
            for (int i = 0; i < LengthSpectrum; ++i)
            {
                double[] sinOmega = frequencySinOmega[i];
                double[] cosOmega = frequencyCosOmega[i];
                double sumSin = 0, sumCos = 0;
                for (int j = 0; j < maxOmegaLength; ++j)
                {
                    double sample = InputSeries[j];
                    sumSin += sample * sinOmega[j];
                    sumCos += sample * cosOmega[j];
                }
                double power = sumSin * sumSin + sumCos * sumCos;
                //power = 1d /power;
                Spectrum[i] = power;
                if (SpectrumMax < power)
                    SpectrumMax = power;
                if (SpectrumMin > power)
                    SpectrumMin = power;
            }
            previousSpectrumMax = SpectrumMax;
        }
        #endregion

        #region Reset
        /// <summary>
        /// Resets the estimator.
        /// </summary>
        public void Reset()
        {
            previousSpectrumMax = 0;
        }
        #endregion
    }
}

using System;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// Implements a Discrete Fourier Transform to estimate the spectrum.
    /// </summary>
    internal sealed class DiscreteFourierTransformSpectrumEstimator
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
        /// The value of 2 corresponds to the Nyquist (the maximum representable) frequency.
        /// </summary>
        public readonly double MinPeriod;

        /// <summary>
        /// The maximal period is equal to the observed time lapse (<c>Length</c>).
        /// </summary>
        public readonly double MaxPeriod;

        /// <summary>
        /// An array of length <c>Length</c> containing an input series window.
        /// </summary>
        public readonly double[] InputSeries;

        /// <summary>
        /// An array of length <c>Length</c> containing input series window samples with the mean value subtracted.
        /// </summary>
        public readonly double[] InputSeriesMinusMean;

        /// <summary>
        /// The mean value over the input series window.
        /// </summary>
        public double Mean;

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
        /// The spectrum resolution (positive number).
        /// A value of 10 means that spectrum is evaluated at every 0.1 of periods amplitude.
        /// </summary>
        public readonly int SpectrumResolution;

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
        /// <param name="minPeriod">The minimum period to calculate, must be less than the <c>maxPeriod</c>.</param>
        /// <param name="maxPeriod">The maximum period to calculate, must be less than or equal to 2 * length.</param>
        /// <param name="spectrumResolution">The spectrum resolution (positive number). A value of 10 means that spectrum is evaluated at every 0.1 of periods amplitude.</param>
        /// <param name="isSpectralDilationCompensation">Specifies if the spectral dilation should be compensated.</param>
        /// <param name="isAutomaticGainControl">Specifies if the <c>fast attack − slow decay</c> automatic gain control should be used.</param>
        /// <param name="automaticGainControlDecayFactor">Specifies the decay factor for the <c>fast attack − slow decay</c> automatic gain control.</param>
        public DiscreteFourierTransformSpectrumEstimator(int length = 48, int minPeriod = 10, int maxPeriod = 48, int spectrumResolution = 1,
            bool isSpectralDilationCompensation = true, bool isAutomaticGainControl = true, double automaticGainControlDecayFactor = 0.995)
        {
            Length = length;
            MinPeriod = 2 > minPeriod ? 2 : minPeriod;
            MaxPeriod = 2 > maxPeriod ? MinPeriod + 1 : maxPeriod;
            SpectrumResolution = spectrumResolution;
            maxOmegaLength = length;
            LengthSpectrum = (int)((MaxPeriod - MinPeriod) * spectrumResolution) + 1;
            IsSpectralDilationCompensation = isSpectralDilationCompensation;
            IsAutomaticGainControl = isAutomaticGainControl;
            AutomaticGainControlDecayFactor = automaticGainControlDecayFactor;
            InputSeries = new double[length];
            InputSeriesMinusMean = new double[length];
            Spectrum = new double[LengthSpectrum];
            Frequency = new double[LengthSpectrum];
            frequencySinOmega = new double[LengthSpectrum][];
            frequencyCosOmega = new double[LengthSpectrum][];
            Period = new double[LengthSpectrum];

            // Frequency is calculated so that we can plot the spectrum as a function of period's length,
            // starting from the MaxPeriod down to the MinPeriod.
            for (int i = 0; i < LengthSpectrum; ++i)
            {
                double period = MaxPeriod - (double)i / spectrumResolution;
                Period[i] = period;
                Frequency[i] = 1 / period;
                double theta = Math.PI * 2 / period;
                var sinOmega = new double[maxOmegaLength];
                var cosOmega = new double[maxOmegaLength];
                frequencySinOmega[i] = sinOmega;
                frequencyCosOmega[i] = cosOmega;
                for (int j = 0; j < maxOmegaLength; ++j)
                {
                    double omega = j * theta;
                    sinOmega[j] = Math.Sin(omega);
                    cosOmega[j] = Math.Cos(omega);
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
            // Determine and subtract the mean from the input series.
            double mean = 0.0;
            for (int i = 0; i != Length; ++i)
                mean += InputSeries[i];
            mean /= Length;
            for (int i = 0; i != Length; ++i)
                InputSeriesMinusMean[i] = InputSeries[i] - mean;
            Mean = mean;

            // Create an array with the spectrum values.
            SpectrumMin = double.MaxValue;
            SpectrumMax = IsAutomaticGainControl ? AutomaticGainControlDecayFactor * previousSpectrumMax : double.MinValue;
            for (int i = 0; i < LengthSpectrum; ++i)
            {
                double[] sinOmega = frequencySinOmega[i];
                double[] cosOmega = frequencyCosOmega[i];
                double sumSin = 0, sumCos = 0;
                for (int j = 0; j < maxOmegaLength; ++j)
                {
                    double sample = InputSeriesMinusMean[j];
                    sumSin += sample * sinOmega[j];
                    sumCos += sample * cosOmega[j];
                }
                double spectrum = sumSin * sumSin + sumCos * sumCos;
                if (IsSpectralDilationCompensation)
                    spectrum /= Period[i];
                Spectrum[i] = spectrum;
                if (SpectrumMax < spectrum)
                    SpectrumMax = spectrum;
                if (SpectrumMin > spectrum)
                    SpectrumMin = spectrum;
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

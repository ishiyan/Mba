using System;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// Implements an auto-correlation to estimate the spectrum.
    /// </summary>
    internal sealed class AutoCorrelationSpectrumEstimator
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
        public readonly int MinPeriod;

        /// <summary>
        /// The maximal period is equal to the observed time lapse (Length).
        /// </summary>
        public readonly int MaxPeriod;

        /// <summary>
        /// The number of last samples of the input series window which are used for averaging.
        /// The default value of 0 means the averaging length is equal to each lag.
        /// That way, the averaging contains the maximum number of data samples per lag.
        /// </summary>
        public int AveragingLength => estimator.AveragingLength;

        /// <summary>
        /// An array of length <c>Length</c> containing input series window.
        /// </summary>
        public double[] InputSeries => estimator.InputSeries;

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
        /// If the spectrum should is smoothed.
        /// </summary>
        public readonly bool IsSmoothed;

        /// <summary>
        /// An automatic gain control decay factor.
        /// </summary>
        public readonly double AutomaticGainControlDecayFactor;

        /// <summary>
        /// If the <c>fast attack − slow decay</c> automatic gain control is used.
        /// </summary>
        public readonly bool IsAutomaticGainControl;

        /// <summary>
        /// An array of length <c>LengthSpectrum</c> containing the frequencies corresponding to the estimated spectrum.
        /// </summary>
        public readonly double[] Frequency;

        /// <summary>
        /// An array of length <c>LengthSpectrum</c> containing the periods corresponding to the estimated spectrum.
        /// </summary>
        public readonly double[] Period;

        private readonly AutoCorrelationEstimator estimator;
        private double previousSpectrumMax;
        private readonly double[] previousSpectrum;
        private readonly double[][] frequencySinOmega;
        private readonly double[][] frequencyCosOmega;
        private readonly int correlationCoefficientsLength;
        private readonly double[] correlationCoefficients;
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="length">The length of the input series window. This determines also the maximum period to calculate.</param>
        /// <param name="minPeriod">The minimum period to calculate, must be less than the <c>maxPeriod</c>.</param>
        /// <param name="maxPeriod">The maximum period to calculate, must be less than or equal to length.</param>
        /// <param name="spectrumResolution">The spectrum resolution (positive number). A value of 10 means that spectrum is evaluated at every 0.1 of periods amplitude.</param>
        /// <param name="averagingLength">The number of last samples of the input series window which are used for averaging. The default value of 0 means the averaging length is equal to each lag. That way, the averaging contains the maximum number of data samples per lag.</param>
        /// <param name="isSmoothed">Specifies if the spectrum should be smoothed.</param>
        /// <param name="isAutomaticGainControl">Specifies if the <c>fast attack − slow decay</c> automatic gain control should be used.</param>
        /// <param name="automaticGainControlDecayFactor">Specifies the decay factor for the <c>fast attack − slow decay</c> automatic gain control.</param>
        public AutoCorrelationSpectrumEstimator(int length = 48, int minPeriod = 3, int maxPeriod = 47, int spectrumResolution = 1,
            int averagingLength = 0, bool isSmoothed = true, bool isAutomaticGainControl = true, double automaticGainControlDecayFactor = 0.995)
        {
            if (2 > length)
                length = 2;
            Length = length;
            MinPeriod = 2 > minPeriod ? 2 : minPeriod;
            MaxPeriod = 2 > maxPeriod ? (MinPeriod + 1) : maxPeriod;
            estimator = new AutoCorrelationEstimator(length, MinPeriod, MaxPeriod, averagingLength);
            //System.Diagnostics.Debug.Assert(length == estimator.Length);
            correlationCoefficientsLength = estimator.CorrelationCoefficientsLength;
            correlationCoefficients = estimator.CorrelationCoefficients;
            SpectrumResolution = spectrumResolution;
            LengthSpectrum = (MaxPeriod - MinPeriod) * spectrumResolution + 1;
            IsSmoothed = isSmoothed;
            IsAutomaticGainControl = isAutomaticGainControl;
            AutomaticGainControlDecayFactor = automaticGainControlDecayFactor;
            previousSpectrum = new double[LengthSpectrum];
            Spectrum = new double[LengthSpectrum];
            Frequency = new double[LengthSpectrum];
            frequencySinOmega = new double[LengthSpectrum][];
            frequencyCosOmega = new double[LengthSpectrum][];
            Period = new double[LengthSpectrum];

            // Frequency is calculated so that we can plot the spectrum as a funcion of period's length,
            // starting from the MaxPeriod down to the MinPeriod.
            for (int i = 0; i < LengthSpectrum; ++i)
            {
                previousSpectrum[i] = 0;
                double period = MaxPeriod - ((double)i / spectrumResolution);
                Period[i] = period;
                Frequency[i] = 1 / period;
                double theta = Math.PI * 2 / period;
                var sinOmega = new double[correlationCoefficientsLength];
                var cosOmega = new double[correlationCoefficientsLength];
                frequencySinOmega[i] = sinOmega;
                frequencyCosOmega[i] = cosOmega;
                for (int j = 0; j < correlationCoefficientsLength; ++j)
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
        /// Calculates the auto-correlation power spectrum estimation of the <c>InputSeries</c>.
        /// The <c>InputSeries</c> must be filled before this call.
        /// </summary>
        public void Calculate()
        {
            // The calculated correlation coefficients are in range [-1, 1].
            estimator.Calculate();

            // Create an array with the spectrum values.
            const double coeff1 = 0.2;
            const double coeff2 = 1 - coeff1;
            SpectrumMin = double.MaxValue;
            SpectrumMax = IsAutomaticGainControl ? AutomaticGainControlDecayFactor * previousSpectrumMax : double.MinValue;

            for (int i = 0; i < LengthSpectrum; ++i)
            {
                double[] sinOmega = frequencySinOmega[i];
                double[] cosOmega = frequencyCosOmega[i];
                double sumSin = 0, sumCos = 0;
                for (int j = 0; j < correlationCoefficientsLength; ++j)
                {
                    double sample = correlationCoefficients[j];
                    sumSin += sample * sinOmega[j];
                    sumCos += sample * cosOmega[j];
                }
                double spectrum = sumSin * sumSin + sumCos * sumCos;
                //spectrum *= spectrum;
                if (IsSmoothed)
                    spectrum = coeff1 * spectrum + coeff2 * previousSpectrum[i];
                previousSpectrum[i] = spectrum;
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
            for (int i = 0; i < LengthSpectrum; ++i)
                previousSpectrum[i] = 0;
        }
        #endregion
    }
}

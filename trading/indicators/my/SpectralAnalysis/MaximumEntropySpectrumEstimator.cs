using System;

namespace Mbs.Trading.Indicators.SpectralAnalysis
{
    /// <summary>
    /// Implements an auto-regressive (AR) model to estimate the AR coefficients using Burg maximum entropy method.
    /// <para/>
    /// <para/>
    /// </summary>
    internal sealed class MaximumEntropySpectrumEstimator
    {
        #region Members and accessors
        /// <summary>
        /// The length of the input series window.
        /// </summary>
        public readonly int Length;

        /// <summary>
        /// The degree (order) of auto-regression.
        /// </summary>
        public readonly int Degree;

        /// <summary>
        /// The spectrum resolution (positive number).
        /// A value of 10 means that spectrum is evaluated at every 0.1 of periods amplitude.
        /// </summary>
        public readonly int SpectrumResolution;

        /// <summary>
        /// The length of the spectrum, <c>(MaxPeriod - MinPeriod) * SpectrumResolution</c>.
        /// </summary>
        public readonly int LengthSpectrum;

        /// <summary>
        /// The minimal period. The lowest value, 2, corresponds to the Nyquist (the maximum representable) frequency
        /// <para/>
        /// ωⁿ = ωˢ/2
        /// <para/>
        /// where ωˢ is the sampling frequency.
        /// The ωˢ=1 because of it's normalization, so ωⁿ corresponds to 2 samples.
        /// </summary>
        public readonly double MinPeriod;

        /// <summary>
        /// The maximal period. The highest value is equal to the observed time lapse (Length samples).
        /// </summary>
        public readonly double MaxPeriod;

        /// <summary>
        /// An array of length <c>Length</c> containing input series window.
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
        /// An automatic gain control decay factor.
        /// </summary>
        public readonly double AutomaticGainControlDecayFactor;

        /// <summary>
        /// If the <c>fast attack − slow decay</c> automatic gain control is used.
        /// </summary>
        public readonly bool IsAutomaticGainControl;

        /// <summary>
        /// An array of length <c>Degree</c> containing the AR coefficients.
        /// </summary>
        public readonly double[] Coefficients;

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
        /// An array of length <c>LengthSpectrum</c> containing the frequencies corresponding to the estimated spectrum.
        /// </summary>
        public readonly double[] Frequency;

        /// <summary>
        /// An array of length <c>LengthSpectrum</c> containing the periods corresponding to the estimated spectrum.
        /// </summary>
        public readonly double[] Period;

        private readonly double[] h;
        private readonly double[] g;
        private readonly double[] per;
        private readonly double[] pef;
        private readonly double[][] frequencySinOmega;
        private readonly double[][] frequencyCosOmega;
        private double previousSpectrumMax;
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="MaximumEntropySpectrumEstimator"/> class.
        /// </summary>
        /// <param name="length">The length of the input series window.</param>
        /// <param name="degree">The degree (order) of auto-regression.</param>
        /// <param name="minPeriod">The minimum period to calculate, must be less than the <c>maxPeriod</c>.</param>
        /// <param name="maxPeriod">The maximum period to calculate, must be less than or equal to 2 * length.</param>
        /// <param name="spectrumResolution">The spectrum resolution (positive number). A value of 10 means that spectrum is evaluated at every 0.1 of periods amplitude.</param>
        /// <param name="isAutomaticGainControl">Specifies if the <c>fast attack − slow decay</c> automatic gain control should be used.</param>
        /// <param name="automaticGainControlDecayFactor">Specifies the decay factor for the <c>fast attack − slow decay</c> automatic gain control.</param>
        public MaximumEntropySpectrumEstimator(int length, int degree, int minPeriod, int maxPeriod, int spectrumResolution,
            bool isAutomaticGainControl = true, double automaticGainControlDecayFactor = 0.995)
        {
            Length = length;
            MinPeriod = 2 > minPeriod ? 2 : minPeriod;
            MaxPeriod = 2 > maxPeriod ? (MinPeriod + 1) : maxPeriod;
            degree = degree > 0 ? degree : length - 1;
            Degree = degree;
            SpectrumResolution = spectrumResolution;
            LengthSpectrum = (int)((MaxPeriod - MinPeriod) * spectrumResolution) + 1;
            IsAutomaticGainControl = isAutomaticGainControl;
            AutomaticGainControlDecayFactor = automaticGainControlDecayFactor;
            InputSeries = new double[length];
            InputSeriesMinusMean = new double[length];
            Coefficients = new double[degree];
            Spectrum = new double[LengthSpectrum];
            Frequency = new double[LengthSpectrum];
            frequencySinOmega = new double[LengthSpectrum][];
            frequencyCosOmega = new double[LengthSpectrum][];
            Period = new double[LengthSpectrum];
            h = new double[degree + 1];
            g = new double[degree + 2];
            per = new double[length + 1];
            pef = new double[length + 1];

            // Frequency is calculated so that we can plot the spectrum as a function of period's length,
            // starting from MaxPeriod down to MinPeriod with the given spectrum resolution.
            for (int i = 0; i < LengthSpectrum; ++i)
            {
                double period = MaxPeriod - (double)i / spectrumResolution;
                Period[i] = period;
                Frequency[i] = 1 / period;
                double theta = Math.PI * 2 / period;
                frequencySinOmega[i] = new double[degree];
                frequencyCosOmega[i] = new double[degree];
                for (int j = 0; j < degree; ++j)
                {
                    double omega = -(j + 1) * theta;
                    frequencySinOmega[i][j] = Math.Sin(omega);
                    frequencyCosOmega[i][j] = Math.Cos(omega);
                }
            }
        }
        #endregion

        #region Calculate
        /// <summary>
        /// Calculates the spectrum estimation of the <c>InputSeries</c>.
        /// Fills the <c>Mean</c>, the <c>InputSeriesMinusMean</c> and the <c>Spectrum</c> arrays.
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
            BurgEstimate(InputSeriesMinusMean);

            // Create an array with the spectrum values.
            SpectrumMin = double.MaxValue;
            SpectrumMax = IsAutomaticGainControl ? AutomaticGainControlDecayFactor * previousSpectrumMax : double.MinValue;
            for (int i = 0; i < LengthSpectrum; ++i)
            {
                // Calculates a spectrum value at a given frequency (in radians) from an auto-regression vector.
                double real = 1.0;
                double imag = 0.0;
                for (int j = 0; j < Degree; ++j)
                {
                    real -= Coefficients[j] * frequencyCosOmega[i][j];
                    imag -= Coefficients[j] * frequencySinOmega[i][j];
                }
                double spectrum = real * real + imag * imag;
                spectrum = 1 / spectrum;
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

        /// <summary>
        /// Estimates auto regression coefficients for the given degree using Burg maximum entropy method.
        /// </summary>
        /// <param name="series">The input series.</param>
        private void BurgEstimate(double[] series)
        {
            for (int i = 1; i <= Length; ++i)
            {
                pef[i] = 0;
                per[i] = 0;
            }
            for (int i = 1; i <= Degree; ++i)
            {
                double sn = 0; // Numerator.
                double sd = 0; // Denominator.
                int jj = Length - i;
                for (int j = 0; j < jj; ++j)
                {
                    double t1 = series[j + i] + pef[j];
                    double t2 = series[j] + per[j];
                    sn -= 2.0 * t1 * t2;
                    sd += (t1 * t1) + (t2 * t2);
                }
                double t = sn / sd;
                g[i] = t;
                if (i != 1)
                {
                    for (int j = 1; j < i; ++j)
                        h[j] = g[j] + t * g[i - j];
                    for (int j = 1; j < i; ++j)
                        g[j] = h[j];
                    --jj;
                }
                for (int j = 0; j < jj; ++j)
                {
                    per[j] += t * pef[j] + t * series[j + i];
                    pef[j] = pef[j + 1] + t * per[j + 1] + t * series[j + 1];
                }
            }
            for (int i = 0; i < Degree; ++i)
                Coefficients[i] = -g[i + 1];
        }
    }
}

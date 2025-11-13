using System;

namespace Mbs.Trading.Indicators.SpectralAnalysis
{
    /// <summary>
    /// Implements a spectrum estimator using the Goertzel algorithm.
    /// </summary>
    internal sealed class GoertzelSpectrumEstimator
    {
        #region Members and accessors
        /// <summary>
        /// The length of the input series window.
        /// </summary>
        public readonly int Length;

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
        /// </summary>
        public readonly double MinPeriod;

        /// <summary>
        /// The maximal period. The highest value is equal to the observed time lapse (Lenth samples).
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
        /// If the spectral dilation compensation is used.
        /// </summary>
        public readonly bool IsSpectralDilationCompensation;

        /// <summary>
        /// If the first or the second order algorithm is used.
        /// </summary>
        public readonly bool IsFirstOrder; 

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

        private double previousSpectrumMax;
        private readonly double[] frequencySin;
        private readonly double[] frequencyCos;
        private readonly double[] frequencyCos2;
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="length">The length of the input series window.</param>
        /// <param name="minPeriod">The minimum period to calculate, must be less than the <c>maxPeriod</c>.</param>
        /// <param name="maxPeriod">The maximum period to calculate, must be less than or equal to 2 * length.</param>
        /// <param name="spectrumResolution">The spectrum resolution (positive number). A value of 10 means that spectrum is evaluated at every 0.1 of periods amplitude.</param>
        /// <param name="isFirstOrder">Specifies if the first or the second order algorithm should be used.</param>
        /// <param name="isSpectralDilationCompensation">Specifies if the spectral dilation should be compensated.</param>
        /// <param name="isAutomaticGainControl">Specifies if the <c>fast attack − slow decay</c> automatic gain control should be used.</param>
        /// <param name="automaticGainControlDecayFactor">Specifies the decay factor for the <c>fast attack − slow decay</c> automatic gain control.</param>
        public GoertzelSpectrumEstimator(int length, double minPeriod, double maxPeriod, int spectrumResolution,
            bool isFirstOrder = false, bool isSpectralDilationCompensation = true, bool isAutomaticGainControl = true, double automaticGainControlDecayFactor = 0.995)
        {
            Length = length;
            MinPeriod = 2 > minPeriod ? 2 : minPeriod;
            MaxPeriod = 2 > maxPeriod ? (MinPeriod + 1) : maxPeriod;
            SpectrumResolution = spectrumResolution;
            LengthSpectrum = (int)((MaxPeriod - MinPeriod) * spectrumResolution) + 1;
            InputSeries = new double[length];
            InputSeriesMinusMean = new double[length];
            Spectrum = new double[LengthSpectrum];
            Frequency = new double[LengthSpectrum];
            Period = new double[LengthSpectrum];
            IsSpectralDilationCompensation = isSpectralDilationCompensation;
            IsAutomaticGainControl = isAutomaticGainControl;
            AutomaticGainControlDecayFactor = automaticGainControlDecayFactor;
            IsFirstOrder = isFirstOrder;

            // Frequency is calculated so that we can plot the spectrum as a function of period's length,
            // starting from MaxPeriod down to MinPeriod with the given spectrum resolution.
            if (isFirstOrder)
            {
                frequencySin = new double[LengthSpectrum];
                frequencyCos = new double[LengthSpectrum];
                for (int i = 0; i < LengthSpectrum; ++i)
                {
                    double period = MaxPeriod - (double)i / spectrumResolution;
                    Period[i] = period;
                    Frequency[i] = 1 / period;
                    double theta = Math.PI * 2 / period;
                    frequencySin[i] = Math.Sin(theta);
                    frequencyCos[i] = Math.Cos(theta);
                }
            }
            else
            {
                frequencyCos2 = new double[LengthSpectrum];
                for (int i = 0; i < LengthSpectrum; ++i)
                {
                    double period = MaxPeriod - ((double)i / spectrumResolution);
                    Period[i] = period;
                    Frequency[i] = 1 / period;
                    frequencyCos2[i] = 2 * Math.Cos(Math.PI * 2 / period);
                }
            }
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

            // Create an array with the spectrum values.
            SpectrumMin = double.MaxValue;
            SpectrumMax = IsAutomaticGainControl ? AutomaticGainControlDecayFactor * previousSpectrumMax : double.MinValue;
            double spectrum = IsFirstOrder ? GoertzelFirstOrderEstimate(0) : GoertzelSecondOrderEstimate(0);
            if (IsSpectralDilationCompensation)
                spectrum /= Period[0];
            Spectrum[0] = spectrum;
            SpectrumMin = spectrum;
            SpectrumMax = IsAutomaticGainControl ? AutomaticGainControlDecayFactor * previousSpectrumMax : spectrum;
            if (IsFirstOrder)
            {
                for (int i = 1; i < LengthSpectrum; ++i)
                {
                    spectrum = GoertzelFirstOrderEstimate(i);
                    if (IsSpectralDilationCompensation)
                        spectrum /= Period[i];
                    Spectrum[i] = spectrum;
                    if (SpectrumMax < spectrum)
                        SpectrumMax = spectrum;
                    else if (SpectrumMin > spectrum)
                        SpectrumMin = spectrum;
                }
            }
            else
            {
                for (int i = 1; i < LengthSpectrum; ++i)
                {
                    spectrum = GoertzelSecondOrderEstimate(i);
                    if (IsSpectralDilationCompensation)
                        spectrum /= Period[i];
                    Spectrum[i] = spectrum;
                    if (SpectrumMax < spectrum)
                        SpectrumMax = spectrum;
                    else if (SpectrumMin > spectrum)
                        SpectrumMin = spectrum;
                }
            }
            previousSpectrumMax = SpectrumMax;
        }
        #endregion

        private double GoertzelSecondOrderEstimate(int j)
        {
            double cos2 = frequencyCos2[j];
            double s1 = 0, s2 = 0;
            for (int i = 0; i != Length; ++i)
            {
                double s0 = InputSeriesMinusMean[i] + cos2 * s1 - s2;
                s2 = s1;
                s1 = s0;
            }
            double spectrum = s1 * s1 + s2 * s2 - cos2 * s1 * s2;
            return spectrum < 0 ? 0 : spectrum;
        }

        private double GoertzelFirstOrderEstimate(int j)
        {
            double cosTheta = frequencyCos[j], sinTheta = frequencySin[j];
            double yre = 0, yim = 0;
            for (int i = 0; i != Length; ++i)
            {
                double re = InputSeriesMinusMean[i] + cosTheta * yre - sinTheta * yim;
                double im = InputSeriesMinusMean[i] + cosTheta * yim + sinTheta * yre;
                yre = re;
                yim = im;
            }
            return yre * yre + yim * yim;
        }
    }
}

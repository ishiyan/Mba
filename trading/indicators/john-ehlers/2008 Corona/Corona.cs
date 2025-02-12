using System;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// Corona.
    /// <para />
    /// </summary>
    internal sealed class Corona
    {
        #region Filter
        internal struct Filter
        {
            internal double InPhase, InPhase1;
            internal double Quadrature, Quadrature1;
            internal double Real, Real1;
            internal double Imaginary, Imaginary1;
            internal double AmplitudeSquared;
            internal double Decibels;

            internal void Clear()
            {
                InPhase = 0;
                InPhase1 = 0;
                Quadrature = 0;
                Quadrature1 = 0;
                Real = 0;
                Real1 = 0;
                Imaginary = 0;
                Imaginary1 = 0;
                AmplitudeSquared = 0;
                Decibels = 0;
            }
        }
        #endregion

        #region Members and accessors
        private long sampleCount;
        private double samplePrevious;
        internal bool IsPrimed;
        internal double MaximalAmplitudeSquared;

        #region Detrending (high-pass filter)
        private const int HighPassFilterBufferSize = 6;
        private const int HighPassFilterBufferSizeMinOne = HighPassFilterBufferSize - 1;
        private readonly double[] highPassFilterBuffer = new double[HighPassFilterBufferSize];

        /// <summary>
        /// α = (1 - sin(2π/λ)) / cos(2π/λ),
        /// <para>where λ is the high-pass filter cutoff  (de-trending period).</para>
        /// </summary>
        private readonly double alpha;

        /// <summary>
        /// (1 + α)/2
        /// </summary>
        private readonly double halfOnePlusAlpha;

        /// <summary>
        /// The high-pass filter cutoff (de-trending period). Suggested values are 20, 30, 100.
        /// </summary>
        internal readonly int HighPassFilterCutoff;
        #endregion

        #region Smoothing (low-pass 6-tap FIR filter)
        private double smoothedHighPassFilter;
        private double smoothedHighPassFilterPrevious;

        /// <summary>
        /// new int[highPassFilterBufferSize]
        /// </summary>
        private static readonly int[] HighPassFilterSmoothingCoefficients = { 1, 2, 3, 3, 2, 1 };

        /// <summary>
        /// Sum of the coefficients of the <c>highPassFilterSmoothingCoefficients</c>.
        /// </summary>
        private const int HighPassFilterSmoothingDenominator = 12;
        #endregion

        #region Filter bank
        private const double DeltaLowerThreshold = 0.1; //0.1 or 0.15?
        private const double DeltaFactor = -0.015;
        private const double DeltaSummand = 0.5;
        private readonly double decibelsUpperThreshold;

        /// <summary>
        /// The filter bank.
        /// </summary>
        internal readonly Filter[] FilterBank;

        /// <summary>
        /// The length of the filter bank, 2 * (maximal period - minimal period).
        /// </summary>
        internal readonly int FilterBankLength;

        /// <summary>
        /// 2 * minimal period. This is used to simulate 0.5 period step using integer indices.
        /// </summary>
        internal readonly int MinimalPeriodTimesTwo;

        /// <summary>
        /// 2 * maximal period. This is used to simulate 0.5 period step using integer indices.
        /// </summary>
        internal readonly int MaximalPeriodTimesTwo;

        /// <summary>
        /// The minimal period.
        /// </summary>
        internal readonly int MinimalPeriod;

        /// <summary>
        /// The maximal period.
        /// </summary>
        internal readonly int MaximalPeriod;

        /// <summary>
        /// Contains pre-calculated βᵢ=cos(2π/λᵢ), where λᵢ = {MinimalPeriodTimesTwo/2 ... MaximalPeriodTimesTwo/2}.
        /// </summary>
        private readonly double[] preCalculatedBeta;
        #endregion

        #region Dominant cycle
        private readonly double decibelsLowerThreshold;
        private const int DominantCycleMedianIndex = 2;
        private const int DominantCycleBufferSize = 5;
        private const int DominantCycleBufferSizeMinOne = DominantCycleBufferSize - 1;
        private readonly double[] dominantCycleBuffer = new double[DominantCycleBufferSize];

        /// <summary>
        /// Serialization is not needed.
        /// </summary>
        private readonly double[] dominantCycleBufferSorted = new double[DominantCycleBufferSize];

        /// <summary>
        /// The current value of the dominant cycle.
        /// </summary>
        internal double DominantCycle = double.MaxValue;

        /// <summary>
        /// The current value of the dominant cycle median.
        /// </summary>
        internal double DominantCycleMedian = double.MaxValue;
        #endregion
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="highPassFilterCutoff">The high-pass filter cutoff (de-trending period). Suggested values are 20, 30, 100.</param>
        /// <param name="minimalPeriod">The minimal period. The default value is 6.</param>
        /// <param name="maximalPeriod">The maximal period. The default value is 30.</param>
        /// <param name="decibelsLowerThreshold">The lower threshold for decibels. The default value is 6.</param>
        /// <param name="decibelsUpperThreshold">The upper threshold for decibels. The default value is 20.</param>
        internal Corona(int highPassFilterCutoff = 30, int minimalPeriod = 6, int maximalPeriod = 30, double decibelsLowerThreshold = 6, double decibelsUpperThreshold = 20)
        {
            HighPassFilterCutoff = highPassFilterCutoff;

            double phi = Math.PI * 2 / highPassFilterCutoff;
            alpha = (1 - Math.Sin(phi)) / Math.Cos(phi);
            halfOnePlusAlpha = (1 + alpha) / 2;

            this.decibelsLowerThreshold = decibelsLowerThreshold;
            this.decibelsUpperThreshold = decibelsUpperThreshold;

            MinimalPeriod = minimalPeriod;
            MaximalPeriod = maximalPeriod;
            MinimalPeriodTimesTwo = minimalPeriod * 2;
            MaximalPeriodTimesTwo = maximalPeriod * 2;
            FilterBankLength = MaximalPeriodTimesTwo - MinimalPeriodTimesTwo + 1;
            FilterBank = new Filter[FilterBankLength];

            preCalculatedBeta = new double[FilterBankLength];
            for (int i = MinimalPeriodTimesTwo; i <= MaximalPeriodTimesTwo; ++i)
                preCalculatedBeta[i - MinimalPeriodTimesTwo] = Math.Cos(Math.PI * 4 / i);
        }
        #endregion

        #region Reset
        /// <summary>
        /// Resets the indicator.
        /// </summary>
        internal void Reset()
        {
            IsPrimed = false;
            sampleCount = 0;
            samplePrevious = 0;
            smoothedHighPassFilter = 0;
            DominantCycle = double.MaxValue;
            DominantCycleMedian = double.MaxValue;
            foreach (var filter in FilterBank)
                filter.Clear();
            for (int i = 0; i < HighPassFilterBufferSize; ++i )
                highPassFilterBuffer[i] = 0;
            for (int i = 0; i < DominantCycleBufferSize; ++i)
                dominantCycleBuffer[i] = double.MaxValue;
        }
        #endregion

        #region Update
        internal bool Update(double sample)
        {
            if (1 == ++sampleCount)
            {
                samplePrevious = sample;
                return false;
            }

            // De-trend data by high-pass filtering with a selected period cutoff.
            double highPassFilter = alpha * highPassFilterBuffer[HighPassFilterBufferSizeMinOne] + halfOnePlusAlpha * (sample - samplePrevious);
            samplePrevious = sample;
            for (int i = 0; i < HighPassFilterBufferSizeMinOne;)
                highPassFilterBuffer[i] = highPassFilterBuffer[++i];
            highPassFilterBuffer[HighPassFilterBufferSizeMinOne] = highPassFilter;

            // 6-tap low-pass FIR filter.
            smoothedHighPassFilter = 0;
            for (int i = 0; i < HighPassFilterBufferSize; ++i)
                smoothedHighPassFilter += highPassFilterBuffer[i] * HighPassFilterSmoothingCoefficients[i];
            smoothedHighPassFilter /= HighPassFilterSmoothingDenominator;

            // Calculate the momentum(1) on the smoothed de-trended data.
            double momentum = smoothedHighPassFilter - smoothedHighPassFilterPrevious;
            smoothedHighPassFilterPrevious = smoothedHighPassFilter;

            double delta = DeltaFactor * sampleCount + DeltaSummand;
            if (delta < DeltaLowerThreshold)
                delta = DeltaLowerThreshold;

            MaximalAmplitudeSquared = 0;
            for (int i = MinimalPeriodTimesTwo; i <= MaximalPeriodTimesTwo; ++i)
            //Parallel.For(MinimalPeriodTimesTwo, MaximalPeriodTimesTwo + 1, i =>
            {
                double gamma = 1 / Math.Cos(8 * Math.PI * delta / i);
                double a = gamma - Math.Sqrt(gamma * gamma - 1);
                double quadrature = momentum * (i / (4 * Math.PI));
                double inPhase = smoothedHighPassFilter;
                double halfOneMinA = (1 - a) / 2;
                int index = i - MinimalPeriodTimesTwo;
                double betaOnePlusA = preCalculatedBeta[index] * (1 + a);

                Filter filter = FilterBank[index];
                double real = halfOneMinA * (inPhase - filter.InPhase1) + betaOnePlusA * filter.Real - a * filter.Real1;
                double imaginary = halfOneMinA * (quadrature - filter.Quadrature1) + betaOnePlusA * filter.Imaginary - a * filter.Imaginary1;
                filter.InPhase1 = filter.InPhase;
                filter.InPhase = inPhase;
                filter.Quadrature1 = filter.Quadrature;
                filter.Quadrature = quadrature;
                filter.Real1 = filter.Real;
                filter.Real = real;
                filter.Imaginary1 = filter.Imaginary;
                filter.Imaginary = imaginary;

                double amplitudeSquared = real * real + imaginary * imaginary;
                if (amplitudeSquared > MaximalAmplitudeSquared)
                    MaximalAmplitudeSquared = amplitudeSquared;
                filter.AmplitudeSquared = amplitudeSquared;
                FilterBank[index] = filter;
            }//);

            double numerator = 0, denominator = 0;
            DominantCycle = 0;
            for (int i = MinimalPeriodTimesTwo; i <= MaximalPeriodTimesTwo; ++i)
            //Parallel.For(MinimalPeriodTimesTwo, MaximalPeriodTimesTwo + 1, i =>
            {
                int index = i - MinimalPeriodTimesTwo;
                Filter filter = FilterBank[index];

                // Calculate smoothed decibels.
                double normalized, decibels = 0;
                if (MaximalAmplitudeSquared > 0 && (normalized = filter.AmplitudeSquared / MaximalAmplitudeSquared) > 0)
                    decibels = 10 * Math.Log10((1 - 0.99 * normalized) / 0.01);
                decibels = 0.33 * decibels + 0.67 * filter.Decibels;
                if (decibels > decibelsUpperThreshold)
                    decibels = decibelsUpperThreshold;
                FilterBank[index].Decibels = decibels;

                // Dominant cycle calculation.
                if (decibels <= decibelsLowerThreshold)
                {
                    decibels = decibelsUpperThreshold - decibels;
                    numerator += i * decibels;
                    denominator += decibels;
                }
            }//);
            if (Math.Abs(denominator) > double.Epsilon)
                DominantCycle = 0.5 * numerator / denominator;
            if (DominantCycle < MinimalPeriod)
                DominantCycle = MinimalPeriod;

            // Dominant cycle median calculation.
            for (int i = 0; i < DominantCycleBufferSizeMinOne;)
                dominantCycleBuffer[i] = dominantCycleBuffer[++i];
            dominantCycleBuffer[DominantCycleBufferSizeMinOne] = DominantCycle;
            for (int i = 0; i < DominantCycleBufferSize; ++i)
                dominantCycleBufferSorted[i] = dominantCycleBuffer[i];
            Array.Sort(dominantCycleBufferSorted);
            DominantCycleMedian = dominantCycleBufferSorted[DominantCycleMedianIndex];
            if (DominantCycleMedian < MinimalPeriod)
                DominantCycleMedian = MinimalPeriod;

            if (MinimalPeriodTimesTwo > sampleCount)
                return false;
            IsPrimed = true;
            return true;
        }
        #endregion
    }
}
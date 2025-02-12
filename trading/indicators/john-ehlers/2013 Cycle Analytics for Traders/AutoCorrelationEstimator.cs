using System;
using Mbs.Numerics;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// Estimates sample Pearson auto-correlation coefficients.
    /// </summary>
    internal sealed class AutoCorrelationEstimator
    {
        #region Members and accessors
        /// <summary>
        /// The length of the input series window.
        /// </summary>
        public readonly int Length;

        /// <summary>
        /// The length of the correlation coefficients array, <c>MaxLag - MinLag</c>.
        /// </summary>
        public readonly int CorrelationCoefficientsLength;

        /// <summary>
        /// The number of last samples of the input series window which are used for averaging.
        /// The default value of 0 means the averaging length is equal to each lag.
        /// That way, the averaging contains the maximum number of data samples per lag.
        /// </summary>
        public readonly int AveragingLength;

        /// <summary>
        /// The minimal lag to compute correlation coefficients.
        /// The minimal value of 2 corresponds to the Nyquist (the maximum representable) frequency.
        /// </summary>
        public readonly int MinLag;

        /// <summary>
        /// The maximal lag is equal to the observed time lapse (Length).
        /// </summary>
        public readonly int MaxLag;

        /// <summary>
        /// An array of length <c>Length</c> containing input series window.
        /// </summary>
        public readonly double[] InputSeries;

        /// <summary>
        /// An array of length <c>CorrelationCoefficientsLength</c> containing the estimated correlation coefficients.
        /// </summary>
        public readonly double[] CorrelationCoefficients;

        /// <summary>
        /// A minimum value of the estimated correlation coefficients. The minimal possible value is -1.
        /// </summary>
        public double CorrelationCoefficientsMin;

        /// <summary>
        /// A maximum value of the estimated correlation coefficients. The maximal possible value is 1.
        /// </summary>
        public double CorrelationCoefficientsMax;

        /// <summary>
        /// An array of length <c>CorrelationsLength</c> containing the lags corresponding to the estimated correlations.
        /// </summary>
        public readonly int[] CorrelationLags;
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="length">The length of the input series window. This determines also the maximum lag to calculate. The minimal value is 2.</param>
        /// <param name="minLag">The minimum lag to compute correlation coefficients, must be less than <c>length</c>.</param>
        /// <param name="maxLag">The maximum lag to compute correlation coefficients, must be less or equal to <c>length</c>.</param>
        /// <param name="averagingLength">The number of last samples of the input series window which are used for averaging. The default value of 0 means the averaging length is equal to each lag. That way, the averaging contains the maximum number of data samples per lag.</param>
        public AutoCorrelationEstimator(int length = 48, int minLag = 3, int maxLag = 47, int averagingLength = 0)
        {
            if (2 > length)
                length = 2;
            Length = length;
            if (2 > minLag)
                minLag = 2;
            if (2 > maxLag)
                maxLag = 2;
            if (length <= minLag)
                minLag = length - 1;
            if (length <= maxLag)
                maxLag = length - 1;
            MinLag = minLag;
            MaxLag = maxLag;
            CorrelationCoefficientsLength = maxLag - minLag;
            InputSeries = new double[Length];
            CorrelationCoefficients = new double[CorrelationCoefficientsLength];
            CorrelationLags = new int[CorrelationCoefficientsLength];
            if (length <= averagingLength)
                averagingLength = length - 1;
            AveragingLength = averagingLength;

            // Lags age calculated so that we can plot them starting from the MaxLag down to the MinLag.
            for (int i = 0; i < CorrelationCoefficientsLength; ++i)
            {
                int lag = MaxLag - i;
                CorrelationLags[i] = lag;
            }
        }
        #endregion

        #region Calculate
        /// <summary>
        /// Calculates sample auto-correlation Pearson coefficients of the <c>InputSeries</c> using stable algorithm.
        /// The <c>InputSeries</c> must be filled before this call.
        /// </summary>
        public void Calculate()
        {
            CorrelationCoefficientsMin = double.MaxValue;
            CorrelationCoefficientsMax = double.MinValue;
            for (int i = 0; i < CorrelationCoefficientsLength; ++i)
            {
                int lag = CorrelationLags[i];
                // This is always at least 1, because the maximal value of both lag and AveragingLength is length - 1.
                int maxLength = Length - lag;
                if (AveragingLength > 1 && maxLength > AveragingLength)
                    maxLength = AveragingLength;
                double meanX = 0, meanY = 0;
                for (int j = 0; j < maxLength; ++j)
                {
                    meanX += InputSeries[j];
                    meanY += InputSeries[j + lag];
                }
                meanX /= maxLength;
                meanY /= maxLength;
                double sumXx = 0, sumYy = 0, sumXy = 0;
                for (int j = 0; j < maxLength; ++j)
                {
                    double x = InputSeries[j] - meanX, y = InputSeries[j + lag] - meanY;
                    sumXx += x * x;
                    sumXy += x * y;
                    sumYy += y * y;
                }
                // Sample Pearson correlation coefficient in range [-1, 1].
                double r = sumXy / (Math.Sqrt(sumXx * sumYy) + Constants.SqrtDoubleEpsilon);
                CorrelationCoefficients[i] = r;
                if (CorrelationCoefficientsMax < r)
                    CorrelationCoefficientsMax = r;
                if (CorrelationCoefficientsMin > r)
                    CorrelationCoefficientsMin = r;
            }
        }
/*
        /// <summary>
        /// Calculates sample auto-correlation Pearson coefficients of the <c>InputSeries</c> using unstable algorithm.
        /// The <c>InputSeries</c> must be filled before this call.
        /// </summary>
        public void Calculate()
        {
            CorrelationCoefficientsMin = double.MaxValue;
            CorrelationCoefficientsMax = double.MinValue;
            for (int i = 0; i < CorrelationCoefficientsLength; ++i)
            {
                double sumX = 0, sumY = 0, sumXx = 0, sumYy = 0, sumXy = 0;
                int lag = CorrelationLags[i];
                // This is always at least 1, because the maximal value of both lag and AveragingLength is length - 1.
                int maxLength = Length - (AveragingLength < 1 ? lag : AveragingLength);
                for (int j = 0; j < maxLength; ++j)
                {
                    double x = InputSeries[j], y = InputSeries[j + lag];
                    sumX += x;
                    sumXx += x * x;
                    sumXy += x * y;
                    sumY += y;
                    sumYy += y * y;
                }
                // Sample Pearson correlation coefficient in range [-1, 1].
                double r = (maxLength * sumXx - sumX * sumX) * (maxLength * sumYy - sumY * sumY);
                r = r > 0 ? (maxLength * sumXy - sumX * sumY) / Math.Sqrt(r) : 0;
                CorrelationCoefficients[i] = r;
                if (CorrelationCoefficientsMax < r)
                    CorrelationCoefficientsMax = r;
                if (CorrelationCoefficientsMin > r)
                    CorrelationCoefficientsMin = r;
            }
        }
*/
        #endregion
    }
}

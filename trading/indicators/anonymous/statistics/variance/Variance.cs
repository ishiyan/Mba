using System;
using System.Collections.Generic;
using System.Globalization;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

namespace Mbs.Trading.Indicators
{
    /// <summary>
    /// Computes the variance of the samples within a moving window of length <c>ℓ</c>:
    /// <para><c>σ² = (∑xᵢ² - (∑xᵢ)²/ℓ)/ℓ</c></para><para>for the estimation of the population variance, or as</para>
    /// <para><c>σ² = (∑xᵢ² - (∑xᵢ)²/ℓ)/(ℓ-1)</c></para><para>for the unbiased estimation of the sample variance, <c>i={0,…,ℓ-1}</c>.</para>
    /// </summary>
    public sealed class Variance : Indicator, ILineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// If the estimate of the variance is the unbiased sample variance or the population variance. The default value is true.
        /// </summary>
        public bool IsUnbiased { get; }

        /// <summary>
        /// The length <c>ℓ</c> (the number of time periods).
        /// </summary>
        public int Length { get; }

        private double value = double.NaN;
        /// <summary>
        /// The current value of the variance, <c>σ²</c>, or <c>NaN</c> if not primed.
        /// Depending on the <see cref="IsUnbiased"/>, the value is the unbiased sample variance or the population variance.
        /// The indicator is not primed during the first <c>ℓ-1</c> updates, where e <c>ℓ</c> is the length.
        /// </summary>
        public double Value { get { lock (Lock) { return value; } } }

        private readonly int lastIndex;
        private int windowCount;
        private readonly double[] window;
        private double windowSum;
        private double windowSquaredSum;

        private const string Var = "VAR";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="Variance"/> class.
        /// </summary>
        /// <param name="length">The number of time periods, <c>ℓ</c>.</param>
        /// <param name="unbiased">If the estimate of the variance is the unbiased sample variance or the population variance. The default value is true.</param>
        public Variance(int length, bool unbiased = true)
            : this(OhlcvComponent.ClosingPrice, length, unbiased)
        {
        }

        /// <summary>
        /// Constructs a new instance of the <see cref="Variance"/> class.
        /// </summary>
        /// <param name="ohlcvComponent">The ohlcv component.</param>
        /// <param name="length">The number of time periods, <c>ℓ</c>.</param>
        /// <param name="unbiased">If the estimate of the variance is the unbiased sample variance or the population variance. The default value is true.</param>
        public Variance(OhlcvComponent ohlcvComponent, int length, bool unbiased = true)
            : base(Var, "Variance", ohlcvComponent)
        {
            if (2 > length)
                throw new ArgumentOutOfRangeException(nameof(length));
            IsUnbiased = unbiased;
            Length = length;
            lastIndex = length - 1;
            window = new double[length];
            Moniker = string.Concat(Var, length.ToString(CultureInfo.InvariantCulture));
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
                windowSum = 0d;
                windowSquaredSum = 0d;
                value = double.NaN;
            }
        }
        #endregion

        #region Update
        /// <summary>
        /// Updates the value of the variance, <c>σ²</c>.
        /// Depending on the <see cref="IsUnbiased"/>, the value is the unbiased sample variance or the population variance.
        /// The indicator is not primed during the first <c>ℓ-1</c> updates.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public double Update(double sample)
        {
            if (double.IsNaN(sample))
                return sample;
            lock (Lock)
            {
                double temp = sample;
                if (Primed)
                {
                    windowSum += temp;
                    temp *= temp;
                    windowSquaredSum += temp;
                    temp = window[0];
                    windowSum -= temp;
                    temp *= temp;
                    windowSquaredSum -= temp;
                    if (IsUnbiased)
                    {
                        temp = windowSum;
                        temp *= temp;
                        temp /= Length;
                        value = windowSquaredSum - temp;
                        value /= lastIndex;
                    }
                    else
                    {
                        temp = windowSum / Length;
                        temp *= temp;
                        value = windowSquaredSum / Length - temp;
                    }
                    //Array.Copy(window, 0, window, 1, lastIndex);
                    for (int i = 0; i < lastIndex; )
                        window[i] = window[++i];
                    window[lastIndex] = sample;
                }
                else // Not primed.
                {
                    windowSum += temp;
                    window[windowCount] = temp;
                    temp *= temp;
                    windowSquaredSum += temp;
                    if (Length == ++windowCount)
                    {
                        Primed = true;
                        if (IsUnbiased)
                        {
                            temp = windowSum;
                            temp *= temp;
                            temp /= Length;
                            value = windowSquaredSum - temp;
                            value /= lastIndex;
                        }
                        else
                        {
                            temp = windowSum / Length;
                            temp *= temp;
                            value = windowSquaredSum / Length - temp;
                        }
                    }
                }
                return value;
            }
        }

        /// <summary>
        /// Updates the value of the variance, <c>σ²</c>.
        /// Depending on the <see cref="IsUnbiased"/>, the value is the unbiased sample variance or the population variance.
        /// The indicator is not primed during the first <c>ℓ-1</c> updates.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <param name="dateTime">A date-time of the new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(double sample, DateTime dateTime)
        {
            return new Scalar(dateTime, Update(sample));
        }

        /// <summary>
        /// Updates the value of the variance, <c>σ²</c>.
        /// Depending on the <see cref="IsUnbiased"/>, the value is the unbiased sample variance or the population variance.
        /// The indicator is not primed during the first <c>ℓ-1</c> updates.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Scalar scalar)
        {
            return new Scalar(scalar.Time, Update(scalar.Value));
        }

        /// <summary>
        /// Updates the value of the variance, <c>σ²</c>.
        /// Depending on the <see cref="IsUnbiased"/>, the value is the unbiased sample variance or the population variance.
        /// The indicator is not primed during the first <c>ℓ-1</c> updates.
        /// </summary>
        /// <param name="ohlcv">A new ohlcv.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Ohlcv ohlcv)
        {
            return new Scalar(ohlcv.Time, Update(ohlcv.Component(OhlcvComponent)));
        }
        #endregion

        #region Calculate
        /// <summary>
        /// Calculates a list of values of the variance, <c>σ²</c>, from the input array.
        /// The indicator is not primed during the first <c>ℓ-1</c> updates.
        /// </summary>
        /// <param name="sampleList">The sample list.</param>
        /// <param name="length">The number of time periods, <c>ℓ</c>.</param>
        /// <param name="unbiased">If the estimate of the variance is the unbiased sample variance or the population variance. The default value is true.</param>
        /// <returns>A list of indicator values.</returns>
        public static List<double> Calculate(List<double> sampleList, int length, bool unbiased = true)
        {
            if (2 > length)
                throw new ArgumentOutOfRangeException(nameof(length));
            int i, count = sampleList.Count;
            var resultList = new List<double>(count);
            if (count < length)
            {
                for (i = 0; i < count; ++i)
                    resultList.Add(double.NaN);
            }
            else
            {
                double v, sum = 0d, sum2 = 0d;
                int j = 0, length1 = length - 1;
                for (i = 0; i < length1; ++i)
                {
                    v = sampleList[i];
                    if (!double.IsNaN(v))
                    {
                        sum += v;
                        v *= v;
                        sum2 += v;
                    }
                    resultList.Add(double.NaN);
                }
                v = sampleList[length1];
                if (!double.IsNaN(v))
                {
                    sum += v;
                    v *= v;
                    sum2 += v;
                }
                if (unbiased)
                {
                    v = sum;
                    v *= v;
                    v /= length;
                    v = sum2 - v;
                    v /= length1;
                    resultList.Add(v);
                    for (i = length; i < count; ++i)
                    {
                        v = sampleList[i];
                        if (!double.IsNaN(v))
                        {
                            sum += v;
                            v *= v;
                            sum2 += v;
                        }
                        v = sampleList[j];
                        ++j;
                        if (!double.IsNaN(v))
                        {
                            sum -= v;
                            v *= v;
                            sum2 -= v;
                        }
                        v = sum;
                        v *= v;
                        v /= length;
                        v = sum2 - v;
                        v /= length1;
                        resultList.Add(v);
                    }
                }
                else
                {
                    v = sum / length;
                    v *= v;
                    resultList.Add(sum2 / length - v);
                    for (i = length; i < count; ++i)
                    {
                        v = sampleList[i];
                        if (!double.IsNaN(v))
                        {
                            sum += v;
                            v *= v;
                            sum2 += v;
                        }
                        v = sampleList[j];
                        ++j;
                        if (!double.IsNaN(v))
                        {
                            sum -= v;
                            v *= v;
                            sum2 -= v;
                        }
                        v = sum / length;
                        v *= v;
                        resultList.Add(sum2 / length - v);
                    }
                }
            }
            return resultList;
        }
        #endregion
    }
}

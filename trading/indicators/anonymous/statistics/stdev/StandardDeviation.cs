using System;
using System.Collections.Generic;
using System.Globalization;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

namespace Mbs.Trading.Indicators
{
    /// <summary>
    /// Computes the standard deviation of the samples within a moving window of length <c>ℓ</c> as a square root of variance:
    /// <para><c>σ² = (∑xᵢ² - (∑xᵢ)²/ℓ)/ℓ</c></para><para>for the estimation of the population variance, or as</para>
    /// <para><c>σ² = (∑xᵢ² - (∑xᵢ)²/ℓ)/(ℓ-1)</c></para><para>for the unbiased estimation of the sample variance, <c>i={0,…,ℓ-1}</c>.</para>
    /// </summary>
    public sealed class StandardDeviation : Indicator, ILineIndicator
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
        /// The current value of the standard deviation, <c>σ</c>, or <c>NaN</c> if not primed.
        /// Depending on the <see cref="IsUnbiased"/>, the value is the unbiased sample variance or the population variance.
        /// The indicator is not primed during the first <c>ℓ-1</c> updates, where e <c>ℓ</c> is the length.
        /// </summary>
        public double Value { get { lock (Lock) { return value; } } }

        private readonly Variance variance;

        //private const double epsilon = 0.00000001;
        private const string StdDev = "STDEV";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="StandardDeviation"/> class.
        /// </summary>
        /// <param name="length">The number of time periods, <c>ℓ</c>.</param>
        /// <param name="unbiased">If the estimate of the variance is the unbiased sample variance or the population variance. The default value is true.</param>
        public StandardDeviation(int length, bool unbiased = true)
            : this(OhlcvComponent.ClosingPrice, length, unbiased)
        {
        }

        /// <summary>
        /// Constructs a new instance of the <see cref="StandardDeviation"/> class.
        /// </summary>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        /// <param name="length">The number of time periods, <c>ℓ</c>.</param>
        /// <param name="unbiased">If the estimate of the variance is the unbiased sample variance or the population variance. The default value is true.</param>
        public StandardDeviation(OhlcvComponent ohlcvComponent, int length, bool unbiased = true)
            : base(StdDev, "Standard Deviation", ohlcvComponent)
        {
            if (2 > length)
                throw new ArgumentOutOfRangeException(nameof(length));
            this.IsUnbiased = unbiased;
            this.Length = length;
            variance = new Variance(length, unbiased);
            Moniker = string.Concat(StdDev, length.ToString(CultureInfo.InvariantCulture));
        }
        #endregion

        #region Reset
        /// <inheritdoc />
        public override void Reset()
        {
            lock (Lock)
            {
                Primed = false;
                variance.Reset();
                value = double.NaN;
            }
        }
        #endregion

        #region Update
        /// <summary>
        /// Updates the value of the standard deviation, <c>σ</c>.
        /// Depending on the <see cref="IsUnbiased"/>, the value is the square root of the unbiased sample variance or the square root of the population variance.
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
                value = variance.Update(sample);
                if (!double.IsNaN(value))
                    value = /*(epsilon < value) ?*/ Math.Sqrt(value) /*: 0d*/;
                Primed = variance.IsPrimed;
                return value;
            }
        }

        /// <summary>
        /// Updates the value of the standard deviation, <c>σ</c>.
        /// Depending on the <see cref="IsUnbiased"/>, the value is the square root of the unbiased sample variance or the square root of the population variance.
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
        /// Updates the value of the standard deviation, <c>σ</c>.
        /// Depending on the <see cref="IsUnbiased"/>, the value is the square root of the unbiased sample variance or the square root of the population variance.
        /// The indicator is not primed during the first <c>ℓ-1</c> updates.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Scalar scalar)
        {
            return new Scalar(scalar.Time, Update(scalar.Value));
        }

        /// <summary>
        /// Updates the value of the standard deviation, <c>σ</c>.
        /// Depending on the <see cref="IsUnbiased"/>, the value is the square root of the unbiased sample variance or the square root of the population variance.
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
        /// Calculates a list of values of the standard deviation, <c>σ</c>, from the input array.
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
                var variance = new Variance(length, unbiased);
                for (i = 0; i < count; ++i)
                {
                    double temp = variance.Update(sampleList[i]);
                    if (!double.IsNaN(temp))
                        temp = /*(epsilon < temp) ?*/ Math.Sqrt(temp) /*: 0d*/;
                    resultList.Add(temp);
                }
            }
            return resultList;
        }
        #endregion
    }
}

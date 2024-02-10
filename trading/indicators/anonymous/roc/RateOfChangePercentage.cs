using System;
using System.Collections.Generic;
using System.Globalization;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

namespace Mbs.Trading.Indicators
{
    /// <summary>
    /// RateOfChangePercentage is the difference between today's sample and the sample <c>ℓ</c> periods ago scaled by the old sample so as to represent the increase as a fraction.
    /// <para><c>RoC%ᵢ = (Pᵢ - Pᵢ₋ℓ) / Pᵢ₋ℓ = (Pᵢ/Pᵢ₋ℓ -1)</c></para>
    /// The values are centered at zero and can be positive and negative.
    /// <para>The indicator is not primed during the first <c>ℓ</c> updates.</para>
    /// </summary>
    public sealed class RateOfChangePercentage : Indicator, ILineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The length <c>ℓ</c> (the number of time periods).
        /// </summary>
        public int Length { get; }

        private double value = double.NaN;
        /// <summary>
        /// The current value of the rate of change percentage, or <c>NaN</c> if not primed.
        /// The indicator is not primed during the first <c>ℓ</c> updates, where e <c>ℓ</c> is the length.
        /// </summary>
        public double Value { get { lock (Lock) { return value; } } }

        private int windowCount;
        private readonly double[] window;

        private const string Rocp = "RoC%";
        private const string RocpFull = "Rate of Change Percentage";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="RateOfChangePercentage"/> class.
        /// </summary>
        /// <param name="length">The number of time periods, <c>ℓ</c>.</param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public RateOfChangePercentage(int length, OhlcvComponent ohlcvComponent = OhlcvComponent.ClosingPrice)
            : base(Rocp, RocpFull, ohlcvComponent)
        {
            if (1 > length)
                throw new ArgumentOutOfRangeException(nameof(length));
            Length = length;
            window = new double[length + 1];
            Moniker = string.Concat(Rocp, length.ToString(CultureInfo.InvariantCulture));
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
                value = double.NaN;
            }
        }
        #endregion

        #region Update
        /// <summary>
        /// Updates the value of the rate of change percentage.
        /// The indicator is not primed during the first <c>ℓ</c> updates.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public double Update(double sample)
        {
            if (double.IsNaN(sample))
                return sample;
            lock (Lock)
            {
                if (Primed)
                {
                    if (1 < Length)
                    {
                        Array.Copy(window, 1, window, 0, Length);
                        //for (int i = 0; i < length; ++i)
                        //    window[i] = window[i];
                    }
                    window[Length] = sample;
                    value = window[0];
                    if (Math.Abs(value) > double.Epsilon)
                        value = sample / value - 1d;
                    else
                        value = 0d;
                }
                else // Not primed.
                {
                    window[windowCount] = sample;
                    if (Length + 1 == ++windowCount)
                    {
                        Primed = true;
                        value = window[0];
                        if (Math.Abs(value) > double.Epsilon)
                            value = sample / value - 1d;
                        else
                            value = 0d;
                    }
                }
                return value;
            }
        }

        /// <summary>
        /// Updates the value of the rate of change percentage.
        /// The indicator is not primed during the first <c>ℓ</c> updates.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <param name="dateTime">A date-time of the new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(double sample, DateTime dateTime)
        {
            return new Scalar(dateTime, Update(sample));
        }

        /// <summary>
        /// Updates the value of the rate of change percentage.
        /// The indicator is not primed during the first <c>ℓ</c> updates.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Scalar scalar)
        {
            return new Scalar(scalar.Time, Update(scalar.Value));
        }

        /// <summary>
        /// Updates the value of the rate of change percentage.
        /// The indicator is not primed during the first <c>ℓ</c> updates.
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
        /// Calculates a list of values of the rate of change percentage from the input array.
        /// The indicator is not primed during the first <c>ℓ</c> updates.
        /// </summary>
        /// <param name="sampleList">The sample list.</param>
        /// <param name="length">The number of time periods, <c>ℓ</c>.</param>
        /// <returns>A list of indicator values.</returns>
        public static List<double> Calculate(List<double> sampleList, int length)
        {
            if (1 > length)
                throw new ArgumentOutOfRangeException(nameof(length));
            int count = sampleList.Count;
            var resultList = new List<double>(count);
            if (count <= length)
            {
                for (int i = 0; i < count; i++)
                    resultList.Add(double.NaN);
            }
            else
            {
                for (int i = 0; i < length; i++)
                    resultList.Add(double.NaN);
                for (int i = 0, j = length; j < count; i++, j++)
                {
                    double sample = sampleList[i];
                    if (Math.Abs(sample) > double.Epsilon)
                        sample = sampleList[j] / sample - 1d;
                    else
                        sample = 0d;
                    resultList.Add(sample);
                }
            }
            return resultList;
        }
        #endregion
    }
}

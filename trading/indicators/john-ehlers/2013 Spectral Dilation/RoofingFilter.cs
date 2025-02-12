using System;
using System.Globalization;
using Mbs.Numerics;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// The Roofing filter suggested by John Ehlers is comprised of a two pole HighPass filter and a Super Smoother.
    /// <para/>
    /// Given the longest (<c>Λ</c>) and the shortest (<c>λ</c>) cycle periods in bars,
    /// the two pole HighPass filter passes cyclic components whose periods are shorter than the longest one,
    /// and the Super Smoother filter attenuates cycle periods shorter than the shortest one.
    /// <para/>
    /// <c>α = (cos(π√̅2̅/Λ) + sin(π√̅2̅/Λ) - 1) / cos(π√̅2̅/Λ)</c>
    /// <para/>
    /// <c>HPᵢ = (1-α/2)²(xᵢ - 2xᵢ₋₁ + xᵢ₋₂) + 2(1-α)xᵢ₋₁ - (1-α)²xᵢ₋₂</c>
    /// <para/>
    /// <c>γ₁ = 1-γ₂-γ₃</c>
    /// <para/>
    /// <c>γ₂ = 2cos(π√̅2̅/λ)exp(-π√̅2̅/λ)</c>
    /// <para/>
    /// <c>γ₃ = -exp(-π√̅2̅/λ)²</c>
    /// <para/>
    /// <c>SSᵢ = γ₁(HPᵢ + HPᵢ₋₁)/2 + γ₂SSᵢ₋₁ + γ₃SSᵢ₋₂</c>
    /// </summary>
    public sealed class RoofingFilter : Indicator, ILineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The shortest cycle period in bars. The Roofing Filter attenuates all cycle periods shorter than this one.
        /// </summary>
        public int ShortestCyclePeriod { get; }

        /// <summary>
        /// The longest cycle period in bars. The Roofing Filter attenuates all cycle periods longer than this one.
        /// </summary>
        public int LongestCyclePeriod { get; }

        private double value = double.NaN;
        /// <summary>
        /// The current value of the the Roofing Filter, or <c>NaN</c> if not primed.
        /// The Roofing Filter is not primed during the first 3 updates.
        /// </summary>
        public double Value { get { lock (updateLock) { return value; } } }

        /// <summary>
        /// If the Roofing Filter has two-pole or one-pole high-pass filter.
        /// </summary>
        public bool HasTwoPoleHighPassFilter { get; }

        /// <summary>
        /// If the Roofing Filter has a zero mean.
        /// </summary>
        public bool HasZeroMean { get; }

        #region One-pole / two-poles high-pass filter
        private double samplePrevious;
        private double samplePrevious2;
        private double highPassFilterPrevious;
        private double highPassFilterPrevious2;
        private readonly double highPassFilterCoeff1;
        private readonly double highPassFilterCoeff2;
        private readonly double highPassFilterCoeff3;
        #endregion

        #region SuperSmoother filter
        private double superSmootherFilterPrevious;
        private double superSmootherFilterPrevious2;
        private readonly double superSmootherFilterCoeff1;
        private readonly double superSmootherFilterCoeff2;
        private readonly double superSmootherFilterCoeff3;
        #endregion

        private double zeroMeanFilterPrevious;
        private int count;
        private readonly ILineIndicator payloadIndicator;

        private const string RfName1Hp = "RoofingFilter1Hp";
        private const string RfName2Hp = "RoofingFilter2Hp";
        private const string RfFull1Hp = "Roofing Filter with 1-pole high-pass";
        private const string RfFull2Hp = "Roofing Filter with 2-pole high-pass";
        private const string RfMonikerFormat = "Roofing{0}PoleHpFilter[{1},{2}]";
        private const string RfMonikerFormat2 = "Roofing{0}PoleHpFilter[{1},{2}]({3})";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="RoofingFilter"/> class.
        /// </summary>
        /// <param name="shortestCyclePeriod">The shortest cycle period in bars. The Roofing Filter attenuates all cycle periods shorter than this one. The default value is 10 bars.</param>
        /// <param name="longestCyclePeriod">The longest cycle period in bars. The Roofing Filter attenuates all cycle periods longer than this one. The default value is 48 bars.</param>
        /// <param name="payloadIndicator">The payload indicator.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The default component is the median price.</param>
        /// <param name="hasTwoPoleHighPassFilter">If the Roofing Filter has two-pole or one-pole high-pass filter.</param>
        /// <param name="hasZeroMean">If the Roofing Filter has a zero mean.</param>
        public RoofingFilter(int shortestCyclePeriod = 10, int longestCyclePeriod = 48, ILineIndicator payloadIndicator = null, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice,
            bool hasTwoPoleHighPassFilter = false, bool hasZeroMean = false)
            : base(hasTwoPoleHighPassFilter ? RfName2Hp : RfName1Hp, hasTwoPoleHighPassFilter ? RfFull2Hp : RfFull1Hp, ohlcvComponent)
        {
            if (2 > shortestCyclePeriod)
                throw new ArgumentOutOfRangeException(nameof(shortestCyclePeriod));
            if (shortestCyclePeriod >= longestCyclePeriod)
                throw new ArgumentOutOfRangeException(nameof(longestCyclePeriod));
            ShortestCyclePeriod = shortestCyclePeriod;
            LongestCyclePeriod = longestCyclePeriod;

            HasTwoPoleHighPassFilter = hasTwoPoleHighPassFilter;
            HasZeroMean = hasZeroMean;

            double alpha, beta;
            if (hasTwoPoleHighPassFilter)
            {
                alpha = Constants.HalfSqrt2 * Constants.TwoPi / longestCyclePeriod;
                alpha = Math.Cos(alpha);
                alpha = (Math.Sin(alpha) + alpha - 1) / alpha;
                beta = 1 - alpha / 2;
                highPassFilterCoeff1 = beta * beta;
                beta = 1 - alpha;
                highPassFilterCoeff2 = 2 * beta;
                highPassFilterCoeff3 = beta * beta;
            }
            else
            {
                alpha = Constants.TwoPi / longestCyclePeriod;
                alpha = Math.Cos(alpha);
                alpha = (Math.Sin(alpha) + alpha - 1) / alpha;
                highPassFilterCoeff1 = 1 - alpha / 2;
                highPassFilterCoeff2 = 1 - alpha;
            }
            beta = /*Constants.Sqrt2*/1.414 * Constants.Pi / shortestCyclePeriod;
            alpha = Math.Exp(-beta);
            beta = 2 * alpha * Math.Cos(beta);
            superSmootherFilterCoeff2 = beta;
            superSmootherFilterCoeff3 = -alpha * alpha;
            superSmootherFilterCoeff1 = (1 - superSmootherFilterCoeff2 - superSmootherFilterCoeff3) / 2;

            this.payloadIndicator = payloadIndicator;
            int poles = hasTwoPoleHighPassFilter ? 2 : 1;
            if (null == payloadIndicator)
                Moniker = string.Format(CultureInfo.InvariantCulture, RfMonikerFormat, poles, shortestCyclePeriod, longestCyclePeriod);
            else
            {
                Moniker = string.Format(CultureInfo.InvariantCulture, RfMonikerFormat2, poles, shortestCyclePeriod, longestCyclePeriod, payloadIndicator.Moniker);
                Description = string.Concat(Description, " over ", payloadIndicator.Description);
            }
        }
        #endregion

        #region Reset
        /// <inheritdoc />
        public override void Reset()
        {
            lock (updateLock)
            {
                primed = false;
                count = 0;
                value = double.NaN;
                samplePrevious = 0;
                highPassFilterPrevious = 0;
                if (HasTwoPoleHighPassFilter)
                {
                    samplePrevious2 = 0;
                    highPassFilterPrevious2 = 0;
                }
                superSmootherFilterPrevious = 0;
                superSmootherFilterPrevious2 = 0;
                if (HasZeroMean)
                    zeroMeanFilterPrevious = 0;
                payloadIndicator?.Reset();
            }
        }
        #endregion

        #region Update
        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public double Update(double sample)
        {
            if (double.IsNaN(sample))
                return sample;
            lock (updateLock)
            {
                return HasTwoPoleHighPassFilter ? Update2Pole(sample) : Update1Pole(sample);
            }
        }

        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <param name="dateTime">A date-time of the new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(double sample, DateTime dateTime)
        {
            return new Scalar(dateTime, Update(sample));
        }

        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Scalar scalar)
        {
            return new Scalar(scalar.Time, Update(scalar.Value));
        }

        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="ohlcv">A new ohlcv.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Ohlcv ohlcv)
        {
            return new Scalar(ohlcv.Time, Update(ohlcv.Component(OhlcvComponent)));
        }

        private double Update1Pole(double sample)
        {
            double highPassFilter, superSmootherFilter, zeroMeanFilter = 0;
            if (primed)
            {
                highPassFilter = highPassFilterCoeff1 * (sample - samplePrevious) + highPassFilterCoeff2 * highPassFilterPrevious;
                superSmootherFilter = superSmootherFilterCoeff1 * (highPassFilter + highPassFilterPrevious) +
                    superSmootherFilterCoeff2 * superSmootherFilterPrevious + superSmootherFilterCoeff3 * superSmootherFilterPrevious2;
                if (HasZeroMean)
                {
                    zeroMeanFilter = highPassFilterCoeff1 * (superSmootherFilter - superSmootherFilterPrevious) + highPassFilterCoeff2 * zeroMeanFilterPrevious;
                    value = payloadIndicator?.Update(zeroMeanFilter) ?? zeroMeanFilter;
                }
                else
                    value = payloadIndicator?.Update(superSmootherFilter) ?? superSmootherFilter;
            }
            else // Not primed.
            {
                if (1 == ++count)
                {
                    highPassFilter = 0;
                    superSmootherFilter = 0;
                }
                else
                {
                    highPassFilter = highPassFilterCoeff1 * (sample - samplePrevious) + highPassFilterCoeff2 * highPassFilterPrevious;
                    superSmootherFilter = superSmootherFilterCoeff1 * (highPassFilter + highPassFilterPrevious) +
                        superSmootherFilterCoeff2 * superSmootherFilterPrevious + superSmootherFilterCoeff3 * superSmootherFilterPrevious2;
                    if (HasZeroMean)
                    {
                        zeroMeanFilter = highPassFilterCoeff1 * (superSmootherFilter - superSmootherFilterPrevious) + highPassFilterCoeff2 * zeroMeanFilterPrevious;
                        if (5 == count)
                        {
                            primed = true;
                            value = payloadIndicator?.Update(zeroMeanFilter) ?? zeroMeanFilter;
                        }

                    }
                    else if (4 == count)
                    {
                        primed = true;
                        value = payloadIndicator?.Update(superSmootherFilter) ?? superSmootherFilter;
                    }
                }
            }
            samplePrevious = sample;
            highPassFilterPrevious = highPassFilter;
            superSmootherFilterPrevious2 = superSmootherFilterPrevious;
            superSmootherFilterPrevious = superSmootherFilter;
            if (HasZeroMean)
                zeroMeanFilterPrevious = zeroMeanFilter;
            return value;
        }

        private double Update2Pole(double sample)
        {
            double highPassFilter, superSmootherFilter;
            if (primed)
            {
                highPassFilter = highPassFilterCoeff1 * (sample - 2 * samplePrevious + samplePrevious2) +
                    highPassFilterCoeff2 * highPassFilterPrevious - highPassFilterCoeff3 * highPassFilterPrevious2;
                superSmootherFilter = superSmootherFilterCoeff1 * (highPassFilter + highPassFilterPrevious) +
                    superSmootherFilterCoeff2 * superSmootherFilterPrevious + superSmootherFilterCoeff3 * superSmootherFilterPrevious2;
                value = payloadIndicator?.Update(superSmootherFilter) ?? superSmootherFilter;
            }
            else // Not primed.
            {
                if (4 > ++count)
                {
                    highPassFilter = 0;
                    superSmootherFilter = 0;
                }
                else
                {
                    highPassFilter = highPassFilterCoeff1 * (sample - 2 * samplePrevious + samplePrevious2) +
                        highPassFilterCoeff2 * highPassFilterPrevious - highPassFilterCoeff3 * highPassFilterPrevious2;
                    superSmootherFilter = superSmootherFilterCoeff1 * (highPassFilter + highPassFilterPrevious) +
                        superSmootherFilterCoeff2 * superSmootherFilterPrevious + superSmootherFilterCoeff3 * superSmootherFilterPrevious2;
                    if (5 == count)
                    {
                        primed = true;
                        value = payloadIndicator?.Update(superSmootherFilter) ?? superSmootherFilter;
                    }
                }
            }
            samplePrevious2 = samplePrevious;
            samplePrevious = sample;
            highPassFilterPrevious2 = highPassFilterPrevious;
            highPassFilterPrevious = highPassFilter;
            superSmootherFilterPrevious2 = superSmootherFilterPrevious;
            superSmootherFilterPrevious = superSmootherFilter;
            return value;
        }
        #endregion
    }
}

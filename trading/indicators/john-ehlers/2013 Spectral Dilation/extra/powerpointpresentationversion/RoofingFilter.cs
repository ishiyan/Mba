using System;
using System.Globalization;
using System.Runtime.Serialization;
using System.Text;
using Mbst.Numerics;

namespace Mbst.Trading.Indicators
{
    /// <summary>
    /// The Roofing filter suggested by John Ehlers is comprised of a two pole HighPass filter and a Super Smoother.
    /// <para/>
    /// Given the longest (<c>Λ</c>) and the shortest (<c>λ</c>) cycle periods in bars,
    /// the two pole Highpass filter passes cyclic components whose periods are shorter than the longest one,
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
    [DataContract]
    public sealed class RoofingFilter : Indicator, ILineIndicator
    {
        #region Members and accessors
        #region ShortestCyclePeriod
        [DataMember]
        private readonly int shortestCyclePeriod;
        /// <summary>
        /// The shortest cycle period in bars. The Roofing Filter attenuates all cycle periods shorter than this one.
        /// </summary>
        public int ShortestCyclePeriod { get { return shortestCyclePeriod; } }
        #endregion

        #region LongestCyclePeriod
        [DataMember]
        private readonly int longestCyclePeriod;
        /// <summary>
        /// The longest cycle period in bars. The Roofing Filter attenuates all cycle periods longer than this one.
        /// </summary>
        public int LongestCyclePeriod { get { return longestCyclePeriod; } }
        #endregion

        #region Value
        [DataMember]
        private double value = double.NaN;
        /// <summary>
        /// The current value of the the Roofing Filter, or <c>NaN</c> if not primed.
        /// The Roofing Filter is not primed during the first 3 updates.
        /// </summary>
        public double Value { get { lock (updateLock) { return value; } } }
        #endregion

        #region Two Pole Highpass filter
        [DataMember]
        private double samplePrevious;
        [DataMember]
        private double samplePrevious2;
        [DataMember]
        private double highPassFilterPrevious;
        [DataMember]
        private double highPassFilterPrevious2;
        [DataMember]
        private readonly double highPassFilterCoeff1;
        [DataMember]
        private readonly double highPassFilterCoeff2;
        [DataMember]
        private readonly double highPassFilterCoeff3;
        #endregion

        #region SuperSmoother filter
        [DataMember]
        private double superSmootherFilterPrevious;
        [DataMember]
        private double superSmootherFilterPrevious2;
        [DataMember]
        private readonly double superSmootherFilterCoeff1;
        [DataMember]
        private readonly double superSmootherFilterCoeff2;
        [DataMember]
        private readonly double superSmootherFilterCoeff3;
        #endregion

        [DataMember]
        private int count;
        [DataMember]
        private ILineIndicator payloadIndicator;

        private const string rfName = "RoofingFilter";
        private const string rfFull = "Roofing Filter";
        private const string rfMonikerFormat = "RoofingFilter[{0},{1}]";
        private const string rfMonikerFormat2 = "RoofingFilter[{0},{1}]({2})";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="RoofingFilter"/> class.
        /// </summary>
        /// <param name="shortestCyclePeriod">The shortest cycle period in bars. The Roofing Filter attenuates all cycle periods shorter than this one. The default value is 10 bars.</param>
        /// <param name="longestCyclePeriod">The longest cycle period in bars. The Roofing Filter attenuates all cycle periods longer than this one. The default value is 48 bars.</param>
        /// <param name="payloadIndicator">The payload indicator.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The default component is the median price.</param>
        public RoofingFilter(int shortestCyclePeriod = 10, int longestCyclePeriod = 48, ILineIndicator payloadIndicator = null, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : base(rfName, rfFull, ohlcvComponent)
        {
            if (2 > shortestCyclePeriod)
                throw new ArgumentOutOfRangeException("shortestCyclePeriod");
            if (shortestCyclePeriod >= longestCyclePeriod)
                throw new ArgumentOutOfRangeException("longestCyclePeriod");
            this.shortestCyclePeriod = shortestCyclePeriod;
            this.longestCyclePeriod = longestCyclePeriod;

            double alpha = Constants.HalfSqrt2 * Constants.TwoPi / longestCyclePeriod;
            alpha = Math.Cos(alpha);
            alpha = (Math.Sin(alpha) + alpha - 1) / alpha;
            double beta = 1 - alpha / 2;
            highPassFilterCoeff1 = beta * beta;
            beta = 1 - alpha;
            highPassFilterCoeff2 = 2 * beta;
            highPassFilterCoeff3 = beta * beta;

            beta = Constants.Sqrt2 * Constants.Pi / shortestCyclePeriod;
            alpha = Math.Exp(-beta);
            beta = 2 * alpha * Math.Cos(beta);
            superSmootherFilterCoeff2 = beta;
            superSmootherFilterCoeff3 = -alpha * alpha;
            superSmootherFilterCoeff1 = (1 - superSmootherFilterCoeff2 - superSmootherFilterCoeff3) / 2;

            this.payloadIndicator = payloadIndicator;
            if (null == payloadIndicator)
                moniker = string.Format(CultureInfo.InvariantCulture, rfMonikerFormat, shortestCyclePeriod, longestCyclePeriod);
            else
            {
                moniker = string.Format(CultureInfo.InvariantCulture, rfMonikerFormat2, shortestCyclePeriod, longestCyclePeriod, payloadIndicator.Moniker);
                description = string.Concat(description, " over ", payloadIndicator.Description);
            }
        }
        #endregion

        #region Reset
        /// <summary>
        /// Resets the indicator.
        /// </summary>
        public override void Reset()
        {
            lock (updateLock)
            {
                primed = false;
                count = 0;
                value = double.NaN;
                samplePrevious = 0;
                samplePrevious2 = 0;
                highPassFilterPrevious = 0;
                highPassFilterPrevious2 = 0;
                superSmootherFilterPrevious = 0;
                superSmootherFilterPrevious2 = 0;
                if (null != payloadIndicator)
                    payloadIndicator.Reset();
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
                double highPassFilter, superSmootherFilter;
                if (primed)
                {
                    highPassFilter = highPassFilterCoeff1 * (sample - 2 * samplePrevious + samplePrevious2) +
                        highPassFilterCoeff2 * highPassFilterPrevious - highPassFilterCoeff3 * highPassFilterPrevious2;
                    superSmootherFilter = superSmootherFilterCoeff1 * (highPassFilter + highPassFilterPrevious) +
                        superSmootherFilterCoeff2 * superSmootherFilterPrevious + superSmootherFilterCoeff3 * superSmootherFilterPrevious2;
                    if (null == payloadIndicator)
                        value = superSmootherFilter;
                    else
                        value = payloadIndicator.Update(superSmootherFilter);
                }
                else // Not primed.
                {
                    if (3 == ++count)
                    {
                        primed = true;
                        highPassFilter = highPassFilterCoeff1 * (sample - 2 * samplePrevious + samplePrevious2);
                        superSmootherFilter = superSmootherFilterCoeff1 * highPassFilter;
                        if (null == payloadIndicator)
                            value = superSmootherFilter;
                        else
                            value = payloadIndicator.Update(superSmootherFilter);
                    }
                    else
                    {
                        highPassFilter = 0;
                        superSmootherFilter = 0;
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
            return new Scalar(ohlcv.Time, Update(ohlcv.Component(ohlcvComponent)));
        }
        #endregion

        #region Overrides
        /// <summary>
        /// Returns the string that represents this object.
        /// </summary>
        /// <returns>Returns the string that represents this object.</returns>
        public override string ToString()
        {
            double v; bool p;
            lock (updateLock)
            {
                p = primed;
                v = value;
            }
            var sb = new StringBuilder();
            sb.Append("{M:");
            sb.Append(moniker);
            sb.Append(" P:");
            sb.Append(p);
            sb.Append(" V:");
            sb.Append(v);
            sb.Append("]");
            return sb.ToString();
        }
        #endregion
    }
}

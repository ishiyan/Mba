using System;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;

namespace Mbst.Trading.Indicators
{
    /// <summary>
    /// The Instantaneous Trendline indicator as described in Ehler's book "Cybernetic Analysis for Stocks and Futures" (2004):
    /// <para />
    /// H(z) = ((α-α²/4) + α²z⁻¹/2 - (α-3α²/4)z⁻²) / (1 - 2(1-α)z⁻¹ + (1-α)²z⁻²)
    /// <para />
    /// which is a complementary low-pass filter found by subtracting the <see cref="CyberCycle"/> high-pass filter
    /// <para />
    /// H(z) = ((1-α/2)²(1 - 2z⁻¹ + z⁻²)) / (1 - 2(1-α)z⁻¹ + (1-α)²z⁻²)
    /// <para />
    /// from the unity.
    /// <para />
    /// The Instantaneous Trendline has zero lag and about the same smoothing as an Exponential Moving Average with the same α.
    /// </summary>
    [DataContract]
    public sealed class InstantaneousTrendLineNew : Indicator, ILineIndicator
    {
        #region Members and accessors
        #region Length
        [DataMember]
        private readonly int length;
        /// <summary>
        /// The length (<c>ℓ</c>) of the instantaneous trend line. The equivalent smoothing factor (<c>α</c>) is
        /// <para><c>α = 2/(ℓ + 1), 0 &lt; α ≤ 1, 1 ≤ ℓ</c></para>
        /// </summary>
        public int Length { get { return length; } }
        #endregion

        #region SmoothingFactor
        [DataMember]
        private readonly double smoothingFactor;
        /// <summary>
        /// The smoothing factor (<c>α</c>) of the instantaneous trend line. The equivalent length (<c>ℓ</c>) is
        /// <para><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c></para>
        /// </summary>
        public double SmoothingFactor { get { return smoothingFactor; } }
        #endregion

        #region TrendLine
        [DataMember]
        private double trendLine = double.NaN;
        /// <summary>
        /// The current value of the instantaneous trend line, or <c>NaN</c> if not primed.
        /// </summary>
        public double TrendLine { get { lock (updateLock) { return primed ? trendLine : double.NaN; } } }
        #endregion

        #region TriggerLine
        [DataMember]
        private double triggerLine = double.NaN;
        /// <summary>
        /// The current value of the trigger line, or <c>NaN</c> if not primed.
        /// </summary>
        public double TriggerLine { get { lock (updateLock) { return primed ? triggerLine : double.NaN; } } }
        #endregion

        #region TrendLineFacade
        /// <summary>
        /// A line indicator façade to expose a value of the trend line as a separate line indicator with a fictious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the trend line from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade TrendLineFacade
        {
            get
            {
                return new LineIndicatorFacade(itrend, moniker, itrendFull, () => IsPrimed, () => TrendLine);
            }
        }
        #endregion

        #region TriggerLineFacade
        /// <summary>
        /// A line indicator façade to expose a value of the trigger line as a separate line indicator with a fictious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the trigger line from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade TriggerLineFacade
        {
            get
            {
                const string suffix = "Trigger";
                return new LineIndicatorFacade(string.Concat(itrend, suffix), string.Concat(moniker, suffix),
                    string.Concat(itrendFull, " (trigger line)"), () => IsPrimed, () => TriggerLine);
            }
        }
        #endregion

        [DataMember]
        private int count;
        [DataMember]
        private double previousSample1;
        [DataMember]
        private double previousSample2;
        [DataMember]
        private double previousTrendLine1;
        [DataMember]
        private double previousTrendLine2;
        [DataMember]
        private readonly double coeff1;
        [DataMember]
        private readonly double coeff2;
        [DataMember]
        private readonly double coeff3;
        [DataMember]
        private readonly double coeff4;
        [DataMember]
        private readonly double coeff5;

        private const double epsilon = 0.00000001;
        private const string itrend = "iTrend";
        private const string itrendFull = "Instantaneous Trend Line";
        private const string argumentLength = "length";
        private const string argumentSmoothingFactor = "smoothingFactor";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the instantaneous trend line.
        /// </summary>
        /// <param name="length">The length, <c>ℓ</c>, of the instantaneous trend line. The equivalent smoothing factor <c>α</c> is
        /// <para><c>α = 2/(ℓ + 1), 0 &lt; α ≤ 1, 1 ≤ ℓ</c></para>
        /// </param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public InstantaneousTrendLineNew(int length, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : base(itrend, itrendFull, ohlcvComponent)
        {
            if (1 > length)
                throw new ArgumentOutOfRangeException(argumentLength);
            this.length = length;
            smoothingFactor = 2d / (1d + length);
            moniker = string.Concat(itrend, "(", length.ToString(CultureInfo.InvariantCulture), ")");
            CalculateCoefficients(smoothingFactor, out coeff1, out coeff2, out coeff3, out coeff4, out coeff5);
        }

        /// <summary>
        /// Constructs a new instance of the instantaneous trend line.
        /// </summary>
        /// <param name="smoothingFactor">The smoothing factor, <c>α</c>, of the instantaneous trend line. The equivalent length <c>ℓ</c> is
        /// <para><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c></para>
        /// The default value is 0.07.
        /// </param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public InstantaneousTrendLineNew(double smoothingFactor = 0.07, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : base(itrend, itrendFull, ohlcvComponent)
        {
            if (0d > smoothingFactor || 1d < smoothingFactor)
                throw new ArgumentOutOfRangeException(argumentSmoothingFactor);
            this.smoothingFactor = smoothingFactor;
            if (epsilon > smoothingFactor)
                length = int.MaxValue;
            else
                length = (int)Math.Round(2d / smoothingFactor) - 1;
            moniker = string.Concat(itrend, "(", length.ToString(CultureInfo.InvariantCulture), ")");
            CalculateCoefficients(smoothingFactor, out coeff1, out coeff2, out coeff3, out coeff4, out coeff5);
        }

        private static void CalculateCoefficients(double a, out double c1, out double c2, out double c3, out double c4, out double c5)
        {
            double a2 = a * a;
            c1 = a - a2 / 4d;
            c2 = a2 / 2d;
            c3 = -(a - 3d * a2 / 4d);
            a2 = 1d - a;
            c4 = 2d * a2;
            c5 = -(a2 * a2);
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
                previousSample1 = 0d;
                previousSample2 = 0d;
                previousTrendLine1 = 0d;
                previousTrendLine2 = 0d;
                trendLine = double.NaN;
                triggerLine = double.NaN;
            }
        }
        #endregion

        #region Update
        /// <summary>
        /// Updates the value of the instantaneous trend line.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public double Update(double sample)
        {
            if (double.IsNaN(sample))
                return sample;
            lock (updateLock)
            {
                if (primed)
                {
                    trendLine = coeff1 * sample + coeff2 * previousSample1 + coeff3 * previousSample2 + coeff4 * previousTrendLine1 + coeff5 * previousTrendLine2;
                    triggerLine = 2d * trendLine - previousTrendLine2;
                    previousSample2 = previousSample1;
                    previousSample1 = sample;
                    previousTrendLine2 = previousTrendLine1;
                    previousTrendLine1 = trendLine;
                }
                else
                {
                    switch (++count)
                    {
                        case 1:
                            previousSample2 = sample;
                            return double.NaN;
                        case 2:
                            previousSample1 = sample;
                            return double.NaN;
                        case 3:
                            previousTrendLine2 = (sample + 2d * previousSample1 + previousSample2) / 4d;
                            previousSample2 = previousSample1;
                            previousSample1 = sample;
                            return double.NaN;
                        case 4:
                            previousTrendLine1 = (sample + 2d * previousSample1 + previousSample2) / 4d;
                            previousSample2 = previousSample1;
                            previousSample1 = sample;
                            return double.NaN;
                        case 5:
                            trendLine = coeff1 * sample + coeff2 * previousSample1 + coeff3 * previousSample2 + coeff4 * previousTrendLine1 + coeff5 * previousTrendLine2;
                            triggerLine = 2d * trendLine - previousTrendLine2;
                            previousSample2 = previousSample1;
                            previousSample1 = sample;
                            previousTrendLine2 = previousTrendLine1;
                            previousTrendLine1 = trendLine;
                            primed = true;
                            break;
                    }
                }
                return trendLine;
            }
        }

        /// <summary>
        /// Updates the value of the instantaneous trend line.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <param name="dateTime">A date-time of the new price.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(double sample, DateTime dateTime)
        {
            return new Scalar(dateTime, Update(sample));
        }

        /// <summary>
        /// Updates the value of the instantaneous trend line.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Scalar scalar)
        {
            return new Scalar(scalar.Time, Update(scalar.Value));
        }

        /// <summary>
        /// Updates the value of the instantaneous trend line.
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
            double tl, tr; bool p;
            lock (updateLock)
            {
                p = primed;
                tl = TrendLine;
                tr = TriggerLine;
            }
            var sb = new StringBuilder();
            sb.Append("[M:");
            sb.Append(moniker);
            sb.Append(" P:");
            sb.Append(p);
            sb.Append(" TL:");
            sb.Append(tl);
            sb.Append(" TR:");
            sb.Append(tr);
            sb.Append("]");
            return sb.ToString();
        }
        #endregion
    }
}

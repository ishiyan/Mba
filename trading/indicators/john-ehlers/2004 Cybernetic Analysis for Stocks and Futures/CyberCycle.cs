using System;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;

namespace Mbst.Trading.Indicators
{
    /// <summary>
    /// The Cyber Cycle indicator as described in Ehler's book "Cybernetic Analysis for Stocks and Futures" (2004):
    /// <para />
    /// H(z) = ((1-α/2)²(1 - 2z⁻¹ + z⁻²)) / (1 - 2(1-α)z⁻¹ + (1-α)²z⁻²)
    /// <para />
    /// which is a complementary high-pass filter found by subtracting the <see cref="InstantaneousTrendLineNew"/> low-pass filter
    /// <para />
    /// H(z) = ((α-α²/4) + α²z⁻¹/2 - (α-3α²/4)z⁻²) / (1 - 2(1-α)z⁻¹ + (1-α)²z⁻²)
    /// <para />
    /// from the unity.
    /// <para />
    /// The Cyber Cycle has zero lag and retains the relative cycle amplitude.
    /// </summary>
    [DataContract]
    public sealed class CyberCycle : Indicator, ILineIndicator
    {
        #region Members and accessors
        #region Length
        [DataMember]
        private readonly int length;
        /// <summary>
        /// The length (<c>ℓ</c>) of the cyber cycle. The equivalent smoothing factor (<c>α</c>) is
        /// <para><c>α = 2/(ℓ + 1), 0 &lt; α ≤ 1, 1 ≤ ℓ</c></para>
        /// </summary>
        public int Length { get { return length; } }
        #endregion

        #region SmoothingFactor
        [DataMember]
        private readonly double smoothingFactor;
        /// <summary>
        /// The smoothing factor (<c>α</c>) of the cyber cycle. The equivalent length (<c>ℓ</c>) is
        /// <para><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c></para>
        /// </summary>
        public double SmoothingFactor { get { return smoothingFactor; } }
        #endregion

        #region SignalLag
        [DataMember]
        private readonly int signalLag;
        /// <summary>
        /// The lag (<c>ℓ</c>) of the signal, which is an exponential moving average of the cybe cycle value.
        /// The equivalent EMA smoothing factor (<c>α</c>) is
        /// <para><c>α = 1/(ℓ + 1), 0 &lt; α ≤ 1, 0 ≤ ℓ</c></para>
        /// </summary>
        public int SignalLag { get { return signalLag; } }
        #endregion

        #region Value
        [DataMember]
        private double value = double.NaN;
        /// <summary>
        /// The current value of the cyber cycle, or <c>NaN</c> if not primed.
        /// </summary>
        public double Value { get { lock (updateLock) { return primed ? value : double.NaN; } } }
        #endregion

        #region Signal
        [DataMember]
        private double signal = double.NaN;
        /// <summary>
        /// The current value of the signal line, which is an exponential moving average of the cybe cycle value, or <c>NaN</c> if not primed.
        /// </summary>
        public double Signal { get { lock (updateLock) { return primed ? signal : double.NaN; } } }
        #endregion

        #region ValueFacade
        /// <summary>
        /// A line indicator façade to expose a value of the cyber cycle as a separate line indicator with a fictious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the cyber cycle from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade ValueFacade
        {
            get
            {
                return new LineIndicatorFacade(cc, moniker, ccFull, () => IsPrimed, () => Value);
            }
        }
        #endregion

        #region SignalFacade
        /// <summary>
        /// A line indicator façade to expose a value of the signal line as a separate line indicator with a fictious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the signal line from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade SignalFacade
        {
            get
            {
                return new LineIndicatorFacade(ccSig, string.Concat(ccSig, "(", signalLag.ToString(CultureInfo.InvariantCulture), ")"),
                    ccSigFull, () => IsPrimed, () => Signal);
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
        private double previousSample3;
        [DataMember]
        private double smoothed;
        [DataMember]
        private double previousSmoothed1;
        [DataMember]
        private double previousSmoothed2;
        [DataMember]
        private double previousValue1;
        [DataMember]
        private double previousValue2;
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
        private const string cc = "cc";
        private const string ccFull = "Cyber Cycle";
        private const string ccSig = "ccSignal";
        private const string ccSigFull = "Cyber Cycle signal";
        private const string argumentLength = "length";
        private const string argumentSmoothingFactor = "smoothingFactor";
        private const string argumentSignalLag = "signalLag";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the cyber cycle.
        /// </summary>
        /// <param name="length">The length, <c>ℓ</c>, of the cyber cycle. The equivalent smoothing factor <c>α</c> is
        /// <para><c>α = 2/(ℓ + 1), 0 &lt; α ≤ 1, 1 ≤ ℓ</c></para>
        /// </param>
        /// <param name="signalLag">The lag, <c>ℓ</c>, of the signal line, which is an exponential moving average of the cybe cycle value. The equivalent EMA smoothing factor <c>α</c> is
        /// <para/>
        /// <c>α = 1/(ℓ + 1), 0 &lt; α ≤ 1, 0 ≤ ℓ</c>
        /// <para/>
        /// There are two default values used in the Ehler's book: 9 (EasyLanguage code) and 20 (EFS code).
        /// </param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public CyberCycle(int length, int signalLag, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : base(cc, ccFull, ohlcvComponent)
        {
            if (1 > length)
                throw new ArgumentOutOfRangeException(argumentLength);
            this.length = length;
            smoothingFactor = 2d / (1d + length);
            if (1 > signalLag)
                throw new ArgumentOutOfRangeException(argumentSignalLag);
            this.signalLag = signalLag;
            moniker = string.Concat(cc, "(", length.ToString(CultureInfo.InvariantCulture), ")");
            CalculateCoefficients(smoothingFactor, signalLag, out coeff1, out coeff2, out coeff3, out coeff4, out coeff5);
        }

        /// <summary>
        /// Constructs a new instance of the cyber cycle.
        /// </summary>
        /// <param name="smoothingFactor">The smoothing factor, <c>α</c>, of the cyber cycle. The equivalent length <c>ℓ</c> is
        /// <para><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c></para>
        /// The default value used in the Ehler's book is 0.07.
        /// </param>
        /// <param name="signalLag">The lag, <c>ℓ</c>, of the signal line, which is an exponential moving average of the cybe cycle value. The equivalent EMA smoothing factor <c>α</c> is
        /// <para/>
        /// <c>α = 1/(ℓ + 1), 0 &lt; α ≤ 1, 0 ≤ ℓ</c>
        /// <para/>
        /// There are two default values used in the Ehler's book: 9 (EasyLanguage code) and 20 (EFS code).
        /// </param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public CyberCycle(double smoothingFactor = 0.07, int signalLag = 9, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : base(cc, ccFull, ohlcvComponent)
        {
            if (0d > smoothingFactor || 1d < smoothingFactor)
                throw new ArgumentOutOfRangeException(argumentSmoothingFactor);
            this.smoothingFactor = smoothingFactor;
            if (epsilon > smoothingFactor)
                length = int.MaxValue;
            else
                length = (int)Math.Round(2d / smoothingFactor) - 1;
            if (1 > signalLag)
                throw new ArgumentOutOfRangeException(argumentSignalLag);
            this.signalLag = signalLag;
            moniker = string.Concat(cc, "(", length.ToString(CultureInfo.InvariantCulture), ")");
            CalculateCoefficients(smoothingFactor, signalLag, out coeff1, out coeff2, out coeff3, out coeff4, out coeff5);
        }

        private static void CalculateCoefficients(double a, int signalLag, out double c1, out double c2, out double c3, out double c4, out double c5)
        {
            double x = 1d - a / 2d;
            c1 = x * x;
            x = 1d - a;
            c2 = 2d * x;
            c3 = -x * x;
            x = 1d / (1d + signalLag);
            c4 = x;
            c5 = 1 - x;
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
                signal = double.NaN;
                previousSample1 = 0d;
                previousSample2 = 0d;
                previousSample3 = 0d;
                smoothed = 0d;
                previousSmoothed1 = 0d;
                previousSmoothed2 = 0d;
                previousValue1 = 0d;
                previousValue2 = 0d;
            }
        }
        #endregion

        #region Update
        /// <summary>
        /// Updates the value of the cyber cycle.
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
                    previousSmoothed2 = previousSmoothed1;
                    previousSmoothed1 = smoothed;
                    smoothed = (sample + 2d * previousSample1 + 2d * previousSample2 + previousSample3) / 6d;
                    previousValue2 = previousValue1;
                    previousValue1 = value;
                    value = coeff1 * (smoothed - 2d * previousSmoothed1 + previousSmoothed2) + coeff2 * previousValue1 + coeff3 * previousValue2;
                    signal = coeff4 * value + coeff5 * signal;
                    previousSample3 = previousSample2;
                    previousSample2 = previousSample1;
                    previousSample1 = sample;
                }
                else
                {
                    switch (++count)
                    {
                        case 1:
                            previousSample3 = sample;
                            return double.NaN;
                        case 2:
                            previousSample2 = sample;
                            return double.NaN;
                        case 3:
                            signal = coeff4 * (sample - 2d * previousSample2 + previousSample3) / 4d;
                            previousSample1 = sample;
                            return double.NaN;
                        case 4:
                            previousSmoothed2 = (sample + 2d * previousSample1 + 2d * previousSample2 + previousSample3) / 6d;
                            signal = coeff4 * (sample - 2d * previousSample1 + previousSample2) / 4d + coeff5 * signal;
                            previousSample3 = previousSample2;
                            previousSample2 = previousSample1;
                            previousSample1 = sample;
                            return double.NaN;
                        case 5:
                            previousSmoothed1 = (sample + 2d * previousSample1 + 2d * previousSample2 + previousSample3) / 6d;
                            signal = coeff4 * (sample - 2d * previousSample1 + previousSample2) / 4d + coeff5 * signal;
                            previousSample3 = previousSample2;
                            previousSample2 = previousSample1;
                            previousSample1 = sample;
                            return double.NaN;
                        case 6:
                            smoothed = (sample + 2d * previousSample1 + 2d * previousSample2 + previousSample3) / 6d;
                            previousValue2 = (sample - 2d * previousSample1 + previousSample2) / 4d;
                            signal = coeff4 * previousValue2 + coeff5 * signal;
                            previousSample3 = previousSample2;
                            previousSample2 = previousSample1;
                            previousSample1 = sample;
                            return double.NaN;
                        case 7:
                            previousSmoothed2 = previousSmoothed1;
                            previousSmoothed1 = smoothed;
                            smoothed = (sample + 2d * previousSample1 + 2d * previousSample2 + previousSample3) / 6d;
                            previousValue1 = (sample - 2d * previousSample1 + previousSample2) / 4d;
                            signal = coeff4 * previousValue1 + coeff5 * signal;
                            previousSample3 = previousSample2;
                            previousSample2 = previousSample1;
                            previousSample1 = sample;
                            return double.NaN;
                        case 8:
                            previousSmoothed2 = previousSmoothed1;
                            previousSmoothed1 = smoothed;
                            smoothed = (sample + 2d * previousSample1 + 2d * previousSample2 + previousSample3) / 6d;
                            value = coeff1 * (smoothed - 2d * previousSmoothed1 + previousSmoothed2) + coeff2 * previousValue1 + coeff3 * previousValue2;
                            signal = coeff4 * value + coeff5 * signal;
                            previousSample3 = previousSample2;
                            previousSample2 = previousSample1;
                            previousSample1 = sample;
                            primed = true;
                            break;
                    }
                }
                return value;
            }
        }

        /// <summary>
        /// Updates the value of the cyber cycle.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <param name="dateTime">A date-time of the new price.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(double sample, DateTime dateTime)
        {
            return new Scalar(dateTime, Update(sample));
        }

        /// <summary>
        /// Updates the value of the cyber cycle.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Scalar scalar)
        {
            return new Scalar(scalar.Time, Update(scalar.Value));
        }

        /// <summary>
        /// Updates the value of the cyber cycle.
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
            double v, s; bool p;
            lock (updateLock)
            {
                p = primed;
                v = value;
                s = signal;
            }
            var sb = new StringBuilder();
            sb.Append("[M:");
            sb.Append(moniker);
            sb.Append(" P:");
            sb.Append(p);
            sb.Append(" V:");
            sb.Append(v);
            sb.Append(" S:");
            sb.Append(s);
            sb.Append("]");
            return sb.ToString();
        }
        #endregion
    }
}

using System;
using System.Runtime.Serialization;
using System.Globalization;

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// Zero-lag exponential moving average.
    /// <para/>
    /// See John Ehlers, Rocket Science for Traders, Wiley, 2001, 0471405671, pp 167-170.
    /// </summary>
    [DataContract]
    public sealed class ZeroLagExponentialMovingAverage : LineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The SMA length (<c>ℓ</c>) equivalent to the smoothing factor (<c>α</c>) of the EMA.<para/>
        /// <c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>.
        /// </summary>
        public int Length => length;

        /// <summary>
        /// The smoothing factor (<c>α</c>) of the EMA.<para/>
        /// <c>α = 2/(ℓ + 1), 0 &lt; α ≤ 1, 1 ≤ ℓ</c> where <c>ℓ</c> is the equivalent SMA length.
        /// </summary>
        public double SmoothingFactor => alpha;

        /// <summary>
        /// The length of the momentum used to estimate the velocity.
        /// </summary>
        public int VelocityMomentumLength => momentumLength;

        /// <summary>
        /// The gain factor used to estimate the velocity.
        /// </summary>
        public double VelocityGainFactor => gainFactor;

        /// <summary>
        /// The default value of the smoothing factor of the EMA.
        /// </summary>
        public const double DefaultSmoothingFactor = 0.25;

        /// <summary>
        /// The default value of the length of the momentum used to estimate the velocity.
        /// </summary>
        public const int DefaultVelocityMomentumLength = 3;

        /// <summary>
        /// The default value of the gain factor used to estimate the velocity.
        /// </summary>
        public const double DefaultVelocityGainFactor = 0.5;

        /// <summary>
        /// The current value of the indicator, or <c>NaN</c> if not primed.<para/>
        /// The indicator is not primed during the first <c>VelocityMomentumLength</c> updates.
        /// </summary>
        public double Value { get { lock (updateLock) { return primed ? value : double.NaN; } } }

        [DataMember]
        private readonly double alpha;
        [DataMember]
        private readonly double oneMinAlpha;
        [DataMember]
        private readonly double gainFactor;
        [DataMember]
        private double value = double.NaN;
        [DataMember]
        private readonly double[] momentumWindow;
        [DataMember]
        private readonly int length;
        [DataMember]
        private readonly int momentumLength;
        [DataMember]
        private int count;

        private const double epsilon = 0.00000001;
        private const string zema = "ehlersZema";
        private const string zemaFull = "John Ehlers Zero-lag Exponential Moving Average";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="smoothingFactor">The smoothing factor, <c>α, 0 &lt; α ≤ 1</c>, of the exponential moving average.<para/>
        /// <c>α = 2/(ℓ + 1), 0 &lt; α ≤ 1, 1 ≤ ℓ</c> where <c>ℓ</c> is the equivalent SMA length.<para/>
        /// The default value is <c>DefaultSmoothingFactor</c>.
        /// </param>
        /// <param name="velocityGainFactor">The gain factor used to estimate the velocity.<para/>
        /// The default value is <c>DefaultVelocityGainFactor</c>.
        /// </param>
        /// <param name="velocityMomentumLength">The length of the momentum used to estimate the velocity.<para/>The value should be positive.<para/>
        /// The default value is <c>DefaultVelocityMomentumLength</c>.
        /// </param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public ZeroLagExponentialMovingAverage(double smoothingFactor = DefaultSmoothingFactor,
            double velocityGainFactor = DefaultVelocityGainFactor, int velocityMomentumLength = DefaultVelocityMomentumLength,
            OhlcvComponent ohlcvComponent = OhlcvComponent.ClosingPrice)
            : base(zema, zemaFull, ohlcvComponent)
        {
            if (0d > smoothingFactor || 1d < smoothingFactor)
                throw new ArgumentOutOfRangeException(nameof(smoothingFactor));
            if (1 > velocityMomentumLength)
                throw new ArgumentOutOfRangeException(nameof(velocityMomentumLength));
            alpha = smoothingFactor;
            oneMinAlpha = 1 - smoothingFactor;
            if (epsilon > smoothingFactor)
                length = int.MaxValue;
            else
                length = (int)Math.Round(2d / smoothingFactor) - 1;
            gainFactor = velocityGainFactor;
            momentumLength = velocityMomentumLength;
            momentumWindow = new double[velocityMomentumLength + 1];
            moniker = string.Format(CultureInfo.InvariantCulture, "{0}(α={1:0.####}(ℓ={2:0.####}),gf={3:0.####},ml={4})",
                zema, alpha, length, gainFactor, momentumLength);
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
            }
        }
        #endregion

        #region Update
        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public override double Update(double sample)
        {
            if (double.IsNaN(sample))
                return sample;
            lock (updateLock)
            {
                if (primed)
                {
                    if (1 == momentumLength)
                        momentumWindow[0] = momentumWindow[1];
                    else
                        Array.Copy(momentumWindow, 1, momentumWindow, 0, momentumLength);
                    momentumWindow[momentumLength] = sample;
                    value = Calculate(sample);
                }
                else
                {
                    momentumWindow[count] = sample;
                    if (++count <= momentumLength)
                        value = sample;
                    else
                    {
                        value = Calculate(sample);
                        primed = true;
                    }
                    if (!primed)
                        return double.NaN;
                }
                return value;
            }
        }
        #endregion

        #region Implementation
        private double Calculate(double sample)
        {
            double momentum = sample - momentumWindow[0];
            return alpha * (sample + gainFactor * momentum) + oneMinAlpha * value;
        }
        #endregion
    }
}

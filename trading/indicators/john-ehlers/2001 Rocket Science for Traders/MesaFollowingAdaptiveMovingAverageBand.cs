using System;
using System.Runtime.Serialization;

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// The MesaAdaptiveMovingAverage / FollowingAdaptiveMovingAverageLead band.
    /// <para/>
    /// See John Ehlers, Rocket Science for Traders, Wiley, 2001, 0471405671, pp 177-184.
    /// </summary>
    [DataContract]
    public sealed class MesaFollowingAdaptiveMovingAverageBand : BandIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The maximum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length (<c>ℓ</c>) is
        /// <para/>
        /// <c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>
        /// </summary>
        public double FastLimit => fama.FastLimit;

        /// <summary>
        /// The minimum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length (<c>ℓ</c>) is
        /// <para/>
        /// <c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>
        /// </summary>
        public double SlowLimit => fama.SlowLimit;

        /// <summary>
        /// The effective length, <c>ℓ</c>, of the maximum value of the smoothing factor <c>α</c> of the underlying exponential moving average.
        /// </summary>
        public int FastLimitLength => fama.FastLimitLength;

        /// <summary>
        /// The effective length, <c>ℓ</c>, of the minimum value of the smoothing factor <c>α</c> of the underlying exponential moving average.
        /// </summary>
        public int SlowLimitLength => fama.SlowLimitLength;

        /// <summary>
        /// The WMA smoothing length used by underlying Hilbert transformer.
        /// </summary>
        internal int SmoothingLength => fama.SmoothingLength;

        /// <summary>
        /// The current value of the the FAMA, or <c>NaN</c> if not primed.
        /// </summary>
        public double FamaValue => fama.Value;

        /// <summary>
        /// The current value of the the MAMA, or <c>NaN</c> if not primed.
        /// </summary>
        public double MamaValue => fama.MamaValue;

        [DataMember]
        private readonly FollowingAdaptiveMovingAverage fama;

        private const string famama = "ehlersMaMa/FaMa";
        private const string famamaFull = "John Ehlers Mesa / Following Adaptive Moving Average";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="slowLimit">The minimum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length <c>ℓ</c> is <para/><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>. The default value is DefaultAlphaSlowLimit (<c>ℓ</c>=39).</param>
        /// <param name="fastLimit">The maximum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length <c>ℓ</c> is<para/><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>. The default value is DefaultAlphaFastLimit (<c>ℓ</c>=3).</param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public MesaFollowingAdaptiveMovingAverageBand(HilbertTransformerCycleEstimator estimator = HilbertTransformerCycleEstimator.HomodyneDiscriminator,
            double slowLimit = MesaAdaptiveMovingAverage.DefaultAlphaSlowLimit, double fastLimit = MesaAdaptiveMovingAverage.DefaultAlphaFastLimit, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(estimator, new FollowingAdaptiveMovingAverage(estimator, slowLimit, fastLimit, ohlcvComponent), ohlcvComponent) {}

        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="smoothingLength">The WMA smoothing length used by underlying Hilbert transformer. The valid values are 2, 3, 4. The default value is 4.</param>
        /// <param name="warmUpPeriod">The number of updates before the indicator is primed. If less than the real primed period, then will be reset to the real primed period. The default value is <c>estimator.DefaultWarmUpPeriod</c>.</param>
        /// <param name="alphaEmaQuadratureInPhase">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the in-phase and quadrature components. The default value is <c>estimator.DefaultAlphaEmaQuadratureInPhase</c>.</param>
        /// <param name="alphaEmaPeriod">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the instantaneous period. The default value is <c>estimator.DefaultAlphaEmaPeriod</c>.</param>
        /// <param name="slowLimit">The minimum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length <c>ℓ</c> is <para/><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>. The default value is DefaultAlphaSlowLimit (<c>ℓ</c>=39).</param>
        /// <param name="fastLimit">The maximum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length <c>ℓ</c> is<para/><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>. The default value is DefaultAlphaFastLimit (<c>ℓ</c>=3).</param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public MesaFollowingAdaptiveMovingAverageBand(HilbertTransformerCycleEstimator estimator, int smoothingLength, int warmUpPeriod, double alphaEmaQuadratureInPhase,
            double alphaEmaPeriod, double slowLimit = MesaAdaptiveMovingAverage.DefaultAlphaSlowLimit, double fastLimit = MesaAdaptiveMovingAverage.DefaultAlphaFastLimit, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(estimator,
                  new FollowingAdaptiveMovingAverage(estimator, smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase, alphaEmaPeriod, slowLimit, fastLimit, ohlcvComponent),
                  ohlcvComponent) {}

        private MesaFollowingAdaptiveMovingAverageBand(HilbertTransformerCycleEstimator estimator,
            FollowingAdaptiveMovingAverage fama, OhlcvComponent ohlcvComponent)
            : base(famama + estimator.ShortName(), famamaFull + estimator.FullNameInBrackets(), ohlcvComponent)
        {
            this.fama = fama;
            moniker = fama.ComposeMoniker(famama);
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
                fama.Reset();
            }
        }
        #endregion

        #region Update
        /// <summary>
        /// Updates the band indicator.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <param name="dateTime">A date-time of the new sample.</param>
        /// <returns>The updated value of the band indicator.</returns>
        public override Band Update(double sample, DateTime dateTime)
        {
            if (double.IsNaN(sample))
                return new Band(dateTime, double.NaN, double.NaN);
            lock (updateLock)
            {
                fama.Update(sample);
                if (primed)
                    return new Band(dateTime, fama.MamaValue, fama.Value);
                if (fama.IsPrimed)
                {
                    primed = true;
                    return new Band(dateTime, fama.MamaValue, fama.Value);
                }
                return new Band(dateTime, double.NaN, double.NaN);
            }
        }
        #endregion
    }
}

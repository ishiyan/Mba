using System;
using System.Globalization;
using System.Runtime.Serialization;
using Mbst.Numerics;

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// The starting point of the MESA Adaptive Moving Average (MAMA) is a conventional Exponential Moving average (EMA):
    /// <para/>
    /// <c>EMA¡ = αP¡ + (1-α)EMA¡₋₁ = EMA¡₋₁ + α(P¡ - EMA¡₋₁), 0 ≤ α ≤ 1</c>
    /// <para/>
    /// The concept of MAMA is to relate the phase rate of change, as measured by a Hilbert Transformer estimator,
    /// to the EMA <c>α</c>, thus making the EMA adaptive.
    /// <para/>
    /// The <c>α</c> in MAMA is allowed to range between a maximum and minimum value, these being established as inputs.
    /// The suggested maximum value, FastLimit, is 0.5 (<c>ℓ</c>=3) and the suggested minimum, SlowLimit, is 0.05 (<c>ℓ</c>=39).
    /// <para/>
    /// The cycle phase is computed from the arctangent of the ratio of the Quadrature component to the InPhase component.
    /// The rate of change is obtained by taking the difference of successive phase measurements.
    /// The <c>α</c> is computed as the FastLimit divided by the phase rate of change.
    /// Any time there is a negative phase rate of change the value of <c>α</c> is set to the FastLimit;
    /// if the phase rate of change is large, the <c>α</c> is bounded at the SlowLimit.
    /// <para/>
    /// See John Ehlers, Rocket Science for Traders, Wiley, 2001, 0471405671, pp 177-184.
    /// </summary>
    [DataContract]
    public sealed class MesaAdaptiveMovingAverage : LineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The maximum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length (<c>ℓ</c>) is
        /// <para/>
        /// <c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>
        /// </summary>
        public double FastLimit => fastLimit;

        /// <summary>
        /// The minimum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length (<c>ℓ</c>) is
        /// <para/>
        /// <c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>
        /// </summary>
        public double SlowLimit => slowLimit;

        /// <summary>
        /// The effective length, <c>ℓ</c>, of the maximum value of the smoothing factor <c>α</c> of the underlying exponential moving average.
        /// </summary>
        public int FastLimitLength => (int)Math.Round(2d / fastLimit) - 1;

        /// <summary>
        /// The effective length, <c>ℓ</c>, of the minimum value of the smoothing factor <c>α</c> of the underlying exponential moving average.
        /// </summary>
        public int SlowLimitLength => (int)Math.Round(2d / slowLimit) - 1;

        /// <summary>
        /// The WMA smoothing length used by underlying Hilbert transformer.
        /// </summary>
        internal int SmoothingLength => htce.SmoothingLength;

        /// <summary>
        /// The current value of the the MAMA, or <c>NaN</c> if not primed.
        /// </summary>
        public double Value { get { lock (updateLock) { return primed ? value : double.NaN; } } }

        /// <summary>
        /// The default value of the maximum slow smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length (<c>ℓ</c>) is
        /// <para/>
        /// <c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>
        /// </summary>
        public const double DefaultAlphaSlowLimit = 0.05;

        /// <summary>
        /// The default value of the maximum fast smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length (<c>ℓ</c>) is
        /// <para/>
        /// <c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>
        /// </summary>
        public const double DefaultAlphaFastLimit = 0.5;

        [DataMember]
        private readonly double slowLimit;
        [DataMember]
        private readonly double fastLimit;
        [DataMember]
        private double value;
        [DataMember]
        private double previousPhase;
        [DataMember]
        private readonly IHilbertTransformerCycleEstimator htce;
        [DataMember]
        private bool isPhaseCached;

        private const string mama = "ehlersMaMa";
        private const string mamaFull = "John Ehlers Mesa Adaptive Moving Average";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="slowLimit">The minimum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length <c>ℓ</c> is <para/><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>. The default value is DefaultAlphaSlowLimit (<c>ℓ</c>=39).</param>
        /// <param name="fastLimit">The maximum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length <c>ℓ</c> is<para/><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>. The default value is DefaultAlphaFastLimit (<c>ℓ</c>=3).</param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public MesaAdaptiveMovingAverage(HilbertTransformerCycleEstimator estimator = HilbertTransformerCycleEstimator.HomodyneDiscriminator,
            double slowLimit = DefaultAlphaSlowLimit, double fastLimit = DefaultAlphaFastLimit, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(estimator, estimator.Create(), slowLimit, fastLimit, ohlcvComponent) {}

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
        public MesaAdaptiveMovingAverage(HilbertTransformerCycleEstimator estimator, int smoothingLength, int warmUpPeriod, double alphaEmaQuadratureInPhase,
            double alphaEmaPeriod, double slowLimit = DefaultAlphaSlowLimit, double fastLimit = DefaultAlphaFastLimit, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(estimator, estimator.Create(smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase, alphaEmaPeriod),
                  slowLimit, fastLimit, ohlcvComponent) {}

        private MesaAdaptiveMovingAverage(HilbertTransformerCycleEstimator estimator, IHilbertTransformerCycleEstimator htce,
            double slowLimit, double fastLimit, OhlcvComponent ohlcvComponent)
            : base(mama + estimator.ShortName(), mamaFull + estimator.FullNameInBrackets(), ohlcvComponent)
        {
            if (0d >= slowLimit || 1d < slowLimit)
                throw new ArgumentOutOfRangeException(nameof(slowLimit));
            if (0d >= fastLimit || 1d < fastLimit)
                throw new ArgumentOutOfRangeException(nameof(fastLimit));
            this.htce = htce;
            this.slowLimit = slowLimit;
            this.fastLimit = fastLimit;
            moniker = string.Format(CultureInfo.InvariantCulture, "{0}({1},αFast={2:0.####}(ℓ={3:0.####}),αSlow={4:0.####}(ℓ={5:0.####}))",
                name, htce.Parameters(), fastLimit, Math.Round(2 / fastLimit) - 1, slowLimit, Math.Round(2 / slowLimit) - 1);
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
                isPhaseCached = false;
                htce.Reset();
                value = 0d;
                previousPhase = 0d;
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
                htce.Update(sample);
                if (primed)
                    return Calculate(sample);
                if (htce.IsPrimed)
                {
                    if (isPhaseCached)
                    {
                        primed = true;
                        return Calculate(sample);
                    }
                    isPhaseCached = true;
                    previousPhase = CalculatePhase();
                    value = sample;
                }
                return double.NaN;
            }
        }
        #endregion

        #region Implementation
        private double CalculatePhase()
        {
            // The cycle phase is computed from the arctangent of the ratio of the Quadrature component to the InPhase component.
            double temp = Math.Atan(htce.Quadrature / htce.InPhase) * Constants.Rad2Deg;//TODO: Math.Atan2(im, re)
            if (double.IsNaN(temp) || double.IsInfinity(temp))
                temp = previousPhase;
            return temp;
        }

        private double Calculate(double sample)
        {
            double temp = CalculatePhase();

            // The phase rate of change is obtained by taking the difference of successive previousPhase measurements.
            double phaseRateOfChange = previousPhase - temp;
            previousPhase = temp;

            // Any negative rate change is theoretically impossible because phase must advance as the time increases.
            // We therefore limit all rate change of phase to be no less than unity.
            if (phaseRateOfChange <= 1d)
                temp = fastLimit;
            else //if (phaseRateOfChange > 1d)
            {
                // The α is computed as the fast limit divided by the phase rate of change.
                temp = fastLimit / phaseRateOfChange;
                if (temp < slowLimit)
                    temp = slowLimit;
            }
            value = temp * sample + (1d - temp) * value;
            return value;
        }
        #endregion
    }
}

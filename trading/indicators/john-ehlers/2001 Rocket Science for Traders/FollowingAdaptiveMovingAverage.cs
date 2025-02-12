using System;
using System.Globalization;
using System.Runtime.Serialization;
using Mbst.Numerics;

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// The Following Adaptive Moving Average (FAMA) is produced by applying the MAMA to the first MAMA indicator.
    /// <para/>
    /// By using an <c>α</c> in FAMA that is the half the value of the <c>α</c> in MAMA, the FAMA has steps in time synchronization with MAMA, but the vertical movement is not as great.
    /// <para/>
    /// As a result, MAMA and FAMA do not cross unless there has been a major change in the market direction.
    /// This suggests an adaptive moving average crossover system that is virtually free of whipsaw trades.
    /// <para/>
    /// See John Ehlers, Rocket Science for Traders, Wiley, 2001, 0471405671, pp 177-184.
    /// </summary>
    [DataContract]
    public sealed class FollowingAdaptiveMovingAverage : LineIndicator
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
        /// The current value of the the FAMA, or <c>NaN</c> if not primed.
        /// </summary>
        public double Value { get { lock (updateLock) { return primed ? value : double.NaN; } } }

        /// <summary>
        /// The current value of the the MAMA, or <c>NaN</c> if not primed.
        /// </summary>
        public double MamaValue { get { lock (updateLock) { return primed ? mamaValue : double.NaN; } } }

        [DataMember]
        private readonly double slowLimit;
        [DataMember]
        private readonly double fastLimit;
        [DataMember]
        private double mamaValue;
        [DataMember]
        private double value;
        [DataMember]
        private double previousPhase;
        [DataMember]
        private readonly IHilbertTransformerCycleEstimator htce;
        [DataMember]
        private bool isPhaseCached;
        [DataMember]
        private bool isMamaValueCached;

        private const string fama = "ehlersFaMa";
        private const string famaFull = "John Ehlers Following Adaptive Moving Average";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="slowLimit">The minimum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length <c>ℓ</c> is <para/><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>. The default value is DefaultAlphaSlowLimit (<c>ℓ</c>=39).</param>
        /// <param name="fastLimit">The maximum value of the smoothing factor (<c>α</c>) of the underlying exponential moving average. The equivalent length <c>ℓ</c> is<para/><c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>. The default value is DefaultAlphaFastLimit (<c>ℓ</c>=3).</param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public FollowingAdaptiveMovingAverage(HilbertTransformerCycleEstimator estimator = HilbertTransformerCycleEstimator.HomodyneDiscriminator,
            double slowLimit = MesaAdaptiveMovingAverage.DefaultAlphaSlowLimit, double fastLimit = MesaAdaptiveMovingAverage.DefaultAlphaFastLimit, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
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
        public FollowingAdaptiveMovingAverage(HilbertTransformerCycleEstimator estimator, int smoothingLength, int warmUpPeriod, double alphaEmaQuadratureInPhase,
            double alphaEmaPeriod, double slowLimit = MesaAdaptiveMovingAverage.DefaultAlphaSlowLimit, double fastLimit = MesaAdaptiveMovingAverage.DefaultAlphaFastLimit, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(estimator, estimator.Create(smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase, alphaEmaPeriod),
                  slowLimit, fastLimit, ohlcvComponent) {}

        private FollowingAdaptiveMovingAverage(HilbertTransformerCycleEstimator estimator, IHilbertTransformerCycleEstimator htce,
            double slowLimit, double fastLimit, OhlcvComponent ohlcvComponent)
            : base(fama + estimator.ShortName(), famaFull + estimator.FullNameInBrackets(), ohlcvComponent)
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

        internal string ComposeMoniker(string newNamePrefix)
        {
            return moniker.Replace(fama, newNamePrefix);
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
                isMamaValueCached = false;
                htce.Reset();
                value = 0d;
                mamaValue = 0d;
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
                    if (isMamaValueCached)
                    {
                        isPhaseCached = true;
                        CalculateMama(sample);
                        value = mamaValue;
                    }
                    else
                    {
                        isMamaValueCached = true;
                        previousPhase = CalculatePhase();
                        mamaValue = sample;
                    }
                }
                return double.NaN;
            }
        }
        #endregion

        #region Implementation
        private double CalculatePhase()
        {
            // The cycle phase is computed from the arctangent of the ratio of the Quadrature component to the InPhase component.
            double temp = Math.Atan(htce.Quadrature / htce.InPhase) * Constants.Rad2Deg; //TODO: Math.Atan2(im, re)
            if (double.IsNaN(temp) || double.IsInfinity(temp))
                temp = previousPhase;
            return temp;
        }

        private double CalculateMama(double sample)
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
            mamaValue = temp * sample + (1d - temp) * mamaValue;
            return temp;
        }

        private double Calculate(double sample)
        {
            double temp = CalculateMama(sample) / 2;
            value = temp * mamaValue + (1d - temp) * value;
            return value;
        }
        #endregion
    }
}

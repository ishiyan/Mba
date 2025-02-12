using System.Globalization;
using System.Runtime.Serialization;

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// The Dominant Cycle Period indicator.
    /// <para/>
    /// See John Ehlers, Rocket Science for Traders, Wiley, 2001, 0471405671, pp 52-77.
    /// </summary>
    [DataContract]
    public sealed class DominantCyclePeriod : LineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The WMA smoothing length used by underlying Hilbert transformer.
        /// </summary>
        internal int SmoothingLength => htce.SmoothingLength;

        /// <summary>
        /// The current value of the the Dominant Cycle Period, or <c>NaN</c> if not primed.
        /// </summary>
        public double Value { get { lock (updateLock) { return primed ? smoothedPeriod : double.NaN; } } }

        /// <summary>
        /// The default value of α (0 &lt; α ≤ 1) used in EMA for additional smoothing of the instantaneous period.
        /// </summary>
        public const double DefaultAlphaEmaPeriodAdditional = 0.33;

        [DataMember]
        private double smoothedPeriod;
        [DataMember]
        private readonly double alphaEmaPeriodAdditional;
        [DataMember]
        private readonly double oneMinAlphaEmaPeriodAdditional;
        [DataMember]
        private readonly IHilbertTransformerCycleEstimator htce;

        private const string dcp = "ehlersDcPer";
        private const string dcpFull = "John Ehlers Dominant Cycle Period ";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="alphaEmaPeriodAdditional">The value of α (0 &lt; α ≤ 1) used in EMA for additional smoothing of the instantaneous period. The default value is <c>DefaultAlphaEmaPeriodAdditional</c>.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The default value is median price.</param>
        public DominantCyclePeriod(HilbertTransformerCycleEstimator estimator = HilbertTransformerCycleEstimator.HomodyneDiscriminator,
            double alphaEmaPeriodAdditional = DefaultAlphaEmaPeriodAdditional,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(estimator.Create(), estimator, alphaEmaPeriodAdditional, ohlcvComponent) {}

        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="smoothingLength">The WMA smoothing length. The valid values are 2, 3, 4. The default value is <c>estimator.DefaultSmoothingLength</c>.</param>
        /// <param name="warmUpPeriod">The number of updates before the indicator is primed. If less than the real primed period, then will be reset to the real primed period. The default value is <c>estimator.DefaultWarmUpPeriod</c>.</param>
        /// <param name="alphaEmaQuadratureInPhase">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the in-phase and quadrature components. The default value is <c>estimator.DefaultAlphaEmaQuadratureInPhase</c>.</param>
        /// <param name="alphaEmaPeriod">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the instantaneous period. The default value is <c>estimator.DefaultAlphaEmaPeriod</c>.</param>
        /// <param name="alphaEmaPeriodAdditional">The value of α (0 &lt; α ≤ 1) used in EMA for additional smoothing of the instantaneous period. The default value is <c>DefaultAlphaEmaPeriodAdditional</c>.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The default value is median price.</param>
        public DominantCyclePeriod(HilbertTransformerCycleEstimator estimator, int smoothingLength, int warmUpPeriod,
            double alphaEmaQuadratureInPhase, double alphaEmaPeriod, double alphaEmaPeriodAdditional = DefaultAlphaEmaPeriodAdditional,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(estimator.Create(smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase, alphaEmaPeriod),
                  estimator, alphaEmaPeriodAdditional, ohlcvComponent) {}

        private DominantCyclePeriod(IHilbertTransformerCycleEstimator htce,
            HilbertTransformerCycleEstimator estimator, double alphaEmaPeriodAdditional, OhlcvComponent ohlcvComponent)
            : base(dcp + estimator.ShortName(), dcpFull + estimator.FullNameInBrackets(), ohlcvComponent)
        {
            this.htce = htce;
            moniker = string.Format(CultureInfo.InvariantCulture, "{0}({1},αPeAdd={2:0.####})",
                name, htce.Parameters(), alphaEmaPeriodAdditional);
            this.alphaEmaPeriodAdditional = alphaEmaPeriodAdditional;
            oneMinAlphaEmaPeriodAdditional = 1d - alphaEmaPeriodAdditional;
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
                htce.Reset();
                smoothedPeriod = 0d;
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
                {
                    smoothedPeriod = alphaEmaPeriodAdditional * htce.Period + oneMinAlphaEmaPeriodAdditional * smoothedPeriod;
                    return smoothedPeriod;
                }
                if (htce.IsPrimed)
                {
                    primed = true;
                    smoothedPeriod = htce.Period;
                    return smoothedPeriod;
                }
                return double.NaN;
            }
        }
        #endregion
    }
}

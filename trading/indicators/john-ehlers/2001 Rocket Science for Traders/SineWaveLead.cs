using System;
using System.Runtime.Serialization;
using Mbst.Numerics;

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// The Sine Wave Lead indicator.
    /// <para/>
    /// See John Ehlers, Rocket Science for Traders, Wiley, 2001, 0471405671, pp 95-105.
    /// </summary>
    [DataContract]
    public sealed class SineWaveLead : LineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The WMA smoothing length used by underlying Hilbert transformer.
        /// </summary>
        internal int SmoothingLength => dcp.SmoothingLength;

        /// <summary>
        /// The current value of the the Sine Wave, or <c>NaN</c> if not primed.
        /// </summary>
        public double SineWave => primed ? Math.Sin(dcp.Value * Constants.Deg2Rad) : double.NaN;

        /// <summary>
        /// The current value of the the Sine Wave Lead, or <c>NaN</c> if not primed.
        /// </summary>
        public double Value { get { lock (updateLock) { return value; } } }

        /// <summary>
        /// The current value of the the smoothed Dominant Cycle Period, or <c>NaN</c> if not primed.
        /// The value is not primed during the first <c>23</c> updates.
        /// </summary>
        public double DominantCyclePeriod => dcp.DominantCyclePeriod;

        /// <summary>
        /// The current value of the the Dominant Cycle Phase, or <c>NaN</c> if not primed.
        /// The value is not primed during the first <c>23</c> updates.
        /// </summary>
        public double DominantCyclePhase => dcp.Value;

        [DataMember]
        private double value = double.NaN;
        [DataMember]
        private readonly DominantCyclePhase dcp;

        private const string sineLead = "ehlersSwLead";
        private const string sineLeadFull = "John Ehlers Sine Wave Lead";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="alphaEmaPeriodAdditional">The value of α (0 &lt; α ≤ 1) used in EMA for additional smoothing of the instantaneous period. The default value is <c>DominantCyclePhase.DefaultAlphaEmaPeriodAdditional</c>.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The default value is median price.</param>
        public SineWaveLead(HilbertTransformerCycleEstimator estimator = HilbertTransformerCycleEstimator.HomodyneDiscriminator,
            double alphaEmaPeriodAdditional = JohnEhlers.DominantCyclePhase.DefaultAlphaEmaPeriodAdditional,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(new DominantCyclePhase(estimator, alphaEmaPeriodAdditional, ohlcvComponent), estimator, ohlcvComponent) {}

        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="smoothingLength">The WMA smoothing length. The valid values are 2, 3, 4. The default value is <c>estimator.DefaultSmoothingLength</c>.</param>
        /// <param name="warmUpPeriod">The number of updates before the indicator is primed. If less than the real primed period, then will be reset to the real primed period. The default value is <c>estimator.DefaultWarmUpPeriod</c>.</param>
        /// <param name="alphaEmaQuadratureInPhase">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the in-phase and quadrature components. The default value is <c>estimator.DefaultAlphaEmaQuadratureInPhase</c>.</param>
        /// <param name="alphaEmaPeriod">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the instantaneous period. The default value is <c>estimator.DefaultAlphaEmaPeriod</c>.</param>
        /// <param name="alphaEmaPeriodAdditional">The value of α (0 &lt; α ≤ 1) used in EMA for additional smoothing of the instantaneous period. The default value is <c>DominantCyclePhase.DefaultAlphaEmaPeriodAdditional</c>.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The default value is median price.</param>
        public SineWaveLead(HilbertTransformerCycleEstimator estimator, int smoothingLength, int warmUpPeriod,
            double alphaEmaQuadratureInPhase, double alphaEmaPeriod, double alphaEmaPeriodAdditional = JohnEhlers.DominantCyclePhase.DefaultAlphaEmaPeriodAdditional,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(new DominantCyclePhase(estimator, smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase,
                alphaEmaPeriod, alphaEmaPeriodAdditional, ohlcvComponent), estimator, ohlcvComponent) {}

        private SineWaveLead(DominantCyclePhase dominantCyclePhase, HilbertTransformerCycleEstimator estimator, OhlcvComponent ohlcvComponent)
            : base(sineLead + estimator.ShortName(), sineLeadFull + estimator.FullNameInBrackets(), ohlcvComponent)
        {
            dcp = dominantCyclePhase;
            moniker = dominantCyclePhase.ComposeMoniker(sineLead);
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
                dcp.Reset();
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
                double phase = dcp.Update(sample) + 45d;
                if (primed)
                {
                    value = Math.Sin(phase * Constants.Deg2Rad);
                    return value;
                }
                if (double.IsNaN(phase))
                    return double.NaN;
                primed = true;
                value = Math.Sin(phase * Constants.Deg2Rad);
                return value;
            }
        }
        #endregion
    }
}

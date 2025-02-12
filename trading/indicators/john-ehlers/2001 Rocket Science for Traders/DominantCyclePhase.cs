using System;
using System.Globalization;
using System.Runtime.Serialization;
using Mbst.Numerics;

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// The Dominant Cycle Phase indicator.
    /// <para/>
    /// See John Ehlers, Rocket Science for Traders, Wiley, 2001, 0471405671, pp 52-77.
    /// </summary>
    [DataContract]
    public sealed class DominantCyclePhase : LineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The WMA smoothing length used by underlying Hilbert transformer.
        /// </summary>
        internal int SmoothingLength => htce.SmoothingLength;

        /// <summary>
        /// The current WMA smoothed value used by underlying Hilbert transformer.
        /// </summary>
        internal double SmoothedValue => htce.SmoothedValue;

        /// <summary>
        /// The current value of the the smoothed Dominant Cycle Period, or <c>NaN</c> if not primed.
        /// </summary>
        public double DominantCyclePeriod { get { lock (updateLock) { return primed ? smoothedPeriod : double.NaN; } } }

        /// <summary>
        /// The current value of the the Dominant Cycle Phase, or <c>NaN</c> if not primed.
        /// </summary>
        public double Value { get { lock (updateLock) { return primed ? smoothedPhase : double.NaN; } } }

        /// <summary>
        /// The current value of the the raw Dominant Cycle Phase.
        /// </summary>
        internal double RawValue { get { lock (updateLock) { return smoothedPhase; } } }

        /// <summary>
        /// The default value of α (0 &lt; α ≤ 1) used in EMA for additional smoothing of the instantaneous period.
        /// </summary>
        public const double DefaultAlphaEmaPeriodAdditional = 0.33;

        /// <summary>
        /// The minimal cycle period supported by Hilbert transformer.
        /// </summary>
        public int MinPeriod => htce.MinPeriod;

        /// <summary>
        /// The maximual cycle period supported by Hilbert transformer.
        /// </summary>
        public int MaxPeriod => htce.MaxPeriod;

        [DataMember]
        private double smoothedPeriod;
        [DataMember]
        private double smoothedPhase;
        [DataMember]
        private readonly double alphaEmaPeriodAdditional;
        [DataMember]
        private readonly double oneMinAlphaEmaPeriodAdditional;
        [DataMember]
        private readonly IHilbertTransformerCycleEstimator htce;

        #region Variables to track the last htce.MaxCycle smoothed input values in a circular buffer.
        [DataMember]
        private readonly double[] smoothedInput;
        [DataMember]
        private readonly int smoothedInputLengthMin1;
        #endregion

        private const string dcp = "ehlersDcPha";
        private const string dcpFull = "John Ehlers Dominant Cycle Phase ";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="alphaEmaPeriodAdditional">The value of α (0 &lt; α ≤ 1) used in EMA for additional smoothing of the instantaneous period. The default value is <c>DefaultAlphaEmaPeriodAdditional</c>.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The default value is median price.</param>
        public DominantCyclePhase(HilbertTransformerCycleEstimator estimator = HilbertTransformerCycleEstimator.HomodyneDiscriminator,
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
        public DominantCyclePhase(HilbertTransformerCycleEstimator estimator, int smoothingLength, int warmUpPeriod,
            double alphaEmaQuadratureInPhase, double alphaEmaPeriod, double alphaEmaPeriodAdditional = DefaultAlphaEmaPeriodAdditional,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(estimator.Create(smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase, alphaEmaPeriod), estimator,
                  alphaEmaPeriodAdditional, ohlcvComponent) {}

        private DominantCyclePhase(IHilbertTransformerCycleEstimator htce, HilbertTransformerCycleEstimator estimator,
            double alphaEmaPeriodAdditional, OhlcvComponent ohlcvComponent)
            : base(dcp + estimator.ShortName(), dcpFull + estimator.FullNameInBrackets(), ohlcvComponent)
        {
            this.htce = htce;
            moniker = string.Format(CultureInfo.InvariantCulture, "{0}({1},αPeAdd={2:0.####})",
                name, htce.Parameters(), alphaEmaPeriodAdditional);
            this.alphaEmaPeriodAdditional = alphaEmaPeriodAdditional;
            oneMinAlphaEmaPeriodAdditional = 1d - alphaEmaPeriodAdditional;
            smoothedInputLengthMin1 = htce.MaxPeriod - 1;
            smoothedInput = new double[htce.MaxPeriod];
            smoothedInput.Initialize();
        }

        internal string ComposeMoniker(string newNamePrefix)
        {
            return moniker.Replace(dcp, newNamePrefix);
        }

        internal string ComposeMoniker(string newNamePrefix, string additionalParameters)
        {
            return moniker.Replace(dcp, newNamePrefix).Replace(")", additionalParameters + ")");
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
                smoothedPhase = 0d;
                smoothedPeriod = 0d;
                smoothedInput.Initialize();
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
                PushSmoothedInput(htce.SmoothedValue);
                if (primed)
                {
                    smoothedPeriod = alphaEmaPeriodAdditional * htce.Period + oneMinAlphaEmaPeriodAdditional * smoothedPeriod;
                    CalculateSmoothedPhase();
                    return smoothedPhase;
                }
                if (htce.IsPrimed)
                {
                    primed = true;
                    smoothedPeriod = htce.Period;
                    CalculateSmoothedPhase();
                    return smoothedPhase;
                }
                return double.NaN;
            }
        }
        #endregion

        #region Implementation
        private void PushSmoothedInput(double value)
        {
            Array.Copy(smoothedInput, 0, smoothedInput, 1, smoothedInputLengthMin1);
            smoothedInput[0] = value;
        }

        private void CalculateSmoothedPhase()
        {
            // The smoothed data are multiplied by the real (cosine) component of the dominant cycle
            // and independently by the imaginary (sine) component of the dominant cycle.
            // The products are summed then over one full dominant cycle.
            int length = (int)Math.Floor(smoothedPeriod + 0.5);
            if (length > smoothedInputLengthMin1)
                length = smoothedInputLengthMin1;
            double realPart = 0d, imagPart = 0d, temp;
            for (int i = 0; i < length; ++i)
            {
                temp = Constants.TwoPi * i / length;
                double smoothed = smoothedInput[i];
                realPart += smoothed * Math.Sin(temp);
                imagPart += smoothed * Math.Cos(temp);
            }
            // We compute the phase angle as the arctangent of the ratio of the real part to the imaginary part.
            // The phase increases from the left to right.
            temp = smoothedPhase;
            smoothedPhase = Math.Atan(realPart / imagPart) * Constants.Rad2Deg;//TODO: Math.Atan2(im, re)
            if (double.IsNaN(smoothedPhase) || double.IsInfinity(smoothedPhase))
                smoothedPhase = temp;
            if (Math.Abs(imagPart) <= 0.01)
                smoothedPhase += 90d * Math.Sign(realPart);

            // Introduce the 90 degree reference shift.
            smoothedPhase += 90d;
            // Compensate for one bar lag of the smoothed input price (weighted moving average).
            // This is done by adding the phase corresponding to a 1-bar lag of the smoothed dominant cycle period.
            smoothedPhase += 360d / smoothedPeriod;
            // Resolvephase ambiguity when the imaginary part is negative to provide a 360 degree phase presentation.
            if (0d > imagPart)
                smoothedPhase += 180d;
            // Perform the cycle wraparound at 315 degrees because there is a tendency for the phase
            // to be near 0 degrees when the market is in a downtrend.If the wraparound were at 360 degrees,
            // the swing from the bottom of the subgraph to the top provides less than a pleasing display.
            if (360d < smoothedPhase) //(315d < smoothedPhase)
                smoothedPhase -= 360d;
        }
        #endregion
    }
}

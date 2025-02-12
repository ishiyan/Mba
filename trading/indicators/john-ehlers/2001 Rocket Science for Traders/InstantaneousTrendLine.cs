using System;
using System.Globalization;
using System.Runtime.Serialization;

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// <para>
    /// The Instantaneous Trend Line indicator.</para>
    /// <para/>
    /// See John Ehlers, Rocket Science for Traders, Wiley, 2001, 0471405671, pp 107-112.
    /// </summary>
    [DataContract]
    public sealed class InstantaneousTrendLine : LineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The WMA smoothing length used by underlying Hilbert transformer.
        /// </summary>
        internal int SmoothingLength => htce.SmoothingLength;

        /// <summary>
        /// The current WMA smoothed price used by underlying Hilbert transformer.
        /// </summary>
        public double SmoothedPrice => htce.SmoothedValue;

        /// <summary>
        /// The current value of the the smoothed Dominant Cycle Period, or <c>NaN</c> if not primed.
        /// </summary>
        public double DominantCyclePeriod { get { lock (updateLock) { return primed ? smoothedPeriod : double.NaN; } } }

        /// <summary>
        /// The current value of the the Instantaneous Trend Line, or <c>NaN</c> if not primed.
        /// </summary>
        public double Value { get { lock (updateLock) { return primed ? value : double.NaN; } } }

        /// <summary>
        /// The additional WMA smoothing length used to smooth the trend line.
        /// </summary>
        public int TrendLineSmoothingLength => trendLineSmoothingLength;

        /// <summary>
        /// The multiplier to the dominant cycle period used to determine the window length to calculate the trend line.
        /// </summary>
        public double CyclePartMultiplier => cyclePartMultiplier;

        /// <summary>
        /// The default value of an additional WMA smoothing length used to smooth the trend line.
        /// </summary>
        public const int DefaultTrendLineSmoothingLength = 4;

        /// <summary>
        /// The default value of the multiplier to the dominant cycle period used to determine the window length to calculate the trend line.
        /// </summary>
        public const double DefaultCyclePartMultiplier = 1;

        [DataMember]
        private double smoothedPeriod;
        [DataMember]
        private double value;
        [DataMember]
        private double average1;
        [DataMember]
        private double average2;
        [DataMember]
        private double average3;
        [DataMember]
        private readonly double coeff0;
        [DataMember]
        private readonly double coeff1;
        [DataMember]
        private readonly double coeff2;
        [DataMember]
        private readonly double coeff3;
        [DataMember]
        private readonly double alphaEmaPeriodAdditional;
        [DataMember]
        private readonly double oneMinAlphaEmaPeriodAdditional;
        [DataMember]
        private readonly double cyclePartMultiplier;
        [DataMember]
        private readonly IHilbertTransformerCycleEstimator htce;

        #region Variables to track the last htce.MaxCycle input values in a circular buffer.
        [DataMember]
        private readonly double[] input;
        [DataMember]
        private readonly int inputLength;
        [DataMember]
        private readonly int inputLengthMin1;
        #endregion

        [DataMember]
        private readonly int trendLineSmoothingLength;

        private const string itl = "ehlersItl";
        private const string itlFull = "John Ehlers Instantaneous Trend Line";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="alphaEmaPeriodAdditional">The value of α (0 &lt; α ≤ 1) used in EMA for additional smoothing of the instantaneous period. The default value is <c>DominantCyclePhase.DefaultAlphaEmaPeriodAdditional</c>.</param>
        /// <param name="trendLineSmoothingLength">The additional WMA smoothing length used to smooth the trend line. The valid values are 2, 3, 4. The default value is <c>DefaultTrendLineSmoothingLength</c>.</param>
        /// <param name="cyclePartMultiplier">The multiplier to the dominant cycle period used to determine the window length to calculate the trend line. The typical values are in [0.5, 1.5]. The default value is <c>DefaultCyclePartMultiplier</c>.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The default value is median price.</param>
        public InstantaneousTrendLine(HilbertTransformerCycleEstimator estimator = HilbertTransformerCycleEstimator.HomodyneDiscriminator,
            double alphaEmaPeriodAdditional = DominantCyclePhase.DefaultAlphaEmaPeriodAdditional,
            int trendLineSmoothingLength = DefaultTrendLineSmoothingLength, double cyclePartMultiplier = DefaultCyclePartMultiplier,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(estimator.Create(), estimator, alphaEmaPeriodAdditional, trendLineSmoothingLength, cyclePartMultiplier, ohlcvComponent) {}

        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="smoothingLength">The WMA smoothing length. The valid values are 2, 3, 4. The default value is <c>estimator.DefaultSmoothingLength</c>.</param>
        /// <param name="warmUpPeriod">The number of updates before the indicator is primed. If less than the real primed period, then will be reset to the real primed period. The default value is <c>estimator.DefaultWarmUpPeriod</c>.</param>
        /// <param name="alphaEmaQuadratureInPhase">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the in-phase and quadrature components. The default value is <c>estimator.DefaultAlphaEmaQuadratureInPhase</c>.</param>
        /// <param name="alphaEmaPeriod">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the instantaneous period. The default value is <c>estimator.DefaultAlphaEmaPeriod</c>.</param>
        /// <param name="alphaEmaPeriodAdditional">The value of α (0 &lt; α ≤ 1) used in EMA for additional smoothing of the instantaneous period. The default value is <c>DominantCyclePhase.DefaultAlphaEmaPeriodAdditional</c>.</param>
        /// <param name="trendLineSmoothingLength">The additional WMA smoothing length used to smooth the trend line. The valid values are 2, 3, 4. The default value is <c>DefaultTrendLineSmoothingLength</c>..</param>
        /// <param name="cyclePartMultiplier">The multiplier to the dominant cycle period used to determine the window length to calculate the trend line. The typical values are in [0.5, 1.5]. The default value is <c>DefaultCyclePartMultiplier</c>.</param>
        /// <param name="ohlcvComponent">The Ohlcv component. The default value is median price.</param>
        public InstantaneousTrendLine(HilbertTransformerCycleEstimator estimator, int smoothingLength, int warmUpPeriod,
            double alphaEmaQuadratureInPhase, double alphaEmaPeriod, double alphaEmaPeriodAdditional = DominantCyclePhase.DefaultAlphaEmaPeriodAdditional,
            int trendLineSmoothingLength = DefaultTrendLineSmoothingLength, double cyclePartMultiplier = DefaultCyclePartMultiplier,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(estimator.Create(smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase, alphaEmaPeriod),
                  estimator, alphaEmaPeriodAdditional, trendLineSmoothingLength, cyclePartMultiplier, ohlcvComponent) {}

        private InstantaneousTrendLine(IHilbertTransformerCycleEstimator htce, HilbertTransformerCycleEstimator estimator,
            double alphaEmaPeriodAdditional = DominantCyclePhase.DefaultAlphaEmaPeriodAdditional,
            int trendLineSmoothingLength = DefaultTrendLineSmoothingLength, double cyclePartMultiplier = DefaultCyclePartMultiplier,
            OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : base(itl + estimator.ShortName(), itlFull + estimator.FullNameInBrackets(), ohlcvComponent)
        {
            if (2 > trendLineSmoothingLength || 4 < trendLineSmoothingLength)
                throw new ArgumentOutOfRangeException(nameof(trendLineSmoothingLength));
            if (0d > alphaEmaPeriodAdditional || 1d < alphaEmaPeriodAdditional)
                throw new ArgumentOutOfRangeException(nameof(alphaEmaPeriodAdditional));
            if (0d >= cyclePartMultiplier || 10d < cyclePartMultiplier)
                throw new ArgumentOutOfRangeException(nameof(cyclePartMultiplier));
            this.htce = htce;
            moniker = string.Format(CultureInfo.InvariantCulture, "{0}({1},αPeAdd={2:0.####},tlsl={3},cpMul={4:0.####})",
                name, htce.Parameters(), alphaEmaPeriodAdditional, trendLineSmoothingLength, cyclePartMultiplier);
            this.cyclePartMultiplier = cyclePartMultiplier;
            this.alphaEmaPeriodAdditional = alphaEmaPeriodAdditional;
            oneMinAlphaEmaPeriodAdditional = 1d - alphaEmaPeriodAdditional;
            inputLength = htce.MaxPeriod;
            inputLengthMin1 = inputLength - 1;
            input = new double[inputLength];
            input.Initialize();
            this.trendLineSmoothingLength = trendLineSmoothingLength;
            if (2 == trendLineSmoothingLength)
            {
                coeff0 = 2d / 3d;
                coeff1 = 1d / 3d;
            }
            else if (3 == trendLineSmoothingLength)
            {
                coeff0 = 3d / 6d;
                coeff1 = 2d / 6d;
                coeff2 = 1d / 6d;
            }
            else //if (4 == trendLineSmoothingLength)
            {
                coeff0 = 4d / 10d;
                coeff1 = 3d / 10d;
                coeff2 = 2d / 10d;
                coeff3 = 1d / 10d;
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
                htce.Reset();
                value = 0d;
                average1 = 0d;
                average2 = 0d;
                average3 = 0d;
                smoothedPeriod = 0d;
                input.Initialize();
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
                PushInput(sample);
                if (primed)
                {
                    smoothedPeriod = alphaEmaPeriodAdditional * htce.Period + oneMinAlphaEmaPeriodAdditional * smoothedPeriod;
                    double average = CalculateAverage();
                    value = Wma(average);
                    PushAverage(average);
                    return value;
                }
                if (htce.IsPrimed)
                {
                    primed = true;
                    smoothedPeriod = htce.Period;
                    value = CalculateAverage();
                    average3 = value;
                    average2 = value;
                    average1 = value;
                    return value;
                }
                return double.NaN;
            }
        }
        #endregion

        #region Implementation
        private void PushInput(double val)
        {
            Array.Copy(input, 0, input, 1, inputLengthMin1);
            input[0] = val;
        }
        private void PushAverage(double val)
        {
            average3 = average2;
            average2 = average1;
            average1 = val;
        }

        private double Wma(double val)
        {
            return coeff0 * val + coeff1 * average1 + coeff2 * average2 + coeff3 * average3;
        }

        private double CalculateAverage()
        {
            // Compute the trend line as a simple average over the measured dominant cycle period.
            int length = (int)Math.Floor(smoothedPeriod * cyclePartMultiplier + 0.5);
            if (length > inputLength)
                length = inputLength;
            else if (length < 1)
                length = 1;
            double temp = 0d;
            for (int i = 0; i < length; ++i)
                temp += input[i];
            return temp / length;
        }
        #endregion
    }
}

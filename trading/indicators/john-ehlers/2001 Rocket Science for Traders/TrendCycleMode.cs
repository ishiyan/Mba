using System;
using System.Globalization;
using System.Runtime.Serialization;
using Mbst.Numerics;

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// <para>
    /// The Trend versus Cycle Mode indicator.</para>
    /// <para/>
    /// See John Ehlers, Rocket Science for Traders, Wiley, 2001, 0471405671, pp 113-118.
    /// </summary>
    [DataContract]
    public sealed class TrendCycleMode : LineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The WMA smoothing length used by underlying Hilbert transformer.
        /// </summary>
        internal int SmoothingLength => dcp.SmoothingLength;

        /// <summary>
        /// The current WMA smoothed price used by underlying Hilbert transformer.
        /// </summary>
        public double SmoothedPrice => dcp.SmoothedValue;

        /// <summary>
        /// The current value of the the smoothed Dominant Cycle Period, or <c>NaN</c> if not primed.
        /// </summary>
        public double DominantCyclePeriod => dcp.DominantCyclePeriod;

        /// <summary>
        /// The current value of the the Dominant Cycle Phase, or <c>NaN</c> if not primed.
        /// </summary>
        public double DominantCyclePhase => dcp.Value;

        /// <summary>
        /// The current value of the the Sine Wave, or <c>NaN</c> if not primed.
        /// </summary>
        public double SineWave { get { lock (updateLock) { return primed ? sinWave : double.NaN; } } }

        /// <summary>
        /// The current value of the the Sine Wave Lead, or <c>NaN</c> if not primed.
        /// </summary>
        public double SineWaveLead { get { lock (updateLock) { return primed ? sinWaveLead : double.NaN; } } }

        /// <summary>
        /// The current value of the the Instantaneous Trend Line, or <c>NaN</c> if not primed.
        /// </summary>
        public double InstantaneousTrendLine { get { lock (updateLock) { return primed ? trendline : double.NaN; } } }

        /// <summary>
        /// The additional WMA smoothing length used to smooth the trend line.
        /// </summary>
        public int TrendLineSmoothingLength => trendLineSmoothingLength;

        /// <summary>
        /// If the WMA smoothed price is separated by more than this percentage from the instantaneous trend line, then the market is in the trend mode.
        /// </summary>
        public double SeparationPercentage => separationPercentage;

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

        /// <summary>
        /// The default value of the separation percentage.
        /// If the WMA smoothed price is separated by more than this percentage from the instantaneous trend line, then the market is in the trend mode.
        /// </summary>
        public const double DefaultSeparationPercentage = 1.5;

        /// <summary>
        /// The current value of the the Trend versus Cycle Mode, or <c>NaN</c> if not primed.
        /// The value equals to <c>-1</c> if in cycle mode, or equals to <c>1</c> in trend mode.
        /// </summary>
        public double Value { get { lock (updateLock) { return isTrendMode ? 1d : -1d; } } }

        /// <summary>
        /// If the trend mode is declared.
        /// </summary>
        public bool IsTrendMode { get { lock (updateLock) { return isTrendMode; } } }

        /// <summary>
        /// If the cycle mode is declared.
        /// </summary>
        public bool IsCycleMode { get { lock (updateLock) { return !isTrendMode; } } }

        [DataMember]
        private double sinWave;
        [DataMember]
        private double sinWaveLead;
        [DataMember]
        private double trendline;
        [DataMember]
        private double trendAverage1;
        [DataMember]
        private double trendAverage2;
        [DataMember]
        private double trendAverage3;
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
        private readonly double separationPercentage;
        [DataMember]
        private readonly double separationFactor;
        [DataMember]
        private double prevDcPhase;
        [DataMember]
        private double prevSineLeadWaveDifference;
        [DataMember]
        private readonly DominantCyclePhase dcp;
        [DataMember]
        private int samplesInTrend;
        [DataMember]
        private readonly int trendLineSmoothingLength;
        [DataMember]
        private bool isTrendMode = true;

        #region Variables to track the last htce.MaxCycle input values in a circular buffer.
        private readonly int inputLength;
        private readonly int inputLengthMin1;
        [DataMember]
        private readonly double[] input;
        #endregion

        private const string tcm = "ehlersTcm";
        private const string tcmFull = "John Ehlers Trend/Cycle Mode";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="alphaEmaPeriodAdditional">The value of α (0 &lt; α ≤ 1) used in EMA for additional smoothing of the instantaneous period. The default value is <c>DefaultAlphaEmaPeriodAdditional</c>.</param>
        /// <param name="trendLineSmoothingLength">The additional WMA smoothing length used to smooth the trend line. The valid values are 2, 3, 4. The default value is <c>DefaultTrendLineSmoothingLength</c>..</param>
        /// <param name="cyclePartMultiplier">The multiplier to the dominant cycle period used to determine the window length to calculate the trend line. The typical values are in [0.5, 1.5]. The default value is DefaultCyclePartMultiplier.</param>
        /// <param name="separationPercentage">If the WMA smoothed price is separated by more than this percentage from the instantaneous trend line, then the market is in the trend mode. The default value is DefaultSeparationPercentage.</param>
        /// <param name="ohlcvComponent">The ohlcv component used to calculate the indicator.</param>
        public TrendCycleMode(HilbertTransformerCycleEstimator estimator = HilbertTransformerCycleEstimator.HomodyneDiscriminator,
            double alphaEmaPeriodAdditional = JohnEhlers.DominantCyclePhase.DefaultAlphaEmaPeriodAdditional,
            int trendLineSmoothingLength = DefaultTrendLineSmoothingLength, double cyclePartMultiplier = DefaultCyclePartMultiplier,
            double separationPercentage = DefaultSeparationPercentage, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(new DominantCyclePhase(estimator, alphaEmaPeriodAdditional, ohlcvComponent),
                  estimator, alphaEmaPeriodAdditional, trendLineSmoothingLength, cyclePartMultiplier, separationPercentage, ohlcvComponent) {}

        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="estimator">The type of an estimator. The default is homodyne discriminator.</param>
        /// <param name="smoothingLength">The WMA smoothing length. The valid values are 2, 3, 4. The default value is <c>estimator.DefaultSmoothingLength</c>.</param>
        /// <param name="warmUpPeriod">The number of updates before the indicator is primed. If less than the real primed period, then will be reset to the real primed period. The default value is <c>estimator.DefaultWarmUpPeriod</c>.</param>
        /// <param name="alphaEmaQuadratureInPhase">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the in-phase and quadrature components. The default value is <c>estimator.DefaultAlphaEmaQuadratureInPhase</c>.</param>
        /// <param name="alphaEmaPeriod">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the instantaneous period. The default value is <c>estimator.DefaultAlphaEmaPeriod</c>.</param>
        /// <param name="alphaEmaPeriodAdditional">The value of α (0 &lt; α ≤ 1) used in EMA for additional smoothing of the instantaneous period. The default value is <c>DefaultAlphaEmaPeriodAdditional</c>.</param>
        /// <param name="trendLineSmoothingLength">The additional WMA smoothing length used to smooth the trend line. The valid values are 2, 3, 4. The default value is <c>DefaultTrendLineSmoothingLength</c>..</param>
        /// <param name="cyclePartMultiplier">The multiplier to the dominant cycle period used to determine the window length to calculate the trend line. The typical values are in [0.5, 1.5]. The default value is DefaultCyclePartMultiplier.</param>
        /// <param name="separationPercentage">If the WMA smoothed price is separated by more than this percentage from the instantaneous trend line, then the market is in the trend mode. The default value is DefaultSeparationPercentage.</param>
        /// <param name="ohlcvComponent">The ohlcv component used to calculate the indicator.</param>
        public TrendCycleMode(HilbertTransformerCycleEstimator estimator, int smoothingLength, int warmUpPeriod,
            double alphaEmaQuadratureInPhase, double alphaEmaPeriod, double alphaEmaPeriodAdditional = JohnEhlers.DominantCyclePhase.DefaultAlphaEmaPeriodAdditional,
            int trendLineSmoothingLength = DefaultTrendLineSmoothingLength, double cyclePartMultiplier = DefaultCyclePartMultiplier,
            double separationPercentage = DefaultSeparationPercentage, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : this(new DominantCyclePhase(estimator, smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase, alphaEmaPeriod, alphaEmaPeriodAdditional, ohlcvComponent),
                  estimator, alphaEmaPeriodAdditional, trendLineSmoothingLength, cyclePartMultiplier, separationPercentage, ohlcvComponent) {}

        private TrendCycleMode(DominantCyclePhase dcp, HilbertTransformerCycleEstimator estimator,
            double alphaEmaPeriodAdditional, int trendLineSmoothingLength,
            double cyclePartMultiplier, double separationPercentage, OhlcvComponent ohlcvComponent)
            : base(tcm + estimator.ShortName(), tcmFull + estimator.FullNameInBrackets(), ohlcvComponent)
        {
            if (2 > trendLineSmoothingLength || 4 < trendLineSmoothingLength)
                throw new ArgumentOutOfRangeException(nameof(trendLineSmoothingLength));
            if (0d >= cyclePartMultiplier || 10d < cyclePartMultiplier)
                throw new ArgumentOutOfRangeException(nameof(cyclePartMultiplier));
            if (0d >= separationPercentage || 100d < separationPercentage)
                throw new ArgumentOutOfRangeException(nameof(separationPercentage));
            string additionalParameters = string.Format(CultureInfo.InvariantCulture, ",tlsl={0},cpMul={1:0.####},sep={2:0.####}%",
                trendLineSmoothingLength, cyclePartMultiplier, separationPercentage);
            moniker = dcp.ComposeMoniker(tcm, additionalParameters);
            this.dcp = dcp;
            this.alphaEmaPeriodAdditional = alphaEmaPeriodAdditional;
            oneMinAlphaEmaPeriodAdditional = 1d - alphaEmaPeriodAdditional;
            this.trendLineSmoothingLength = trendLineSmoothingLength;
            this.cyclePartMultiplier = cyclePartMultiplier;
            this.separationPercentage = separationPercentage;
            separationFactor = separationPercentage / 100;
            inputLength = dcp.MaxPeriod;
            inputLengthMin1 = inputLength - 1;
            input = new double[inputLength];
            input.Initialize();
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
                isTrendMode = true;
                dcp.Reset();
                trendline = 0d;
                trendAverage1 = 0d;
                trendAverage2 = 0d;
                trendAverage3 = 0d;
                prevDcPhase = 0d;
                prevSineLeadWaveDifference = 0d;
                sinWave = 0d;
                sinWaveLead = 0d;
                samplesInTrend = 0;
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
                dcp.Update(sample);
                PushInput(sample);
                if (primed)
                {
                    double smoothedPeriod = dcp.DominantCyclePeriod;
                    double average = CalculateTrendAverage(smoothedPeriod);
                    trendline = Wma(average);
                    PushTrendAverage(average);

                    double phase = dcp.RawValue;
                    double diff = CalculateSineLeadWaveDifference(phase);

                    // Compute the trend mode, assuming trend by default.
                    isTrendMode = true;
                    // Measure days in trend from last the crossing of the SineWave and SineWaveLead indicator lines.
                    // Condition 1. A cycle mode exists for the half-period of a dominant cycle after the crossing.
                    if ((diff > 0 && prevSineLeadWaveDifference < 0) || (diff < 0 && prevSineLeadWaveDifference > 0))
                    {
                        isTrendMode = false;
                        samplesInTrend = 0;
                    }
                    prevSineLeadWaveDifference = diff;
                    if (++samplesInTrend < 0.5 * smoothedPeriod)
                        isTrendMode = false;

                    // Cycle mode if delta phase is ±50% of dominant cycle change of phase.
                    // Condition 2. A cycle mode exists if the measured phase rate of change is
                    // more than 2/3 the phase rate of change of the dominant cycle (360/period)
                    // and is less than 1.5 times the phase rate of change of the dominant cycle.
                    diff = phase - prevDcPhase;
                    prevDcPhase = phase;
                    if (Math.Abs(smoothedPeriod) > double.Epsilon)
                    {
                        const double minFactor = 2d / 3d, maxFactor = 1.5;
                        smoothedPeriod = 360d / smoothedPeriod;
                        if (diff > minFactor * smoothedPeriod &&
                            diff < maxFactor * smoothedPeriod)
                            isTrendMode = false;
                    }

                    // When the market makes a major reversal, it often does this with great vigor.
                    // When this occurs, the prices have a wide separation from the instantaneous trend line.
                    // Condition 3. If the WMA smoothed price is separated by more than 1.5%
                    // from the instantaneous trend line, then the market is in the trend mode.
                    if (Math.Abs(trendline) > double.Epsilon &&
                        Math.Abs((dcp.SmoothedValue - trendline) / trendline) >= separationFactor)
                        isTrendMode = true;

                    return isTrendMode ? 1d : -1d;
                }
                if (dcp.IsPrimed)
                {
                    primed = true;
                    double smoothedPeriod = dcp.DominantCyclePeriod;
                    trendline = CalculateTrendAverage(smoothedPeriod);
                    trendAverage3 = trendline;
                    trendAverage2 = trendline;
                    trendAverage1 = trendline;

                    prevDcPhase = dcp.RawValue;
                    prevSineLeadWaveDifference = CalculateSineLeadWaveDifference(prevDcPhase);

                    isTrendMode = true;
                    if (++samplesInTrend < 0.5 * smoothedPeriod)
                        isTrendMode = false;

                    return isTrendMode ? 1d : -1d;
                }
                return 0d;
            }
        }
        #endregion

        #region Implementation
        private void PushInput(double val)
        {
            Array.Copy(input, 0, input, 1, inputLengthMin1);
            input[0] = val;
        }
        private void PushTrendAverage(double val)
        {
            trendAverage3 = trendAverage2;
            trendAverage2 = trendAverage1;
            trendAverage1 = val;
        }

        private double Wma(double val)
        {
            return coeff0 * val + coeff1 * trendAverage1 + coeff2 * trendAverage2 + coeff3 * trendAverage3;
        }

        private double CalculateTrendAverage(double smoothedPeriod)
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

        private double CalculateSineLeadWaveDifference(double phase)
        {
            const double pi4 = 45d * Constants.Deg2Rad;
            phase *= Constants.Deg2Rad;
            sinWave = Math.Sin(phase);
            sinWaveLead = Math.Sin(phase + pi4);
            return sinWave - sinWaveLead;
        }
        #endregion
    }
}

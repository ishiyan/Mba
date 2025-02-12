using System;
using System.Globalization;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// Adaptive zero-lag exponential moving average.
    /// <para/>
    /// See John Ehlers and Ric Way, 'Zero Lag (well, almost)', TASC, 2010, v28.11, pp30-35.
    /// </summary>
    public sealed class ZeroLagErrorCorrectingExponentialMovingAverage : LineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The SMA length (<c>ℓ</c>) equivalent to the smoothing factor (<c>α</c>) of the EMA.<para/>
        /// <c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>.
        /// </summary>
        public int Length { get; }

        /// <summary>
        /// The smoothing factor (<c>α</c>) of the EMA.<para/>
        /// <c>α = 2/(ℓ + 1), 0 &lt; α ≤ 1, 1 ≤ ℓ</c> where <c>ℓ</c> is the equivalent SMA length.
        /// </summary>
        public double SmoothingFactor { get; }

        /// <summary>
        /// Defines the range [-g, g] for finding the best gain factor.
        /// </summary>
        public double GainLimit { get; }

        /// <summary>
        /// Defines the iteration step for finding the best gain factor.
        /// </summary>
        public double GainStep { get; }

        /// <summary>
        /// The default value of a SMA length equivalent to the smoothing factor of the EMA.
        /// </summary>
        public const int DefaultLength = 20;

        /// <summary>
        /// The default value of the smoothing factor of the EMA.
        /// </summary>
        public const double DefaultSmoothingFactor = 0.095;

        /// <summary>
        /// The default value of the range [-g, g] for finding the best gain factor.
        /// </summary>
        public const double DefaultGainLimit = 5;

        /// <summary>
        /// The default value of the iteration step for finding the best gain factor.
        /// </summary>
        public const double DefaultGainStep = 0.1;

        /// <summary>
        /// The current value of the indicator, or <c>NaN</c> if not primed.<para/>
        /// The indicator is not primed during two first updates.
        /// </summary>
        public double Value { get { lock (updateLock) { return primed ? value : double.NaN; } } }

        /// <summary>
        /// The current value of the underlying EMA, or <c>NaN</c> if not primed.<para/>
        /// The indicator is not primed during two first updates.
        /// </summary>
        public double EmaValue { get { lock (updateLock) { return primed ? emaValue : double.NaN; } } }

        private readonly double oneMinAlpha;
        private double value = double.NaN;
        private double emaValue = double.NaN;
        private int count;

        private const double Epsilon = 0.00000001;
        private const string ZecEma = "ehlersZecema";
        private const string ZecEmaFull = "John Ehlers Zero-lag Error-Correcting Exponential Moving Average";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="length">The SMA length (<c>ℓ</c>) equivalent to the smoothing factor (<c>α</c>) of the exponential moving average<para/>
        /// <c>ℓ = 2/α - 1, 0 &lt; α ≤ 1, 1 ≤ ℓ</c>.<para/>
        /// The default value is <c>DefaultLength</c>.
        /// </param>
        /// <param name="gainLimit">Defines the range [-g, g] for finding the best gain factor.<para/>
        /// The default value is <c>DefaultGainLimit</c>.
        /// </param>
        /// <param name="gainStep">Defines the iteration step for finding the best gain factor.<para/>
        /// The default value is <c>DefaultGainStep</c>.
        /// </param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public ZeroLagErrorCorrectingExponentialMovingAverage(int length = DefaultLength,
            double gainLimit = DefaultGainLimit, double gainStep = DefaultGainStep, OhlcvComponent ohlcvComponent = OhlcvComponent.ClosingPrice)
            : this(length, double.NaN, gainLimit, gainStep, ohlcvComponent) {}

        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="smoothingFactor">The smoothing factor, <c>α, 0 &lt; α ≤ 1</c>, of the exponential moving average.<para/>
        /// <c>α = 2/(ℓ + 1), 0 &lt; α ≤ 1, 1 ≤ ℓ</c> where <c>ℓ</c> is the equivalent SMA length.<para/>
        /// The default value is <c>DefaultSmoothingFactor</c>.
        /// </param>
        /// <param name="gainLimit">Defines the range [-g, g] for finding the best gain factor.<para/>
        /// The default value is <c>DefaultGainLimit</c>.
        /// </param>
        /// <param name="gainStep">Defines the iteration step for finding the best gain factor.<para/>
        /// The default value is <c>DefaultGainStep</c>.
        /// </param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public ZeroLagErrorCorrectingExponentialMovingAverage(double smoothingFactor /*= DefaultSmoothingFactor*/,
            double gainLimit = DefaultGainLimit, double gainStep = DefaultGainStep, OhlcvComponent ohlcvComponent = OhlcvComponent.ClosingPrice)
            : this(0, smoothingFactor, gainLimit, gainStep, ohlcvComponent) {}

        private ZeroLagErrorCorrectingExponentialMovingAverage(int length, double smoothingFactor,
            double gainLimit, double gainStep, OhlcvComponent ohlcvComponent)
            : base(ZecEma, ZecEmaFull, ohlcvComponent)
        {
            if (double.IsNaN(smoothingFactor))
            {
                if (1 > length)
                    throw new ArgumentOutOfRangeException(nameof(length));
                this.Length = length;
                SmoothingFactor = 2d / (1 + length);
            }
            else
            {
                if (0d > smoothingFactor || 1d < smoothingFactor)
                    throw new ArgumentOutOfRangeException(nameof(smoothingFactor));
                SmoothingFactor = smoothingFactor;
                if (Epsilon > smoothingFactor)
                    length = int.MaxValue;
                else
                    length = (int)Math.Round(2d / smoothingFactor) - 1;
            }
            if (0 >= gainLimit)
                throw new ArgumentOutOfRangeException(nameof(gainLimit));
            if (0 >= gainStep)
                throw new ArgumentOutOfRangeException(nameof(gainStep));
            oneMinAlpha = 1 - SmoothingFactor;
            this.GainLimit = gainLimit;
            this.GainStep = gainStep;
            Moniker = string.Format(CultureInfo.InvariantCulture, "{0}(ℓ={1}(α={2:0.####}),gl={3:0.####},gs={4:0.####})",
                ZecEma, length, SmoothingFactor, gainLimit, gainStep);
        }
        #endregion

        #region Reset
        /// <inheritdoc />
        public override void Reset()
        {
            lock (updateLock)
            {
                primed = false;
                count = 0;
                value = double.NaN;
                emaValue = double.NaN;
            }
        }
        #endregion

        #region Update
        /// <inheritdoc />
        public override double Update(double sample)
        {
            if (double.IsNaN(sample))
                return sample;
            lock (updateLock)
            {
                if (primed)
                    value= Calculate(sample);
                else
                {
                    if (++count == 1)
                        emaValue = sample;
                    else if (count == 2)
                    {
                        emaValue = CalculateEma(sample);
                        value = emaValue;
                    }
                    else
                    {
                        value= Calculate(sample);
                        primed = true;
                    }
                    if (!primed)
                        return double.NaN;
                }
                return value;
            }
        }
        #endregion

        private double CalculateEma(double sample)
        {
            return SmoothingFactor * sample + oneMinAlpha * emaValue;
        }

        private double Calculate(double sample)
        {
            emaValue = CalculateEma(sample);
            double leastError = double.MaxValue;
            double bestErrorCorrection = 0;
            for (double gain = -GainLimit; gain <= GainLimit; gain += GainStep)
            {
                double errorCorrection = SmoothingFactor * (emaValue + gain * (sample - value)) + oneMinAlpha * value;
                double error = Math.Abs(sample - errorCorrection); 
                if (leastError > error)
                {
                    leastError = error;
                    bestErrorCorrection = errorCorrection;
                }
            }
            return bestErrorCorrection;
        }
    }
}

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// A Hilbert transformer of WMA-smoothed and detrended data followed by the estimator to determine the instantaneous period.
    /// See John Ehlers, Rocket Science for Traders, Wiley, 2001, 0471405671, pp 63-77.
    /// </summary>
    internal interface IHilbertTransformerCycleEstimator
    {
        /// <summary>
        /// The WMA smoothing length.
        /// </summary>
        int SmoothingLength { get; }

        /// <summary>
        /// The current WMA-smoothed value used by underlying Hilbert transformer.
        /// <para/>
        /// The linear-Weighted Moving Average has a window size of <c>SmoothingLength</c>.
        /// </summary>
        double SmoothedValue { get; }

        /// <summary>
        /// The current detrended value.
        /// </summary>
        double DetrendedValue { get; }

        /// <summary>
        /// The current Quadrature component value.
        /// </summary>
        double Quadrature { get; }

        /// <summary>
        /// The current InPhase component value.
        /// </summary>
        double InPhase { get; }

        /// <summary>
        /// The current period value.
        /// </summary>
        double Period { get; }

        /// <summary>
        /// The current count value.
        /// </summary>
        int Count { get; }

        /// <summary>
        /// If the instance is primed.
        /// </summary>
        bool IsPrimed { get; }

        /// <summary>
        /// The minimal cycle period.
        /// </summary>
        int MinPeriod { get; }

        /// <summary>
        /// The maximual cycle period.
        /// </summary>
        int MaxPeriod { get; }

        /// <summary>
        /// The value of α (0 &lt; α ≤ 1) used in EMA to smooth the in-phase and quadrature components.
        /// </summary>
        double AlphaEmaQuadratureInPhase { get; }

        /// <summary>
        /// The value of α (0 &lt; α ≤ 1) used in EMA to smooth the instantaneous period.
        /// </summary>
        double AlphaEmaPeriod { get; }

        /// <summary>
        /// The value of the number of updates before the indicator is primed (MaxPeriod * 2 = 100).
        /// </summary>
        int WarmUpPeriod { get; }

        /// <summary>
        /// Resets the instance.
        /// </summary>
        void Reset();

        /// <summary>
        /// Updates the instance.
        /// </summary>
        /// <param name="value">A new value.</param>
        void Update(double value);
    }
}

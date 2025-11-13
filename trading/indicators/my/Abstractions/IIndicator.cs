namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// An indicator interface.
    /// </summary>
    public interface IIndicator
    {
        /// <summary>
        /// Identifies the indicator.
        /// </summary>
        string Name { get; }

        /// <summary>
        /// Identifies an instance of the indicator.
        /// </summary>
        string Moniker { get; }

        /// <summary>
        /// Describes the indicator.
        /// </summary>
        string Description { get; }

        /// <summary>
        /// Is the indicator primed.
        /// </summary>
        bool IsPrimed { get; }

        /// <summary>
        /// Resets the indicator.
        /// </summary>
        void Reset();
    }
}

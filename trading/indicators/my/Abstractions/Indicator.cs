using Mbs.Trading.Data;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// An abstract indicator.
    /// </summary>
    public abstract class Indicator : IIndicator
    {
        #region Members and accessors
        /// <inheritdoc />
        public string Name { get; protected set; }

        /// <inheritdoc />
        public string Moniker { get; protected set; }

        /// <inheritdoc />
        public string Description { get; protected set; }

        /// <summary>
        /// Is the indicator primed.
        /// </summary>
        protected bool Primed;

        /// <inheritdoc />
        public bool IsPrimed => Primed;

        /// <summary>
        /// The Ohlcv component to use.
        /// </summary>
        public OhlcvComponent OhlcvComponent { get; protected set; }

        /// <summary>
        /// The lock object.
        /// </summary>
        protected readonly object Lock = new object();
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new object.
        /// </summary>
        /// <param name="name">Identifies the indicator.</param>
        /// <param name="description">Describes the indicator.</param>
        /// <param name="ohlcvComponent">Ohlcv component.</param>
        protected Indicator(string name, string description, OhlcvComponent ohlcvComponent = OhlcvComponent.ClosingPrice)
        {
            Name = name;
            Description = description;
            OhlcvComponent = ohlcvComponent;
        }
        #endregion

        #region Reset
        /// <inheritdoc />
        public abstract void Reset();
        #endregion
    }
}

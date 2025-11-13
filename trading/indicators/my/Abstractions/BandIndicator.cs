using System;
using Mbs.Trading.Data;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// An abstract band indicator.
    /// </summary>
    public abstract class BandIndicator : Indicator, IBandIndicator
    {
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="name">Identifies the indicator.</param>
        /// <param name="description">Describes the indicator.</param>
        /// <param name="ohlcvComponent">Ohlcv component.</param>
        protected BandIndicator(string name, string description, OhlcvComponent ohlcvComponent = OhlcvComponent.ClosingPrice)
            : base(name, description, ohlcvComponent) {}

        /// <inheritdoc />
        public abstract Band Update(double sample, DateTime dateTime);

        /// <inheritdoc />
        public virtual Band Update(Scalar scalar) => Update(scalar.Value, scalar.Time);

        /// <inheritdoc />
        public virtual Band Update(Ohlcv ohlcv) => Update(ohlcv.Component(OhlcvComponent), ohlcv.Time);
    }
}

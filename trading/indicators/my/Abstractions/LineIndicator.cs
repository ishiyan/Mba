using System;
using Mbs.Trading.Data;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// An abstract line indicator.
    /// </summary>
    public abstract class LineIndicator : Indicator, ILineIndicator
    {
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="name">Identifies the indicator.</param>
        /// <param name="description">Describes the indicator.</param>
        /// <param name="ohlcvComponent">Ohlcv component.</param>
        protected LineIndicator(string name, string description, OhlcvComponent ohlcvComponent = OhlcvComponent.ClosingPrice)
            : base(name, description, ohlcvComponent) {}

        /// <inheritdoc />
        public abstract double Update(double sample);

        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <param name="dateTime">A date-time of the new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public virtual Scalar Update(double sample, DateTime dateTime) => new Scalar(dateTime, Update(sample));

        /// <inheritdoc />
        public virtual Scalar Update(Scalar scalar) => new Scalar(scalar.Time, Update(scalar.Value));

        /// <inheritdoc />
        public virtual Scalar Update(Ohlcv ohlcv) => new Scalar(ohlcv.Time, Update(ohlcv.Component(OhlcvComponent)));
    }
}

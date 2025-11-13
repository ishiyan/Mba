using Mbs.Trading.Data;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// A line indicator interface.
    /// </summary>
    public interface ILineIndicator : IIndicator
    {
        /// <summary>
        /// Updates the line indicator.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <returns>The updated value of the line indicator.</returns>
        double Update(double sample);

        /// <summary>
        /// Updates the indicator.
        /// </summary>
        /// <param name="scalar">A new <see cref="Scalar"/> sample.</param>
        /// <returns>The updated value of the line indicator.</returns>
        Scalar Update(Scalar scalar);

        /// <summary>
        /// Updates the indicator.
        /// </summary>
        /// <param name="ohlcv">A new <see cref="Ohlcv"/> sample.</param>
        /// <returns>The updated value of the line indicator.</returns>
        Scalar Update(Ohlcv ohlcv);
    }
}

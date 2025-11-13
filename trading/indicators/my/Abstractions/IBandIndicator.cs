using System;
using Mbs.Trading.Data;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// A band indicator interface.
    /// </summary>
    public interface IBandIndicator : IIndicator
    {
        /// <summary>
        /// Updates the band indicator.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <param name="dateTime">A date-time of the new sample.</param>
        /// <returns>The updated value of the band indicator.</returns>
        Band Update(double sample, DateTime dateTime);

        /// <summary>
        /// Updates the band indicator.
        /// </summary>
        /// <param name="scalar">A new <see cref="Scalar"/> sample.</param>
        /// <returns>The updated value of the band indicator.</returns>
        Band Update(Scalar scalar);

        /// <summary>
        /// Updates the band indicator.
        /// </summary>
        /// <param name="ohlcv">A new <see cref="Ohlcv"/> sample.</param>
        /// <returns>The updated value of the band indicator.</returns>
        Band Update(Ohlcv ohlcv);
    }
}

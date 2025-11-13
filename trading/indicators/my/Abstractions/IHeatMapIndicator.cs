using Mbs.Trading.Data;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// A heat map indicator interface.
    /// </summary>
    public interface IHeatMapIndicator : IIndicator
    {
        /// <summary>
        /// Updates the heat-map indicator.
        /// </summary>
        /// <param name="scalar">A new <see cref="Scalar"/> sample.</param>
        /// <returns>The updated value of the heat-map indicator.</returns>
        HeatMap Update(Scalar scalar);

        /// <summary>
        /// Updates the heat-map indicator.
        /// </summary>
        /// <param name="ohlcv">A new <see cref="Ohlcv"/> sample.</param>
        /// <returns>The updated value of the heat-map indicator.</returns>
        HeatMap Update(Ohlcv ohlcv);

        /// <summary>
        /// The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        double MinParameterValue { get; }

        /// <summary>
        /// The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        double MaxParameterValue { get; }
    }
}

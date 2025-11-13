using System.Collections.ObjectModel;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// A heat-map indicator with over-writable history interface.
    /// </summary>
    public interface IHeatMapIndicatorWithOverWritableHistory : IHeatMapIndicator
    {
        /// <summary>
        /// Historical values of the indicator.
        /// </summary>
        ReadOnlyCollection<HeatMap> HistoricalValues { set; }
    }
}

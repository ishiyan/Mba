using System.Collections.ObjectModel;
using Mbs.Trading.Data;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// A line indicator with over-writable history interface.
    /// </summary>
    public interface ILineIndicatorWithOverWritableHistory : ILineIndicator
    {
        /// <summary>
        /// Historical values of the indicator.
        /// </summary>
        ReadOnlyCollection<Scalar> HistoricalValues { set; }
    }
}

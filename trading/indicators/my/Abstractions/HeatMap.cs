using System;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// Holds a time stamp and a brush to paint a heat-map column.
    /// </summary>
    public sealed class HeatMap
    {
        #region Members and accessors
        /// <summary>
        /// An intensity of a heat-map column.
        /// </summary>
        public double[] Intensity { get; }

        /// <summary>
        /// A time stamp.
        /// </summary>
        public DateTime Time { get; }

        /// <summary>
        /// Indicates if this <c>heat-map</c> is not initialized.
        /// </summary>
        public bool IsEmpty => null == Intensity;
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new object.
        /// </summary>
        /// <param name="time">The time stamp of the <see cref="HeatMap"/>.</param>
        /// <param name="intensity">The intensities of a <see cref="HeatMap"/> column.</param>
        public HeatMap(DateTime time, double[] intensity = null)
        {
            Time = time;
            Intensity = intensity;
        }
        #endregion
    }
}

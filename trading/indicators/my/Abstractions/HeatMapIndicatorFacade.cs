using System;
using Mbs.Trading.Data;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// A façade class to expose two properties of a source indicator as a separate heat-map indicator with a fictitious update.
    /// <para />
    /// This may be used in a situation when a source indicator calculates several properties which we want to plot simultaneously on a chart.
    /// <para />
    /// The heat-map indicator façade does not perform an actual update. It assumes that the source indicator is already updated, and just fetches the values of required properties.
    /// <para />
    /// Resetting the heat-map indicator façade has no effect. The source indicator should be reset instead.
    /// </summary>
    public sealed class HeatMapIndicatorFacade : IHeatMapIndicator
    {
        #region Members and accessors
        /// <summary>
        /// Identifies the heat-map indicator façade.
        /// </summary>
        public string Name { get; }

        /// <summary>
        /// Identifies an instance of the heat-map indicator façade.
        /// </summary>
        public string Moniker { get; }

        /// <summary>
        /// Describes the heat-map indicator façade.
        /// </summary>
        public string Description { get; }

        private readonly Func<bool> isPrimed;
        /// <summary>
        /// Is the source indicator primed.
        /// </summary>
        public bool IsPrimed => isPrimed();

        /// <inheritdoc />
        public double MinParameterValue { get; }

        /// <inheritdoc />
        public double MaxParameterValue { get; }
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="HeatMapIndicatorFacade"/> class.
        /// </summary>
        /// <param name="name">Identifies the heat-map indicator façade.</param>
        /// <param name="moniker">Identifies an instance of the heat-map indicator façade.</param>
        /// <param name="description">Describes the heat-map indicator façade.</param>
        /// <param name="isPrimed">A function to check if the source indicator is primed.</param>
        /// <param name="minParameterValue">The minimum parameter value of the heat-map. This value is the same for all heat-map columns.</param>
        /// <param name="maxParameterValue">The maximum parameter value of the heat-map. This value is the same for all heat-map columns.</param>
        internal HeatMapIndicatorFacade(string name, string moniker, string description, Func<bool> isPrimed, double minParameterValue, double maxParameterValue)
        {
            Name = name;
            Moniker = moniker;
            Description = description;
            this.isPrimed = isPrimed;
            MinParameterValue = minParameterValue;
            MaxParameterValue = maxParameterValue;
        }
        #endregion

        #region Reset
        /// <summary>
        /// Resetting the heat-map indicator façade has no effect. The source indicator should be reset instead.
        /// </summary>
        public void Reset() {}
        #endregion

        #region Update
        /// <summary>
        /// Fetches both the first and the second <see cref="HeatMap"/> values from the source indicator, which is assumed to be already updated.
        /// </summary>
        /// <param name="scalar">A new <see cref="Scalar"/>. The time stamp is used as time stamp of the new <see cref="HeatMap"/> instance.</param>
        /// <returns>The new value of the heat-map indicator façade.</returns>
        public HeatMap Update(Scalar scalar) => new HeatMap(scalar.Time);

        /// <summary>
        /// Fetches both the first and the second <see cref="HeatMap"/> values from the source indicator, which is assumed to be already updated.
        /// </summary>
        /// <param name="ohlcv">A new <see cref="Ohlcv"/>. The time stamp is used as time stamp of the new <see cref="HeatMap"/> instance.</param>
        /// <returns>The new value of the heat-map indicator façade.</returns>
        public HeatMap Update(Ohlcv ohlcv) => new HeatMap(ohlcv.Time);
        #endregion
    }
}

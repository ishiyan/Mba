using System;
using Mbs.Trading.Data;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// A façade class to expose a property of a source indicator as a separate line indicator with a fictitious update.
    /// <para />
    /// This may be used in a situation when a source indicator calculates several properties which we want to plot simultaneously on a chart.
    /// <para />
    /// The line indicator façade does not perform an actual update. It assumes that the source indicator is already updated, and just gets a value of the required property.
    /// <para />
    /// Resetting the line indicator façade has no effect. The source indicator should be reset instead.
    /// </summary>
    public sealed class LineIndicatorFacade : ILineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// Identifies the line indicator façade.
        /// </summary>
        public string Name { get; }

        /// <summary>
        /// Identifies an instance of the line indicator façade.
        /// </summary>
        public string Moniker { get; }

        /// <summary>
        /// Describes the line indicator façade.
        /// </summary>
        public string Description { get; }

        private readonly Func<bool> isPrimed;
        /// <summary>
        /// Is the source indicator primed.
        /// </summary>
        public bool IsPrimed => isPrimed();

        private readonly Func<double> getValue;
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="LineIndicatorFacade"/> class.
        /// </summary>
        /// <param name="name">Identifies the line indicator façade.</param>
        /// <param name="moniker">Identifies an instance of the line indicator façade.</param>
        /// <param name="description">Describes the line indicator façade.</param>
        /// <param name="isPrimed">A function to check if the source indicator is primed.</param>
        /// <param name="getValue">A function to to fetch the current value from the source indicator.</param>
        internal LineIndicatorFacade(string name, string moniker, string description, Func<bool> isPrimed, Func<double> getValue)
        {
            Name = name;
            Moniker = moniker;
            Description = description;
            this.isPrimed = isPrimed;
            this.getValue = getValue;
        }
        #endregion

        #region Reset
        /// <summary>
        /// Resetting the line indicator façade has no effect. The source indicator should be reset instead.
        /// </summary>
        public void Reset() {}
        #endregion

        #region Update
        /// <summary>
        /// Fetches the current value from the source indicator, which is assumed to be already updated.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <returns>The new value of the line indicator façade.</returns>
        public double Update(double sample) => getValue();

        /// <summary>
        /// Fetches the current <see cref="Scalar"/> value from the source indicator, which is assumed to be already updated.
        /// </summary>
        /// <param name="scalar">A new <see cref="Scalar"/>. The time stamp is used as time stamp of the new <see cref="Scalar"/> instance.</param>
        /// <returns>The new value of the line indicator façade.</returns>
        public Scalar Update(Scalar scalar) => new Scalar(scalar.Time, getValue());

        /// <summary>
        /// Fetches the current <see cref="Scalar"/> value from the source indicator, which is assumed to be already updated.
        /// </summary>
        /// <param name="ohlcv">A new <see cref="Ohlcv"/>. The time stamp is used as time stamp of the new <see cref="Scalar"/> instance.</param>
        /// <returns>The new value of the line indicator façade.</returns>
        public Scalar Update(Ohlcv ohlcv) => new Scalar(ohlcv.Time, getValue());
        #endregion
    }
}

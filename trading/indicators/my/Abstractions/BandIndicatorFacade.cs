using System;
using Mbs.Trading.Data;

namespace Mbs.Trading.Indicators.Abstractions
{
    /// <summary>
    /// A façade class to expose two properties of a source indicator as a separate band indicator with a fictitious update.
    /// <para />
    /// This may be used in a situation when a source indicator calculates several properties which we want to plot simultaneously on a chart.
    /// <para />
    /// The band indicator façade does not perform an actual update. It assumes that the source indicator is already updated, and just fetches values of two required properties.
    /// <para />
    /// Resetting the band indicator façade has no effect. The source indicator should be reset instead.
    /// </summary>
    public sealed class BandIndicatorFacade : IBandIndicator
    {
        #region Members and accessors
        /// <summary>
        /// Identifies the band indicator façade.
        /// </summary>
        public string Name { get; }

        /// <summary>
        /// Identifies an instance of the band indicator façade.
        /// </summary>
        public string Moniker { get; }

        /// <summary>
        /// Describes the band indicator façade.
        /// </summary>
        public string Description { get; }

        private readonly Func<bool> isPrimed;
        /// <summary>
        /// Is the source indicator primed.
        /// </summary>
        public bool IsPrimed => isPrimed();

        private readonly Func<double> getFirstValue; 
        private readonly Func<double> getSecondValue; 
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="BandIndicatorFacade"/> class.
        /// </summary>
        /// <param name="name">Identifies the band indicator façade.</param>
        /// <param name="moniker">Identifies an instance of the band indicator façade.</param>
        /// <param name="description">Describes the band indicator façade.</param>
        /// <param name="isPrimed">An function to check if the source indicator is primed.</param>
        /// <param name="getFirstValue">An function to fetch the first value of the band from the source indicator.</param>
        /// <param name="getSecondValue">An function to fetch the second value of the band from the source indicator.</param>
        internal BandIndicatorFacade(string name, string moniker, string description, Func<bool> isPrimed, Func<double> getFirstValue, Func<double> getSecondValue)
        {
            Name = name;
            Moniker = moniker;
            Description = description;
            this.isPrimed = isPrimed;
            this.getFirstValue = getFirstValue;
            this.getSecondValue = getSecondValue;
        }
        #endregion

        #region Reset
        /// <summary>
        /// Resetting the band indicator façade has no effect. The source indicator should be reset instead.
        /// </summary>
        public void Reset() {}
        #endregion

        #region Update
        /// <summary>
        /// Fetches both the first and the second <see cref="Band"/> values from the source indicator, which is assumed to be already updated.
        /// </summary>
        /// <param name="sample">A new sample. Not used.</param>
        /// <param name="dateTime">The date and time which is used as time stamp of the new <see cref="Band"/> instance.</param>
        /// <returns>The new value of the band indicator façade.</returns>
        public Band Update(double sample, DateTime dateTime) => new Band(dateTime, getFirstValue(), getSecondValue());

        /// <summary>
        /// Fetches both the first and the second <see cref="Band"/> values from the source indicator, which is assumed to be already updated.
        /// </summary>
        /// <param name="scalar">A new <see cref="Scalar"/>. The time stamp is used as time stamp of the new <see cref="Band"/> instance.</param>
        /// <returns>The new value of the band indicator façade.</returns>
        public Band Update(Scalar scalar) => new Band(scalar.Time, getFirstValue(), getSecondValue());

        /// <summary>
        /// Fetches both the first and the second <see cref="Band"/> values from the source indicator, which is assumed to be already updated.
        /// </summary>
        /// <param name="ohlcv">A new <see cref="Ohlcv"/>. The time stamp is used as time stamp of the new <see cref="Band"/> instance.</param>
        /// <returns>The new value of the band indicator façade.</returns>
        public Band Update(Ohlcv ohlcv) => new Band(ohlcv.Time, getFirstValue(), getSecondValue());
        #endregion
    }
}

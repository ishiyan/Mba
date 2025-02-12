using System;
using System.Globalization;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// Plots a heat-map of estimated sample Pearson auto-correlation coefficients.
    /// </summary>
    public sealed class AutoCorrelationCoefficients : Indicator, IHeatMapIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        public double MinParameterValue => estimator.MinLag;

        /// <summary>
        /// The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        public double MaxParameterValue => estimator.MaxLag;

        /// <summary>
        /// The length (the number of time periods) of the sample window.
        /// This determines also the maximum correlation lag to calculate. The minimal value is 2
        /// </summary>
        public int Length => estimator.Length;

        private int windowCount;
        private readonly AutoCorrelationEstimator estimator;
        private readonly int lastIndex;
        private readonly double parameterRange;

        private const string Acc = "acc";
        private const string AccFull = "Autocorrelation Coefficients";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="length">The length of the input series window. This determines also the maximum lag to calculate. The minimal value is 2.</param>
        /// <param name="minLag">The minimum lag to compute correlation coefficients, must be less than <c>length</c>.</param>
        /// <param name="maxLag">The maximum lag to compute correlation coefficients, must be less or equal to <c>length</c>.</param>
        /// <param name="averagingLength">The number of last samples of the input series window which are used for averaging. The default value of 0 means the averaging length is equal to each lag. That way, the averaging contains the maximum number of data samples per lag.</param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public AutoCorrelationCoefficients(int length = 48, int minLag = 10, int maxLag = 47, int averagingLength = 0, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : base(Acc, AccFull, ohlcvComponent)
        {
            if (2 > length)
                throw new ArgumentOutOfRangeException(nameof(length));
            estimator = new AutoCorrelationEstimator(length, minLag, maxLag, averagingLength);
            lastIndex = estimator.Length - 1;
            Moniker = string.Concat(Acc, length.ToString(CultureInfo.InvariantCulture));
            parameterRange = estimator.MaxLag - estimator.MinLag;
        }
        #endregion

        #region Reset
        /// <inheritdoc />
        public override void Reset()
        {
            lock (updateLock)
            {
                primed = false;
                windowCount = 0;
            }
        }
        #endregion

        #region Update
        private HeatMap Update(double sample, DateTime dateTime)
        {
            if (double.IsNaN(sample))
                return null;
            double[] window = estimator.InputSeries;
            if (primed)
            {
                Array.Copy(window, 1, window, 0, lastIndex);
                //for (int i = 0; i < lastIndex; )
                //    window[i] = window[++i];
                window[lastIndex] = sample;
            }
            else // Not primed.
            {
                window[windowCount] = sample;
                if (estimator.Length == ++windowCount)
                    primed = true;
            }
            double[] intensity;
            if (primed)
            {
                estimator.Calculate();
                int correlationCoefficientsLength = estimator.CorrelationCoefficientsLength;
                intensity = new double[correlationCoefficientsLength];
                window = estimator.CorrelationCoefficients;
                for (int i = 0; i < correlationCoefficientsLength; ++i)
                {
                    double value = window[i];
                    // Re-range from [-1, 1] to [0, 1].
                    value = (value + 1) / 2;
                    intensity[i] = value;
                }
            }
            else
            {
                intensity = null;
            }
            return new HeatMap(dateTime, intensity);
        }

        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="ohlcv">A new ohlcv.</param>
        /// <returns>The new heat-map column of the indicator or <c>null</c>.</returns>
        public HeatMap Update(Ohlcv ohlcv)
        {
            lock (updateLock)
            {
                return Update(ohlcv.Component(OhlcvComponent), ohlcv.Time);
            }
        }

        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new heat-map column of the indicator or <c>null</c>.</returns>
        public HeatMap Update(Scalar scalar)
        {
            lock (updateLock)
            {
                return Update(scalar.Value, scalar.Time);
            }
        }
        #endregion
    }
}

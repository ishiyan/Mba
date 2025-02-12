using System;
using System.Globalization;
using Mbs.Trading.Data;
using Mbs.Trading.Indicators.Abstractions;

// ReSharper disable once CheckNamespace
namespace Mbs.Trading.Indicators.JohnEhlers
{
    // ReSharper disable once CommentTypo
    /// <summary>
    /// A generic "swami-fication" indicator.
    /// </summary>
    public sealed class SwamiIndicator<T> : Indicator, IHeatMapIndicator where T : Indicator, ILineIndicator
    {
        #region Members and accessors
        /// <summary>
        /// The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        public double MinParameterValue { get; }

        /// <summary>
        /// The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.
        /// </summary>
        public double MaxParameterValue { get; }

        private readonly double minIntensityValue;
        private readonly double maxIntensityValue;
        private readonly double intensityDelta;
        private readonly int indicatorCount;
        private readonly T[] indicatorArray;
        private readonly double[] valueArray;
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="minParameterValue">The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.</param>
        /// <param name="maxParameterValue">The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.</param>
        /// <param name="stepParameterValue">The step of the ordinate (parameter) value.</param>
        /// <param name="minIntensityValue">The minimum intensity value of the heat-map. Used to normalize intensity values.</param>
        /// <param name="maxIntensityValue">The maximum intensity value of the heat-map. Used to normalize intensity values.</param>
        /// <param name="instanceFactory">A factory to create instances of the underlying indicator.</param>
        public SwamiIndicator(double minParameterValue, double maxParameterValue, double stepParameterValue,
            double minIntensityValue, double maxIntensityValue, Func<double, T> instanceFactory)
            : base(null, null)
        {
            this.MinParameterValue = minParameterValue;
            this.MaxParameterValue = maxParameterValue;
            this.minIntensityValue = minIntensityValue;
            this.maxIntensityValue = maxIntensityValue;
            intensityDelta = maxIntensityValue - minIntensityValue;
            indicatorCount = (int)Math.Ceiling((maxParameterValue - minParameterValue + stepParameterValue) / stepParameterValue);
            indicatorArray = new T[indicatorCount];
            double parameter = minParameterValue;
            for (int i = 0; i < indicatorCount; ++i, parameter += stepParameterValue)
                indicatorArray[i] = instanceFactory(parameter);
            valueArray = new double[indicatorCount];
            Initialize(indicatorArray[0], minParameterValue.ToString(CultureInfo.InvariantCulture), maxParameterValue.ToString(CultureInfo.InvariantCulture));
        }

        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="minParameterValue">The minimum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.</param>
        /// <param name="maxParameterValue">The maximum ordinate (parameter) value of the heat-map. This value is the same for all heat-map columns.</param>
        /// <param name="minIntensityValue">The minimum intensity value of the heat-map. Used to normalize intensity values.</param>
        /// <param name="maxIntensityValue">The maximum intensity value of the heat-map. Used to normalize intensity values.</param>
        /// <param name="instanceFactory">A factory to create instances of the underlying indicator.</param>
        public SwamiIndicator(int minParameterValue, int maxParameterValue,
            double minIntensityValue, double maxIntensityValue, Func<int, T> instanceFactory)
            : base(null, null)
        {
            this.MinParameterValue = minParameterValue;
            this.MaxParameterValue = maxParameterValue;
            this.minIntensityValue = minIntensityValue;
            this.maxIntensityValue = maxIntensityValue;
            intensityDelta = maxIntensityValue - minIntensityValue;
            indicatorCount = ++maxParameterValue - minParameterValue;
            indicatorArray = new T[indicatorCount];
            for (int i = 0, parameter = minParameterValue; i < indicatorCount; ++i, ++parameter)
                indicatorArray[i] = instanceFactory(parameter);
            valueArray = new double[indicatorCount];
            Initialize(indicatorArray[0], minParameterValue.ToString(CultureInfo.InvariantCulture), maxParameterValue.ToString(CultureInfo.InvariantCulture));
        }

        private void Initialize(T t, string minParameter, string maxParameter)
        {
            Name = string.Concat("swami(", t.Name, ")"); 
            // ReSharper disable once StringLiteralTypo
            Description = string.Concat("Swamified ", t.Description); 
            Moniker = string.Concat(Name, "[", minParameter, "; ", maxParameter, "]"); 
        } 
        #endregion

        #region Reset
        /// <inheritdoc />
        public override void Reset()
        {
            lock (updateLock)
            {
                primed = false;
                foreach (var indicator in indicatorArray)
                    indicator.Reset();
            }
        }
        #endregion

        #region Update
        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="ohlcv">A new ohlcv.</param>
        /// <returns>The new heat-map column of the indicator or <c>null</c>.</returns>
        public HeatMap Update(Ohlcv ohlcv)
        {
            lock (updateLock)
            {
                var values = new double[indicatorCount];
                for (int i = 0; i < indicatorCount; ++i)
                {
                    double value = indicatorArray[i].Update(ohlcv).Value;
                    values[i] = value;
                    if (value <= minIntensityValue)
                        valueArray[i] = 0;
                    else if (value >= maxIntensityValue)
                        valueArray[i] = 1;
                    else
                        valueArray[i] = (value - minIntensityValue) / intensityDelta;
                }
                return new HeatMap(ohlcv.Time, values);
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
                var values = new double[indicatorCount];
                for (int i = 0; i < indicatorCount; ++i)
                {
                    double value = indicatorArray[i].Update(scalar).Value;
                    values[i] = value;
                    valueArray[i] = (value - minIntensityValue) / intensityDelta;
                }
                return new HeatMap(scalar.Time, values);
            }
        }
        #endregion
    }
}

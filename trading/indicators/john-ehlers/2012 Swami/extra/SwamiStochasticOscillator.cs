using System;
using System.Collections.Generic;
using System.Globalization;
using System.Runtime.Serialization;
using System.Text;
using System.Windows;
using System.Windows.Media;
using Mbst.Core;

namespace Mbst.Indicators
{
    /// <summary>
    /// A "swamified" Swami stochastic oscillator heatmap.SwamiStochasticOscillator
    /// </summary>
    [DataContract]
    public sealed class SwamiStochasticOscillator : SwamiIndicator<StochasticOscillator>
    {
        #region Construction
        /// <summary>
        /// Constructs a new instance of the class.
        /// </summary>
        /// <param name="minParameterValue">The minimum ordinate (parameter) value of the heatmap. This value is the same for all heatmap columns.</param>
        /// <param name="maxParameterValue">The maximum ordinate (parameter) value of the heatmap. This value is the same for all heatmap columns.</param>
        /// <param name="stepParameterValue">The step of the ordinate (parameter) value.</param>
        /// <param name="minIntensityValue">The minimum intensity value of the heatmap. Used to normalize intensity values.</param>
        /// <param name="maxIntensityValue">The maximum intensity value of the heatmap. Used to normalize intensity values.</param>
        /// <param name="instanceFactory">A factory to create instances of the underlying indicator.</param>
        public SwamiStochasticOscillator(double minParameterValue, double maxParameterValue, double stepParameterValue,
            double minIntensityValue, double maxIntensityValue, Func<double, T> instanceFactory)
            : base(minParameterValue, maxParameterValue, stepParameterValue, minIntensityValue, maxIntensityValue,
            parameter => )
        {
            this.minParameterValue = minParameterValue;
            this.maxParameterValue = maxParameterValue;
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
        /// <param name="minParameterValue">The minimum ordinate (parameter) value of the heatmap. This value is the same for all heatmap columns.</param>
        /// <param name="maxParameterValue">The maximum ordinate (parameter) value of the heatmap. This value is the same for all heatmap columns.</param>
        /// <param name="minIntensityValue">The minimum intensity value of the heatmap. Used to normalize intensity values.</param>
        /// <param name="maxIntensityValue">The maximum intensity value of the heatmap. Used to normalize intensity values.</param>
        /// <param name="instanceFactory">A factory to create instances of the underlying indicator.</param>
        public SwamiIndicator(int minParameterValue, int maxParameterValue,
            double minIntensityValue, double maxIntensityValue, Func<int, T> instanceFactory)
            : base(null, null)
        {
            this.minParameterValue = minParameterValue;
            this.maxParameterValue = maxParameterValue;
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

        private void Initialize(T t, string minParemeter, string maxParameter)
        {
            name = string.Concat("swami(", t.Name, ")"); 
            description = string.Concat("Swamified ", t.Description); 
            moniker = string.Concat(Name, "[", minParemeter, "; ", maxParameter, "]"); 
        } 
        #endregion

        #region Reset
        /// <summary>
        /// Resets the indicator.
        /// </summary>
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
        private static readonly Func<Color,byte> redSelector = color => color.R;
        private static readonly Func<Color, byte> greenSelector = color => color.G;
        private static readonly Func<Color, byte> blueSelector = color => color.B;
        private static readonly Func<Color, byte> alphaSelector = color => color.A;

        private static Color InterpolateBetween(Color downPoint, Color upPoint, Color midPoint, double lambda)
        {
            if (lambda < 0 || lambda > 1)
                throw new ArgumentOutOfRangeException("lambda");
            if (midPoint == Colors.Transparent)
                return Color.FromArgb(
                    InterpolateComponent(downPoint, upPoint, lambda, alphaSelector),
                    InterpolateComponent(downPoint, upPoint, lambda, redSelector),
                    InterpolateComponent(downPoint, upPoint, lambda, greenSelector),
                    InterpolateComponent(downPoint, upPoint, lambda, blueSelector));
            if (lambda < 0.5)
                return Color.FromArgb(
                    InterpolateComponent(downPoint, midPoint, lambda * 2, alphaSelector),
                    InterpolateComponent(downPoint, midPoint, lambda * 2, redSelector),
                    InterpolateComponent(downPoint, midPoint, lambda * 2, greenSelector),
                    InterpolateComponent(downPoint, midPoint, lambda * 2, blueSelector));
            return Color.FromArgb(
                InterpolateComponent(midPoint, upPoint, lambda * 2 - 1, alphaSelector),
                InterpolateComponent(midPoint, upPoint, lambda * 2 - 1, redSelector),
                InterpolateComponent(midPoint, upPoint, lambda * 2 - 1, greenSelector),
                InterpolateComponent(midPoint, upPoint, lambda * 2 - 1, blueSelector));
        }

        private static byte InterpolateComponent(Color endPoint1, Color endPoint2, double lambda, Func<Color, byte> selector)
        {
            return (byte)(selector(endPoint1) + (selector(endPoint2) - selector(endPoint1)) * lambda);
        }

        private static readonly Color bulishColor = Colors.Green;
        private static readonly Color bearishColor = Colors.Red;
        private static Color neutralColor = Colors.Yellow;

        private Brush Update()
        {
            neutralColor.A = 0x00;
            var gradientStopCollection = new GradientStopCollection(indicatorCount);
            foreach (var d in valueArray)
                gradientStopCollection.Add(new GradientStop(InterpolateBetween(bearishColor, bulishColor, neutralColor, d), d));
            //var gradientStopCollection = new GradientStopCollection(4) { new GradientStop(Color.FromArgb(0xff, 0xff, 0x00, 0x00), 0.0), new GradientStop(Color.FromArgb(0xff, 0x00, 0xff, 0x00), 0.49), new GradientStop(Color.FromArgb(0xff, 0x00, 0xff, 0x00), 0.50), new GradientStop(Color.FromArgb(0xff, 0x00, 0x00, 0xff), 1.0) };
            return new LinearGradientBrush(gradientStopCollection, new Point(0, 0), new Point(0, 1));
        }

        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="ohlcv">A new ohlcv.</param>
        /// <returns>The new heatmap column of the indicator or <c>null</c>.</returns>
        public Heatmap Update(Ohlcv ohlcv)
        {
            bool isEmpty = false;
            lock (updateLock)
            {
                var values = new double[indicatorCount];
                for (int i = 0; i < indicatorCount; ++i)
                {
                    double value = indicatorArray[i].Update(ohlcv).Value;
                    if (double.IsNaN(value))
                        isEmpty = true;
                    values[i] = value;
                    if (value <= minIntensityValue)
                        valueArray[i] = 0;
                    else if (value >= maxIntensityValue)
                        valueArray[i] = 1;
                    else
                        valueArray[i] = (value - minIntensityValue) / intensityDelta;
                }
                return new Heatmap(ohlcv.Time, isEmpty ? null : Update(), values);
            }
        }

        /// <summary>
        /// Updates the value of the indicator.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new heatmap column of the indicator or <c>null</c>.</returns>
        public Heatmap Update(Scalar scalar)
        {
            bool isEmpty = false;
            lock (updateLock)
            {
                var values = new double[indicatorCount];
                for (int i = 0; i < indicatorCount; ++i)
                {
                    double value = indicatorArray[i].Update(scalar).Value;
                    if (double.IsNaN(value))
                        isEmpty = true;
                    values[i] = value;
                    valueArray[i] = (value - minIntensityValue) / intensityDelta;
                }
                return new Heatmap(scalar.Time, isEmpty ? null : Update(), values);
            }
        }
        #endregion

        #region Overrides
        /// <summary>
        /// Returns the string that represents this object.
        /// </summary>
        /// <returns>Returns the string that represents this object.</returns>
        public override string ToString()
        {
            bool p;
            lock (updateLock)
            {
                p = primed;
            }
            var sb = new StringBuilder();
            sb.Append("[M:");
            sb.Append(moniker);
            sb.Append(" P:");
            sb.Append(p);
            sb.Append("]");
            return sb.ToString();
        }
        #endregion
    }
}

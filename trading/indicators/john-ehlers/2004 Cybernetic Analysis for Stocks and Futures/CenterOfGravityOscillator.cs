using System;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;

namespace Mbst.Trading.Indicators
{
    /// <summary>
    /// The Center of Gravity oscillator as described in Ehler's book "Cybernetic Analysis for Stocks and Futures" (2004).
    /// <para />
    /// The center of gravity in a FIR filter is the position of the average price within the filter window lwngth:
    /// <para />
    /// CGᵢ = ∑(i+1)Priceᵢ / ∑Priceᵢ, where i = 0…ℓ-1, ℓ being a window size.
    /// <para />
    /// <para />
    /// The Center of Gravity oscillator has essentially zero lag and retains the relative cycle amplitude.
    /// <para />
    /// It moves toward the most recent bar (decreases) when prices rise and moves away from the
    /// most recent bar (increases) when prices fall; thus moving exactly opposite to the price direction.
    /// </summary>
    [DataContract]
    public sealed class CenterOfGravityOscillator : Indicator, ILineIndicator
    {
        #region Members and accessors
        #region Length
        [DataMember]
        private readonly int length;
        /// <summary>
        /// The length (<c>ℓ</c>) of the center of gravity oscillator.
        /// </summary>
        public int Length { get { return length; } }
        #endregion

        #region Value
        [DataMember]
        private double value = double.NaN;
        /// <summary>
        /// The current value of the center of gravity oscillator, or <c>NaN</c> if not primed.
        /// </summary>
        public double Value { get { lock (updateLock) { return primed ? value : double.NaN; } } }
        #endregion

        #region Trigger
        [DataMember]
        private double valuePrevious = double.NaN;
        /// <summary>
        /// The current value of the trigger line, which is the previous value of the center of gravity oscillator, or <c>NaN</c> if not primed.
        /// </summary>
        public double Trigger { get { lock (updateLock) { return primed ? valuePrevious : double.NaN; } } }
        #endregion

        #region ValueFacade
        /// <summary>
        /// A line indicator façade to expose a value of the center of gravity oscillator as a separate line indicator with a fictious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the center of gravity oscillator from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade ValueFacade
        {
            get
            {
                return new LineIndicatorFacade(cog, moniker, cogFull, () => IsPrimed, () => Value);
            }
        }
        #endregion

        #region TriggerFacade
        /// <summary>
        /// A line indicator façade to expose a value of the trigger line as a separate line indicator with a fictious update.
        /// <para />
        /// The line indicator façade do not perform actual updates. It just gets a current value of the trigger line from this instance, assuming it is already updated.
        /// <para />
        /// Resetting the line indicator façade has no effect. This instance should be reset instead.
        /// </summary>
        public LineIndicatorFacade TriggerFacade
        {
            get
            {
                return new LineIndicatorFacade(cogTrig, string.Concat(cogTrig, "(", length.ToString(CultureInfo.InvariantCulture), ")"),
                    cogTrigFull, () => IsPrimed, () => Trigger);
            }
        }
        #endregion

        [DataMember]
        private readonly int lengthMinusOne;
        [DataMember]
        private int windowCount;
        [DataMember]
        private readonly double[] window;
        [DataMember]
        private double denominatorSum;

        private const string cog = "cog";
        private const string cogFull = "Center of Gravity oscillator";
        private const string cogTrig = "cogTrig";
        private const string cogTrigFull = "Center of Gravity trigger";
        private const string argumentLength = "length";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the Center of Gravity oscillator.
        /// </summary>
        /// <param name="length">The length, <c>ℓ</c>, of the center of gravity oscillator. The default value used by Ehlers  is 10.</param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public CenterOfGravityOscillator(int length = 10, OhlcvComponent ohlcvComponent = OhlcvComponent.MedianPrice)
            : base(cog, cogFull, ohlcvComponent)
        {
            if (1 > length)
                throw new ArgumentOutOfRangeException(argumentLength);
            this.length = length;
            lengthMinusOne = length - 1;
            window = new double[length];
            moniker = string.Concat(cog, "(", length.ToString(CultureInfo.InvariantCulture), ")");
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
                windowCount = 0;
                value = double.NaN;
                valuePrevious = double.NaN;
                denominatorSum = 0d;
            }
        }
        #endregion

        #region Update
        private double Calculate(double sample)
        {
            denominatorSum += sample - window[0];
            Array.Copy(window, 1, window, 0, lengthMinusOne);
            //for (int i = 0; i < lengthMinusOne;)
            //    window[i] = window[++i];
            window[lengthMinusOne] = sample;
            double sum = 0d;
            if (Math.Abs(denominatorSum) > double.Epsilon)
            {
                for (int i = 0, j = 1; i < length; ++i, ++j)
                    sum += j * window[i];
                sum /= denominatorSum;
            }
            return sum;
        }

        /// <summary>
        /// Updates the value of the center of gravity oscillator.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public double Update(double sample)
        {
            if (double.IsNaN(sample))
                return sample;
            lock (updateLock)
            {
                if (primed)
                {
                    valuePrevious = value;
                    value = Calculate(sample);
                }
                else // Not primed.
                {
                    if (length > windowCount)
                    {
                        denominatorSum += sample;
                        window[windowCount] = sample;
                        if (lengthMinusOne == windowCount)
                        {
                            double sum = 0d;
                            if (Math.Abs(denominatorSum) > double.Epsilon)
                            {
                                for (int i = 0; i < length; ++i)
                                    sum += (1d + i) * window[i];
                                sum /= denominatorSum;
                            }
                            valuePrevious = sum;
                        }
                    }
                    else
                    {
                        value = Calculate(sample);
                        primed = true;
                    }
                    ++windowCount;
                }
                return value;
            }
        }

        /// <summary>
        /// Updates the value of the center of gravity oscillator.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <param name="dateTime">A date-time of the new price.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(double sample, DateTime dateTime)
        {
            return new Scalar(dateTime, Update(sample));
        }

        /// <summary>
        /// Updates the value of the center of gravity oscillator.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Scalar scalar)
        {
            return new Scalar(scalar.Time, Update(scalar.Value));
        }

        /// <summary>
        /// Updates the value of the center of gravity oscillator.
        /// </summary>
        /// <param name="ohlcv">A new ohlcv.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Ohlcv ohlcv)
        {
            return new Scalar(ohlcv.Time, Update(ohlcv.Component(ohlcvComponent)));
        }
        #endregion

        #region Overrides
        /// <summary>
        /// Returns the string that represents this object.
        /// </summary>
        /// <returns>Returns the string that represents this object.</returns>
        public override string ToString()
        {
            double v; bool p;
            lock (updateLock)
            {
                p = primed;
                v = value;
            }
            var sb = new StringBuilder();
            sb.Append("[M:");
            sb.Append(moniker);
            sb.Append(" P:");
            sb.Append(p);
            sb.Append(" V:");
            sb.Append(v);
            sb.Append("]");
            return sb.ToString();
        }
        #endregion
    }
}

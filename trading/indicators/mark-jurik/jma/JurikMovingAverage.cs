using System;
using System.Collections.Generic;
using System.Globalization;
using System.Runtime.Serialization;
using System.Text;

using Mbst.Core;

namespace Mbst.Indicators
{
    /// <summary>
    /// JurikMovingAverage is the absolute (not normalized) difference between today's sample and the sample <c>ℓ</c> periods ago.
    /// <para>The indicator is not primed during the first <c>ℓ</c> updates.</para>
    /// </summary>
    [DataContract]
    public sealed class JurikMovingAverage : Indicator, ILineIndicator
    {
        #region Members and accessors
        #region Length
        [DataMember]
        private readonly int length;
        /// <summary>
        /// The length <c>ℓ</c> (the number of time periods).
        /// </summary>
        public int Length { get { return length; } }
        #endregion

        #region Phase
        [DataMember]
        private readonly int phase;
        /// <summary>
        /// The phase.
        /// </summary>
        public int Phase { get { return phase; } }
        #endregion

        #region Value
        [DataMember]
        private double value = double.NaN;
        /// <summary>
        /// The current value of the momentum, or <c>NaN</c> if not primed.
        /// The indicator is not primed during the first <c>ℓ</c> updates, where e <c>ℓ</c> is the length.
        /// </summary>
        public double Value { get { lock (updateLock) { return value; } } }
        #endregion

      double PrevJMAValueBuffer;
      double Cur_fC0Buffer;        double Prev_fC0Buffer;
      double Cur_fA8Buffer;        double Prev_fA8Buffer;
      double Cur_fC8Buffer;        double Prev_fC8Buffer;
      double[] list = new double[128];
      double[] ring1 = new double[128];
      double[] ring2 = new double[11];
      double[] buffer = new double[62];
      int limitValue = 63;         int startValue = 64;
      int loopParam;               int loopCriteria;
      int cycleLimit;              int highLimit;
      int counterA;                int counterB;
      int s58;                     int s60;
      int s40;                     int s38;
      int s68;
      double cycleDelta;           double lowDValue;
      double highDValue;           double absValue;
      double paramA;               double paramB;
      double phaseParam;           double logParam;
      double JMAValue;             double series;
      double sValue;               double sqrtParam;
      double lengthDivider;        double NoEvalValue;
      double lengthParam;
      bool MoreThanThirtyFlag = true;
      int Counter;

        private const string jma = "JMA";
        private const string argumentLength = "length";
        #endregion

        #region Construction
        /// <summary>
        /// Constructs a new instance of the <see cref="JurikMovingAverage"/> class.
        /// </summary>
        /// <param name="length">The number of time periods, <c>ℓ</c>.</param>
        public JurikMovingAverage(int length)
            : this(length, 0, OhlcvComponent.ClosingPrice)
        {
        }

        /// <summary>
        /// Constructs a new instance of the <see cref="JurikMovingAverage"/> class.
        /// </summary>
        /// <param name="length">The number of time periods, <c>ℓ</c>.</param>
        /// <param name="phase">The phase.</param>
        public JurikMovingAverage(int length, int phase)
            : this(length, phase, OhlcvComponent.ClosingPrice)
        {
        }

        /// <summary>
        /// Constructs a new instance of the <see cref="JurikMovingAverage"/> class.
        /// </summary>
        /// <param name="length">The number of time periods, <c>ℓ</c>.</param>
        /// <param name="phase">The phase.</param>
        /// <param name="ohlcvComponent">The Ohlcv component.</param>
        public JurikMovingAverage(int length, int phase, OhlcvComponent ohlcvComponent)
            : base(jma, "JurikMovingAverage", ohlcvComponent)
        {
            if (1 > length)
                throw new ArgumentOutOfRangeException(argumentLength);
            this.length = length;
            base.moniker = string.Concat(jma, length.ToString(CultureInfo.InvariantCulture));
            phaseParam = phase / 100.0 + 1.5;
            if (phase < -100) phaseParam = 0.5;
            if (phase > 100) phaseParam = 2.5;
            /////
            for (int i = 0; i < 62; i++) buffer[i] = 0.0;
            for (int i = 0; i < 11; i++) ring2[i] = 0.0;
            for (int i = 0; i < 128; i++) ring1[i] = 0.0;
            for (int i = 0; i < 128; i++) list[i] = 0.0;
            for (int i = 0; i <= limitValue; i++) list[i] = -1000000.0;
            for (int i = startValue; i < 128; i++) list[i] = 1000000.0;
            lengthParam = (length - 1.0) / 2.0;
            logParam = Math.Log10(Math.Sqrt(lengthParam) / Math.Log10(2.0));
            if ((logParam + 2.0) < 0.0) logParam = 0.0;
            else logParam = logParam + 2.0;
            sqrtParam = logParam * Math.Sqrt(lengthParam);
            lengthParam = lengthParam * 0.9;
            lengthDivider = lengthParam / (lengthParam + 2.0);
            Counter = 0;


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
                value = double.NaN;
                PrevJMAValueBuffer = 0;
                Cur_fC0Buffer = 0; Prev_fC0Buffer = 0;
                Cur_fA8Buffer = 0; Prev_fA8Buffer = 0;
                Cur_fC8Buffer = 0; Prev_fC8Buffer = 0;
                limitValue = 0; startValue = 0;
                loopParam = 0; loopCriteria = 0;
                cycleLimit = 0; highLimit = 0;
                counterA = 0; counterB = 0;
                s58 = 0; s60 = 0; s40 = 0; s38 = 0; s68 = 0;
                cycleDelta = 0; lowDValue = 0;
                highDValue = 0; absValue = 0;
                paramA = 0; paramB = 0;
                phaseParam = 0; logParam = 0;
                JMAValue = 0; series = 0;
                sValue = 0; sqrtParam = 0;
                lengthDivider = 0; NoEvalValue = 0;
                MoreThanThirtyFlag = true;
                limitValue = 63; startValue = 64;
            }
        }
        #endregion

        #region Update
        /// <summary>
        /// Updates the value of the Jurik Moving Average.
        /// The indicator is not primed during the first <c>ℓ</c> updates.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public double Update(double sample)
        {
            if (double.IsNaN(sample))
                return sample;
            lock (updateLock)
            {
                int i;
                int j;
                int intPart;
                int leftInt;
                int rightPart;
                int upShift;
                int dnShift;
                double sqrtDivider;
                double dValue;
                double powerValue;
                double squareValue;
                double JMATempValue;
                if (primed)
                {
                    if (1 < length)
                    {
                    }
                    value = 0.0;
                }
                else // Not primed.
                {
                    primed = true;
                    value = 0.0;
                }
                ///////////////////////////////////////
                if (Counter <= (Period + 1000)) Counter++;
                /*** Begin of JMA ***/
                if (NoEvalValue == 0.0) NoEvalValue = CurClose;
                series = CurClose;
                if (loopParam < 61)
                { loopParam++; buffer[loopParam] = series; }
                if (loopParam > 30)
                {
                    if (MoreThanThirtyFlag == true)
                    {
                        int diffFlag = 0;
                        MoreThanThirtyFlag = false;
                        for (i = 1; i <= 29; i++)
                        { if (buffer[i + 1] != buffer[i]) diffFlag = 1; }
                        highLimit = diffFlag * 30;
                        if (highLimit == 0) paramB = series;
                        else paramB = buffer[1];
                        paramA = paramB;
                        if (highLimit > 29) highLimit = 29;
                    }
                    else highLimit = 0;
                    ///////////////////////////////////
                    for (i = highLimit; i >= 0; i--)
                    {
                        if (i == 0) sValue = series;
                        else sValue = buffer[31 - i];
                        if ((fabs(sValue - paramA)) > (fabs(sValue - paramB)))
                            absValue = fabs(sValue - paramA);
                        else absValue = fabs(sValue - paramB);
                        dValue = absValue + 0.0000000001;
                        if (counterA <= 1) counterA = 127;
                        else counterA--;
                        if (counterB <= 1) counterB = 10;
                        else counterB--;
                        if (cycleLimit < 128) cycleLimit++;
                        cycleDelta += (dValue - ring2[counterB]);
                        ring2[counterB] = dValue;
                        if (cycleLimit > 10) highDValue = cycleDelta;
                        else highDValue = cycleDelta / cycleLimit;
                        if (cycleLimit > 127)
                        {
                            dValue = ring1[counterA];
                            ring1[counterA] = highDValue;
                            s68 = 64; s58 = s68;
                            while (s68 > 1)
                            {
                                if (list[s58] < dValue)
                                { s68 = s68 / 2.0; s58 += s68; }
                                else
                                {
                                    if (list[s58] <= dValue) s68 = 1;
                                    else { s68 = s68 / 2.0; s58 -= s68; }
                                }
                            }
                        }
                        else
                        {
                            ring1[counterA] = highDValue;
                            if ((limitValue + startValue) > 127) { startValue--; s58 = startValue; }
                            else { limitValue++; s58 = limitValue; }
                            if (limitValue > 96) s38 = 96;
                            else s38 = limitValue;
                            if (startValue < 32) s40 = 32;
                            else s40 = startValue;
                        }
                        s68 = 64;
                        s60 = s68;
                        while (s68 > 1)
                        {
                            if (list[s60] >= highDValue)
                            {
                                if (list[s60 - 1] <= highDValue) s68 = 1;
                                else { s68 = s68 / 2.0; s60 -= s68; }
                            }
                            else { s68 = s68 / 2.0; s60 += s68; }
                            if ((s60 == 127) && (highDValue > list[127]))
                                s60 = 128;
                        }
                        if (cycleLimit > 127)
                        {
                            if (s58 >= s60)
                            {
                                if (((s38 + 1) > s60) && ((s40 - 1) < s60))
                                    lowDValue += highDValue;
                                else { if ((s40 > s60) && ((s40 - 1) < s58))
                                    lowDValue += list[s40 - 1]; }
                            }
                            else
                            {
                                if (s40 >= s60) { if (((s38 + 1) < s60) && ((s38 + 1) > s58))
                                    lowDValue += list[s38 + 1]; }
                                else
                                {
                                    if ((s38 + 2) > s60) lowDValue += highDValue;
                                    else { if (((s38 + 1) < s60) && ((s38 + 1) > s58))
                                        lowDValue += list[s38 + 1]; }
                                }
                            }
                            if (s58 > s60)
                            {
                                if (((s40 - 1) < s58) && ((s38 + 1) > s58))
                                    lowDValue -= list[s58];
                                else { if ((s38 < s58) && ((s38 + 1) > s60))
                                    lowDValue -= list[s38]; }
                            }
                            else
                            {
                                if (((s38 + 1) > s58) && ((s40 - 1) < s58))
                                    lowDValue -= list[s58];
                                else { if ((s40 > s58) && (s40 < s60))
                                    lowDValue -= list[s40]; }
                            }
                        }
                        if (s58 <= s60)
                        {
                            if (s58 >= s60) list[s60] = highDValue;
                            else
                            {
                                for (j = s58 + 1; j <= (s60 - 1); j++)
                                { list[j - 1] = list[j]; }
                                list[s60 - 1] = highDValue;
                            }
                        }
                        else
                        {
                            for (j = s58 - 1; j >= s60; j--)
                            { list[j + 1] = list[j]; }
                            list[s60] = highDValue;
                        }
                        if (cycleLimit <= 127)
                        {
                            lowDValue = 0;
                            for (j = s40; j <= s38; j++) { lowDValue += list[j]; }
                        }
                        if ((loopCriteria + 1) > 31) loopCriteria = 31;
                        else loopCriteria++;
                        sqrtDivider = sqrtParam / (sqrtParam + 1.0);
                        if (loopCriteria <= 30)
                        {
                            if ((sValue - paramA) > 0) paramA = sValue;
                            else paramA = sValue - ((sValue - paramA) * sqrtDivider);
                            if ((sValue - paramB) < 0) paramB = sValue;
                            else paramB = sValue - ((sValue - paramB) * sqrtDivider);
                            JMATempValue = series;
                            if (loopCriteria == 30)
                            {
                                Cur_fC0Buffer = series;
                                if (ceil(sqrtParam) >= 1)
                                    intPart = ceil(sqrtParam);
                                else intPart = 1;
                                leftInt = IntPortion(intPart);
                                if (floor(sqrtParam) >= 1)
                                    intPart = floor(sqrtParam);
                                else intPart = 1;
                                rightPart = IntPortion(intPart);
                                if (leftInt == rightPart) dValue = 1.0;
                                else
                                { dValue = (sqrtParam - rightPart) / (leftInt - rightPart); }
                                if (rightPart <= 29) upShift = rightPart;
                                else upShift = 29;
                                if (leftInt <= 29) dnShift = leftInt;
                                else dnShift = 29;
                                Cur_fA8Buffer = ((series - buffer[loopParam - upShift]) *
                                    (1 - dValue) / rightPart) +
                                    ((series - buffer[loopParam - dnShift]) * dValue / leftInt);
                            }
                        }
                        else
                        {
                            dValue = lowDValue / (s38 - s40 + 1);
                            if ((logParam - 2.0) >= 0.5)
                                powerValue = logParam - 2.0;
                            else powerValue = 0.5;
                            if (logParam >= pow(absValue / dValue, powerValue))
                                dValue = pow((absValue / dValue), powerValue);
                            else dValue = logParam;
                            if (dValue < 1) dValue = 1;
                            powerValue = pow(sqrtDivider, sqrt(dValue));
                            if ((sValue - paramA) > 0) paramA = sValue;
                            else { paramA = sValue - ((sValue - paramA) * powerValue); }
                            if ((sValue - paramB) < 0) paramB = sValue;
                            else paramB = sValue - ((sValue - paramB) * powerValue);
                        }
                    }
                    ////////////////////////////////////////////////////////////////////////////////////
                    if (loopCriteria > 30)
                    {
                        JMATempValue = PrevJMAValueBuffer;
                        powerValue = pow(lengthDivider, dValue);
                        squareValue = pow(powerValue, 2);
                        Cur_fC0Buffer = ((1 - powerValue) * series) +
                            (powerValue * Prev_fC0Buffer);
                        Cur_fC8Buffer = ((series - Cur_fC0Buffer) *
                            (1 - lengthDivider)) + (lengthDivider * Prev_fC8Buffer);
                        Cur_fA8Buffer = (phaseParam * Cur_fC8Buffer +
                            Cur_fC0Buffer - JMATempValue) *
                            (powerValue * (-2.0) + squareValue + 1) +
                            (squareValue * Prev_fA8Buffer);
                        JMATempValue += Cur_fA8Buffer;
                    }
                    JMAValue = JMATempValue;
                    PrevJMAValueBuffer = JMAValue;
                    Prev_fC0Buffer = Cur_fC0Buffer;
                    Prev_fC8Buffer = Cur_fC8Buffer;
                    Prev_fA8Buffer = Cur_fA8Buffer;
                    return JMAValue;
                }
                if (Counter <= max(Period, 50))
                    return Empty;
                return NoEvalValue;
                /*** End of JMA ***/
                ///////////////////////////////////////
                return value;
            }
        }

        /// <summary>
        /// Updates the value of the Jurik Moving Average.
        /// The indicator is not primed during the first <c>ℓ</c> updates.
        /// </summary>
        /// <param name="sample">A new sample.</param>
        /// <param name="dateTime">A date-time of the new sample.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(double sample, DateTime dateTime)
        {
            return new Scalar(dateTime, Update(sample));
        }

        /// <summary>
        /// Updates the value of the Jurik Moving Average.
        /// The indicator is not primed during the first <c>ℓ</c> updates.
        /// </summary>
        /// <param name="scalar">A new scalar.</param>
        /// <returns>The new value of the indicator.</returns>
        public Scalar Update(Scalar scalar)
        {
            return new Scalar(scalar.Time, Update(scalar.Value));
        }

        /// <summary>
        /// Updates the value of the Jurik Moving Average.
        /// The indicator is not primed during the first <c>ℓ</c> updates.
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
            StringBuilder sb = new StringBuilder();
            sb.Append("[M:");
            sb.Append(moniker);
            sb.Append(" L:");
            sb.Append(length);
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

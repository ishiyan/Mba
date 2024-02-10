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

        private double PrevJmaValueBuffer;
        private double Cur_fC0Buffer, Prev_fC0Buffer;
        private double Cur_fA8Buffer, Prev_fA8Buffer;
        private double Cur_fC8Buffer, Prev_fC8Buffer;
        double[] list = new double[128];
        double[] ring1 = new double[128];
        double[] ring2 = new double[11];
        double[] buffer = new double[62];
        private int limitValue = 63, startValue = 64;
        private int loopParam, loopCriteria;
        private int cycleLimit, highLimit;
        private int counterA, counterB;
        private int s58, s60, s40, s38, s68;
        private double cycleDelta, lowValue;
        private double highValue, absValue;
        private double paramA, paramB;
        private double phaseParam, logParam;
        private double jmaValue, series;
        private double sValue, sqrtParam;
        private double lengthDivider, NoEvalValue;
        private double lengthParam;
        private bool moreThanThirtyFlag = true;
        private int counter;

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
            if (phase < -100)
                phaseParam = 0.5;
            else if (phase > 100)
                phaseParam = 2.5;
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
            counter = 0;


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
                PrevJmaValueBuffer = 0;
                Cur_fC0Buffer = 0; Prev_fC0Buffer = 0;
                Cur_fA8Buffer = 0; Prev_fA8Buffer = 0;
                Cur_fC8Buffer = 0; Prev_fC8Buffer = 0;
                limitValue = 0; startValue = 0;
                loopParam = 0; loopCriteria = 0;
                cycleLimit = 0; highLimit = 0;
                counterA = 0; counterB = 0;
                s58 = 0; s60 = 0; s40 = 0; s38 = 0; s68 = 0;
                cycleDelta = 0; lowValue = 0;
                highValue = 0; absValue = 0;
                paramA = 0; paramB = 0;
                phaseParam = 0; logParam = 0;
                jmaValue = 0; series = 0;
                sValue = 0; sqrtParam = 0;
                lengthDivider = 0; NoEvalValue = 0;
                moreThanThirtyFlag = true;
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
                double jmaTempValue;
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
                const int N61 = 61;
                const int N30 = 30;
                if (counter <= (Period + 1000)) counter++;
                /*** Begin of JMA ***/
                if (NoEvalValue == 0.0)
                    NoEvalValue = CurClose;
                series = CurClose;
                if (loopParam < N61)
                {
                    loopParam++; buffer[loopParam] = series;
                }
                if (loopParam > N30)
                {
                    if (moreThanThirtyFlag == true)
                    {
                        int diffFlag = 0;
                        moreThanThirtyFlag = false;
                        for (int i = 1; i <= N30 - 1; i++) // if we have at least one different pair?
                        {
                            if (buffer[i + 1] != buffer[i])
                                diffFlag = 1;
                        }
                        highLimit = diffFlag * N30; // bool is sufficient
                        paramB = highLimit == 0 ? series : buffer[1];
                        paramA = paramB;
                        if (highLimit > 29)
                            highLimit = 29;
                    }
                    else
                        highLimit = 0;
                    ///////////////////////////////////
                    for (int i = highLimit; i >= 0; i--)
                    {
                        sValue = i == 0 ? series : buffer[N30+1 - i];
                        double tempA = Math.Abs(sValue - paramA);
                        double tempB = Math.Abs(sValue - paramB);
                        absValue = tempA > tempB ? tempA : tempB;
                        dValue = absValue + 0.0000000001;
                        if (counterA <= 1)
                            counterA = 127;
                        else
                            counterA--;
                        if (counterB <= 1)
                            counterB = 10;
                        else
                            counterB--;
                        if (cycleLimit < 128)
                            cycleLimit++;
                        cycleDelta += (dValue - ring2[counterB]);
                        ring2[counterB] = dValue;
                        highValue = cycleLimit > 10 ? cycleDelta : cycleDelta / cycleLimit;
                        if (cycleLimit > 127)
                        {
                            dValue = ring1[counterA];
                            ring1[counterA] = highValue;
                            s68 = 64; s58 = s68;
                            while (s68 > 1)
                            {
                                if (list[s58] < dValue)
                                {
                                    s68 /= 2.0;
                                    s58 += s68;
                                }
                                else
                                {
                                    if (list[s58] <= dValue)
                                        s68 = 1;
                                    else
                                    {
                                        s68 /= 2.0;
                                        s58 -= s68;
                                    }
                                }
                            }
                        }
                        else
                        {
                            ring1[counterA] = highValue;
                            s58 = (limitValue + startValue > 127) ? --startValue : ++limitValue;
                            s38 = limitValue > 96 ? 96 : limitValue;
                            s40 = startValue < 32 ? 32 : startValue;
                        }
                        s68 = 64;
                        s60 = s68;
                        while (s68 > 1)
                        {
                            if (list[s60] >= highValue)
                            {
                                if (list[s60 - 1] <= highValue)
                                    s68 = 1;
                                else
                                {
                                    s68 /= 2.0;
                                    s60 -= s68;
                                }
                            }
                            else
                            {
                                s68 /= 2.0;
                                s60 += s68;
                            }
                            if (s60 == 127 && highValue > list[127])
                                s60 = 128;
                        }
                        if (cycleLimit > 127)
                        {
                            if (s58 >= s60)
                            {
                                if (((s38 + 1) > s60) && ((s40 - 1) < s60))
                                    lowValue += highValue;
                                else { if ((s40 > s60) && ((s40 - 1) < s58))
                                    lowValue += list[s40 - 1]; }
                            }
                            else
                            {
                                if (s40 >= s60) { if (((s38 + 1) < s60) && ((s38 + 1) > s58))
                                    lowValue += list[s38 + 1]; }
                                else
                                {
                                    if ((s38 + 2) > s60) lowValue += highValue;
                                    else { if (((s38 + 1) < s60) && ((s38 + 1) > s58))
                                        lowValue += list[s38 + 1]; }
                                }
                            }
                            if (s58 > s60)
                            {
                                if (((s40 - 1) < s58) && ((s38 + 1) > s58))
                                    lowValue -= list[s58];
                                else { if ((s38 < s58) && ((s38 + 1) > s60))
                                    lowValue -= list[s38]; }
                            }
                            else
                            {
                                if (((s38 + 1) > s58) && ((s40 - 1) < s58))
                                    lowValue -= list[s58];
                                else { if ((s40 > s58) && (s40 < s60))
                                    lowValue -= list[s40]; }
                            }
                        }
                        if (s58 <= s60)
                        {
                            if (s58 >= s60) list[s60] = highValue;
                            else
                            {
                                for (j = s58 + 1; j <= (s60 - 1); j++)
                                { list[j - 1] = list[j]; }
                                list[s60 - 1] = highValue;
                            }
                        }
                        else
                        {
                            for (j = s58 - 1; j >= s60; j--)
                            { list[j + 1] = list[j]; }
                            list[s60] = highValue;
                        }
                        if (cycleLimit <= 127)
                        {
                            lowValue = 0;
                            for (j = s40; j <= s38; j++) { lowValue += list[j]; }
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
                            jmaTempValue = series;
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
                            dValue = lowValue / (s38 - s40 + 1);
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
                        jmaTempValue = PrevJmaValueBuffer;
                        powerValue = pow(lengthDivider, dValue);
                        squareValue = pow(powerValue, 2);
                        Cur_fC0Buffer = ((1 - powerValue) * series) +
                            (powerValue * Prev_fC0Buffer);
                        Cur_fC8Buffer = ((series - Cur_fC0Buffer) *
                            (1 - lengthDivider)) + (lengthDivider * Prev_fC8Buffer);
                        Cur_fA8Buffer = (phaseParam * Cur_fC8Buffer +
                            Cur_fC0Buffer - jmaTempValue) *
                            (powerValue * (-2.0) + squareValue + 1) +
                            (squareValue * Prev_fA8Buffer);
                        jmaTempValue += Cur_fA8Buffer;
                    }
                    jmaValue = jmaTempValue;
                    PrevJmaValueBuffer = jmaValue;
                    Prev_fC0Buffer = Cur_fC0Buffer;
                    Prev_fC8Buffer = Cur_fC8Buffer;
                    Prev_fA8Buffer = Cur_fA8Buffer;
                    return jmaValue;
                }
                if (counter <= max(Period, 50))
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

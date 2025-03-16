namespace SmartQuant.Indicators
{
    using SmartQuant.Data;
    using SmartQuant.Series;
    using System;
    using System.ComponentModel;
    using System.Drawing;

    [Serializable]
    public class TRIX : Indicator
    {
        protected EMA fEMA;
        protected EMA fEMA_2;
        protected EMA fEMA_3;
        protected int fLength;
        protected BarData fOption;

        public TRIX()
        {
            this.fLength = 14;
            this.Init();
        }

        public TRIX(TimeSeries input, int length) : base(input)
        {
            this.fLength = 14;
            this.fLength = length;
            this.Init();
        }

        public TRIX(TimeSeries input, int length, BarData option) : base(input)
        {
            this.fLength = 14;
            this.fLength = length;
            this.fOption = option;
            this.Init();
        }

        public TRIX(TimeSeries input, int length, Color color) : base(input)
        {
            this.fLength = 14;
            this.fLength = length;
            base.Color = color;
            this.Init();
        }

        public TRIX(TimeSeries input, int length, BarData option, Color color) : base(input)
        {
            this.fLength = 14;
            this.fLength = length;
            this.fOption = option;
            this.Init();
            base.Color = color;
        }

        public TRIX(TimeSeries input, int length, BarData option, Color color, EDrawStyle drawStyle) : base(input)
        {
            this.fLength = 14;
            this.fLength = length;
            this.fOption = option;
            this.Init();
            base.Color = color;
            base.DrawStyle = drawStyle;
        }

        protected override void Calculate(int index)
        {
            double naN = double.NaN;
            if (index >= (1 + base.fInput.FirstIndex))
            {
                naN = ((this.fEMA_3[index] - this.fEMA_3[index - 1]) / this.fEMA_3[index - 1]) * 100.0;
            }
            this.Add(base.fInput.GetDateTime(index), naN);
        }

        public override void Detach()
        {
            this.fEMA.Detach();
            base.Detach();
        }

        protected override void Init()
        {
            base.fName = "TRIX (" + this.fLength + " )";
            base.fTitle = "TRIX Index";
            this.Clear();
            base.fCalculate = true;
            if (base.fInput != null)
            {
                if (base.fInput is BarSeries)
                {
                    base.fName = string.Concat(new object[] { "TRIX (", this.fLength, ", ", this.fOption, ")" });
                }
                if (TimeSeries.fNameOption == ENameOption.Long)
                {
                    base.fName = base.fInput.Name + " " + base.fName;
                }
                base.Disconnect();
                this.fEMA = new EMA(base.fInput, this.fLength, this.fOption);
                this.Connect();
                this.fEMA_2 = new EMA(this.fEMA, this.fLength, this.fOption);
                this.fEMA_3 = new EMA(this.fEMA_2, this.fLength, this.fOption);
                this.fEMA.DrawEnabled = false;
                this.fEMA_2.DrawEnabled = false;
                this.fEMA_3.DrawEnabled = false;
            }
        }

        public override void OnInputItemAdded(object sender, DateTimeEventArgs EventArgs)
        {
            if (base.fMonitored)
            {
                int index = base.fInput.GetIndex(EventArgs.DateTime);
                if (index != -1)
                {
                    for (int i = index; i <= (base.fInput.Count - 1); i++)
                    {
                        this.Calculate(i);
                    }
                }
            }
        }

        public static double Value(DoubleSeries input, int index, int length)
        {
            return Value(input, index, length, BarData.Close);
        }

        public static double Value(TimeSeries input, int index, int length, BarData option)
        {
            if (index < (1 + input.FirstIndex))
            {
                return double.NaN;
            }
            DoubleSeries series = new DoubleSeries();
            for (int i = input.FirstIndex; i <= index; i++)
            {
                series.Add(input.GetDateTime(i), input[i, option]);
            }
            EMA ema = new EMA(series, length, option);
            EMA ema2 = new EMA(ema, length, option);
            EMA ema3 = new EMA(ema2, length, option);
            return (((ema3[index - input.FirstIndex] - ema3[(index - 1) - input.FirstIndex]) / ema3[(index - 1) - input.FirstIndex]) * 100.0);
        }

        [Category("Parameters"), Description(""), IndicatorParameter(0)]
        public int Length
        {
            get
            {
                return this.fLength;
            }
            set
            {
                this.fLength = value;
                this.Init();
            }
        }

        [Description(""), Category("Parameters"), IndicatorParameter(1)]
        public BarData Option
        {
            get
            {
                return this.fOption;
            }
            set
            {
                this.fOption = value;
                this.Init();
            }
        }
    }
}


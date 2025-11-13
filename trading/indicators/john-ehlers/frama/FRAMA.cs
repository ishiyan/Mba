#region Using declarations
using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Xml.Serialization;
using NinjaTrader.Cbi;
using NinjaTrader.Data;
using NinjaTrader.Gui.Chart;
#endregion

// This namespace holds all indicators and is required. Do not change it.
namespace NinjaTrader.Indicator
{
    /// <summary>
    /// FRAMA by John Ehlers, Nonlinear Moving Average that adapts with help of the Hurst exponent
    /// </summary>
    [Description("FRAMA by John Ehlers, Nonlinear Moving Average that adapts with help of the Hurst exponent")]
    public class FRAMA : Indicator
    {
        #region Variables
        
		// Wizard generated variables
            private int period = 16; // Default setting for period
            private int deviation = 1; // Default setting for deviation
        
		// User defined variables
			private double dimension;
		    private double alpha;
		    private double finalAlpha;
		    private double upperBand;
			private double lowerBand;
		    private double highLowRange1;
			private double highLowRange2;
			private double highLowRange3;
		    
		    private int halfPeriod;
		    
		// declare DataSeries objects
		    private DataSeries halfPeriodHigh;
			private DataSeries halfPeriodLow;
		    private DataSeries filter;
					
        #endregion

        /// <summary>
        /// This method is used to configure the indicator and is called once before any bar data is loaded.
        /// </summary>
        protected override void Initialize()
        {
            Add(new Plot(Color.FromKnownColor(KnownColor.Blue), PlotStyle.Line, "FRAMA"));
            Add(new Plot(Color.FromKnownColor(KnownColor.Gray), PlotStyle.Line, "UpperBand"));
            Add(new Plot(Color.FromKnownColor(KnownColor.Gray), PlotStyle.Line, "LowerBand"));
            
			CalculateOnBarClose	= true;
            Overlay				= true;
            PriceTypeSupported	= true;
			
			halfPeriodHigh 	= new DataSeries(this);
			halfPeriodLow 	= new DataSeries(this);
			filter 			= new DataSeries(this);
			
        }

        /// <summary>
        /// Called on each bar update event (incoming tick)
        /// </summary>
        protected override void OnBarUpdate()
        {
			//do we have enough bars?
			if (CurrentBar < Period)
				return;
			
			//define half period
			halfPeriod = Period / 2;
			
			//define the three needed ranges for calculating the fractal dimension
			highLowRange1 = ((MAX(High, Period)[0] - MIN(Low, Period)[0]) / Period);
					
			highLowRange2 = ((MAX(High, halfPeriod)[0] - MIN(Low, halfPeriod)[0]) / (halfPeriod));
			
			halfPeriodHigh.Set(High[halfPeriod]);
			halfPeriodLow.Set(Low[halfPeriod]);
	
			highLowRange3 = ((MAX(halfPeriodHigh, halfPeriod)[0] - MIN(halfPeriodLow, halfPeriod)[0]) / halfPeriod);
			
			// calculate fractal dimension for adapting the MA
			if (highLowRange1 > 0 && highLowRange2 > 0 && highLowRange3 > 0)
				dimension = (Math.Log(highLowRange3 + highLowRange2) - Math.Log(highLowRange1)) / Math.Log(2);
			
			// calculate the alpha needed for the adaptive ema in the next step
				alpha = Math.Exp(- 4.6 * (dimension - 1));
			
			// limit alpha to vary only from 0.01 to 1
			if (alpha < 0.01)
				finalAlpha = 0.01;
			else
				finalAlpha = alpha;
				
			if (alpha > 1)
				finalAlpha = 1;
			else
				finalAlpha = alpha;
			
			//final calculation of the frama filter with user changeable input series
			filter.Set(finalAlpha * Input[0] + (1 - finalAlpha) * filter[1]);
            
			//calculate uppper- and lowerbands
			upperBand = filter[0] + (Deviation * StdDev(Period)[0]);
			lowerBand = filter[0] - (Deviation * StdDev(Period)[0]);
			
			//define our final plots
            Frama.Set(filter[0]);
			Upperband.Set(upperBand);
            Lowerband.Set(lowerBand);
        }

        #region Properties
        [Browsable(false)]	// this line prevents the data series from being displayed in the indicator properties dialog, do not remove
        [XmlIgnore()]		// this line ensures that the indicator can be saved/recovered as part of a chart template, do not remove
        public DataSeries Frama
        {
            get { return Values[0]; }
        }

        [Browsable(false)]	// this line prevents the data series from being displayed in the indicator properties dialog, do not remove
        [XmlIgnore()]		// this line ensures that the indicator can be saved/recovered as part of a chart template, do not remove
        public DataSeries Upperband
        {
            get { return Values[1]; }
        }

        [Browsable(false)]	// this line prevents the data series from being displayed in the indicator properties dialog, do not remove
        [XmlIgnore()]		// this line ensures that the indicator can be saved/recovered as part of a chart template, do not remove
        public DataSeries Lowerband
        {
            get { return Values[2]; }
        }

        [Description("Even number of bars used for calculations")]
        [Category("Parameters")]
        public int Period
        {
            get { return period; }
            set { period = Math.Max(2, value); }
        }

        [Description("Number of standard deviations")]
        [Category("Parameters")]
        public int Deviation
        {
            get { return deviation; }
            set { deviation = Math.Max(0, value); }
        }

        #endregion
    }
}

#region NinjaScript generated code. Neither change nor remove.
// This namespace holds all indicators and is required. Do not change it.
namespace NinjaTrader.Indicator
{
    public partial class Indicator : IndicatorBase
    {
        private FRAMA[] cacheFRAMA = null;

        private static FRAMA checkFRAMA = new FRAMA();

        /// <summary>
        /// FRAMA by John Ehlers, Nonlinear Moving Average that adapts with help of the Hurst exponent
        /// </summary>
        /// <returns></returns>
        public FRAMA FRAMA(int deviation, int period)
        {
            return FRAMA(Input, deviation, period);
        }

        /// <summary>
        /// FRAMA by John Ehlers, Nonlinear Moving Average that adapts with help of the Hurst exponent
        /// </summary>
        /// <returns></returns>
        public FRAMA FRAMA(Data.IDataSeries input, int deviation, int period)
        {
            checkFRAMA.Deviation = deviation;
            deviation = checkFRAMA.Deviation;
            checkFRAMA.Period = period;
            period = checkFRAMA.Period;

            if (cacheFRAMA != null)
                for (int idx = 0; idx < cacheFRAMA.Length; idx++)
                    if (cacheFRAMA[idx].Deviation == deviation && cacheFRAMA[idx].Period == period && cacheFRAMA[idx].EqualsInput(input))
                        return cacheFRAMA[idx];

            FRAMA indicator = new FRAMA();
            indicator.BarsRequired = BarsRequired;
            indicator.CalculateOnBarClose = CalculateOnBarClose;
            indicator.Input = input;
            indicator.Deviation = deviation;
            indicator.Period = period;
            indicator.SetUp();

            FRAMA[] tmp = new FRAMA[cacheFRAMA == null ? 1 : cacheFRAMA.Length + 1];
            if (cacheFRAMA != null)
                cacheFRAMA.CopyTo(tmp, 0);
            tmp[tmp.Length - 1] = indicator;
            cacheFRAMA = tmp;
            Indicators.Add(indicator);

            return indicator;
        }

    }
}

// This namespace holds all market analyzer column definitions and is required. Do not change it.
namespace NinjaTrader.MarketAnalyzer
{
    public partial class Column : ColumnBase
    {
        /// <summary>
        /// FRAMA by John Ehlers, Nonlinear Moving Average that adapts with help of the Hurst exponent
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator.FRAMA FRAMA(int deviation, int period)
        {
            return _indicator.FRAMA(Input, deviation, period);
        }

        /// <summary>
        /// FRAMA by John Ehlers, Nonlinear Moving Average that adapts with help of the Hurst exponent
        /// </summary>
        /// <returns></returns>
        public Indicator.FRAMA FRAMA(Data.IDataSeries input, int deviation, int period)
        {
            return _indicator.FRAMA(input, deviation, period);
        }

    }
}

// This namespace holds all strategies and is required. Do not change it.
namespace NinjaTrader.Strategy
{
    public partial class Strategy : StrategyBase
    {
        /// <summary>
        /// FRAMA by John Ehlers, Nonlinear Moving Average that adapts with help of the Hurst exponent
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator.FRAMA FRAMA(int deviation, int period)
        {
            return _indicator.FRAMA(Input, deviation, period);
        }

        /// <summary>
        /// FRAMA by John Ehlers, Nonlinear Moving Average that adapts with help of the Hurst exponent
        /// </summary>
        /// <returns></returns>
        public Indicator.FRAMA FRAMA(Data.IDataSeries input, int deviation, int period)
        {
            if (InInitialize && input == null)
                throw new ArgumentException("You only can access an indicator with the default input/bar series from within the 'Initialize()' method");

            return _indicator.FRAMA(input, deviation, period);
        }

    }
}
#endregion

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
     
    [Description("Even Better Sine Wave indicator from John Ehler's book, Cycle Analytics for Ttraders")]
    public class _JFE_EBSineWave : Indicator
    {
        //#region Variables
      
            private int duration = 20; 
			private const double rtd = Math.PI / 180;
			private double alpha1;
			private DataSeries HP;
			private double a1;
			private double b1;
			private double c1;
			private double c2;
			private double c3;
			private DataSeries filt;
			private DataSeries wave;
			private DataSeries pwr;
			private bool ShowPlot=true;
		    private double alpha1Plus1d2,k1,k2,k3,k4, prevInput=0;
		
      //  #endregion

       
        protected override void Initialize()
        {
            Add(new Plot(Color.FromKnownColor(KnownColor.PowderBlue), PlotStyle.Line, "Wave"));
            Add(new Line(Color.FromKnownColor(KnownColor.White), 0, "ZeroLine"));
            Overlay				= false;
			HP = new DataSeries(this);
			filt = new DataSeries(this);
			wave = new DataSeries(this);
			pwr = new DataSeries(this);
			this.Name="_JFE Even Better Sine Wave";
			CalculateOnBarClose=false;
        }

        protected override void OnStartUp()
		{   try{
			// these only need to be calculated ONCE, not OnBarUpdate
			 alpha1 = (1 - Math.Sin(rtd*360 / duration)) / Math.Cos(rtd*360 / duration);
			 alpha1Plus1d2=.50*(1+alpha1);
			 a1 = Math.Exp(-1.414*Math.PI / 10);
			 b1 = 2*a1*Math.Cos(1.414*rtd*180 / 10);
			 c2 = b1;
			 c3 = -a1*a1;
			 c1 = 1 - c2 - c3;
			}catch (Exception e){	Print("~JFE Even Better Sine Wave Line 67 " + e.ToString());}	
		}
		
        protected override void OnBarUpdate()
        {   try{
			
			if (CurrentBar < 2 ||( !FirstTickOfBar && !(prevInput != Input[0]) ))  return;  			
			prevInput=Input[0];
			
			if(FirstTickOfBar)   // all of these remain unchanged during the entire lifetime of each bar since they are dependent on PREVIOUS inputs.
			 { 
				k1=alpha1*HP[1];               k2=c2*filt[1] + c3*filt[2];			   
			    k3=filt[1]+filt[2];            k4=filt[1]*filt[1] + filt[2]*filt[2];
			 }
			//HighPass filter cyclic components whose periods are shorter than Duration input
			//HP.Set(.5*(1 + alpha1)*(Input[0] - Input[1]) + alpha1*HP[1]);
			  HP[0] =alpha1Plus1d2  *(Input[0] - Input[1]) + k1             ;
			//Smooth with a Super Smoother Filter from equation 3-3
			//filt.Set(c1*(HP[0] + HP[1]) / 2 + c2*filt[1] + c3*filt[2]);
			  filt[0]=c1*(HP[0] + HP[1]) / 2 + k2                      ;
			//3 Bar average of Wave amplitude and power
			//wave.Set((filt[0] + filt[1] + filt[2]) / 3);
			  wave[0]=(filt[0] + k3                ) / 3 ;
			//pwr.Set((filt[0]*filt[0] + filt[1]*filt[1] + filt[2]*filt[2]) / 3);
			  pwr[0]= (filt[0]*filt[0]                                + k4) / 3 ;
			//Normalize the Average Wave to Square Root of the Average Power
			//wave.Set(wave[0] / Math.Sqrt(pwr[0]));
              wave[0]=wave[0]  / Math.Sqrt(pwr[0]) ;
            if(ShowPlot)Values[0][0]=wave[0];
			//if called by another indicator there is no point setting the value of a plot that cannot be displayed.
			}catch (Exception e){	Print("__atf EMA Line 94 " + e.ToString());}	
        }

        #region Properties
        [Browsable(false)]	
        [XmlIgnore()]		
        public DataSeries SineWave
        {
            get { return wave; }
        }

        [Description("Period Length")]
        [Category("Parameters")]
        public int Duration
        {
            get { return duration; }
            set { duration = Math.Max(1, value); }
        }
		
		[Browsable(false)]	
        [XmlIgnore()]
		[Description("Set to false if called by another indicator")]
        [Category("Parameters")]
        public bool PlotDisplay
        {
            get { return ShowPlot; }
            set { ShowPlot=value; }
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
        private _JFE_EBSineWave[] cache_JFE_EBSineWave = null;

        private static _JFE_EBSineWave check_JFE_EBSineWave = new _JFE_EBSineWave();

        /// <summary>
        /// Even Better Sine Wave indicator from John Ehler's book, Cycle Analytics for Ttraders
        /// </summary>
        /// <returns></returns>
        public _JFE_EBSineWave _JFE_EBSineWave(int duration, bool plotDisplay)
        {
            return _JFE_EBSineWave(Input, duration, plotDisplay);
        }

        /// <summary>
        /// Even Better Sine Wave indicator from John Ehler's book, Cycle Analytics for Ttraders
        /// </summary>
        /// <returns></returns>
        public _JFE_EBSineWave _JFE_EBSineWave(Data.IDataSeries input, int duration, bool plotDisplay)
        {
            if (cache_JFE_EBSineWave != null)
                for (int idx = 0; idx < cache_JFE_EBSineWave.Length; idx++)
                    if (cache_JFE_EBSineWave[idx].Duration == duration && cache_JFE_EBSineWave[idx].PlotDisplay == plotDisplay && cache_JFE_EBSineWave[idx].EqualsInput(input))
                        return cache_JFE_EBSineWave[idx];

            lock (check_JFE_EBSineWave)
            {
                check_JFE_EBSineWave.Duration = duration;
                duration = check_JFE_EBSineWave.Duration;
                check_JFE_EBSineWave.PlotDisplay = plotDisplay;
                plotDisplay = check_JFE_EBSineWave.PlotDisplay;

                if (cache_JFE_EBSineWave != null)
                    for (int idx = 0; idx < cache_JFE_EBSineWave.Length; idx++)
                        if (cache_JFE_EBSineWave[idx].Duration == duration && cache_JFE_EBSineWave[idx].PlotDisplay == plotDisplay && cache_JFE_EBSineWave[idx].EqualsInput(input))
                            return cache_JFE_EBSineWave[idx];

                _JFE_EBSineWave indicator = new _JFE_EBSineWave();
                indicator.BarsRequired = BarsRequired;
                indicator.CalculateOnBarClose = CalculateOnBarClose;
#if NT7
                indicator.ForceMaximumBarsLookBack256 = ForceMaximumBarsLookBack256;
                indicator.MaximumBarsLookBack = MaximumBarsLookBack;
#endif
                indicator.Input = input;
                indicator.Duration = duration;
                indicator.PlotDisplay = plotDisplay;
                Indicators.Add(indicator);
                indicator.SetUp();

                _JFE_EBSineWave[] tmp = new _JFE_EBSineWave[cache_JFE_EBSineWave == null ? 1 : cache_JFE_EBSineWave.Length + 1];
                if (cache_JFE_EBSineWave != null)
                    cache_JFE_EBSineWave.CopyTo(tmp, 0);
                tmp[tmp.Length - 1] = indicator;
                cache_JFE_EBSineWave = tmp;
                return indicator;
            }
        }
    }
}

// This namespace holds all market analyzer column definitions and is required. Do not change it.
namespace NinjaTrader.MarketAnalyzer
{
    public partial class Column : ColumnBase
    {
        /// <summary>
        /// Even Better Sine Wave indicator from John Ehler's book, Cycle Analytics for Ttraders
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator._JFE_EBSineWave _JFE_EBSineWave(int duration, bool plotDisplay)
        {
            return _indicator._JFE_EBSineWave(Input, duration, plotDisplay);
        }

        /// <summary>
        /// Even Better Sine Wave indicator from John Ehler's book, Cycle Analytics for Ttraders
        /// </summary>
        /// <returns></returns>
        public Indicator._JFE_EBSineWave _JFE_EBSineWave(Data.IDataSeries input, int duration, bool plotDisplay)
        {
            return _indicator._JFE_EBSineWave(input, duration, plotDisplay);
        }
    }
}

// This namespace holds all strategies and is required. Do not change it.
namespace NinjaTrader.Strategy
{
    public partial class Strategy : StrategyBase
    {
        /// <summary>
        /// Even Better Sine Wave indicator from John Ehler's book, Cycle Analytics for Ttraders
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator._JFE_EBSineWave _JFE_EBSineWave(int duration, bool plotDisplay)
        {
            return _indicator._JFE_EBSineWave(Input, duration, plotDisplay);
        }

        /// <summary>
        /// Even Better Sine Wave indicator from John Ehler's book, Cycle Analytics for Ttraders
        /// </summary>
        /// <returns></returns>
        public Indicator._JFE_EBSineWave _JFE_EBSineWave(Data.IDataSeries input, int duration, bool plotDisplay)
        {
            if (InInitialize && input == null)
                throw new ArgumentException("You only can access an indicator with the default input/bar series from within the 'Initialize()' method");

            return _indicator._JFE_EBSineWave(input, duration, plotDisplay);
        }
    }
}
#endregion

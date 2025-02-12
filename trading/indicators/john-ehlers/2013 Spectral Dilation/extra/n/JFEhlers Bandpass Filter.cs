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
	
	
	[Description("CPU optimized version of John Ehlers' Bandpass Filter from Cycle Analytics for Traders")]
	public class JFE_Bandpass_Filter : Indicator
	{
		private const double rtd = Math.PI / 180; //radians to degrees
		private double alpha2;
		private double gamma1;
		private double alpha1;
		private double beta1;
		private double bandwidth = 0.3;
        private double br3p,rtdp,_1a22,_1at1,fbrt;
		private double HPf,BPf,Tf,_1alpha;
		private DataSeries HP;
		private DataSeries BP;
		private DataSeries Peak;
		private DataSeries signal;
		private DataSeries trigger;
		private int period = 20;
		
		
		protected override void Initialize()
		{
			Add(new Plot(Color.FromKnownColor(KnownColor.Orange), PlotStyle.Line, "Trigger"));
			Add(new Plot(Color.FromKnownColor(KnownColor.Red), PlotStyle.Line, "Signal"));
			Add (new Line (Color.DarkGray, 0, "ZeroLine"));
			Overlay = false;
			HP = new DataSeries(this);
			BP = new DataSeries(this);
			trigger = new DataSeries(this);
			signal = new DataSeries(this);
			Peak = new DataSeries(this);
			CalculateOnBarClose=false;
			this.Name="JFEhlers' Bandpass Filter";
		}
           
		protected override void OnStartUp()
		{   
			rtdp= rtd * 360 / period;
			br3p= .25 * bandwidth * rtdp;
			fbrt= 1.5 * bandwidth * rtdp;
			//alpha2 = (Math.Cos(.25 * bandwidth * rtd * 360 / period) + Math.Sin(.25 * bandwidth * rtd * 360 / period) - 1) / Math.Cos(.25 * bandwidth * rtd * 360 / period);
			alpha2 = (Math.Cos(br3p) + Math.Sin(br3p) - 1) / Math.Cos(br3p);
			beta1 = Math.Cos(rtd * 360 / period);
			gamma1 = 1 / Math.Cos(rtd * 360 * bandwidth / period);
			alpha1 = gamma1 - Math.Sqrt(gamma1 * gamma1 - 1);
			alpha2 = (Math.Cos(fbrt) + Math.Sin(fbrt) - 1) / Math.Cos(fbrt);
			_1a22   =  1 + alpha2 / 2;
			_1alpha = .5 * (1 - alpha1);
		}
		
		
		protected override void OnBarUpdate()
		{
			if (CurrentBar < 2)
			{
				Trigger.Set(0);
				Peak.Set(0);
				Signal.Set(0);
				BP.Set(0);
				return;
			}
			if(FirstTickOfBar)
			{   
				HPf = (1- alpha2) * HP[1];
			    BPf = beta1 * (1 + alpha1) * BP[1] - alpha1 * BP[2];
			    Peak.Set(.991 * Peak[1]);
			    _1at1=(1- alpha2) * Trigger[1];
			}
			
			//HP.Set((1 + alpha2 / 2)*(Input[0] - Input[1]) + (1- alpha2) * HP[1]  );
			HP[0]=  _1a22*(Input[0] - Input[1]) + HPf;
			
			BP[0] = _1alpha * (HP[0] - HP[2]) + BPf;

			if (Math.Abs(BP[0]) > Peak[0]) 	Peak[0]=Math.Abs(BP[0]);
				
			if (Peak[0] != 0)              	signal[0]=BP[0] / Peak[0];
			
			Trigger[0]=(_1a22) * (signal[0] - signal[1]) + _1at1;
			
			Signal[0]=signal[0];
				
		}

		#region Properties
		[Browsable(false)]
		[XmlIgnore]
		public DataSeries Trigger
		{
			get { return Values[0]; }
		}

		[Browsable(false)]
		[XmlIgnore]
		public DataSeries Signal
		{
			get { return Values[1]; }
		}
		
		[Description("")]
		[GridCategory("Parameters")]
		public int Period
		{
			get { return period; }
			set { period = Math.Max(1, value); }
		}	
		
		[Description("")]
        [Category("Parameters")]
        public double Bandwidth
        {
            get { return bandwidth; }
            set { bandwidth = Math.Max(0.000, value); }
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
        private JFE_Bandpass_Filter[] cacheJFE_Bandpass_Filter = null;

        private static JFE_Bandpass_Filter checkJFE_Bandpass_Filter = new JFE_Bandpass_Filter();

        /// <summary>
        /// CPU optimized version of John Ehlers' Bandpass Filter from Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        public JFE_Bandpass_Filter JFE_Bandpass_Filter(double bandwidth, int period)
        {
            return JFE_Bandpass_Filter(Input, bandwidth, period);
        }

        /// <summary>
        /// CPU optimized version of John Ehlers' Bandpass Filter from Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        public JFE_Bandpass_Filter JFE_Bandpass_Filter(Data.IDataSeries input, double bandwidth, int period)
        {
            if (cacheJFE_Bandpass_Filter != null)
                for (int idx = 0; idx < cacheJFE_Bandpass_Filter.Length; idx++)
                    if (Math.Abs(cacheJFE_Bandpass_Filter[idx].Bandwidth - bandwidth) <= double.Epsilon && cacheJFE_Bandpass_Filter[idx].Period == period && cacheJFE_Bandpass_Filter[idx].EqualsInput(input))
                        return cacheJFE_Bandpass_Filter[idx];

            lock (checkJFE_Bandpass_Filter)
            {
                checkJFE_Bandpass_Filter.Bandwidth = bandwidth;
                bandwidth = checkJFE_Bandpass_Filter.Bandwidth;
                checkJFE_Bandpass_Filter.Period = period;
                period = checkJFE_Bandpass_Filter.Period;

                if (cacheJFE_Bandpass_Filter != null)
                    for (int idx = 0; idx < cacheJFE_Bandpass_Filter.Length; idx++)
                        if (Math.Abs(cacheJFE_Bandpass_Filter[idx].Bandwidth - bandwidth) <= double.Epsilon && cacheJFE_Bandpass_Filter[idx].Period == period && cacheJFE_Bandpass_Filter[idx].EqualsInput(input))
                            return cacheJFE_Bandpass_Filter[idx];

                JFE_Bandpass_Filter indicator = new JFE_Bandpass_Filter();
                indicator.BarsRequired = BarsRequired;
                indicator.CalculateOnBarClose = CalculateOnBarClose;
#if NT7
                indicator.ForceMaximumBarsLookBack256 = ForceMaximumBarsLookBack256;
                indicator.MaximumBarsLookBack = MaximumBarsLookBack;
#endif
                indicator.Input = input;
                indicator.Bandwidth = bandwidth;
                indicator.Period = period;
                Indicators.Add(indicator);
                indicator.SetUp();

                JFE_Bandpass_Filter[] tmp = new JFE_Bandpass_Filter[cacheJFE_Bandpass_Filter == null ? 1 : cacheJFE_Bandpass_Filter.Length + 1];
                if (cacheJFE_Bandpass_Filter != null)
                    cacheJFE_Bandpass_Filter.CopyTo(tmp, 0);
                tmp[tmp.Length - 1] = indicator;
                cacheJFE_Bandpass_Filter = tmp;
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
        /// CPU optimized version of John Ehlers' Bandpass Filter from Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator.JFE_Bandpass_Filter JFE_Bandpass_Filter(double bandwidth, int period)
        {
            return _indicator.JFE_Bandpass_Filter(Input, bandwidth, period);
        }

        /// <summary>
        /// CPU optimized version of John Ehlers' Bandpass Filter from Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        public Indicator.JFE_Bandpass_Filter JFE_Bandpass_Filter(Data.IDataSeries input, double bandwidth, int period)
        {
            return _indicator.JFE_Bandpass_Filter(input, bandwidth, period);
        }
    }
}

// This namespace holds all strategies and is required. Do not change it.
namespace NinjaTrader.Strategy
{
    public partial class Strategy : StrategyBase
    {
        /// <summary>
        /// CPU optimized version of John Ehlers' Bandpass Filter from Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator.JFE_Bandpass_Filter JFE_Bandpass_Filter(double bandwidth, int period)
        {
            return _indicator.JFE_Bandpass_Filter(Input, bandwidth, period);
        }

        /// <summary>
        /// CPU optimized version of John Ehlers' Bandpass Filter from Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        public Indicator.JFE_Bandpass_Filter JFE_Bandpass_Filter(Data.IDataSeries input, double bandwidth, int period)
        {
            if (InInitialize && input == null)
                throw new ArgumentException("You only can access an indicator with the default input/bar series from within the 'Initialize()' method");

            return _indicator.JFE_Bandpass_Filter(input, bandwidth, period);
        }
    }
}
#endregion

//#define SHOW_PERIOD

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
	
	/// Speed optimized by Zondor 20 DEC 2011
	/// Supports the Cyber Cycle Oscillator
	
	[Description ("Hilbert Transform (from Cybernetic Analysis by John Ehlers)")]
	public class HilbertTransform2 : Indicator
	{
		//#region Variables
		
		private double alpha = 0.07; // Default setting for Alpha
		
        private double medianDelta,dc,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,s1,s2,s3,c11,c12,c13;
		private DataSeries _smooth;
		private DataSeries _cycle;
		private DataSeries _instPeriod;
//#if !SHOW_PERIOD
		private DataSeries _period;
//#endif
		private DataSeries _deltaPhase;
		private double prevInput;
		private MedianIndicator aMI;
		//#endregion

		
		protected override void Initialize ()
		{   this.Name="Hibert Transform 2)";
			Add (new Line (Color.DarkGray, 0, "ZeroLine"));

			Add (new Plot (Color.Red, PlotStyle.Line, "InPhase"));
			Add (new Plot (Color.Blue, PlotStyle.Line, "Quadrature"));
//#if SHOW_PERIOD
			Add (new Plot (Color.Transparent, PlotStyle.Line, "Period"));
//#else
			_period = new DataSeries (this);
//#endif

			CalculateOnBarClose = false;
			Overlay = false;
			PriceTypeSupported = true;

			_smooth = new DataSeries (this);// WMA (Input, alpha).Value;
			_cycle = new DataSeries (this);
			_instPeriod = new DataSeries (this);
			_deltaPhase = new DataSeries (this);
		}

	protected override void OnStartUp()
		{   s1=(1 - alpha) * (1 - alpha);
			s2=(1 - .5 * alpha) * (1 - .5 * alpha);
			
		}
		protected override void OnBarUpdate ()
		{      DataSeries I1 = Value;
			   DataSeries Q1 = Quadrature;
			
            if(FirstTickOfBar||prevInput!=Input[0])
			{   if (this.CurrentBar < 7)	return;
				prevInput=Input[0];
				if(FirstTickOfBar)
			   { 
				 c1= 2 * Input [1] + 2 * Input [2] + Input [3] ;
			     c2=  - 2 * Smooth [1] + Smooth [2];
			     c3=(1 - alpha) * 2 * Cycle [1] -	s1 * Cycle [2];
				 c4=0.5769 * Cycle [2] - 0.5769 * Cycle [4] - 0.0962 * Cycle [6];
				 c5=0.5 + 0.08 * _instPeriod [1];
				 c6=I1[1] / Q1[1];
				 c7=-2 * Smooth [1] + Smooth [2];
				 c8=  - 2 * Input [1] + Input [2] ;
				 c11=(0.5 + 0.08 * _instPeriod [1]);
				 c12= _instPeriod [1] * 2 / 3;
				 c13=  0.85 * Period [1];
			   }
			
			
			//Smooth.Set ((Input [0] + 2 * Input [1] + 2 * Input [2] + Input [3]) / 6.0);
			
			Smooth.Set ((Input [0] + c1) / 6.0);

			if (CurrentBar < 7)
				//Cycle.Set ((Input [0] - 2 * Input [1] + Input [2]) / 4);
			    Cycle.Set ((Input [0] +c8) / 4);
			else
				Cycle.Set ((s2) * (Smooth [0] +c2) +c3);
				    //(s2) * (Smooth [0] - 2 * Smooth [1] + Smooth [2]) +					
					//(1 - alpha) * 2 * Cycle [1] -	(s1) * Cycle [2]);
                   
			//Q1.Set ((0.0962 * Cycle [0] + 0.5769 * Cycle [2] - 0.5769 * Cycle [4] - 0.0962 * Cycle [6]) * (0.5 + 0.08 * _instPeriod [1]));
			//Q1.Set ((0.0962 * Cycle [0] + c4) * (0.5 + 0.08 * _instPeriod [1]));
			Q1.Set ((0.0962 * Cycle [0] + c4) * (c11));
			I1.Set (Cycle [3]);

			double deltaPhase = 0;
			if (Q1 [0] != 0 && Q1 [1] != 0)
				deltaPhase = (I1 [0] / Q1 [0] - c6) / (1 + I1 [0] * I1 [1] / (Q1 [0] * Q1 [1]));

			if (deltaPhase < 0.1)
				deltaPhase = 0.1;
			else if (deltaPhase > 1.1)
				deltaPhase = 1.1;

			_deltaPhase.Set (deltaPhase);
            if(aMI==null)aMI=MedianIndicator (_deltaPhase, 3);
			//double medianDelta = MedianIndicator (_deltaPhase, 5) [0];
			//medianDelta = aMI[0];
			//double medianDelta = WMA (_deltaPhase, 5) [0];
			//dc = (medianDelta == 0) ? 15 : 0.5 + Math.PI * 2 / medianDelta;
			//dc =( (aMI[0] == 0) ? 15 : 0.5 + Math.PI * 2 / aMI[0]);
            //_instPeriod.Set (dc / 3 + _instPeriod [1] * 2 / 3);
			//_instPeriod.Set (  dc/3   +  c12);
			
			_instPeriod.Set (  ( (aMI[0] == 0) ? 15 : 0.5 + Math.PI * 2 / aMI[0])/3   +  c12);
			//Period.Set (0.15 * _instPeriod [0] + 0.85 * Period [1]);
			//Period.Set (0.15 * _instPeriod [0] + c13);
			_period[0]=(0.15 * _instPeriod [0] + c13); Period[0]=_period[0];
		}
        }
		#region Properties

		[Browsable (false)]
		[XmlIgnore ()]
		public DataSeries Quadrature
		{
			get { return Values [1]; }
		}

		[Browsable (false)]
		[XmlIgnore ()]
		public DataSeries Period
		{
#if SHOW_PERIOD
			get { return Values [2]; }
#else
			get { return _period; }
#endif
		}

		[Browsable (false)]
		[XmlIgnore ()]
		public DataSeries Cycle
		{
			get { return _cycle; }
		}

		[Browsable (false)]
		[XmlIgnore ()]
		public DataSeries Smooth
		{
			get { return _smooth; }
		}

		[Description ("")]
		[Category ("Parameters")]
		public double Alpha
		{
			get { return alpha; }
			set { alpha = Math.Max (0.001, value); }
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
        private HilbertTransform2[] cacheHilbertTransform2 = null;

        private static HilbertTransform2 checkHilbertTransform2 = new HilbertTransform2();

        /// <summary>
        /// Hilbert Transform (from Cybernetic Analysis by John Ehlers)
        /// </summary>
        /// <returns></returns>
        public HilbertTransform2 HilbertTransform2(double alpha)
        {
            return HilbertTransform2(Input, alpha);
        }

        /// <summary>
        /// Hilbert Transform (from Cybernetic Analysis by John Ehlers)
        /// </summary>
        /// <returns></returns>
        public HilbertTransform2 HilbertTransform2(Data.IDataSeries input, double alpha)
        {
            if (cacheHilbertTransform2 != null)
                for (int idx = 0; idx < cacheHilbertTransform2.Length; idx++)
                    if (Math.Abs(cacheHilbertTransform2[idx].Alpha - alpha) <= double.Epsilon && cacheHilbertTransform2[idx].EqualsInput(input))
                        return cacheHilbertTransform2[idx];

            lock (checkHilbertTransform2)
            {
                checkHilbertTransform2.Alpha = alpha;
                alpha = checkHilbertTransform2.Alpha;

                if (cacheHilbertTransform2 != null)
                    for (int idx = 0; idx < cacheHilbertTransform2.Length; idx++)
                        if (Math.Abs(cacheHilbertTransform2[idx].Alpha - alpha) <= double.Epsilon && cacheHilbertTransform2[idx].EqualsInput(input))
                            return cacheHilbertTransform2[idx];

                HilbertTransform2 indicator = new HilbertTransform2();
                indicator.BarsRequired = BarsRequired;
                indicator.CalculateOnBarClose = CalculateOnBarClose;
#if NT7
                indicator.ForceMaximumBarsLookBack256 = ForceMaximumBarsLookBack256;
                indicator.MaximumBarsLookBack = MaximumBarsLookBack;
#endif
                indicator.Input = input;
                indicator.Alpha = alpha;
                Indicators.Add(indicator);
                indicator.SetUp();

                HilbertTransform2[] tmp = new HilbertTransform2[cacheHilbertTransform2 == null ? 1 : cacheHilbertTransform2.Length + 1];
                if (cacheHilbertTransform2 != null)
                    cacheHilbertTransform2.CopyTo(tmp, 0);
                tmp[tmp.Length - 1] = indicator;
                cacheHilbertTransform2 = tmp;
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
        /// Hilbert Transform (from Cybernetic Analysis by John Ehlers)
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator.HilbertTransform2 HilbertTransform2(double alpha)
        {
            return _indicator.HilbertTransform2(Input, alpha);
        }

        /// <summary>
        /// Hilbert Transform (from Cybernetic Analysis by John Ehlers)
        /// </summary>
        /// <returns></returns>
        public Indicator.HilbertTransform2 HilbertTransform2(Data.IDataSeries input, double alpha)
        {
            return _indicator.HilbertTransform2(input, alpha);
        }
    }
}

// This namespace holds all strategies and is required. Do not change it.
namespace NinjaTrader.Strategy
{
    public partial class Strategy : StrategyBase
    {
        /// <summary>
        /// Hilbert Transform (from Cybernetic Analysis by John Ehlers)
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator.HilbertTransform2 HilbertTransform2(double alpha)
        {
            return _indicator.HilbertTransform2(Input, alpha);
        }

        /// <summary>
        /// Hilbert Transform (from Cybernetic Analysis by John Ehlers)
        /// </summary>
        /// <returns></returns>
        public Indicator.HilbertTransform2 HilbertTransform2(Data.IDataSeries input, double alpha)
        {
            if (InInitialize && input == null)
                throw new ArgumentException("You only can access an indicator with the default input/bar series from within the 'Initialize()' method");

            return _indicator.HilbertTransform2(input, alpha);
        }
    }
}
#endregion

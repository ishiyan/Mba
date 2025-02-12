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
    /// Autocorrelation Periodogram from John Ehlers' book, Cycle Analytics for Traders
    /// </summary>
    [Description("Autocorrelation Periodogram from John Ehlers' book, Cycle Analytics for Traders")]
    public class AutocorrelationPeriodogram2 : Indicator
    {
        #region Variables
        // Wizard generated variables
        // User defined variables (add any user defined variables below)
		private const double rtd = Math.PI / 180;
		private int avgLength = 3;
		private double M;
		private int N;
		private double X;
		private double Y;
		private double alpha1;
		private DataSeries HP;
		private double a1;
		private double b1;
		private double c1;
		private double c2;
		private double c3;
		private DataSeries filt;
		private int lag;
		private int count;
		private double Sx;
		private double Sy;
		private double Sxx;
		private double Syy;
		private double Sxy;
		private int period;
		private double Sp;
		private double Spx;
		private double maxPwr;
		private DataSeries dominantCycle;
		private double Color1;
		private double Color2;
		private double Color3;
		private DataSeries corr;
		private DataSeries cosinepart;
		private DataSeries sinepart;
		private DataSeries sqsum;
		private double[,] r;
		private DataSeries pwr;
        #endregion

        /// <summary>
        /// This method is used to configure the indicator and is called once before any bar data is loaded.
        /// </summary>
        protected override void Initialize()
        {
            Add(new Plot(Color.FromKnownColor(KnownColor.Yellow), PlotStyle.Line, "DominantCycle"));
            Overlay				= false;
			CalculateOnBarClose = true;
			
			HP = new DataSeries(this);
			filt = new DataSeries(this);
			dominantCycle = new DataSeries(this);
			corr = new DataSeries(this); 
			cosinepart = new DataSeries(this);
			sinepart = new DataSeries(this);
			sqsum = new DataSeries(this);
			r = new double[2,48];
			pwr = new DataSeries(this);
        }

        /// <summary>
        /// Called on each bar update event (incoming tick)
        /// </summary>
        protected override void OnBarUpdate()
        {
			if (CurrentBar < 10)
			{
				HP.Set(0);
				DominantCycle.Set(0);
				return;
			}
			
			//Highpass filter cyclic components whose periods are shorter than 48 bars
			alpha1 = (Math.Cos(.707*rtd*360 / 48) + Math.Sin(.707*rtd*360 / 48) - 1) / Math.Cos(.707*rtd*360 / 48);
			HP.Set((1 - alpha1 / 2)*(1 - alpha1 / 2)*(Input[0] - 2*Input[1] + Input[2]) + 2*(1 - alpha1)*HP[1] - (1 - alpha1)* (1 - alpha1)*HP[2]);
			
			//Smooth with a Super Smoother Filter from equation 3-3
			a1 = Math.Exp(-1.414*3.14159 / 10);
			b1 = 2*a1*Math.Cos(1.414*rtd*180 / 10);
			c2 = b1;
			c3 = -a1*a1;
			c1 = 1 - c2 - c3;
			filt.Set(c1*(HP[0] + HP[1]) / 2 + c2*filt[1] + c3*filt[2]);
			
			//Pearson correlation for each value of lag
			for (lag = 0; lag <= 48; lag++)
			{
				//Set the averaging length as M
				M = avgLength;
					if (avgLength == 0)
						M = lag;
				Sx = 0;
				Sy = 0;
				Sxx = 0;
				Syy = 0;
				Sxy = 0;
				for (count = 0; count < (M - 1); count++)
				{
					X = filt[count];
					Y = filt[lag + count];
					Sx = Sx + X;
					Sy = Sy + Y;
					Sxx = Sxx + X*X;
					Sxy = Sxy + X*Y;
					Syy = Syy + Y*Y;
				}
				if ((M*Sxx - Sx*Sx)*(M*Syy - Sy*Sy) > 0)
					corr[lag] = (M*Sxy - Sx*Sy)/Math.Sqrt((M*Sxx - Sx*Sx)*(M*Syy - Sy*Sy));
			}
			for (period = 10; period <= 48; period++)
			{
				cosinepart[period] = 0;
				sinepart[period] = 0;
				for (N = 3; N <= 48; N++)
				{
					cosinepart[period] = cosinepart[period] + corr[N]*Math.Cos(rtd*370*N / period);
					sinepart[period] = sinepart[period] + corr[N]*Math.Sin(rtd*370*N / period);
				}
				sqsum[period] = cosinepart[period]*cosinepart[period] + sinepart[period]*sinepart[period];
			}

			for (period = 10; period <= r.GetUpperBound(1); period++)
			{
				r[1,period] = r[0,period];
				r[0,period] = .2*sqsum[period]*sqsum[period] + .8*r[1,period];
			}
			
			maxPwr = .991*maxPwr;
			for (period = 10; period <= r.GetUpperBound(1); period++)
			{		
				if (r[0,period] > maxPwr)
					maxPwr = ((r[0,period]));
			
			}
			
			for (period = 3; period <= r.GetUpperBound(1); period++)
			{
				pwr[period] = r[0,period] / maxPwr;
			}
			
			//Compute the dominant cycle using the CG of the spectrum
			Spx = 0;
			Sp = 0;
			for (period = 10; period <= 48; period++)
			{
				if (pwr[period] >= .5)
				{
					Spx = Spx + period*pwr[period];
					Sp = Sp + pwr[period];
				}
			}
			if (Sp != 0)
				dominantCycle.Set(Spx / Sp);
//			Plot2(DominantCycle, "DC", RGB(0, 0, 255), 0, 2);
//			{
//			//Increase Display Resolution by raising the NormPwr to a
//			//higher mathematical power (optional)
//			For Period = 10 to 48 Begin
//			Pwr[Period] = Power(Pwr[Period], 2);
//			End;

            DominantCycle.Set(dominantCycle[0]);
        }

        #region Properties
        [Browsable(false)]	// this line prevents the data series from being displayed in the indicator properties dialog, do not remove
        [XmlIgnore()]		// this line ensures that the indicator can be saved/recovered as part of a chart template, do not remove
        public DataSeries DominantCycle
        {
            get { return Values[0]; }
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
        private AutocorrelationPeriodogram2[] cacheAutocorrelationPeriodogram2 = null;

        private static AutocorrelationPeriodogram2 checkAutocorrelationPeriodogram2 = new AutocorrelationPeriodogram2();

        /// <summary>
        /// Autocorrelation Periodogram from John Ehlers' book, Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        public AutocorrelationPeriodogram2 AutocorrelationPeriodogram2()
        {
            return AutocorrelationPeriodogram2(Input);
        }

        /// <summary>
        /// Autocorrelation Periodogram from John Ehlers' book, Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        public AutocorrelationPeriodogram2 AutocorrelationPeriodogram2(Data.IDataSeries input)
        {
            if (cacheAutocorrelationPeriodogram2 != null)
                for (int idx = 0; idx < cacheAutocorrelationPeriodogram2.Length; idx++)
                    if (cacheAutocorrelationPeriodogram2[idx].EqualsInput(input))
                        return cacheAutocorrelationPeriodogram2[idx];

            lock (checkAutocorrelationPeriodogram2)
            {
                if (cacheAutocorrelationPeriodogram2 != null)
                    for (int idx = 0; idx < cacheAutocorrelationPeriodogram2.Length; idx++)
                        if (cacheAutocorrelationPeriodogram2[idx].EqualsInput(input))
                            return cacheAutocorrelationPeriodogram2[idx];

                AutocorrelationPeriodogram2 indicator = new AutocorrelationPeriodogram2();
                indicator.BarsRequired = BarsRequired;
                indicator.CalculateOnBarClose = CalculateOnBarClose;
#if NT7
                indicator.ForceMaximumBarsLookBack256 = ForceMaximumBarsLookBack256;
                indicator.MaximumBarsLookBack = MaximumBarsLookBack;
#endif
                indicator.Input = input;
                Indicators.Add(indicator);
                indicator.SetUp();

                AutocorrelationPeriodogram2[] tmp = new AutocorrelationPeriodogram2[cacheAutocorrelationPeriodogram2 == null ? 1 : cacheAutocorrelationPeriodogram2.Length + 1];
                if (cacheAutocorrelationPeriodogram2 != null)
                    cacheAutocorrelationPeriodogram2.CopyTo(tmp, 0);
                tmp[tmp.Length - 1] = indicator;
                cacheAutocorrelationPeriodogram2 = tmp;
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
        /// Autocorrelation Periodogram from John Ehlers' book, Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator.AutocorrelationPeriodogram2 AutocorrelationPeriodogram2()
        {
            return _indicator.AutocorrelationPeriodogram2(Input);
        }

        /// <summary>
        /// Autocorrelation Periodogram from John Ehlers' book, Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        public Indicator.AutocorrelationPeriodogram2 AutocorrelationPeriodogram2(Data.IDataSeries input)
        {
            return _indicator.AutocorrelationPeriodogram2(input);
        }
    }
}

// This namespace holds all strategies and is required. Do not change it.
namespace NinjaTrader.Strategy
{
    public partial class Strategy : StrategyBase
    {
        /// <summary>
        /// Autocorrelation Periodogram from John Ehlers' book, Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator.AutocorrelationPeriodogram2 AutocorrelationPeriodogram2()
        {
            return _indicator.AutocorrelationPeriodogram2(Input);
        }

        /// <summary>
        /// Autocorrelation Periodogram from John Ehlers' book, Cycle Analytics for Traders
        /// </summary>
        /// <returns></returns>
        public Indicator.AutocorrelationPeriodogram2 AutocorrelationPeriodogram2(Data.IDataSeries input)
        {
            if (InInitialize && input == null)
                throw new ArgumentException("You only can access an indicator with the default input/bar series from within the 'Initialize()' method");

            return _indicator.AutocorrelationPeriodogram2(input);
        }
    }
}
#endregion

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Xml.Serialization;
using NinjaTrader.Data;
using NinjaTrader.Gui.Chart;
using NinjaTrader.Gui.Design;
using NinjaTrader.Indicator;

namespace NinjaTrader.Indicator
{
    /// <summary>
    /// John Ehlers Corona Indicators 
    /// ported to NT by sefstrat 
    /// </summary>
    [Description("Corona Dominant Cycle")]
    [Gui.Design.DisplayName(" Corona DominantCycle")]
    public class CoronaCycle : Indicator
    {
        #region Variables

        private bool _showDC;

        private DataSeries _domCyc;
        private DataSeries _domCycMdn;
        private DataSeries _smoothHp;
        private DataSeries _hp;
        private Color[] _colors;
        private Dictionary<int, FilterBank[]> _filters;

        private FilterBank[] bank
        {
            get { return _filters[CurrentBar]; }
        }

        #endregion

        /// <summary>
        /// This method is used to configure the indicator and is called once before any bar data is loaded.
        /// </summary>
        protected override void Initialize()
        {
            Add(new Plot(new Pen(Color.FromArgb(150, 255, 255, 0), 3), "dominant cycle"));

            _filters = new Dictionary<int, FilterBank[]>();

            #region Colors

            _colors = new Color[21]; 
            for (int n = 0; n <= 10; n++) // yellow to red: 0 to 10 dB
                _colors[n] = Color.FromArgb(255, (255-(255*n/10)), 0);
            for (int n = 11; n <= 20; n++) // red to black: 11 to 20 db
                _colors[n] = Color.FromArgb((255*(20-n)/10), 0, 0);

            #endregion

            #region DataSeries

            _domCyc = new DataSeries(this);
            _hp = new DataSeries(this);
            _smoothHp = new DataSeries(this);
            _domCycMdn = new DataSeries(this);

            #endregion

            CalculateOnBarClose = true;
            Overlay = false;
            PriceTypeSupported = false;
        }


        protected override void OnBarUpdate()
        {
            if (CurrentBar < 12) return;

            // Detrend data by High Pass Filtering with a 40 Period cutoff		
            double alpha = (1-Math.Sin(twoPi/30))/Math.Cos(twoPi/30);

            if (CurrentBar == 12)
            {
                FilterBank[] b = new FilterBank[60];
                for (int n = 11; n < 60; n++)
                    b[n] = new FilterBank();
                _filters[12] = b;

                for (int bar = 1; bar < CurrentBar; bar++)
                {
                    _hp[bar] = 0.5*(1+alpha)*Momentum(Input, 1)[bar]+alpha*_hp[bar+1];
                }
            }
            else
            {
                _hp[0] = 0.5*(1+alpha)*Momentum(Input, 1)[0]+alpha*_hp[1];
                FilterBank[] b = new FilterBank[60];
                for (int n = 11; n < 60; n++)
                    b[n] = (FilterBank) _filters[CurrentBar-1][n].Clone();
                _filters[CurrentBar] = b;
            }

            _smoothHp[0] = (_hp[0]+2*_hp[1]+3*_hp[2]+3*_hp[3]+2*_hp[4]+_hp[5])/12;

            double maxAmpl = 0d;
            double delta = -0.015*CurrentBar+0.5;
            delta = delta < 0.1 ? 0.1 : delta;


            for (int n = 11; n < 60; n++)
            {
                double beta = Math.Cos(4*Math.PI/(n+1));
                double gamma = 1/Math.Cos(8*Math.PI*delta/(n+1));
                double a = gamma-Math.Sqrt(gamma*gamma-1);
                bank[n].Q[0] = (_smoothHp[0]-_smoothHp[1])*((n+1)/4/Math.PI);
                bank[n].I[0] = _smoothHp[0];
                bank[n].R[0] = 0.5*(1-a)*(bank[n].I[0]-bank[n].I[2])+beta*(1+a)*bank[n].R[1]-a*bank[n].R[2];
                bank[n].Im[0] = 0.5*(1-a)*(bank[n].Q[0]-bank[n].Q[2])+beta*(1+a)*bank[n].Im[1]-a*bank[n].Im[2];
                bank[n].Amplitude = bank[n].R[0]*bank[n].R[0]+bank[n].Im[0]*bank[n].Im[0];

                maxAmpl = bank[n].Amplitude > maxAmpl ? bank[n].Amplitude : maxAmpl;
            }


            double num = 0;
            double den = 0;
            for (int n = 11; n < 60; n++)
            {
                bank[n].I[2] = bank[n].I[1];
                bank[n].I[1] = bank[n].I[0];
                bank[n].Q[2] = bank[n].Q[1];
                bank[n].Q[1] = bank[n].Q[0];
                bank[n].R[2] = bank[n].R[1];
                bank[n].R[1] = bank[n].R[0];
                bank[n].Im[2] = bank[n].Im[1];
                bank[n].Im[1] = bank[n].Im[0];
                bank[n].dB[1] = bank[n].dB[0];

                if (maxAmpl != 0 && bank[n].Amplitude/maxAmpl > 0)
                {
                    bank[n].dB[0] = -10*Math.Log(.01/(1-0.99*bank[n].Amplitude/maxAmpl))/Math.Log(10);
                }

                bank[n].dB[0] = 0.33*bank[n].dB[0]+0.67*bank[n].dB[1];
                bank[n].dB[0] = bank[n].dB[0] > 20 ? 20 : bank[n].dB[0];

                if (bank[n].dB[0] <= 6)
                {
                    num += n*(20-bank[n].dB[0]);
                    den += (20-bank[n].dB[0]);
                }
                if (den != 0) _domCyc.Set(0.5*num/den);
            }


            _domCycMdn[0] = GetMedian(_domCyc, 5);
            _domCycMdn[0] = _domCyc[0] < 6 ? 6 : _domCyc[0];

            if (_showDC)
                Values[0].Set(_domCyc[0]);
            else
                Values[0].Set(_domCycMdn[0]);
        }

        public override void GetMinMaxValues(ChartControl chartControl, ref double min, ref double max)
        {
            min = 5;
            max = 31;
            return;
        }

        public override void Plot(Graphics graphics, Rectangle bounds, double min, double max)
        {
            drawCorona(graphics, bounds, min, max);
            base.Plot(graphics, bounds, min, max);
        }

        private void drawCorona(Graphics graphics, Rectangle bounds, double min, double max)
        {
            if (base.Bars != null)
            {
                int barPaintWidth = ChartControl.ChartStyle.GetBarPaintWidth(ChartControl.BarWidth);
                SmoothingMode smoothingMode = graphics.SmoothingMode;
                graphics.SmoothingMode = SmoothingMode.AntiAlias;
                int bars = ChartControl.BarsPainted;
                double y1;
                double vscale = bounds.Height/ChartControl.MaxMinusMin(max, min);
                Exception caughtException;
                while (bars >= 0)
                {
                    int index = ChartControl.LastBarPainted-ChartControl.BarsPainted+1+bars;
                    if (ChartControl.ShowBarsRequired || ((index-base.Displacement) >= base.BarsRequired))
                    {
                        try
                        {
                            double x1 = (((ChartControl.CanvasRight-ChartControl.BarMarginRight)-(barPaintWidth/2))
                                         -((base.ChartControl.BarsPainted-1)*base.ChartControl.BarSpace))
                                        +(bars*(base.ChartControl.BarSpace));
                            for (int i = 11; i < 60; ++i)
                            {
                                double v = (i+1)/2;
                                y1 = (bounds.Y+bounds.Height)-(int) ((v-min)*vscale+0.5);
                                double y2 = (bounds.Y+bounds.Height)-(int) ((v+1-min)*vscale+0.5);
                                SolidBrush brush = new SolidBrush(_colors[(int) Math.Round(_filters[index][i].dB[0])]);
                                int width = (int) (barPaintWidth+ChartControl.BarSpaceIntern);
                                graphics.FillRectangle(brush,
                                                       new Rectangle((int) x1-width/2, (int) y2, width,
                                                                     (int) Math.Abs(y1-y2)));
                            }
                        }
                        catch (Exception exception)
                        {
                            caughtException = exception;
                        }
                    }
                    bars--;
                }
                graphics.SmoothingMode = smoothingMode;
            }
        }

        #region Properties

        [Browsable(false)]
        [XmlIgnore]
        public DataSeries DominantCycleMedian
        {
            get { return Values[0]; }
        }

        #endregion

        public const double twoPi = 2*Math.PI;
        public const double fourPi = 4*Math.PI;

        protected class FilterBank : ICloneable
        {
            // current, old, older
            internal double[] I = new double[3];
            internal double[] Q = new double[3];
            internal double[] R = new double[3];
            internal double[] Im = new double[3];
            internal double Amplitude;
            internal double[] dB = new double[2];

            public object Clone()
            {
                FilterBank clone = new FilterBank();

                I.CopyTo(clone.I, 0);
                Q.CopyTo(clone.Q, 0);
                R.CopyTo(clone.R, 0);
                Im.CopyTo(clone.Im, 0);
                clone.Amplitude = Amplitude;
                dB.CopyTo(clone.dB, 0);

                return clone;
            }
        }
    }
}

#region NinjaScript generated code. Neither change nor remove.

// This namespace holds all indicators and is required. Do not change it.

namespace NinjaTrader.Indicator
{
    public partial class Indicator : IndicatorBase
    {
        private CoronaCycle[] cacheCoronaCycle;

        private static CoronaCycle checkCoronaCycle = new CoronaCycle();

        /// <summary>
        /// Corona Dominant Cycle
        /// </summary>
        /// <returns></returns>
        public CoronaCycle CoronaCycle()
        {
            return CoronaCycle(Input);
        }

        /// <summary>
        /// Corona Dominant Cycle
        /// </summary>
        /// <returns></returns>
        public CoronaCycle CoronaCycle(IDataSeries input)
        {
            if (cacheCoronaCycle != null)
                for (int idx = 0; idx < cacheCoronaCycle.Length; idx++)
                    if (cacheCoronaCycle[idx].EqualsInput(input))
                        return cacheCoronaCycle[idx];

            CoronaCycle indicator = new CoronaCycle();
            indicator.BarsRequired = BarsRequired;
            indicator.CalculateOnBarClose = CalculateOnBarClose;
            indicator.Input = input;
            indicator.SetUp();

            CoronaCycle[] tmp = new CoronaCycle[cacheCoronaCycle == null ? 1 : cacheCoronaCycle.Length+1];
            if (cacheCoronaCycle != null)
                cacheCoronaCycle.CopyTo(tmp, 0);
            tmp[tmp.Length-1] = indicator;
            cacheCoronaCycle = tmp;
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
        /// Corona Dominant Cycle
        /// </summary>
        /// <returns></returns>
        [WizardCondition("Indicator")]
        public CoronaCycle CoronaCycle()
        {
            return _indicator.CoronaCycle(Input);
        }

        /// <summary>
        /// Corona Dominant Cycle
        /// </summary>
        /// <returns></returns>
        public CoronaCycle CoronaCycle(IDataSeries input)
        {
            return _indicator.CoronaCycle(input);
        }
    }
}

// This namespace holds all strategies and is required. Do not change it.

namespace NinjaTrader.Strategy
{
    public partial class Strategy : StrategyBase
    {
        /// <summary>
        /// Corona Dominant Cycle
        /// </summary>
        /// <returns></returns>
        [WizardCondition("Indicator")]
        public CoronaCycle CoronaCycle()
        {
            return _indicator.CoronaCycle(Input);
        }

        /// <summary>
        /// Corona Dominant Cycle
        /// </summary>
        /// <returns></returns>
        public CoronaCycle CoronaCycle(IDataSeries input)
        {
            if (InInitialize && input == null)
                throw new ArgumentException(
                    "You only can access an indicator with the default input/bar series from within the 'Initialize()' method");

            return _indicator.CoronaCycle(input);
        }
    }
}

#endregion

using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Xml.Serialization;
using NinjaTrader.Data;
using NinjaTrader.Gui.Chart;

namespace NinjaTrader.Indicator
{
    /// <summary>
    /// John Ehlers Corona Indicators 
    /// ported to NT by sefstrat 
    /// </summary>
    [Description("Corona Swing Position")]
    [Gui.Design.DisplayName(" Corona SwingPosition")]
    public class CoronaSwingPsn : Indicator
    {
        #region Variables
        private DataSeries _domCyc;
        private DataSeries _domCycMdn;
        private DataSeries _smoothHP;
        private DataSeries _highPass;
        private DataSeries _bandPass;

        ArrayList leadList = new ArrayList(51);
        ArrayList posList = new ArrayList(21);

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
	
            Add(new Plot(new Pen(Color.Aquamarine, 3), "Swing"));

            _filters = new Dictionary<int, FilterBank[]>();
            
            #region Colors
            _colors= new Color[21];	
            for (int n = 0; n <= 10; n++)
            {
                int c1 = 180 - (18 * n);
                int c2 = 255 - (8 * n);
                int c3 = 210 - (15 * n);
                _colors[n] = Color.FromArgb(c1, c2, c3);
            }
            for (int n = 11; n <= 20; n++)
            {
                int c2 = (int)(172 * (2 - n / 10d));
                int c3 = (int)(64 * (2 - n / 10d));
                _colors[n] = Color.FromArgb(0, c2, c3);
            }
            #endregion

            #region DataSeries
            _domCyc = new DataSeries(this);
            _highPass = new DataSeries(this);
            _smoothHP = new DataSeries(this);
            _domCycMdn = new DataSeries(this);
            _bandPass = new DataSeries(this);
            #endregion

            CalculateOnBarClose = true;
            Overlay = false;
            PriceTypeSupported = false;
        }


        protected override void OnBarUpdate()
        {
            if (CurrentBar < 12) return;

      
            double alpha = (1 - Math.Sin(twoPi / 30)) / Math.Cos(twoPi / 30);

            if (CurrentBar == 12)
            {           
                FilterBank[] b = new FilterBank[60];
                for (int n = 1; n < 60; n++)
                    b[n] = new FilterBank();
                _filters[12] = b;

                for(int bar = 1; bar < CurrentBar; bar++)
                {
                    _highPass[bar] = 0.5 * (1 + alpha)* Momentum(Input, 1)[bar] + alpha * _highPass[bar+1];
                }
            }
            else
            {
                _highPass[0] = 0.5 * (1 + alpha)* Momentum(Input, 1)[0] + alpha * _highPass[1];
                FilterBank[] b = new FilterBank[60];
                for (int n = 1; n < 60; n++)
                    b[n] = (FilterBank)_filters[CurrentBar - 1][n].Clone();
                _filters[CurrentBar] = b;
            }
				          
            _smoothHP[0] = (_highPass[0] + 2 * _highPass[1] + 3 * _highPass[2] + 3 * _highPass[3] + 2 * _highPass[4] + _highPass[5]) / 12;

            double maxAmpl = 0d;
            double delta = -0.015 * CurrentBar + 0.5;
            delta = delta < 0.1 ? 0.1 : delta;
			
            for (int n = 11; n < 60; n++)
            {
                double beta = Math.Cos(4*Math.PI / (n+1));
                double gamma = 1 / Math.Cos(8*Math.PI * delta / (n+1));
                double a = gamma - Math.Sqrt(gamma * gamma - 1);
                bank[n].Q[0] = (_smoothHP[0] - _smoothHP[1]) * ((n+1)/4/Math.PI);
                bank[n].I[0]= _smoothHP[0];
                bank[n].R[0]= 0.5 * (1 - a) * (bank[n].I[0]- bank[n].I[2]) + beta * (1 + a) * bank[n].R[1] - a * bank[n].R[2];
                bank[n].Im[0] = 0.5 * (1 - a) * (bank[n].Q[0] - bank[n].Q[2]) + beta * (1 + a) * bank[n].Im[1] - a * bank[n].Im[2];
                bank[n].Amplitude = bank[n].R[0]* bank[n].R[0]+ bank[n].Im[0] * bank[n].Im[0];
                maxAmpl = bank[n].Amplitude > maxAmpl ? bank[n].Amplitude : maxAmpl;
            }
			

            double num = 0; double den = 0;
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

                if (maxAmpl != 0 && bank[n].Amplitude / maxAmpl > 0){
                    bank[n].dB[0] = -10 * Math.Log(.01 / (1 - 0.99 * bank[n].Amplitude / maxAmpl)) / Math.Log(10);
                }

                bank[n].dB[0] = 0.33 * bank[n].dB[0] + 0.67 * bank[n].dB[1];
                bank[n].dB[0] = bank[n].dB[0] > 20 ? 20 : bank[n].dB[0];

                if (bank[n].dB[0] <= 6)
                {
                    num += n * (20 - bank[n].dB[0]);
                    den += (20 - bank[n].dB[0]);
                }
                if (den != 0) _domCyc.Set(0.5 * num / den);
            }

            _domCycMdn[0] = GetMedian(_domCyc, 5);
            _domCycMdn[0] = _domCyc[0] < 6 ? 6 : _domCyc[0];


            double delta2 = .1;
            double beta2 = Math.Cos(twoPi / _domCycMdn[0]);
            double g2 = 1 / Math.Cos(fourPi * delta2 / _domCycMdn[0]);
            double alpha2 = g2 - Math.Sqrt(g2 * g2 - 1);
            _bandPass[0] = 0.5 * (1 - alpha2) * (Input[0] - Input[2])
                           + beta2 * (1 + alpha2) * _bandPass[1] - alpha2 * _bandPass[2];
            double Q2 = (_domCycMdn[0] / twoPi) * (_bandPass[0] - _bandPass[1]);
            double lead60 = .5*_bandPass[1]+.866*Q2;
            double HL, LL;
            PhaseList(ref leadList, 50, lead60, out HL, out LL);
            double Psn = (lead60 - LL) / (HL - LL);
            PhaseList(ref posList, 20, Psn, out HL, out LL);

            double cWidth = HL-LL > 0.85 ? 0.01 : 0.15*(HL-LL);
            

            Value.Set( 10 * Psn - 5d);

            int psn50 = (int)Math.Round(50 * Psn);

            for (int n = 1; n < 51; n++)
            {
                bank[n].Raster[1] = bank[n].Raster[0]; 
                bank[n].Raster[0] = 20d;
                if (n < psn50) 
                    bank[n].Raster[0] = 0.5 * (Math.Pow((20 * Psn - 0.4 * n) / cWidth, 0.95) + 0.5 * bank[n].Raster[1]);
                else if (n > psn50 && (0.4*n-20*Psn)/cWidth > 1) 
                    bank[n].Raster[0] = 0.5 * (Math.Pow((-20 * Psn + 0.4 * n) / cWidth, 0.95) + 0.5 * bank[n].Raster[1]);
                else if (n == psn50)
                    bank[n].Raster[0] = 0.5 * bank[n].Raster[1];
                if (bank[n].Raster[0] > 20) bank[n].Raster[0] = 20;
                else if (bank[n].Raster[0] < 0) bank[n].Raster[0] = 0;
                if (HL - LL > 0.8) bank[n].Raster[0] = 20;
            }
        }

        // Keep cntMax fifo samples and find the Highest and Lowest lead for samples in the list
        private void PhaseList(ref ArrayList list, int cntMax, double lead, out double H, out double L)
        {
            H = lead; L = lead;
            if (list.Count < cntMax)
                list.Add(lead);
            else
            {
                list.RemoveAt(0);
                list.Add(lead);
            }
            for (int n = 0; n < list.Count - 1; n++)
            {
                double val = (double)list[n];
                if (val > H) H = val;
                if (val < L) L = val;
            }
        }
        public override void GetMinMaxValues(ChartControl chartControl, ref double min, ref double max)
        {
            min = -5;
            max = 5;
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
                double vscale = bounds.Height / ChartControl.MaxMinusMin(max, min);
                Exception caughtException;
                while (bars >= 0)
                {
                    int index = ChartControl.LastBarPainted - ChartControl.BarsPainted + 1 + bars;
                    if (ChartControl.ShowBarsRequired || ((index - base.Displacement) >= base.BarsRequired))
                    {
                        try
                        {
                            double x1 = (((ChartControl.CanvasRight - ChartControl.BarMarginRight) - (barPaintWidth / 2))
                                         - ((base.ChartControl.BarsPainted - 1) * base.ChartControl.BarSpace))
                                        + (bars * (base.ChartControl.BarSpace));
                            for (int i = 1; i < 51; ++i)
                            {
                                double v = .2*i-5;// -.5 * .2;
                                y1 = (bounds.Y + bounds.Height) - (int)((v - min) * vscale + 0.5);
                                double y2 = (bounds.Y + bounds.Height) - (int)((v + 1 - min) * vscale + 0.5);
                                SolidBrush brush = new SolidBrush(_colors[(int) Math.Round(_filters[index][i].Raster[0])]);
                                int width = (int)(barPaintWidth + ChartControl.BarSpaceIntern);
                                graphics.FillRectangle(brush, new Rectangle((int)x1 - width / 2, (int)y2, width, (int)Math.Abs(y1 - y2)));
                                
                            }
                        }
                        catch (Exception exception) { caughtException = exception; }
                    }
                    bars--;
                }

                graphics.SmoothingMode = smoothingMode;
            }
        }


        #region Properties
		
        [Browsable(false)]
        [XmlIgnore()]
        public DataSeries SwingPsn
        {
            get { return Values[0]; }
        }

        #endregion
    
        public const double twoPi = 2 * Math.PI;
        public const double fourPi = 4 * Math.PI;
		
        protected class FilterBank : ICloneable
        {	// current, old, older
            internal double[] I = new double[3];  
            internal double[] Q = new double [3];
            internal double[] R = new double [3];
            internal double[] Im = new double[3];
            internal double Amplitude = 0;
            internal double[] dB = new double[2];
            internal double[] Raster = new double[2];

            public object Clone()
            {
                FilterBank clone = new FilterBank();

                I.CopyTo(clone.I, 0);
                Q.CopyTo(clone.Q, 0);
                R.CopyTo(clone.R, 0);
                Im.CopyTo(clone.Im, 0);
                clone.Amplitude = Amplitude;
                dB.CopyTo(clone.dB, 0);
                Raster.CopyTo(clone.Raster, 0);

                return clone;
            }
        }
    }
}
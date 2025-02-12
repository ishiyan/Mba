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
    /// Ehlers Filter by John Elher
    /// </summary>
    [Description("Ehlers Filter.  It is recommend that you use the Price Type of Median.")]
    public class EhlersFilter : Indicator
    {
        #region Variables
        // Wizard generated variables
            private int length = 20; // Default setting for Length
        // User defined variables (add any user defined variables below)
            private DataSeries Smooth;
            private DataSeries Coef;        //defined as an array in EL code
            private DataSeries Distance2;    //defined as an array in EL code
            private int count;        //loop index
            private int lookback;    //loop index
            private double Num = 0.00;
            private double SumCoef = 0.00;
        #endregion

        /// <summary>
        /// This method is used to configure the indicator and is called once before any bar data is loaded.
        /// </summary>
        protected override void Initialize()
        {
            Add(new Plot(Color.FromKnownColor(KnownColor.PaleTurquoise), PlotStyle.Line, "EF"));
            CalculateOnBarClose    = true;
            Overlay                = true;
            PriceTypeSupported    = true;        // one should select Median.
            Smooth = new DataSeries(this);
            Coef = new DataSeries(this);
            Distance2 = new DataSeries(this); 
        }

        /// <summary>
        /// Called on each bar update event (incoming tick)
        /// </summary>
        protected override void OnBarUpdate()
        {
            // 
            Smooth.Set( (Input[0] + 2*Input[1] + 2*Input[2] + Input[3]) / 6.0);
            for ( count = 0; count <= length -1; count++)
            {
                Distance2.Set( 0.00);
                for ( lookback = 1; lookback <= length -1; lookback++)
                {
                    Distance2.Set( Distance2[count] + (Smooth[count] -    Smooth[count + lookback])*(Smooth[count] - Smooth[count + lookback]) );
                }
                Coef.Set( count, Distance2[count] );
            }
            Num = 0.0;
            SumCoef = 0.0;
            for ( count = 0; count <= length -1; count++)
            {
                Num = Num + Coef[count]*Smooth[count];
                SumCoef =  SumCoef + Coef[count];
            }
            if( SumCoef != 0) EF.Set( Num / SumCoef  );
        }

        #region Properties
        [Browsable(false)]    // this line prevents the data series from being displayed in the indicator properties dialog, do not remove
        [XmlIgnore()]        // this line ensures that the indicator can be saved/recovered as part of a chart template, do not remove
        public DataSeries EF
        {
            get { return Values[0]; }
        }

        [Description("Length")]
        [Category("Parameters")]
        public int Length
        {
            get { return length; }
            set { length = Math.Max(1, value); }
        }
        #endregion
    }
}


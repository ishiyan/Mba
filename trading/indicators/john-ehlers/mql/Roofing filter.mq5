//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Roofing filter"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average     // Average (high+low+oprn+close)/4
};

input enPrices Price = pr_close;     // Price to use
double rf[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define Pi 3.14159265358979323846264338327950288
double c1,c2,c3;
int OnInit()
{
   SetIndexBuffer(0,rf,INDICATOR_DATA); 
      double a1 = MathExp(-1.414*Pi/10.0);
      double b1 = 2.0*a1*MathCos(1.414*Pi/10.0);
             c2 = b1;
             c3 = -a1*a1;
             c1 = 1.0 - c2 - c3;
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double work[][2];
#define _price 0
#define _hp    1

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
    if (ArrayRange(work,0)!= rates_total) ArrayResize(work,rates_total);

   //
   //
   //
   //
   //

   double modif = 2.0*Pi/48.0;
   double alpha = (MathCos(0.707*modif) + MathSin(0.707*modif)-1)/MathCos(0.707*modif);

   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      work[i][_price] = getPrice(Price,open,close,high,low,i,rates_total);
      if (i<3)
      {
            work[i][_hp] = 0;
            rf[i]        = 0;
      }            
      else  
      {
         work[i][_hp] = (1.0-alpha/2.0)*(1.0-alpha/2.0)*(work[i][_price]-2.0*work[i-1][_price]+work[i-2][_price])+2.0*(1-alpha)*work[i-1][_hp]-(1-alpha)*(1-alpha)*work[i-2][_hp];      
                rf[i] = c1*(work[i][_hp]+work[i-1][_hp])/2.0 + c2*rf[i-1] + c3*rf[i-2];
      }         
   }
   return(rates_total);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double getPrice(enPrices price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars)
{
   switch (price)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
   }
   return(0);
}
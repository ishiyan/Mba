//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  LimeGreen
#property indicator_color2  Orange
#property indicator_color3  Orange
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_level1  0.2
#property indicator_level2  0.8

//
//
//
//
//

extern int    Length       = 50;
extern int    Price        =  PRICE_CLOSE;
extern double SmoothPeriod = 20;
double sto[];
double stoda[];
double stodb[];
double slope[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define Pi 3.14159265358979323846264338327950288
double c1,c2,c3;
int init()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,sto);
   SetIndexBuffer(1,stoda);
   SetIndexBuffer(2,stodb);
   SetIndexBuffer(3,slope);
      double a1 = MathExp(-1.414*Pi/SmoothPeriod);
      double b1 = 2.0*a1*MathCos(1.414*Pi/SmoothPeriod);
             c2 = b1;
             c3 = -a1*a1;
             c1 = 1.0 - c2 - c3;
   IndicatorShortName ("roofing stochastic ("+Length+")");
   return(0);
}
int deinit() { return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double work[][4];
#define _price 0
#define _hp    1
#define _rf    2
#define _sto   3

int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (ArrayRange(work,0)!= Bars) ArrayResize(work,Bars);

   //
   //
   //
   //
   //
   //

   double modif = 2.0*Pi/48.0;
   double alpha = (MathCos(0.707*modif) + MathSin(0.707*modif)-1)/MathCos(0.707*modif);
   
   if (slope[limit] == -1) CleanPoint(limit,stoda,stodb);
   for(i=limit, r =Bars-i-1; i >= 0; i--,r++)
   {
      work[r][_price] = iMA(NULL,0,1,0,MODE_SMA,Price,i);
      work[r][_hp]    = (1.0-alpha/2.0)*(1.0-alpha/2.0)*(work[r][_price]-2.0*work[r-1][_price]+work[r-2][_price])+2.0*(1-alpha)*work[r-1][_hp]-(1-alpha)*(1-alpha)*work[r-2][_hp];
      work[r][_rf]    = c1*(work[r][_hp]+work[r-1][_hp])/2.0 + c2* work[r-1][_rf] + c3*work[r-2][_rf];
      work[r][_sto]   = 0;
      
         double min   = work[r][_rf];
         double max   = work[r][_rf];
         double stoch = 0;
         for (int k = 1; k<Length; k++)
         {
            min = MathMin(work[r-k][_rf],min);
            max = MathMax(work[r-k][_rf],max);
         }
         
      if (min!=max) work[r][_sto] = (work[r][_rf]-min)/(max-min);
      sto[i]   = c1*(work[r][_sto]+work[r-1][_sto])/2.0 + c2*sto[i+1] + c3*sto[i+2];
      stoda[i] = EMPTY_VALUE;
      stodb[i] = EMPTY_VALUE;
      slope[i] = slope[i+1];
         if (sto[i]>sto[i+1]) slope[i] =  1;
         if (sto[i]<sto[i+1]) slope[i] = -1;
         if (slope[i] == -1) PlotPoint(i,stoda,stodb,sto);
   }         
   return(0);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
}
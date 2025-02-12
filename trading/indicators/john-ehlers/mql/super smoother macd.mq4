//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  LimeGreen
#property indicator_color2  Orange
#property indicator_color3  Orange
#property indicator_color4  Gold
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_style4  STYLE_DOT

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern double FastLength      =  24;
extern double SlowLength      =  52;
extern double SignalLength    =  18;
extern int    Price           =  PRICE_CLOSE;

double ssm[];
double ssmda[];
double ssmdb[];
double signal[];
double slope[];


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,ssm);
   SetIndexBuffer(1,ssmda);
   SetIndexBuffer(2,ssmdb);
   SetIndexBuffer(3,signal);
   SetIndexBuffer(4,slope);
      IndicatorShortName ("super smoother MACD ("+DoubleToStr(FastLength,1)+","+DoubleToStr(SlowLength,1)+","+DoubleToStr(SignalLength,1)+")");
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

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //
   //

      if (slope[limit]==-1) CleanPoint(limit,ssmda,ssmdb);
      for(int i=limit; i >= 0; i--)
      {
         ssm[i]    = iSsm(iMA(NULL,0,1,0,MODE_SMA,Price,i),FastLength,i,0)-iSsm(iMA(NULL,0,1,0,MODE_SMA,Price,i),SlowLength,i,1);
         signal[i] = iSsm(ssm[i],SignalLength,i,2);
         ssmda[i]  = EMPTY_VALUE;
         ssmdb[i]  = EMPTY_VALUE;
         slope[i]  = slope[i+1];
            if (ssm[i]>signal[i]) slope[i] =  1;
            if (ssm[i]<signal[i]) slope[i] = -1;
            if (slope[i] == -1) PlotPoint(i,ssmda,ssmdb,ssm);
      }   
      return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workSsm[][6];
#define _price  0
#define _ssm    1

double workSsmCoeffs[][4];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define Pi 3.14159265358979323846264338327950288

//
//
//
//
//

double iSsm(double price, double period, int i, int instanceNo)
{
   if (ArrayRange(workSsm,0) !=Bars)                 ArrayResize(workSsm,Bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_period] != period)
   {
      workSsmCoeffs[instanceNo][_period] = period;
      double a1 = MathExp(-1.414*Pi/period);
      double b1 = 2.0*a1*MathCos(1.414*Pi/period);
         workSsmCoeffs[instanceNo][_c2] = b1;
         workSsmCoeffs[instanceNo][_c3] = -a1*a1;
         workSsmCoeffs[instanceNo][_c1] = 1.0 - workSsmCoeffs[instanceNo][_c2] - workSsmCoeffs[instanceNo][_c3];
   }

   //
   //
   //
   //
   //

      i = Bars-i-1;
      int s = instanceNo*2;   
          workSsm[i][s+_price] = price;
          workSsm[i][s+_ssm]   = workSsmCoeffs[instanceNo][_c1]*(workSsm[i][s+_price]+workSsm[i-1][s+_price])/2.0 + 
                                 workSsmCoeffs[instanceNo][_c2]*workSsm[i-1][s+_ssm]                              + 
                                 workSsmCoeffs[instanceNo][_c3]*workSsm[i-2][s+_ssm];
   return(workSsm[i][s+_ssm]);
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
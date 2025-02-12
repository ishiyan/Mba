//+------------------------------------------------------------------+
//|                                                     smoothed rsi |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers  5
#property indicator_color1   Gray
#property indicator_color2   LimeGreen
#property indicator_color3   LimeGreen
#property indicator_color4   Orange
#property indicator_color5   Orange
#property indicator_width2   3
#property indicator_width3   3
#property indicator_width4   3
#property indicator_width5   3
#property indicator_minimum  0
#property indicator_maximum  100

//
//
//
//
//

extern int    Length            = 14;
extern int    Price             = PRICE_CLOSE;
extern double LevelUp           = 70;
extern double LevelDown         = 30;
extern double SmoothLength      = 10;
//
//
//
//
//

double rsi[];
double rsiUa[];
double rsiUb[];
double rsiDa[];
double rsiDb[];
double prc[];
double trend[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(7);
      SetIndexBuffer(0,rsi);
      SetIndexBuffer(1,rsiUa);
      SetIndexBuffer(2,rsiUb);
      SetIndexBuffer(3,rsiDa);
      SetIndexBuffer(4,rsiDb);
      SetIndexBuffer(5,prc);
      SetIndexBuffer(6,trend);
         Length = MathMax(Length ,1);
         string PriceType;
         switch(Price)
         {
            case PRICE_CLOSE:    PriceType = "Close";    break;  // 0
            case PRICE_OPEN:     PriceType = "Open";     break;  // 1
            case PRICE_HIGH:     PriceType = "High";     break;  // 2
            case PRICE_LOW:      PriceType = "Low";      break;  // 3
            case PRICE_MEDIAN:   PriceType = "Median";   break;  // 4
            case PRICE_TYPICAL:  PriceType = "Typical";  break;  // 5
            case PRICE_WEIGHTED: PriceType = "Weighted"; break;  // 6
         }      

   //
   //
   //
   //
   //

   SetLevelValue(0,LevelUp);
   SetLevelValue(1,LevelDown);
      string addName = "";
         if (SmoothLength>1) addName = "smoothed ";
   IndicatorShortName("RSI "+addName+"("+Length+","+PriceType+")");
   return(0);
}


int deinit()
{
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

      if (trend[limit]== 1) CleanPoint(limit,rsiUa,rsiUb);
      if (trend[limit]==-1) CleanPoint(limit,rsiDa,rsiDb);
      for(int i=limit; i >= 0; i--)
      {
         double price = iMA(NULL,0,1,0,MODE_SMA,Price,i);
            if (SmoothLength>1)
                  price  = iSsm(price,SmoothLength,i);
                  prc[i] = price;
         if (i>=Bars-Length) continue;
      
         //
         //
         //
         //
         //
      
         double cu = 0;
         double cd = 0;
         for (int k=0; k<Length; k++)
            {
               double diff = prc[i+k]-prc[i+k+1];
                  if (diff > 0)
                        cu += diff;
                  else  cd -= diff;
            }
         if ((cu+cd)!=0)
               rsi[i] = 50.0*((cu-cd)/(cu+cd)+1.0);
         else  rsi[i] = 0;
         rsiUa[i] = EMPTY_VALUE;
         rsiUb[i] = EMPTY_VALUE;
         rsiDa[i] = EMPTY_VALUE;
         rsiDb[i] = EMPTY_VALUE;

         //
         //
         //
         //
         //
         
         trend[i] = trend[i+1];
            if (rsi[i]>LevelUp)                     trend[i]= 1;
            if (rsi[i]<LevelDown)                   trend[i]=-1;
            if (rsi[i]<LevelUp && rsi[i]>LevelDown) trend[i]= 0;
            if (trend[i] ==  1) PlotPoint(i,rsiUa,rsiUb,rsi);
            if (trend[i] == -1) PlotPoint(i,rsiDa,rsiDb,rsi);
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workSsm[][2];
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

double iSsm(double price, double period, int i, int instanceNo=0)
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
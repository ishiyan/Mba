//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  LimeGreen
#property indicator_color2  Orange
#property indicator_color3  Orange
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

//
//
//
//
//

extern int    Price       =  PRICE_CLOSE;
extern double Length      =  20;
extern int    AdaptPeriod =  15;

double ssm[];
double ssmda[];
double ssmdb[];
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
   IndicatorBuffers(4);
   SetIndexBuffer(0,ssm);
   SetIndexBuffer(1,ssmda);
   SetIndexBuffer(2,ssmdb);
   SetIndexBuffer(3,slope);
   IndicatorShortName ("super smoother");
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
      double dev = iStdDev(NULL,0,AdaptPeriod,0,MODE_SMA,Price,i);
      double avg = iSma(dev,AdaptPeriod,i,0);
         if (dev!=0) 
                double period = Length*avg/dev;
         else          period = Length; 
         if (period<3) period = 3;
         ssm[i] = iSsm(iMA(NULL,0,1,0,MODE_SMA,Price,i),period,i,0);
           
         //
         //
         //
         //
         //
                 
         ssmda[i] = EMPTY_VALUE;
         ssmdb[i] = EMPTY_VALUE;
         slope[i] = slope[i+1];
            if (ssm[i]>ssm[i+1]) slope[i] =  1;
            if (ssm[i]<ssm[i+1]) slope[i] = -1;
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

double workSma[][2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); instanceNo *= 2; r = Bars-r-1;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo] = price;
   if (r>=period)
          workSma[r][instanceNo+1] = workSma[r-1][instanceNo+1]+(workSma[r][instanceNo]-workSma[r-period][instanceNo])/period;
   else { workSma[r][instanceNo+1] = 0; for(int k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
          workSma[r][instanceNo+1] /= k; }
   return(workSma[r][instanceNo+1]);
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
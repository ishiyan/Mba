//------------------------------------------------------------------
//
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers    5
#property indicator_color1     Goldenrod
#property indicator_color2     Lime
#property indicator_color3     Lime
#property indicator_color4     Red
#property indicator_color5     Red
#property indicator_minimum    -1.05
#property indicator_maximum    1.05
#property indicator_levelcolor MediumOrchid

//
//
//
//
//

extern string TimeFrame   = "Current time frame";
extern int    WprPeriod   = 5;
extern int    MA_Period   = 9;
extern int    MA_Method   = 3;
extern int    AdaptPeriod = 15;
extern int    AdaptPrice  = PRICE_CLOSE;
extern double levelOb     = 0.5;
extern double levelOs     = -0.5;

//
//
//
//
//

double wpr[];
double iFish[];
double iFishua[];
double iFishub[];
double iFishda[];
double iFishdb[];
double state[];

string indicatorFileName;
int    timeFrame;
bool   returnBars;
bool   calculateValue;

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
   IndicatorBuffers(7);
   SetIndexBuffer(0,iFish); 
   SetIndexBuffer(1,iFishua); 
   SetIndexBuffer(2,iFishub); 
   SetIndexBuffer(3,iFishda); 
   SetIndexBuffer(4,iFishdb); 
   SetIndexBuffer(5,wpr);
   SetIndexBuffer(6,state);
   SetLevelValue(0, levelOs);
   SetLevelValue(1, levelOb);
   SetLevelValue(2, 0);
        indicatorFileName = WindowExpertName();
        calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
        returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
        timeFrame         = stringToTimeFrame(TimeFrame);
   IndicatorShortName(timeFrameToString(timeFrame)+" ift of wpr ("+WprPeriod+","+MA_Period+")" );
   return(0); 
}  
int deinit() { return(0); } 


//+------------------------------------------------------------------+ 
//| Custom indicator iteration function | 
//+------------------------------------------------------------------+ 
int start() 
{ 
   int i,counted_bars = IndicatorCounted(); 
      if (counted_bars < 0) return(-1); 
      if (counted_bars > 0) counted_bars--;  
         int limit=MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { iFish[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
      
   if (calculateValue || timeFrame==Period())
   {
      if (state[limit] ==  1) ClearPoint(limit,iFishua,iFishub);
      if (state[limit] == -1) ClearPoint(limit,iFishda,iFishdb);
      for (i= limit; i >= 0; i--)
      {
          double dev = iStdDev(NULL,0,AdaptPeriod,0,MODE_SMA,AdaptPrice,i);
          double avg = iSma(dev,AdaptPeriod,i,0);
          if (dev!=0) 
                double period = WprPeriod*avg/dev;
          else         period = WprPeriod; 
          if (period<3) period = 3;
         
          
          //
          //
          //
          //
          //
          
          double hi = High[iHighest(NULL,0,MODE_HIGH,WprPeriod,i)];
          double lo =  Low[iLowest(NULL,0, MODE_LOW, WprPeriod,i)]; 
          if (hi!=lo)
               wpr[i] = iSsm(50 +(-100)*(hi - Close[i]) /(hi - lo),period,i,0)*0.1;
          else wpr[i] = iSsm(0,                                    period,i,0)*0.1;         
        
          double MA = iMAOnArray(wpr,0,MA_Period,0,MA_Method,i); 
          iFish[i]  = (MathExp(2.0*MA)-1.0)/(MathExp(2.0*MA)+1.0);
          iFishua[i] = EMPTY_VALUE;
          iFishub[i] = EMPTY_VALUE;
          iFishda[i] = EMPTY_VALUE;
          iFishdb[i] = EMPTY_VALUE;
          state[i]   = 0;
             if (iFish[i]>levelOb) state[i] =  1;
             if (iFish[i]<levelOs) state[i] = -1;
             if (state[i] ==  1) PlotPoint(i,iFishua,iFishub,iFish);
             if (state[i] == -1) PlotPoint(i,iFishda,iFishdb,iFish);
     }
     return(0); 
    }
    
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (state[limit] ==  1) ClearPoint(limit,iFishua,iFishub);
   if (state[limit] == -1) ClearPoint(limit,iFishda,iFishdb);
   for (i=limit;i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
        iFish[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",WprPeriod,MA_Period,MA_Method,AdaptPeriod,AdaptPrice,levelOb,levelOs,0,y);
        state[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",WprPeriod,MA_Period,MA_Method,AdaptPeriod,AdaptPrice,levelOb,levelOs,6,y);
        iFishua[i] = EMPTY_VALUE;
        iFishub[i] = EMPTY_VALUE;
        iFishda[i] = EMPTY_VALUE;
        iFishdb[i] = EMPTY_VALUE;
   }
   for (i=limit;i>=0;i--)
   {
      if (state[i] ==  1) PlotPoint(i,iFishua,iFishub,iFish);
      if (state[i] == -1) PlotPoint(i,iFishda,iFishdb,iFish);
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
   if (period<=1) return(price);
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void ClearPoint(int i,double& first[],double& second[])
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
      if (first[i+2] == EMPTY_VALUE) 
      {
          first[i]    = from[i];
          first[i+1]  = from[i+1];
          second[i]   = EMPTY_VALUE;
      }
      else
      {
          second[i]   = from[i];
          second[i+1] = from[i+1];
          first[i]    = EMPTY_VALUE;
      }
   }
   else
   {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
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
//

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
return(s);
}




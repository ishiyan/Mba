//+------------------------------------------------------------------+
//|                                                           rsiSS  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers    4
#property indicator_color1     LimeGreen
#property indicator_color2     Red
#property indicator_color3     Red
#property indicator_color4     White
#property indicator_width1     2
#property indicator_width2     2
#property indicator_width3     2
#property indicator_style4     STYLE_DASH
#property indicator_levelcolor MediumOrchid

//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern int    RsiSS_Period    = 10;
extern int    RsiSS_Price     = 0;
extern int    MaPeriod        = 7;
extern int    MaType          = MODE_LWMA;

extern double levelOb         = 80;
extern double levelOs         = 20;

extern bool   alertsOn        = true;
extern bool   alertsOnSlope   = false;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

//
//
//
//
//

double rsi[];
double rsida[];
double rsidb[];
double ma[];
double mab[];
double trend[];
double slope[];

//
//
//
//
//

string indicatorFileName;
int    timeFrame;
bool   returnBars;
bool   calculateValue;

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
    SetIndexBuffer(1,rsida);
    SetIndexBuffer(2,rsidb);
    SetIndexBuffer(3,ma);
    SetIndexBuffer(4,mab);
    SetIndexBuffer(5,trend);
    SetIndexBuffer(6,slope);
    SetLevelValue(0,levelOs);
    SetLevelValue(1,levelOb);
    
       //
       //
       //
       //
       //
     
        indicatorFileName = WindowExpertName();
        calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
        returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
        timeFrame         = stringToTimeFrame(TimeFrame);
 
   IndicatorShortName(timeFrameToString(timeFrame)+"  rsi_super smooth("+RsiSS_Period+","+MaPeriod+")");
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
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { rsi[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame==Period())
   {

     if  (slope[limit] == -1) ClearPoint(limit,rsida,rsidb);
     for (i=limit; i >= 0; i--) mab[i] = iSsm(iMA(NULL,0,1,0,MODE_SMA,RsiSS_Price,i),RsiSS_Period,i,0);
     for (i=limit; i >= 0; i--) rsi[i] = iRSIOnArray(mab,0,RsiSS_Period,i);
     for (i=limit; i >= 0; i--)
     {
        ma[i] = iMAOnArray(rsi,0,MaPeriod,0,MaType,i);
        rsida[i] = EMPTY_VALUE;
        rsidb[i] = EMPTY_VALUE;
        slope[i] = slope[i+1];
        trend[i] = trend[i+1]; 
         
	     if (rsi[i] > rsi[i+1]) slope[i]= 1; 
	     if (rsi[i] < rsi[i+1]) slope[i]=-1;
	     if (rsi[i] > ma[i])    trend[i]= 1; 
	     if (rsi[i] < ma[i])    trend[i]=-1;
	     if (slope[i] == -1)    PlotPoint(i,rsida,rsidb,rsi);
	       
     }
     manageAlerts();  
    return(0);
    }
    
    //
    //
    //
    //
    //
   
    limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
    if (slope[limit]==-1) ClearPoint(limit,rsida,rsidb);
    for (i=limit;i>=0; i--)
    {
       int y = iBarShift(NULL,timeFrame,Time[i]);
            rsi[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiSS_Period,RsiSS_Price,MaPeriod,MaType,0,y);
            rsida[i] = EMPTY_VALUE;
            rsidb[i] = EMPTY_VALUE;
            ma[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiSS_Period,RsiSS_Price,MaPeriod,MaType,3,y);
            trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiSS_Period,RsiSS_Price,MaPeriod,MaType,5,y);
            slope[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",RsiSS_Period,RsiSS_Price,MaPeriod,MaType,6,y);
            
            //
            //
            //
            //
            //
     
    }  
    for (i=limit;i>=0;i--) if (slope[i]==-1) PlotPoint(i,rsida,rsidb,rsi);
    manageAlerts();
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

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

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

//
//
//
//
//

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
      int char = StringGetChar(s, length);
         if((char > 96 && char < 123) || (char > 223 && char < 256))
                     s = StringSetChar(s, length, char - 32);
         else if(char > -33 && char < 0)
                     s = StringSetChar(s, length, char + 224);
   }
return(s);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      
      //
      //
      //
      //
      //
      
      if (alertsOnSlope)
      {
         if (slope[whichBar] != slope[whichBar+1])
         {
            if (slope[whichBar] == 1) doAlert(whichBar,"slope changed to up");
            if (slope[whichBar] ==-1) doAlert(whichBar,"slope changed to down");
         }         
      }
      else
      {
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] == 1) doAlert(whichBar,"crossed ma line up");
            if (trend[whichBar] ==-1) doAlert(whichBar,"crossed ma line down");
         }         
      }         
   }
}   

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Rsi super smooth ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Rsi super smooth"),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}



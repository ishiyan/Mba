/*
For the work of indicator should be placed the files
JJMASeries.mqh 
PriceSeries.mqh 
in the folder (directory): MetaTrader\.experts\.include \
Heiken Ashi#.mq4
in the folder (directory): MetaTrader\.indicators \
*/
//+------------------------------------------------------------------+  
//|                                             JMoving Avereges.mq4 | 
//|       JMoving Avereges: Copyright  2006-07,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright  2006-07, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//otrisovka of indicator in the main window
#property indicator_chart_window 
//a quantity of the indicator buffers
#property indicator_buffers 1 
//the color of the indicator
#property indicator_color1 Purple 

//THE INPUT PARAMETERS OF THE INDICATOR OF--------------------------------------------------------------------------------------------------
extern string note1 = "Jurik Moving Average";
extern int MA_period = 130; //the depth of the first smoothing
extern string note2 = "0=Simple,1=Exponential";
extern string note3 = "2=Smooth,3=Linear Weighted";
extern int MA_method = 1; //the method of the averaging

extern string note11 = "---------------------------------------------";
extern string note12 = "the depth of the smoothing";
extern int Smooth = 4; //the depth of the smoothing
extern string note13 = "influence the quality of transient process";
extern int Smooth_Phase = 100;///the parameter of smoothing, which ischanged within limits of -100... 100, influence the quality oftransient process;
extern string note14 = "cdvig indicator along the time axis";
extern int Shift = 0; //cdvig indicator along the time axis

extern string note15 = "---------------------------------------------";
extern string note16 = "0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW";
extern string note17 = "4-MEDIAN, 5-TYPICAL, 6-WEIGHTED";
extern string note18 = "7-Heiken Ashi Med, 8-SIMPLE, 9-TRENDFOLLOW";
extern string note19 = "10-TRENDFOLLOW";
extern string note20 = "11-Heiken Ashi Low, 12-Heiken Ashi High";
extern string note21 = "13-Heiken Ashi Open, 14-Heiken Ashi Close";
extern int Input_Price_Customs = 0; //Vybor of prices, on which isproduced the calculation of the indicator
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)

extern string note31 = "---------------------------------------------";
extern string note32 = "change color in the Colors area too";
extern color MAcolor1 = Purple;
extern string note33 = "Display the info in what corner?";
extern string note34 = "Upper left=0; Upper right=1";
extern string note35 = "Lower left=2; Lower right=3";
extern int    WhatCorner=1;
extern string note36 = "Y distance; add 10 to each MA";
extern int    ydistance1=250;
//---- -------------------------------------------------------------------------------------------------------------------------------+
//the indicator buffers
double Series_buffer[];
double JMovingBuffer[];
//variables with the floating point
double Temp_Series,Resalt;
string objectma1;
//+------------------------------------------------------------------+  
//introduction to function JJMASeries
//introduction to function JJMASeriesResize
//introduction to function JJMASeriesAlert
//introduction to function JMA_.ErrDescr
#include <JJMASeries.mqh> 
//+------------------------------------------------------------------+  
//introduction to function PriceSeries
//introduction to function PriceSeriesAlert
#include <PriceSeries.mqh>
//+------------------------------------------------------------------+
string IntToStr(int X)
  {
    return (DoubleToStr(X, 0));
  }
//+------------------------------------------------------------------+
int deinit()
  {
  ObjectDelete(objectma1);  
  return(0);
  }
//+------------------------------------------------------------------+ 
//| JMoving Avereges initialization function                         | 
//+------------------------------------------------------------------+  
int init() 
{  
   int    ydistance2;
   string short_name;
//the determination of the style of the performance of the graph
SetIndexStyle (0,DRAW_LINE); 
//2 indicator buffers of ispol'zovan.s for the calculation
IndicatorBuffers(2);
SetIndexBuffer(0,JMovingBuffer);
SetIndexBuffer(1,Series_buffer);
//the horizontal shift of the indicator line
SetIndexShift (0, Shift);  
//the installation of the values of indicator, which not will be seenon the graph
SetIndexEmptyValue(0,0); 

   switch(MA_method)
     {
      case 1 : short_name="JEMA";  break;
      case 2 : short_name="JSMMA"; break;
      case 3 : short_name="JLWMA"; break;
      default :
         MA_method=0;
         short_name="JSMA";
     }
   IndicatorShortName(short_name+MA_period+")");

//name for the windows of data and leyba for sub"okon
SetIndexLabel (0, short_name); 
//the installation of the size of the accuracy of mapping theindicator
IndicatorDigits(Digits);
//a change in the sizes of the buffer variables of functionJLiteSeries, nJMAnumber=1(Odno turning to function JLiteSeries)
if (JJMASeriesResize(1)!=1)return(-1);
//the installation of Alerts at the inadmissible values of theexternal variables

JJMASeriesAlert (0,"MA_period",MA_period);
JJMASeriesAlert (0,"Smooth",Smooth);
JJMASeriesAlert (1,"Smooth_Phase",Smooth_Phase);
PriceSeriesAlert(Input_Price_Customs);
if (MA_method<0){Alert("Parameter MA_method must be from 0 to 3"   
            + MA_method + " is not permitted; " + " 0 will be used.");}
if (MA_method>3){Alert("Parameter MA_method must be from 0 to 3"   
            + MA_method + " is not permitted; " + " 0 will be used.");}

PriceSeriesAlert(Input_Price_Customs);
//korektsiya of the inadmissible value of parameter MA_.period
if (MA_period<1) MA_period = 1; 
//the completion of the initialization

   if ((WhatCorner == 2) || (WhatCorner == 3))
      {
      ydistance2 = 50+ydistance1;
      }
    else
      {
      ydistance1 = 20+ydistance1;
      }
   objectma1 = "banzaiJMA"+IntToStr(MA_period);  
   ObjectCreate(objectma1, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(objectma1, short_name+"("+MA_period+")", 8, "Arial", MAcolor1);
   ObjectSet(objectma1, OBJPROP_CORNER, WhatCorner); 
   ObjectSet(objectma1, OBJPROP_XDISTANCE, 2);
   ObjectSet(objectma1, OBJPROP_YDISTANCE, ydistance1);
return(0); 
} 
//+------------------------------------------------------------------+  
//| JMoving Avereges iteration function                              | 
//+------------------------------------------------------------------+  
int start() 
{ 
//checking a quantity of bars to the sufficiency for furthercalculation
if (Bars-1<MA_period+31)return(0);
//the introduction of entire variables and obtaining the alreadycalculated bars
int reset,MaxBar,bar,counted_bars=IndicatorCounted();
//checking to the possible errors
if (counted_bars<0)return(-1);
//the last calculated bar must be converted
//(bez of this conversion for counted_.bars function JJMASeries willwork incorrectly!!!)
if (counted_bars>0)counted_bars--;
//the determination of the number of the oldest bar, beginning fromwhich there will be proizeden the conversion of the new bars
int limit=Bars-counted_bars-1; MaxBar=Bars-1-MA_period; 
//load into the buffer of the initial prices
for(bar=limit;bar>=0;bar--)Series_buffer[bar]=PriceSeries(Input_Price_Customs,bar);
//korektsiya of the starting raschetogo bar in the cycle
//initialization of zero
if (limit>MaxBar)
   {
    for(bar=limit;bar>=MaxBar;bar--)JMovingBuffer[bar]=0;
    limit=MaxBar;
   }

//THE BASIC CYCLE OF THE CALCULATION OF THE INDICATOR
for(bar=limit;bar>=0;bar--)
  {
//formula for calculating the indicator
  Temp_Series=iMAOnArray(Series_buffer,0,MA_period,0,MA_method, bar);
//the smoothing of that obtained Moving Avereges
//turning to function JJMASeries after number 0. ParametersnJJMA.Length and nJJMA.Phase not menya.ttsya on each bar(nJJMA.din=0)
  Resalt=JJMASeries(0,0,MaxBar,limit,Smooth_Phase,Smooth,Temp_Series,bar,reset);
//checking to the absence of error in the previous operation
  if(reset!=0)return(-1);
  JMovingBuffer[bar]=Resalt; 
  }
//the completion of the calculations of the values of the indicator
return(0); 
} 

//+---------------------------------------------------------------+


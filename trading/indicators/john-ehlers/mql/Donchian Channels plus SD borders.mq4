//+------------------------------------------------------------------+
//|                      Donchian Channels - Generalized version.mq4 |
//|                         Copyright © 2005, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Magenta
#property indicator_color2 Magenta
#property indicator_color3 Purple
#property indicator_color4 Purple

//Periods: number of bars used for calculating the Donchian channel 
//Extremes: if 1 uses the highest high and the lowest low -> I do not recomend using this
//			if 0 uses the open of the extremes bar -> the open point of a bar (as well as the close
//				are the points of maximum probability of concentration of the prices during the bar
//			if 3 uses the median point most extreme open and lowest low or highest high
//Margins: is the percent of the channel subtrated from the channel border before printing it, negative values are allowed
//Advance: the numbers of bars ahead
//---- input parameters
extern int       Periods=24;
extern int       Extremes=3;
extern int       Margins=-2;
extern int       Advance=0;
extern   int      max_bars=2000;
extern bool SD_border= true;
extern double SD_factor=0.2;

//---- buffers
double ExtMapBuffer0[];
double ExtMapBuffer1[];
double BorderSupBuffer2[];
double BorderInfBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,1,3);
   SetIndexBuffer(0,ExtMapBuffer0);
   SetIndexStyle(1,DRAW_LINE,1,3);
   SetIndexBuffer(1,ExtMapBuffer1);
   SetIndexStyle(2,DRAW_LINE,1,1);
   SetIndexBuffer(2,BorderSupBuffer2);
   SetIndexStyle(3,DRAW_LINE,1,1);
   SetIndexBuffer(3,BorderInfBuffer3);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int    fixed_bars=IndicatorCounted();
   //---- 
   
   //int shift=0;//, cnt(0), loopbegin(0);
   double smin=0, smax=0, SsMax=0, SsMin=0;
   //Variables : bar(0), prevbars(0), start(0), cs(0), prevcs(0),commodt(0);

   for (int shift=0;shift< max_bars;shift++)
   {
	  if (Extremes ==1)
	  {
		 SsMax = High[Highest(NULL,0,MODE_HIGH,Periods,shift)];
		 SsMin = Low[Lowest(NULL,0,MODE_LOW,Periods,shift)];
	  }
	  else if (Extremes == 3)
	  {
		 SsMax = (Open[Highest(NULL,0,MODE_OPEN,Periods,shift)]+High[Highest(NULL,0,MODE_HIGH,Periods,shift)])/2;
		 SsMin = (Open[Lowest(NULL,0,MODE_OPEN,Periods,shift)]+Low[Lowest(NULL,0,MODE_LOW,Periods,shift)])/2;
	  }
	     else
	  {
		SsMax = Open[Highest(NULL,0,MODE_OPEN,Periods,shift)];
		SsMin = Open[Lowest(NULL,0,MODE_OPEN,Periods,shift)];
	  }
	  smin = SsMin+(SsMax-SsMin)*Margins/100;
	  smax = SsMax-(SsMax-SsMin)*Margins/100;
	  
	  
	  ExtMapBuffer0[shift-Advance]=smin;
	  ExtMapBuffer1[shift-Advance]=smax;
	  if(SD_border)
	  {
	     double sd=iStdDev(NULL,0,Periods,MODE_LWMA,0,PRICE_TYPICAL,shift-Advance);
	     BorderSupBuffer2[shift-Advance]=smax+sd*SD_factor;
	     BorderInfBuffer3[shift-Advance]=smin-sd*SD_factor;
	  
	  }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
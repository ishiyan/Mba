//+------------------------------------------------------------------+
//|                                               RAVI FX Fisher.mq4 |
//|                         Copyright © 2005, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Yellow

//---- input parameters
extern int       lenth=10;
extern int       maxbars=2000;


//---- buffers
double FishBuffer[];
double SignalBuffer[];
double AuxBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,FishBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,SignalBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,AuxBuffer);
   SetLevelValue(0,0.8);
   SetLevelValue(1,-0.8);
   ArrayInitialize(FishBuffer,0);
   ArrayInitialize(SignalBuffer,0);
   ArrayInitialize(AuxBuffer,0);
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
      int    counted_bars=IndicatorCounted();
      Comment(Bars,"  ", counted_bars);
      //double Normalized=0;
      //double Fish=0;
      //---- check for possible errors
      if(counted_bars<0) return(-1);
      int limit=Bars-counted_bars;
      if(limit>maxbars)limit=maxbars;      
      if (limit>Bars-lenth-1)limit=Bars-lenth-1;   
      //---- 
      for (int shift = limit; shift>=0;shift--)
      {
	      AuxBuffer[shift]=0.5*(iStochastic(NULL,0,lenth,2,1,MODE_SMA,0,MODE_MAIN,shift)/100-0.5)*2+0.5*AuxBuffer[shift+1];  
	      
	      FishBuffer[shift]= 0.25* MathLog((1+AuxBuffer[shift])/(1-AuxBuffer[shift]))+0.5*FishBuffer[shift+1];       
         SignalBuffer[shift]=FishBuffer[shift+1];
         
       }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
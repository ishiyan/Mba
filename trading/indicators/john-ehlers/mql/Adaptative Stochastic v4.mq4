//+------------------------------------------------------------------+
//|                                     Adaptative Stochastic v4.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"

#property indicator_separate_window
#property indicator_minimum -100
#property indicator_maximum 130
#property indicator_buffers 6
#property indicator_color1 DeepSkyBlue
#property indicator_color2 DodgerBlue
#property indicator_color3 DodgerBlue
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 PaleGreen

//---- input parameters
extern int       base_periods=10;
extern int       fast_ATR=7;
extern int       slow_ATR=49;
extern bool      quadratic=true;
extern int       over_bs_level=90;
extern int       entry_level=75;
extern int       maxbars=500; 
extern int       step=2;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators   
   SetIndexStyle(0,DRAW_LINE,1,2);
   SetIndexBuffer(0,ExtMapBuffer1);  
   SetIndexStyle(1,DRAW_LINE,1,2);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE,1,2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_LINE,1,2);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_LINE,1,2);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5,DRAW_LINE,1,1);
   SetIndexBuffer(5,ExtMapBuffer6);
   
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
      double multiplier=0;
      int    counted_bars=IndicatorCounted();
      //---- check for possible errors
      if(counted_bars<0) return(-1);
      //---- last counted bar will be recounted
      int limit=Bars-counted_bars;
      if(limit>maxbars)limit=maxbars;
      if (limit>Bars-base_periods*2-1)limit=Bars-base_periods*2-1;
      double adapt_stoch=0;
      //Comment(Bars+"    "+limit); 
      int periods=0;
      static double factor=0;
      for (int shift = 0; shift<=limit;shift++)
      {  
         if(MathMod(shift,step)==0)
         {
            //factor=10000*iMACD(NULL,0,adapt_fast,adapt_slow,1,PRICE_CLOSE,MODE_MAIN,shift);
            //factor=MathAbs(iCCI(NULL,0,adapt_n,PRICE_TYPICAL,shift));
            factor=iATR(NULL,0,fast_ATR,shift)/iATR(NULL,0,slow_ATR,shift);
            if (quadratic)multiplier = factor*factor;else multiplier=factor;        
            periods=MathRound(base_periods*multiplier);
         }
                             
         adapt_stoch=2*(iStochastic(NULL,0,periods,1,4,MODE_LWMA,1,MODE_MAIN,shift)-50);
   
   
         ExtMapBuffer1[shift]=adapt_stoch;
         ExtMapBuffer2[shift]=entry_level;
         ExtMapBuffer3[shift]=-entry_level;
         ExtMapBuffer4[shift]=over_bs_level;
         ExtMapBuffer5[shift]=-over_bs_level;
         ExtMapBuffer6[shift]=0;
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+
#property copyright "Kalenzo"
#property link      "http://www.fxservice.eu"
#property indicator_buffers 2

#property indicator_color1 Red 
#property indicator_color2 Blue

#property indicator_width1 2
#property indicator_width2 1
 
extern int    TimeFrame= 60;


extern int        AlertDelay  = 1;//In minutes
extern bool       AlertOn     = true;
extern bool       MailOn      = true;

double sUp1[],sDn1[];
int a=0,b=0;



#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,sUp1);
   SetIndexBuffer(1,sDn1);
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
   SetIndexStyle(0,DRAW_LINE,3);
    
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
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
     
     int counted_bars=IndicatorCounted();
     if(counted_bars<0) return(-1);
     if(counted_bars>0) counted_bars--;
     int limit=Bars-counted_bars;
     
     for(int i=0; i<=limit; i++)
     {
         sUp1[i] = 0; sDn1[i] = 0;
         
         int bbs = iBarShift(NULL,TimeFrame,Time[i],true);
         
         sUp1[i] = iCustom(NULL,TimeFrame,"Instant TrendLine",0,bbs);
         sDn1[i] = iCustom(NULL,TimeFrame,"Instant TrendLine",1,bbs);
         
         
     }

  
     return(0);
  }
//+------------------------------------------------------------------+
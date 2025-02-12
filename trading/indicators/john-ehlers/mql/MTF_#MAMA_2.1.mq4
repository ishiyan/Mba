#property copyright "Kalenzo"
#property link      "http://www.fxservice.eu"
#property indicator_buffers 2

#property indicator_color1 Lime 
#property indicator_color2 MediumOrchid

#property indicator_width1 1
#property indicator_width2 1
 
extern int    TimeFrame= 15;
extern double FastLimit=0.5;
extern double SlowLimit=0.05; 
 
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
   
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_DOT);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_DOT);
    
   
   
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
         
         sUp1[i] = iCustom(NULL,TimeFrame,"#MAMA",FastLimit,SlowLimit,0,bbs);
         sDn1[i] = iCustom(NULL,TimeFrame,"#MAMA",FastLimit,SlowLimit,1,bbs);
         
         
     }
     
         if(Bars > a  && sUp1[2]>=sDn1[2] && sUp1[1]<sDn1[1])
         {
            Alert(Symbol()+" M("+Period()+") SHORT -> MAMA");
            SendMail("SHORT MAMA",Symbol()+" M("+Period()+") SHORT -> MAMA");
            a = Bars;
         }
         
         if(Bars>b  && sUp1[2]<=sDn1[2] && sUp1[1]>sDn1[1])
         {
            Alert(Symbol()+" M("+Period()+") LONG ->  MAMA");
            SendMail("LONG MAMA",Symbol()+" M("+Period()+") LONG ->  MAMA");
            b = Bars;
         }

     return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                 MA of RSX   mq4  |
//|                           Copyright © 2009, Obaidah / GodfreyH   |
//+------------------------------------------------------------------+
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Magenta
#property  indicator_color2  Aqua
#property  indicator_width1  2
#property indicator_level1 70
#property indicator_level2 50
#property indicator_level3 30
#property indicator_levelcolor RoyalBlue
#property indicator_levelwidth 2

//---- indicator parameters
extern int Len = 10;
extern int SignalMA=2;
extern string MAMethod ="0:SMA 1:EMA 2:SMMA 3:LWMA";
extern int MA_Method =0;
extern string aa="String Colors";
extern color  Bullish=C'0,106,0';
extern color  Bearish=C'157,0,0';
extern bool AlertOn=false;
extern int       RSXPeriod=10;
//---- indicator buffers
double     ExtMapBuffer[];
double     SignalBuffer[];
int        Shadow[];
int        shift[];
string Label="";

string signal;
string lastsignal;
double alertTag;
string ShortName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
//   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(0,SignalMA);
   SetIndexDrawBegin(1,SignalMA);
   IndicatorDigits(Digits+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,SignalBuffer);
   
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("RSX Limited");
   SetIndexLabel(0,"RSXTrend");
   Label=" ";
//---- initialization done
   return(0);
  }

int deinit()
{
   for(int i = ObjectsTotal() - 1; i >= 0; i--) {
      string Label = ObjectName(i);
      if(StringSubstr(Label, 0, 8) != "RSXTrend")
         continue;
     ObjectDelete(Label);   
   }
  // ObjectDelete("SHORT");      
   //ObjectDelete("LONG");      
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  
int start()
  {
  int Window=WindowFind("RSX Limited");
   int i,limit;

   int counted_bars=IndicatorCounted();   
//---- last counted bar will be recounted
   if(counted_bars<0) return(-1);
   
   if(counted_bars>0) counted_bars--;      
   limit=Bars-counted_bars;

   //--- RSX counted in the 1-st buffer
   for (i=limit;i>=0;i--) ExtMapBuffer[i]=iCustom(NULL,0,"RSX",Len,0,i);
   
   //---- signal line counted in the 2ND buffer
   for (i=limit;i>=0;i--) SignalBuffer[i]=iMAOnArray(ExtMapBuffer,Bars,SignalMA,0,MA_Method,i);
   

   for (i=limit;i>=1;i--) 
   {          
         
      if( ( SignalBuffer[i] > ExtMapBuffer[i]) && (SignalBuffer[i+1] < ExtMapBuffer[i+1]) )
      { // If its a cross point
         Label="RSXTrend"+ DoubleToStr(Time[i],0);         
         if(ObjectFind(Label)==-1) ObjectCreate(Label,OBJ_RECTANGLE,Window,0,0);
         ObjectSet(Label,OBJPROP_COLOR,Bearish);
         ObjectSet(Label,OBJPROP_PRICE1,100);
         ObjectSet(Label,OBJPROP_PRICE2,0);
         ObjectSet(Label,OBJPROP_TIME1,Time[i]);
         ObjectSet(Label,OBJPROP_TIME2,Time[i-1]);              
      }
      else 
      {
         if(  (SignalBuffer[i] < ExtMapBuffer[i]) && (SignalBuffer[i+1] > ExtMapBuffer[i+1]) )
         { // If its a cross point
            Label="RSXTrend"+ DoubleToStr(Time[i],0);
            if(ObjectFind(Label)==-1) ObjectCreate(Label,OBJ_RECTANGLE,Window,0,0);
            ObjectSet(Label,OBJPROP_COLOR,Bullish);
            ObjectSet(Label,OBJPROP_PRICE1,100);
            ObjectSet(Label,OBJPROP_PRICE2,0);
            ObjectSet(Label,OBJPROP_TIME1,Time[i]);
            ObjectSet(Label,OBJPROP_TIME2,Time[i-1]);
         }
         else
         {
           if(ObjectFind(Label)!=-1) ObjectSet(Label,OBJPROP_TIME2,Time[i-1]); // drag the current shadow
         }  
                      
      }
      
   }
             
   WindowRedraw();                        
   
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| MTF_INSTANTTRENDLINE_D1
//|  Adapted by Simba from:     MTF_ChandelierStops_60min.mq4 
//|                              by Zathar 
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_width1 2
#property indicator_width2 2

int TimeFrame=PERIOD_D1;
double ExtMapBuffer1[];
double ExtMapBuffer2[];


int init()
  {
   //---- indicator line
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_LINE);   
   IndicatorShortName("MTF_InstTrndlnFltr_D1");
   SetIndexLabel(0,"Up");
   SetIndexLabel(1,"Dn");
  }
//----
   return(0);
 

int start()
  {
   datetime TimeArray[];
   int    i,shift,limit,y=0,counted_bars=IndicatorCounted();
     
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++) {
     if (Time[i]<TimeArray[y]) {y++;}   
     ExtMapBuffer1[i]=iCustom(NULL,TimeFrame,"Instant Trendline Filter",1,y); 
     ExtMapBuffer2[i]=iCustom(NULL,TimeFrame,"Instant Trendline Filter",0,y);
   }
   return(0);
  }
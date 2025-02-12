//+------------------------------------------------------------------+
//|                                                          PDF.mq4 |
//|                         Copyright © 2006, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 MediumSeaGreen
#property indicator_color2 Yellow

double pdf[];
double pdft[];
//---- input parameters
extern int       ch_size=20;
extern int       cn=300;
//extern int limit_value=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
  SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,pdf);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,pdft);

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
   
//----
//---- indicators
   int counter[];
   int counter_ft[];
   int totBars=Bars;
   int value,ftvalue=0;
   
   int    counted_bars=IndicatorCounted();
      
   if(counted_bars<0) return(-1);
   ArrayResize(counter,cn+1);
   ArrayResize(counter_ft,cn+1);
   ArrayInitialize(counter,0);   
   ArrayInitialize(counter_ft,0);   
   for(int i =Bars-1-ch_size;i>=0;i--)
   {
      value=MathCeil(iStochastic(NULL,0,ch_size, 2,1,MODE_SMA,0,MODE_MAIN,i));  
 
      ftvalue=(value/100-0.5)*2;
      if(ftvalue<-0.9999)ftvalue=-0.9999;
      if(ftvalue>0.9999)ftvalue=0.9999;
      ftvalue=0.5*MathLog((1+ftvalue)/(1-ftvalue));
      ftvalue=MathCeil((ftvalue/2+0.5)*100)+(MathFloor(cn/2)-50);
      if(ftvalue>cn)ftvalue=cn;
      if(ftvalue<0)ftvalue=0;
   
      value=value+(MathFloor(cn/2)-50);
      counter[cn-value]=counter[cn-value]+1;
      counter_ft[cn-ftvalue]=counter_ft[cn-ftvalue]+1;
   }
   pdf[0]=0;
   for(i=cn;i>0;i--)
   {
      pdf[i]=counter[i];
      if(counter_ft[i]<700)pdft[i]=counter_ft[i];
      else pdft[i]=700;
     // Print(pdf[i]);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                        Bands.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Red 
#property indicator_color3 DodgerBlue
//---- стиль линий Bollinger Bands
#property indicator_style1 4
#property indicator_style5 4
//---- indicator parameters
extern int    BandsPeriod=30;
extern int    BandsShift=0;
extern double BandsDeviations=2.0;
//---- buffers
double UpperBuffer[];
double MovingBuffer[];
double LowerBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
//---- 3indicator buffers   
   IndicatorBuffers(3);
//----    
   SetIndexBuffer(0,UpperBuffer); 
   SetIndexBuffer(1,MovingBuffer);  
   SetIndexBuffer(2,LowerBuffer);
//----
//----
   SetIndexDrawBegin(0,BandsPeriod+BandsShift);
   SetIndexDrawBegin(1,BandsPeriod+BandsShift);
   SetIndexDrawBegin(2,BandsPeriod+BandsShift);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
//+------------------------------------------------------------------+
int start()
  {
//---- проверка количества баров на достаточность дл€ расчЄта
if(Bars<=BandsPeriod) return(0);
//----+ ¬ведение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчЄта всех подсчитанных и отрисованных баров при подключении к интернету
int ii,jj,k,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начина€ с которого будет произедЄн пересчЄт новых баров
int limit=Bars-counted_bars-1;
double sum,oldval,newres,deviation;
   
//----
   for(ii=0; ii<limit; ii++)MovingBuffer[ii]=iMA(NULL,0,BandsPeriod,BandsShift,MODE_SMA,PRICE_CLOSE,ii);
//----
   jj=Bars-BandsPeriod+1;
   if(counted_bars>BandsPeriod-1) jj=Bars-counted_bars-1;
   while(jj>=0)
     {
      sum=0.0;
      k=jj+BandsPeriod-1;
      oldval=MovingBuffer[jj];
      while(k>=jj)
        {
         newres=Close[k]-oldval;
         sum+=newres*newres;
         k--;
        }
      deviation=BandsDeviations*MathSqrt(sum/BandsPeriod);
      UpperBuffer[jj]=oldval+deviation;
      LowerBuffer[jj]=oldval-deviation;
      jj--;
     }
//----
   return(0);
  }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ ¬ведение функции INDICATOR_COUNTED (файл INDICATOR_COUNTED.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
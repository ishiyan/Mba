//+------------------------------------------------------------------+
//|                                                Price Channel.mq4 |
//|                                                                  |
//|                                       http://forex.kbpauk.ru/    |
//+------------------------------------------------------------------+
 
#property link      "http://forex.kbpauk.ru/"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 3
//---- цвет индикатора
#property indicator_color1 Lime
#property indicator_color2 Blue
#property indicator_color3 Red
//---- стиль линий Bollinger Bands
#property indicator_style1 4
#property indicator_style2 2
#property indicator_style3 4
//---- input parameters
extern int ChannelPeriod=14;
//---- buffers
double UpBuffer[];
double DnBuffer[];
double MdBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
//----   
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,MdBuffer);
   SetIndexBuffer(2,DnBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="Price Channel("+ChannelPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Up Channel");
   SetIndexLabel(1,"Middle Channel");
   SetIndexLabel(2,"Down Channel");
//----
   SetIndexDrawBegin(0,ChannelPeriod);
   SetIndexDrawBegin(1,ChannelPeriod);
   SetIndexDrawBegin(2,ChannelPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Price Channel                                                    |
//+------------------------------------------------------------------+
int start()
  {
//---- блокирование пересчЄта всех подсчитанных и отрисованных баров при подключении к интернету
int ii,kk,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан (без этого пересчЄта дл€ counted_bars функци€ JurXSeries будет работать некорректно!!!)
if (counted_bars>0) counted_bars--;
 
   double high,low,price;
//----
   if(Bars<=ChannelPeriod) return(0);
//---- initial zero
   if(counted_bars<1)for(ii=1;ii<=ChannelPeriod;ii++) UpBuffer[Bars-ii]=0.0;
//---- определение номера самого старого бара, начина€ с которого будет произедЄн пересчЄт новых баров
   ii=Bars-ChannelPeriod-1;
   if(counted_bars>=ChannelPeriod) ii=Bars-counted_bars-1;
   while(ii>=0)
     {
       high=High[ii]; low=Low[ii]; kk=ii-1+ChannelPeriod;
      while(kk>=ii)
        {
         price=High[kk];
         if(high<price) high=price;
         price=Low[kk];
         if(low>price)  low=price;
         kk--;
        } 
     UpBuffer[ii]=high;
     DnBuffer[ii]=low;
     MdBuffer[ii]=(high+low)/2;
      ii--;
     }
   return(0);
  }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ ¬ведение функции INDICATOR_COUNTED (файл INDICATOR_COUNTED.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
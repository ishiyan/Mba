//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                 Heiken Ashi#.mq4 |
//|                      Copyright c 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//+------------------------------------------------------------------+
//| For Heiken Ashi we recommend next chart settings ( press F8 or   |
//| select on menu 'Charts'->'Properties...'):                       |
//|  - On 'Color' Tab select 'Black' for 'Line Graph'                |
//|  - On 'Common' Tab disable 'Chart on Foreground' checkbox and    |
//|    select 'Line Chart' radiobutton                               |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 4 
//---- цвета индикатора 
#property indicator_color1 Red  
#property indicator_color2 LimeGreen 
#property indicator_color3 Red
#property indicator_color4 LimeGreen
//---- толщина индикаторных линий
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3 
#property indicator_width4 3
//---- индикаторные буфферы
double L.Buffer[];
double H.Buffer[];
double O.Buffer[];
double C.Buffer[];
//---- переменные с плавающей точкой  
double haOpen, haHigh, haLow, haClose;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Heiken Ashi# initialization function                             |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- стиль изображения индикатора
   SetIndexStyle(0,DRAW_HISTOGRAM,0);
   SetIndexStyle(1,DRAW_HISTOGRAM,0);
   SetIndexStyle(2,DRAW_HISTOGRAM,0);
   SetIndexStyle(3,DRAW_HISTOGRAM,0);
//---- установка номера бара, начиная с которого будет отрисовываться индикатор  
   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
   SetIndexDrawBegin(3,10);
//---- 4 индикаторных буффера использованы для счёта
   SetIndexBuffer(0,L.Buffer);
   SetIndexBuffer(1,H.Buffer);
   SetIndexBuffer(2,O.Buffer);
   SetIndexBuffer(3,C.Buffer);
//---- завершение инициализации
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Heiken Ashii# teration function                                  |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
if (Bars<=10) return(0);
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int MaxBar,bar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
//(без этого пересчёта для counted_bars функция JJMASeries будет работать некорректно!!!)
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
bar=Bars-counted_bars-1; MaxBar=Bars-2;
//---- корекция стартового расчётого бара в цикле
//---- инициализация нуля          
if (bar>MaxBar)
     {
      for(bar=Bars-1;bar>=MaxBar;bar--)
       {
        L.Buffer[bar]=0;
        H.Buffer[bar]=0;
        O.Buffer[bar]=0;
        C.Buffer[bar]=0;
       }
     bar=MaxBar;
     }
//----
while(bar>=0)
     {
      haOpen=(O.Buffer[bar+1]+C.Buffer[bar+1])/2;
      haClose=(Open[bar]+High[bar]+Low[bar]+Close[bar])/4;
      haHigh=MathMax(High[bar], MathMax(haOpen, haClose));
      haLow=MathMin(Low[bar], MathMin(haOpen, haClose));
      if (haOpen<haClose) 
        {
         L.Buffer[bar]=haLow;
         H.Buffer[bar]=haHigh;
        } 
      else
        {
         L.Buffer[bar]=haHigh;
         H.Buffer[bar]=haLow;
        } 
      O.Buffer[bar]=haOpen;
      C.Buffer[bar]=haClose;
 	   bar--;
     }
//----
   return(0);
  }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции INDICATOR_COUNTED (файл INDICATOR_COUNTED.mqh следует положить в папку (директорию): 
#include <INDICATOR_COUNTED.mqh> ////////////////////////////////                                  MetaTrader\experts\include)
//+---------------------------------------------------------------------------------------------------------------------------+
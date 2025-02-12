//редактировано и исправлено 17.04.2006 Николай Косицин
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                 Heiken AshiR.mq4 |
//|                               Copyright © 2004, Poul_Trade_Forum |
//|                                                         Aborigen |
//|                                          http://forex.kbpauk.ru/ |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Poul Trade Forum"
#property link      "http://forex.kbpauk.ru/"
//---- отрисовка индикатора в отдельном окне
#property  indicator_separate_window
//---- количество индикаторных буфферов
#property indicator_buffers 2
//---- цвета индикатора
#property indicator_color1 Red
#property indicator_color2 Lime
//---- верхнее и нижнее ограничение шкалы окна индикатора
#property indicator_maximum 1.1
#property indicator_minimum 0.9
//---- толщина индикаторных линий
#property indicator_width1 2
#property indicator_width2 2
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА 
extern int Simbol=110;
//---- индикаторные буфферы
double HighBuffer[];
double LowBuffer [];
//---- переменные с плавающей точкой  
double Trend;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Heiken AshiR initialization function                             |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {   
//---- Стиль исполнения графика виде символов
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
//---- Определение стиля точечных объектов
   SetIndexArrow(0,Simbol);
   SetIndexArrow(1,Simbol);
//---- 2 индикаторных буффера использованы для счёта.
   SetIndexBuffer(0,HighBuffer);
   SetIndexBuffer(1,LowBuffer );
//---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
//---- имена для окон данных и лэйбы для субъокон.
   IndicatorShortName("Heiken Ashi");
   SetIndexLabel   (0,"Heiken Ashi");
   SetIndexLabel   (1,"Heiken Ashi");
//---- установка номера бара, начиная с которого будет отрисовываться индикатор  
   SetIndexDrawBegin(0,1);
   SetIndexDrawBegin(1,1);
//----

   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Heiken AshiR iteration function                                  |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int MaxBar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
MaxBar=Bars-2;
limit=(Bars-1-counted_bars);
//---- инициализация нуля
if (limit>MaxBar)
{
  limit=MaxBar;
  HighBuffer[Bars-1]=0; 
  LowBuffer [Bars-1]=0;
}
//----
for (int bar=limit; bar>=0;bar--)
{
  Trend = iCustom(NULL,0,"Heiken Ashi#",1,bar)-iCustom(NULL,0,"Heiken Ashi#",0,bar);
  if (Trend>0){HighBuffer[bar]=1; LowBuffer [bar]=0;}
  if (Trend<0){LowBuffer [bar]=1; HighBuffer[bar]=0;}
}
   return(0);
 }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции INDICATOR_COUNTED (файл INDICATOR_COUNTED.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+


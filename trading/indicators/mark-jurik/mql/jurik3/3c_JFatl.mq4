/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh  
PriceSeries.mqh 
3Color.mqh
в папку (директорию): MetaTrader\experts\include\
JFatl.mq4
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                     3c_JFatl.mq4 | 
//|                             Copyright © 2006,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 6
//---- цвета индикатора
#property indicator_color1 Yellow
#property indicator_color2 Yellow
#property indicator_color3 Magenta 
#property indicator_color4 Magenta 
#property indicator_color5 Gray
#property indicator_color6 Gray
//---- толщина индикаторных линий
#property indicator_width1 2
#property indicator_width2 2 
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2 
#property indicator_width6 2
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int              Length = 4;   // глубина сглаживания 
extern int               Phase = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- введение функции digits() для установки формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
int digits(){return(Digits);}
//---- Введение функции COUNT_begin() для вычисления номера бара, начиная с которого будет отрисовываться индикатор
int COUNT_begin(){return(39+30);}
//---- установка значений индикатора, которые не будут видимы на графике 
int EmptyValue=0;
string Label="JFatl";                 
//---- включение в текст индикатора его основного текста
#include <3Color.mqh>
//---- введение функции INDICATOR -------------------------------------------------------------------------+
//---- обращение к исходному индикатору для получения иходных значений
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom(NULL,0,"JFatl",Length,Phase,0,Input_Price_Customs,0,INDICATOR.bar) );
 }
//---- ----------------------------------------------------------------------------------------------------+
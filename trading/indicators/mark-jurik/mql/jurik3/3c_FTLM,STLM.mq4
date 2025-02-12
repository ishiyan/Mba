/*
Для  работы  индикатора  следует  положить  файлы   
JJMASeries.mqh
PriceSeries.mqh
3c_BB_Osc.mqh  
в папку (директорию): MetaTrader\experts\include\
FTLM,STLM.mq4 
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                 3c_FTLM,STLM.mq4 | 
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буфферов
#property indicator_buffers 8 
//---- цвета индикатора 
#property indicator_color1 Purple 
#property indicator_color2 Lime 
#property indicator_color3 OrangeRed
#property indicator_color4 Gray
//---- Bollinger Bands цвета
#property indicator_color5 Gray
#property indicator_color6 Gray
#property indicator_color7 BlueViolet
#property indicator_color8 BlueViolet
//---- толщина индикаторных линий
#property indicator_width1 3
#property indicator_width2 1
#property indicator_width3 1 
#property indicator_width4 1
//---- стиль огибающей линии
#property indicator_style1 0
//---- стиль линий Bollinger Bands
#property indicator_style5 4
#property indicator_style6 4
#property indicator_style7 4
#property indicator_style8 4
//---- параметры горизонтальных уровней индикатора
#property indicator_level1 0.0
#property indicator_levelcolor Blue
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int JMAsmooth=4; // глубина сглаживания полученного индикатора
extern int Smooth_Phase=100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов сглаживания
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- введение функции digits() для установки формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
int digits(){return(0);}
//---- Введение функции COUNT_begin() для вычисления номера бара, начиная с которого будет отрисовываться индикатор и расчитываться Bollinger Bands 
int COUNT_begin(){return(128+30);}
//---- установка значений индикатора, которые не будут видимы на графике 
int EmptyValue=0.0;
//---- Определение названия индикатора
string Label = "FTLM,STLM";

//---- Включение в текст индикатора его основного текста
#include <3c_BB_Osc.mqh> 
//---- +-----------------------------------------------+

//---- введение функции INDICATOR -------------------------------------------------------------------------+
//---- обращение к исходному индикатору для получения иходных значений
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom( NULL, 0, "FTLM,STLM", JMAsmooth, Smooth_Phase, Input_Price_Customs, 0, bar) );
 }
//---- ----------------------------------------------------------------------------------------------------+
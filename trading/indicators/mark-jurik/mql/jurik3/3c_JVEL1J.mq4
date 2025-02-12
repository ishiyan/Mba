/*
/---- 
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
3c_BB_Osc.mqh
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                    3c_JVEL1J.mq4 |
//|         JVEL1: Copyright © 2005,            Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|   MQL4+3color: Copyright © 2006,                Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+  
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буфферов
#property indicator_buffers 8 
//---- цвета индикатора 
#property indicator_color1 SlateBlue 
#property indicator_color2 SpringGreen
#property indicator_color3 Magenta
#property indicator_color4 Gray
//---- Bollinger Bands цвета
#property indicator_color5 Blue
#property indicator_color6 Blue
#property indicator_color7 Red
#property indicator_color8 Red
//---- толщина индикаторных линий
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2 
#property indicator_width4 2
//---- стиль огибающей линии
#property indicator_style1 0
//---- стиль линий Bollinger Bands
#property indicator_style5 4
#property indicator_style6 4
#property indicator_style7 4
#property indicator_style8 4
//---- параметры горизонтальных уровней индикатора
#property indicator_level1 0.0
#property indicator_levelcolor DarkGray
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Depth=10;           // глубина сглаживания индикатора
extern int Smooth_Length=3;     // глубина JMA сглаживания готового индикатора
extern int Smooth_Phase =100;    // параметр JMA сглаживания готового индикатора, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
extern int Input_Price_Customs = 4;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- введение функции digits() для установки формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
int digits(){return(0);}
//---- Введение функции COUNT_begin() для вычисления номера бара, начиная с которого будет отрисовываться индикатор и расчитываться Bollinger Bands 
int COUNT_begin(){return(Depth+30);}
//---- установка значений индикатора, которые не будут видимы на графике 
int EmptyValue=0.0;
//---- Определение названия индикатора
string Label = "JVEL1";

//---- Включение в текст индикатора его основного текста
#include <3c_BB_Osc.mqh> 
//---- +-----------------------------------------------+
//---- введение функции INDICATOR ----------------------------------------------------------------------------+
//---- обращение к исходному индикатору для получения иходных значений
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom( NULL, 0, "JVEL1", Depth, Smooth_Length, Smooth_Phase, Input_Price_Customs, 1, bar) );
 }
//---- -------------------------------------------------------------------------------------------------------+
 


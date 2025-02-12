/*
Для  работы  индикатора  следует  положить файл JJMASeries.mqh в папку
(директорию): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                      3c_JADX.mq4 | 
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
#property indicator_color2 Blue 
#property indicator_color3 Magenta
#property indicator_color4 Gray
//---- Bollinger Bands цвета
#property indicator_color5 Gray
#property indicator_color6 Gray
#property indicator_color7 Gold 
#property indicator_color8 Gold 
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
extern int Length      = 15;  // глубина сглаживания DX
extern int Phase       =-100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов +DM и -DM 
extern int Smooth      = 3;   // глубина сглаживания готового индикатора
extern int Smooth_Phase=-100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса сглаживания 
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- введение функции digits() для установки формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
int digits(){return(0);}
//---- Введение функции COUNT_begin() для вычисления номера бара, начиная с которого будет отрисовываться индикатор и расчитываться Bollinger Bands 
int COUNT_begin(){return(60);}
//---- установка значений индикатора, которые не будут видимы на графике 
int EmptyValue=0.0;
//---- Определение названия индикатора
string Label = "JADX";

//---- Включение в текст индикатора его основного текста
#include <3c_BB_Osc.mqh> 
//---- +-----------------------------------------------+
//---- введение функции INDICATOR -------------------------------------------------------------------------+
//---- обращение к исходному индикатору для получения иходных значений
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom( NULL, 0, "JADX", Length, Phase,Smooth,Smooth_Phase, 0, 0, bar) );
 }
//---- ----------------------------------------------------------------------------------------------------+


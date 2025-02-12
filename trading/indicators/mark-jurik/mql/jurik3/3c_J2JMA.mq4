/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh  
PriceSeries.mqh 
3Color.mqh
в папку (директорию): MetaTrader\experts\include\
J2JMA.mq4 
в папку (директорию): MetaTrader\experts\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                      3_J2JMA.mq4 | 
//|                           Copyright © 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 6
//---- цвета индикатора
#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Red 
#property indicator_color5 Gray
#property indicator_color6 Gray
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Length1 = 5;   // глубина  первого сглаживания 
extern int Length2 = 5;   // глубина  второго сглаживания 
extern int Phase1  = 100; // параметр первого сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Phase2  = 100; // параметр второго сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- введение функции digits() для установки формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
int digits(){return(Digits);}
//---- Введение функции COUNT_begin() для вычисления номера бара, начиная с которого будет отрисовываться индикатор
int COUNT_begin(){return(60);}
//---- установка значений индикатора, которые не будут видимы на графике 
int  EmptyValue=0;
//---- лейба для индикатора
string Label="J2JMA";                 
//---- включение в текст индикатора его основного текста
#include <3Color.mqh>
//---- введение функции INDICATOR -------------------------------------------------------------------------+
//---- обращение к исходному индикатору для получения иходных значений
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom(NULL,0,"J2JMA",Length1,Length2,Phase1,Phase2,0,Input_Price_Customs,0,INDICATOR.bar) );
 }
//---- ----------------------------------------------------------------------------------------------------+
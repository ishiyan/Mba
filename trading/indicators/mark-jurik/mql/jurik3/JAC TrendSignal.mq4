/*
Для  работы  индикатора  следует  положить  файлы   
JJMASeries.mqh
PriceSeries.mqh
TrendSignal.mqh 
в папку (директорию): MetaTrader\experts\include\
JAccelerator.mq4
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                              JAC TrendSignal.mq4 |
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- цвета индикатора
#property indicator_buffers 8 
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Lime
#property indicator_color6 Lime
#property indicator_color7 Lime
#property indicator_color8 Lime
//---- толщина индикаторных линий
#property indicator_width1 3
#property indicator_width2 2
#property indicator_width3 1 
#property indicator_width4 0
#property indicator_width5 0
#property indicator_width6 1
#property indicator_width7 2 
#property indicator_width8 3
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int LEVEL14= 50;
extern int LEVEL13= 43;
extern int LEVEL12= 32;
extern int LEVEL11= 25;
extern int LEVEL01=-25;
extern int LEVEL02=-32;
extern int LEVEL03=-43;
extern int LEVEL04=-50;
extern int FastJMA=05;   // глубина сглаживания быстрой JMA
extern int SlowJMA=34;   // глубина сглаживания медленной JMA
extern int SignJMA=05;   // глубина сглаживания сигнальной JMA
extern int JMACD_Phase = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов JMACD 
extern int Sign_Phase  = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов сигнальной линии 
extern int Input_Price_Customs = 4;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- введение функции digits() для установки формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
int digits(){return(Digits);}
//---- Введение функции COUNT_begin() для вычисления номера бара, начиная с которого будет отрисовываться индикатор и расчитываться Bollinger Bands 
int COUNT_begin(){return(60);}
//---- установка значений индикатора, которые не будут видимы на графике 
int EmptyValue=0.0;
//---- Определение названия индикатора
string Label = "JAccelerator";

//---- Включение в текст индикатора его основного текста
#include <TrendSignal.mqh> 
//---- +-----------------------------------------------+
//---- введение функции INDICATOR ---------------------------------------------------------------------------------------+
//---- обращение к исходному индикатору для получения иходных значений
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom( NULL, 0, "JAccelerator",FastJMA,SlowJMA,SignJMA,JMACD_Phase,Sign_Phase,Input_Price_Customs, 0, bar) );
 }
//---- ------------------------------------------------------------------------------------------------------------------+
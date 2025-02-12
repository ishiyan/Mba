/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\

TRIX  –  это  моментум  осцилатор  цены,  введенный в оборот Джеком К.
Хатссоном (“Goog TRIX”, Technical Analysis of Stock & Commodities, том
1:5,  http://www.forexua.com/indicators/www.traders.com).
TRIX  –  однодневная  разность  тройного экспоненциального сглаживания
логарифма  цены  закрытия.  Индикатор  рассчитывается  в шесть этапов:
1. Получают логарифм дневной цены закрытия;
2. Сглаживают логарифм с помощью ЭСС;
3.  Получают ЭСС экспоненциального скользящего среднего, найденного на
этапе 2;
4.  Получают ЭСС экспоненциального скользящего среднего, найденного на
этапе 3;
5.   Вычисляют   однодневную   разность  между  результатами  тройного
сглаживания:  для  этого  значение  этапа  4  текущего дня вычитают из
значения этапа 4 предшествующего дня;
6. Значение, полученное на этапе 5, умножают (для удобного отображения
на графике) на 10 000.
Настройка   ТRIХ  в  соответствии  с  тем  или  иным  торговым  циклом
проводится,  как  и в случае других индикаторов, путем изменения числа
дней  в  экспоненциальном  скользящем  среднем.  Существует  несколько
возможных   путей  интерпретации  ТRIХ.  Самое  простое  прямолинейное
правило  принятия торговых решений для стратегии следования за трендом
гласит:  покупать,  когда  ТRIХ  меняет  направление  с  падающего  на
растущее.  Продавать,  когда  ТRIХ  меняет  направления с растущего на
падающее.
Copyright © 2003  Forex company http://www.forexua.com

В  данном  индикаторе  трёхкратное  сглаживание входной цены с помощью  
экспоненциального  скользящего  среднего  заменено  на двухкратное JMA 
сглаживание.
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                     3c_JTRIX.mq4 | 
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
#property indicator_color2 Yellow 
#property indicator_color3 Red
#property indicator_color4 Gray
//---- Bollinger Bands цвета
#property indicator_color5 Gray
#property indicator_color6 Gray
#property indicator_color7 Blue
#property indicator_color8 Blue
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
#property indicator_levelcolor BlueViolet
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Length = 5;  // глубина двойного сглаживания 
extern int Phase = 100; // параметр двойного сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Smooth = 5;  // глубина сглаживания готового индикатора
extern int Mom_Period = 1;// Momentum период индикатора
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- введение функции digits() для установки формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
int digits(){return(0);}
//---- Введение функции COUNT_begin() для вычисления номера бара, начиная с которого будет отрисовываться индикатор и расчитываться Bollinger Bands 
int COUNT_begin(){return(60+Mom_Period+30);}
//---- установка значений индикатора, которые не будут видимы на графике 
int EmptyValue=0.0;
//---- Определение названия индикатора
string Label = "JTRIX";
//---- Включение в текст индикатора его основного текста
#include <3c_BB_Osc.mqh> 
//---- +-----------------------------------------------+
//---- введение функции INDICATOR ----------------------------------------------------------------------------+
//---- обращение к исходному индикатору для получения иходных значений
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom( NULL, 0, "JTRIX", Length, Phase,Smooth,Mom_Period, 0, Input_Price_Customs, 0, bar) );
 }
//---- -------------------------------------------------------------------------------------------------------+
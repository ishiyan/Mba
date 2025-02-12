/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh
JurSeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                        JCCIX.mq4 |
//|   MQL4+3color: Copyright © 2006,                Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буфферов
#property indicator_buffers  1
//---- цвета индикатора
#property indicator_color1  BlueViolet
//---- параметры горизонтальных уровней индикатора
#property indicator_level1  0.5
#property indicator_level2 -0.5
#property indicator_level3  0.0
#property indicator_levelcolor MediumBlue
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int  JCCIX.Length = 8;  // глубина сглаживания индикатора
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_Buffer1[];
//---- целые переменные 
int    w;
//---- переменные с плавающей точкой    
double price,JCCIX,UPCCI,DNCCI,JUPCCIX,JDNCCIX,Temp_Series,JMA; 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JCCIX initialization function                                    |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
 {
//---- стили изображения индикатора
   SetIndexStyle(0,DRAW_LINE);
//---- 1 индикаторный буффер использован для счёта. 
   SetIndexBuffer(0,Ind_Buffer1);
//---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,0); 
//---- имена для окон данных и лэйбы для субъокон.
   SetIndexLabel(0,"JCCIX("+JCCIX.Length+")");
   IndicatorShortName("JCCIX(JCCIX.Length="+JCCIX.Length+")");
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора  
   IndicatorDigits(0);
//---- установка алертов на недопустимые значения входных параметров ==========================================================================+ 
if(JCCIX.Length< 1) {Alert("Параметр JCCIX.Length должен быть не менее 1"+ " Вы ввели недопустимое "+JCCIX.Length+ " будет использовано 1");}//|
PriceSeriesAlert(Input_Price_Customs);//---- обращение к функции PriceSeriesAlert /////////////////////////////////////////////////////////////|
//---- ========================================================================================================================================+ 
//---- установка номера бара, начиная с которого будет отрисовываться индикатор  
   SetIndexDrawBegin(0,JCCIX.Length+1);
//---- корекция недопустимого значения параметра JCCIX.Length
   if(JCCIX.Length<1)JCCIX.Length=1; 
//---- инициализация коэффициентов для расчёта индикатора 
   if (JCCIX.Length>5) w=JCCIX.Length-1; else w=5;
//---- завершение инициализации
return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|  JCommodity Channel IndexX                                       |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
  {
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,MaxBar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
//---- (без этого пересчёта для counted_bars функци JJMASeries и JurXSeries будут работать некорректно!!!)
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функциq JJMASeries и JurXSeries 
if (counted_bars==0){JJMASeriesReset(1);JurXSeriesReset(2);}
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBar=Bars-1; 
//---- корекция стартового расчётого бара в цикле
if(limit>=MaxBar)limit=MaxBar;

for(int bar=limit; bar>=0; bar--)
 { 
   //----+ Обращение к функции PriceSeries для получения входной цены Series
   Temp_Series=PriceSeries(Input_Price_Customs, bar);
   //+----------------------------------------------------------------------------+ 
   //----+ Одно обращение к функции JJMASeries за номерам 0. 
   //----+ Параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
   //+----------------------------------------------------------------------------+   
   JMA=JJMASeries(0,0,MaxBar,limit,100,JCCIX.Length,Temp_Series,bar,reset);
   //----+ проверка на отсутствие ошибки в предыдущей операции
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
   //+----------------------------------------------------------------------------+    
   price=PriceSeries(Input_Price_Customs, bar);
   UPCCI=price-JMA;         
   DNCCI=MathAbs(UPCCI);
   //----+ Два обращения к функции JurXSeries за номерами 0 и 1. Параметр nJJurXLength не меняtтся на каждом баре (nJurXdin=0)
   //----+ проверка на отсутствие ошибки в предыдущей операции
   JUPCCIX=JurXSeries(0,0,MaxBar-30,limit,JCCIX.Length,UPCCI,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   JDNCCIX=JurXSeries(1,0,MaxBar-30,limit,JCCIX.Length,DNCCI,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   //----+
   if (bar>MaxBar-30-w)JCCIX=0;
   else 
     if (JDNCCIX!=0)
       {
        JCCIX=JUPCCIX/JDNCCIX;
        if(JCCIX>1)JCCIX=1;
        if(JCCIX<-1)JCCIX=-1;
       }
     else JCCIX=0;
   Ind_Buffer1[bar]=JCCIX; 
   //----+
 }
//----
   return(0);
  }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
//----+ Введение функции JJMASeriesReset  (дополнительная функция файла JJMASeries.mqh)
//----+ Введение функции INDICATOR_COUNTED(дополнительная функция файла JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции JurXSeries (файл JurXSeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
//----+ Введение функции JurXSeriesReset (дополнительная функция файла JurXSeries.mqh)
#include <JurXSeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции PriceSeries, файл PriceSeries.mqh следует положить в папку (директорию): MetaTrader\experts\include
//----+ Введение функции PriceSeriesAlert (дополнительная функция файла PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+


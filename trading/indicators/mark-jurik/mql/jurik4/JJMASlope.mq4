/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh и 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+------------------------------------------------------------------+  
//|                                                         JJMA.mq4 | 
//|               MQL4+J2JMA: Copyright © 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2006, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_separate_window 
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_width1 3
#property indicator_width2 3 

//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА --------------------------------------------------------------------------------------------------+
extern int Length = 14;   // глубина JMA сглаживания 
extern int Phase  =  0; // параметр JMA сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Input_Price_Customs = 0;/* Выбор цен, по которым производится расчёт индикатора 
(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.) */
//---- -------------------------------------------------------------------------------------------------------------------------------+
//---- индикаторные буферы
double UpBuffer [];
double DnBuffer [];
double JJMA[];
//---- переменные с плавающей точкой  
double Temp_Series,Resalt;
//+------------------------------------------------------------------+  
//----+ Введение функции JJMASeries 
//----+ Введение функции JJMASeriesResize 
//----+ Введение функции JJMASeriesAlert  
//----+ Введение функции JMA_ErrDescr  
#include <JJMASeries.mqh> 
//+------------------------------------------------------------------+  
//----+ Введение функции PriceSeries
//----+ Введение функции PriceSeriesAlert 
#include <PriceSeries.mqh>
//+------------------------------------------------------------------+    
//| JJMA indicator initialization function                           | 
//+------------------------------------------------------------------+  
int init() 
{  
//---- определение стиля исполнения графика
IndicatorBuffers(3);
SetIndexStyle  (0, DRAW_HISTOGRAM);
SetIndexStyle  (1, DRAW_HISTOGRAM);
SetIndexBuffer (0, UpBuffer);
SetIndexBuffer (1, DnBuffer); 
SetIndexBuffer (2, JJMA);
SetIndexDrawBegin(0, 31);//2*Length+1);
SetIndexDrawBegin(1, 31);//2*Length+1);
//---- установка значений индикатора, которые не будут видимы на графике
SetIndexEmptyValue(0,0.0);    
SetIndexEmptyValue(1,0.0);
//---- имя для окон данных и лэйба для субъокон 
IndicatorShortName ("JJMASlope( Length="+Length+", Phase="+Phase+")"); 
SetIndexLabel (0, "JJMA UpTrend");
SetIndexLabel (1, "JJMA DnTrend"); 
//---- Установка формата точности отображения индикатора
IndicatorDigits(Digits);
//---- установка алертов на недопустимые значения внешних переменных
JJMASeriesAlert (0,"Length",Length);
JJMASeriesAlert (1,"Phase", Phase);
PriceSeriesAlert(Input_Price_Customs);
//----+ Изменение размеров буферных переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции JJMASeries)
if (JJMASeriesResize(1)!=1)return(-1);
//---- завершение инициализации
return(0); 
} 
//+------------------------------------------------------------------+  
//| JJMA iteration function                                          | 
//+------------------------------------------------------------------+  
int start() 
{ 
//---- Проверка количества баров на достаточность для дальнейшего расчёта
if (Bars-1<31)return(0);
//----+ Введение целых переменных и получение уже подсчитанных баров
int reset,MaxBar,counted_bars=IndicatorCounted();
//---- проверка на возможные ошибки
if (counted_bars<0)return(-1);
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
MaxBar=Bars-1; int limit=MaxBar-counted_bars;

//----+ ОСНОВНОЙ ЦИКЛ ВЫЧИСЛЕНИЯ ИНДИКАТОРА 
for(int bar=limit;bar>=0;bar--)
  {
    //----+ Обращение к функции PriceSeries для получения входной цены Series
    Temp_Series=PriceSeries(Input_Price_Customs, bar);
    //----+ Обращение к функции JJMASeries за номерам 0. Параметры nJMA.Phase и nJMA.Length не меняются на каждом баре (nJMA.din=0)
    Resalt=JJMASeries(0,0,MaxBar,limit,Phase,Length,Temp_Series,bar,reset);
    //----+ проверка на отсутствие ошибки в предыдущей операции
    if(reset!=0)return(-1);
    JJMA[bar]=Resalt;
    double rel=(JJMA[bar]-JJMA[bar+1])/Point;
    if(rel>=0)
    {
    UpBuffer[bar]=rel; 
    DnBuffer[bar]=0;
    }
    else
    { 
    DnBuffer[bar]=rel;
    UpBuffer[bar]=0;
    } 
  }
//---- завершение вычислений значений индикатора
return(0); 
} 

//+--------------------------------------------------------+
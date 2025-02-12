/*
Для  работы  индикатора  следует  положить файлы 

JurXSeries.mqh, 
PriceSeries.mqh,  
INDICATOR_COUNTED.mqh   
в папку (директорию): MetaTrader\experts\include\

Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\

В основе  этого  индикатора  лежит  алгоритм сглаживания от индикатора 
JRSX.    Конечный результат этого алгоритма имеет некоторое сходство с 
двойным JMA сглаживанием, но в силу большей простоты менее совершенен.
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                         JurX.mq4 | 
//|                JurX code: Copyright © 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|                MQL4+JurX: Copyright © 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 1 
//---- цвет индикатора
#property indicator_color1 Yellow
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Length  = 5; // глубина  первого сглаживания 
extern int Shift   = 0; // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_Buffer[];
//---- переменные с плавающей точкой  
double Temp_Series,JurX;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JurX indicator initialization function                           | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{  
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE); 
//---- 1 индикаторный буффер использован для счёта
SetIndexBuffer(0,Ind_Buffer);
//---- горизонтальный сдвиг индикаторной линии 
SetIndexShift (0, Shift); 
//---- установка значений индикатора, которые не будут видимы на графике
SetIndexEmptyValue(0,0); 
//---- имя для окон данных и лэйба для субъокон. 
IndicatorShortName ("JurX( Length="+Length+", Shift="+Shift+")"); 
SetIndexLabel (0, "JurX"); 
//----
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- установка алертов на недопустимые значения входных параметров =======================================================+ 
if(Length<1){Alert("Параметр Length должен быть не менее 1" + " Вы ввели недопустимое " +Length+ " будет использовано 1");}
PriceSeriesAlert(Input_Price_Customs);
//+=========================================================================================================================+
//---- завершение инициализации
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JurX iteration function                                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,MaxBar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан (без этого пересчёта для counted_bars функция JurXSeries будет работать некорректно!!!)
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функций JurXSeries, nJurXnumber=1(Одно  обращение к функции)
if (counted_bars==0)JurXSeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
int limit=Bars-counted_bars-1; MaxBar=Bars-1-2*Length; 

//----+ ОСНОВНОЙ ЦИКЛ ВЫЧИСЛЕНИЯ ИНДИКАТОРА 
for(int bar=limit;bar>=0;bar--)
 {
  //----+ Обращение к функции PriceSeries для получения входной цены Series
  Temp_Series=PriceSeries(Input_Price_Customs,bar);
  //----+ Одно обращение к функции JurXSeries за номером 0. Параметр nJJurXLength не меняtтся на каждом баре (nJurXdin=0)
  JurX=JurXSeries(0,0,MaxBar,limit,Length,Temp_Series,bar,reset); 
  //----+ проверка на отсутствие ошибки в предыдущей операции
  if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}  
  Ind_Buffer[bar]=JurX;                 
 }
//---- завершение вычислений значений индикатора
return(0); 
} 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции INDICATOR_COUNTED (файл INDICATOR_COUNTED.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции JurXSeries (файл JurXSeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
//----+ Введение функции JurXSeriesReset (дополнительная функция файла JurXSeries.mqh)
#include <JurXSeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции PriceSeries, файл PriceSeries.mqh следует положить в папку (директорию): MetaTrader\experts\include
//----+ Введение функции PriceSeriesAlert (дополнительная функция файла PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+
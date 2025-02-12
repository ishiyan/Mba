/*
Для работы индикатора  следует  положить  файлы  
INDICATOR_COUNTED.mqh    
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\

Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\

По своим  свойствам  этот  индикатор абсолютно аналогичен классическим
осциляторам  и к нему применимы абсолютно те же приёмы теханализа, что
и  к  RSI. Только благодаря использованию более совершенных алгоритмов
сглаживания он имеет меньшее запаздывание и более глакую форму кривой.
//---- 
Relative   Strenght  Index  (RSI)
Индекс относительной силы - это следующий за ценой осциллятор, который
колеблется  в  диапазоне от 0 до 100. Один из распространенных методов
анализа  RSI  состоит  в поиске расхождений, при которых цена образует
новый максимум, а RSI не удается преодолеть уровень своего предыдущего
максимума.   Подобное   расхождение   свидетельствует   о  вероятности
разворота  цен.  Если  затем  RSI  поворачивает вниз и опускается ниже
своей   впадины,   то   он   завершает   так  называемый  'неудавшийся
размах'(failure    swing).    Этот    неудавшийся   размах   считается
подтверждением  скорого  разворота  цен.  Способы  применения  RSI для
анализа графиков:
1.  Вершины  и  основания  Вершины  RSIобычно  формируются  выше 70, а
основания  - ниже 30, причем они обычно опережают образования вершин и
оснований на ценовом графике.
2.  Графические  модели  RSI часто образует графические модели - такие
как  'голова  и  плечи'  или  треугольники, которые на ценовом графике
могут   и  не  обозначиться.
3.  Неудавшийся  размах  (прорыв  уровня  поддержки или сопротивления)
Имеет  место,  когда RSI поднимается выше предыдущего максимума (пика)
или опускается ниже предыдущего минимума (впадина).
4.  Уровни поддержки и сопротивления На графике RSI уровни поддержки и
сопротивления проступают даже отчетливее, чем на ценовом графике.
5.  Расхождения  Как  уже  сказано выше, расхождения образуются, когда
цена  достигает  нового  максимума (минимума), но он не подтверждается
новым   максимумом   (минимумом)  на  графике  RSI.  При  этом  обычно
происходит коррекция цен в направлении движения RSI.
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                       JRSX.s.mq4 |
//|          JRSX: Copyright © 2005,            Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
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
extern int  JRSX.Length = 8;  // глубина сглаживания индикатора
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_Buffer1[];
//---- целые переменные 
int    w;
//---- переменные с плавающей точкой 
double v8,v14,v20,v8A;   
double JRSX; 

//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JRSX initialization function                                     |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- стили изображения индикатора
   SetIndexStyle(0,DRAW_LINE);
//---- 1 индикаторныQ буффер использован для счёта. 
   SetIndexBuffer(0,Ind_Buffer1);
//---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,0); 
//---- имена для окон данных и лэйбы для субъокон.
   SetIndexLabel(0,"JRSX");
   IndicatorShortName("JRSX(JRSX.Length="+JRSX.Length+", Input_Price_Customs="+Input_Price_Customs+")");
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора  
   IndicatorDigits(0);
//---- установка алертов на недопустимые значения входных параметров =======================================================================+ 
if(JRSX.Length< 1) {Alert("Параметр JRSX.Length должен быть не менее 1"+ " Вы ввели недопустимое "+JRSX.Length+ " будет использовано 1");}//|
PriceSeriesAlert(Input_Price_Customs);//---- обращение к функции PriceSeriesAlert //////////////////////////////////////////////////////////|
//---- =====================================================================================================================================+ 
//---- установка номера бара, начиная с которого будет отрисовываться индикатор  
   SetIndexDrawBegin(0,JRSX.Length+1);
//---- корекция недопустимого значения параметра JRSX.Length
   if(JRSX.Length<1)JRSX.Length=1; 
//---- инициализация коэффициентов для расчёта индикатора 
   if (JRSX.Length>5) w=JRSX.Length-1; else w=5;
//---- завершение инициализации
return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JRSX iteration function                                          |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
{
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int bar,limit,reset,MaxBar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JurXSeries, nJurXnumber=2(Два обращения к функции JurXSeries)
if (counted_bars==0)JurXSeriesReset(2);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
MaxBar=Bars-2; limit=Bars-counted_bars-1; 
//----+ 
if (bar>MaxBar){bar=MaxBar;Ind_Buffer1[bar]=0.0;}

bar=limit;
while (bar>=0)
{
//----+ два обращения к функции PriceSeries для получения разницы входных цен v8
v8 = PriceSeries(Input_Price_Customs, bar)-PriceSeries(Input_Price_Customs, bar+1);
//----+  
v8A=MathAbs(v8);
//----+ Два обращения к функции JurXSeries за номерами 0 и 1. Параметр nJJurXLength не меняtтся на каждом баре (nJurXdin=0), проверка на отсутствие ошибки в предыдущей операции
v14=JurXSeries(0,0,MaxBar,limit,JRSX.Length,v8, bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
v20=JurXSeries(1,0,MaxBar,limit,JRSX.Length,v8A,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
//----+
if (bar>MaxBar-w)JRSX=0;else if (v20!=0){JRSX=v14/v20;if(JRSX>1)JRSX=1;if(JRSX<-1)JRSX=-1;}else JRSX=0;

Ind_Buffer1[bar]=JRSX; 

//----+
bar--;
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



/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                        J2JMA.mq4 | 
//|                 JMA code: Copyright © 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|               MQL4+J2JMA: Copyright © 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 1 
//---- цвет индикатора
#property indicator_color1 Magenta 
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Length1 = 5; // глубина  первого сглаживания 
extern int Length2 = 5; // глубина  второго сглаживания 
extern int Phase1  = 5; // параметр первого сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Phase2  = 5; // параметр второго сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Shift   = 0; // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double J2JMA[];
//---- переменные с плавающей точкой  
double Temp_Series;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| J2JMA indicator initialization function                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{  
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE); 
//---- 1 индикаторный буффер использован для счёта
SetIndexBuffer(0,J2JMA);
//---- горизонтальный сдвиг индикаторной линии 
SetIndexShift (0, Shift);  
//---- установка значений индикатора, которые не будут видимы на графике
SetIndexEmptyValue(0,0); 
//---- имя для окон данных и лэйба для субъокон. 
IndicatorShortName ("J2JMA( Length1="+Length1+", Phase1="+Phase1+", Length2="+Length2+", Phase2="+Phase2+", Shift="+Shift+")"); 
SetIndexLabel (0, "J2JMA"); 
//----
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- установка алертов на недопустимые значения входных параметров =================================================================+ 
if(Phase1<-100){Alert("Параметр Phase1 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase1+  " будет использовано -100");}
if(Phase1> 100){Alert("Параметр Phase1 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase1+  " будет использовано  100");}
if(Phase2<-100){Alert("Параметр Phase2 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase2+  " будет использовано -100");}
if(Phase2> 100){Alert("Параметр Phase2 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase2+  " будет использовано  100");}
if(Length1<  1){Alert("Параметр Length1 должен быть не менее 1"     + " Вы ввели недопустимое " +Length1+ " будет использовано  1"  );}
if(Length2<  1){Alert("Параметр Length2 должен быть не менее 1"     + " Вы ввели недопустимое " +Length2+ " будет использовано  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+===================================================================================================================================+
//---- завершение инициализации
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| J2JMA iteration function                                         | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,MaxBar1,MaxBar2,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
//---- (без этого пересчёта для counted_bars функция JJMASeries будет работать некорректно!!!)
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=2(Два обращения к функции JJMASeries)
if (counted_bars==0)JJMASeriesReset(2);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
int limit=Bars-counted_bars-1; MaxBar1=Bars-1; MaxBar2=MaxBar1-30;

//----+ ОСНОВНОЙ ЦИКЛ ВЫЧИСЛЕНИЯ ИНДИКАТОРА 
for(int bar=limit;bar>=0;bar--)
{
//----+ Обращение к функции PriceSeries для получения входной цены Series
Temp_Series=PriceSeries(Input_Price_Customs, bar);
//+----------------------------------------------------------------------------+ 
//----+ Два обращения к функции JJMASeries за номерами 0, 1. Параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
//(Во втором  обращении параметр nJMAMaxBar  уменьшен на 30  т. к. это повторное JMA сглаживание)
//+----------------------------------------------------------------------------+   
Temp_Series=JJMASeries(0,0,MaxBar1,limit,Phase1,Length1,Temp_Series,bar,reset);
//----+ проверка на отсутствие ошибки в предыдущей операции
if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
//+----------------------------------------------------------------------------+ 
Temp_Series=JJMASeries(1,0,MaxBar2,limit,Phase2,Length2,Temp_Series,bar,reset);
//----+ проверка на отсутствие ошибки в предыдущей операции
if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
//+----------------------------------------------------------------------------+ 
J2JMA[bar]=Temp_Series;
}
//---- завершение вычислений значений индикатора
return(0); 
} 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
//----+ Введение функции JJMASeriesReset  (дополнительная функция файла JJMASeries.mqh)
//----+ Введение функции INDICATOR_COUNTED(дополнительная функция файла JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции PriceSeries, файл PriceSeries.mqh следует положить в папку (директорию): MetaTrader\experts\include
//----+ Введение функции PriceSeriesAlert (дополнительная функция файла PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+
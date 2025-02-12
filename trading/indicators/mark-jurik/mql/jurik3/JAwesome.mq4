/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                     JAwesome.mq4 |
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буфферов
#property  indicator_buffers 3
//---- цвета индикатора
#property indicator_color1  MediumSeaGreen
#property indicator_color2  Red
#property indicator_color3  Gray
//---- толщина индикаторных линий
#property indicator_width1 3
#property indicator_width2 2 
#property indicator_width3 2
//---- стиль огибающей линии индикатора
#property indicator_style1 4
//---- параметры горизонтальных уровней индикатора
#property indicator_level1 0.0
#property indicator_levelcolor Blue
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int FastJMA=05;   // глубина сглаживания быстрой JMA
extern int SlowJMA=34;   // глубина сглаживания медленной JMA
extern int JMACD_Phase = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов JMACD  
extern int Input_Price_Customs = 4;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double     Ind_Buffer0[];
double     Ind_Buffer1[];
double     Ind_Buffer2[];
//---- переменные с плавающей точкой
double JMACD,FastJ,SlowJ,Signal,Temp_Series,trend;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JAwesome initialization function                                 |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- стили изображения индикатора
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора    
   IndicatorDigits(0);
//---- установка номера бара, начиная с которого будет отрисовываться индикатор    
   SetIndexDrawBegin(0,61);
   SetIndexDrawBegin(1,61);
   SetIndexDrawBegin(2,61);
//---- 3 индикаторных буфферов использованы для счёта.
   SetIndexBuffer(0,Ind_Buffer0);
   SetIndexBuffer(1,Ind_Buffer1);
   SetIndexBuffer(2,Ind_Buffer2);
//---- имена для окон данных и лэйбы для субъокон.
   IndicatorShortName("JAwesome");
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
//---- установка алертов на недопустимые значения входных параметров =====================================================================================+ 
if(JMACD_Phase<-100) {Alert("Параметр JMACD_Phase должен быть от -100 до +100" +  " Вы ввели недопустимое " +JMACD_Phase+    " будет использовано -100");}
if(JMACD_Phase> 100) {Alert("Параметр JMACD_Phase должен быть от -100 до +100" +  " Вы ввели недопустимое " +JMACD_Phase+    " будет использовано  100");}
if(FastJMA<  1)      {Alert("Параметр FastJMA должен быть не менее 1"     + " Вы ввели недопустимое " +FastJMA+  " будет использовано  1"  );}
if(SlowJMA<  1)      {Alert("Параметр SlowJMA должен быть не менее 1"     + " Вы ввели недопустимое " +SlowJMA+  " будет использовано  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+=======================================================================================================================================================+    
//---- завершение инициализации
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Awesome Oscillator                                               |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,MaxBar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
//---- (без этого пересчёта для counted_bars функция JJMASeries будет работать некорректно!!!)
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=2(Два обращения к функции JJMASeries)
if (counted_bars==0)JJMASeriesReset(2);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBar=Bars-1; 

for(int bar=limit; bar>=0; bar--)
 {
   //----+ Обращение к функции PriceSeries для получения входной цены Series
   Temp_Series=PriceSeries(Input_Price_Customs, bar);
   //+----------------------------------------------------------------------------+ 
   //----+ Два обращения к функции JJMASeries за номерами 0, 1. 
   //----+ Параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
   //+----------------------------------------------------------------------------+   
   FastJ=JJMASeries(0,0,MaxBar,limit,JMACD_Phase,FastJMA,Temp_Series,bar,reset);
   //----+ проверка на отсутствие ошибки в предыдущей операции
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
   //+----------------------------------------------------------------------------+ 
   SlowJ=JJMASeries(1,0,MaxBar,limit,JMACD_Phase,SlowJMA,Temp_Series,bar,reset);
   //----+ проверка на отсутствие ошибки в предыдущей операции
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   //+----------------------------------------------------------------------------+ 
   
   JMACD=FastJ-SlowJ;
   //----+ изменение единицы измерения JMACD до пунктов  
   JMACD=JMACD/Point;
   //---- +SSSSSSSSSSSSSSSS <<< Трёхцветный код индикатора >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
   trend=JMACD-Ind_Buffer0[bar+1]-Ind_Buffer1[bar+1]-Ind_Buffer2[bar+1];     
   if     (trend>0){Ind_Buffer0[bar]=JMACD; Ind_Buffer1[bar]=0;     Ind_Buffer2[bar]=0;}
   else{if(trend<0){Ind_Buffer0[bar]=0;     Ind_Buffer1[bar]=JMACD; Ind_Buffer2[bar]=0;}
   else            {Ind_Buffer0[bar]=0;     Ind_Buffer1[bar]=0;     Ind_Buffer2[bar]=JMACD;}}    
   //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+    
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
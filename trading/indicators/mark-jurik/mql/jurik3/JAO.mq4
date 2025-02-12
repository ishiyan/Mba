/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                          JAO.mq4 |
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буфферов
#property  indicator_buffers 4
//---- цвета индикатора
#property indicator_color1  Blue
#property indicator_color2  Gold
#property indicator_color3  Magenta
#property indicator_color4  Gray
//---- толщина индикаторных линий
#property indicator_width1 0
#property indicator_width2 2 
#property indicator_width3 2
#property indicator_width4 2
//---- стиль огибающей линии индикатора
#property indicator_style1 4
//---- параметры горизонтальных уровней индикатора
#property indicator_level1 0.0
#property indicator_levelcolor Blue
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int FastJMA=05;   // глубина сглаживания быстрой JMA
extern int SlowJMA=34;   // глубина сглаживания медленной JMA
extern int SignJMA=05;   // глубина сглаживания сигнальной JMA
extern int JMACD_Phase = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов JMACD 
extern int Sign_Phase  = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов сигнальной линии 
extern int Input_Price_Customs = 4;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double     Ind_Buffer0[];
double     Ind_Buffer1[];
double     Ind_Buffer2[];
double     Ind_Buffer3[];
//---- переменные с плавающей точкой
double JMACD,JAccelerator,FastJ,SlowJ,Signal,Temp_Series,trend;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JAccelerator initialization function                             |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- стили изображения индикатора
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора    
   IndicatorDigits(0);
//---- установка номера бара, начиная с которого будет отрисовываться индикатор    
   SetIndexDrawBegin(0,61);
   SetIndexDrawBegin(1,61);
   SetIndexDrawBegin(2,61);
   SetIndexDrawBegin(3,61);
//---- 4 индикаторных буфферов использованы для счёта.
   IndicatorBuffers(4);
   SetIndexBuffer(0,Ind_Buffer0);
   SetIndexBuffer(1,Ind_Buffer1);
   SetIndexBuffer(2,Ind_Buffer2);
   SetIndexBuffer(3,Ind_Buffer3);
//---- имена для окон данных и лэйбы для субъокон.
   IndicatorShortName("JAccelerator");
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
//---- установка алертов на недопустимые значения входных параметров =====================================================================================+ 
if(JMACD_Phase<-100) {Alert("Параметр JMACD_Phase должен быть от -100 до +100" +  " Вы ввели недопустимое " +JMACD_Phase+    " будет использовано -100");}
if(JMACD_Phase> 100) {Alert("Параметр JMACD_Phase должен быть от -100 до +100" +  " Вы ввели недопустимое " +JMACD_Phase+    " будет использовано  100");}
if(Sign_Phase<-100)  {Alert("Параметр Sign_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Sign_Phase+   " будет использовано -100");}
if(Sign_Phase> 100)  {Alert("Параметр Sign_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Sign_Phase+   " будет использовано  100");}
if(FastJMA<  1)      {Alert("Параметр FastJMA должен быть не менее 1"     + " Вы ввели недопустимое " +FastJMA+  " будет использовано  1"  );}
if(SlowJMA<  1)      {Alert("Параметр SlowJMA должен быть не менее 1"     + " Вы ввели недопустимое " +SlowJMA+  " будет использовано  1"  );}
if(SignJMA<1)        {Alert("Параметр SignJMA должен быть не менее 1"   + " Вы ввели недопустимое " +SignJMA+" будет использовано  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+=======================================================================================================================================================+    
//---- завершение инициализации
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JAccelerator/Decelerator Oscillator                              |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
{
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,MaxBar1,MaxBar2,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
//---- (без этого пересчёта для counted_bars функция JJMASeries будет работать некорректно!!!)
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=3(Три обращения к функции)  
if (counted_bars==0)JJMASeriesReset(3);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBar1=Bars-1; MaxBar2=MaxBar1-30;

for(int bar=limit; bar>=0; bar--)
 {
   //----+ Обращение к функции PriceSeries для получения входной цены Series
   Temp_Series=PriceSeries(Input_Price_Customs, bar);
   //+----------------------------------------------------------------------------+ 
   //----+ Два обращения к функции JJMASeries за номерами 0, 1. 
   //----+ Параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
   //+----------------------------------------------------------------------------+   
   FastJ=JJMASeries(0,0,MaxBar1,limit,JMACD_Phase,FastJMA,Temp_Series,bar,reset);
   //----+ проверка на отсутствие ошибки в предыдущей операции
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
   //+----------------------------------------------------------------------------+ 
   SlowJ=JJMASeries(1,0,MaxBar1,limit,JMACD_Phase,SlowJMA,Temp_Series,bar,reset);
   //----+ проверка на отсутствие ошибки в предыдущей операции
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   //+----------------------------------------------------------------------------+    
   JMACD=FastJ-SlowJ;
   //----+ изменение единицы измерения JMACD до пунктов  
   JMACD=JMACD/Point;  
   //+----------------------------------------------------------------------------+ 
   //----+ Обращение к функции JJMASeries за номерам 2. 
   //----+ Параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
   //+----------------------------------------------------------------------------+   
   Signal=JJMASeries(2,0,MaxBar2,limit,Sign_Phase,SignJMA,JMACD,bar,reset);
   //----+ проверка на отсутствие ошибки в предыдущей операции
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
   //+----------------------------------------------------------------------------+ 
   JAccelerator=JMACD-Signal; 
   Ind_Buffer0[bar]=JAccelerator;
   //---- +SSSSSSSSSSSSSSSS <<< Трёхцветный код индикатора >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
   trend=JAccelerator-Ind_Buffer0[bar+1];     
   if     (trend>0){Ind_Buffer1[bar]=JAccelerator; Ind_Buffer2[bar]=0;            Ind_Buffer3[bar]=0;}
   else{if(trend<0){Ind_Buffer1[bar]=0;            Ind_Buffer2[bar]=JAccelerator; Ind_Buffer3[bar]=0;}
   else            {Ind_Buffer1[bar]=0;            Ind_Buffer2[bar]=0;            Ind_Buffer3[bar]=JAccelerator;}}    
   //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+    
 }
 if(limit>=MaxBar2-1){int iii=MaxBar2-1;Ind_Buffer1[iii]=0;Ind_Buffer2[iii]=0;Ind_Buffer3[iii]=0;}
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
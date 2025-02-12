/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                     3c_JMACD.mq4 | 
//|                 JMA code: Copyright © 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|                 3c_JMACD: Copyright © 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буфферов
#property indicator_buffers 5
//---- цвета индикатора
#property indicator_color1  BlueViolet 
#property indicator_color2  Blue
#property indicator_color3  Magenta
#property indicator_color4  Gray
#property indicator_color5  Red
//---- толщина индикаторных линий
#property indicator_width1 0
#property indicator_width2 3 
#property indicator_width3 3
#property indicator_width4 4
//---- стиль огибающей линии индикатора
#property indicator_style1 4
//---- стиль сигнальной линии индикатора
#property indicator_style5 4
//---- параметры горизонтальных уровней индикатора
#property indicator_level1 0.0
#property indicator_levelcolor Red 
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int FastJMA=12;   // глубина сглаживания быстрой JMA
extern int SlowJMA=26;   // глубина сглаживания медленной JMA
extern int SignalJMA=9;  // глубина сглаживания сигнальной JMA
extern int JMACD_Phase  = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов JMACD 
extern int Signal_Phase = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов сигнальной линии 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_buffer1[];
double Ind_buffer2[];
double Ind_buffer3[];
double Ind_buffer4[];
double Ind_buffer5[];
//---- переменные с плавающей точкой 
double F.JMA,S.JMA,JMACD,Series,trend,Signal;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACD initialization function                                    |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- стили изображения индикатора
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(4,DRAW_LINE);
//---- 4 индикаторных буффера использованы для счёта.
if(!SetIndexBuffer(0,Ind_buffer1)&& 
   !SetIndexBuffer(1,Ind_buffer2)&& 
   !SetIndexBuffer(2,Ind_buffer3)&& 
   !SetIndexBuffer(3,Ind_buffer4)&& 
   !SetIndexBuffer(4,Ind_buffer5))
   Print("cannot set indicator buffers!");
//---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,0.0);  
   SetIndexEmptyValue(1,0.0); 
   SetIndexEmptyValue(2,0.0); 
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);  
//---- имена для окон данных и лэйбы для субъокон.
   IndicatorShortName("JMACD("+FastJMA+","+SlowJMA+","+SignalJMA+")");
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,"Up_Trend");
   SetIndexLabel(2,"Down_Trend");
   SetIndexLabel(3,"Straight_Trend");
   SetIndexLabel(4,"Signal");
   //---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора    
   IndicatorDigits(0);
//---- установка алертов на недопустимые значения входных параметров =====================================================================================+ 
if(JMACD_Phase<-100) {Alert("Параметр JMACD_Phase должен быть от -100 до +100" +  " Вы ввели недопустимое " +JMACD_Phase+    " будет использовано -100");}
if(JMACD_Phase> 100) {Alert("Параметр JMACD_Phase должен быть от -100 до +100" +  " Вы ввели недопустимое " +JMACD_Phase+    " будет использовано  100");}
if(Signal_Phase<-100){Alert("Параметр Signal_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Signal_Phase+   " будет использовано -100");}
if(Signal_Phase> 100){Alert("Параметр Signal_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Signal_Phase+   " будет использовано  100");}
if(FastJMA<  1){Alert("Параметр FastJMA должен быть не менее 1"     + " Вы ввели недопустимое " +FastJMA+  " будет использовано  1"  );}
if(SlowJMA<  1){Alert("Параметр SlowJMA должен быть не менее 1"     + " Вы ввели недопустимое " +SlowJMA+  " будет использовано  1"  );}
if(SignalJMA<1){Alert("Параметр SignalJMA должен быть не менее 1"   + " Вы ввели недопустимое " +SignalJMA+" будет использовано  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+=======================================================================================================================================================+    
//---- завершение инициализации
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACD iteration function                                         |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
  {
   //----+ Введение целых переменных и получение уже подсчитанных баров
   //---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
   int reset,limit,MaxBar,MaxBarS,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
   //---- проверка на возможные ошибки
   if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
   //---- последний подсчитанный бар должен быть пересчитан
   if (counted_bars>0) counted_bars--;
   //----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAJMAnumber=3(Три обращенния к функции) 
   if (counted_bars==0)JJMASeriesReset(3);
   //---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
   limit=Bars-counted_bars-1; MaxBar=Bars-1; MaxBarS=MaxBar-30;
   
   //----+ ОСНОВНОЙ ЦИКЛ ВЫЧИСЛЕНИЯ ИНДИКАТОРА JMACD
   for(int bar=limit; bar>=0; bar--)
    {
     //----+ Обращение к функции PriceSeries для получения входной цены Series
     Series=PriceSeries(Input_Price_Customs, bar);  
       
     //----+ Два Обращения к функции JJMASeries за номерами 0, 1. Параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
     F.JMA=JJMASeries(0,0,MaxBar,limit,JMACD_Phase,FastJMA,Series,bar,reset);
     //----+ проверка на отсутствие ошибки в предыдущей операции
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
     //+---------------------------------------------------------------------+
     S.JMA=JJMASeries(1,0,MaxBar,limit,JMACD_Phase,SlowJMA,Series,bar,reset);
     //----+ проверка на отсутствие ошибки в предыдущей операции
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
     //+---------------------------------------------------------------------+
     //----+ Формула для JMACD
     JMACD=F.JMA-S.JMA;
     //----+ изменение единицы измерения JMACD до пунктов  
     JMACD = JMACD/Point;
     Ind_buffer1[bar]=JMACD;
     
     //---- +SSSSSSSSSSSSSSSS <<< Трёхцветный код индикатора >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
     trend=JMACD-Ind_buffer1[bar+1];     
     if(trend>0.0)     {Ind_buffer2[bar]=JMACD;  Ind_buffer3[bar]=0.0;    Ind_buffer4[bar]=0.0;}
     else{if(trend<0.0){Ind_buffer2[bar]=0.0;    Ind_buffer3[bar]=JMACD;  Ind_buffer4[bar]=0.0;}
     else              {Ind_buffer2[bar]=0.0;    Ind_buffer3[bar]=0.0;    Ind_buffer4[bar]=JMACD;}}    
     //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
     
     //----+ Обращение к функции JJMASeries за номером 2, (nJMAdin=0, В этом обращении параметр nJMAMaxBar уменьшен на 30  т. к. это повторное JMA сглаживание) 
     Signal=JJMASeries(2,0,MaxBarS,limit,Signal_Phase,SignalJMA,JMACD,bar,reset);
     //----+ проверка на отсутствие ошибки в предыдущей операции
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
     Ind_buffer5[bar]=Signal;
   }
   if(limit>=MaxBar-31){int iii=MaxBar-31;Ind_buffer2[iii]=0;Ind_buffer3[iii]=0;Ind_buffer4[iii]=0;} 
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
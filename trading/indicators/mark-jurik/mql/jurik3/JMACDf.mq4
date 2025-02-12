/*
Для  работы  индикатора  следует  положить файлы 

JJMASeries.mqh 
и PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
JFatl.mq4
в папку (директорию): MetaTrader\experts\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                       JMACDf.mq4 | 
//|                 JMA code: Copyright © 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|                   JMACDf: Copyright © 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буфферов
#property indicator_buffers 2
//---- цвета индикатора 
#property indicator_color1  Gray
#property indicator_color2  Red
//---- толщина индикаторных линий
#property indicator_width1 3
//---- стиль сигнальной линии индикатора
#property indicator_style2 4
//---- параметры горизонтальных уровней индикатора
#property indicator_level1 0.0
#property indicator_levelcolor Blue 
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int FastJFatl=12;   // глубина сглаживания быстрого JFatl
extern int SlowJFatl=26;   // глубина сглаживания медленного JFatl
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
//---- переменные с плавающей точкой 
double Fast.JFATL,Slow.JFATL,JMACDf,Series,Signal;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACDf initialization function                                   |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- стили изображения индикатора
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(1,DRAW_LINE);
//---- 2 индикаторных буффера использованы для счёта.
if(!SetIndexBuffer(0,Ind_buffer1)&& 
   !SetIndexBuffer(1,Ind_buffer2))
   Print("cannot set indicator buffers!");
   //---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,0.0);  
   SetIndexEmptyValue(1,0.0); 
//---- имена для окон данных и лэйбы для субъокон.
   IndicatorShortName("JMACDf("+FastJFatl+","+SlowJFatl+","+SignalJMA+")");
   SetIndexLabel(0,"JMACDf");
   SetIndexLabel(1,"Signal");
   //---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора    
   IndicatorDigits(0);
//---- установка алертов на недопустимые значения входных параметров ===================================================================================+ 
if(JMACD_Phase<-100) {Alert("Параметр JMACD_Phase  должен быть от -100 до +100" + " Вы ввели недопустимое " +JMACD_Phase+ " будет использовано -100");}
if(JMACD_Phase> 100) {Alert("Параметр JMACD_Phase  должен быть от -100 до +100" + " Вы ввели недопустимое " +JMACD_Phase+ " будет использовано  100");}
if(Signal_Phase<-100){Alert("Параметр Signal_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Signal_Phase+" будет использовано -100");}
if(Signal_Phase> 100){Alert("Параметр Signal_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Signal_Phase+" будет использовано  100");}
if(FastJFatl<  1)    {Alert("Параметр FastJFatl должен быть не менее 1" + " Вы ввели недопустимое " +FastJFatl+  " будет использовано  1"  );}
if(SlowJFatl<  1)    {Alert("Параметр SlowJFatl должен быть не менее 1" + " Вы ввели недопустимое " +SlowJFatl+  " будет использовано  1"  );}
if(SignalJMA<1)      {Alert("Параметр SignalJMA должен быть не менее 1" + " Вы ввели недопустимое " +SignalJMA+"   будет использовано  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+=====================================================================================================================================================+    
//---- завершение инициализации
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACDf iteration function                                        |
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
   //----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции) 
   if (counted_bars==0)JJMASeriesReset(1);
   //---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
   MaxBar=Bars-1; MaxBarS=MaxBar-30;limit=MaxBar-counted_bars; 
   
   //----+ ОСНОВНОЙ ЦИКЛ ВЫЧИСЛЕНИЯ ИНДИКАТОРА JMACD
   for(int bar=limit; bar>=0; bar--)
    {
     //----+ Обращение к функции PriceSeries для получения входной цены Series
     Series=PriceSeries(Input_Price_Customs, bar);    
     //----+ Два Обращения к пользовательскому индикатору JFatl     
     Fast.JFATL= iCustom(NULL,0,"JFatl",FastJFatl,JMACD_Phase,0,Input_Price_Customs,0,bar);
     Slow.JFATL= iCustom(NULL,0,"JFatl",SlowJFatl,JMACD_Phase,0,Input_Price_Customs,0,bar);     
     //----+ Формула для JMACDf
     JMACDf=Fast.JFATL-Slow.JFATL;
     //----+ изменение единицы измерения JMACDf до пунктов  
     JMACDf = JMACDf/Point;
     Ind_buffer1[bar]=JMACDf;     
     //----+ Обращение к функции JJMASeries за номером 0, (nJMAdin=0) 
     Signal=JJMASeries(0,0,MaxBarS,limit,Signal_Phase,SignalJMA,JMACDf,bar,reset);
     //----+ проверка на отсутствие ошибки в предыдущей операции
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
     Ind_buffer2[bar]=Signal;
     //----+
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


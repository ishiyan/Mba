/*
Для  работы  индикатора  следует  положить файл 
JJMASeries.mqh 
(директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\

              "Описание индикатора Т.ДеМарка " 
Во   вногие   пакеты   технического  включен  индикатор,  предложенный
Т.ДеМарком.  Близкий  по  смыслу  к  DMI,  но более просто вычисляемый
(DEMARK  в  отличие  от ADX, учитывает только экстремальные цены, а не
цены   закрытия)  он  дает  наглядные  сигналы  и  наравне  с  другими
осцилляторами  может  быть  применен  для  построения торговых систем.
Определение индикатора: если сегодняшний high выше вчерашнего high, то
аккумулируем  соответствующие  разности,  если  сегодняшний  low  ниже
вчерашнего,  то отдельно аккумулируем соответствующие разности (и те и
другие  -  положительные  величины).  Количество  свечей n, по которым
происходит    аккумулирование    (усреднение),   является   параметром
индикатора,  равного дроби: DEMARK = (накопленные за n свечей разности
high  -  high[-1]) / (  (накопленные  за  n  свечей  разности   high -
high[-1])  +  (накопленные  за  n свечей разности low[-1] - low) ) При
вызове   индикатора  он  запрашивает  длину  окна  усреденения  n;  по
умолчанию  предлагается  значение  n  = 13. Чтение этого индикатора во
многом  аналогично  RSI:  он  также образует области перекупленности и
перепроданности,  часто показывает хорошие дивергенции. В то же время,
во  вмогих  ситуациях  он  может  иметь  преимущества, так  как  более 
полно учитывает структуру свечи.
                © 1997-2005, «FOREX CLUB»
     http://www.fxclub.org/academy_lib_article/article17.html
В данном индикаторе значения, полученные на основе алгоритма  Демарка,
сглажены  с  помощью  JMA  сглаживания  и  добавлена сигнальная линия, 
полученная дополнительным JMA сглаживанием. 
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                   3c_JDemark.mq4 | 
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буфферов
#property indicator_buffers  4
//---- цвета индикатора
#property indicator_color1  Blue
#property indicator_color2  Magenta
#property indicator_color3  Purple
#property indicator_color4  Aqua
//---- толщина индикаторных линий
#property indicator_width1 3
#property indicator_width2 3 
#property indicator_width3 3
//---- стиль сигнальной линии индикатора
#property indicator_style4 4
//---- параметры горизонтальных уровней индикатора
#property indicator_level1   50
#property indicator_level2  -50
#property indicator_level3   0
#property indicator_levelcolor DarkOrchid
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА -----+   
extern int Demark_Period = 13;
extern int Demark_Smooth = 3; 
extern int Smooth_Phase  = 100;
extern int Sign_Length   = 15;
extern int Sign_Phase    = 100;
//---- ----------------------------------+
//---- индикаторные буфферы
double Ind_Buffer1[];
double Ind_Buffer2[];
double Ind_Buffer3[];
double Ind_Buffer4[];
//---- переменные с плавающей точкой 
double MinHigh,MinLow,Up,Down,Demark,JDemark,trend,Signal;  
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JDemark initialization function                                  | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- 4 индикаторных буффера использованы для счёта.
if(!SetIndexBuffer(0,Ind_Buffer1) &&
   !SetIndexBuffer(1,Ind_Buffer2) &&
   !SetIndexBuffer(2,Ind_Buffer3) &&
   !SetIndexBuffer(3,Ind_Buffer4))
   Print("cannot set indicator buffers!");   
//---- стили изображения индикатора
   SetIndexStyle(0,DRAW_HISTOGRAM, STYLE_SOLID); 
   SetIndexStyle(1,DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(3,DRAW_LINE);
//---- имена для окон данных и лэйбы для субъокон.
   IndicatorShortName ("JDemark");
   SetIndexLabel(0,"Up_Trend");
   SetIndexLabel(1,"Down_Trend");
   SetIndexLabel(2,"Straight_Trend");
   SetIndexLabel(3,"Signal");
//---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0); 
   SetIndexEmptyValue(3,0); 
//---- установка алертов на недопустимые значения входных параметров ======================================================================================+ 
if(Smooth_Phase<-100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано -100");}//|
if(Smooth_Phase> 100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано  100");}//|
if(Sign_Phase<-100)  {Alert("Параметр Sign_Phase должен быть от -100 до +100"   + " Вы ввели недопустимое " +Sign_Phase+    " будет использовано -100");}//|
if(Sign_Phase> 100)  {Alert("Параметр Sign_Phase должен быть от -100 до +100"   + " Вы ввели недопустимое " +Sign_Phase+    " будет использовано  100");}//|
if(Demark_Smooth< 1) {Alert("Параметр Demark_Smooth должен быть не менее 1"     + " Вы ввели недопустимое " +Demark_Smooth+ " будет использовано  13");}///|
if(Demark_Period< 1) {Alert("Параметр Demark_Period должен быть не менее 1"     + " Вы ввели недопустимое " +Demark_Period+ " будет использовано  1");}////|
if(Sign_Length< 1)   {Alert("Параметр Sign_Length должен быть не менее 1"       + " Вы ввели недопустимое " +Sign_Length+   " будет использовано  1");}////|
//+========================================================================================================================================================+ 
//---- корекция недопустимого значения параметра Demark_Period
   if(Demark_Period<1)Demark_Period=1;
//---- установка номера бара, начиная с которого будет отрисовываться индикатор 
   int draw_begin=Demark_Period+1+30; 
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);  
   SetIndexDrawBegin(3,draw_begin+30);     
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора  
   IndicatorDigits(0);
//---- завершение инициализации   
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JDemark iteration function                                       | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
   { 
   //---- проверка на количества баров на достаточность для расчёта
   if (Bars-1<Demark_Period)return(0);  
   //----+ Введение целых переменных и получение уже подсчитанных баров
   //---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
   int reset,MaxBarD,MaxBarJ,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
   //---- проверка на возможные ошибки
   if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
   //---- последний подсчитанный бар должен быть пересчитан
   if (counted_bars>0) counted_bars--;
   //----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=2(Два  обращения к функции)
   if (counted_bars==0)JJMASeriesReset(2);
   //---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
   limit=Bars-counted_bars-1; MaxBarD=Bars-1-Demark_Period; MaxBarJ=MaxBarD-30; 
   //----+  
   for(int bar=limit; bar>=0; bar--) 
     {  
        //----+ Расчёт индикатора Демарка (обращение к техническому индикатору iDeMarker)  
        Demark=200*iDeMarker(NULL, 0, Demark_Period, bar)-100;
             
        //----+ Сглаживание готового индикатора
        //----+ ( Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0))
        JDemark=JJMASeries(0,0,MaxBarD,limit,Smooth_Phase,Demark_Smooth,Demark,bar,reset);
        //----+ проверка на отсутствие ошибки в предыдущей операции
        if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
                            
        //---- +SSSSSSSSSSSSSSSS <<< Трёхцветный код индикатора >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
        trend=JDemark-Ind_Buffer1[bar+1]-Ind_Buffer2[bar+1]-Ind_Buffer3[bar+1];     
        if     (trend>0){Ind_Buffer1[bar]=JDemark; Ind_Buffer2[bar]=0;       Ind_Buffer3[bar]=0;}
        else{if(trend<0){Ind_Buffer1[bar]=0;       Ind_Buffer2[bar]=JDemark; Ind_Buffer3[bar]=0;}
        else            {Ind_Buffer1[bar]=0;       Ind_Buffer2[bar]=0;       Ind_Buffer3[bar]=JDemark;}}    
        //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+  
        //----+ Вычисление сигнальной линии 
        //----+ ( Обращение к функции JJMASeries за номером 1, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0))
        Signal=JJMASeries(1,0,MaxBarJ,limit,Sign_Phase,Sign_Length,JDemark,bar,reset);
        //----+ проверка на отсутствие ошибки в предыдущей операции
        if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
        Ind_Buffer4[bar]=Signal;
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
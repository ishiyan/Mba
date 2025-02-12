/*
Для  работы  индикатора  следует  положить   файлы      
JMASeries.mqh,
JUR001Series.mqh 
в папку (директорию):     MetaTrader\experts\include\
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
     
В  данном  индикаторе  внутри расчёта классический алгоритм усреднения 
заменён  на  алгоритм  усреднения от индикатора JRSX с помощью функции 
JUR001Series и  добавлена  сигнальная линия, полученная дополнительным 
JMA сглаживанием индикатора.   
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                  3c_JDemarkX.mq4 | 
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
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА жжжжжж+    
extern int Demark_Length = 10;
extern int Signal_Length = 15;
extern int Signal_Phase  = 100;
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_Buffer1[];
double Ind_Buffer2[];
double Ind_Buffer3[];
double Ind_Buffer4[];
//---- переменные с плавающей точкой 
double min_L,min_H,min_S,Jmin_H,Jmin_S,Demark,JDemarkX,trend,Signal;  
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JDemarkX initialization function                                 | 
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
   IndicatorShortName ("JDemarkX"); 
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
if(Signal_Phase<-100){Alert("Параметр Signal_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Signal_Phase+  " будет использовано -100");}//|
if(Signal_Phase> 100){Alert("Параметр Signal_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Signal_Phase+  " будет использовано  100");}//|
if(Signal_Length< 1) {Alert("Параметр Signal_Length должен быть не менее 1"     + " Вы ввели недопустимое " +Signal_Length+ " будет использовано  1");}////|
if(Demark_Length< 1) {Alert("Параметр Demark_Length должен быть не менее 1"     + " Вы ввели недопустимое " +Demark_Length+ " будет использовано  1");}////|
//+========================================================================================================================================================+ 
//---- установка номера бара, начиная с которого будет отрисовываться индикатор  
   int drawbegin=Demark_Length+1; 
   SetIndexDrawBegin(0,drawbegin);
   SetIndexDrawBegin(1,drawbegin);
   SetIndexDrawBegin(2,drawbegin);  
   SetIndexDrawBegin(3,drawbegin+30);        
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора  
   IndicatorDigits(0);
//---- завершение инициализации   
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JDemarkX iteration function                                      | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
   { 
   //---- проверка количества баров на достаточность для расчёта
   if (Bars-1<Demark_Length)return(0); 
   //----+ Введение целых переменных и получение уже подсчитанных баров
   //---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
   int reset,limit,MaxBarD,MaxBarJ,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
   //---- проверка на возможные ошибки
   if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
   //---- последний подсчитанный бар должен быть пересчитан 
   //---- (без этого пересчёта для counted_bars функциb JJMASeries и JurXSeries будут работать некорректно!!!)
   if (counted_bars>0) counted_bars--;
   //----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1 (Одно обращение к функции) 
   //----+ Введение и инициализация внутренних переменных функций JurXSeries, nJurXnumber=2(Два  обращения к функции)
   if(counted_bars==0){JJMASeriesReset(1);JurXSeriesReset(2);}
   //---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
   limit=Bars-counted_bars-1;
   //---- определение номера  максимального самого старого бара, начиная с которого будет произедён пересчёт новых баров
   MaxBarD=Bars-2;MaxBarJ=MaxBarD-Demark_Length;
   if (limit>MaxBarD)limit=MaxBarD;
   
   //----+ ОСНОВНОЙ ЦИКЛ РАСЧЁТА ИЕДИКАТОРА
   for(int bar=limit; bar>=0; bar--) 
     {  
        min_H=High[bar]-High[bar+1];
        min_L=Low[bar+1]-Low[bar];
        //----+    
        if(min_H<0) min_H=0; 
        if(min_L<0) min_L=0; 
        min_S = min_L + min_H;
        //----+ ----------------------------------------------------------------+ 
        //----+ Два параллельных обращения к функции JurXSeries за номерами 0, 1 
        //----+ параметр nJurXLength не меняется на каждом баре (nJurXdin=0) 
        //----+ ----------------------------------------------------------------+     
        Jmin_H=JurXSeries(0,0,MaxBarD,limit,Demark_Length,min_H,bar,reset);
        //----+ проверка на отсутствие ошибки в предыдущей операции
        if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
        //----+ ----------------------------------------------------------------+ 
        Jmin_S=JurXSeries(1,0,MaxBarD,limit,Demark_Length,min_S,bar,reset);
        //----+ проверка на отсутствие ошибки в предыдущей операции
        if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}                               
        //----+ ----------------------------------------------------------------+ 
        if (bar>MaxBarJ)continue;
        //----+ Расчёт индикатора Демарка
        if(Jmin_S!=0)JDemarkX =(200*Jmin_H/Jmin_S)-100;else JDemarkX = 100;
                                    
        //---- +SSSSSSSSSSSSSSSS <<< Трёхцветный код индикатора >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
        trend=JDemarkX-Ind_Buffer1[bar+1]-Ind_Buffer2[bar+1]-Ind_Buffer3[bar+1];     
        if     (trend>0){Ind_Buffer1[bar]=JDemarkX; Ind_Buffer2[bar]=0;        Ind_Buffer3[bar]=0;}
        else{if(trend<0){Ind_Buffer1[bar]=0;        Ind_Buffer2[bar]=JDemarkX; Ind_Buffer3[bar]=0;}
        else            {Ind_Buffer1[bar]=0;        Ind_Buffer2[bar]=0;        Ind_Buffer3[bar]=JDemarkX;}}    
        //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+  
        
        //----+ Вычисление сигнальной линии
        //----+ ---------------------------------------------------------------------------------------------------------------------------+   
        //----+ (Одно обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0))
        Signal=JJMASeries(0,0,MaxBarJ,limit,Signal_Phase,Signal_Length,JDemarkX,bar,reset);
        //----+ проверка на отсутствие ошибки в предыдущей операции
        if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}  
        Ind_Buffer4[bar]=Signal;             
        //----+ ---------------------------------------------------------------------------------------------------------------------------+          
     } 
     if(limit>=MaxBarJ){int iii=MaxBarJ;Ind_Buffer1[iii]=0;Ind_Buffer2[iii]=0;Ind_Buffer3[iii]=0;}      
   //---- завершение вычислений значений индикатора
   return(0);
   }  
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
//----+ Введение функции JJMASeriesReset  (дополнительная функция файла JJMASeries.mqh)
//----+ Введение функции INDICATOR_COUNTED(дополнительная функция файла JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции JurXSeriess (файл JurXSeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
//----+ Введение функции JurXSeriesReset (дополнительная функция файла JurXSeries.mqh для старта JurXSeries)
#include <JurXSeries.mqh>    
//+---------------------------------------------------------------------------------------------------------------------------+
     
  
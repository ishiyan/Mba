/*
Для  работы  индикатора  следует  положить файл
JJMASeries.mqh 
в папку (директорию): MetaTrader\experts\include\
/*
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                    3c_SG_Osc.mqh |
//|                        Copyright © 2006,        Nikolay Kositsin | 
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
*/
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Signal_Length = 15; // глубина сглаживания сигнальной линии
extern int Signal_Phase  = 100; // параметр сигнальной линии, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
extern int Ind_Shift     = 0;  // cдвиг индикатора вдоль оси времени 
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_Buffer1[];
double Ind_Buffer2[];
double Ind_Buffer3[];
double Ind_Buffer4[];
double Ind_Buffer5[];
//---- целые переменные
int bar;
//---- переменные с плавающей точкой 
double trend,Signal,Out_Series;
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
if(!SetIndexBuffer(0,Ind_Buffer1)&& 
   !SetIndexBuffer(1,Ind_Buffer2)&& 
   !SetIndexBuffer(2,Ind_Buffer3)&& 
   !SetIndexBuffer(3,Ind_Buffer4)&& 
   !SetIndexBuffer(4,Ind_Buffer5))
   Print("cannot set indicator buffers!");
//---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,EmptyValue);
   SetIndexEmptyValue(1,EmptyValue);
   SetIndexEmptyValue(2,EmptyValue);
   SetIndexEmptyValue(3,EmptyValue);
   SetIndexEmptyValue(4,EmptyValue);
//---- имена для окон данных и лэйбы для субъокон.  
   IndicatorShortName(""+Label+"");
   SetIndexLabel   (0,NULL);
   SetIndexLabel   (1,"Up_Trend");
   SetIndexLabel   (2,"Down_Trend");
   SetIndexLabel   (3,"Straight_Trend");
   SetIndexLabel   (4,"Signal");
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
   IndicatorDigits(digits());
//---- установка номера бара, начиная с которого будет отрисовываться индикатор
   int draw_begin=COUNT_begin()+Ind_Shift+1;
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   draw_begin+=29;
   SetIndexDrawBegin(3,draw_begin);
//---- завершение инициализации
//---- установка алертов на недопустимые значения входных параметров =====================================================================================+ 
if(Signal_Phase<-100){Alert("Параметр Signal_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Signal_Phase+"  будет использовано -100");}
if(Signal_Phase> 100){Alert("Параметр Signal_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Signal_Phase+"  будет использовано  100");}
if(Signal_Length<1)  {Alert("Параметр Signal_Length должен быть не менее 1"     + " Вы ввели недопустимое " +Signal_Length+" будет использовано  1"  );}
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
int reset,limit,MaxBarS,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции) 
if (counted_bars==0)JJMASeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBar=Bars-1-COUNT_begin()-1; MaxBarS=MaxBar+1;      
//---- Загрузка значений исходного индикатора в буффер
for(bar=limit; bar>=0; bar--)Ind_Buffer1[bar]=INDICATOR(bar);
//---- корекция максимального номера самого старого бара, начиная с которого будет произедён пересчёт новых баров 
//---- инициализация нуля
if (limit>MaxBar)
 {
  limit=MaxBar; 
  for(int ttt=Bars-1;ttt>MaxBar;ttt--)
   {
    Ind_Buffer2[ttt]=EmptyValue; 
    Ind_Buffer3[ttt]=EmptyValue; 
    Ind_Buffer4[ttt]=EmptyValue;
    Ind_Buffer5[ttt]=EmptyValue; 
   }
 }

//---- Расчёт индикатора
for(bar=limit;bar>=0;bar--)
   {
    Out_Series=Ind_Buffer1[bar];
    //---- +SSSSSSSSSSSSSSSS <<< Трёхцветный код индикатора >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
    trend=Out_Series-Ind_Buffer1[bar+1];     
    if(trend>0)     {Ind_Buffer2[bar]=Out_Series; Ind_Buffer3[bar]=EmptyValue; Ind_Buffer4[bar]=EmptyValue;}
    else{if(trend<0){Ind_Buffer2[bar]=EmptyValue; Ind_Buffer3[bar]=Out_Series; Ind_Buffer4[bar]=EmptyValue;}
    else            {Ind_Buffer2[bar]=EmptyValue; Ind_Buffer3[bar]=EmptyValue; Ind_Buffer4[bar]=Out_Series;}}    
    //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
     
    //----+ Обращение к функции JJMASeries за номером 0, (nJMAdin=0) 
    Signal=JJMASeries(0,0,MaxBarS,limit,Signal_Phase,Signal_Length,Out_Series,bar,reset);
    //----+ проверка на отсутствие ошибки в предыдущей операции
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
    Ind_Buffer5[bar]=Signal;
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
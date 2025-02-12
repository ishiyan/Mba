/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
и PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                J2JMA_Channel.mq4 | 
//|                           Copyright © 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 3
//---- цвета индикатора
#property indicator_color1 Red
#property indicator_color2 Gray
#property indicator_color3 Gray
//---- стиль линий индикатора
#property indicator_style1 0
#property indicator_style2 4
#property indicator_style3 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int  Channel_width = 100; // ширина канала в пунктах
extern int        Length1 = 3;   // глубина первого сглаживания 
extern int        Phase1  = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса первого сглаживания 
extern int        Length2 = 3;   // глубина второго сглаживания 
extern int        Phase2  = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса второго сглаживания  
extern int         Shift  = 0;   // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double JJMA[];
double UpperBuffer[];
double LowerBuffer[];
//---- целые переменные
int nf; 
//---- переменные с плавающей точкой 
double Series,Half_Width,Resalt,Temp_Series;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| J2JMA_Channel initialization function                            |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init() 
{ 
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE);
SetIndexStyle (1,DRAW_LINE);
SetIndexStyle (2,DRAW_LINE); 
//---- 3 индикаторных буффера использованы для счёта
SetIndexBuffer(0,JJMA);  
SetIndexBuffer(1,UpperBuffer); 
SetIndexBuffer(2,LowerBuffer);
//---- установка значений индикатора, которые не будут видимы на графике
SetIndexEmptyValue(0,0.0);  
SetIndexEmptyValue(1,0.0); 
SetIndexEmptyValue(2,0.0); 
//---- горизонтальный сдвиг индикаторных линий
SetIndexShift (0, Shift); 
SetIndexShift (1, Shift); 
SetIndexShift (2, Shift); 
//---- установка алертов на недопустимые значения входных параметров =================================================================+ 
if(Phase1<-100){Alert("Параметр Phase1 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase1+  " будет использовано -100");}
if(Phase1> 100){Alert("Параметр Phase1 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase1+  " будет использовано  100");}
if(Length1<  1){Alert("Параметр Length1 должен быть не менее 1"     + " Вы ввели недопустимое " +Length1+ " будет использовано  1"  );}
if(Phase2<-100){Alert("Параметр Phase2 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase2+  " будет использовано -100");}
if(Phase2> 100){Alert("Параметр Phase2 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase2+  " будет использовано  100");}
if(Length2<  1){Alert("Параметр Length2 должен быть не менее 1"     + " Вы ввели недопустимое " +Length2+ " будет использовано  1"  );}
PriceSeriesAlert(Input_Price_Customs);////PriceSeriesAlert///////PriceSeriesAlert//////////PriceSeriesAlert/////////PriceSeriesAlert//|
//+===================================================================================================================================+
//---- установка номера бара, начиная с которого будет отрисовываться индикатор 
int draw_begin=50; 
SetIndexDrawBegin(0,draw_begin);
SetIndexDrawBegin(1,draw_begin);
SetIndexDrawBegin(2,draw_begin); 
//---- размер канала в пунктах
Half_Width = Channel_width*Point/2;
//---- завершение инициализации
return(0); 
}
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| J2JMA_Channel iteration function                                 |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,MaxBar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=2(Два обращения к функции JJMASeries)
if (counted_bars==0)JJMASeriesReset(2);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
MaxBar=Bars-1; int limit=MaxBar-counted_bars;

//----+ ОСНОВНОЙ ЦИКЛ ВЫЧИСЛЕНИЯ ИНДИКАТОРА 
for(int bar=limit;bar>=0;bar--)
  {
    //----+ Обращение к функции PriceSeries для получения входной цены Series
    Temp_Series=PriceSeries(Input_Price_Customs, bar);
    //----+ Обращение к функции JJMASeries за номерам 0. Параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
    Temp_Series=JJMASeries(0,0,MaxBar,limit,Phase1,Length1,Temp_Series,bar,reset);
    //----+ проверка на отсутствие ошибки в предыдущей операции
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
    //----+ Обращение к функции JJMASeries за номерам 1. Параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
    Resalt     =JJMASeries(1,0,MaxBar,limit,Phase2,Length2,Temp_Series,bar,reset);
    //----+ проверка на отсутствие ошибки в предыдущей операции
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
    
    JJMA[bar]=Resalt;
   //----+ расчёт канала
   UpperBuffer[bar]=Resalt+Half_Width;     
   LowerBuffer[bar]=Resalt-Half_Width;
   //---- завершение вычислений значений индикатора        
  }
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
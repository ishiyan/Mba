/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh  
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                     JMoving Avereges_Channel.mq4 | 
//|                 JMA code: Copyright © 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|         JMoving Avereges: Copyright © 2006,     Nikolay Kositsin | 
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
#property indicator_color2 Lime
#property indicator_color3 Lime
//---- стиль линий индикатора
#property indicator_style1 0
#property indicator_style2 4
#property indicator_style3 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int       Channel_width = 100; // ширина канала в пунктах
extern int           MA_period = 8; // глубина  первого сглаживания 
extern int           MA_method = 0;  // метод усреднения
extern int           Smooth    = 8; // глубина сглаживания 
extern int       Smooth_Phase  = 100;// параметр сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int           Shift     = 0;  // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0;  //Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Series_buffer[];
double JMovingBuffer[];
double UpperBuffer[];
double LowerBuffer[];
//---- переменные с плавающей точкой  
double Temp_Series,Half_Width,Resalt;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JMoving Avereges_Channel initialization function                 | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{  
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE);
SetIndexStyle (1,DRAW_LINE);
SetIndexStyle (2,DRAW_LINE); 
//---- 4 индикаторных буффера использованs для счёта
IndicatorBuffers(4);
SetIndexBuffer(0,JMovingBuffer);  
SetIndexBuffer(1,UpperBuffer); 
SetIndexBuffer(2,LowerBuffer); 
SetIndexBuffer(3,Series_buffer);
//---- горизонтальный сдвиг индикаторных линий
SetIndexShift (0, Shift);  
SetIndexShift (1, Shift);
SetIndexShift (2, Shift);
//---- установка значений индикатора, которые не будут видимы на графике
SetIndexEmptyValue(0,0); 
SetIndexEmptyValue(1,0);
SetIndexEmptyValue(2,0);
//---- имя для окон данных и лэйба для субъокон. 
IndicatorShortName ("JMoving Avereges( MA_period="+MA_period+", MA_method="+MA_method+", Shift="+Shift+")"); 
SetIndexLabel (0, "JMoving Avereges"); 
SetIndexLabel (1, "Upper"); 
SetIndexLabel (2, "Lower"); 
//----
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- установка алертов на недопустимые значения входных параметров ======================================================================================+ 
if(Smooth_Phase<-100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано -100");}//|
if(Smooth_Phase> 100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано  100");}//|
if(Smooth< 1)        {Alert("Параметр Smooth должен быть не менее 1"     + " Вы ввели недопустимое " +Smooth+ " будет использовано  1");}//////////////////|
if(MA_period< 1)     {Alert("Параметр MA_period должен быть не менее 1"  + " Вы ввели недопустимое " +MA_period+ " будет использовано  1");}///////////////|
if(MA_method<0)      {Alert("Параметр MA_method должен быть от 0 до 3"   + " Вы ввели недопустимое " +MA_method+ " будет использовано 0");}////////////////|
if(MA_method>3)      {Alert("Параметр MA_method должен быть от 0 до 3"   + " Вы ввели недопустимое " +MA_method+ " будет использовано 0");}////////////////|
PriceSeriesAlert(Input_Price_Customs);//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|
//+========================================================================================================================================================+ 
//---- корекция недопустимого значения параметра MA_period
if(MA_period<1)MA_period=1; 
//---- установка номера бара, начиная с которого будет отрисовываться индикатор 
int draw_begin=MA_period+30; 
SetIndexDrawBegin(0,draw_begin);
SetIndexDrawBegin(1,draw_begin);
SetIndexDrawBegin(2,draw_begin); 
//---- размер канала в пунктах
Half_Width = Channel_width*Point/2;
//---- завершение инициализации
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JMoving Avereges_Channel iteration function                      | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,MaxBar,bar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
//(без этого пересчёта для counted_bars функция JJMASeries будет работать некорректно!!!)
if (counted_bars>0)counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции) 
if (counted_bars==0)JJMASeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
int limit=Bars-counted_bars-1; MaxBar=Bars-1-MA_period; 
//----+ загрузка в буфер исходных цен
for(bar=limit;bar>=0;bar--)Series_buffer[bar]=PriceSeries(Input_Price_Customs,bar);
//---- корекция стартового расчётого бара в цикле
//---- инициализация нуля          
if (limit>=MaxBar)
  {
   for(bar=limit;bar>=MaxBar;bar--)
     {
      JMovingBuffer[bar]=0.0;
      UpperBuffer  [bar]=0.0; 
      LowerBuffer  [bar]=0.0;
     }
   limit=MaxBar;
  }

//----+ ОСНОВНОЙ ЦИКЛ ВЫЧИСЛЕНИЯ ИНДИКАТОРА 
for(bar=limit;bar>=0;bar--)
  {
  //----+ формула для расчёта индикатора
  switch(MA_method)
    {
     case  0: Temp_Series=iMAOnArray(Series_buffer,0,MA_period,0,MODE_SMA, bar);break;
     case  1: Temp_Series=iMAOnArray(Series_buffer,0,MA_period,0,MODE_EMA, bar);break;
     case  2: Temp_Series=iMAOnArray(Series_buffer,0,MA_period,0,MODE_SMMA,bar);break;
     case  3: Temp_Series=iMAOnArray(Series_buffer,0,MA_period,0,MODE_LWMA,bar);break;
     default: Temp_Series=iMAOnArray(Series_buffer,0,MA_period,0,MODE_SMA, bar);
    }
  //----+ сглаживание полученного Moving Avereges
  //----+ обращение к функции JJMASeries за номером 0. Параметрs nJJMALength не меняtтся на каждом баре (nJJMAdin=0)
  Resalt=JJMASeries(0,0,MaxBar,limit,Smooth_Phase,Smooth,Temp_Series,bar,reset);
  //----+ проверка на отсутствие ошибки в предыдущей операции
  if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
  JMovingBuffer[bar]=Resalt; 
   //----+ расчёт канала
   UpperBuffer[bar]=Resalt+Half_Width;     
   LowerBuffer[bar]=Resalt-Half_Width;
   //---- завершение вычислений значений индикатора      
  
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
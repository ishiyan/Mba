/*
Для  работы  индикатора  следует  положить файл

INDICATOR_COUNTED.mqh 
JJMASeries.mqh  
в папку (директорию): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                               JPrice Channel.mq4 |
//|                                                                  |
//|                                       http://forex.kbpauk.ru/    |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property link      "http://forex.kbpauk.ru/"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 3
//---- цвет индикатора
#property indicator_color1 Lime
#property indicator_color2 Magenta
#property indicator_color3 Red
//---- стиль линий Bollinger Bands
#property indicator_style1 4
#property indicator_style2 2
#property indicator_style3 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int  Channel_Period = 14; // период канала
extern int         Smooth = 8; // глубина сглаживания средней линии
extern int   Smooth_Phase = 100;// параметр сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int      Ind_Shift = 0;  // cдвиг индикатора вдоль оси времени 
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double UpBuffer[];
double DnBuffer[];
double MdBuffer[];
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Price Channel initialization function                            | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
   string short_name;
//---- стили изображения индикатора
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
//---- 3 индикаторных буфферов использованы для счёта   
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,MdBuffer);
   SetIndexBuffer(2,DnBuffer);
//---- горизонтальный сдвиг индикаторных линий 
   SetIndexShift (0, Ind_Shift); 
   SetIndexShift (1, Ind_Shift); 
   SetIndexShift (2, Ind_Shift); 
//---- имя для окон данных и лэйба для субъокон.
   short_name="Price Channel("+Channel_Period+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Up Channel");
   SetIndexLabel(1,"Middle Channel");
   SetIndexLabel(2,"Down Channel");
//---- установка номера бара, начиная с которого будет отрисовываться индикатор 
   SetIndexDrawBegin(0,Channel_Period);
   SetIndexDrawBegin(1,Channel_Period+30);
   SetIndexDrawBegin(2,Channel_Period);
//---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
   //---- установка алертов на недопустимые значения входных параметров ===================================================================================+ 
if(Smooth_Phase<-100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+ " будет использовано -100");}///|
if(Smooth_Phase> 100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+ " будет использовано  100");}///|
if(Channel_Period<1) {Alert("Параметр Channel_Period должен быть не менее 1"+ " Вы ввели недопустимое " +Channel_Period+ " будет использовано  1");}///////|
if(Smooth< 1)        {Alert("Параметр Smooth должен быть не менее 1"      + " Вы ввели недопустимое " +Smooth+   " будет использовано  1");}///////////////|
//---- ====================================================================================================================================================+ 
//---- корекция недопустимого значения параметра Channel_Period
   if(Channel_Period<1)Channel_Period=1; 
//---- завершение инициализации
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Price Channel iteration function                                 | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//----
if(Bars<=Channel_Period) return(0);
//---- введение переменных с плавающей точкой 
double high,low,price,Temp_Series,Resalt;
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int limit,reset,MaxBar,bar,ii,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции) 
if (counted_bars==0)JJMASeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1;MaxBar=Bars-1-Channel_Period;
//---- корекция стартового расчётого бара в цикле
//---- инициализация нуля          
if (limit>=MaxBar)
    {
     for(bar=limit;bar>=MaxBar;bar--)
      {
       UpBuffer[bar]=0.0;    
       DnBuffer[bar]=0.0;
       MdBuffer[bar]=0.0;
      }
     limit=MaxBar;
    }
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
bar=limit;
while(bar>=0)
  {
      high=High[bar]; low=Low[bar]; 
      ii=bar-1+Channel_Period;
      while(ii>=bar)
        {
         price=High[ii];
         if(high<price)high=price;
         price=Low[ii];
         if(low>price) low=price;
         ii--;
        } 
     UpBuffer[bar]=high;
     DnBuffer[bar]=low;
     Temp_Series=(high+low)/2;
     
    //----+ Обращение к функции JJMASeries за номерам 0. Параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
    Resalt=JJMASeries(0,0,MaxBar,limit,Smooth_Phase,Smooth,Temp_Series,bar,reset);
    //----+ проверка на отсутствие ошибки в предыдущей операции
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
    MdBuffer[bar]=Resalt;
     
      bar--;
  }
return(0);
 }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
//----+ Введение функции JJMASeriesReset  (дополнительная функция файла JJMASeries.mqh)
//----+ Введение функции INDICATOR_COUNTED(дополнительная функция файла JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
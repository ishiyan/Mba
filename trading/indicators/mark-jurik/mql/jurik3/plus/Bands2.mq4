/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                              Bollinger Bands.mq4 | 
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 2
//---- цвет индикатора
#property indicator_color1 Blue
#property indicator_color2 Blue
//---- стиль линий Bollinger Bands
#property indicator_style1 4
#property indicator_style2 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int        Bands_Period = 20; // период  усреднения J2Bollinger Bands
extern double Bands_Deviations = 2.0; // девиатация 
extern int           MA_method = 0;   // метод усреднения
extern int         Bands_Shift = 0;   // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0;   //Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi High, 12-Heiken Ashi Low, 13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- buffers
double UpperBuffer[];
double LowerBuffer[];
double SeriesBuffer[];
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Bollinger Bands initialization function                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexStyle(1,DRAW_LINE);
//---- 4 индикаторных буфферов использованы для счёта
   IndicatorBuffers(3); 
   SetIndexBuffer(0,UpperBuffer );  
   SetIndexBuffer(1,LowerBuffer );
   SetIndexBuffer(2,SeriesBuffer);
//---- установка номера бара, начиная с которого будет отрисовываться индикатор 
   int drawbegin=Bands_Period+Bands_Shift; 
   SetIndexDrawBegin(0,drawbegin);
   SetIndexDrawBegin(1,drawbegin);
//---- горизонтальный сдвиг индикаторных линий  
   SetIndexShift (0, Bands_Shift); 
   SetIndexShift (1, Bands_Shift); 
//---- имя для окон данных и лэйба для субъокон. 
   IndicatorShortName ("Bollinger Bands( Period="+Bands_Period+", Deviations="+Bands_Deviations+")"); 
   SetIndexLabel (0, "Upper Bands"); 
   SetIndexLabel (1, "Lower Bands"); 
//---- установка алертов на недопустимые значения входных параметров ======================================================================================+ 
if(Bands_Period<1)   {Alert("Параметр Bands_Period должен быть не менее 1 "+ " Вы ввели недопустимое " +Bands_Period+ " будет использовано  1");}//////////|
if(MA_method<0)      {Alert("Параметр MA_method должен быть от 0 до 3"   + " Вы ввели недопустимое " +MA_method+ " будет использовано 0");}////////////////|
if(MA_method>3)      {Alert("Параметр MA_method должен быть от 0 до 3"   + " Вы ввели недопустимое " +MA_method+ " будет использовано 0");}////////////////|
PriceSeriesAlert(Input_Price_Customs);//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|
//+========================================================================================================================================================+ 
//---- корекция недопустимого значения параметра Bands_Period
if(Bands_Period<1)Bands_Period=1; 
//---- завершение инициализации
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Bollinger Bands iteration function                               | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//---- проверка количества баров на достаточность для расчёта
if(Bars<=Bands_Period) return(0);
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int bar,kk,MaxBarBB,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBarBB=Bars-1-Bands_Period;
double Temp_Series,sum,midline,priceswing,deviation;
//----+ загрузка входных цен в буффер для расчёта       
for(bar=limit;bar>=0;bar--)SeriesBuffer[bar]=PriceSeries(Input_Price_Customs,bar);
//---- проверка бара на достаточность для расчёта Bollinger Bands 
if (limit>MaxBarBB)limit=MaxBarBB;

for(bar=limit;bar>=0;bar--)
     {
      //----+ формула для расчёта Moving Avereges
      switch(MA_method)
           {
            case  0: Temp_Series=iMAOnArray(SeriesBuffer,0,Bands_Period,0,MODE_SMA, bar);break;
            case  1: Temp_Series=iMAOnArray(SeriesBuffer,0,Bands_Period,0,MODE_EMA, bar);break;
            case  2: Temp_Series=iMAOnArray(SeriesBuffer,0,Bands_Period,0,MODE_SMMA,bar);break;
            case  3: Temp_Series=iMAOnArray(SeriesBuffer,0,Bands_Period,0,MODE_LWMA,bar);break;
            default: Temp_Series=iMAOnArray(SeriesBuffer,0,Bands_Period,0,MODE_SMA, bar);
           }
                 
      //---- РАСЧЁТ Bollinger Bands
      sum=0.0;
      kk=bar+Bands_Period-1;
      midline=Temp_Series;
      while(kk>=bar)
        {
         priceswing=PriceSeries(Input_Price_Customs,kk)-midline;
         sum+=priceswing*priceswing;
         kk--;
        }
      deviation=Bands_Deviations*MathSqrt(sum/Bands_Period);
      UpperBuffer[bar]=midline+deviation;
      LowerBuffer[bar]=midline-deviation;
      //----
    }
//----
   return(0);
  }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции INDICATOR_COUNTED (файл INDICATOR_COUNTED.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции PriceSeries, файл PriceSeries.mqh следует положить в папку (директорию): MetaTrader\experts\include
//----+ Введение функции PriceSeriesAlert (дополнительная функция файла PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+
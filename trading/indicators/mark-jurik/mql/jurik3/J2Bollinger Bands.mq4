/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                            J2Bollinger Bands.mq4 | 
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 3
//---- цвет индикатора
#property indicator_color1 Gray
#property indicator_color2 Lime
#property indicator_color3 Gray
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int        Bands_Period = 100; // период  усреднения J2Bollinger Bands
extern double Bands_Deviations = 2.0; // девиатация 
extern int           MA_method = 0;   // метод усреднения
extern int           MA_Smooth = 20;  // глубина сглаживания полученного Moving Avereges
extern int        Bands_Smooth = 20;  // глубина сглаживания полученных Bollinger Bands
extern int        Smooth_Phase = 100; // параметр сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int          Bands_Shift = 0;  // cдвиг индикатора вдоль оси времени 
extern int  Input_Price_Customs = 0;  //Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double UpperBuffer  [];
double JMovingBuffer[];
double LowerBuffer  [];
double Series_buffer[];
//---- переменные с плавающей точкой  
double deviation,Temp_Series,sum,midline,priceswing,Resalt;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| J2Bollinger Bands initialization function                        | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- определение стиля исполнения графика
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
//---- 4 индикаторных буффера использованы для счёта.  
   IndicatorBuffers(4);
   SetIndexBuffer(0,UpperBuffer  );
   SetIndexBuffer(1,JMovingBuffer);
   SetIndexBuffer(2,LowerBuffer  );
   SetIndexBuffer(3,Series_buffer);
   //---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
//---- установка номера бара, начиная с которого будет отрисовываться индикатор 
   int drawbegin=Bands_Period+30+Bands_Shift; 
   SetIndexDrawBegin(0,drawbegin);
   SetIndexDrawBegin(1,drawbegin);
   SetIndexDrawBegin(2,drawbegin);
//---- горизонтальный сдвиг индикаторных линий  
   SetIndexShift (0, Bands_Shift); 
   SetIndexShift (1, Bands_Shift); 
   SetIndexShift (2, Bands_Shift); 
//---- имя для окон данных и лэйба для субъокон.
   IndicatorShortName ("J2Bollinger Bands( Period="+Bands_Period+", Deviations="+Bands_Deviations+")"); 
   SetIndexLabel (0, "Upper Bands"); 
   SetIndexLabel (2, "Lower Bands"); 
   switch(MA_method)
           {
            case  0: SetIndexLabel (1, "JMoving Avereges JSMA ("+Bands_Period+")");break;
            case  1: SetIndexLabel (1, "JMoving Avereges JEMA ("+Bands_Period+")");break;
            case  2: SetIndexLabel (1, "JMoving Avereges JSSMA("+Bands_Period+")");break;
            case  3: SetIndexLabel (1, "JMoving Avereges JLWMA("+Bands_Period+")");break;
            default: SetIndexLabel (1, "JMoving Avereges JSMA ("+Bands_Period+")");
           }
//----          
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- установка алертов на недопустимые значения входных параметров ======================================================================================+ 
if(Smooth_Phase<-100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано -100");}//|
if(Smooth_Phase> 100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано  100");}//|
if(MA_Smooth<1)      {Alert("Параметр MA_Smooth должен быть не менее 1" + " Вы ввели недопустимое " +MA_Smooth+ " будет использовано  1");}////////////////|
if(MA_Smooth<1)      {Alert("Параметр Bands_Smooth должен быть не менее 1" + " Вы ввели недопустимое " +Bands_Smooth + " будет использовано  1");}/////////|
if(Bands_Period<1)   {Alert("Параметр Bands_Period должен быть не менее 1 "+ " Вы ввели недопустимое " +Bands_Period+ " будет использовано  1");}//////////|
if(MA_method<0)      {Alert("Параметр MA_method должен быть от 0 до 3"   + " Вы ввели недопустимое " +MA_method+ " будет использовано 0");}////////////////|
if(MA_method>3)      {Alert("Параметр MA_method должен быть от 0 до 3"   + " Вы ввели недопустимое " +MA_method+ " будет использовано 0");}////////////////|
PriceSeriesAlert(Input_Price_Customs);/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|
//+========================================================================================================================================================+ 
//---- корекция недопустимого значения параметра Bands_Period
if(Bands_Period<1)Bands_Period=1; 
//---- завершение инициализации
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| J2Bollinger Bands iteration function                             | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//---- проверка количества баров на достаточность для расчёта
if(Bars-1<=Bands_Period) return(0);
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,MaxBar,MaxBarBB,bar,kk,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
//---- (без этого пересчёта для counted_bars функция JJMASeries будет работать некорректно!!!)
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=3(Три обращения к функции JJMASeries)
if (counted_bars==0)if (Bands_Smooth>1)JJMASeriesReset(3);else JJMASeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
int limit=Bars-counted_bars-1;MaxBar=Bars-1-Bands_Period;MaxBarBB=MaxBar-30;
//----+ загрузка входных цен в буффер для расчёта       
for(bar=limit;bar>=0;bar--)Series_buffer[bar]=PriceSeries(Input_Price_Customs,bar);
//---- проверка бара на достаточность для расчёта Bollinger Bands 
//---- инициализация нуля          
if (limit>MaxBar)
     {
      for(bar=limit;bar>=MaxBar;bar--)JMovingBuffer[bar]=0;
      limit=MaxBar;
     }
//----+ цикл расчёта Moving Avereges
for(bar=limit;bar>=0;bar--)
     {
      //----+ формула для расчёта Moving Avereges
      switch(MA_method)
           {
            case  0: Temp_Series=iMAOnArray(Series_buffer,0,Bands_Period,0,MODE_SMA, bar);break;
            case  1: Temp_Series=iMAOnArray(Series_buffer,0,Bands_Period,0,MODE_EMA, bar);break;
            case  2: Temp_Series=iMAOnArray(Series_buffer,0,Bands_Period,0,MODE_SMMA,bar);break;
            case  3: Temp_Series=iMAOnArray(Series_buffer,0,Bands_Period,0,MODE_LWMA,bar);break;
            default: Temp_Series=iMAOnArray(Series_buffer,0,Bands_Period,0,MODE_SMA, bar);
           }
      //----+ сглаживание полученного Moving Avereges
      //----+ обращение к функции JJMASeries за номером 0. Параметрs nJJMALength не меняtтся на каждом баре (nJJMAdin=0)
      Resalt=JJMASeries(0,0,MaxBar,limit,Smooth_Phase,MA_Smooth,Temp_Series,bar,reset);
      //----+ проверка на отсутствие ошибки в предыдущей операции
      if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
      JMovingBuffer[bar]=Resalt; 
     }     
//---- РАСЧЁТ Bollinger Bands 
//---- инициализация нуля      
if (limit>MaxBarBB)
     {

      for(bar=limit;bar>=MaxBarBB;bar--)
       {
        UpperBuffer[bar]=0;
        LowerBuffer[bar]=0;
       }
      limit=MaxBarBB;
     }
for(bar=limit;bar>=0;bar--)
     {         
      sum=0.0;
      midline=JMovingBuffer[bar];
      kk=bar+Bands_Period-1;
      while(kk>=bar)
        {
         priceswing=PriceSeries(Input_Price_Customs,kk)-midline;
         sum+=priceswing*priceswing;
         kk--;
        }  
      deviation=Bands_Deviations*MathSqrt(sum/Bands_Period);    
      if (Bands_Smooth>1)
        {    
         //----+ вычисление и JMA сглаживание Bollinger Bands      
         //----+ ----------------------------------------------------------------------------------------+            
         //----+ Два параллельных обращения к функции JJMASeries за номерами 1, 2.
         //----+ Параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
         //----+ ----------------------------------------------------------------------------------------+     
         Resalt=JJMASeries(1,0,MaxBarBB-1,limit,Smooth_Phase,Bands_Smooth ,midline+deviation,bar,reset);
         //----+ проверка на отсутствие ошибки в предыдущей операции
         if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} UpperBuffer[bar]=Resalt; 
         //----+ ----------------------------------------------------------------------------------------+ 
         Resalt=JJMASeries(2,0,MaxBarBB-1,limit,Smooth_Phase,Bands_Smooth ,midline-deviation,bar,reset);
         //----+ проверка на отсутствие ошибки в предыдущей операции
         if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} LowerBuffer[bar]=Resalt; 
         //----+ ----------------------------------------------------------------------------------------+ 
        }
      else 
        {
         //----+ вычисление Bollinger Bands без JMA сглаживания   
         UpperBuffer[bar]=midline+deviation;
         LowerBuffer[bar]=midline-deviation;
        }

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
/*
Для  работы  индикатора  следует  положить файлы 

SmoothXSeries.mqh
T3Series.mqh
MASeries.mqh
LRMASeries.mqh
JurXSeries.mqh
ParMASeries.mqh
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\

Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+X================================================================X+  
//|                                                        XMACD.mq4 | 
//|                        Copyright © 2009,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+   
#property copyright "Copyright © 2009, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в отдельном окне
#property  indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- цвета индикатора
#property  indicator_color1  Blue
#property  indicator_color2  Magenta
//---- толщина линии диаграммы
#property  indicator_width1  2
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА
extern int MACD_Mode = 0;  // Выбор алгоритма сглаживания для MACD 0 - JJMA, 1 - JurX,        
                 // 2 - ParMA, 3 - LRMA, 4 - T3, 5 - SMA, 6 - EMA, 7 - SSMA, 8 - LWMA
extern int MACD_Phase = 100;
extern int FastXMA = 12;
extern int SlowXMA = 26;
extern int Signal_Mode = 0;  // Выбор алгоритма сглаживания для сигнальной линии 
  //0 - JJMA, 1 - JurX, 2 - ParMA, 3 - LRMA, 4 - T3, 5 - SMA, 6 - EMA, 7 - SSMA, 8 - LWMA
extern int Signal_Phase = 100;
extern int SignalXMA = 9;
extern int Input_Price_Customs = 0; /* Выбор цен, по которым производится расчёт 
индикатора (0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 
6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW, 
11-Heiken Ashi Low, 12-Heiken Ashi High, 13-Heiken Ashi Open, 14-Heiken Ashi Close.) */
//---- индикаторные буферы
double     XMacdBuffer[];
double     XSignalBuffer[];
//---- переменные 
bool   INIT;
int    StartBar, StartBar1, StartBar2;
//+X================================================================X+   
//| SmoothXSeries() function                                         |
//+X================================================================X+    
//----+ Объявление функции SmoothXSeries
//----+ Объявление функции SmoothXSeriesResize 
//----+ Объявление функции SmoothXSeriesAlert   
#include <SmoothXSeries.mqh> 
//+X================================================================X+   
//| PriceSeries() function                                           |
//+X================================================================X+    
//----+ Объявление функции PriceSeries
//----+ Объявление функции PriceSeriesAlert 
#include <PriceSeries.mqh>
//+X================================================================X+ 
//| XMACD indicator initialization function                          |
//+X================================================================X+ 
int init()
  {
//----+
   //---- установка стиля изображения индикатора 
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_LINE);
   //---- Установка формата точности (количество знаков 
        //после десятичной точки) для визуализации значений индикатора 
   IndicatorDigits(Digits + 1);
   //---- определение буферов для подсчёта 
   SetIndexBuffer(0, XMacdBuffer);
   SetIndexBuffer(1, XSignalBuffer);
   //---- имена для окон данных и лэйбы для субъокон
   IndicatorShortName(StringConcatenate
            ("XMACD(", FastXMA, ",", SlowXMA, ",", SignalXMA, ")"));
   SetIndexLabel(0, "XMACD");
   SetIndexLabel(1, "XSignal");
   //---- установка алертов на недопустимые значения внешних переменных
   JJMASeriesAlert (0, "FastXMA", FastXMA);
   JJMASeriesAlert (0, "SlowXMA", SlowXMA);
   JJMASeriesAlert (0, "SignalXMA", SignalXMA);
   //----
   JJMASeriesAlert (1, "MACD_Phase", MACD_Phase);  
   JJMASeriesAlert (1, "Signal_Phase", Signal_Phase);
   PriceSeriesAlert(Input_Price_Customs);
   //---- Изменение размеров буферных переменных функции
           //SmoothXSeries, number = 3(Три обращения к функции SmoothXSeries)
   if (SmoothXSeriesResize(3) != 3)
    {
     INIT = false;
     return(0);
    }
   //---- инициализация переменных 
   if (MACD_Mode > 0 && MACD_Mode < 9) 
                            StartBar1 = MathMax( FastXMA, SlowXMA);
   else StartBar1 = 30;
   //----
   if (Signal_Mode > 0 && Signal_Mode < 9) 
                          StartBar2 = SignalXMA;
   else StartBar2 = 30;
   //----
   StartBar = StartBar1 + StartBar2;
   //----
   SetIndexDrawBegin(0, StartBar1);
   SetIndexDrawBegin(1, StartBar);
   //---- завершение инициализации
   INIT = true;
   return(0);
//----+
  }
//+X================================================================X+ 
//| XMACD indicator iteration function                               |
//+X================================================================X+ 
int start()
  {
//----+
   //---- Получение номера последнего бара
   int Bars_ = Bars - 1;
	//---- проверка завершения инициализации и 
	     //проверка количества баров на достаточность для расчёта
	if (!INIT || Bars_ <= StartBar)
			                  return(-1); 
	//---- Введение переменных с плавающей точкой
	double Price, FastXMA_, SlowXMA_, XMACD, SignalXMA_;
	//---- Введение целых переменных и получение 
	                        //количества уже посчитанных баров
	int reset, MaxBar1, MaxBar2, limit, 
	                   bar, counted_bars = IndicatorCounted();
	//---- проверка на возможные ошибки
	if (counted_bars < 0)
				    return(-1);
	//---- последний подсчитанный бар должен быть пересчитан
	if (counted_bars > 0)
				counted_bars--;
	//---- определение номера самого старого бара, 
					//начиная с которого будет произедён пересчёт новых баров 
	limit = Bars_ - counted_bars;
	//---- определение номера самого старого бара, 
					 //начиная с которого будет произедён пересчёт всех баров 
	MaxBar1 = Bars_;
	MaxBar2 = MaxBar1 - StartBar1;

   //----+ основной цикл расчёта индикатора
	for(bar = limit; bar >= 0; bar--)
	 {
	  //---- Получение исходного значения ценового ряда
	  Price = PriceSeries(Input_Price_Customs, bar);
	  //---- FastXMA сглаживание исходного значения ценового ряда, 
	  //---- Обращение к функции SmoothXSeries за номером 0, 
			 //параметры Phase и Length не меняются на каждом баре (din = 0)
	  FastXMA_ = SmoothXSeries(0, MACD_Mode, 0, MaxBar1, limit, 
	                              MACD_Phase, FastXMA, Price, bar, reset);
	  //---- проверка на отсутствие ошибки в предыдущей операции
	  if(reset != 0)
				  return(-1);
	  //---- SlowXMA сглаживание исходного значения ценового ряда, 
	  //---- Обращение к функции SmoothXSeries за номером 1, 
			 //параметры Phase и Length не меняются на каждом баре (din = 0)
	  SlowXMA_ = SmoothXSeries(1, MACD_Mode, 0, MaxBar1, limit, 
	                             MACD_Phase, SlowXMA, Price,  bar, reset);                       
	  //---- проверка на отсутствие ошибки в предыдущей операции
	  if(reset != 0)
				  return(-1);
	  //----			  
	  if(bar < MaxBar2) 
	         XMACD = FastXMA_ - SlowXMA_;
	  
	  //---- SignalXMA сглаживание полученной диаграммы XMACD, 
	  //---- Обращение к функции SmoothXSeries за номером 2, 
			 //параметры Phase и Length не меняются на каждом баре (din = 0)
	  SignalXMA_ = SmoothXSeries(2, Signal_Mode, 0, MaxBar2, limit, 
	                         Signal_Phase, SignalXMA, XMACD,  bar, reset);            
	  //---- проверка на отсутствие ошибки в предыдущей операции
	  if(reset != 0)
				  return(-1);
	  //----
	  XMacdBuffer[bar] = XMACD;
	  XSignalBuffer[bar] = SignalXMA_;		  
    }
   return(0);
  
//----+
  }
//+X----------------------+ <<< The End >>> +-----------------------X+
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
//|                                                         X1MA.mq4 | 
//|                        Copyright © 2009,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+   
#property copyright "Copyright © 2009, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в основном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- цвет индикатора
#property indicator_color1 Red
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА +-------------------------------------------------+
extern int Smooth_Mode = 0;   // Выбор алгоритма сглаживания 0 - JJMA, 1 - JurX,        
                 // 2 - ParMA, 3 - LRMA, 4 - T3, 5 - SMA, 6 - EMA, 7 - SSMA, 8 - LWMA
extern int Length = 11;   // глубина сглаживания 
extern int Phase  = 100; // параметр, изменяющийся в пределах -100 ... +100, 
                                       //влияет на качество переходного процесса; 
extern int Shift  = 0;   // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0; /* Выбор цен, по которым производится расчёт 
индикатора (0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 
6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW, 
11-Heiken Ashi Low, 12-Heiken Ashi High, 13-Heiken Ashi Open, 14-Heiken Ashi Close.) */
//---- +------------------------------------------------------------------------------+
//---- буферы
double XMA[]; 
//---- переменные  
bool INIT;
int  StartBar;
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
//| X1MA initialization function                                     |
//+X================================================================X+ 
int init() 
 { 
//----+
   //---- установка стиля изображения индикатора 
   SetIndexStyle(0, DRAW_LINE); 
   //---- определение буфера для подсчёта 
   SetIndexBuffer(0, XMA);
   //---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0, 0.0);  
   //---- установка алертов на недопустимые значения внешних переменных
   JJMASeriesAlert (0, "Length", Length);
   JJMASeriesAlert (1, "Phase",   Phase);
   PriceSeriesAlert(Input_Price_Customs);
   //----+ Изменение размеров буферных переменных функции
           //SmoothXSeries, number = 1(Одно обращение к функции SmoothXSeries)
   if (SmoothXSeriesResize(1) != 1)
    {
     INIT = false;
     return(0);
    }
   //---- инициализация переменных
   if (Smooth_Mode > 0 && Smooth_Mode < 9) 
                              StartBar = Length;
   else StartBar = 30;
   //---- установка номера бара,
                     //начиная с которого будет отрисовываться индикатор 
   SetIndexDrawBegin(0, StartBar); 
   //---- Установка формата точности отображения индикатора
   IndicatorDigits(Digits);
   //---- завершение инициализации
   INIT = true;
   return(0);
//----+ 
 }
//+X================================================================X+  
//| X1MA iteration function                                          | 
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
	double Price, xma;
	//---- Введение целых переменных и получение 
	                           //количества уже посчитанных баров
	int reset, MaxBar, limit, bar, counted_bars = IndicatorCounted();
	//---- проверка на возможные ошибки
	if (counted_bars < 0)
				    return(-1);
	//---- последний посчитанный бар должен быть пересчитан
	if (counted_bars > 0)
				counted_bars--;
	//---- определение номера самого старого бара, 
					//начиная с которого будет произедён пересчёт новых баров 
	limit = Bars_ - counted_bars;
	//---- определение номера самого старого бара, 
					 //начиная с которого будет произедён пересчёт всех баров 
	MaxBar = Bars_;
	
	//----+ основной цикл расчёта индикатора
	for(bar = limit; bar >= 0; bar--)
	 {
	  //---- Получение исходного значения ценового ряда
	  Price = PriceSeries(Input_Price_Customs, bar);
	  //---- X1MA сглаживание исходного значения ценового ряда, 
	  //---- Обращение к функции SmoothXSeries за номером 0, 
			 //параметры Phase и Length не меняются на каждом баре (din = 0)
	  xma = SmoothXSeries(0, Smooth_Mode, 0, MaxBar, limit, 
	                                     Phase, Length, Price, bar, reset);
	  //---- проверка на отсутствие ошибки в предыдущей операции
	  if(reset != 0)
				  return(-1);
				  
	  XMA[bar] = xma;
	  //----
	 }
	//----+ завершение вычислений значений индикатора
	return(0); 
//----+  
 } 
//+X--------------------+ <<< The End >>> +--------------------X+


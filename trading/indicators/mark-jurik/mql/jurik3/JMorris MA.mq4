/*
*** Morris MA *** 
Version 2 (29th May 2004) 
** forex version **
use short duration bars e.g. 
5min set length to give required speed of response
increase damping to eliminate overshooting 
Lower length will require Higher damping
*/
/*
Для  работы  индикатора  следует  положить файлы 
INDICATOR_COUNTED.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                   JMorris MA.mq4 |
//|                Copyright © 2003,2004                  Tim Morris |
//|                                                                  |
//|                     MQL4 © 2005,                Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 1
#property indicator_color1 Red
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int       Length  = 10;//inverse of driving coefficient
extern int      damping  = 5;//smoothing (percent)
extern int       maxgap  = 30;//maximum week gap ignored (pips)
extern int     Smooth    = 8; // глубина сглаживания 
extern int Smooth_Phase  = 100;// параметр сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int        Shift  = 0;
extern int  Input_Price_Customs = 2;  //Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double MMA_Buffer [];
double MEMORY[];
//---- переменные с плавающей точкой  
double p, dmp, drv, gap;
double n, k, d0, y0, y1, y2, mg, err, Resalt; 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Morris MA initialization function                                | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {  
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE); 
//---- 2 индикаторных буффера использованы для счёта.  
IndicatorBuffers(2);  
SetIndexBuffer(0, MMA_Buffer);
SetIndexBuffer(1, MEMORY);
//---- горизонтальный сдвиг индикаторной линии 
SetIndexShift (0, Shift);  
//---- имя для окон данных и лэйба для субъокон. 
SetIndexLabel   (0, "Moris_MA");
IndicatorShortName ("Moris_MA (Length="+Length+", damping="+damping+", maxgap="+maxgap+", Shift="+Shift+")");    
//----   
   k =1.0/Length; d0 = damping/100.0; mg = maxgap*Point;  
//----    
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- установка алертов на недопустимые значения входных параметров ======================================================================================+ 
if(Smooth_Phase<-100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано -100");}//|
if(Smooth_Phase> 100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано  100");}//|
if(Smooth< 1)        {Alert("Параметр Smooth должен быть не менее 1"     + " Вы ввели недопустимое " +Smooth+ " будет использовано  1");}//////////////////|
if(Length<1)         {Alert("Параметр Length должен быть не менее 1 "+ " Вы ввели недопустимое " +Length+ " будет использовано  1");}//////////////////////|
PriceSeriesAlert(Input_Price_Customs);/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|
//+========================================================================================================================================================+ 
//---- корекция недопустимого значения параметра Bands_Period
if(Length<1)Length=1; 
//---- завершение инициализации   
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Morris MA iteration function                                     | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int MaxBar,reset,bar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции) 
if (counted_bars==0)JJMASeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1;MaxBar=Bars-1-2;

if (limit>=MaxBar)
	{
   	limit=MaxBar;
   	y0=PriceSeries(Input_Price_Customs,MaxBar);
   	//----
   	MEMORY[MaxBar+0]=y0;
      MEMORY[MaxBar+1]=y0;
      MEMORY[MaxBar+2]=y0; 
      //----
	   MMA_Buffer[MaxBar+0]=y0;
	   MMA_Buffer[MaxBar+1]=0.0;
   	MMA_Buffer[MaxBar+2]=0.0;  
   }
bar=limit;
while (bar>=0)
	{
	  p=PriceSeries(Input_Price_Customs,bar);
//week} gap compensation------------------------------------------+
	  if (Time[bar]-Time[bar+1]>30000)
		 if ((High[bar]<Low[bar+1])||(Low[bar]>High[bar+1]))
			{
	    		gap=p-PriceSeries(Input_Price_Customs,bar+1);
	    		if (MathAbs(gap)>mg){MEMORY[bar+1]+=gap; MEMORY[bar+2]+=gap;}
	    	}
//----------------------------------------------------------------+	
//*** calculate new average position ***
   y1  = MEMORY[bar+1]; 
   y2  = MEMORY[bar+2];
   n   = High[bar]-Low[bar];//consider H-L as noise level
   if(n==0)n=Point/100;
   err = (p-2.0*y1+y2)/n; 
//error is difference between price && straight line
   drv = MathMax(MathMin(k*err*err + k*MathAbs(err),0.5),0.0);
//driving function = polynomial of error/noise
//small moves have little effect, 
//big moves have big effect, 
//spikes have small effect
	dmp = MathMax(MathMin(k*MathAbs(y1-y2)/n + d0,1.0),0.0);
//damping function = polynomial of gradient/noise
//if average is moving fast but price isn't - put the brakes on.
   y0  = y1 + n*err*drv + (y1-y2)*(1.0-dmp);
//new average = straight line less damping plus driving
   MEMORY[bar+0]=y0; 
   //----+ Обращение к функции JJMASeries за номерам 0. Параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
   Resalt=JJMASeries(0,0,MaxBar,limit,Smooth_Phase,Smooth,y0,bar,reset);
   //----+ проверка на отсутствие ошибки в предыдущей операции
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
   MMA_Buffer[bar]=Resalt;
	bar--;
	}
//---- done---
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
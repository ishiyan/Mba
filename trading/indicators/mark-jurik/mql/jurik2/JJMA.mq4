/*
Для  работы  индикатора  следует  положить файл JJMASeries.mqh в папку
(директорию): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                         JJMA.mq4 | 
//|                 JMA code: Copyright © 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|                MQL4+JJMA: Copyright © 2005,     Nikolay Kositsin | 
//|                                   Khabarovsk, violet@mail.kht.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Weld" 
#property link "http://weld.torguem.net" 
#property indicator_chart_window 
#property indicator_buffers 1 
#property indicator_color1 Lime 
//---- input parameters 
extern int Length = 5; // глубина сглаживания 
extern int Phase  = 5; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Shift  = 0; // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-"Close", 1-"Open", 2-"(High+Low)/2", 3-"High", 4-"Low", 5-"Heiken Ashi Close", 6-"(Open+Close)/2") 
//---- buffers 
double JJMA[]; 
double Series;
int IPC;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Custom indicator initialization function                         | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{  
//---- indicator line 
SetIndexStyle (0,DRAW_LINE); 
SetIndexBuffer(0,JJMA);
SetIndexShift (0, Shift);  
IndicatorShortName ("JJMA( Length="+Length+", Phase="+Phase+", Shift="+Shift+")"); 
SetIndexLabel (0, "JJMA"); 
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));IPC=Input_Price_Customs;
//+================================================================================================================================+ 
if(Phase<-100){Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase+  " будет использовано -100");}
if(Phase> 100){Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase+  " будет использовано  100");}
if(Length<  1){Alert("Параметр Length должен быть не менее 1"     + " Вы ввели недопустимое " +Length+ " будет использовано  1"  );}
if(IPC<0){Alert("Параметр Input_Price_Customs должен быть не менее 0" + " Вы ввели недопустимое "+IPC+ " будет использовано 0"   );}
if(IPC>6){Alert("Параметр Input_Price_Customs должен быть не более 6" + " Вы ввели недопустимое "+IPC+ " будет использовано 0"   );}
//+================================================================================================================================+
//--+
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JJMA iteration function                                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
int x,counted_bars=IndicatorCounted(); 
int limit=Bars-counted_bars-1; 
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumberJ=1(Одно обращение к функции) 
if (limit==Bars-1){int reset=-1;int set=JJMASeries(1,0,0,0,0,0,0,0,reset);if((reset!=0)||(set!=0))return(-1);}
//----+  
  for(x=limit;x>=0;x--)
  {
   switch(IPC)
    {
    //----+ Выбор цен, по которым производится расчёт индикатора +----+
     case 0:  Series=Close[x];break;
     case 1:  Series= Open[x];break;
     case 2: {Series=(High[x]+Low  [x])/2;}break;
     case 3:  Series= High[x];break;
     case 4:  Series=  Low[x];break;
     case 5: {Series=(Open[x]+High [x]+Low[x]+Close[x])/4;}break;
     case 6: {Series=(Open[x]+Close[x])/2;}break;
     default: Series=Close[x];break;
    //----+-----------------------------------------------------------+
    }
  //----+ Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
  reset=1;JJMA[x]=JJMASeries(0,0,Bars-1,limit,Phase,Length,Series,x,reset);if(reset!=0)return(-1);
  }
return(0); 
} 
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <JJMASeries.mqh> 
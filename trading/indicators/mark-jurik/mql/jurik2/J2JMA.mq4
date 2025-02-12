/*
Для  работы  индикатора  следует  положить файл JJMASeries.mqh в папку
(директорию): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                        J2JMA.mq4 | 
//|                 JMA code: Copyright © 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|               MQL4+J2JMA: Copyright © 2005,     Nikolay Kositsin | 
//|                                   Khabarovsk, violet@mail.kht.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Weld" 
#property link "http://weld.torguem.net" 
#property indicator_chart_window 
#property indicator_buffers 1 
#property indicator_color1 Magenta 
//---- input parameters 
extern int Length1 = 5; // глубина первого сглаживания 
extern int Length2 = 5; // глубина второго сглаживания 
extern int Phase1  = 5; // параметр первого сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Phase2  = 5; // параметр второго сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Shift  = 0; // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-"Close", 1-"Open", 2-"(High+Low)/2", 3-"High", 4-"Low", 5-"Heiken Ashi Close", 6-"(Open+Close)/2") 
//---- buffers 
double JJMA[]; 
double Series,Temp_Series;
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
IndicatorShortName ("J2JMA( Length1="+Length1+", Phase1="+Phase1+", Length2="+Length2+", Phase2="+Phase2+", Shift="+Shift+")"); 
SetIndexLabel (0, "J2JMA"); 
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));IPC=Input_Price_Customs;
//+===================================================================================================================================+ 
if(Phase1<-100){Alert("Параметр Phase1 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase1+  " будет использовано -100");}
if(Phase1> 100){Alert("Параметр Phase1 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase1+  " будет использовано  100");}
if(Phase2<-100){Alert("Параметр Phase2 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase2+  " будет использовано -100");}
if(Phase2> 100){Alert("Параметр Phase2 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase2+  " будет использовано  100");}
if(Length1<  1){Alert("Параметр Length1 должен быть не менее 1"     + " Вы ввели недопустимое " +Length1+ " будет использовано  1"  );}
if(Length2<  1){Alert("Параметр Length2 должен быть не менее 1"     + " Вы ввели недопустимое " +Length2+ " будет использовано  1"  );}
if(IPC<0){Alert("Параметр Input_Price_Customs должен быть не менее 0" + " Вы ввели недопустимое "+IPC+ " будет использовано 0"   );}
if(IPC>6){Alert("Параметр Input_Price_Customs должен быть не более 6" + " Вы ввели недопустимое "+IPC+ " будет использовано 0"   );}
//+===================================================================================================================================+
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
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=2(Два обращения к функции JJMASeries) 
if (limit==Bars-1){int reset=-1;int set=JJMASeries(2,0,0,0,0,0,0,0,reset);if((reset!=0)||(set!=0))return(-1);}
//----+  
for(x=limit;x>=0;x--)
{
switch(IPC)
{
//----+ Выбор цен, по которым производится расчёт индикатора +----------------------+
case 0:  Series=Close[x];break;
case 1:  Series= Open[x];break;
case 2: {Series=(High[x]+Low  [x])/2;}break;
case 3:  Series= High[x];break;
case 4:  Series=  Low[x];break;
case 5: {Series=(Open[x]+High [x]+Low[x]+Close[x])/4;}break;
case 6: {Series=(Open[x]+Close[x])/2;}break;
default: Series=Close[x];break;
//----+-----------------------------------------------------------------------------+
}
//----+ Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0) 
reset=1;Temp_Series=JJMASeries(0,0,Bars-1,limit,Phase1,Length1,Series,x,reset);if(reset!=0)return(-1);
//----+ Обращение к функции JJMASeries за номером 1, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0) 
//(В этом обращении параметр nJMAMaxBar уменьшен на 30  т. к. это повторное JMA сглаживание) 
reset=1;JJMA[x]=JJMASeries(1,0,Bars-1-30,limit,Phase2,Length2,Temp_Series,x,reset);if(reset!=0)return(-1);
}
return(0); 
} 
//----+ Введение функции JJMASeries, файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include
#include <JJMASeries.mqh> 
/*
По своим  свойствам  этот  индикатор абсолютно аналогичен классическим
осциляторам  и к нему применимы абсолютно те же приёмы теханализа, что
и  к  RSI. Только благодаря использованию более совершенных алгоритмов
сглаживания он имеет меньшее запаздывание и более глакую форму кривой.
Сигналы,  которые  подаёт  медленная  сигнальная  линиия, аналогичны с
сигналам сигнальной линии MACD 
Для  работы  индикатора  следует  положить файл JJMASeries.mqh в папку
(директорию): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                   3c_JRSX_Hs.mq4 |
//|          JRSX: Copyright © 2005,            Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|   MQL4+3color: Copyright © 2005,                Nikolay Kositsin | 
//|                                   Khabarovsk, violet@mail.kht.ru |   
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
#property copyright "Copyright © 2005, Weld, Jurik Research"
#property link      " http://weld.torguem.net"
#property indicator_separate_window
#property indicator_buffers  4
#property indicator_color1  Blue
#property indicator_color2  Magenta
#property indicator_color3  Gray
#property indicator_color4  Lime
#property indicator_level1  0.5
#property indicator_level2 -0.5
#property indicator_level3  0.0
#property indicator_maximum  1
#property indicator_minimum -1
//---- input parameters
extern int  JRSX.Length = 8;
extern int  Sign.Length = 15;
extern int  Sign.Phase  = 100;
extern int   CountBars  = 300;
//---- buffers
double JRSX1[];
double JRSX2[];
double JRSX3[];
double JSIGN[];
//----
int    shift,r,w,k,counted_bars,T0,T1,Tnew;
//----
double v4,v8,v10,v14,v18,v20,v0C,v1C,v8A,trend;   
double F28,F30,F38,F40,F48,F50,F58,F60,F68,F70,F78,F80,JRSX; 
double f0,f28,f30,f38,f40,f48,f50,f58,f60,f68,f70,f78,f80,Kg,Hg;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| Custom indicator initialization function                         |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(1,DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(3,DRAW_LINE);
//----   
   SetIndexBuffer(0,JRSX1);
   SetIndexBuffer(1,JRSX2);
   SetIndexBuffer(2,JRSX3);
   SetIndexBuffer(3,JSIGN);   
//----  
   IndicatorShortName("JRSX");
//----   
   SetIndexDrawBegin(0,Bars-CountBars);
   SetIndexDrawBegin(1,Bars-CountBars);
   SetIndexDrawBegin(2,Bars-CountBars);
   SetIndexDrawBegin(3,Bars-CountBars);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//----  
   if (JRSX.Length-1>=5) w=JRSX.Length-1; else w=5; Kg=3/(JRSX.Length+2.0); Hg=1.0-Kg;
//----
return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| Custom indicator iteration function                              |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
{
counted_bars=IndicatorCounted();
if (counted_bars<0) return(-1);
if (counted_bars>JRSX.Length) shift=Bars-counted_bars-1;
else shift=Bars-JRSX.Length-1;
int limit=shift;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращенние к функции) 
if (limit==Bars-JRSX.Length-1){int reset=-1;int set=JJMASeries(1,0,0,0,0,0,0,0,reset);if((reset!=0)||(set!=0))return(-1);}

Tnew=Time[shift+1];

//+--- восстановление переменных +=====================+
if((Tnew!=T0)&&(shift<Bars-JRSX.Length-1)) 
{
if (Tnew==T1)
{
f28=F28; f30=F30; f38=F38; f40=F40; f48=F48; f50=F50;
f58=F58; f60=F60; f68=F68; f70=F70; f78=F78; f80=F80;
} else return(-1);
}
//+--- +===============================================+

if (JRSX.Length-1>=5)w=JRSX.Length-1;else w=5; Kg=3/(JRSX.Length+2.0); Hg=1.0-Kg;

while (shift>=0)
{
//+-------------------+
if (r==0){r=1; k=0;}
else
{
//++++++++++++++++++++
if (r>=w) r=w+1; else r=r+1;

v8 = Close[shift]-Close[shift+1]; v8A=MathAbs(v8);
//---- вычисление V14 ------
f28 = Hg  * f28 + Kg  *  v8;
f30 = Kg  * f28 + Hg  * f30;
v0C = 1.5 * f28 - 0.5 * f30;
f38 = Hg  * f38 + Kg  * v0C;
f40 = Kg  * f38 + Hg  * f40;
v10 = 1.5 * f38 - 0.5 * f40;
f48 = Hg  * f48 + Kg  * v10;
f50 = Kg  * f48 + Hg  * f50;
v14 = 1.5 * f48 - 0.5 * f50;
//---- вычисление V20 ------
f58 = Hg  * f58 + Kg  * v8A;
f60 = Kg  * f58 + Hg  * f60;
v18 = 1.5 * f58 - 0.5 * f60;
f68 = Hg  * f68 + Kg  * v18;
f70 = Kg  * f68 + Hg  * f70;
v1C = 1.5 * f68 - 0.5 * f70;
f78 = Hg  * f78 + Kg  * v1C;
f80 = Kg  * f78 + Hg  * f80;
v20 = 1.5 * f78 - 0.5 * f80;
//-------wwwwwwwwww---------
if ((r <= w) && (v8!= 0)) k = 1;
if ((r == w) && (k == 0)) r = 0;
}//++++++++++++++++++++
if ((r>w)&&(v20>0.0000000001)){v4=(v14/v20+1.0)*50.0;if(v4>100.0)v4=100.0;if(v4<0.0)v4=0.0;}else v4=50.0;

JRSX=(v4/50)-1;

//+--- Сохранение переменных +========================+
if (shift==1)
{
T1=Time[1];T0=Time[0];
F28=f28; F30=f30; F38=f38; F40=f40; F48=f48; F50=f50;
F58=f58; F60=f60; F68=f68; F70=f70; F78=f78; F80=f80;
}
//+---+===============================================+

//---- +SSSSSSSSSSSSSSSS <<< Three colore code >>> SSSSSSSSSSSSSSSSSSSSSSSSS+
trend=JRSX-JRSX1[shift+1]-JRSX2[shift+1]-JRSX3[shift+1];     
if(trend>0.0)     {JRSX1[shift]=JRSX;JRSX2[shift]=0.0; JRSX3[shift]=0.0;}
else{if(trend<0.0){JRSX1[shift]=0.0; JRSX2[shift]=JRSX;JRSX3[shift]=0.0;}
else              {JRSX1[shift]=0.0; JRSX2[shift]=0.0; JRSX3[shift]=JRSX;}}    
//---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 

//----+ Вычисление сигнальной линии ( Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0))
reset=1;JSIGN[shift]=JJMASeries(0,0,Bars-JRSX.Length-1,limit,Sign.Phase,Sign.Length,JRSX,shift,reset);if(reset!=0)return(-1);

shift--;
}
//+-------------------+
return(0);
}
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <JJMASeries.mqh> 







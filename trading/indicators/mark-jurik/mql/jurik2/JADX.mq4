/*
Для  работы  индикатора  следует  положить файл JJMASeries.mqh в папку
(директорию): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                         JADX.mq4 | 
//|                 JMA code: Copyright © 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|                JADX+MQL4: Copyright © 2005,     Nikolay Kositsin | 
//|                                   Khabarovsk, violet@mail.kht.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Weld" 
#property link "http://weld.torguem.net" 
#property indicator_separate_window
#property indicator_color1 Red 
//---- input parameters 
extern int Length1   = 8;  // глубина сглаживания DX
extern int Length2   = 3;  // глубина сглаживания ADX
extern int Phase1    =-100;// параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов +DM и -DM; 
extern int Phase2    =-100;// параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса ADX; 
extern int Shift     = 0;  // cдвиг индикатора вдоль оси времени 
extern int CountBars = 500;// Количество последних баров, на которых происходит расчёт ндикатора
//---- indicator buffers 
double JADX_Buffer[ ]; 
//---- ADX variabls
double pDM,mDM,TRJ,JpDM,JmDM,ADX,JADX;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JADX initialization function                                     | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{ 
SetIndexStyle(0, DRAW_LINE); 
SetIndexShift(0, Shift); 
//---- 1 indicator buffer[n]s mapping 
SetIndexBuffer (0, JADX_Buffer);
SetIndexDrawBegin(0,Bars-CountBars); 
SetIndexEmptyValue(0,0.0); 
//---- 
SetIndexLabel (0, "JADX"); 
IndicatorShortName ("JADX"); 
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//+======================================================================================================================================+ 
if(Phase1<-100){Alert("Параметр Phase1 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase1+  " будет использовано -100");}//|
if(Phase1> 100){Alert("Параметр Phase1 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase1+  " будет использовано  100");}//|
if(Phase2<-100){Alert("Параметр Phase2 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase2+  " будет использовано -100");}//|
if(Phase2> 100){Alert("Параметр Phase2 должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase2+  " будет использовано  100");}//|
if(Length1< 1) {Alert("Параметр Length1 должен быть не менее 1"     + " Вы ввели недопустимое " +Length1+ " будет использовано  1");}////|
if(Length2< 1) {Alert("Параметр Length2 должен быть не менее 1"     + " Вы ввели недопустимое " +Length2+ " будет использовано  1");}////|
//+======================================================================================================================================+ 
//---- initialization done
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JADX iteration function                                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ Получение уже подсчитанных баров
int counted_bars = IndicatorCounted(); 
//----+ Проверка на возможные ошибки
if (counted_bars<0) return (-1);
int limit=Bars-counted_bars-1;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=3(Три обращения к функции) 
if (limit==Bars-1){int reset=-1;int set=JJMASeries(3,0,0,0,0,0,0,0,reset);if((reset!=0)||(set!=0))return(-1);}
//----+  
 for(int k=limit;k>=0;k--)
 {
  TRJ=iATR(NULL,Period(),1,k);     
  pDM=High[k]-High[k+1];mDM=Low[k+1]-Low[k];
  if (pDM<0)pDM=0.0;
  if (mDM<0)mDM=0.0;
  if (pDM==mDM)  {pDM=0.0; mDM=0.0;}
  if((pDM> mDM)&&(pDM>0.0))mDM=0.0;
  if((pDM< mDM)&&(mDM>0.0))pDM=0.0;
  if((TRJ<0.00001)&&(k<Bars-40)){pDM=0.0;mDM=0.0;}
  else{pDM=pDM/TRJ;mDM=mDM/TRJ;}
  
  //----+ Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре во всех трёх обращениях к функции (nJMAdin=0)
  reset=1;JpDM=JJMASeries(0,0,Bars-1,limit,Phase1,Length1,pDM,k,reset);if(reset!=0)return(-1);
  
  //----+ Обращение к функции JJMASeries за номером 1 
  reset=1;JmDM=JJMASeries(1,0,Bars-1,limit,Phase1,Length1,mDM,k,reset);if(reset!=0)return(-1); 
   
  if (JpDM+JmDM>0.00001) ADX=100*(JpDM-JmDM)/(JpDM+JmDM);else ADX=0.0;
  
  //----+ Обращение к функции JJMASeries за номером 2 (В этом обращении параметр nJMAMaxBar уменьшен на 30  т. к. это повторное JMA сглаживание) 
  reset=1;JADX=JJMASeries(2,0,Bars-1-30,limit,Phase2,Length2,ADX,k,reset);if(reset!=0)return(-1); 
  JADX_Buffer[k]=JADX;  
 }
//----+
return(0);  
}
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <JJMASeries.mqh> 
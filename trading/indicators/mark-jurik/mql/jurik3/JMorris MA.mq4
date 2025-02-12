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
���  ������  ����������  �������  �������� ����� 
INDICATOR_COUNTED.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                   JMorris MA.mq4 |
//|                Copyright � 2003,2004                  Tim Morris |
//|                                                                  |
//|                     MQL4 � 2005,                Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 1
#property indicator_color1 Red
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int       Length  = 10;//inverse of driving coefficient
extern int      damping  = 5;//smoothing (percent)
extern int       maxgap  = 30;//maximum week gap ignored (pips)
extern int     Smooth    = 8; // ������� ����������� 
extern int Smooth_Phase  = 100;// �������� �����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int        Shift  = 0;
extern int  Input_Price_Customs = 2;  //����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double MMA_Buffer [];
double MEMORY[];
//---- ���������� � ��������� ������  
double p, dmp, drv, gap;
double n, k, d0, y0, y1, y2, mg, err, Resalt; 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Morris MA initialization function                                | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {  
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE); 
//---- 2 ������������ ������� ������������ ��� �����.  
IndicatorBuffers(2);  
SetIndexBuffer(0, MMA_Buffer);
SetIndexBuffer(1, MEMORY);
//---- �������������� ����� ������������ ����� 
SetIndexShift (0, Shift);  
//---- ��� ��� ���� ������ � ����� ��� ��������. 
SetIndexLabel   (0, "Moris_MA");
IndicatorShortName ("Moris_MA (Length="+Length+", damping="+damping+", maxgap="+maxgap+", Shift="+Shift+")");    
//----   
   k =1.0/Length; d0 = damping/100.0; mg = maxgap*Point;  
//----    
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- ��������� ������� �� ������������ �������� ������� ���������� ======================================================================================+ 
if(Smooth_Phase<-100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+  " ����� ������������ -100");}//|
if(Smooth_Phase> 100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+  " ����� ������������  100");}//|
if(Smooth< 1)        {Alert("�������� Smooth ������ ���� �� ����� 1"     + " �� ����� ������������ " +Smooth+ " ����� ������������  1");}//////////////////|
if(Length<1)         {Alert("�������� Length ������ ���� �� ����� 1 "+ " �� ����� ������������ " +Length+ " ����� ������������  1");}//////////////////////|
PriceSeriesAlert(Input_Price_Customs);/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|
//+========================================================================================================================================================+ 
//---- �������� ������������� �������� ��������� Bands_Period
if(Length<1)Length=1; 
//---- ���������� �������������   
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Morris MA iteration function                                     | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int MaxBar,reset,bar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
if (counted_bars==0)JJMASeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
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
   //----+ ��������� � ������� JJMASeries �� ������� 0. ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
   Resalt=JJMASeries(0,0,MaxBar,limit,Smooth_Phase,Smooth,y0,bar,reset);
   //----+ �������� �� ���������� ������ � ���������� ��������
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
   MMA_Buffer[bar]=Resalt;
	bar--;
	}
//---- done---
return(0); 
}
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� JJMASeries (���� JJMASeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
//----+ �������� ������� JJMASeriesReset  (�������������� ������� ����� JJMASeries.mqh)
//----+ �������� ������� INDICATOR_COUNTED(�������������� ������� ����� JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� PriceSeries, ���� PriceSeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include
//----+ �������� ������� PriceSeriesAlert (�������������� ������� ����� PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+
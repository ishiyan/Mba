/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                        J2JMA.mq4 | 
//|                 JMA code: Copyright � 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|               MQL4+J2JMA: Copyright � 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 1 
//---- ���� ����������
#property indicator_color1 Magenta 
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Length1 = 5; // �������  ������� ����������� 
extern int Length2 = 5; // �������  ������� ����������� 
extern int Phase1  = 5; // �������� ������� �����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int Phase2  = 5; // �������� ������� �����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int Shift   = 0; // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double J2JMA[];
//---- ���������� � ��������� ������  
double Temp_Series;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| J2JMA indicator initialization function                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{  
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE); 
//---- 1 ������������ ������ ����������� ��� �����
SetIndexBuffer(0,J2JMA);
//---- �������������� ����� ������������ ����� 
SetIndexShift (0, Shift);  
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
SetIndexEmptyValue(0,0); 
//---- ��� ��� ���� ������ � ����� ��� ��������. 
IndicatorShortName ("J2JMA( Length1="+Length1+", Phase1="+Phase1+", Length2="+Length2+", Phase2="+Phase2+", Shift="+Shift+")"); 
SetIndexLabel (0, "J2JMA"); 
//----
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- ��������� ������� �� ������������ �������� ������� ���������� =================================================================+ 
if(Phase1<-100){Alert("�������� Phase1 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase1+  " ����� ������������ -100");}
if(Phase1> 100){Alert("�������� Phase1 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase1+  " ����� ������������  100");}
if(Phase2<-100){Alert("�������� Phase2 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase2+  " ����� ������������ -100");}
if(Phase2> 100){Alert("�������� Phase2 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase2+  " ����� ������������  100");}
if(Length1<  1){Alert("�������� Length1 ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length1+ " ����� ������������  1"  );}
if(Length2<  1){Alert("�������� Length2 ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length2+ " ����� ������������  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+===================================================================================================================================+
//---- ���������� �������������
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| J2JMA iteration function                                         | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,MaxBar1,MaxBar2,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
//---- (��� ����� ��������� ��� counted_bars ������� JJMASeries ����� �������� �����������!!!)
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=2(��� ��������� � ������� JJMASeries)
if (counted_bars==0)JJMASeriesReset(2);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
int limit=Bars-counted_bars-1; MaxBar1=Bars-1; MaxBar2=MaxBar1-30;

//----+ �������� ���� ���������� ���������� 
for(int bar=limit;bar>=0;bar--)
{
//----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
Temp_Series=PriceSeries(Input_Price_Customs, bar);
//+----------------------------------------------------------------------------+ 
//----+ ��� ��������� � ������� JJMASeries �� �������� 0, 1. ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
//(�� ������  ��������� �������� nJMAMaxBar  �������� �� 30  �. �. ��� ��������� JMA �����������)
//+----------------------------------------------------------------------------+   
Temp_Series=JJMASeries(0,0,MaxBar1,limit,Phase1,Length1,Temp_Series,bar,reset);
//----+ �������� �� ���������� ������ � ���������� ��������
if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
//+----------------------------------------------------------------------------+ 
Temp_Series=JJMASeries(1,0,MaxBar2,limit,Phase2,Length2,Temp_Series,bar,reset);
//----+ �������� �� ���������� ������ � ���������� ��������
if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
//+----------------------------------------------------------------------------+ 
J2JMA[bar]=Temp_Series;
}
//---- ���������� ���������� �������� ����������
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
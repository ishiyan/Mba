/*
���  ������  ����������  �������  �������� ����� 

JurXSeries.mqh, 
PriceSeries.mqh,  
INDICATOR_COUNTED.mqh   
� ����� (����������): MetaTrader\experts\include\

Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\

� ������  �����  ����������  �����  �������� ����������� �� ���������� 
JRSX.    �������� ��������� ����� ��������� ����� ��������� �������� � 
������� JMA ������������, �� � ���� ������� �������� ����� ����������.
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                         JurX.mq4 | 
//|                JurX code: Copyright � 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|                MQL4+JurX: Copyright � 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 1 
//---- ���� ����������
#property indicator_color1 Yellow
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Length  = 5; // �������  ������� ����������� 
extern int Shift   = 0; // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Ind_Buffer[];
//---- ���������� � ��������� ������  
double Temp_Series,JurX;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JurX indicator initialization function                           | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{  
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE); 
//---- 1 ������������ ������ ����������� ��� �����
SetIndexBuffer(0,Ind_Buffer);
//---- �������������� ����� ������������ ����� 
SetIndexShift (0, Shift); 
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
SetIndexEmptyValue(0,0); 
//---- ��� ��� ���� ������ � ����� ��� ��������. 
IndicatorShortName ("JurX( Length="+Length+", Shift="+Shift+")"); 
SetIndexLabel (0, "JurX"); 
//----
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- ��������� ������� �� ������������ �������� ������� ���������� =======================================================+ 
if(Length<1){Alert("�������� Length ������ ���� �� ����� 1" + " �� ����� ������������ " +Length+ " ����� ������������ 1");}
PriceSeriesAlert(Input_Price_Customs);
//+=========================================================================================================================+
//---- ���������� �������������
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JurX iteration function                                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,MaxBar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� (��� ����� ��������� ��� counted_bars ������� JurXSeries ����� �������� �����������!!!)
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JurXSeries, nJurXnumber=1(����  ��������� � �������)
if (counted_bars==0)JurXSeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
int limit=Bars-counted_bars-1; MaxBar=Bars-1-2*Length; 

//----+ �������� ���� ���������� ���������� 
for(int bar=limit;bar>=0;bar--)
 {
  //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
  Temp_Series=PriceSeries(Input_Price_Customs,bar);
  //----+ ���� ��������� � ������� JurXSeries �� ������� 0. �������� nJJurXLength �� ����t��� �� ������ ���� (nJurXdin=0)
  JurX=JurXSeries(0,0,MaxBar,limit,Length,Temp_Series,bar,reset); 
  //----+ �������� �� ���������� ������ � ���������� ��������
  if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}  
  Ind_Buffer[bar]=JurX;                 
 }
//---- ���������� ���������� �������� ����������
return(0); 
} 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� INDICATOR_COUNTED (���� INDICATOR_COUNTED.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� JurXSeries (���� JurXSeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
//----+ �������� ������� JurXSeriesReset (�������������� ������� ����� JurXSeries.mqh)
#include <JurXSeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� PriceSeries, ���� PriceSeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include
//----+ �������� ������� PriceSeriesAlert (�������������� ������� ����� PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+
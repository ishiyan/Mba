/*
��� ������ ����������  �������  ��������  �����  
INDICATOR_COUNTED.mqh    
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\

Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\

�� �����  ���������  ����  ��������� ��������� ���������� ������������
�����������  � � ���� ��������� ��������� �� �� ����� ����������, ���
�  �  RSI. ������ ��������� ������������� ����� ����������� ����������
����������� �� ����� ������� ������������ � ����� ������ ����� ������.
//---- 
Relative   Strenght  Index  (RSI)
������ ������������� ���� - ��� ��������� �� ����� ����������, �������
����������  �  ��������� �� 0 �� 100. ���� �� ���������������� �������
�������  RSI  �������  � ������ �����������, ��� ������� ���� ��������
����� ��������, � RSI �� ������� ���������� ������� ������ �����������
���������.   ��������   �����������   ���������������   �  �����������
���������  ���.  ����  �����  RSI  ������������ ���� � ���������� ����
�����   �������,   ��   ��   ���������   ���  ����������  '�����������
������'(failure    swing).    ����    �����������   ������   ���������
��������������  �������  ���������  ���.  �������  ����������  RSI ���
������� ��������:
1.  �������  �  ���������  �������  RSI������  �����������  ���� 70, �
���������  - ���� 30, ������ ��� ������ ��������� ����������� ������ �
��������� �� ������� �������.
2.  �����������  ������  RSI ����� �������� ����������� ������ - �����
���  '������  �  �����'  ���  ������������, ������� �� ������� �������
�����   �  ��  ������������.
3.  �����������  ������  (������  ������  ��������� ��� �������������)
�����  �����,  ����� RSI ����������� ���� ����������� ��������� (����)
��� ���������� ���� ����������� �������� (�������).
4.  ������ ��������� � ������������� �� ������� RSI ������ ��������� �
������������� ���������� ���� ����������, ��� �� ������� �������.
5.  �����������  ���  ���  ������� ����, ����������� ����������, �����
����  ���������  ������  ��������� (��������), �� �� �� ��������������
�����   ����������   (���������)  ��  �������  RSI.  ���  ����  ������
���������� ��������� ��� � ����������� �������� RSI.
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                       JRSX.s.mq4 |
//|          JRSX: Copyright � 2005,            Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|   MQL4+3color: Copyright � 2006,                Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers  1
//---- ����� ����������
#property indicator_color1  BlueViolet
//---- ��������� �������������� ������� ����������
#property indicator_level1  0.5
#property indicator_level2 -0.5
#property indicator_level3  0.0
#property indicator_levelcolor MediumBlue
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int  JRSX.Length = 8;  // ������� ����������� ����������
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Ind_Buffer1[];
//---- ����� ���������� 
int    w;
//---- ���������� � ��������� ������ 
double v8,v14,v20,v8A;   
double JRSX; 

//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JRSX initialization function                                     |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_LINE);
//---- 1 �����������Q ������ ����������� ��� �����. 
   SetIndexBuffer(0,Ind_Buffer1);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0); 
//---- ����� ��� ���� ������ � ����� ��� ��������.
   SetIndexLabel(0,"JRSX");
   IndicatorShortName("JRSX(JRSX.Length="+JRSX.Length+", Input_Price_Customs="+Input_Price_Customs+")");
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������  
   IndicatorDigits(0);
//---- ��������� ������� �� ������������ �������� ������� ���������� =======================================================================+ 
if(JRSX.Length< 1) {Alert("�������� JRSX.Length ������ ���� �� ����� 1"+ " �� ����� ������������ "+JRSX.Length+ " ����� ������������ 1");}//|
PriceSeriesAlert(Input_Price_Customs);//---- ��������� � ������� PriceSeriesAlert //////////////////////////////////////////////////////////|
//---- =====================================================================================================================================+ 
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������  
   SetIndexDrawBegin(0,JRSX.Length+1);
//---- �������� ������������� �������� ��������� JRSX.Length
   if(JRSX.Length<1)JRSX.Length=1; 
//---- ������������� ������������� ��� ������� ���������� 
   if (JRSX.Length>5) w=JRSX.Length-1; else w=5;
//---- ���������� �������������
return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JRSX iteration function                                          |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
{
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int bar,limit,reset,MaxBar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JurXSeries, nJurXnumber=2(��� ��������� � ������� JurXSeries)
if (counted_bars==0)JurXSeriesReset(2);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
MaxBar=Bars-2; limit=Bars-counted_bars-1; 
//----+ 
if (bar>MaxBar){bar=MaxBar;Ind_Buffer1[bar]=0.0;}

bar=limit;
while (bar>=0)
{
//----+ ��� ��������� � ������� PriceSeries ��� ��������� ������� ������� ��� v8
v8 = PriceSeries(Input_Price_Customs, bar)-PriceSeries(Input_Price_Customs, bar+1);
//----+  
v8A=MathAbs(v8);
//----+ ��� ��������� � ������� JurXSeries �� �������� 0 � 1. �������� nJJurXLength �� ����t��� �� ������ ���� (nJurXdin=0), �������� �� ���������� ������ � ���������� ��������
v14=JurXSeries(0,0,MaxBar,limit,JRSX.Length,v8, bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
v20=JurXSeries(1,0,MaxBar,limit,JRSX.Length,v8A,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
//----+
if (bar>MaxBar-w)JRSX=0;else if (v20!=0){JRSX=v14/v20;if(JRSX>1)JRSX=1;if(JRSX<-1)JRSX=-1;}else JRSX=0;

Ind_Buffer1[bar]=JRSX; 

//----+
bar--;
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



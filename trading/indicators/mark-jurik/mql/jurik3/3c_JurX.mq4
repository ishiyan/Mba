/*
���  ������  ����������  �������  �������� ����� 

JurXSeries.mqh, 
PriceSeries.mqh,  
INDICATOR_COUNTED.mqh  
3Color.mqh

� ����� (����������): MetaTrader\experts\include\

JurX.mq4
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\

� ������  �����  ����������  �����  �������� ����������� �� ���������� 
JRSX.    �������� ��������� ����� ��������� ����� ��������� �������� � 
������� JMA ������������, �� � ���� ������� �������� ����� ����������.
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                      3c_JurX.mq4 | 
//|                           Copyright � 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 6
//---- ����� ����������
#property indicator_color1 Yellow
#property indicator_color2 Yellow
#property indicator_color3 Red
#property indicator_color4 Red 
#property indicator_color5 Gray
#property indicator_color6 Gray
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Length  = 5; // �������  ������� ����������� 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- �������� ������� digits() ��� ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ���������� 
int digits(){return(Digits);}
//---- �������� ������� COUNT_begin() ��� ���������� ������ ����, ������� � �������� ����� �������������� ���������
int COUNT_begin(){int count_begin=Length+3;if (Length<5)count_begin=8;return(count_begin);}
//---- ��������� �������� ����������, ������� �� ����� ������ �� ������� 
int EmptyValue=0;
//---- ����� ��� ����������
string Label="JurX";                 
//---- ��������� � ����� ���������� ��� ��������� ������
#include <3Color.mqh>
//---- �������� ������� INDICATOR -------------------------------------------------------------------------+
//---- ��������� � ��������� ���������� ��� ��������� ������� ��������
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom(NULL,0,"JurX",Length,0,Input_Price_Customs,0,INDICATOR.bar) );
 }
//---- ----------------------------------------------------------------------------------------------------+
/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh  
PriceSeries.mqh 
3Color.mqh 
� ����� (����������): MetaTrader\experts\include\
JJMA.mq4 
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                      3c_JJMA.mq4 | 
//|                             Copyright � 2006,   Nikolay Kositsin | 
//|                                Khabarovsk, farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 6
//---- ����� ����������
#property indicator_color1 Lime
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Red 
#property indicator_color5 Gray
#property indicator_color6 Gray
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Length = 5;   // �������  ����������� 
extern int Phase  = 100; // �������� �����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- �������� ������� digits() ��� ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ���������� 
int digits(){return(Digits);}
//---- �������� ������� COUNT_begin() ��� ���������� ������ ����, ������� � �������� ����� �������������� ���������
int COUNT_begin(){return(30);}
//---- ��������� �������� ����������, ������� �� ����� ������ �� ������� 
int  EmptyValue=0;
//---- ����� ��� ����������
string Label="JJMA";                 
//---- ��������� � ����� ���������� ��� ��������� ������
#include <3Color.mqh>
//---- �������� ������� INDICATOR -------------------------------------------------------------------------+
//---- ��������� � ��������� ���������� ��� ��������� ������� ��������
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom(NULL,0,"JJMA",Length,Phase,0,Input_Price_Customs,0,INDICATOR.bar) );
 }
//---- ----------------------------------------------------------------------------------------------------+
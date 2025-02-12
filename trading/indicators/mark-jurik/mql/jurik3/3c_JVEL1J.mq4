/*
/---- 
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
PriceSeries.mqh 
3c_BB_Osc.mqh
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                    3c_JVEL1J.mq4 |
//|         JVEL1: Copyright � 2005,            Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|   MQL4+3color: Copyright � 2006,                Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+  
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers 8 
//---- ����� ���������� 
#property indicator_color1 SlateBlue 
#property indicator_color2 SpringGreen
#property indicator_color3 Magenta
#property indicator_color4 Gray
//---- Bollinger Bands �����
#property indicator_color5 Blue
#property indicator_color6 Blue
#property indicator_color7 Red
#property indicator_color8 Red
//---- ������� ������������ �����
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2 
#property indicator_width4 2
//---- ����� ��������� �����
#property indicator_style1 0
//---- ����� ����� Bollinger Bands
#property indicator_style5 4
#property indicator_style6 4
#property indicator_style7 4
#property indicator_style8 4
//---- ��������� �������������� ������� ����������
#property indicator_level1 0.0
#property indicator_levelcolor DarkGray
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Depth=10;           // ������� ����������� ����������
extern int Smooth_Length=3;     // ������� JMA ����������� �������� ����������
extern int Smooth_Phase =100;    // �������� JMA ����������� �������� ����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������;
extern int Input_Price_Customs = 4;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- �������� ������� digits() ��� ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ���������� 
int digits(){return(0);}
//---- �������� ������� COUNT_begin() ��� ���������� ������ ����, ������� � �������� ����� �������������� ��������� � ������������� Bollinger Bands 
int COUNT_begin(){return(Depth+30);}
//---- ��������� �������� ����������, ������� �� ����� ������ �� ������� 
int EmptyValue=0.0;
//---- ����������� �������� ����������
string Label = "JVEL1";

//---- ��������� � ����� ���������� ��� ��������� ������
#include <3c_BB_Osc.mqh> 
//---- +-----------------------------------------------+
//---- �������� ������� INDICATOR ----------------------------------------------------------------------------+
//---- ��������� � ��������� ���������� ��� ��������� ������� ��������
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom( NULL, 0, "JVEL1", Depth, Smooth_Length, Smooth_Phase, Input_Price_Customs, 1, bar) );
 }
//---- -------------------------------------------------------------------------------------------------------+
 


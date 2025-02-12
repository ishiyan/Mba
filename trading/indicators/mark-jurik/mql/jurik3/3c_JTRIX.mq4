/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\

TRIX  �  ���  ��������  ���������  ����,  ��������� � ������ ������ �.
��������� (�Goog TRIX�, Technical Analysis of Stock & Commodities, ���
1:5,  http://www.forexua.com/indicators/www.traders.com).
TRIX  �  �����������  ��������  �������� ����������������� �����������
���������  ����  ��������.  ���������  ��������������  � ����� ������:
1. �������� �������� ������� ���� ��������;
2. ���������� �������� � ������� ���;
3.  �������� ��� ����������������� ����������� ��������, ���������� ��
����� 2;
4.  �������� ��� ����������������� ����������� ��������, ���������� ��
����� 3;
5.   ���������   �����������   ��������  �����  ������������  ��������
�����������:  ���  �����  ��������  �����  4  �������� ��� �������� ��
�������� ����� 4 ��������������� ���;
6. ��������, ���������� �� ����� 5, �������� (��� �������� �����������
�� �������) �� 10 000.
���������   �RI�  �  ������������  �  ���  ���  ����  ��������  ������
����������,  ���  � � ������ ������ �����������, ����� ��������� �����
����  �  ����������������  ����������  �������.  ����������  ���������
���������   �����  �������������  �RI�.  �����  �������  �������������
�������  �������� �������� ������� ��� ��������� ���������� �� �������
������:  ��������,  �����  �RI�  ������  �����������  �  ���������  ��
��������.  ���������,  �����  �RI�  ������  ����������� � ��������� ��
��������.
Copyright � 2003  Forex company http://www.forexua.com

�  ������  ����������  ����������  ����������� ������� ���� � �������  
�����������������  �����������  ��������  ��������  �� ����������� JMA 
�����������.
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                     3c_JTRIX.mq4 | 
//|                        Copyright � 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers 8 
//---- ����� ���������� 
#property indicator_color1 Purple 
#property indicator_color2 Yellow 
#property indicator_color3 Red
#property indicator_color4 Gray
//---- Bollinger Bands �����
#property indicator_color5 Gray
#property indicator_color6 Gray
#property indicator_color7 Blue
#property indicator_color8 Blue
//---- ������� ������������ �����
#property indicator_width1 3
#property indicator_width2 1
#property indicator_width3 1 
#property indicator_width4 1
//---- ����� ��������� �����
#property indicator_style1 0
//---- ����� ����� Bollinger Bands
#property indicator_style5 4
#property indicator_style6 4
#property indicator_style7 4
#property indicator_style8 4
//---- ��������� �������������� ������� ����������
#property indicator_level1 0.0
#property indicator_levelcolor BlueViolet
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Length = 5;  // ������� �������� ����������� 
extern int Phase = 100; // �������� �������� �����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int Smooth = 5;  // ������� ����������� �������� ����������
extern int Mom_Period = 1;// Momentum ������ ����������
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- �������� ������� digits() ��� ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ���������� 
int digits(){return(0);}
//---- �������� ������� COUNT_begin() ��� ���������� ������ ����, ������� � �������� ����� �������������� ��������� � ������������� Bollinger Bands 
int COUNT_begin(){return(60+Mom_Period+30);}
//---- ��������� �������� ����������, ������� �� ����� ������ �� ������� 
int EmptyValue=0.0;
//---- ����������� �������� ����������
string Label = "JTRIX";
//---- ��������� � ����� ���������� ��� ��������� ������
#include <3c_BB_Osc.mqh> 
//---- +-----------------------------------------------+
//---- �������� ������� INDICATOR ----------------------------------------------------------------------------+
//---- ��������� � ��������� ���������� ��� ��������� ������� ��������
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom( NULL, 0, "JTRIX", Length, Phase,Smooth,Mom_Period, 0, Input_Price_Customs, 0, bar) );
 }
//---- -------------------------------------------------------------------------------------------------------+
/*
���  ������  ����������  �������  ��������  �����   
JJMASeries.mqh
PriceSeries.mqh
3c_BB_Osc.mqh  
� ����� (����������): MetaTrader\experts\include\
JAccelerator.mq4
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                             3c_JAccelerator1.mq4 |
//|                             Copyright � 2006,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers 8 
//---- ����� ���������� 
#property indicator_color1 BlueViolet
#property indicator_color2 Yellow 
#property indicator_color3 Magenta
#property indicator_color4 Purple
//---- Bollinger Bands �����
#property indicator_color5 Blue
#property indicator_color6 Blue
#property indicator_color7 Crimson
#property indicator_color8 Crimson
//---- ������� ������������ �����
#property indicator_width1 1
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
#property indicator_levelcolor Gray
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int FastJMA=05;   // ������� ����������� ������� JMA
extern int SlowJMA=34;   // ������� ����������� ��������� JMA
extern int SignJMA=05;   // ������� ����������� ���������� JMA
extern int JMACD_Phase = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ���������x ��������� JMACD 
extern int Sign_Phase  = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ���������x ��������� ���������� ����� 
extern int Input_Price_Customs = 4;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- �������� ������� digits() ��� ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ���������� 
int digits(){return(0);}
//---- �������� ������� COUNT_begin() ��� ���������� ������ ����, ������� � �������� ����� �������������� ��������� � ������������� Bollinger Bands 
int COUNT_begin(){return(60);}
//---- ��������� �������� ����������, ������� �� ����� ������ �� ������� 
int EmptyValue=0.0;
//---- ����������� �������� ����������
string Label = "JAccelerator";

//---- ��������� � ����� ���������� ��� ��������� ������
#include <3c_BB_Osc.mqh> 
//---- +-----------------------------------------------+

//---- �������� ������� INDICATOR ----------------------------------------------------------------------------------------+
//---- ��������� � ��������� ���������� ��� ��������� ������� ��������
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom( NULL, 0, "JAccelerator",FastJMA,SlowJMA,SignJMA,JMACD_Phase,Sign_Phase,Input_Price_Customs, 0, bar) );
 }
//---- -------------------------------------------------------------------------------------------------------------------+



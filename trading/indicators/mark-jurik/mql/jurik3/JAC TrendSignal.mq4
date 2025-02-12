/*
���  ������  ����������  �������  ��������  �����   
JJMASeries.mqh
PriceSeries.mqh
TrendSignal.mqh 
� ����� (����������): MetaTrader\experts\include\
JAccelerator.mq4
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                              JAC TrendSignal.mq4 |
//|                        Copyright � 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ����� ����������
#property indicator_buffers 8 
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Lime
#property indicator_color6 Lime
#property indicator_color7 Lime
#property indicator_color8 Lime
//---- ������� ������������ �����
#property indicator_width1 3
#property indicator_width2 2
#property indicator_width3 1 
#property indicator_width4 0
#property indicator_width5 0
#property indicator_width6 1
#property indicator_width7 2 
#property indicator_width8 3
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int LEVEL14= 50;
extern int LEVEL13= 43;
extern int LEVEL12= 32;
extern int LEVEL11= 25;
extern int LEVEL01=-25;
extern int LEVEL02=-32;
extern int LEVEL03=-43;
extern int LEVEL04=-50;
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
int digits(){return(Digits);}
//---- �������� ������� COUNT_begin() ��� ���������� ������ ����, ������� � �������� ����� �������������� ��������� � ������������� Bollinger Bands 
int COUNT_begin(){return(60);}
//---- ��������� �������� ����������, ������� �� ����� ������ �� ������� 
int EmptyValue=0.0;
//---- ����������� �������� ����������
string Label = "JAccelerator";

//---- ��������� � ����� ���������� ��� ��������� ������
#include <TrendSignal.mqh> 
//---- +-----------------------------------------------+
//---- �������� ������� INDICATOR ---------------------------------------------------------------------------------------+
//---- ��������� � ��������� ���������� ��� ��������� ������� ��������
double INDICATOR(int INDICATOR.bar)
 {
  return( iCustom( NULL, 0, "JAccelerator",FastJMA,SlowJMA,SignJMA,JMACD_Phase,Sign_Phase,Input_Price_Customs, 0, bar) );
 }
//---- ------------------------------------------------------------------------------------------------------------------+
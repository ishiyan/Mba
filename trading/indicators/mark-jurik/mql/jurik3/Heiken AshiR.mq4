//������������� � ���������� 17.04.2006 ������� �������
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                 Heiken AshiR.mq4 |
//|                               Copyright � 2004, Poul_Trade_Forum |
//|                                                         Aborigen |
//|                                          http://forex.kbpauk.ru/ |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Poul Trade Forum"
#property link      "http://forex.kbpauk.ru/"
//---- ��������� ���������� � ��������� ����
#property  indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers 2
//---- ����� ����������
#property indicator_color1 Red
#property indicator_color2 Lime
//---- ������� � ������ ����������� ����� ���� ����������
#property indicator_maximum 1.1
#property indicator_minimum 0.9
//---- ������� ������������ �����
#property indicator_width1 2
#property indicator_width2 2
//---- ������� ��������� ���������� 
extern int Simbol=110;
//---- ������������ �������
double HighBuffer[];
double LowBuffer [];
//---- ���������� � ��������� ������  
double Trend;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Heiken AshiR initialization function                             |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {   
//---- ����� ���������� ������� ���� ��������
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
//---- ����������� ����� �������� ��������
   SetIndexArrow(0,Simbol);
   SetIndexArrow(1,Simbol);
//---- 2 ������������ ������� ������������ ��� �����.
   SetIndexBuffer(0,HighBuffer);
   SetIndexBuffer(1,LowBuffer );
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
//---- ����� ��� ���� ������ � ����� ��� ��������.
   IndicatorShortName("Heiken Ashi");
   SetIndexLabel   (0,"Heiken Ashi");
   SetIndexLabel   (1,"Heiken Ashi");
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������  
   SetIndexDrawBegin(0,1);
   SetIndexDrawBegin(1,1);
//----

   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Heiken AshiR iteration function                                  |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int MaxBar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
if (counted_bars>0) counted_bars--;
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
MaxBar=Bars-2;
limit=(Bars-1-counted_bars);
//---- ������������� ����
if (limit>MaxBar)
{
  limit=MaxBar;
  HighBuffer[Bars-1]=0; 
  LowBuffer [Bars-1]=0;
}
//----
for (int bar=limit; bar>=0;bar--)
{
  Trend = iCustom(NULL,0,"Heiken Ashi#",1,bar)-iCustom(NULL,0,"Heiken Ashi#",0,bar);
  if (Trend>0){HighBuffer[bar]=1; LowBuffer [bar]=0;}
  if (Trend<0){LowBuffer [bar]=1; HighBuffer[bar]=0;}
}
   return(0);
 }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� INDICATOR_COUNTED (���� INDICATOR_COUNTED.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+


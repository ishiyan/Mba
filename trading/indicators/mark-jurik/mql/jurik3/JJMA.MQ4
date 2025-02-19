/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh � 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                         JJMA.mq4 | 
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
#property indicator_color1 Red  
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Length = 5;   // �������  ������� ����������� 
extern int Phase  = 100; // �������� ������� �����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int Shift  = 0;   // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double JJMA[];
//---- ���������� � ��������� ������  
double Temp_Series,Resalt;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JJMA indicator initialization function                           | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{  
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE); 
//---- 1 ������������ ������ ����������� ��� �����
SetIndexBuffer(0,JJMA);
//---- �������������� ����� ������������ ����� 
SetIndexShift (0, Shift); 
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
SetIndexEmptyValue(0,0.0);    
//---- ��� ��� ���� ������ � ����� ��� ��������. 
IndicatorShortName ("JJMA( Length="+Length+", Phase="+Phase+",  Shift="+Shift+")"); 
SetIndexLabel (0, "JJMA"); 
//----
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- ��������� ������� �� ������������ �������� ������� ���������� ==============================================================+ 
if(Phase<-100){Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������ -100");}
if(Phase> 100){Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������  100");}
if(Length<  1){Alert("�������� Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length+ " ����� ������������  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+================================================================================================================================+
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
int reset,MaxBar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
if (counted_bars==0)JJMASeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
MaxBar=Bars-1; int limit=MaxBar-counted_bars;

//----+ �������� ���� ���������� ���������� 
for(int bar=limit;bar>=0;bar--)
  {
    //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
    Temp_Series=PriceSeries(Input_Price_Customs, bar);
    //----+ ��������� � ������� JJMASeries �� ������� 0. ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
    Resalt=JJMASeries(0,0,MaxBar,limit,Phase,Length,Temp_Series,bar,reset);
    //----+ �������� �� ���������� ������ � ���������� ��������
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
    JJMA[bar]=Resalt;
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
/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh � 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+------------------------------------------------------------------+  
//|                                                         JJMA.mq4 | 
//|               MQL4+J2JMA: Copyright � 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright � 2006, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_separate_window 
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_width1 3
#property indicator_width2 3 

//---- ������� ��������� ���������� --------------------------------------------------------------------------------------------------+
extern int Length = 14;   // ������� JMA ����������� 
extern int Phase  =  0; // �������� JMA �����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int Input_Price_Customs = 0;/* ����� ���, �� ������� ������������ ������ ���������� 
(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.) */
//---- -------------------------------------------------------------------------------------------------------------------------------+
//---- ������������ ������
double UpBuffer [];
double DnBuffer [];
double JJMA[];
//---- ���������� � ��������� ������  
double Temp_Series,Resalt;
//+------------------------------------------------------------------+  
//----+ �������� ������� JJMASeries 
//----+ �������� ������� JJMASeriesResize 
//----+ �������� ������� JJMASeriesAlert  
//----+ �������� ������� JMA_ErrDescr  
#include <JJMASeries.mqh> 
//+------------------------------------------------------------------+  
//----+ �������� ������� PriceSeries
//----+ �������� ������� PriceSeriesAlert 
#include <PriceSeries.mqh>
//+------------------------------------------------------------------+    
//| JJMA indicator initialization function                           | 
//+------------------------------------------------------------------+  
int init() 
{  
//---- ����������� ����� ���������� �������
IndicatorBuffers(3);
SetIndexStyle  (0, DRAW_HISTOGRAM);
SetIndexStyle  (1, DRAW_HISTOGRAM);
SetIndexBuffer (0, UpBuffer);
SetIndexBuffer (1, DnBuffer); 
SetIndexBuffer (2, JJMA);
SetIndexDrawBegin(0, 31);//2*Length+1);
SetIndexDrawBegin(1, 31);//2*Length+1);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
SetIndexEmptyValue(0,0.0);    
SetIndexEmptyValue(1,0.0);
//---- ��� ��� ���� ������ � ����� ��� �������� 
IndicatorShortName ("JJMASlope( Length="+Length+", Phase="+Phase+")"); 
SetIndexLabel (0, "JJMA UpTrend");
SetIndexLabel (1, "JJMA DnTrend"); 
//---- ��������� ������� �������� ����������� ����������
IndicatorDigits(Digits);
//---- ��������� ������� �� ������������ �������� ������� ����������
JJMASeriesAlert (0,"Length",Length);
JJMASeriesAlert (1,"Phase", Phase);
PriceSeriesAlert(Input_Price_Customs);
//----+ ��������� �������� �������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � ������� JJMASeries)
if (JJMASeriesResize(1)!=1)return(-1);
//---- ���������� �������������
return(0); 
} 
//+------------------------------------------------------------------+  
//| JJMA iteration function                                          | 
//+------------------------------------------------------------------+  
int start() 
{ 
//---- �������� ���������� ����� �� ������������� ��� ����������� �������
if (Bars-1<31)return(0);
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
int reset,MaxBar,counted_bars=IndicatorCounted();
//---- �������� �� ��������� ������
if (counted_bars<0)return(-1);
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
MaxBar=Bars-1; int limit=MaxBar-counted_bars;

//----+ �������� ���� ���������� ���������� 
for(int bar=limit;bar>=0;bar--)
  {
    //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
    Temp_Series=PriceSeries(Input_Price_Customs, bar);
    //----+ ��������� � ������� JJMASeries �� ������� 0. ��������� nJMA.Phase � nJMA.Length �� �������� �� ������ ���� (nJMA.din=0)
    Resalt=JJMASeries(0,0,MaxBar,limit,Phase,Length,Temp_Series,bar,reset);
    //----+ �������� �� ���������� ������ � ���������� ��������
    if(reset!=0)return(-1);
    JJMA[bar]=Resalt;
    double rel=(JJMA[bar]-JJMA[bar+1])/Point;
    if(rel>=0)
    {
    UpBuffer[bar]=rel; 
    DnBuffer[bar]=0;
    }
    else
    { 
    DnBuffer[bar]=rel;
    UpBuffer[bar]=0;
    } 
  }
//---- ���������� ���������� �������� ����������
return(0); 
} 

//+--------------------------------------------------------+
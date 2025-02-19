/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh
JurSeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                        JCCIX.mq4 |
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
extern int  JCCIX.Length = 8;  // ������� ����������� ����������
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Ind_Buffer1[];
//---- ����� ���������� 
int    w;
//---- ���������� � ��������� ������    
double price,JCCIX,UPCCI,DNCCI,JUPCCIX,JDNCCIX,Temp_Series,JMA; 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JCCIX initialization function                                    |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
 {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_LINE);
//---- 1 ������������ ������ ����������� ��� �����. 
   SetIndexBuffer(0,Ind_Buffer1);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0); 
//---- ����� ��� ���� ������ � ����� ��� ��������.
   SetIndexLabel(0,"JCCIX("+JCCIX.Length+")");
   IndicatorShortName("JCCIX(JCCIX.Length="+JCCIX.Length+")");
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������  
   IndicatorDigits(0);
//---- ��������� ������� �� ������������ �������� ������� ���������� ==========================================================================+ 
if(JCCIX.Length< 1) {Alert("�������� JCCIX.Length ������ ���� �� ����� 1"+ " �� ����� ������������ "+JCCIX.Length+ " ����� ������������ 1");}//|
PriceSeriesAlert(Input_Price_Customs);//---- ��������� � ������� PriceSeriesAlert /////////////////////////////////////////////////////////////|
//---- ========================================================================================================================================+ 
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������  
   SetIndexDrawBegin(0,JCCIX.Length+1);
//---- �������� ������������� �������� ��������� JCCIX.Length
   if(JCCIX.Length<1)JCCIX.Length=1; 
//---- ������������� ������������� ��� ������� ���������� 
   if (JCCIX.Length>5) w=JCCIX.Length-1; else w=5;
//---- ���������� �������������
return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|  JCommodity Channel IndexX                                       |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
  {
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,MaxBar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
//---- (��� ����� ��������� ��� counted_bars ������ JJMASeries � JurXSeries ����� �������� �����������!!!)
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������q JJMASeries � JurXSeries 
if (counted_bars==0){JJMASeriesReset(1);JurXSeriesReset(2);}
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1; MaxBar=Bars-1; 
//---- �������� ���������� ��������� ���� � �����
if(limit>=MaxBar)limit=MaxBar;

for(int bar=limit; bar>=0; bar--)
 { 
   //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
   Temp_Series=PriceSeries(Input_Price_Customs, bar);
   //+----------------------------------------------------------------------------+ 
   //----+ ���� ��������� � ������� JJMASeries �� ������� 0. 
   //----+ ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
   //+----------------------------------------------------------------------------+   
   JMA=JJMASeries(0,0,MaxBar,limit,100,JCCIX.Length,Temp_Series,bar,reset);
   //----+ �������� �� ���������� ������ � ���������� ��������
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
   //+----------------------------------------------------------------------------+    
   price=PriceSeries(Input_Price_Customs, bar);
   UPCCI=price-JMA;         
   DNCCI=MathAbs(UPCCI);
   //----+ ��� ��������� � ������� JurXSeries �� �������� 0 � 1. �������� nJJurXLength �� ����t��� �� ������ ���� (nJurXdin=0)
   //----+ �������� �� ���������� ������ � ���������� ��������
   JUPCCIX=JurXSeries(0,0,MaxBar-30,limit,JCCIX.Length,UPCCI,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   JDNCCIX=JurXSeries(1,0,MaxBar-30,limit,JCCIX.Length,DNCCI,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   //----+
   if (bar>MaxBar-30-w)JCCIX=0;
   else 
     if (JDNCCIX!=0)
       {
        JCCIX=JUPCCIX/JDNCCIX;
        if(JCCIX>1)JCCIX=1;
        if(JCCIX<-1)JCCIX=-1;
       }
     else JCCIX=0;
   Ind_Buffer1[bar]=JCCIX; 
   //----+
 }
//----
   return(0);
  }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� JJMASeries (���� JJMASeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
//----+ �������� ������� JJMASeriesReset  (�������������� ������� ����� JJMASeries.mqh)
//----+ �������� ������� INDICATOR_COUNTED(�������������� ������� ����� JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� JurXSeries (���� JurXSeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
//----+ �������� ������� JurXSeriesReset (�������������� ������� ����� JurXSeries.mqh)
#include <JurXSeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� PriceSeries, ���� PriceSeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include
//----+ �������� ������� PriceSeriesAlert (�������������� ������� ����� PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+


/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                     JAwesome.mq4 |
//|                        Copyright � 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property  indicator_buffers 3
//---- ����� ����������
#property indicator_color1  MediumSeaGreen
#property indicator_color2  Red
#property indicator_color3  Gray
//---- ������� ������������ �����
#property indicator_width1 3
#property indicator_width2 2 
#property indicator_width3 2
//---- ����� ��������� ����� ����������
#property indicator_style1 4
//---- ��������� �������������� ������� ����������
#property indicator_level1 0.0
#property indicator_levelcolor Blue
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int FastJMA=05;   // ������� ����������� ������� JMA
extern int SlowJMA=34;   // ������� ����������� ��������� JMA
extern int JMACD_Phase = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ���������x ��������� JMACD  
extern int Input_Price_Customs = 4;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double     Ind_Buffer0[];
double     Ind_Buffer1[];
double     Ind_Buffer2[];
//---- ���������� � ��������� ������
double JMACD,FastJ,SlowJ,Signal,Temp_Series,trend;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JAwesome initialization function                                 |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������    
   IndicatorDigits(0);
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������    
   SetIndexDrawBegin(0,61);
   SetIndexDrawBegin(1,61);
   SetIndexDrawBegin(2,61);
//---- 3 ������������ �������� ������������ ��� �����.
   SetIndexBuffer(0,Ind_Buffer0);
   SetIndexBuffer(1,Ind_Buffer1);
   SetIndexBuffer(2,Ind_Buffer2);
//---- ����� ��� ���� ������ � ����� ��� ��������.
   IndicatorShortName("JAwesome");
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
//---- ��������� ������� �� ������������ �������� ������� ���������� =====================================================================================+ 
if(JMACD_Phase<-100) {Alert("�������� JMACD_Phase ������ ���� �� -100 �� +100" +  " �� ����� ������������ " +JMACD_Phase+    " ����� ������������ -100");}
if(JMACD_Phase> 100) {Alert("�������� JMACD_Phase ������ ���� �� -100 �� +100" +  " �� ����� ������������ " +JMACD_Phase+    " ����� ������������  100");}
if(FastJMA<  1)      {Alert("�������� FastJMA ������ ���� �� ����� 1"     + " �� ����� ������������ " +FastJMA+  " ����� ������������  1"  );}
if(SlowJMA<  1)      {Alert("�������� SlowJMA ������ ���� �� ����� 1"     + " �� ����� ������������ " +SlowJMA+  " ����� ������������  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+=======================================================================================================================================================+    
//---- ���������� �������������
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Awesome Oscillator                                               |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,MaxBar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
//---- (��� ����� ��������� ��� counted_bars ������� JJMASeries ����� �������� �����������!!!)
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=2(��� ��������� � ������� JJMASeries)
if (counted_bars==0)JJMASeriesReset(2);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1; MaxBar=Bars-1; 

for(int bar=limit; bar>=0; bar--)
 {
   //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
   Temp_Series=PriceSeries(Input_Price_Customs, bar);
   //+----------------------------------------------------------------------------+ 
   //----+ ��� ��������� � ������� JJMASeries �� �������� 0, 1. 
   //----+ ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
   //+----------------------------------------------------------------------------+   
   FastJ=JJMASeries(0,0,MaxBar,limit,JMACD_Phase,FastJMA,Temp_Series,bar,reset);
   //----+ �������� �� ���������� ������ � ���������� ��������
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
   //+----------------------------------------------------------------------------+ 
   SlowJ=JJMASeries(1,0,MaxBar,limit,JMACD_Phase,SlowJMA,Temp_Series,bar,reset);
   //----+ �������� �� ���������� ������ � ���������� ��������
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   //+----------------------------------------------------------------------------+ 
   
   JMACD=FastJ-SlowJ;
   //----+ ��������� ������� ��������� JMACD �� �������  
   JMACD=JMACD/Point;
   //---- +SSSSSSSSSSSSSSSS <<< ���������� ��� ���������� >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
   trend=JMACD-Ind_Buffer0[bar+1]-Ind_Buffer1[bar+1]-Ind_Buffer2[bar+1];     
   if     (trend>0){Ind_Buffer0[bar]=JMACD; Ind_Buffer1[bar]=0;     Ind_Buffer2[bar]=0;}
   else{if(trend<0){Ind_Buffer0[bar]=0;     Ind_Buffer1[bar]=JMACD; Ind_Buffer2[bar]=0;}
   else            {Ind_Buffer0[bar]=0;     Ind_Buffer1[bar]=0;     Ind_Buffer2[bar]=JMACD;}}    
   //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+    
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
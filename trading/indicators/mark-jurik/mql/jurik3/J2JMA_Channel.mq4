/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
� PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                J2JMA_Channel.mq4 | 
//|                           Copyright � 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 3
//---- ����� ����������
#property indicator_color1 Red
#property indicator_color2 Gray
#property indicator_color3 Gray
//---- ����� ����� ����������
#property indicator_style1 0
#property indicator_style2 4
#property indicator_style3 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int  Channel_width = 100; // ������ ������ � �������
extern int        Length1 = 3;   // ������� ������� ����������� 
extern int        Phase1  = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� �������� ������� ����������� 
extern int        Length2 = 3;   // ������� ������� ����������� 
extern int        Phase2  = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� �������� ������� �����������  
extern int         Shift  = 0;   // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double JJMA[];
double UpperBuffer[];
double LowerBuffer[];
//---- ����� ����������
int nf; 
//---- ���������� � ��������� ������ 
double Series,Half_Width,Resalt,Temp_Series;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| J2JMA_Channel initialization function                            |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init() 
{ 
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE);
SetIndexStyle (1,DRAW_LINE);
SetIndexStyle (2,DRAW_LINE); 
//---- 3 ������������ ������� ������������ ��� �����
SetIndexBuffer(0,JJMA);  
SetIndexBuffer(1,UpperBuffer); 
SetIndexBuffer(2,LowerBuffer);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
SetIndexEmptyValue(0,0.0);  
SetIndexEmptyValue(1,0.0); 
SetIndexEmptyValue(2,0.0); 
//---- �������������� ����� ������������ �����
SetIndexShift (0, Shift); 
SetIndexShift (1, Shift); 
SetIndexShift (2, Shift); 
//---- ��������� ������� �� ������������ �������� ������� ���������� =================================================================+ 
if(Phase1<-100){Alert("�������� Phase1 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase1+  " ����� ������������ -100");}
if(Phase1> 100){Alert("�������� Phase1 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase1+  " ����� ������������  100");}
if(Length1<  1){Alert("�������� Length1 ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length1+ " ����� ������������  1"  );}
if(Phase2<-100){Alert("�������� Phase2 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase2+  " ����� ������������ -100");}
if(Phase2> 100){Alert("�������� Phase2 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase2+  " ����� ������������  100");}
if(Length2<  1){Alert("�������� Length2 ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length2+ " ����� ������������  1"  );}
PriceSeriesAlert(Input_Price_Customs);////PriceSeriesAlert///////PriceSeriesAlert//////////PriceSeriesAlert/////////PriceSeriesAlert//|
//+===================================================================================================================================+
//---- ��������� ������ ����, ������� � �������� ����� �������������� ��������� 
int draw_begin=50; 
SetIndexDrawBegin(0,draw_begin);
SetIndexDrawBegin(1,draw_begin);
SetIndexDrawBegin(2,draw_begin); 
//---- ������ ������ � �������
Half_Width = Channel_width*Point/2;
//---- ���������� �������������
return(0); 
}
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| J2JMA_Channel iteration function                                 |
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
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=2(��� ��������� � ������� JJMASeries)
if (counted_bars==0)JJMASeriesReset(2);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
MaxBar=Bars-1; int limit=MaxBar-counted_bars;

//----+ �������� ���� ���������� ���������� 
for(int bar=limit;bar>=0;bar--)
  {
    //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
    Temp_Series=PriceSeries(Input_Price_Customs, bar);
    //----+ ��������� � ������� JJMASeries �� ������� 0. ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
    Temp_Series=JJMASeries(0,0,MaxBar,limit,Phase1,Length1,Temp_Series,bar,reset);
    //----+ �������� �� ���������� ������ � ���������� ��������
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
    //----+ ��������� � ������� JJMASeries �� ������� 1. ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
    Resalt     =JJMASeries(1,0,MaxBar,limit,Phase2,Length2,Temp_Series,bar,reset);
    //----+ �������� �� ���������� ������ � ���������� ��������
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
    
    JJMA[bar]=Resalt;
   //----+ ������ ������
   UpperBuffer[bar]=Resalt+Half_Width;     
   LowerBuffer[bar]=Resalt-Half_Width;
   //---- ���������� ���������� �������� ����������        
  }
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
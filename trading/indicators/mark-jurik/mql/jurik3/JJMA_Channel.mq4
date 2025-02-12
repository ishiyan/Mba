/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
� PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                 JJMA_Channel.mq4 | 
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
extern int Channel_width = 100; // ������ ������ � �������
extern int        Length = 3;   // ������� ����������� 
extern int        Phase  = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int        Shift  = 0;   // c���� ���������� ����� ��� ������� 
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
//| JJMA_Channel initialization function                             |
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
//---- �������������� ����� ������������ �����
SetIndexShift (0, Shift); 
SetIndexShift (1, Shift); 
SetIndexShift (2, Shift); 
//---- ��������� ������� �� ������������ �������� ������� ���������� ==============================================================+ 
if(Phase<-100){Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������ -100");}
if(Phase> 100){Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������  100");}
if(Length<  1){Alert("�������� Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length+ " ����� ������������  1"  );}
PriceSeriesAlert(Input_Price_Customs);////PriceSeriesAlert///////PriceSeriesAlert//////////PriceSeriesAlert/////////PriceSeriesAlert////|
//+================================================================================================================================+
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
//| JJMA_Channel iteration function                                  |
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
    //----+ J�������� � ������� JJMASeries �� ������� 0. ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
    Resalt=JJMASeries(0,0,MaxBar,limit,Phase,Length,Temp_Series,bar,reset);
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
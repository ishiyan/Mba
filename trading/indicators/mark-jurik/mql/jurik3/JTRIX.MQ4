/*
���  ������  ����������  �������  ��������  ����� 
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
//|                                                        JTRIX.mq4 | 
//|                        Copyright � 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers 1 
//---- ����� ����������
#property indicator_color1 Blue
//---- ��������� �������������� ������� ����������
#property indicator_level1 0.0
#property indicator_levelcolor BlueViolet
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Length = 5;  // ������� �������� ����������� ������� ����
extern int Phase = 100; // �������� �������� �����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int Smooth = 5;  // ������� ����������� �������� ����������
extern int Mom_Period = 1;  // Momentum ������ ����������
extern int Ind_Shift   = 0; // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Ind_Buffer1 [];
double Smooth_Price[];
//---- ���������� � ��������� ������ 
double Series,Temp_Series,Trix,JTRIX;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JTRIX initialization function                                    | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{  
//---- 2 ������������ ������� ������������ ��� �����. 
IndicatorBuffers(2);
SetIndexBuffer(0,Ind_Buffer1 );
SetIndexBuffer(1,Smooth_Price);
//---- ��������� �������� ����������, ������� �� ����� ������ �� ������� 
SetIndexEmptyValue(0,0); 
//---- �������������� ����� ������������ ����� 
SetIndexShift (0, Ind_Shift); 
//---- ����� ���������� ������� ���� �������� �����
SetIndexStyle(0,DRAW_LINE);
//---- ����� ��� ���� ������ � ����� ��� ��������. 
IndicatorShortName ("JTRIX( Length="+Length+", Smooth="+Smooth+", Mom_Period="+Mom_Period+")"); 
SetIndexLabel   (0, "JTRIX"); 
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������  
IndicatorDigits(0);
//---- ��������� ������� �� ������������ �������� ������� ���������� =========================================================================+ 
if(Phase<-100)    {Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������ -100");}//////|
if(Phase> 100)    {Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������  100");}//////|
if(Length<  1)    {Alert("�������� Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length+ " ����� ������������  1"  );}//////|
if(Smooth<  1)    {Alert("�������� Smooth ������ ���� �� ����� 1"     + " �� ����� ������������ " +Smooth+ " ����� ������������  1"  );}//////|
if(Mom_Period<1)  {Alert("�������� Mom_Period ������ ���� �� ����� 1"  + " �� ����� ������������ "+Mom_Period+ " ����� ������������  1");}////|
PriceSeriesAlert(Input_Price_Customs);//---- ��������� � ������� PriceSeriesAlert ////////////////////////////////////////////////////////////|
//+===========================================================================================================================================+
//---- �������� ������������� �������� ��������� Mom_Period
if(Mom_Period<1)Mom_Period=1; 
//---- ���������� �������������
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JTRIX iteration function                                         | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----  �������� ���������� ����� �� ���������� ����������� ��� ������� JTRIX
if (Bars-1<Mom_Period-60)return(0);
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,limit,MaxBar1,MaxBar2,MaxBarJ,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=3(��� ��������� � �������)  
if (counted_bars==0)JJMASeriesReset(3);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1;
MaxBar1=Bars-1; MaxBar2=MaxBar1-30; MaxBarJ=MaxBar2-30-Mom_Period; 

//----+ ���� ������� ��������� ������� ���� � ������� ������������ 
for(int bar=limit;bar>=0;bar--)
  {
  //----+ ��������� � ������� TimeJJMASeries ��� ��������� ������� ����
   Series=PriceSeries(Input_Price_Customs, bar);
   //----+ ����������������  ������� ����
   Temp_Series=MathLog(Series);
   //----+ ��� ���������������� ��������� � ������� JJMASeries �� �������� 0, 1 ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
   //----+ (�� ������ ��������� �������� nJMAMaxBar  �������� �� 30  �. �. ��� ��������� JMA �����������)  
   Temp_Series=JJMASeries(0,0,MaxBar1,limit,Phase,Length,Temp_Series,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   Temp_Series=JJMASeries(1,0,MaxBar2,limit,Phase,Length,Temp_Series,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   Smooth_Price[bar]=Temp_Series;
  }
//---- ������������� ��������������� �������� ��������� ���� � ��������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
if(limit>MaxBarJ)
 {
  for(bar=limit;bar>=MaxBarJ;bar--)Ind_Buffer1[bar]=0.0;
  limit=MaxBarJ;
 }

//----+ �������� ���� ���������� ���������� JTRIX 
for(bar=limit;bar>=0;bar--)
  {
  Trix=10000*(Smooth_Price[bar]-Smooth_Price[bar+Mom_Period]);
  //----+ ��������� � ������� JJMASeries �� ������� 2, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0) 
  //(� ���� ��������� �������� nJMAMaxBar �������� ��� �� 30  �. �. ��� ��������� JMA �����������) 
  JTRIX=JJMASeries(2,0,MaxBarJ,limit,100,Smooth,Trix,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
  Ind_Buffer1[bar]=JTRIX; 
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
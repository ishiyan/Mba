/*
���  ������  ����������  �������  ��������   �����      
JMASeries.mqh,
PriceSeries.mqh 
� ����� (����������):       MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\

���������  Momentum  (����) �������� �������� ��������� ���� ������ ��
������������  ������. �������� ������� ������������� ���������� �����:
�  ��������  �����������, ���������� �� ����������, ���������� MACD. �
����  ������  ������  �  �������  ���������,  ����  ��������� ��������
������� � �������� �����; � ������ � ������� - ����� �� ��������� ����
�  ������������ ����. ��� ����� ������� ����������� �������� ���������
����������  ����� ������������ ��� �������� ���������� �������. ������
�������  ��� ������ �������� ���������� ����� ������������ �����������
�������  ���������.  ���,  ����  ���������  ���������  ������  �������
��������  � ����� ������������ ����, ������� ������� ����������� �����
���.  ��  �  ����� ������ � ��������� (��� ���������) ������� �� �����
�������  ��  ���  ���,  ����  ����  �� ���������� ������ ����������. �
�������� ������������ ����������. ���� ������ ������� �� �������������
�   ���,   ���   ��������������   ����   ����������  ���������  ������
��������������  �������������  ������  ���  (���  ���  ��� ����� � ���
�����������),  �  ��������� ���������� ����� - �� ������ �������� (���
��� ��� ��������� ����� �� �����). ������ ��� ������� � ����������, ��
��� �� ��� ������� ������� ���������. 
�  ������ ���������� ������������ �������� ������� � ������� ��������� 
JMA. 
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                    JMomentum.mq4 | 
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
#property indicator_color1 Lime
//---- ��������� �������������� ������� ����������
#property indicator_level1 0.0
#property indicator_levelcolor Blue
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Mom_Period  = 8;  // ������ Momentum
extern int Smooth      = 8;  // ������� JMA ����������� �������� ����������
extern int Smooth_Phase = 100;// ��������, ������������ � �������� -100 ... +100, ������ �� �������� ���������x JMA ��������� ����������� 
extern int Ind_Shift   = 0;  // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Ind_Buffer1[];
//---- ���������� � ��������� ������ 
double Momentum,JMomentum;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JMomentum initialization function                                | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{ 
//---- 1 ������������ ������ ����������� ��� �����.
SetIndexBuffer(0,Ind_Buffer1);
//---- ��������� �������� ����������, ������� �� ����� ������ �� ������� 
SetIndexEmptyValue(0,0); 
//---- �������������� ����� ������������ ����� 
SetIndexShift (0, Ind_Shift); 
//---- ����� ���������� ������� ���� �������� �����
SetIndexStyle(0,DRAW_LINE);
//---- ����� ��� ���� ������ � ����� ��� ��������.  
SetIndexLabel   (0, "JMomentum"); 
IndicatorShortName ("JMomentum"); 
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ���������� 
IndicatorDigits(0);
//---- ��������� ������� �� ������������ �������� ������� ���������� ======================================================================================+ 
if(Smooth_Phase<-100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+ " ����� ������������ -100");}///|
if(Smooth_Phase> 100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+ " ����� ������������  100");}///|
if(Mom_Period< 1)   {Alert("�������� Mom_Period ������ ���� �� ����� 1"  + " �� ����� ������������ " +Mom_Period+ " ����� ������������  1");}//////////////|
if(Smooth< 1)       {Alert("�������� Smooth ������ ���� �� ����� 1"      + " �� ����� ������������ " +Smooth+   " ����� ������������  1");}////////////////|
PriceSeriesAlert(Input_Price_Customs);//---- ��������� � ������� PriceSeriesAlert ///////////////////////////////////////////////////////////////////////////|
//---- ====================================================================================================================================================+ 
//---- �������� ������������� �������� ��������� Mom_Period
if(Mom_Period<1)Mom_Period=1; 
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������  
int draw_begin=Mom_Period+30; 
SetIndexDrawBegin(0,draw_begin); 
//---- ���������� �������������
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JMomentum iteration function                                     | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,bar,MaxBarM,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
if(counted_bars==0)JJMASeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1; MaxBarM=Bars-1-Mom_Period;
//---- ������������� ���� ���������������� �������� �������� � ��������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����        
if (limit>=MaxBarM)
   {
    for(bar=limit;bar>=MaxBarM;bar--)Ind_Buffer1[bar]=0.0;
    limit=MaxBarM;
   }  
       
//----+ �������� ���� ���������� ���������� JMomentum
for(bar=limit;bar>=0;bar--)
   {
    //----+ ��������� ������� ���������� Mom_Period ( ��� ��������� � ������� PriceSeries )
    Momentum=PriceSeries(Input_Price_Customs,bar)-PriceSeries(Input_Price_Customs,bar+Mom_Period);  
    //----+ ��������� ������� ��������� JMomentum �� ������� 
    Momentum=Momentum/Point;
   
    //----+ ����������� ���������� Momentum
    //----+ ��������� � ������� JJMASeries �� ������� 0, ��������� nJMASmooth_Phase � nJMASmooth �� �������� �� ������ ���� (nJMAdin=0)
    JMomentum=JJMASeries(0,0,MaxBarM,limit,Smooth_Phase,Smooth,Momentum,bar,reset);
    //----+ �������� �� ���������� ������ � ���������� ��������
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}    
    Ind_Buffer1[bar]=JMomentum;
   }
//---- ���������� ���������� �������� ����������
return(0);  
}
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� JJMASeries (���� JJMASeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
//----+ �������� ������� JJMASeriesReset (�������������� ������� ����� JJMASeries.mqh)
//----+ �������� ������� INDICATOR_COUNTED(�������������� ������� ����� JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� PriceSeries, ���� PriceSeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include
//----+ �������� ������� PriceSeriesAlert (�������������� ������� ����� PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+


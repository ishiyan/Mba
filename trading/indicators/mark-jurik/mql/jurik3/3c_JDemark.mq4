/*
���  ������  ����������  �������  �������� ���� 
JJMASeries.mqh 
(����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\

              "�������� ���������� �.������� " 
��   ������   ������   ������������  �������  ���������,  ������������
�.��������.  �������  ��  ������  �  DMI,  �� ����� ������ �����������
(DEMARK  �  �������  �� ADX, ��������� ������ ������������� ����, � ��
����   ��������)  ��  ����  ���������  �������  �  �������  �  �������
�������������  �����  ����  ��������  ���  ���������� �������� ������.
����������� ����������: ���� ����������� high ���� ���������� high, ��
������������  ���������������  ��������,  ����  �����������  low  ����
����������,  �� �������� ������������ ��������������� �������� (� �� �
������  -  �������������  ��������).  ����������  ������ n, �� �������
����������    ���������������    (����������),   ��������   ����������
����������,  ������� �����: DEMARK = (����������� �� n ������ ��������
high  -  high[-1]) / (  (�����������  ��  n  ������  ��������   high -
high[-1])  +  (�����������  ��  n ������ �������� low[-1] - low) ) ���
������   ����������  ��  �����������  �����  ����  �����������  n;  ��
���������  ������������  ��������  n  = 13. ������ ����� ���������� ��
������  ����������  RSI:  ��  ����� �������� ������� ��������������� �
���������������,  ����� ���������� ������� �����������. � �� �� �����,
��  ������  ���������  ��  �����  �����  ������������, ���  ���  ����� 
����� ��������� ��������� �����.
                � 1997-2005, �FOREX CLUB�
     http://www.fxclub.org/academy_lib_article/article17.html
� ������ ���������� ��������, ���������� �� ������ ���������  �������,
��������  �  �������  JMA  �����������  �  ��������� ���������� �����, 
���������� �������������� JMA ������������. 
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                   3c_JDemark.mq4 | 
//|                        Copyright � 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers  4
//---- ����� ����������
#property indicator_color1  Blue
#property indicator_color2  Magenta
#property indicator_color3  Purple
#property indicator_color4  Aqua
//---- ������� ������������ �����
#property indicator_width1 3
#property indicator_width2 3 
#property indicator_width3 3
//---- ����� ���������� ����� ����������
#property indicator_style4 4
//---- ��������� �������������� ������� ����������
#property indicator_level1   50
#property indicator_level2  -50
#property indicator_level3   0
#property indicator_levelcolor DarkOrchid
#property indicator_levelstyle 4
//---- ������� ��������� ���������� -----+   
extern int Demark_Period = 13;
extern int Demark_Smooth = 3; 
extern int Smooth_Phase  = 100;
extern int Sign_Length   = 15;
extern int Sign_Phase    = 100;
//---- ----------------------------------+
//---- ������������ �������
double Ind_Buffer1[];
double Ind_Buffer2[];
double Ind_Buffer3[];
double Ind_Buffer4[];
//---- ���������� � ��������� ������ 
double MinHigh,MinLow,Up,Down,Demark,JDemark,trend,Signal;  
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JDemark initialization function                                  | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- 4 ������������ ������� ������������ ��� �����.
if(!SetIndexBuffer(0,Ind_Buffer1) &&
   !SetIndexBuffer(1,Ind_Buffer2) &&
   !SetIndexBuffer(2,Ind_Buffer3) &&
   !SetIndexBuffer(3,Ind_Buffer4))
   Print("cannot set indicator buffers!");   
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_HISTOGRAM, STYLE_SOLID); 
   SetIndexStyle(1,DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(3,DRAW_LINE);
//---- ����� ��� ���� ������ � ����� ��� ��������.
   IndicatorShortName ("JDemark");
   SetIndexLabel(0,"Up_Trend");
   SetIndexLabel(1,"Down_Trend");
   SetIndexLabel(2,"Straight_Trend");
   SetIndexLabel(3,"Signal");
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0); 
   SetIndexEmptyValue(3,0); 
//---- ��������� ������� �� ������������ �������� ������� ���������� ======================================================================================+ 
if(Smooth_Phase<-100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+  " ����� ������������ -100");}//|
if(Smooth_Phase> 100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+  " ����� ������������  100");}//|
if(Sign_Phase<-100)  {Alert("�������� Sign_Phase ������ ���� �� -100 �� +100"   + " �� ����� ������������ " +Sign_Phase+    " ����� ������������ -100");}//|
if(Sign_Phase> 100)  {Alert("�������� Sign_Phase ������ ���� �� -100 �� +100"   + " �� ����� ������������ " +Sign_Phase+    " ����� ������������  100");}//|
if(Demark_Smooth< 1) {Alert("�������� Demark_Smooth ������ ���� �� ����� 1"     + " �� ����� ������������ " +Demark_Smooth+ " ����� ������������  13");}///|
if(Demark_Period< 1) {Alert("�������� Demark_Period ������ ���� �� ����� 1"     + " �� ����� ������������ " +Demark_Period+ " ����� ������������  1");}////|
if(Sign_Length< 1)   {Alert("�������� Sign_Length ������ ���� �� ����� 1"       + " �� ����� ������������ " +Sign_Length+   " ����� ������������  1");}////|
//+========================================================================================================================================================+ 
//---- �������� ������������� �������� ��������� Demark_Period
   if(Demark_Period<1)Demark_Period=1;
//---- ��������� ������ ����, ������� � �������� ����� �������������� ��������� 
   int draw_begin=Demark_Period+1+30; 
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);  
   SetIndexDrawBegin(3,draw_begin+30);     
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������  
   IndicatorDigits(0);
//---- ���������� �������������   
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JDemark iteration function                                       | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
   { 
   //---- �������� �� ���������� ����� �� ������������� ��� �������
   if (Bars-1<Demark_Period)return(0);  
   //----+ �������� ����� ���������� � ��������� ��� ������������ �����
   //---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
   int reset,MaxBarD,MaxBarJ,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
   //---- �������� �� ��������� ������
   if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
   //---- ��������� ������������ ��� ������ ���� ����������
   if (counted_bars>0) counted_bars--;
   //----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=2(���  ��������� � �������)
   if (counted_bars==0)JJMASeriesReset(2);
   //---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
   limit=Bars-counted_bars-1; MaxBarD=Bars-1-Demark_Period; MaxBarJ=MaxBarD-30; 
   //----+  
   for(int bar=limit; bar>=0; bar--) 
     {  
        //----+ ������ ���������� ������� (��������� � ������������ ���������� iDeMarker)  
        Demark=200*iDeMarker(NULL, 0, Demark_Period, bar)-100;
             
        //----+ ����������� �������� ����������
        //----+ ( ��������� � ������� JJMASeries �� ������� 0, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0))
        JDemark=JJMASeries(0,0,MaxBarD,limit,Smooth_Phase,Demark_Smooth,Demark,bar,reset);
        //----+ �������� �� ���������� ������ � ���������� ��������
        if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
                            
        //---- +SSSSSSSSSSSSSSSS <<< ���������� ��� ���������� >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
        trend=JDemark-Ind_Buffer1[bar+1]-Ind_Buffer2[bar+1]-Ind_Buffer3[bar+1];     
        if     (trend>0){Ind_Buffer1[bar]=JDemark; Ind_Buffer2[bar]=0;       Ind_Buffer3[bar]=0;}
        else{if(trend<0){Ind_Buffer1[bar]=0;       Ind_Buffer2[bar]=JDemark; Ind_Buffer3[bar]=0;}
        else            {Ind_Buffer1[bar]=0;       Ind_Buffer2[bar]=0;       Ind_Buffer3[bar]=JDemark;}}    
        //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+  
        //----+ ���������� ���������� ����� 
        //----+ ( ��������� � ������� JJMASeries �� ������� 1, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0))
        Signal=JJMASeries(1,0,MaxBarJ,limit,Sign_Phase,Sign_Length,JDemark,bar,reset);
        //----+ �������� �� ���������� ������ � ���������� ��������
        if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
        Ind_Buffer4[bar]=Signal;
        //----+        
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
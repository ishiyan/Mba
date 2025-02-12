/*
���  ������  ����������  �������  ��������   �����      
JMASeries.mqh,
JUR001Series.mqh 
� ����� (����������):     MetaTrader\experts\include\
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
     
�  ������  ����������  ������ ������� ������������ �������� ���������� 
������  ��  ��������  ���������� �� ���������� JRSX � ������� ������� 
JUR001Series �  ���������  ���������� �����, ���������� �������������� 
JMA ������������ ����������.   
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                  3c_JDemarkX.mq4 | 
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
//---- ������� ��������� ���������� ������+    
extern int Demark_Length = 10;
extern int Signal_Length = 15;
extern int Signal_Phase  = 100;
//---- �����������������������������������+
//---- ������������ �������
double Ind_Buffer1[];
double Ind_Buffer2[];
double Ind_Buffer3[];
double Ind_Buffer4[];
//---- ���������� � ��������� ������ 
double min_L,min_H,min_S,Jmin_H,Jmin_S,Demark,JDemarkX,trend,Signal;  
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JDemarkX initialization function                                 | 
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
   IndicatorShortName ("JDemarkX"); 
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
if(Signal_Phase<-100){Alert("�������� Signal_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Signal_Phase+  " ����� ������������ -100");}//|
if(Signal_Phase> 100){Alert("�������� Signal_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Signal_Phase+  " ����� ������������  100");}//|
if(Signal_Length< 1) {Alert("�������� Signal_Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Signal_Length+ " ����� ������������  1");}////|
if(Demark_Length< 1) {Alert("�������� Demark_Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Demark_Length+ " ����� ������������  1");}////|
//+========================================================================================================================================================+ 
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������  
   int drawbegin=Demark_Length+1; 
   SetIndexDrawBegin(0,drawbegin);
   SetIndexDrawBegin(1,drawbegin);
   SetIndexDrawBegin(2,drawbegin);  
   SetIndexDrawBegin(3,drawbegin+30);        
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������  
   IndicatorDigits(0);
//---- ���������� �������������   
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JDemarkX iteration function                                      | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
   { 
   //---- �������� ���������� ����� �� ������������� ��� �������
   if (Bars-1<Demark_Length)return(0); 
   //----+ �������� ����� ���������� � ��������� ��� ������������ �����
   //---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
   int reset,limit,MaxBarD,MaxBarJ,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
   //---- �������� �� ��������� ������
   if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
   //---- ��������� ������������ ��� ������ ���� ���������� 
   //---- (��� ����� ��������� ��� counted_bars ������b JJMASeries � JurXSeries ����� �������� �����������!!!)
   if (counted_bars>0) counted_bars--;
   //----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1 (���� ��������� � �������) 
   //----+ �������� � ������������� ���������� ���������� ������� JurXSeries, nJurXnumber=2(���  ��������� � �������)
   if(counted_bars==0){JJMASeriesReset(1);JurXSeriesReset(2);}
   //---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
   limit=Bars-counted_bars-1;
   //---- ����������� ������  ������������� ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
   MaxBarD=Bars-2;MaxBarJ=MaxBarD-Demark_Length;
   if (limit>MaxBarD)limit=MaxBarD;
   
   //----+ �������� ���� ���ר�� ����������
   for(int bar=limit; bar>=0; bar--) 
     {  
        min_H=High[bar]-High[bar+1];
        min_L=Low[bar+1]-Low[bar];
        //----+    
        if(min_H<0) min_H=0; 
        if(min_L<0) min_L=0; 
        min_S = min_L + min_H;
        //----+ ----------------------------------------------------------------+ 
        //----+ ��� ������������ ��������� � ������� JurXSeries �� �������� 0, 1 
        //----+ �������� nJurXLength �� �������� �� ������ ���� (nJurXdin=0) 
        //----+ ----------------------------------------------------------------+     
        Jmin_H=JurXSeries(0,0,MaxBarD,limit,Demark_Length,min_H,bar,reset);
        //----+ �������� �� ���������� ������ � ���������� ��������
        if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
        //----+ ----------------------------------------------------------------+ 
        Jmin_S=JurXSeries(1,0,MaxBarD,limit,Demark_Length,min_S,bar,reset);
        //----+ �������� �� ���������� ������ � ���������� ��������
        if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}                               
        //----+ ----------------------------------------------------------------+ 
        if (bar>MaxBarJ)continue;
        //----+ ������ ���������� �������
        if(Jmin_S!=0)JDemarkX =(200*Jmin_H/Jmin_S)-100;else JDemarkX = 100;
                                    
        //---- +SSSSSSSSSSSSSSSS <<< ���������� ��� ���������� >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
        trend=JDemarkX-Ind_Buffer1[bar+1]-Ind_Buffer2[bar+1]-Ind_Buffer3[bar+1];     
        if     (trend>0){Ind_Buffer1[bar]=JDemarkX; Ind_Buffer2[bar]=0;        Ind_Buffer3[bar]=0;}
        else{if(trend<0){Ind_Buffer1[bar]=0;        Ind_Buffer2[bar]=JDemarkX; Ind_Buffer3[bar]=0;}
        else            {Ind_Buffer1[bar]=0;        Ind_Buffer2[bar]=0;        Ind_Buffer3[bar]=JDemarkX;}}    
        //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+  
        
        //----+ ���������� ���������� �����
        //----+ ---------------------------------------------------------------------------------------------------------------------------+   
        //----+ (���� ��������� � ������� JJMASeries �� ������� 0, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0))
        Signal=JJMASeries(0,0,MaxBarJ,limit,Signal_Phase,Signal_Length,JDemarkX,bar,reset);
        //----+ �������� �� ���������� ������ � ���������� ��������
        if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}  
        Ind_Buffer4[bar]=Signal;             
        //----+ ---------------------------------------------------------------------------------------------------------------------------+          
     } 
     if(limit>=MaxBarJ){int iii=MaxBarJ;Ind_Buffer1[iii]=0;Ind_Buffer2[iii]=0;Ind_Buffer3[iii]=0;}      
   //---- ���������� ���������� �������� ����������
   return(0);
   }  
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� JJMASeries (���� JJMASeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
//----+ �������� ������� JJMASeriesReset  (�������������� ������� ����� JJMASeries.mqh)
//----+ �������� ������� INDICATOR_COUNTED(�������������� ������� ����� JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� JurXSeriess (���� JurXSeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
//----+ �������� ������� JurXSeriesReset (�������������� ������� ����� JurXSeries.mqh ��� ������ JurXSeries)
#include <JurXSeries.mqh>    
//+---------------------------------------------------------------------------------------------------------------------------+
     
  
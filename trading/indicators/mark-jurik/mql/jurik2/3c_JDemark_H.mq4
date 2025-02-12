/*
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
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                 3c_JDemark_H.mq4 | 
//|                           Copyright � 2005,     Nikolay Kositsin | 
//|                                   Khabarovsk, violet@mail.kht.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "violet@mail.kht.ru" 
#property indicator_separate_window
#property indicator_level1   0.7
#property indicator_level2  -0.7
#property indicator_buffers  3
#property indicator_color1  Blue
#property indicator_color2  Magenta
#property indicator_color3  Purple
//---- input parameters
extern int DemarkLength=13;
extern int DemarkPhase =100;
extern int CountBars   =300;
//---- buffers
double ind_buffer1[];
double ind_buffer2[];
double ind_buffer3[];
double MinHigh,MinLow,Up,Down,Demark,trend;  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;

//---- 3 additional buffers are used for counting.
   if(!SetIndexBuffer(0,ind_buffer1) &&
      !SetIndexBuffer(1,ind_buffer2) &&
      !SetIndexBuffer(2,ind_buffer3))
       Print("cannot set indicator buffers!");   
//---- indicator drow line style.
   SetIndexStyle(0,DRAW_HISTOGRAM, STYLE_SOLID, 3); 
   SetIndexStyle(1,DRAW_HISTOGRAM, STYLE_SOLID, 3);
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID, 3);
//---- name for DataWindow and indicator subwindow label.
   short_name="Demark("+DemarkLength+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"DemarkUp");
   SetIndexLabel(1,"DemarkDown");
   SetIndexLabel(2,"DemarkSt");
//---------------------------------------   
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0); 
//---------------------------------------   
   SetIndexDrawBegin(0,Bars-CountBars);
   SetIndexDrawBegin(1,Bars-CountBars);
   SetIndexDrawBegin(2,Bars-CountBars);     
//--------------------------------------- 
   return(0);
  }
//+------------------------------------------------------------------+
//| Demark                                                           |
//+------------------------------------------------------------------+
int start()
     {   
   int limit,counted_bars=IndicatorCounted();
   //---- check for possible errors
   if(counted_bars<0)return(-1);
   if(Bars-1<=30)    return( 0);
   limit=Bars-counted_bars-1;
   if(limit>=Bars-1)limit=Bars-2;
   //----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=2(��� ��������� � �������) 
   if (limit==Bars-2){int reset=-1;int set=JJMASeries(2,0,0,0,0,0,0,0,reset);if((reset!=0)||(set!=0))return(-1);}  
   //-------------------------------------------------------------------------------------------------------------+  
   for(int k=limit; k>=0; k--) 
     {   
        MinHigh=High[k] - High[k+1];
        MinLow =Low [k+1]- Low[k];
        //----
        if(MinHigh<=0) MinHigh=0.0; 
        if(MinLow <=0) MinLow =0.0;      
        //----           
        //----+ ��������� � ������� JJMASeries �� ������� 0, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� �� ���� ��� ���������� � ������� (nJMAdin=0)
        reset=1;Up  =JJMASeries(0,0,Bars-2,limit,DemarkPhase,DemarkLength,MinHigh,k,reset);if(reset!=0)return(-1);
        //----+ ��������� � ������� JJMASeries �� ������� 1, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� �� ���� ��� ���������� � ������� (nJMAdin=0)
        reset=1;Down=JJMASeries(1,0,Bars-2,limit,DemarkPhase,DemarkLength,MinLow, k,reset);if(reset!=0)return(-1);
        //----
        if(Up+Down!=0.0) Demark=2*Up/(Up+Down)-1; else Demark=1.0; 
                            
        //---- +SSSSSSSSSSSSSSSS <<< Three colore code >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
        trend=Demark-ind_buffer1[k+1]-ind_buffer2[k+1]-ind_buffer3[k+1];     
        if     (trend>0.0){ind_buffer1[k]=Demark; ind_buffer2[k]=0.0;    ind_buffer3[k]=0.0;}
        else{if(trend<0.0){ind_buffer1[k]=0.0;    ind_buffer2[k]=Demark; ind_buffer3[k]=0.0;}
        else              {ind_buffer1[k]=0.0;    ind_buffer2[k]=0.0;    ind_buffer3[k]=Demark;}}    
        //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+          
     }      
//----
   return(0);
   }
   
//----+ �������� ������� JJMASeries (���� JJMASeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
#include <JJMASeries.mqh>    
  
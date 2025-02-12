/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
JurXSeries.mqh
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                       JMACDX.mq4 | 
//|                 JMA code: Copyright � 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|                    JMACD: Copyright � 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers 2
//---- ����� ���������� 
#property indicator_color1  Gray
#property indicator_color2  Red
//---- ������� ������������ �����
#property indicator_width1 3
//---- ����� ���������� ����� ����������
#property indicator_style2 4
//---- ��������� �������������� ������� ����������
#property indicator_level1 0.0
#property indicator_levelcolor Blue 
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int FastJurX=6;    // ������� ����������� ������� JurX
extern int SlowJurX=13;   // ������� ����������� ��������� JurX
extern int SignalJMA=12;  // ������� ����������� ���������� JMA
extern int JMACD_Phase  = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ���������x ��������� JMACD 
extern int Signal_Phase = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ���������x ��������� ���������� ����� 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Ind_buffer1[];
double Ind_buffer2[];
//---- ���������� � ��������� ������ 
double F.JurX,S.JurX,JMACDX,Series,trend,Signal;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACDX initialization function                                   |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(1,DRAW_LINE);
//---- 4 ������������ ������� ������������ ��� �����.
if(!SetIndexBuffer(0,Ind_buffer1)&& 
   !SetIndexBuffer(1,Ind_buffer2))
   Print("cannot set indicator buffers!");
   //---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0.0);  
   SetIndexEmptyValue(1,0.0); 
//---- ����� ��� ���� ������ � ����� ��� ��������.
   IndicatorShortName("JMACDX("+FastJurX+","+SlowJurX+","+SignalJMA+")");
   SetIndexLabel(0,"JMACDX");
   SetIndexLabel(1,"Signal");
   //---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������    
   IndicatorDigits(0);
//---- ��������� ������� �� ������������ �������� ������� ���������� =====================================================================================+ 
if(Signal_Phase<-100){Alert("�������� Signal_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Signal_Phase+   " ����� ������������ -100");}
if(Signal_Phase> 100){Alert("�������� Signal_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Signal_Phase+   " ����� ������������  100");}
if(FastJurX< 1){Alert("�������� FastJurX ������ ���� �� ����� 1"   + " �� ����� ������������ " +FastJurX+  " ����� ������������  1"  );}
if(SlowJurX< 1){Alert("�������� SlowJurX ������ ���� �� ����� 1"   + " �� ����� ������������ " +SlowJurX+  " ����� ������������  1"  );}
if(SignalJMA<1){Alert("�������� SignalJMA ������ ���� �� ����� 1"  + " �� ����� ������������ " +SignalJMA+ " ����� ������������  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+=======================================================================================================================================================+    
//---- ���������� �������������
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACDX iteration function                                        |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
  {
   //----+ �������� ����� ���������� � ��������� ��� ������������ �����
   //---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
   int reset,limit,MaxBar,MaxBarS,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
   //---- �������� �� ��������� ������
   if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
   //---- ��������� ������������ ��� ������ ���� ����������
   if (counted_bars>0) counted_bars--;
   //----+ �������� � ������������� ���������� ���������� ������q JJMASeries � JurXSeries 
   if (counted_bars==0){JJMASeriesReset(1);JurXSeriesReset(2);}
   //---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
   limit=Bars-counted_bars-1; MaxBar=Bars-1; MaxBarS=MaxBar-3*SlowJurX;
   
   //----+ �������� ���� ���������� ���������� JMACD
   for(int bar=limit; bar>=0; bar--)
    {
     //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
     Series=PriceSeries(Input_Price_Customs, bar);  
       
     //----+ ��� ��������� � ������� JurXSeries �� �������� 0, 1. ��������� nJurXPhase � nJurXLength �� �������� �� ������ ���� (nJurXdin=0)
     F.JurX=JurXSeries(0,0,MaxBar,limit,FastJurX,Series,bar,reset);
     //----+ �������� �� ���������� ������ � ���������� ��������
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
     //+---------------------------------------------------------------------+
     S.JurX=JurXSeries(1,0,MaxBar,limit,SlowJurX,Series,bar,reset);
     //----+ �������� �� ���������� ������ � ���������� ��������
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
     //+---------------------------------------------------------------------+
     //----+ ������� ��� JMACDX
     JMACDX=F.JurX-S.JurX;
     if(bar>MaxBarS)JMACDX = 0;
     Ind_buffer1[bar]=JMACDX;   
     //----+ ��������� � ������� JJMASeries �� ������� 2, (nJMAdin=0, � ���� ��������� �������� nJMAMaxBar �������� �� 3*SlowJurX  �. �. ��� ��������� �����������) 
     Signal=JJMASeries(2,0,MaxBarS,limit,Signal_Phase,SignalJMA,JMACDX,bar,reset);
     //----+ �������� �� ���������� ������ � ���������� ��������
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
     Ind_buffer2[bar]=Signal; 
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
//----+ �������� ������� JurXSeries (���� JJMASeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
//----+ �������� ������� JurXSeriesReset  (�������������� ������� ����� JurXSeries.mqh)
#include <JurXSeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� PriceSeries, ���� PriceSeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include
//----+ �������� ������� PriceSeriesAlert (�������������� ������� ����� PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+
/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
� PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                        JMACD.mq4 | 
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
extern int FastJMA=12;   // ������� ����������� ������� JMA
extern int SlowJMA=26;   // ������� ����������� ��������� JMA
extern int SignalJMA=9;  // ������� ����������� ���������� JMA
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
double F.JMA,S.JMA,JMACD,Series,Signal;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACD initialization function                                    |
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
   IndicatorShortName("JMACD("+FastJMA+","+SlowJMA+","+SignalJMA+")");
   SetIndexLabel(0,"JMACD");
   SetIndexLabel(1,"Signal");
   //---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������    
   IndicatorDigits(0);
//---- ��������� ������� �� ������������ �������� ������� ���������� =====================================================================================+ 
if(JMACD_Phase<-100) {Alert("�������� JMACD_Phase ������ ���� �� -100 �� +100" +  " �� ����� ������������ " +JMACD_Phase+    " ����� ������������ -100");}
if(JMACD_Phase> 100) {Alert("�������� JMACD_Phase ������ ���� �� -100 �� +100" +  " �� ����� ������������ " +JMACD_Phase+    " ����� ������������  100");}
if(Signal_Phase<-100){Alert("�������� Signal_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Signal_Phase+   " ����� ������������ -100");}
if(Signal_Phase> 100){Alert("�������� Signal_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Signal_Phase+   " ����� ������������  100");}
if(FastJMA<  1){Alert("�������� FastJMA ������ ���� �� ����� 1"     + " �� ����� ������������ " +FastJMA+  " ����� ������������  1"  );}
if(SlowJMA<  1){Alert("�������� SlowJMA ������ ���� �� ����� 1"     + " �� ����� ������������ " +SlowJMA+  " ����� ������������  1"  );}
if(SignalJMA<1){Alert("�������� SignalJMA ������ ���� �� ����� 1"   + " �� ����� ������������ " +SignalJMA+" ����� ������������  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+=======================================================================================================================================================+    
//---- ���������� �������������
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACD iteration function                                         |
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
   //----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=3(��� ��������� � �������)  
   if (counted_bars==0)JJMASeriesReset(3);
   //---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
   limit=Bars-counted_bars-1; MaxBar=Bars-1; MaxBarS=MaxBar-30;
   
   //----+ �������� ���� ���������� ���������� JMACD
   for(int bar=limit; bar>=0; bar--)
    {
     //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
     Series=PriceSeries(Input_Price_Customs, bar);  
       
     //----+ ��� ��������� � ������� JJMASeries �� �������� 0, 1. ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
     F.JMA=JJMASeries(0,0,MaxBar,limit,JMACD_Phase,FastJMA,Series,bar,reset);
     //----+ �������� �� ���������� ������ � ���������� ��������
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
     
     S.JMA=JJMASeries(1,0,MaxBar,limit,JMACD_Phase,SlowJMA,Series,bar,reset);
     //----+ �������� �� ���������� ������ � ���������� ��������
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
     
     //----+ ������� ��� JMACD
     JMACD=F.JMA-S.JMA;
     //----+ ��������� ������� ��������� JMACD �� �������  
     JMACD = JMACD/Point;
     Ind_buffer1[bar]=JMACD;     
     //----+ ��������� � ������� JJMASeries �� ������� 2, (nJMAdin=0, � ���� ��������� �������� nJMAMaxBar �������� �� 30  �. �. ��� ��������� JMA �����������) 
     Signal=JJMASeries(2,0,MaxBarS,limit,Signal_Phase,SignalJMA,JMACD,bar,reset);
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
//----+ �������� ������� PriceSeries, ���� PriceSeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include
//----+ �������� ������� PriceSeriesAlert (�������������� ������� ����� PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+


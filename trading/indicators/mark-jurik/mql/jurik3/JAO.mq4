/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                          JAO.mq4 |
//|                        Copyright � 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property  indicator_buffers 4
//---- ����� ����������
#property indicator_color1  Blue
#property indicator_color2  Gold
#property indicator_color3  Magenta
#property indicator_color4  Gray
//---- ������� ������������ �����
#property indicator_width1 0
#property indicator_width2 2 
#property indicator_width3 2
#property indicator_width4 2
//---- ����� ��������� ����� ����������
#property indicator_style1 4
//---- ��������� �������������� ������� ����������
#property indicator_level1 0.0
#property indicator_levelcolor Blue
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int FastJMA=05;   // ������� ����������� ������� JMA
extern int SlowJMA=34;   // ������� ����������� ��������� JMA
extern int SignJMA=05;   // ������� ����������� ���������� JMA
extern int JMACD_Phase = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ���������x ��������� JMACD 
extern int Sign_Phase  = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ���������x ��������� ���������� ����� 
extern int Input_Price_Customs = 4;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double     Ind_Buffer0[];
double     Ind_Buffer1[];
double     Ind_Buffer2[];
double     Ind_Buffer3[];
//---- ���������� � ��������� ������
double JMACD,JAccelerator,FastJ,SlowJ,Signal,Temp_Series,trend;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JAccelerator initialization function                             |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������    
   IndicatorDigits(0);
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������    
   SetIndexDrawBegin(0,61);
   SetIndexDrawBegin(1,61);
   SetIndexDrawBegin(2,61);
   SetIndexDrawBegin(3,61);
//---- 4 ������������ �������� ������������ ��� �����.
   IndicatorBuffers(4);
   SetIndexBuffer(0,Ind_Buffer0);
   SetIndexBuffer(1,Ind_Buffer1);
   SetIndexBuffer(2,Ind_Buffer2);
   SetIndexBuffer(3,Ind_Buffer3);
//---- ����� ��� ���� ������ � ����� ��� ��������.
   IndicatorShortName("JAccelerator");
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
//---- ��������� ������� �� ������������ �������� ������� ���������� =====================================================================================+ 
if(JMACD_Phase<-100) {Alert("�������� JMACD_Phase ������ ���� �� -100 �� +100" +  " �� ����� ������������ " +JMACD_Phase+    " ����� ������������ -100");}
if(JMACD_Phase> 100) {Alert("�������� JMACD_Phase ������ ���� �� -100 �� +100" +  " �� ����� ������������ " +JMACD_Phase+    " ����� ������������  100");}
if(Sign_Phase<-100)  {Alert("�������� Sign_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Sign_Phase+   " ����� ������������ -100");}
if(Sign_Phase> 100)  {Alert("�������� Sign_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Sign_Phase+   " ����� ������������  100");}
if(FastJMA<  1)      {Alert("�������� FastJMA ������ ���� �� ����� 1"     + " �� ����� ������������ " +FastJMA+  " ����� ������������  1"  );}
if(SlowJMA<  1)      {Alert("�������� SlowJMA ������ ���� �� ����� 1"     + " �� ����� ������������ " +SlowJMA+  " ����� ������������  1"  );}
if(SignJMA<1)        {Alert("�������� SignJMA ������ ���� �� ����� 1"   + " �� ����� ������������ " +SignJMA+" ����� ������������  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+=======================================================================================================================================================+    
//---- ���������� �������������
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JAccelerator/Decelerator Oscillator                              |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
{
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,MaxBar1,MaxBar2,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
//---- (��� ����� ��������� ��� counted_bars ������� JJMASeries ����� �������� �����������!!!)
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=3(��� ��������� � �������)  
if (counted_bars==0)JJMASeriesReset(3);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1; MaxBar1=Bars-1; MaxBar2=MaxBar1-30;

for(int bar=limit; bar>=0; bar--)
 {
   //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
   Temp_Series=PriceSeries(Input_Price_Customs, bar);
   //+----------------------------------------------------------------------------+ 
   //----+ ��� ��������� � ������� JJMASeries �� �������� 0, 1. 
   //----+ ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
   //+----------------------------------------------------------------------------+   
   FastJ=JJMASeries(0,0,MaxBar1,limit,JMACD_Phase,FastJMA,Temp_Series,bar,reset);
   //----+ �������� �� ���������� ������ � ���������� ��������
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
   //+----------------------------------------------------------------------------+ 
   SlowJ=JJMASeries(1,0,MaxBar1,limit,JMACD_Phase,SlowJMA,Temp_Series,bar,reset);
   //----+ �������� �� ���������� ������ � ���������� ��������
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   //+----------------------------------------------------------------------------+    
   JMACD=FastJ-SlowJ;
   //----+ ��������� ������� ��������� JMACD �� �������  
   JMACD=JMACD/Point;  
   //+----------------------------------------------------------------------------+ 
   //----+ ��������� � ������� JJMASeries �� ������� 2. 
   //----+ ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
   //+----------------------------------------------------------------------------+   
   Signal=JJMASeries(2,0,MaxBar2,limit,Sign_Phase,SignJMA,JMACD,bar,reset);
   //----+ �������� �� ���������� ������ � ���������� ��������
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
   //+----------------------------------------------------------------------------+ 
   JAccelerator=JMACD-Signal; 
   Ind_Buffer0[bar]=JAccelerator;
   //---- +SSSSSSSSSSSSSSSS <<< ���������� ��� ���������� >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
   trend=JAccelerator-Ind_Buffer0[bar+1];     
   if     (trend>0){Ind_Buffer1[bar]=JAccelerator; Ind_Buffer2[bar]=0;            Ind_Buffer3[bar]=0;}
   else{if(trend<0){Ind_Buffer1[bar]=0;            Ind_Buffer2[bar]=JAccelerator; Ind_Buffer3[bar]=0;}
   else            {Ind_Buffer1[bar]=0;            Ind_Buffer2[bar]=0;            Ind_Buffer3[bar]=JAccelerator;}}    
   //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+    
 }
 if(limit>=MaxBar2-1){int iii=MaxBar2-1;Ind_Buffer1[iii]=0;Ind_Buffer2[iii]=0;Ind_Buffer3[iii]=0;}
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
/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                     3c_JMACD.mq4 | 
//|                 JMA code: Copyright � 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|                 3c_JMACD: Copyright � 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers 5
//---- ����� ����������
#property indicator_color1  BlueViolet 
#property indicator_color2  Blue
#property indicator_color3  Magenta
#property indicator_color4  Gray
#property indicator_color5  Red
//---- ������� ������������ �����
#property indicator_width1 0
#property indicator_width2 3 
#property indicator_width3 3
#property indicator_width4 4
//---- ����� ��������� ����� ����������
#property indicator_style1 4
//---- ����� ���������� ����� ����������
#property indicator_style5 4
//---- ��������� �������������� ������� ����������
#property indicator_level1 0.0
#property indicator_levelcolor Red 
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
double Ind_buffer3[];
double Ind_buffer4[];
double Ind_buffer5[];
//---- ���������� � ��������� ������ 
double F.JMA,S.JMA,JMACD,Series,trend,Signal;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACD initialization function                                    |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(4,DRAW_LINE);
//---- 4 ������������ ������� ������������ ��� �����.
if(!SetIndexBuffer(0,Ind_buffer1)&& 
   !SetIndexBuffer(1,Ind_buffer2)&& 
   !SetIndexBuffer(2,Ind_buffer3)&& 
   !SetIndexBuffer(3,Ind_buffer4)&& 
   !SetIndexBuffer(4,Ind_buffer5))
   Print("cannot set indicator buffers!");
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0.0);  
   SetIndexEmptyValue(1,0.0); 
   SetIndexEmptyValue(2,0.0); 
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);  
//---- ����� ��� ���� ������ � ����� ��� ��������.
   IndicatorShortName("JMACD("+FastJMA+","+SlowJMA+","+SignalJMA+")");
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,"Up_Trend");
   SetIndexLabel(2,"Down_Trend");
   SetIndexLabel(3,"Straight_Trend");
   SetIndexLabel(4,"Signal");
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
   //----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAJMAnumber=3(��� ���������� � �������) 
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
     //+---------------------------------------------------------------------+
     S.JMA=JJMASeries(1,0,MaxBar,limit,JMACD_Phase,SlowJMA,Series,bar,reset);
     //----+ �������� �� ���������� ������ � ���������� ��������
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
     //+---------------------------------------------------------------------+
     //----+ ������� ��� JMACD
     JMACD=F.JMA-S.JMA;
     //----+ ��������� ������� ��������� JMACD �� �������  
     JMACD = JMACD/Point;
     Ind_buffer1[bar]=JMACD;
     
     //---- +SSSSSSSSSSSSSSSS <<< ���������� ��� ���������� >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
     trend=JMACD-Ind_buffer1[bar+1];     
     if(trend>0.0)     {Ind_buffer2[bar]=JMACD;  Ind_buffer3[bar]=0.0;    Ind_buffer4[bar]=0.0;}
     else{if(trend<0.0){Ind_buffer2[bar]=0.0;    Ind_buffer3[bar]=JMACD;  Ind_buffer4[bar]=0.0;}
     else              {Ind_buffer2[bar]=0.0;    Ind_buffer3[bar]=0.0;    Ind_buffer4[bar]=JMACD;}}    
     //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
     
     //----+ ��������� � ������� JJMASeries �� ������� 2, (nJMAdin=0, � ���� ��������� �������� nJMAMaxBar �������� �� 30  �. �. ��� ��������� JMA �����������) 
     Signal=JJMASeries(2,0,MaxBarS,limit,Signal_Phase,SignalJMA,JMACD,bar,reset);
     //----+ �������� �� ���������� ������ � ���������� ��������
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
     Ind_buffer5[bar]=Signal;
   }
   if(limit>=MaxBar-31){int iii=MaxBar-31;Ind_buffer2[iii]=0;Ind_buffer3[iii]=0;Ind_buffer4[iii]=0;} 
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
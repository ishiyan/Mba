/*
���  ������  ����������  �������  �������� ����� 

JJMASeries.mqh 
� PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
JFatl.mq4
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                    3c_JMACDf.mq4 | 
//|                 JMA code: Copyright � 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|                   JMACDf: Copyright � 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers 4
//---- ����� ���������� 
#property indicator_color1  Yellow 
#property indicator_color2  Red
#property indicator_color3  Gray
#property indicator_color4  Blue
//---- ������� ������������ �����
#property indicator_width1 3
#property indicator_width2 3 
#property indicator_width3 3
//---- ����� ���������� ����� ����������
#property indicator_style4 4
//---- ��������� �������������� ������� ����������
#property indicator_level1 0.0
#property indicator_levelcolor LimeGreen  
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int FastJFatl=8;    // ������� ����������� �������� JFatl
extern int SlowJFatl=20;   // ������� ����������� ���������� JFatl
extern int SignalJMA=12;   // ������� ����������� ���������� JMA
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
//---- ���������� � ��������� ������ 
double Fast.JFATL,Slow.JFATL,JMACDf,Series,trend,Signal;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACDf initialization function                                   |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(3,DRAW_LINE);
//---- 4 ������������ ������� ������������ ��� �����.
if(!SetIndexBuffer(0,Ind_buffer1)&& 
   !SetIndexBuffer(1,Ind_buffer2)&& 
   !SetIndexBuffer(2,Ind_buffer3)&& 
   !SetIndexBuffer(3,Ind_buffer4))
   Print("cannot set indicator buffers!");
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0.0);  
   SetIndexEmptyValue(1,0.0); 
   SetIndexEmptyValue(2,0.0); 
   SetIndexEmptyValue(3,0.0);  
//---- ����� ��� ���� ������ � ����� ��� ��������.
   IndicatorShortName("JMACDf("+FastJFatl+","+SlowJFatl+","+SignalJMA+")");
   SetIndexLabel(0,"Up_Trend");
   SetIndexLabel(1,"Down_Trend");
   SetIndexLabel(2,"Straight_Trend");
   SetIndexLabel(3,"Signal");
   //---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������    
   IndicatorDigits(0);
//---- ��������� ������� �� ������������ �������� ������� ���������� ===================================================================================+ 
if(JMACD_Phase<-100) {Alert("�������� JMACD_Phase  ������ ���� �� -100 �� +100" + " �� ����� ������������ " +JMACD_Phase+ " ����� ������������ -100");}
if(JMACD_Phase> 100) {Alert("�������� JMACD_Phase  ������ ���� �� -100 �� +100" + " �� ����� ������������ " +JMACD_Phase+ " ����� ������������  100");}
if(Signal_Phase<-100){Alert("�������� Signal_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Signal_Phase+" ����� ������������ -100");}
if(Signal_Phase> 100){Alert("�������� Signal_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Signal_Phase+" ����� ������������  100");}
if(FastJFatl<  1)    {Alert("�������� FastJFatl ������ ���� �� ����� 1" + " �� ����� ������������ " +FastJFatl+  " ����� ������������  1"  );}
if(SlowJFatl<  1)    {Alert("�������� SlowJFatl ������ ���� �� ����� 1" + " �� ����� ������������ " +SlowJFatl+  " ����� ������������  1"  );}
if(SignalJMA<1)      {Alert("�������� SignalJMA ������ ���� �� ����� 1" + " �� ����� ������������ " +SignalJMA+"   ����� ������������  1"  );}
PriceSeriesAlert(Input_Price_Customs);
//+=====================================================================================================================================================+    
//---- ���������� �������������
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACDf iteration function                                        |
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
   //----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
   if (counted_bars==0)JJMASeriesReset(1);
   //---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
   limit=Bars-counted_bars-1; MaxBar=Bars-1; MaxBarS=MaxBar-30;
   
   //----+ �������� ���� ���������� ���������� JMACD
   for(int bar=limit; bar>=0; bar--)
    {
     //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
     Series=PriceSeries(Input_Price_Customs, bar);        
     //----+ ��� ��������� � ����������������� ���������� JFatl     
     Fast.JFATL= iCustom(NULL,0,"JFatl",FastJFatl,JMACD_Phase,0,Input_Price_Customs,0,bar);
     Slow.JFATL= iCustom(NULL,0,"JFatl",SlowJFatl,JMACD_Phase,0,Input_Price_Customs,0,bar);     
     //----+ ������� ��� JMACDf
     JMACDf=Fast.JFATL-Slow.JFATL;
     //----+ ��������� ������� ��������� JMACDf �� �������  
     JMACDf = JMACDf/Point;    
     //---- +SSSSSSSSSSSSSSSS <<< ���������� ��� ���������� >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
     trend=JMACDf-Ind_buffer1[bar+1]-Ind_buffer2[bar+1]-Ind_buffer3[bar+1];     
     if(trend>0.0)     {Ind_buffer1[bar]=JMACDf;  Ind_buffer2[bar]=0.0;     Ind_buffer3[bar]=0.0;}
     else{if(trend<0.0){Ind_buffer1[bar]=0.0;     Ind_buffer2[bar]=JMACDf;  Ind_buffer3[bar]=0.0;}
     else              {Ind_buffer1[bar]=0.0;     Ind_buffer2[bar]=0.0;     Ind_buffer3[bar]=JMACDf;}}    
     //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS�SSSSSSSSSSSSSSSSS+
     
     //----+ ��������� � ������� JJMASeries �� ������� 0, (nJMAdin=0, � ���� ��������� �������� nJMAMaxBar 
     //----+  �������� �� 30  �. �. ��� ��������� JMA �����������: ���������� ���� � ���������� JFatl) 
     Signal=JJMASeries(0,0,MaxBarS,limit,Signal_Phase,SignalJMA,JMACDf,bar,reset);
     //----+ �������� �� ���������� ������ � ���������� ��������
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
     Ind_buffer4[bar]=Signal;
     //----+
   }
   if(limit>=MaxBarS){int iii=MaxBarS;Ind_buffer1[iii]=0;Ind_buffer2[iii]=0;Ind_buffer3[iii]=0;} 
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
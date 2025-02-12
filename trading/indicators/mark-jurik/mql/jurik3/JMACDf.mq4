/*
���  ������  ����������  �������  �������� ����� 

JJMASeries.mqh 
� PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
JFatl.mq4
� ����� (����������): MetaTrader\experts\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                       JMACDf.mq4 | 
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
extern int FastJFatl=12;   // ������� ����������� �������� JFatl
extern int SlowJFatl=26;   // ������� ����������� ���������� JFatl
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
double Fast.JFATL,Slow.JFATL,JMACDf,Series,Signal;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JMACDf initialization function                                   |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexStyle(1,DRAW_LINE);
//---- 2 ������������ ������� ������������ ��� �����.
if(!SetIndexBuffer(0,Ind_buffer1)&& 
   !SetIndexBuffer(1,Ind_buffer2))
   Print("cannot set indicator buffers!");
   //---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0.0);  
   SetIndexEmptyValue(1,0.0); 
//---- ����� ��� ���� ������ � ����� ��� ��������.
   IndicatorShortName("JMACDf("+FastJFatl+","+SlowJFatl+","+SignalJMA+")");
   SetIndexLabel(0,"JMACDf");
   SetIndexLabel(1,"Signal");
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
   MaxBar=Bars-1; MaxBarS=MaxBar-30;limit=MaxBar-counted_bars; 
   
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
     Ind_buffer1[bar]=JMACDf;     
     //----+ ��������� � ������� JJMASeries �� ������� 0, (nJMAdin=0) 
     Signal=JJMASeries(0,0,MaxBarS,limit,Signal_Phase,SignalJMA,JMACDf,bar,reset);
     //----+ �������� �� ���������� ������ � ���������� ��������
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
     Ind_buffer2[bar]=Signal;
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
//----+ �������� ������� PriceSeries, ���� PriceSeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include
//----+ �������� ������� PriceSeriesAlert (�������������� ������� ����� PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+


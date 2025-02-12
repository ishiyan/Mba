/*
���  ������  ����������  �������  �������� ����s
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\ ,   
JFatl.mq4 
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                   JFatlSpeed.mq4 | 
//|                             Copyright � 2006,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers  8
#property indicator_color1  Blue
#property indicator_color2  Magenta
#property indicator_color3  Gray
#property indicator_color4  Purple
#property indicator_color5  Lime 
#property indicator_color6  Tomato 
#property indicator_color7  Yellow  
#property indicator_color8  Red
//---- ������� ������������ �����
#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
//---- ��������� �������������� ������� ����������
#property indicator_level1  0.0
#property indicator_levelstyle 0
#property indicator_levelcolor SlateBlue
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Noise     = 8;   // �������� ��������� ����, ����������� �� ���;
extern int Length    = 3;   // ������� JFatl �����������; 
extern int Phase     = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� JFatl ��������; 
extern int LengthS   = 1;   // ������� ����������� �������� ���������� JFatlSpeed;
extern int PhaseS    = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� JFatlSpeed ��������; 
extern int Shift     = 0;   // c���� ���������� ����� ��� �������; 
extern int sh        = 10;  // ������������ �������� �������� Buy1, Buy2, Sell1, Sell2;
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ����������: 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double JFatlSpeed1[]; 
double JFatlSpeed2[];
double JFatlSpeed3[];
double JFatlSpeed4[];
double Buy1       [];
double Sell1      [];
double Buy2       [];
double Sell2      [];
//---- ����� ����������
int    SH; 
//---- ���������� � ��������� ������ 
double JFatlSpeed,JFS0,JFS1,trend,JFatl0,JFatl1,Series;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| Custom indicator initialization function                         |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init() 
{ 
//---- ����� ���������� ����� � ���� �����������
SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID);
SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID);
//---- ����� ���������� ������� ���� ��������
SetIndexStyle(4,DRAW_ARROW);
SetIndexStyle(5,DRAW_ARROW);
SetIndexStyle(6,DRAW_ARROW);
SetIndexStyle(7,DRAW_ARROW);
//---- ����������� ����� �������� ��������
SetIndexArrow(4,108);
SetIndexArrow(5,108);
SetIndexArrow(6,233);
SetIndexArrow(7,234);
//---- 8 ������������ �������� ������������ ��� �����
IndicatorBuffers(8);
SetIndexBuffer(0,JFatlSpeed1);
SetIndexBuffer(1,JFatlSpeed2);
SetIndexBuffer(2,JFatlSpeed3);
SetIndexBuffer(3,JFatlSpeed4);
SetIndexBuffer(4,Buy1);
SetIndexBuffer(5,Sell1);
SetIndexBuffer(6,Buy2);
SetIndexBuffer(7,Sell2); 
//---- ��������� ������ ����, ������� � �������� ����� �������������� ��������� 
SetIndexDrawBegin(0,69); 
SetIndexDrawBegin(1,69);
SetIndexDrawBegin(2,69);
SetIndexDrawBegin(3,69);
SetIndexDrawBegin(4,69);
SetIndexDrawBegin(5,69);
SetIndexDrawBegin(6,69);
SetIndexDrawBegin(7,69);
SH=sh+Noise;
//+====================================================================================================================================+ 
if(PhaseS<-100){Alert("�������� PhaseS ������ ���� �� -100 �� +100" + " �� ����� ������������ " +PhaseS+  " ����� ������������ -100");}
if(PhaseS> 100){Alert("�������� PhaseS ������ ���� �� -100 �� +100" + " �� ����� ������������ " +PhaseS+  " ����� ������������  100");}
if(LengthS<  1){Alert("�������� LengthS ������ ���� �� ����� 1"     + " �� ����� ������������ " +LengthS+ " ����� ������������  1"  );}
//+====================================================================================================================================+
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ���������� 
IndicatorDigits(0);
//---- ���������� �������������
return(0); 
}
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JFATL SPEED                                                      |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,MaxBar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
if (counted_bars==0)JJMASeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1; MaxBar=Bars-1;
//----+   
for(int k=limit;k>=0;k--)
{
JFatl0= iCustom( NULL, 0, "JFatl",Length,Phase,Shift,0,Input_Price_Customs,0,k+0); 
JFatl1= iCustom( NULL, 0, "JFatl",Length,Phase,Shift,0,Input_Price_Customs,0,k+1);      
Series=(JFatl0-JFatl1)/Point;
//----+ ��������� � ������� JJMASeries �� ������� 0, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
JFatlSpeed=JJMASeries(0,0,MaxBar,limit,PhaseS,LengthS,Series,k,reset);
//----+ �������� �� ���������� ������ � ���������� ��������
if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}   
 
JFS1=JFatlSpeed1[k+1]+JFatlSpeed2[k+1]+JFatlSpeed3[k+1]+JFatlSpeed4[k+1];
JFS0=JFatlSpeed;
//----+

if (MathAbs(JFS1)<=Noise)
  { 
  if(JFS0> Noise)Buy2 [k]=-SH; else Buy2 [k]=EMPTY_VALUE;
  if(JFS0<-Noise)Sell2[k]= SH; else Sell2[k]=EMPTY_VALUE;
  }
else
  {
  if((JFS1<-Noise)&&(MathAbs(JFS0)<=Noise))Buy1 [k]=-SH; else Buy1 [k]=EMPTY_VALUE;
  if((JFS1> Noise)&&(MathAbs(JFS0)<=Noise))Sell1[k]= SH; else Sell1[k]=EMPTY_VALUE;
  if((JFS1<-Noise)&&(JFS0> Noise))Buy2 [k]=-SH; else Buy2 [k]=EMPTY_VALUE;
  if((JFS1> Noise)&&(JFS0<-Noise))Sell2[k]= SH; else Sell2[k]=EMPTY_VALUE; 
  }
//----+
if(MathAbs(JFatlSpeed)<=Noise){JFatlSpeed4[k]=JFatlSpeed; JFatlSpeed=0;}
if(MathAbs(JFatlSpeed)> Noise) JFatlSpeed4[k]=0; 
//----+
//----+ +SSSSSSSSSSSSSSSS <<< Three colore code >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
trend=JFatlSpeed-JFatlSpeed1[k+1]-JFatlSpeed2[k+1]-JFatlSpeed3[k+1];     
if(trend>0.0)     {JFatlSpeed1[k]=JFatlSpeed;JFatlSpeed2[k]=0.0;       JFatlSpeed3[k]=0.0;}
else{if(trend<0.0){JFatlSpeed1[k]=0.0;       JFatlSpeed2[k]=JFatlSpeed;JFatlSpeed3[k]=0.0;}
else              {JFatlSpeed1[k]=0.0;       JFatlSpeed2[k]=0.0;       JFatlSpeed3[k]=JFatlSpeed;}}    
//----+ +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
}
//----+
return(0); 
} 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� JJMASeries (���� JJMASeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
//----+ �������� ������� JJMASeriesReset  (�������������� ������� ����� JJMASeries.mqh)
//----+ �������� ������� INDICATOR_COUNTED(�������������� ������� ����� JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+


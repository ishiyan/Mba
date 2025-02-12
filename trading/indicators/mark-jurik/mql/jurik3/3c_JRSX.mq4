/*
���  ������  ����������  �������  ��������  �����  
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\

��� ������ ����������  ������� ��������  �����  
INDICATOR_COUNTED.mqh,    
PriceSeries.mqh, 
JJMASeries.mqh
� ����� (����������): MetaTrader\experts\include\

�� �����  ���������  ����  ��������� ��������� ���������� ������������
�����������  � � ���� ��������� ��������� �� �� ����� ����������, ���
�  �  RSI. ������ ��������� ������������� ����� ����������� ����������
����������� �� ����� ������� ������������ � ����� ������ ����� ������.
�������,  �������  �����  ���������  ����������  ������, ���������� �
�������� ���������� ����� MACD
//---- 
Relative   Strenght  Index  (RSI)
������ ������������� ���� - ��� ��������� �� ����� ����������, �������
����������  �  ��������� �� 0 �� 100. ���� �� ���������������� �������
�������  RSI  �������  � ������ �����������, ��� ������� ���� ��������
����� ��������, � RSI �� ������� ���������� ������� ������ �����������
���������.   ��������   �����������   ���������������   �  �����������
���������  ���.  ����  �����  RSI  ������������ ���� � ���������� ����
�����   �������,   ��   ��   ���������   ���  ����������  '�����������
������'(failure    swing).    ����    �����������   ������   ���������
��������������  �������  ���������  ���.  �������  ����������  RSI ���
������� ��������:
1.  �������  �  ���������  �������  RSI������  �����������  ���� 70, �
���������  - ���� 30, ������ ��� ������ ��������� ����������� ������ �
��������� �� ������� �������.
2.  �����������  ������  RSI ����� �������� ����������� ������ - �����
���  '������  �  �����'  ���  ������������, ������� �� ������� �������
�����   �  ��  ������������.
3.  �����������  ������  (������  ������  ��������� ��� �������������)
�����  �����,  ����� RSI ����������� ���� ����������� ��������� (����)
��� ���������� ���� ����������� �������� (�������).
4.  ������ ��������� � ������������� �� ������� RSI ������ ��������� �
������������� ���������� ���� ����������, ��� �� ������� �������.
5.  �����������  ���  ���  ������� ����, ����������� ����������, �����
����  ���������  ������  ��������� (��������), �� �� �� ��������������
�����   ����������   (���������)  ��  �������  RSI.  ���  ����  ������
���������� ��������� ��� � ����������� �������� RSI.
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                      3c_JRSX.mq4 |
//|          JRSX: Copyright � 2005,            Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|   MQL4+3color: Copyright � 2006,                Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers  4
//---- ����� ����������
#property indicator_color1  BlueViolet
#property indicator_color2  Magenta
#property indicator_color3  Gray
#property indicator_color4  Lime
//---- ������� ������������ �����
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 3
//---- ����� ���������� ����� ����������
#property indicator_style4 4
//---- ��������� �������������� ������� ����������
#property indicator_level1  0.5
#property indicator_level2 -0.5
#property indicator_level3  0.0
#property indicator_levelcolor MediumBlue
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int  JRSX.Length = 8;  // ������� ����������� ����������
extern int  Sign.Length = 15; // ������� ����������� ���������� �����
extern int  Sign.Phase  = 100; // �������� ���������� �����, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������;
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Ind_Buffer1[];
double Ind_Buffer2[];
double Ind_Buffer3[];
double Ind_Buffer4[];
//---- ���������� ���������� 
bool Exp=true;
//---- ����� ���������� 
int    bar,r,w,k,counted_bars,T2[2],Tnew;
//---- ���������� � ��������� ������ 
double v8,v10,v14,v18,v20,v0C,v1C,v8A; 
double F28[2],F30[2],F38[2],F40[2],F48[2],F50[2],F58[2];  
double F60[2],F68[2],F70[2],F78[2],F80[2],JRSX,trend,Signal; 
double f0,f28,f30,f38,f40,f48,f50,f58,f60,f68,f70,f78,f80,Kg,Hg;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JRSX initialization function                                     |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(1,DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexStyle(3,DRAW_LINE);
//---- 4 ������������ ������� ������������ ��� �����. 
   SetIndexBuffer(0,Ind_Buffer1);
   SetIndexBuffer(1,Ind_Buffer2);
   SetIndexBuffer(2,Ind_Buffer3);
   SetIndexBuffer(3,Ind_Buffer4);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0); 
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
   SetIndexEmptyValue(3,0);
//---- ����� ��� ���� ������ � ����� ��� ��������.
   SetIndexLabel(0,"Up_Trend");
   SetIndexLabel(1,"Down_Trend");
   SetIndexLabel(2,"Straight_Trend");
   SetIndexLabel(3,"Signal");  
   IndicatorShortName("JRSX(JRSX.Length="+JRSX.Length+", Input_Price_Customs="+Input_Price_Customs+")");
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������  
   IndicatorDigits(0);
//---- ��������� ������� �� ������������ �������� ������� ���������� ===============================================================================+ 
if(Sign.Phase<-100){Alert("�������� Sign.Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Sign.Phase+ " ����� ������������ -100");}//|
if(Sign.Phase> 100){Alert("�������� Sign.Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Sign.Phase+ " ����� ������������  100");}//|
if(Sign.Length< 1) {Alert("�������� Sign.Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Sign.Length+ " ����� ������������   1");}//|
if(JRSX.Length< 1) {Alert("�������� JRSX.Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +JRSX.Length+ " ����� ������������   1");}//|
PriceSeriesAlert(Input_Price_Customs);//---- ��������� � ������� PriceSeriesAlert //////////////////////////////////////////////////////////////////|
//---- =============================================================================================================================================+ 
//---- �������� ������������� �������� ��������� JRSX.Length
if(JRSX.Length<1)JRSX.Length=1; 
//---- ������������� ������������� ��� ������� ���������� 
if (JRSX.Length-1>=5) w=JRSX.Length-1; else w=5; Kg=3/(JRSX.Length+2.0); Hg=1.0-Kg;
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������  
   SetIndexDrawBegin(0,w+2);
   SetIndexDrawBegin(1,w+2);
   SetIndexDrawBegin(2,w+2);  
   SetIndexDrawBegin(3,w+2+30); 
//---- ���������� �������������
return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JRSX iteration function                                          |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
{
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,limit,MaxBar,MaxBarJ,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
//---- (��� ����� ��������� ��� counted_bars ������� JJMASeries ����� �������� �����������!!!)
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
if (counted_bars==0)JJMASeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
MaxBar=Bars-2; MaxBarJ=MaxBar-JRSX.Length; 
limit=Bars-counted_bars-1; 
if (limit>MaxBar)
 {
  limit=MaxBar;
  Ind_Buffer1[Bars-1]=0.0;
  Ind_Buffer2[Bars-1]=0.0;
  Ind_Buffer3[Bars-1]=0.0;
 }
//+--- �������������� �������� ���������� +=================================+
Tnew=Time[limit+1];
if (limit<MaxBar)
if (Tnew==T2[1])
 {
  f28=F28[1]; f30=F30[1]; f38=F38[1]; f40=F40[1]; f48=F48[1]; f50=F50[1];     
  f58=F58[1]; f60=F60[1]; f68=F68[1]; f70=F70[1]; f78=F78[1]; f80=F80[1];
  Exp=false;
 }
else 
if (Tnew==T2[0])
 {
  f28=F28[0]; f30=F30[0]; f38=F38[0]; f40=F40[0]; f48=F48[0]; f50=F50[0];     
  f58=F58[0]; f60=F60[0]; f68=F68[0]; f70=F70[0]; f78=F78[0]; f80=F80[0];
  //+--- �������������� �������� ����������
  F28[1]=F28[0]; F30[1]=F30[0]; F38[1]=F38[0]; F40[1]=F40[0]; 
  F48[1]=F48[0]; F50[1]=F50[0]; F58[1]=F58[0]; F60[1]=F60[0]; 
  F68[1]=F68[0]; F70[1]=F70[0]; F78[1]=F78[0]; F80[1]=F80[0];
  } 
else 
 {
 if (Tnew>T2[1])Print("ERROR01");
 else Print("ERROR02");INDICATOR_COUNTED(-1);return(-1);
 }
//+--- +====================================================================+

bar=limit;
while (bar>=0)
{
//+-------------------+
if (r==0){r=1; k=0;}
else
{
//++++++++++++++++++++
if (r>=w) r=w+1; else r=r+1;
//----+ ��� ��������� � ������� PriceSeries ��� ��������� ������� ������� ��� v8
v8 = PriceSeries(Input_Price_Customs, bar)-PriceSeries(Input_Price_Customs, bar+1);
//----+  
v8A=MathAbs(v8);
//---- ���������� V14 ------
f28 = Hg  * f28 + Kg  *  v8;
f30 = Kg  * f28 + Hg  * f30;
v0C = 1.5 * f28 - 0.5 * f30;
f38 = Hg  * f38 + Kg  * v0C;
f40 = Kg  * f38 + Hg  * f40;
v10 = 1.5 * f38 - 0.5 * f40;
f48 = Hg  * f48 + Kg  * v10;
f50 = Kg  * f48 + Hg  * f50;
v14 = 1.5 * f48 - 0.5 * f50;
//---- ���������� V20 ------
f58 = Hg  * f58 + Kg  * v8A;
f60 = Kg  * f58 + Hg  * f60;
v18 = 1.5 * f58 - 0.5 * f60;
f68 = Hg  * f68 + Kg  * v18;
f70 = Kg  * f68 + Hg  * f70;
v1C = 1.5 * f68 - 0.5 * f70;
f78 = Hg  * f78 + Kg  * v1C;
f80 = Kg  * f78 + Hg  * f80;
v20 = 1.5 * f78 - 0.5 * f80;
//-------wwwwwwwwww---------
if ((r <= w) && (v8!= 0)) k = 1;
if ((r == w) && (k == 0)) r = 0;
}//++++++++++++++++++++

if ((r>w)&&(v20>0.0000000001))
{
JRSX=v14/v20;
if(JRSX> 1)JRSX=1;
if(JRSX<-1)JRSX=-1;
}
else JRSX=0;

//+--- ���������� �������� ���������� +=======================+
if ((bar==2)||((bar==1)&&(Exp==true)))
{
F28[bar-1]=f28; F30[bar-1]=f30; F38[bar-1]=f38; F40[bar-1]=f40; 
F48[bar-1]=f48; F50[bar-1]=f50; F58[bar-1]=f58; F60[bar-1]=f60; 
F68[bar-1]=f68; F70[bar-1]=f70; F78[bar-1]=f78; F80[bar-1]=f80;
T2[bar-1]=Time[bar];
}
//+---+=======================================================+
//---- +SSSSSSSSSSSSSSSS <<< ���������� ��� ���������� >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
trend=JRSX-Ind_Buffer1[bar+1]-Ind_Buffer2[bar+1]-Ind_Buffer3[bar+1];     
if(trend>0)     {Ind_Buffer1[bar]=JRSX; Ind_Buffer2[bar]=0;    Ind_Buffer3[bar]=0;}
else{if(trend<0){Ind_Buffer1[bar]=0;    Ind_Buffer2[bar]=JRSX; Ind_Buffer3[bar]=0;}
else            {Ind_Buffer1[bar]=0;    Ind_Buffer2[bar]=0;    Ind_Buffer3[bar]=JRSX;}}    
  //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+

//----+ ���������� ���������� ����� ( ��������� � ������� JJMASeries �� ������� 0, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0))
Signal=JJMASeries(0,0,MaxBarJ,limit,Sign.Phase,Sign.Length,JRSX,bar,reset);
//----+ �������� �� ���������� ������ � ���������� ��������
if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
Ind_Buffer4[bar]=Signal;
//----+
bar--;
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





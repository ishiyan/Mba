/*
��� ������ ����������  �������  ��������  ����s  INDICATOR_COUNTED.mqh
� ����� (����������): MetaTrader\experts\include\

//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                  TrendSignal.mqh |
//|                        Copyright � 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ����� ����������
#property indicator_buffers 8 
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Lime
#property indicator_color6 Lime
#property indicator_color7 Lime
#property indicator_color8 Lime
//---- ������� ������������ �����
#property indicator_width1 3
#property indicator_width2 2
#property indicator_width3 1 
#property indicator_width4 0
#property indicator_width5 0
#property indicator_width6 1
#property indicator_width7 2 
#property indicator_width8 3
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int LEVEL14=
extern int LEVEL13=
extern int LEVEL12=
extern int LEVEL11=
extern int LEVEL01=
extern int LEVEL02=
extern int LEVEL03=
extern int LEVEL04=
*/
extern int Index14=159;
extern int Index13=159;
extern int Index12=159;
extern int Index11=159;
extern int Index01=159;
extern int Index02=159;
extern int Index03=159;
extern int Index04=159;
//----
extern int Vertical_Shift = 10;
extern int Ind_Shift = 0;  // c���� ���������� ����� ��� ������� 
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Ind_Buffer1 [];
double Ind_Buffer2 [];
double Ind_Buffer3 [];
double Ind_Buffer4 [];
double Ind_Buffer5 [];
double Ind_Buffer6 [];
double Ind_Buffer7 [];
double Ind_Buffer8 [];
//---- ����� ���������� 
int bar; 
//---- ���������� � ��������� ������ 
double Series,Out_Series,SHIFT,high,low;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Custom indicator initialization function                         | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{
//---- 8 ������������ �������� ������������ ��� �����.  
SetIndexBuffer(0,Ind_Buffer1 );
SetIndexBuffer(1,Ind_Buffer2 );
SetIndexBuffer(2,Ind_Buffer3 );
SetIndexBuffer(3,Ind_Buffer4 );
SetIndexBuffer(4,Ind_Buffer5 );
SetIndexBuffer(5,Ind_Buffer6 );
SetIndexBuffer(6,Ind_Buffer7 ); 
SetIndexBuffer(7,Ind_Buffer8 ); 
//---- �������������� ����� ������������ �����
SetIndexShift (0, Ind_Shift); 
SetIndexShift (1, Ind_Shift); 
SetIndexShift (2, Ind_Shift); 
SetIndexShift (3, Ind_Shift); 
SetIndexShift (4, Ind_Shift); 
SetIndexShift (5, Ind_Shift); 
SetIndexShift (6, Ind_Shift); 
SetIndexShift (7, Ind_Shift); 
//---- ����� ���������� ������� ���� �������� �����
SetIndexStyle(0,DRAW_ARROW);
SetIndexStyle(1,DRAW_ARROW);
SetIndexStyle(2,DRAW_ARROW);
SetIndexStyle(3,DRAW_ARROW);
SetIndexStyle(4,DRAW_ARROW);
SetIndexStyle(5,DRAW_ARROW);
SetIndexStyle(6,DRAW_ARROW);
SetIndexStyle(7,DRAW_ARROW);
//---- ����������� ����� �������� ��������
SetIndexArrow(0,Index14);
SetIndexArrow(1,Index13);
SetIndexArrow(2,Index12);
SetIndexArrow(3,Index11);
SetIndexArrow(4,Index01);
SetIndexArrow(5,Index02);
SetIndexArrow(6,Index03);
SetIndexArrow(7,Index04);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
SetIndexEmptyValue(0,EmptyValue);
SetIndexEmptyValue(1,EmptyValue);
SetIndexEmptyValue(2,EmptyValue);
SetIndexEmptyValue(3,EmptyValue);
SetIndexEmptyValue(4,EmptyValue);
SetIndexEmptyValue(5,EmptyValue);
SetIndexEmptyValue(6,EmptyValue);
SetIndexEmptyValue(7,EmptyValue);
//---- ����� ��� ���� ������ � ����� ��� ��������.  
IndicatorShortName(""+Label+"");
SetIndexLabel   (0,"Up_Trend");
SetIndexLabel   (1,"Up_Trend");
SetIndexLabel   (2,"Up_Trend");
SetIndexLabel   (3,"Up_Trend");
SetIndexLabel   (4,"Down_Trend");
SetIndexLabel   (5,"Down_Trend");
SetIndexLabel   (6,"Down_Trend");
SetIndexLabel   (7,"Down_Trend");
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ���������� 
IndicatorDigits(digits());
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������
int draw_begin=COUNT_begin()+Ind_Shift;
SetIndexDrawBegin(0,draw_begin);
SetIndexDrawBegin(1,draw_begin);
SetIndexDrawBegin(2,draw_begin);
SetIndexDrawBegin(3,draw_begin);
SetIndexDrawBegin(4,draw_begin);
SetIndexDrawBegin(5,draw_begin);
SetIndexDrawBegin(6,draw_begin);
SetIndexDrawBegin(7,draw_begin);
//----
SHIFT=Vertical_Shift*Point;
//---- ���������� �������������
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JTRIX iteration function                                         | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int MaxBar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1; MaxBar=Bars-1-COUNT_begin();if (limit>MaxBar)limit=MaxBar;
//---- ������ ����������
for(bar=limit;bar>=0;bar--)
{
//---- 
Ind_Buffer1[bar]=EmptyValue;Ind_Buffer2[bar]=EmptyValue;
Ind_Buffer3[bar]=EmptyValue;Ind_Buffer4[bar]=EmptyValue;
Ind_Buffer5[bar]=EmptyValue;Ind_Buffer6[bar]=EmptyValue;
Ind_Buffer7[bar]=EmptyValue;Ind_Buffer8[bar]=EmptyValue;

//---- ��������� � ������� INDICATOR();
Out_Series=INDICATOR(bar);
//----
high=High[bar]+SHIFT;
low =Low [bar]-SHIFT;
if (Out_Series>=LEVEL14){Ind_Buffer1[bar]=high;continue;}
if (Out_Series>=LEVEL13){Ind_Buffer2[bar]=high;continue;}
if (Out_Series>=LEVEL12){Ind_Buffer3[bar]=high;continue;}
if (Out_Series>=LEVEL11){Ind_Buffer4[bar]=high;continue;}
if (Out_Series<=LEVEL04){Ind_Buffer8[bar]=low; continue;}
if (Out_Series<=LEVEL03){Ind_Buffer7[bar]=low; continue;}
if (Out_Series<=LEVEL02){Ind_Buffer6[bar]=low; continue;}
if (Out_Series<=LEVEL01){Ind_Buffer5[bar]=low; continue;}
}
//---- ���������� ���������� �������� ����������

return(0); 
} 

//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� INDICATOR_COUNTED (���� INDICATOR_COUNTED.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+


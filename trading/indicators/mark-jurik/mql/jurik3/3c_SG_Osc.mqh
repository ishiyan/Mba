/*
���  ������  ����������  �������  �������� ����
JJMASeries.mqh 
� ����� (����������): MetaTrader\experts\include\
/*
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                    3c_SG_Osc.mqh |
//|                        Copyright � 2006,        Nikolay Kositsin | 
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
*/
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Signal_Length = 15; // ������� ����������� ���������� �����
extern int Signal_Phase  = 100; // �������� ���������� �����, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������;
extern int Ind_Shift     = 0;  // c���� ���������� ����� ��� ������� 
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Ind_Buffer1[];
double Ind_Buffer2[];
double Ind_Buffer3[];
double Ind_Buffer4[];
double Ind_Buffer5[];
//---- ����� ����������
int bar;
//---- ���������� � ��������� ������ 
double trend,Signal,Out_Series;
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
if(!SetIndexBuffer(0,Ind_Buffer1)&& 
   !SetIndexBuffer(1,Ind_Buffer2)&& 
   !SetIndexBuffer(2,Ind_Buffer3)&& 
   !SetIndexBuffer(3,Ind_Buffer4)&& 
   !SetIndexBuffer(4,Ind_Buffer5))
   Print("cannot set indicator buffers!");
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,EmptyValue);
   SetIndexEmptyValue(1,EmptyValue);
   SetIndexEmptyValue(2,EmptyValue);
   SetIndexEmptyValue(3,EmptyValue);
   SetIndexEmptyValue(4,EmptyValue);
//---- ����� ��� ���� ������ � ����� ��� ��������.  
   IndicatorShortName(""+Label+"");
   SetIndexLabel   (0,NULL);
   SetIndexLabel   (1,"Up_Trend");
   SetIndexLabel   (2,"Down_Trend");
   SetIndexLabel   (3,"Straight_Trend");
   SetIndexLabel   (4,"Signal");
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ���������� 
   IndicatorDigits(digits());
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������
   int draw_begin=COUNT_begin()+Ind_Shift+1;
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   draw_begin+=29;
   SetIndexDrawBegin(3,draw_begin);
//---- ���������� �������������
//---- ��������� ������� �� ������������ �������� ������� ���������� =====================================================================================+ 
if(Signal_Phase<-100){Alert("�������� Signal_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Signal_Phase+"  ����� ������������ -100");}
if(Signal_Phase> 100){Alert("�������� Signal_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Signal_Phase+"  ����� ������������  100");}
if(Signal_Length<1)  {Alert("�������� Signal_Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Signal_Length+" ����� ������������  1"  );}
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
int reset,limit,MaxBarS,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
if (counted_bars==0)JJMASeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1; MaxBar=Bars-1-COUNT_begin()-1; MaxBarS=MaxBar+1;      
//---- �������� �������� ��������� ���������� � ������
for(bar=limit; bar>=0; bar--)Ind_Buffer1[bar]=INDICATOR(bar);
//---- �������� ������������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� ����� 
//---- ������������� ����
if (limit>MaxBar)
 {
  limit=MaxBar; 
  for(int ttt=Bars-1;ttt>MaxBar;ttt--)
   {
    Ind_Buffer2[ttt]=EmptyValue; 
    Ind_Buffer3[ttt]=EmptyValue; 
    Ind_Buffer4[ttt]=EmptyValue;
    Ind_Buffer5[ttt]=EmptyValue; 
   }
 }

//---- ������ ����������
for(bar=limit;bar>=0;bar--)
   {
    Out_Series=Ind_Buffer1[bar];
    //---- +SSSSSSSSSSSSSSSS <<< ���������� ��� ���������� >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
    trend=Out_Series-Ind_Buffer1[bar+1];     
    if(trend>0)     {Ind_Buffer2[bar]=Out_Series; Ind_Buffer3[bar]=EmptyValue; Ind_Buffer4[bar]=EmptyValue;}
    else{if(trend<0){Ind_Buffer2[bar]=EmptyValue; Ind_Buffer3[bar]=Out_Series; Ind_Buffer4[bar]=EmptyValue;}
    else            {Ind_Buffer2[bar]=EmptyValue; Ind_Buffer3[bar]=EmptyValue; Ind_Buffer4[bar]=Out_Series;}}    
    //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
     
    //----+ ��������� � ������� JJMASeries �� ������� 0, (nJMAdin=0) 
    Signal=JJMASeries(0,0,MaxBarS,limit,Signal_Phase,Signal_Length,Out_Series,bar,reset);
    //----+ �������� �� ���������� ������ � ���������� ��������
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
    Ind_Buffer5[bar]=Signal;
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
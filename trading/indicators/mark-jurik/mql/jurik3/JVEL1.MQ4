/*
// Created by Starlight (extesy@y&&ex.ru). Don't remove this line even if you do conversion to EL,MQL etc!
/---- 
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                        JVEL1.mq4 |
//|         JVEL1: Copyright � 2005,            Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|   MQL4+3color: Copyright � 2006,                Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers  2
//---- ����� ���������� 
#property indicator_color1  Gray
#property indicator_color2  Yellow
//---- ����� ���������� ����� ����������
#property indicator_style1 0
#property indicator_style2 4
//---- ��������� �������������� ������� ����������
#property indicator_level1  0.0
#property indicator_levelcolor MediumBlue
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Depth=10;           // ������� ����������� ����������
extern int Sign.Length=12;     // ������� ����������� ���������� �����
extern int Sign.Phase =100;    // �������� ���������� �����, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������;
extern int Input_Price_Customs = 4;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Ind_Buffer1[];
double Ind_Buffer2[];
//---- ���������� � ��������� ������ 
double jrc01, jrc04, jrc05, jrc06, jrc07, jrc08, jrc09, trend, JVEL1, Resalt;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JVEL1 initialization function                                    |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
//---- 2 ������������ ������� ������������ ��� �����. 
   SetIndexBuffer(0,Ind_Buffer1);
   SetIndexBuffer(1,Ind_Buffer2);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0); 
   SetIndexEmptyValue(1,0);
//---- ����� ��� ���� ������ � ����� ��� ��������.
   SetIndexLabel(0,"JVELaux"  );  
   SetIndexLabel(3,"Signal"  );    
   IndicatorShortName("JVELaux1( Depth="+Depth+"Input_Price_Customs="+Input_Price_Customs+")"); 
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ���������� 
   IndicatorDigits(0);
//---- ��������� ������� �� ������������ �������� ������� ���������� ===============================================================================+ 
if(Sign.Phase<-100){Alert("�������� Sign.Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Sign.Phase+ " ����� ������������ -100");}//|
if(Sign.Phase> 100){Alert("�������� Sign.Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Sign.Phase+ " ����� ������������  100");}//|
if(Sign.Length< 1) {Alert("�������� Sign.Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Sign.Length+ " ����� ������������   1");}//|
if(Depth< 1)       {Alert("�������� Depth ������ ���� �� ����� 1"           + " �� ����� ������������ " +Depth+ "       ����� ������������   1");}//|
PriceSeriesAlert(Input_Price_Customs);//---- ��������� � ������� PriceSeriesAlert ////////////////////////////////////////////////////////////////////|
//---- =============================================================================================================================================+ 
//---- �������� ������������� �������� ��������� Depth
   if(Depth<1)Depth=1; 
//---- ������������� ������������
   jrc04 = Depth + 1.0;
   jrc05 = jrc04 * (jrc04+1.0)/2.0;
   jrc06 = jrc05 * (2*jrc04+1.0)/3.0;
   jrc07 = jrc05 * jrc05 * jrc05 - jrc06 * jrc06; 
//---- ���������� �������������
return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JVEL1 iteration function                                         |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
{
//---- �������� ���������� ����� �� ������������� ��� �������
if(Bars-1<=Depth)return(0);  
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,limit,MaxBar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0)counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
if (counted_bars==0)JJMASeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1; MaxBar=Bars-1-Depth;
//---- �������� ������������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� ����� 
//---- ������������� ����
if (limit>MaxBar)
 {
  limit=MaxBar; 
  for(int ttt=Bars-1;ttt>MaxBar;ttt--)
   {
    Ind_Buffer1[ttt]=0.0; 
    Ind_Buffer2[ttt]=0.0; 
   }
 }

//----+ ������ ����������
for(int bar=limit; bar>=0; bar--)
  {
    jrc08 = 0.0;
    jrc09 = 0.0;
    for(int jj=0; jj<=Depth; jj++)
      {
       //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� jrc01
       jrc01=PriceSeries(Input_Price_Customs, bar+jj);    
       //----+ 
       jrc08 = jrc08 + jrc01 * (jrc04 - jj);
       jrc09 = jrc09 + jrc01 * (jrc04 - jj) * (jrc04 - jj);
      }
    JVEL1 = (jrc09*jrc05 - jrc08*jrc06) / jrc07; 
    JVEL1 = JVEL1/Point;
    Ind_Buffer1[bar]=JVEL1;
    //----+ ���������� ���������� ����� ( ��������� � ������� JJMASeries �� ������� 0, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0))
    Resalt=JJMASeries(0,0,MaxBar,limit,Sign.Phase,Sign.Length,JVEL1,bar,reset);
    //----+ �������� �� ���������� ������ � ���������� ��������
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
     Ind_Buffer2[bar]=Resalt; 
  }  
return(0);
//---- ���������� ���������� �������� ����������
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
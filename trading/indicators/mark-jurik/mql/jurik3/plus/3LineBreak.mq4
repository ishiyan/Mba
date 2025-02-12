//������������� � ���������� 17.04.2006 ������� �������
/*
��� ������ ����������  �������  ��������  ����  
INDICATOR_COUNTED.mqh    
� ����� (����������): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                   3LineBreak.mq4 |
//|                               Copyright � 2004, Poul_Trade_Forum |
//|                                                         Aborigen |
//|                                          http://forex.kbpauk.ru/ |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Poul Trade Forum"
#property link      "http://forex.kbpauk.ru/"
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 2
//---- ����� ����������
#property indicator_color1 Gold
#property indicator_color2 Magenta
//---- ������� ������������ �����
#property indicator_width1 1
#property indicator_width2 1
//---- ������� ��������� ���������� 
extern int Lines_Break=3;
//---- ������������ �������
double HighBuffer[];
double LowBuffer [];
int T2[2],Tnew,MEMORY[2];
//---- ���������� � ��������� ������  
double VALUE1,VALUE2,Swing=1,OLDSwing;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| 3LineBreak initialization function                               |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {   
//---- ����� ���������� ������� ���� ����������� 
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
//---- 2 ������������ ������� ������������ ��� �����.
   SetIndexBuffer(0,HighBuffer);
   SetIndexBuffer(1,LowBuffer );
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
//---- ����� ��� ���� ������ � ����� ��� ��������.
   IndicatorShortName("3LineBreak");
   SetIndexLabel   (0,"3LineBreak");
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������  
   SetIndexDrawBegin(0,Lines_Break);
   SetIndexDrawBegin(1,Lines_Break);
//---- ���������� �������������

   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| 3LineBreak iteration function                                    |
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
MaxBar=Bars-1-Lines_Break;
limit=(Bars-1-counted_bars);
if (limit>MaxBar)limit=MaxBar;
//----
Tnew=Time[limit+1];
//+--- �������������� �������� ���������� +================+
if (limit<MaxBar)
 if (Tnew==T2[1])Swing=MEMORY[1]; 
 else 
 if (Tnew==T2[0]){Swing=MEMORY[0];MEMORY[1]=MEMORY[0];}  
 else
  {
   if (Tnew>T2[1])Print("ERROR01");
   else Print("ERROR02");
   INDICATOR_COUNTED(-1);return(-1);  
  }
//+--- +===================================================+
for (int bar=limit; bar>=0;bar--)
 {
  OLDSwing=Swing;
  //----
  VALUE1=High[Highest(NULL,0,MODE_HIGH,Lines_Break,bar+1)];
  VALUE2= Low[Lowest (NULL,0,MODE_LOW, Lines_Break,bar+1)];
  //----
  if (OLDSwing== 1 &&  Low [bar]<VALUE2) Swing=-1;
  if (OLDSwing==-1 &&  High[bar]>VALUE1) Swing= 1;
  //----
  if (Swing==1)
   { 
    HighBuffer[bar]=High[bar]; 
    LowBuffer [bar]=Low [bar]; 
   }

  if (Swing==-1)
   { 
    LowBuffer [bar]=High[bar]; 
    HighBuffer[bar]=Low [bar]; 
   }
  //+--- ���������� �������� ���������� +====+
  if ((bar==2)||(bar==1))
   {
     MEMORY[bar-1]=Swing;
     T2[bar-1]=Time[bar];
   }
  //+---+====================================+     
 }
   return(0);
}
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� INDICATOR_COUNTED (���� INDICATOR_COUNTED.mqh ������� �������� � ����� (����������): 
#include <INDICATOR_COUNTED.mqh>                           //                                      MetaTrader\experts\include)
//+---------------------------------------------------------------------------------------------------------------------------+


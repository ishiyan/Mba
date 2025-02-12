//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                 Heiken AshiR.mq4 |
//|                      Copyright c 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//+------------------------------------------------------------------+
//| For Heiken Ashi we recommend next chart settings ( press F8 or   |
//| select on menu 'Charts'->'Properties...'):                       |
//|  - On 'Color' Tab select 'Black' for 'Line Graph'                |
//|  - On 'Common' Tab disable 'Chart on Foreground' checkbox and    |
//|    select 'Line Chart' radiobutton                               |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 4 
//---- ����� ���������� 
#property indicator_color1 Red  
#property indicator_color2 LimeGreen 
#property indicator_color3 Red
#property indicator_color4 LimeGreen
//---- ������� ������������ �����
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3 
#property indicator_width4 3
//---- ������������ �������
double L.Buffer[];
double H.Buffer[];
double O.Buffer[];
double C.Buffer[];
//---- ���������� � ��������� ������  
double haOpen, haHigh, haLow, haClose;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Heiken AshiR initialization function                             |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_HISTOGRAM,0);
   SetIndexStyle(1,DRAW_HISTOGRAM,0);
   SetIndexStyle(2,DRAW_HISTOGRAM,0);
   SetIndexStyle(3,DRAW_HISTOGRAM,0);
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������  
   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
   SetIndexDrawBegin(3,10);
//---- 4 ������������ ������� ������������ ��� �����
   SetIndexBuffer(0,L.Buffer);
   SetIndexBuffer(1,H.Buffer);
   SetIndexBuffer(2,O.Buffer);
   SetIndexBuffer(3,C.Buffer);
//---- ���������� �������������
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Heiken AshiiR teration function                                  |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
if (Bars<=10) return(0);
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int bar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
//(��� ����� ��������� ��� counted_bars ������� JJMASeries ����� �������� �����������!!!)
if (counted_bars>0) counted_bars--;
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
bar=Bars-counted_bars-1;
if (bar>Bars-2)bar=Bars-2;
//----
while(bar>=0)
     {
      haOpen=(O.Buffer[bar+1]+C.Buffer[bar+1])/2;
      haClose=(Open[bar]+High[bar]+Low[bar]+Close[bar])/4;
      haHigh=MathMax(High[bar], MathMax(haOpen, haClose));
      haLow=MathMin(Low[bar], MathMin(haOpen, haClose));
      if (haOpen<haClose) 
        {
         L.Buffer[bar]=haLow;
         H.Buffer[bar]=haHigh;
        } 
      else
        {
         L.Buffer[bar]=haHigh;
         H.Buffer[bar]=haLow;
        } 
      O.Buffer[bar]=haOpen;
      C.Buffer[bar]=haClose;
 	   bar--;
     }
//----
   return(0);
  }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� INDICATOR_COUNTED (���� INDICATOR_COUNTED.mqh ������� �������� � ����� (����������): 
#include <INDICATOR_COUNTED.mqh> ////////////////////////////////                                  MetaTrader\experts\include)
//+---------------------------------------------------------------------------------------------------------------------------+
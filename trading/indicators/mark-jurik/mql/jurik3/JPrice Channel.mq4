/*
���  ������  ����������  �������  �������� ����

INDICATOR_COUNTED.mqh 
JJMASeries.mqh  
� ����� (����������): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                               JPrice Channel.mq4 |
//|                                                                  |
//|                                       http://forex.kbpauk.ru/    |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property link      "http://forex.kbpauk.ru/"
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 3
//---- ���� ����������
#property indicator_color1 Lime
#property indicator_color2 Magenta
#property indicator_color3 Red
//---- ����� ����� Bollinger Bands
#property indicator_style1 4
#property indicator_style2 2
#property indicator_style3 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int  Channel_Period = 14; // ������ ������
extern int         Smooth = 8; // ������� ����������� ������� �����
extern int   Smooth_Phase = 100;// �������� �����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int      Ind_Shift = 0;  // c���� ���������� ����� ��� ������� 
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double UpBuffer[];
double DnBuffer[];
double MdBuffer[];
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Price Channel initialization function                            | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
   string short_name;
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
//---- 3 ������������ �������� ������������ ��� �����   
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,MdBuffer);
   SetIndexBuffer(2,DnBuffer);
//---- �������������� ����� ������������ ����� 
   SetIndexShift (0, Ind_Shift); 
   SetIndexShift (1, Ind_Shift); 
   SetIndexShift (2, Ind_Shift); 
//---- ��� ��� ���� ������ � ����� ��� ��������.
   short_name="Price Channel("+Channel_Period+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Up Channel");
   SetIndexLabel(1,"Middle Channel");
   SetIndexLabel(2,"Down Channel");
//---- ��������� ������ ����, ������� � �������� ����� �������������� ��������� 
   SetIndexDrawBegin(0,Channel_Period);
   SetIndexDrawBegin(1,Channel_Period+30);
   SetIndexDrawBegin(2,Channel_Period);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
   //---- ��������� ������� �� ������������ �������� ������� ���������� ===================================================================================+ 
if(Smooth_Phase<-100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+ " ����� ������������ -100");}///|
if(Smooth_Phase> 100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+ " ����� ������������  100");}///|
if(Channel_Period<1) {Alert("�������� Channel_Period ������ ���� �� ����� 1"+ " �� ����� ������������ " +Channel_Period+ " ����� ������������  1");}///////|
if(Smooth< 1)        {Alert("�������� Smooth ������ ���� �� ����� 1"      + " �� ����� ������������ " +Smooth+   " ����� ������������  1");}///////////////|
//---- ====================================================================================================================================================+ 
//---- �������� ������������� �������� ��������� Channel_Period
   if(Channel_Period<1)Channel_Period=1; 
//---- ���������� �������������
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Price Channel iteration function                                 | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//----
if(Bars<=Channel_Period) return(0);
//---- �������� ���������� � ��������� ������ 
double high,low,price,Temp_Series,Resalt;
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int limit,reset,MaxBar,bar,ii,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
if (counted_bars==0)JJMASeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1;MaxBar=Bars-1-Channel_Period;
//---- �������� ���������� ��������� ���� � �����
//---- ������������� ����          
if (limit>=MaxBar)
    {
     for(bar=limit;bar>=MaxBar;bar--)
      {
       UpBuffer[bar]=0.0;    
       DnBuffer[bar]=0.0;
       MdBuffer[bar]=0.0;
      }
     limit=MaxBar;
    }
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
bar=limit;
while(bar>=0)
  {
      high=High[bar]; low=Low[bar]; 
      ii=bar-1+Channel_Period;
      while(ii>=bar)
        {
         price=High[ii];
         if(high<price)high=price;
         price=Low[ii];
         if(low>price) low=price;
         ii--;
        } 
     UpBuffer[bar]=high;
     DnBuffer[bar]=low;
     Temp_Series=(high+low)/2;
     
    //----+ ��������� � ������� JJMASeries �� ������� 0. ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
    Resalt=JJMASeries(0,0,MaxBar,limit,Smooth_Phase,Smooth,Temp_Series,bar,reset);
    //----+ �������� �� ���������� ������ � ���������� ��������
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
    MdBuffer[bar]=Resalt;
     
      bar--;
  }
return(0);
 }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� JJMASeries (���� JJMASeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
//----+ �������� ������� JJMASeriesReset  (�������������� ������� ����� JJMASeries.mqh)
//----+ �������� ������� INDICATOR_COUNTED(�������������� ������� ����� JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
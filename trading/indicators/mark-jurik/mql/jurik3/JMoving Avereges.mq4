/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                             JMoving Avereges.mq4 | 
//|                 JMA code: Copyright � 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|         JMoving Avereges: Copyright � 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 1 
//---- ���� ����������
#property indicator_color1 Red 
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int           MA_period = 8; // �������  ������� ����������� 
extern int           MA_method = 0;  // ����� ����������
extern int           Smooth    = 8; // ������� ����������� 
extern int       Smooth_Phase  = 100;// �������� �����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int           Shift     = 0;  // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0;  //����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Series_buffer[];
double JMovingBuffer[];
//---- ���������� � ��������� ������  
double Temp_Series,Resalt;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JMoving Avereges initialization function                         | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{  
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE); 
//---- 2 ������������ ������� �����������s ��� �����
IndicatorBuffers(2);
SetIndexBuffer(0,JMovingBuffer);
SetIndexBuffer(1,Series_buffer);
//---- �������������� ����� ������������ ����� 
SetIndexShift (0, Shift);  
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
SetIndexEmptyValue(0,0); 
//---- ��� ��� ���� ������ � ����� ��� ��������. 
IndicatorShortName ("JMoving Avereges( MA_period="+MA_period+", MA_method="+MA_method+", Shift="+Shift+")"); 
SetIndexLabel (0, "JMoving Avereges"); 
//----
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- ��������� ������� �� ������������ �������� ������� ���������� ======================================================================================+ 
if(Smooth_Phase<-100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+  " ����� ������������ -100");}//|
if(Smooth_Phase> 100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+  " ����� ������������  100");}//|
if(Smooth< 1)        {Alert("�������� Smooth ������ ���� �� ����� 1"     + " �� ����� ������������ " +Smooth+ " ����� ������������  1");}//////////////////|
if(MA_period< 1)     {Alert("�������� MA_period ������ ���� �� ����� 1"  + " �� ����� ������������ " +MA_period+ " ����� ������������  1");}///////////////|
if(MA_method<0)      {Alert("�������� MA_method ������ ���� �� 0 �� 3"   + " �� ����� ������������ " +MA_method+ " ����� ������������ 0");}////////////////|
if(MA_method>3)      {Alert("�������� MA_method ������ ���� �� 0 �� 3"   + " �� ����� ������������ " +MA_method+ " ����� ������������ 0");}////////////////|
PriceSeriesAlert(Input_Price_Customs);//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|
//+========================================================================================================================================================+ 
//---- �������� ������������� �������� ��������� MA_period
if(MA_period<1)MA_period=1; 
//---- ���������� �������������
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JMoving Avereges iteration function                              | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,MaxBar,bar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
//(��� ����� ��������� ��� counted_bars ������� JJMASeries ����� �������� �����������!!!)
if (counted_bars>0)counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
if (counted_bars==0)JJMASeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
int limit=Bars-counted_bars-1; MaxBar=Bars-1-MA_period; 
//----+ �������� � ����� �������� ���
for(bar=limit;bar>=0;bar--)Series_buffer[bar]=PriceSeries(Input_Price_Customs,bar);
//---- �������� ���������� ��������� ���� � �����
//---- ������������� ����          
if (limit>MaxBar)
   {
    for(bar=limit;bar>=MaxBar;bar--)JMovingBuffer[bar]=0;
    limit=MaxBar;
   }

//----+ �������� ���� ���������� ���������� 
for(bar=limit;bar>=0;bar--)
  {
  //----+ ������� ��� ������� ����������
  switch(MA_method)
    {
     case  0: Temp_Series=iMAOnArray(Series_buffer,0,MA_period,0,MODE_SMA, bar);break;
     case  1: Temp_Series=iMAOnArray(Series_buffer,0,MA_period,0,MODE_EMA, bar);break;
     case  2: Temp_Series=iMAOnArray(Series_buffer,0,MA_period,0,MODE_SMMA,bar);break;
     case  3: Temp_Series=iMAOnArray(Series_buffer,0,MA_period,0,MODE_LWMA,bar);break;
     default: Temp_Series=iMAOnArray(Series_buffer,0,MA_period,0,MODE_SMA, bar);
    }
  //----+ ����������� ����������� Moving Avereges
  //----+ ��������� � ������� JJMASeries �� ������� 0. ��������s nJJMALength �� ����t��� �� ������ ���� (nJJMAdin=0)
  Resalt=JJMASeries(0,0,MaxBar,limit,Smooth_Phase,Smooth,Temp_Series,bar,reset);
  //----+ �������� �� ���������� ������ � ���������� ��������
  if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
  JMovingBuffer[bar]=Resalt; 
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
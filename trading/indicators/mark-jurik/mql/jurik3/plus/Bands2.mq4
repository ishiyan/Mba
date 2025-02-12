/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                              Bollinger Bands.mq4 | 
//|                        Copyright � 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 2
//---- ���� ����������
#property indicator_color1 Blue
#property indicator_color2 Blue
//---- ����� ����� Bollinger Bands
#property indicator_style1 4
#property indicator_style2 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int        Bands_Period = 20; // ������  ���������� J2Bollinger Bands
extern double Bands_Deviations = 2.0; // ���������� 
extern int           MA_method = 0;   // ����� ����������
extern int         Bands_Shift = 0;   // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0;   //����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi High, 12-Heiken Ashi Low, 13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- buffers
double UpperBuffer[];
double LowerBuffer[];
double SeriesBuffer[];
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Bollinger Bands initialization function                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexStyle(1,DRAW_LINE);
//---- 4 ������������ �������� ������������ ��� �����
   IndicatorBuffers(3); 
   SetIndexBuffer(0,UpperBuffer );  
   SetIndexBuffer(1,LowerBuffer );
   SetIndexBuffer(2,SeriesBuffer);
//---- ��������� ������ ����, ������� � �������� ����� �������������� ��������� 
   int drawbegin=Bands_Period+Bands_Shift; 
   SetIndexDrawBegin(0,drawbegin);
   SetIndexDrawBegin(1,drawbegin);
//---- �������������� ����� ������������ �����  
   SetIndexShift (0, Bands_Shift); 
   SetIndexShift (1, Bands_Shift); 
//---- ��� ��� ���� ������ � ����� ��� ��������. 
   IndicatorShortName ("Bollinger Bands( Period="+Bands_Period+", Deviations="+Bands_Deviations+")"); 
   SetIndexLabel (0, "Upper Bands"); 
   SetIndexLabel (1, "Lower Bands"); 
//---- ��������� ������� �� ������������ �������� ������� ���������� ======================================================================================+ 
if(Bands_Period<1)   {Alert("�������� Bands_Period ������ ���� �� ����� 1 "+ " �� ����� ������������ " +Bands_Period+ " ����� ������������  1");}//////////|
if(MA_method<0)      {Alert("�������� MA_method ������ ���� �� 0 �� 3"   + " �� ����� ������������ " +MA_method+ " ����� ������������ 0");}////////////////|
if(MA_method>3)      {Alert("�������� MA_method ������ ���� �� 0 �� 3"   + " �� ����� ������������ " +MA_method+ " ����� ������������ 0");}////////////////|
PriceSeriesAlert(Input_Price_Customs);//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|
//+========================================================================================================================================================+ 
//---- �������� ������������� �������� ��������� Bands_Period
if(Bands_Period<1)Bands_Period=1; 
//---- ���������� �������������
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Bollinger Bands iteration function                               | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//---- �������� ���������� ����� �� ������������� ��� �������
if(Bars<=Bands_Period) return(0);
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int bar,kk,MaxBarBB,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1; MaxBarBB=Bars-1-Bands_Period;
double Temp_Series,sum,midline,priceswing,deviation;
//----+ �������� ������� ��� � ������ ��� �������       
for(bar=limit;bar>=0;bar--)SeriesBuffer[bar]=PriceSeries(Input_Price_Customs,bar);
//---- �������� ���� �� ������������� ��� ������� Bollinger Bands 
if (limit>MaxBarBB)limit=MaxBarBB;

for(bar=limit;bar>=0;bar--)
     {
      //----+ ������� ��� ������� Moving Avereges
      switch(MA_method)
           {
            case  0: Temp_Series=iMAOnArray(SeriesBuffer,0,Bands_Period,0,MODE_SMA, bar);break;
            case  1: Temp_Series=iMAOnArray(SeriesBuffer,0,Bands_Period,0,MODE_EMA, bar);break;
            case  2: Temp_Series=iMAOnArray(SeriesBuffer,0,Bands_Period,0,MODE_SMMA,bar);break;
            case  3: Temp_Series=iMAOnArray(SeriesBuffer,0,Bands_Period,0,MODE_LWMA,bar);break;
            default: Temp_Series=iMAOnArray(SeriesBuffer,0,Bands_Period,0,MODE_SMA, bar);
           }
                 
      //---- ���ר� Bollinger Bands
      sum=0.0;
      kk=bar+Bands_Period-1;
      midline=Temp_Series;
      while(kk>=bar)
        {
         priceswing=PriceSeries(Input_Price_Customs,kk)-midline;
         sum+=priceswing*priceswing;
         kk--;
        }
      deviation=Bands_Deviations*MathSqrt(sum/Bands_Period);
      UpperBuffer[bar]=midline+deviation;
      LowerBuffer[bar]=midline-deviation;
      //----
    }
//----
   return(0);
  }
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� INDICATOR_COUNTED (���� INDICATOR_COUNTED.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ �������� ������� PriceSeries, ���� PriceSeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include
//----+ �������� ������� PriceSeriesAlert (�������������� ������� ����� PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+
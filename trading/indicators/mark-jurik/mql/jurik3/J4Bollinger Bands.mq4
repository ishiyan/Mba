/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                            J4Bollinger Bands.mq4 | 
//|                        Copyright � 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 5
//---- ����� ����������
#property indicator_color1 Red
#property indicator_color2 Blue 
#property indicator_color3 Lime
#property indicator_color4 Blue
#property indicator_color5 Red
//---- ����� ����� ����������
#property indicator_style1 4
#property indicator_style2 2
#property indicator_style3 4
#property indicator_style4 2
#property indicator_style5 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int        Bands_Period = 100; // ������  ���������� J2Bollinger Bands
extern double Bands_Deviations = 2.0; // ���������� 
extern int           MA_method = 0;   // ����� ����������
extern int           MA_Smooth = 20;  // ������� ����������� ����������� Moving Avereges
extern int        Bands_Smooth = 20;  // ������� ����������� ���������� Bollinger Bands
extern int        Smooth_Phase = 100; // �������� �����������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int          Bands_Shift = 0;  // c���� ���������� ����� ��� ������� 
extern int  Input_Price_Customs = 0;  //����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double UpperBuffer2 [];
double UpperBuffer1 [];
double JMovingBuffer[];
double LowerBuffer1 [];
double LowerBuffer2 [];
double Series_buffer[];
//---- ���������� � ��������� ������  
double deviation1,deviation2,Temp_Series,sum,midline,priceswing,Resalt;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| J4Bollinger Bands initialization function                        | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {
//---- ����������� ����� ���������� �������
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE); 
   SetIndexStyle(4,DRAW_LINE);
//---- 4 ������������ ������� ������������ ��� �����.  
   IndicatorBuffers(6);
   SetIndexBuffer(0,UpperBuffer2 );
   SetIndexBuffer(1,UpperBuffer1 );
   SetIndexBuffer(2,JMovingBuffer);
   SetIndexBuffer(3,LowerBuffer1 );
   SetIndexBuffer(4,LowerBuffer2 );
   SetIndexBuffer(5,Series_buffer);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
   SetIndexEmptyValue(3,0);
   SetIndexEmptyValue(4,0);
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������  
   int drawbegin=Bands_Period+30+Bands_Shift;
   SetIndexDrawBegin(0,drawbegin);
   SetIndexDrawBegin(1,drawbegin);
   SetIndexDrawBegin(2,drawbegin);
   SetIndexDrawBegin(3,drawbegin);
   SetIndexDrawBegin(4,drawbegin);
//---- �������������� ����� ������������ �����  
   SetIndexShift (0, Bands_Shift); 
   SetIndexShift (1, Bands_Shift); 
   SetIndexShift (2, Bands_Shift); 
   SetIndexShift (3, Bands_Shift); 
   SetIndexShift (4, Bands_Shift); 
//---- ��� ��� ���� ������ � ����� ��� ��������.
   IndicatorShortName ("J4Bollinger Bands( Period="+Bands_Period+", Deviations="+Bands_Deviations+")"); 
   SetIndexLabel (0, "Upper2 Bands");
   SetIndexLabel (1, "Upper1 Bands"); 
   SetIndexLabel (3, "Lower1 Bands"); 
   SetIndexLabel (4, "Lower2 Bands"); 
   switch(MA_method)
           {
            case  0: SetIndexLabel (2, "JMoving Avereges JSMA ("+Bands_Period+")");break;
            case  1: SetIndexLabel (2, "JMoving Avereges JEMA ("+Bands_Period+")");break;
            case  2: SetIndexLabel (2, "JMoving Avereges JSSMA("+Bands_Period+")");break;
            case  3: SetIndexLabel (2, "JMoving Avereges JLWMA("+Bands_Period+")");break;
            default: SetIndexLabel (2, "JMoving Avereges JSMA ("+Bands_Period+")");
           }
//----
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- ��������� ������� �� ������������ �������� ������� ���������� ======================================================================================+ 
if(Smooth_Phase<-100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+  " ����� ������������ -100");}//|
if(Smooth_Phase> 100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+  " ����� ������������  100");}//|
if(MA_Smooth<1)      {Alert("�������� MA_Smooth ������ ���� �� ����� 1" + " �� ����� ������������ " +MA_Smooth+ " ����� ������������  1");}////////////////|
if(MA_Smooth<1)      {Alert("�������� Bands_Smooth ������ ���� �� ����� 1" + " �� ����� ������������ " +Bands_Smooth + " ����� ������������  1");}/////////|
if(Bands_Period<1)   {Alert("�������� Bands_Period ������ ���� �� ����� 1 "+ " �� ����� ������������ " +Bands_Period+ " ����� ������������  1");}//////////|
if(MA_method<0)      {Alert("�������� MA_method ������ ���� �� 0 �� 3"   + " �� ����� ������������ " +MA_method+ " ����� ������������ 0");}////////////////|
if(MA_method>3)      {Alert("�������� MA_method ������ ���� �� 0 �� 3"   + " �� ����� ������������ " +MA_method+ " ����� ������������ 0");}////////////////|
PriceSeriesAlert(Input_Price_Customs);/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|
//+========================================================================================================================================================+ 
//---- �������� ������������� �������� ��������� Bands_Period
if (Bands_Period<1)Bands_Period=1; 
//---- ���������� �������������
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| J4Bollinger Bands iteration function                             | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
  {
//---- �������� ���������� ����� �� ������������� ��� �������
if(Bars-1<=Bands_Period) return(0);
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,MaxBar,MaxBarBB,bar,kk,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
//---- (��� ����� ��������� ��� counted_bars ������� JJMASeries ����� �������� �����������!!!)
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=5(���� ��������� � �������)  
if (counted_bars==0)if (Bands_Smooth>1)JJMASeriesReset(5);else JJMASeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
int limit=Bars-counted_bars-1;MaxBar=Bars-1-Bands_Period;MaxBarBB=MaxBar-30-Bands_Period;
//----+ �������� ������� ��� � ������ ��� �������       
for(bar=limit;bar>=0;bar--)Series_buffer[bar]=PriceSeries(Input_Price_Customs,bar);
//---- �������� ���� �� ������������� ��� ������� Bollinger Bands 
//---- ������������� ����          
if (limit>MaxBar)
     {
      for(bar=limit;bar>=MaxBar;bar--)JMovingBuffer[bar]=0;
      limit=MaxBar;
     }
//----+ ���� ������� Moving Avereges
for(bar=limit;bar>=0;bar--)
     {
      //----+ ������� ��� ������� Moving Avereges
      switch(MA_method)
           {
            case  0: Temp_Series=iMAOnArray(Series_buffer,0,Bands_Period,0,MODE_SMA, bar);break;
            case  1: Temp_Series=iMAOnArray(Series_buffer,0,Bands_Period,0,MODE_EMA, bar);break;
            case  2: Temp_Series=iMAOnArray(Series_buffer,0,Bands_Period,0,MODE_SMMA,bar);break;
            case  3: Temp_Series=iMAOnArray(Series_buffer,0,Bands_Period,0,MODE_LWMA,bar);break;
            default: Temp_Series=iMAOnArray(Series_buffer,0,Bands_Period,0,MODE_SMA, bar);
           }
      //----+ ����������� ����������� Moving Avereges
      //----+ ��������� � ������� JJMASeries �� ������� 0. ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
      Resalt=JJMASeries(0,0,MaxBar,limit,Smooth_Phase,MA_Smooth,Temp_Series,bar,reset);
      //----+ �������� �� ���������� ������ � ���������� ��������
      if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
      JMovingBuffer[bar]=Resalt; 
     }     
//---- ���ר� Bollinger Bands 
//---- ������������� ����      
if (limit>MaxBarBB)
     {
      for(bar=limit;bar>=MaxBarBB;bar--)
       {
        UpperBuffer2[bar]=0;
        UpperBuffer1[bar]=0;
        LowerBuffer1[bar]=0;
        LowerBuffer2[bar]=0;
       }
      limit=MaxBarBB;
     }
for(bar=limit;bar>=0;bar--)
   {         
     sum=0.0;
     midline=JMovingBuffer[bar];
     kk=bar+Bands_Period-1;
     while(kk>=bar)
      {
       priceswing=PriceSeries(Input_Price_Customs,kk)-midline;
       sum+=priceswing*priceswing;
       kk--;
      }
     deviation2=Bands_Deviations*MathSqrt(sum/Bands_Period);     
     deviation1=0.5*deviation2;
     if (Bands_Smooth>1)
        {
         //----+ ���������� � JMA ����������� Bollinger Bands      
         //----+ ----------------------------------------------------------------------------------------+            
         //----+ ������ ������������ ��������� � ������� JJMASeries �� �������� 1, 2, 3, 4. 
         //----+ ��������� nJJMALength �� ����t��� �� ������ ���� (nJJMAdin=0)
         //----+ ----------------------------------------------------------------------------------------+ 
         Resalt=JJMASeries(1,0,MaxBarBB-1,limit,Smooth_Phase,Bands_Smooth ,midline+deviation2,bar,reset);
         //----+ �������� �� ���������� ������ � ���������� ��������
         if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
         UpperBuffer2[bar]=Resalt; 
         //----+ ----------------------------------------------------------------------------------------+       
         Resalt=JJMASeries(2,0,MaxBarBB-1,limit,Smooth_Phase,Bands_Smooth ,midline+deviation1,bar,reset);
         //----+ �������� �� ���������� ������ � ���������� ��������
         if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
         UpperBuffer1[bar]=Resalt; 
         //----+ ----------------------------------------------------------------------------------------+ 
         Resalt=JJMASeries(3,0,MaxBarBB-1,limit,Smooth_Phase,Bands_Smooth ,midline-deviation1,bar,reset);
         //----+ �������� �� ���������� ������ � ���������� ��������
         if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
         LowerBuffer1[bar]=Resalt; 
         //----+ ----------------------------------------------------------------------------------------+ 
         Resalt=JJMASeries(4,0,MaxBarBB-1,limit,Smooth_Phase,Bands_Smooth ,midline-deviation2,bar,reset);
         //----+ �������� �� ���������� ������ � ���������� ��������
         if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
         LowerBuffer2[bar]=Resalt;         
         //----+ ----------------------------------------------------------------------------------------+ 
        }
      else 
        {
         //----+ ���������� Bollinger Bands ��� JMA �����������  
         UpperBuffer2[bar]=midline+deviation2;
         UpperBuffer1[bar]=midline+deviation1;
         LowerBuffer1[bar]=midline-deviation1;
         LowerBuffer2[bar]=midline-deviation2;
        }
      
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
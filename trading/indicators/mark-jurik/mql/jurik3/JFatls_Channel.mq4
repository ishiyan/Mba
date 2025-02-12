/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                               JFatls_Channel.mq4 | 
//|                           Copyright � 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ ��������
#property indicator_buffers 3
//---- ����� ����������
#property indicator_color1 Blue
#property indicator_color2 Magenta
#property indicator_color3 Blue
//---- ����� ����� ����������
#property indicator_style1 4
#property indicator_style2 0
#property indicator_style3 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Channel_width = 100; // ������ ������ � �������
extern int        Length = 3;   // ������� ����������� 
extern int        Phase  = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int        Shift  = 0;   // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������ ������������� ��������� �������
double Filter[1];
//---- ������������ �������
double JFilter[];
double UpperBuffer[];
double LowerBuffer[];
//---- ����� ����������
int nf; 
//---- ���������� � ��������� ������ 
double FILTER,Series,Half_Width,Resalt;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JFatls_Channel initialization function                           |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init() 
{ 
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE);
SetIndexStyle (1,DRAW_LINE);
SetIndexStyle (2,DRAW_LINE); 
//---- 3 ������������ ������� ������������ ��� �����
SetIndexBuffer(0,UpperBuffer); 
SetIndexBuffer(1,JFilter);  
SetIndexBuffer(2,LowerBuffer); 
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
SetIndexEmptyValue(0,0.0);  
SetIndexEmptyValue(1,0.0); 
SetIndexEmptyValue(2,0.0); 
//---- ��������� ������� ������� Filter[]
nf=38;int count=ArrayResize(Filter,nf+1);if(count==0){Alert("���������� �������� ������ ��� ������ Filter");return(0);}
//+=== ������������� ������������� ��������� ������� =======================================================================+
Filter[00]=+0.4360409450;Filter[01]=+0.3658689069;Filter[02]=+0.2460452079;Filter[03]=+0.1104506886;Filter[04]=-0.0054034585;
Filter[05]=-0.0760367731;Filter[06]=-0.0933058722;Filter[07]=-0.0670110374;Filter[08]=-0.0190795053;Filter[09]=+0.0259609206;
Filter[10]=+0.0502044896;Filter[11]=+0.0477818607;Filter[12]=+0.0249252327;Filter[13]=-0.0047706151;Filter[14]=-0.0272432537;
Filter[15]=-0.0338917071;Filter[16]=-0.0244141482;Filter[17]=-0.0055774838;Filter[18]=+0.0128149838;Filter[19]=+0.0226522218; 
Filter[20]=+0.0208778257;Filter[21]=+0.0100299086;Filter[22]=-0.0036771622;Filter[23]=-0.0136744850;Filter[24]=-0.0160483392;
Filter[25]=-0.0108597376;Filter[26]=-0.0016060704;Filter[27]=+0.0069480557;Filter[28]=+0.0110573605;Filter[29]=+0.0095711419;
Filter[30]=+0.0040444064;Filter[31]=-0.0023824623;Filter[32]=-0.0067093714;Filter[33]=-0.0072003400;Filter[34]=-0.0047717710;
Filter[35]=+0.0005541115;Filter[36]=+0.0007860160;Filter[37]=+0.0130129076;Filter[38]=+0.0040364019;
//+=========================================================================================================================+
//---- ��������� ������� �� ������������ �������� ������� ���������� ==============================================================+ 
if(Phase<-100){Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������ -100");}
if(Phase> 100){Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������  100");}
if(Length<  1){Alert("�������� Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length+ " ����� ������������  1"  );}
PriceSeriesAlert(Input_Price_Customs);////PriceSeriesAlert///////PriceSeriesAlert//////////PriceSeriesAlert/////////PriceSeriesAlert////|
//+================================================================================================================================+
//---- ��������� ������ ����, ������� � �������� ����� �������������� ��������� 
int draw_begin=nf+30; 
SetIndexDrawBegin(0,draw_begin);
SetIndexDrawBegin(1,draw_begin);
SetIndexDrawBegin(2,draw_begin); 
//---- ������ ������ � �������
Half_Width = Channel_width*Point/2;
//---- ���������� �������������
return(0); 
}
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JFATL iteration function                                         |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//---- �������� ���������� ����� �� ������������� ��� �������
if(Bars-1<=nf)return(0);
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,limit,MaxBar,bar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
if (counted_bars==0)JJMASeriesReset(1);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1; 
MaxBar=Bars-1-nf;
//---- �������� ������������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� ����� 
//---- ������������� ����          
if (limit>=MaxBar)
 {
  for(bar=limit;bar>=MaxBar;bar--)
   {
    JFilter[bar]=0.0; 
    UpperBuffer[bar]=0.0;    
    LowerBuffer[bar]=0.0; 
   }
  limit=MaxBar;
 }

//----+  ���������� ��������� ������� Fatl
for(bar=limit;bar>=0;bar--)
  {
   FILTER=0.0;
   for(int ii=0;ii<=nf;ii++)
    {
     //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
     Series=PriceSeries(Input_Price_Customs, bar+ii);
     FILTER=FILTER+Filter[ii]*Series;
    }
   //----+ JMA ����������� ����������� ����������, �������� nJMAMaxBar �������� �� ������ ������� nf  MaxBar=Bars-1-nf
   //----+ ��������� � ������� JJMASeries �� ������� 0, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
   Resalt=JJMASeries(0,0,MaxBar,limit,Phase,Length,FILTER,bar,reset);
   //----+ �������� �� ���������� ������ � ���������� ��������
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   JFilter[bar]=Resalt; 
   //----+ ������ ������
   UpperBuffer[bar]=Resalt+Half_Width;     
   LowerBuffer[bar]=Resalt-Half_Width;
   //---- ���������� ���������� �������� ����������        
  }
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
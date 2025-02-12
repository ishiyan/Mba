/*
���  ������  ����������  �������  �������� ���� JJMASeries.mqh � �����
(����������): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                        JFatl.mq4 | 
//|                           Copyright � 2005,     Nikolay Kositsin | 
//|                                   Khabarovsk, violet@mail.kht.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Copyright 2002, Finware.ru Ltd." 
#property link "http://www.finware.ru/" 

#property indicator_chart_window 
#property indicator_buffers 1 
#property indicator_color1 Blue 
extern int Length = 3;   // ������� ����������� 
extern int Phase  = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������; 
extern int Shift  = 0;   // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0;//����� ���, �� ������� ������������ ������ ���������� 
//(0-"Close", 1-"Open", 2-"(High+Low)/2", 3-"High", 4-"Low", 5-"Heiken Ashi Close", 6-"(Open+Close)/2") 
//---- buffers 
double FILTER,Series;
double @Rezalt[]; 
double Filter[1];
int nf,IPC; 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| Custom indicator initialization function                         |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init() 
{ 
//---- indicator line 
SetIndexStyle(0,DRAW_LINE); 
SetIndexBuffer(0,@Rezalt); 
//---- 
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
//+================================================================================================================================+ 
if(Phase<-100){Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������ -100");}
if(Phase> 100){Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������  100");}
if(Length<  1){Alert("�������� Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length+ " ����� ������������  1"  );}
//+================================================================================================================================+
SetIndexDrawBegin(0,nf+30); 
IPC=Input_Price_Customs;
return(0); 
}
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JFATL                                                            |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
int limit,counted_bars=IndicatorCounted(); 
//---- 
if((counted_bars==0)&&(Bars<=nf))return(0);
//----  
limit=Bars-counted_bars-1; 
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � �������) 
if (limit==Bars-1){int reset=-1;int set=JJMASeries(1,0,0,0,0,0,0,0,reset);if((reset!=0)||(set!=0))return(-1);}
//----+  
for(int k=limit;k>=0;k--)
{
FILTER=0.0;
for(int x=0;x<=nf;x++)
{
if(k<Bars-1-nf)
switch(IPC)
    {
    //----+ ����� ���, �� ������� ������������ ������ ������������� ������� +----+
     case 0:  Series=Close[k+x];break;
     case 1:  Series= Open[k+x];break;
     case 2:  Series=(High[k+x]+Low  [k+x])/2;break;
     case 3:  Series= High[k+x];break;
     case 4:  Series=  Low[k+x];break;
     case 5:  Series=(Open[k+x]+High [k+x]+Low[k+x]+Close[k+x])/4;break;
     case 6:  Series=(Open[k+x]+Close[k+x])/2;break;
     default: Series=Close[k+x];break;
    //----+----------------------------------------------------------------------+   
    }
    FILTER=FILTER+Filter[x]*Series;
}
//----+ JMA ����������� ����������� ����������, �������� nJMAMaxBar �������� �� ������ ������� nf
//----+ ��������� � ������� JJMASeries �� ������� 0, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� (nJMAdin=0)
reset=1;@Rezalt[k]=JJMASeries(0,0,Bars-1-nf,limit,Phase,Length,FILTER,k,reset);if(reset!=0)return(-1);
}
return(0); 
} 
//+------------------------------------------------------------------+

//----+ �������� ������� JJMASeries (���� JJMASeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
#include <JJMASeries.mqh> 
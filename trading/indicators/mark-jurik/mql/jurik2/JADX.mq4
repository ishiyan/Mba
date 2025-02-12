/*
���  ������  ����������  �������  �������� ���� JJMASeries.mqh � �����
(����������): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                         JADX.mq4 | 
//|                 JMA code: Copyright � 2005, Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|                JADX+MQL4: Copyright � 2005,     Nikolay Kositsin | 
//|                                   Khabarovsk, violet@mail.kht.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Weld" 
#property link "http://weld.torguem.net" 
#property indicator_separate_window
#property indicator_color1 Red 
//---- input parameters 
extern int Length1   = 8;  // ������� ����������� DX
extern int Length2   = 3;  // ������� ����������� ADX
extern int Phase1    =-100;// ��������, ������������ � �������� -100 ... +100, ������ �� �������� ���������x ��������� +DM � -DM; 
extern int Phase2    =-100;// ��������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� �������� ADX; 
extern int Shift     = 0;  // c���� ���������� ����� ��� ������� 
extern int CountBars = 500;// ���������� ��������� �����, �� ������� ���������� ������ ���������
//---- indicator buffers 
double JADX_Buffer[ ]; 
//---- ADX variabls
double pDM,mDM,TRJ,JpDM,JmDM,ADX,JADX;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JADX initialization function                                     | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{ 
SetIndexStyle(0, DRAW_LINE); 
SetIndexShift(0, Shift); 
//---- 1 indicator buffer[n]s mapping 
SetIndexBuffer (0, JADX_Buffer);
SetIndexDrawBegin(0,Bars-CountBars); 
SetIndexEmptyValue(0,0.0); 
//---- 
SetIndexLabel (0, "JADX"); 
IndicatorShortName ("JADX"); 
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//+======================================================================================================================================+ 
if(Phase1<-100){Alert("�������� Phase1 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase1+  " ����� ������������ -100");}//|
if(Phase1> 100){Alert("�������� Phase1 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase1+  " ����� ������������  100");}//|
if(Phase2<-100){Alert("�������� Phase2 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase2+  " ����� ������������ -100");}//|
if(Phase2> 100){Alert("�������� Phase2 ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase2+  " ����� ������������  100");}//|
if(Length1< 1) {Alert("�������� Length1 ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length1+ " ����� ������������  1");}////|
if(Length2< 1) {Alert("�������� Length2 ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length2+ " ����� ������������  1");}////|
//+======================================================================================================================================+ 
//---- initialization done
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JADX iteration function                                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ ��������� ��� ������������ �����
int counted_bars = IndicatorCounted(); 
//----+ �������� �� ��������� ������
if (counted_bars<0) return (-1);
int limit=Bars-counted_bars-1;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=3(��� ��������� � �������) 
if (limit==Bars-1){int reset=-1;int set=JJMASeries(3,0,0,0,0,0,0,0,reset);if((reset!=0)||(set!=0))return(-1);}
//----+  
 for(int k=limit;k>=0;k--)
 {
  TRJ=iATR(NULL,Period(),1,k);     
  pDM=High[k]-High[k+1];mDM=Low[k+1]-Low[k];
  if (pDM<0)pDM=0.0;
  if (mDM<0)mDM=0.0;
  if (pDM==mDM)  {pDM=0.0; mDM=0.0;}
  if((pDM> mDM)&&(pDM>0.0))mDM=0.0;
  if((pDM< mDM)&&(mDM>0.0))pDM=0.0;
  if((TRJ<0.00001)&&(k<Bars-40)){pDM=0.0;mDM=0.0;}
  else{pDM=pDM/TRJ;mDM=mDM/TRJ;}
  
  //----+ ��������� � ������� JJMASeries �� ������� 0, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� �� ���� ��� ���������� � ������� (nJMAdin=0)
  reset=1;JpDM=JJMASeries(0,0,Bars-1,limit,Phase1,Length1,pDM,k,reset);if(reset!=0)return(-1);
  
  //----+ ��������� � ������� JJMASeries �� ������� 1 
  reset=1;JmDM=JJMASeries(1,0,Bars-1,limit,Phase1,Length1,mDM,k,reset);if(reset!=0)return(-1); 
   
  if (JpDM+JmDM>0.00001) ADX=100*(JpDM-JmDM)/(JpDM+JmDM);else ADX=0.0;
  
  //----+ ��������� � ������� JJMASeries �� ������� 2 (� ���� ��������� �������� nJMAMaxBar �������� �� 30  �. �. ��� ��������� JMA �����������) 
  reset=1;JADX=JJMASeries(2,0,Bars-1-30,limit,Phase2,Length2,ADX,k,reset);if(reset!=0)return(-1); 
  JADX_Buffer[k]=JADX;  
 }
//----+
return(0);  
}
//----+ �������� ������� JJMASeries (���� JJMASeries.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
#include <JJMASeries.mqh> 
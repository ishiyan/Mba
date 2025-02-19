/*
���  ������  ����������  �������  �������� ���� 
JJMASeries.mqh 
� ����� (����������): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                         JADX.mq4 | 
//|                        Copyright � 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ��������
#property indicator_buffers 1 
//---- ����� ����������
#property indicator_color1 Magenta
//---- ��������� �������������� ������� ����������
#property indicator_level1 0.0
#property indicator_levelcolor SlateBlue
#property indicator_levelstyle 4
//---- ������� ��������� ���������� ��������������������������������������������������������������������������������������������������+
extern int Length      = 15;  // ������� ����������� DX
extern int Phase       =-100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ���������x ��������� +DM � -DM 
extern int Smooth      = 3;   // ������� ����������� �������� ����������
extern int Smooth_Phase=-100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� �������� ����������� 
extern int Ind_Shift   = 0;   // c���� ���������� ����� ��� ������� 
//---- �������������������������������������������������������������������������������������������������������������������������������+
//---- ������������ �������
double Ind_Buffer1[];
//---- ���������� � ��������� ������ 
double pDM,mDM,TRJ,JpDM,JmDM,ADX,JADX;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JADX initialization function                                     | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{ 
//---- 1 �����������q ������ ����������� ��� �����.
SetIndexBuffer(0,Ind_Buffer1);
//---- ��������� �������� ����������, ������� �� ����� ������ �� ������� 
SetIndexEmptyValue(0,0); 
//---- �������������� ����� ������������ ����� 
SetIndexShift (0, Ind_Shift); 
//---- ����� ���������� ������� ���� �������� �����
SetIndexStyle(0,DRAW_LINE);
//---- ����� ��� ���� ������ � ����� ��� ��������. 
IndicatorShortName ("JADX"); 
SetIndexLabel (0,   "JADX"); 
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ���������� 
IndicatorDigits(0);
//---- ��������� ������� �� ������������ �������� ������� ���������� ======================================================================================+ 
if(Phase<-100)       {Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth+ " ����� ������������ -100");}////////////////|
if(Phase> 100)       {Alert("�������� Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Phase+  " ����� ������������  100");}////////////////|
if(Smooth_Phase<-100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+  " ����� ������������ -100");}//|
if(Smooth_Phase> 100){Alert("�������� Smooth_Phase ������ ���� �� -100 �� +100" + " �� ����� ������������ " +Smooth_Phase+  " ����� ������������  100");}//|
if(Length< 1)        {Alert("�������� Length ������ ���� �� ����� 1"     + " �� ����� ������������ " +Length+ " ����� ������������  1");}//////////////////|
if(Smooth< 1)        {Alert("�������� Smooth ������ ���� �� ����� 1"     + " �� ����� ������������ " +Smooth+ " ����� ������������  1");}//////////////////|
//+========================================================================================================================================================+ 
//---- ���������� �������������
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JADX iteration function                                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int reset,MaxBar,MaxBarJ,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//----+ �������� � ������������� ���������� ���������� ������� JJMASeries, nJMAnumber=3(��� ��������� � �������)  
if (counted_bars==0)JJMASeriesReset(3);
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
int limit=Bars-counted_bars-1; MaxBar=Bars-2; MaxBarJ=MaxBar-30; 
if (limit==Bars-1){limit=Bars-2;Ind_Buffer1[Bars-1]=0.0;}

//----+ �������� ���� ���������� ���������� JADX
for(int bar=limit;bar>=0;bar--)
   {
    TRJ=iATR(NULL,Period(),1,bar);     
    pDM=High[bar]-High[bar+1];mDM=Low[bar+1]-Low[bar];
    if (pDM<0)pDM=0.0;
    if (mDM<0)mDM=0.0;
    if (pDM==mDM)  {pDM=0.0; mDM=0.0;}
    if((pDM> mDM)&&(pDM>0.0))mDM=0.0;
    if((pDM< mDM)&&(mDM>0.0))pDM=0.0;
    if((TRJ<0.00001)&&(bar<Bars-40)){pDM=0.0;mDM=0.0;}
    else{pDM=pDM/TRJ;mDM=mDM/TRJ;}
  
    //----+ ��������� � ������� JJMASeries �� ������� 0, ��������� nJMAPhase � nJMALength �� �������� �� ������ ���� �� ���� ��� ���������� � ������� (nJMAdin=0)
    JpDM=JJMASeries(0,0,MaxBar,limit,Phase,Length,pDM,bar,reset);
    //----+ �������� �� ���������� ������ � ���������� ��������
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
     
    //----+ ��������� � ������� JJMASeries �� ������� 1 
    JmDM=JJMASeries(1,0,MaxBar,limit,Phase,Length,mDM,bar,reset);
    //----+ �������� �� ���������� ������ � ���������� ��������
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
    
   
    if (JpDM+JmDM>0.00001) ADX=100*(JpDM-JmDM)/(JpDM+JmDM);else ADX=0.0;
  
    //----+ ����������� ���������� ADX
    //----+ ��������� � ������� JJMASeries �� ������� 2 (� ���� ��������� �������� nJMAMaxBar �������� �� 30  �. �. ��� ��������� JMA �����������) 
    JADX=JJMASeries(2,0,MaxBarJ,limit,Smooth_Phase,Smooth,ADX,bar,reset);
    //----+ �������� �� ���������� ������ � ���������� ��������
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}   
    Ind_Buffer1[bar]=JADX; 
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
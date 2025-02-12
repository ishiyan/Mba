/*
���  ������  ����������  �������  �������� ����� 

SmoothXSeries.mqh
T3Series.mqh
MASeries.mqh
LRMASeries.mqh
JurXSeries.mqh
ParMASeries.mqh
JJMASeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\

Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+X================================================================X+  
//|                                                         X1MA.mq4 | 
//|                        Copyright � 2009,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+   
#property copyright "Copyright � 2009, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � �������� ����
#property indicator_chart_window 
//---- ���������� ������������ �������
#property indicator_buffers 1 
//---- ���� ����������
#property indicator_color1 Red
//---- ������� ��������� ���������� +-------------------------------------------------+
extern int Smooth_Mode = 0;   // ����� ��������� ����������� 0 - JJMA, 1 - JurX,        
                 // 2 - ParMA, 3 - LRMA, 4 - T3, 5 - SMA, 6 - EMA, 7 - SSMA, 8 - LWMA
extern int Length = 11;   // ������� ����������� 
extern int Phase  = 100; // ��������, ������������ � �������� -100 ... +100, 
                                       //������ �� �������� ����������� ��������; 
extern int Shift  = 0;   // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0; /* ����� ���, �� ������� ������������ ������ 
���������� (0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 
6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW, 
11-Heiken Ashi Low, 12-Heiken Ashi High, 13-Heiken Ashi Open, 14-Heiken Ashi Close.) */
//---- +------------------------------------------------------------------------------+
//---- ������
double XMA[]; 
//---- ����������  
bool INIT;
int  StartBar;
//+X================================================================X+   
//| SmoothXSeries() function                                         |
//+X================================================================X+    
//----+ ���������� ������� SmoothXSeries
//----+ ���������� ������� SmoothXSeriesResize 
//----+ ���������� ������� SmoothXSeriesAlert   
#include <SmoothXSeries.mqh> 
//+X================================================================X+   
//| PriceSeries() function                                           |
//+X================================================================X+    
//----+ ���������� ������� PriceSeries
//----+ ���������� ������� PriceSeriesAlert 
#include <PriceSeries.mqh>
//+X================================================================X+   
//| X1MA initialization function                                     |
//+X================================================================X+ 
int init() 
 { 
//----+
   //---- ��������� ����� ����������� ���������� 
   SetIndexStyle(0, DRAW_LINE); 
   //---- ����������� ������ ��� �������� 
   SetIndexBuffer(0, XMA);
   //---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0, 0.0);  
   //---- ��������� ������� �� ������������ �������� ������� ����������
   JJMASeriesAlert (0, "Length", Length);
   JJMASeriesAlert (1, "Phase",   Phase);
   PriceSeriesAlert(Input_Price_Customs);
   //----+ ��������� �������� �������� ���������� �������
           //SmoothXSeries, number = 1(���� ��������� � ������� SmoothXSeries)
   if (SmoothXSeriesResize(1) != 1)
    {
     INIT = false;
     return(0);
    }
   //---- ������������� ����������
   if (Smooth_Mode > 0 && Smooth_Mode < 9) 
                              StartBar = Length;
   else StartBar = 30;
   //---- ��������� ������ ����,
                     //������� � �������� ����� �������������� ��������� 
   SetIndexDrawBegin(0, StartBar); 
   //---- ��������� ������� �������� ����������� ����������
   IndicatorDigits(Digits);
   //---- ���������� �������������
   INIT = true;
   return(0);
//----+ 
 }
//+X================================================================X+  
//| X1MA iteration function                                          | 
//+X================================================================X+   
int start()
 {
//----+ 
   //---- ��������� ������ ���������� ����
   int Bars_ = Bars - 1;
	//---- �������� ���������� ������������� � 
	     //�������� ���������� ����� �� ������������� ��� �������
	if (!INIT || Bars_ <= StartBar)
			                  return(-1); 
	//---- �������� ���������� � ��������� ������
	double Price, xma;
	//---- �������� ����� ���������� � ��������� 
	                           //���������� ��� ����������� �����
	int reset, MaxBar, limit, bar, counted_bars = IndicatorCounted();
	//---- �������� �� ��������� ������
	if (counted_bars < 0)
				    return(-1);
	//---- ��������� ����������� ��� ������ ���� ����������
	if (counted_bars > 0)
				counted_bars--;
	//---- ����������� ������ ������ ������� ����, 
					//������� � �������� ����� �������� �������� ����� ����� 
	limit = Bars_ - counted_bars;
	//---- ����������� ������ ������ ������� ����, 
					 //������� � �������� ����� �������� �������� ���� ����� 
	MaxBar = Bars_;
	
	//----+ �������� ���� ������� ����������
	for(bar = limit; bar >= 0; bar--)
	 {
	  //---- ��������� ��������� �������� �������� ����
	  Price = PriceSeries(Input_Price_Customs, bar);
	  //---- X1MA ����������� ��������� �������� �������� ����, 
	  //---- ��������� � ������� SmoothXSeries �� ������� 0, 
			 //��������� Phase � Length �� �������� �� ������ ���� (din = 0)
	  xma = SmoothXSeries(0, Smooth_Mode, 0, MaxBar, limit, 
	                                     Phase, Length, Price, bar, reset);
	  //---- �������� �� ���������� ������ � ���������� ��������
	  if(reset != 0)
				  return(-1);
				  
	  XMA[bar] = xma;
	  //----
	 }
	//----+ ���������� ���������� �������� ����������
	return(0); 
//----+  
 } 
//+X--------------------+ <<< The End >>> +--------------------X+


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
//|                                                         X2MA.mq4 | 
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
#property indicator_color1 Lime
//---- ������� ��������� ���������� +-------------------------------------------------+
extern int Smooth_Mode1 = 0;   // ����� ��������� 1 ����������� 0 - JJMA, 1 - JurX,        
                 // 2 - ParMA, 3 - LRMA, 4 - T3, 5 - SMA, 6 - EMA, 7 - SSMA, 8 - LWMA
extern int Length1 = 9;   // ������� ����������� 
extern int Phase1  = 100; // ��������, ������������ � �������� -100 ... +100, 
                                       //������ �� �������� ����������� ��������;
extern int Smooth_Mode2 = 0;   // ����� ��������� 2 ����������� 0 - JJMA, 1 - JurX,        
                 // 2 - ParMA, 3 - LRMA, 4 - T3, 5 - SMA, 6 - EMA, 7 - SSMA, 8 - LWMA
extern int Length2 = 5;   // ������� ����������� 
extern int Phase2  = 100; // ��������, ������������ � �������� -100 ... +100, 
                                       //������ �� �������� ����������� ��������;  
extern int Shift  = 0;   // c���� ���������� ����� ��� ������� 
extern int Input_Price_Customs = 0; /* ����� ���, �� ������� ������������ ������ 
���������� (0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 
6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW, 
11-Heiken Ashi Low, 12-Heiken Ashi High, 13-Heiken Ashi Open, 14-Heiken Ashi Close.) */
//---- +------------------------------------------------------------------------------+
//---- ������
double X2MA[];
//---- ����������  
bool INIT;
int  StartBar, StartBar1, StartBar2;
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
//| X2MA initialization function                                     |
//+X================================================================X+ 
int init() 
 { 
//----+
   //---- ��������� ����� ����������� ���������� 
   SetIndexStyle(0, DRAW_LINE); 
   //---- ����������� ������ ��� �������� 
   SetIndexBuffer(0, X2MA);
   //---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0, 0.0); 
   //---- ��������� ������� �� ������������ �������� ������� ����������
   JJMASeriesAlert (0, "Length1", Length1);
   JJMASeriesAlert (1, "Phase1",   Phase1);
   JJMASeriesAlert (0, "Length2", Length2);
   JJMASeriesAlert (1, "Phase2",   Phase2);
   PriceSeriesAlert(Input_Price_Customs);
   //----+ ��������� �������� �������� ���������� �������
           //SmoothXSeries, number = 2(��� ��������� � ������� SmoothXSeries)
   if (SmoothXSeriesResize(2) != 2)
    {
     INIT = false;
     return(0);
    }
   //---- ������������� ����������
   if (Smooth_Mode1 > 0 && Smooth_Mode1 < 9) 
                              StartBar1 = Length1;
   else StartBar1 = 30;
   
   if (Smooth_Mode2 > 0 && Smooth_Mode2 < 9) 
                              StartBar2 = Length2;
   else StartBar2 = 30;
   StartBar = StartBar1 + StartBar2;
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
//| X2MA iteration function                                          | 
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
	double Price, x1ma, x2ma;
	//---- �������� ����� ���������� � ��������� 
	                        //���������� ��� ����������� �����
	int reset, MaxBar1, MaxBar2, limit, 
	                   bar, counted_bars = IndicatorCounted();
	//---- �������� �� ��������� ������
	if (counted_bars < 0)
				    return(-1);
	//---- ��������� ������������ ��� ������ ���� ����������
	if (counted_bars > 0)
				counted_bars--;
	//---- ����������� ������ ������ ������� ����, 
					//������� � �������� ����� �������� �������� ����� ����� 
	limit = Bars_ - counted_bars;
	//---- ����������� ������ ������ ������� ����, 
					 //������� � �������� ����� �������� �������� ���� ����� 
	MaxBar1 = Bars_;
	MaxBar2 = MaxBar1 - StartBar1;
	
	//----+ �������� ���� ������� ����������
	for(bar = limit; bar >= 0; bar--)
	 {
	  //---- ��������� ��������� �������� �������� ����
	  Price = PriceSeries(Input_Price_Customs, bar);
	  //---- X1MA ����������� ��������� �������� �������� ����, 
	  //---- ��������� � ������� SmoothXSeries �� ������� 0, 
			 //��������� Phase � Length �� �������� �� ������ ���� (din = 0)
	  x1ma = SmoothXSeries(0, Smooth_Mode1, 0, MaxBar1, limit, 
	                                     Phase1, Length1, Price, bar, reset);
	  //---- �������� �� ���������� ������ � ���������� ��������
	  if(reset != 0)
				  return(-1);
	  //---- X2MA ����������� ����������� ����������, 
	  //---- ��������� � ������� SmoothXSeries �� ������� 1, 
			 //��������� Phase � Length �� �������� �� ������ ���� (din = 0)
	  x2ma = SmoothXSeries(1, Smooth_Mode2, 0, MaxBar2, limit, 
	                                     Phase2, Length2, x1ma,  bar, reset);
	  //---- �������� �� ���������� ������ � ���������� ��������
	  if(reset != 0)
				  return(-1);
	  //----			  		  
	  X2MA[bar] = x2ma;
	  //----
	 }
	//----+ ���������� ���������� �������� ����������
	return(0); 
//----+  
 } 
//+X--------------------+ <<< The End >>> +--------------------X+


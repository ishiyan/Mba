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
//|                                                        XMACD.mq4 | 
//|                        Copyright � 2009,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+   
#property copyright "Copyright � 2009, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property  indicator_separate_window 
//---- ���������� ������������ �������
#property indicator_buffers 2 
//---- ����� ����������
#property  indicator_color1  Blue
#property  indicator_color2  Magenta
//---- ������� ����� ���������
#property  indicator_width1  2
//---- ������� ��������� ����������
extern int MACD_Mode = 0;  // ����� ��������� ����������� ��� MACD 0 - JJMA, 1 - JurX,        
                 // 2 - ParMA, 3 - LRMA, 4 - T3, 5 - SMA, 6 - EMA, 7 - SSMA, 8 - LWMA
extern int MACD_Phase = 100;
extern int FastXMA = 12;
extern int SlowXMA = 26;
extern int Signal_Mode = 0;  // ����� ��������� ����������� ��� ���������� ����� 
  //0 - JJMA, 1 - JurX, 2 - ParMA, 3 - LRMA, 4 - T3, 5 - SMA, 6 - EMA, 7 - SSMA, 8 - LWMA
extern int Signal_Phase = 100;
extern int SignalXMA = 9;
extern int Input_Price_Customs = 0; /* ����� ���, �� ������� ������������ ������ 
���������� (0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 
6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW, 
11-Heiken Ashi Low, 12-Heiken Ashi High, 13-Heiken Ashi Open, 14-Heiken Ashi Close.) */
//---- ������������ ������
double     XMacdBuffer[];
double     XSignalBuffer[];
//---- ���������� 
bool   INIT;
int    StartBar, StartBar1, StartBar2;
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
//| XMACD indicator initialization function                          |
//+X================================================================X+ 
int init()
  {
//----+
   //---- ��������� ����� ����������� ���������� 
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_LINE);
   //---- ��������� ������� �������� (���������� ������ 
        //����� ���������� �����) ��� ������������ �������� ���������� 
   IndicatorDigits(Digits + 1);
   //---- ����������� ������� ��� �������� 
   SetIndexBuffer(0, XMacdBuffer);
   SetIndexBuffer(1, XSignalBuffer);
   //---- ����� ��� ���� ������ � ����� ��� ��������
   IndicatorShortName(StringConcatenate
            ("XMACD(", FastXMA, ",", SlowXMA, ",", SignalXMA, ")"));
   SetIndexLabel(0, "XMACD");
   SetIndexLabel(1, "XSignal");
   //---- ��������� ������� �� ������������ �������� ������� ����������
   JJMASeriesAlert (0, "FastXMA", FastXMA);
   JJMASeriesAlert (0, "SlowXMA", SlowXMA);
   JJMASeriesAlert (0, "SignalXMA", SignalXMA);
   //----
   JJMASeriesAlert (1, "MACD_Phase", MACD_Phase);  
   JJMASeriesAlert (1, "Signal_Phase", Signal_Phase);
   PriceSeriesAlert(Input_Price_Customs);
   //---- ��������� �������� �������� ���������� �������
           //SmoothXSeries, number = 3(��� ��������� � ������� SmoothXSeries)
   if (SmoothXSeriesResize(3) != 3)
    {
     INIT = false;
     return(0);
    }
   //---- ������������� ���������� 
   if (MACD_Mode > 0 && MACD_Mode < 9) 
                            StartBar1 = MathMax( FastXMA, SlowXMA);
   else StartBar1 = 30;
   //----
   if (Signal_Mode > 0 && Signal_Mode < 9) 
                          StartBar2 = SignalXMA;
   else StartBar2 = 30;
   //----
   StartBar = StartBar1 + StartBar2;
   //----
   SetIndexDrawBegin(0, StartBar1);
   SetIndexDrawBegin(1, StartBar);
   //---- ���������� �������������
   INIT = true;
   return(0);
//----+
  }
//+X================================================================X+ 
//| XMACD indicator iteration function                               |
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
	double Price, FastXMA_, SlowXMA_, XMACD, SignalXMA_;
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
	  //---- FastXMA ����������� ��������� �������� �������� ����, 
	  //---- ��������� � ������� SmoothXSeries �� ������� 0, 
			 //��������� Phase � Length �� �������� �� ������ ���� (din = 0)
	  FastXMA_ = SmoothXSeries(0, MACD_Mode, 0, MaxBar1, limit, 
	                              MACD_Phase, FastXMA, Price, bar, reset);
	  //---- �������� �� ���������� ������ � ���������� ��������
	  if(reset != 0)
				  return(-1);
	  //---- SlowXMA ����������� ��������� �������� �������� ����, 
	  //---- ��������� � ������� SmoothXSeries �� ������� 1, 
			 //��������� Phase � Length �� �������� �� ������ ���� (din = 0)
	  SlowXMA_ = SmoothXSeries(1, MACD_Mode, 0, MaxBar1, limit, 
	                             MACD_Phase, SlowXMA, Price,  bar, reset);                       
	  //---- �������� �� ���������� ������ � ���������� ��������
	  if(reset != 0)
				  return(-1);
	  //----			  
	  if(bar < MaxBar2) 
	         XMACD = FastXMA_ - SlowXMA_;
	  
	  //---- SignalXMA ����������� ���������� ��������� XMACD, 
	  //---- ��������� � ������� SmoothXSeries �� ������� 2, 
			 //��������� Phase � Length �� �������� �� ������ ���� (din = 0)
	  SignalXMA_ = SmoothXSeries(2, Signal_Mode, 0, MaxBar2, limit, 
	                         Signal_Phase, SignalXMA, XMACD,  bar, reset);            
	  //---- �������� �� ���������� ������ � ���������� ��������
	  if(reset != 0)
				  return(-1);
	  //----
	  XMacdBuffer[bar] = XMACD;
	  XSignalBuffer[bar] = SignalXMA_;		  
    }
   return(0);
  
//----+
  }
//+X----------------------+ <<< The End >>> +-----------------------X+
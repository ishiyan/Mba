//+------------------------------------------------------------------+
//|															  EfficencyRatio.mq4 |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//---- input parameters
extern int PERIOD = 21;

//---- indicator buffers
double Buffer1[],
		 Buffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicator line
	IndicatorBuffers(2);
	IndicatorShortName("EfficencyRatio ("+PERIOD+")");
	SetIndexStyle(0,DRAW_HISTOGRAM);
	SetIndexStyle(1,DRAW_HISTOGRAM);
	SetIndexBuffer(0,Buffer1);
	SetIndexBuffer(1,Buffer2);
	SetIndexLabel(0,"EfficencyRatio ("+PERIOD+")");
	SetIndexLabel(1,"EfficencyRatio ("+PERIOD+")");
//----
	return(0);
}

//+------------------------------------------------------------------+
double EfficencyRatio(int i = 0)
{
	double signal = MathAbs(Close[i] - Close[i+PERIOD]),
			 noise  = 0.0;

	for(int n = 0; n < PERIOD; n++)
		noise += MathAbs(Close[i+n] - Close[i+n+1]);

	if(noise>0.0)	return(signal/noise);
	else				return(EMPTY_VALUE);
}

//+------------------------------------------------------------------+
int start()
{
//	int tickStart = GetTickCount();
//----
	int counted = IndicatorCounted(),
		 start = Bars-1-counted-PERIOD;

	if(!counted)
	{
		ArrayInitialize(Buffer1,0.0);
		ArrayInitialize(Buffer2,0.0);
	}

	for(int i = MathMax(0,start); i >= 0; i--)
	{
		double x = EfficencyRatio(i);

		if(Close[i]-Close[i+PERIOD] > 0.0)
			Buffer1[i] = EfficencyRatio(i);
		else
			Buffer2[i] = EfficencyRatio(i);
	}
//----
//	Print("Indicator calculation took "+(GetTickCount()-tickStart)+" milliseconds.");
	return(0);	
}



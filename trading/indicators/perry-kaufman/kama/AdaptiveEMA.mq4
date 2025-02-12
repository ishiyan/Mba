//+------------------------------------------------------------------+
//|																  AdaptiveEMA.mq4 |
//| Several types of adaptive moving averages:								|
//| TYPE=1: FRAMA (Fractal Adaptive Moving Average, John Ehlers)		|
//| TYPE=2:	KAMA  (Kaufman's Adaptive Moving Average)						|
//| TYPE=3:	VIDYA (Variable Index Dynamic Average)							|
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//---- input parameters
extern int		TYPE		=  2,	// {1=FRAMA, 2=KAMA, 3=VIDYA}
		 			PERIOD	= 16,
		 			FAST		=  8,
					SLOW		= 21;

//---- indicator buffers
double Buffer1[],
		 Buffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
	string name;
	switch(TYPE)
	{
		case 1:	name = "FRAMA ("+PERIOD+")";	break;
		case 2:	name = "KAMA ("+PERIOD+","+FAST+"-"+SLOW+")";	break;
		case 3:	name = "VIDYA ("+PERIOD+","+FAST+"/"+SLOW+")";	break;
		default:	name = "EMA ("+PERIOD+")";		break;
	}

//---- indicator line
	IndicatorBuffers(2);
	IndicatorShortName(name);
	SetIndexStyle(0,DRAW_LINE);
	SetIndexStyle(1,DRAW_LINE);
	SetIndexBuffer(0,Buffer1);
	SetIndexBuffer(1,Buffer2);
	SetIndexLabel(0,name);
	SetIndexLabel(1,name);
//----
	return(0);
}

//+------------------------------------------------------------------+
double FractalDimension(int i)
{
	double	N3 = (High[iHighest(NULL,0,MODE_HIGH,PERIOD,i)]
				     -Low [iLowest (NULL,0,MODE_LOW,PERIOD,i)])/PERIOD,
			 	N1 = (High[iHighest(NULL,0,MODE_HIGH,PERIOD/2,i)]
				     -Low [iLowest (NULL,0,MODE_LOW, PERIOD/2,i)]) / (PERIOD/2),
			 	N2 = (High[iHighest(NULL,0,MODE_HIGH,PERIOD/2,i+PERIOD/2)]
				     -Low [iLowest (NULL,0,MODE_LOW, PERIOD/2,i+PERIOD/2)]) / (PERIOD/2);

	if(N1 > 0 && N2 > 0 && N3 > 0)
		return((MathLog(N1+N2) - MathLog(N3)) / MathLog(2.0));

	return(0);
}

//+------------------------------------------------------------------+
double EfficencyRatio(int i = 0)
{
	double	signal = MathAbs(Close[i] - Close[i+PERIOD]),
				noise  = 0.0;

	for(int n = 0; n < PERIOD; n++)
		noise += MathAbs(Close[i+n] - Close[i+n+1]);

	if(noise>0.0)	return(signal/noise);
	else				return(EMPTY_VALUE);
}

//+------------------------------------------------------------------+
double StdDevRatio(int i = 0)
{
	double shortStdDev = iStdDev(NULL,0,FAST,0,MODE_EMA,PRICE_CLOSE,i),
			 longStdDev  = iStdDev(NULL,0,SLOW, 0,MODE_EMA,PRICE_CLOSE,i);

	return(shortStdDev/longStdDev);
}

//+------------------------------------------------------------------+
int start()
{
//----
	double emaWeight = 2.0 / (PERIOD+1.0);

	int counted = IndicatorCounted(),
		 start = Bars-1-counted-MathMax(SLOW,PERIOD);

	if(!counted)
	{
		Buffer1[start+1] = Close[start+1];
		Buffer2[start+1] = Close[start+1];
	}

	if(start<0)
		start=0;

	for(int i = MathMax(0,start); i >= 0; i--)
	{
		double adaptiveWeight;
		switch(TYPE)
		{
			case 1:	// Fractal Adaptive Moving Average (John Ehlers)
			{
				adaptiveWeight = MathExp(-4.6 * (FractalDimension(i)-1.0));
				break;
			}

			case 2:	// Kaufman's Adaptive Moving Average
			{
				double slowestWeight = 2.0 / (SLOW+1.0),
						 fastestWeight = 2.0 / (FAST+1.0);
				adaptiveWeight = EfficencyRatio(i)*fastestWeight + slowestWeight;
				adaptiveWeight *= adaptiveWeight;
				break;
			}

			case 3:	// Variable Index Dynamic Average
			{
				adaptiveWeight = StdDevRatio(i)*emaWeight;
				break;
			}

			default:	// Exponential Moving Average
				adaptiveWeight = emaWeight;
		}

		Buffer1[i] = adaptiveWeight*Close[i] + (1.0-adaptiveWeight)*Buffer1[i+1];
		if(Buffer1[i] < Buffer1[i+1])
		{
			Buffer2[i]   = Buffer1[i];
			Buffer2[i+1] = Buffer1[i+1];
		}
		else
			Buffer2[i]   = EMPTY_VALUE;

	}

	return(0);	
}


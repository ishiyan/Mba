//+------------------------------------------------------------------+
//|                                                StochasticRVI.mq4 |
//|                                                                  |
//| Stochastic RVI                                                   |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
#property copyright "Coded by Witold Wozniak"
#property link      "www.mqlsoft.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

#property indicator_level1 0
#property indicator_minimum -1
#property indicator_maximum 1

double StocRVI[];
double Trigger[];
double RVI[];
double Value1[];
double Value2[];
double Value3[];

extern int Length2 = 8;
int buffers = 0;
int drawBegin = 0;

int init() {
    drawBegin = Length2;
    initBuffer(StocRVI, "Stochastic RVI", DRAW_LINE);
    initBuffer(Trigger, "Trigger", DRAW_LINE);
    initBuffer(RVI);
    initBuffer(Value1);
    initBuffer(Value2);
    initBuffer(Value3);
    IndicatorBuffers(buffers);
    IndicatorShortName("Stochastic RVI [" + Length2 + "]");
    return (0);
}

int start() {
    if (Bars <= drawBegin) return (0);
    int countedBars = IndicatorCounted();
    if (countedBars < 0) return (-1);
    if (countedBars > 0) countedBars--;
    int s, limit = Bars - countedBars - 1;
    for (s = limit; s >= 0; s--) {
        Value1[s] = ((Close[s] - Open[s]) + 
            2.0 * (Close[s + 1] - Open[s + 1]) + 
            2.0 * (Close[s + 2] - Open[s + 2]) + 
            (Close[s + 3] - Open[s + 3])) / 6.0;
        Value2[s] = ((High[s] - Low[s]) + 
            2.0 * (High[s + 1] - Low[s + 1]) + 
            2.0 * (High[s + 2] - Low[s + 2]) + 
            (High[s + 3] - Low[s + 3])) / 6.0;
        double Num = 0.0;
        double Denom = 0.0;
        for (int count = 0; count < Length2; count++) {
            Num += Value1[s + count];
            Denom += Value2[s + count];
        }        
        if (Denom != 0.0) {
            RVI[s] = Num / Denom;
        } else {
            RVI[s] = 0.0;
        }
        double rvi = RVI[s];
        double hh = rvi, ll = rvi;
        for (int i = 0; i < Length2; i++) {
            double tmp = RVI[s + i];
            hh = MathMax(hh, tmp);
            ll = MathMin(ll, tmp);
        }
        Value3[s] = 0.0;
        if (hh != ll) {
            Value3[s] = (rvi - ll) / (hh - ll);
        }
        StocRVI[s] = (4.0 * Value3[s] + 3.0 * Value3[s + 1] + 2.0 * Value3[s + 2] + Value3[s + 3]) / 10.0;
        StocRVI[s] = 2.0 * (StocRVI[s] - 0.5);
        Trigger[s] = 0.96 * (StocRVI[s + 1] + 0.02);        
    }
    return (0);   
}

void initBuffer(double array[], string label = "", int type = DRAW_NONE, int arrow = 0, int style = EMPTY, int width = EMPTY, color clr = CLR_NONE) {
    SetIndexBuffer(buffers, array);
    SetIndexLabel(buffers, label);
    SetIndexEmptyValue(buffers, EMPTY_VALUE);
    SetIndexDrawBegin(buffers, drawBegin);
    SetIndexShift(buffers, 0);
    SetIndexStyle(buffers, type, style, width);
    SetIndexArrow(buffers, arrow);
    buffers++;
}
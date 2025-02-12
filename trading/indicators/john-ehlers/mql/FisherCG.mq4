//+------------------------------------------------------------------+
//|                                                     FisherCG.mq4 |
//|                                                                  |
//| Fisher Stochastic CG Oscillator                                  |
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

double FisherCG[];
double Trigger[];
double CG[];
double Value1[];
double Value2[];

extern int Length = 8;
int buffers = 0;
int drawBegin = 0;

int init() {
    drawBegin = Length;
    initBuffer(FisherCG, "Fisher CG", DRAW_LINE);
    initBuffer(Trigger, "Trigger", DRAW_LINE);
    initBuffer(CG);
    initBuffer(Value1);
    initBuffer(Value2);    
    IndicatorBuffers(buffers);
    IndicatorShortName("Fisher CG [" + Length + "]");
    return (0);
}

int start() {
    if (Bars <= drawBegin) return (0);
    int countedBars = IndicatorCounted();
    if (countedBars < 0) return (-1);
    if (countedBars > 0) countedBars--;
    int s, limit = Bars - countedBars - 1;
    for (s = limit; s >= 0; s--) {
        double Num = 0.0;
        double Denom = 0.0;
        for (int count = 0; count < Length; count++) {
            Num += (1.0 + count) * P(s + count);
            Denom += P(s + count);
        }
        if (Denom != 0.0) {
            CG[s] = -Num / Denom + (Length + 1.0) / 2.0;
        } else {
            CG[s] = 0.0;
        }
        double hh = CG[s], ll = CG[s];
        for (int i = 0; i < Length; i++) {
            double tmp = CG[s + i];
            hh = MathMax(hh, tmp);
            ll = MathMin(ll, tmp);
        }
        Value1[s] = 0.0;
        if (hh != ll) {
            Value1[s] = (CG[s] - ll) / (hh - ll);
        }
        Value2[s] = (4.0 * Value1[s] + 3.0 * Value1[s + 1] + 2.0 * Value1[s + 2] + Value1[s + 3]) / 10.0;
        FisherCG[s] = 0.5 * MathLog((1.0 + 1.98 * (Value2[s] - 0.5)) / (1.0 - 1.98 * (Value2[s] - 0.5)));
        Trigger[s] = FisherCG[s + 1];
    }
    return (0);   
}

double P(int index) {
    return ((High[index] + Low[index]) / 2.0);
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
//+------------------------------------------------------------------+
//|                                                   AdaptiveCG.mq4 |
//|                                                                  |
//| Adaptive CG Oscillator                                           |
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

double CG[];
double Trigger[];

extern double Alpha = 0.07;
int buffers = 0;
int drawBegin = 0;

int init() {
    drawBegin = 30;
    initBuffer(CG, "CG", DRAW_LINE);
    initBuffer(Trigger, "Trigger", DRAW_LINE);
    IndicatorBuffers(buffers);
    IndicatorShortName("Adaptive CG [" + DoubleToStr(Alpha, 2) + "]");
    return (0);
}

int start() {
    if (Bars <= drawBegin) return (0);
    int countedBars = IndicatorCounted();
    if (countedBars < 0) return (-1);
    if (countedBars > 0) countedBars--;
    int s, limit = Bars - countedBars - 1;
    for (s = limit; s >= 0; s--) {
        double period = iCustom(0, 0, "CyclePeriod", Alpha, 0, s);
        int intPeriod = MathFloor(period / 2.0);
        double Num = 0.0;
        double Denom = 0.0;
        for (int count = 0; count < intPeriod; count++) {
            Num += (1.0 + count) * P(s + count);
            Denom += P(s + count);
        }
        if (Denom != 0.0) {
            CG[s] = -Num / Denom + (intPeriod + 1.0) / 2.0;
        } else {
            CG[s] = 0.0;
        }
        Trigger[s] = CG[s + 1];        
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
//+------------------------------------------------------------------+
//|                                             FisherCyberCycle.mq4 |
//|                                                                  |
//| Fisher Stochastic Cyber Cycle                                    |
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

double FisherCC[];
double Trigger[];
double Smooth[];
double Cycle[];
double Value1[];

extern double Alpha4 = 0.07;
extern int Length4 = 8;
int buffers = 0;
int drawBegin = 0;

int init() {
    drawBegin = Length4;
    initBuffer(FisherCC, "Fisher Cyber Cycle", DRAW_LINE);
    initBuffer(Trigger, "Trigger", DRAW_LINE);
    initBuffer(Smooth);
    initBuffer(Cycle);
    initBuffer(Value1);
    IndicatorBuffers(buffers);
    IndicatorShortName("Fisher Cyber Cycle [" + DoubleToStr(Alpha4, 2) + ", " + Length4 + "]");
    return (0);
}

int start() {
    if (Bars <= drawBegin) return (0);
    int countedBars = IndicatorCounted();
    if (countedBars < 0) return (-1);
    if (countedBars > 0) countedBars--;
    int s, limit = Bars - countedBars - 1;
    for (s = limit; s >= 0; s--) {
        Smooth[s] = (P(s) + 2.0 * P(s + 1) + 2.0 * P(s + 2) + P(s + 3)) / 6.0;
        Cycle[s] = (1.0 - 0.5 * Alpha4) * (1.0 - 0.5 * Alpha4) * (Smooth[s] - 2.0 * Smooth[s + 1] + Smooth[s + 2])
            + 2.0 * (1.0 - Alpha4) * Cycle[s + 1]
            - (1.0 - Alpha4) * (1.0 - Alpha4) * Cycle[s + 2];
        if (s > Bars - 8) {
            Cycle[s] = (P(s) - 2.0 * P(s + 1) + P(s + 2)) / 4.0;
        }
        double hh = Cycle[s], ll = Cycle[s];
        for (int i = 0; i < Length4; i++) {
            double tmp = Cycle[s + i];
            hh = MathMax(hh, tmp);
            ll = MathMin(ll, tmp);
        }
        Value1[s] = 0.0;
        if (hh != ll) {
            Value1[s] = (Cycle[s] - ll) / (hh - ll);
        }
        FisherCC[s] = (4.0 * Value1[s] + 3.0 * Value1[s + 1] + 2.0 * Value1[s + 2] + Value1[s + 3]) / 10.0;
        FisherCC[s] = 0.5 * MathLog((1.0 + 1.98 * (FisherCC[s] - 0.5)) / (1.0 - 1.98 * (FisherCC[s] - 0.5)));
        Trigger[s] = FisherCC[s + 1];
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
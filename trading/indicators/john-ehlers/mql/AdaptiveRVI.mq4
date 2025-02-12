//+------------------------------------------------------------------+
//|                                                  AdaptiveRVI.mq4 |
//|                                                                  |
//| Adaptive Relative Vigor Index                                    |
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

double RVI[];
double Trigger[];
double Value1[];
double Value2[];

extern double Alpha = 0.07;
int buffers = 0;
int drawBegin = 0;

int init() {
    drawBegin = 30;
    initBuffer(RVI, "RVI", DRAW_LINE);
    initBuffer(Trigger, "Trigger", DRAW_LINE);
    initBuffer(Value1);
    initBuffer(Value2);
    IndicatorBuffers(buffers);
    IndicatorShortName("Adaptive RVI [" + DoubleToStr(Alpha, 2) + "]");
    return (0);
}

int start() {
    if (Bars <= drawBegin) return (0);
    int countedBars = IndicatorCounted();
    if (countedBars < 0) return (-1);
    if (countedBars > 0) countedBars--;
    int s, limit = Bars - countedBars - 1;
    for (s = limit; s >= 0; s--) {
        double period0 = iCustom(0, 0, "CyclePeriod", Alpha, 0, s);
        double period1 = iCustom(0, 0, "CyclePeriod", Alpha, 0, s + 1);
        double period3 = iCustom(0, 0, "CyclePeriod", Alpha, 0, s + 3);
        double period4 = iCustom(0, 0, "CyclePeriod", Alpha, 0, s + 4);
        int Length = MathFloor((4.0 * period0 + 3.0 * period1 + 2.0 * period3 + period4) / 20.0);    
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
        for (int count = 0; count < Length; count++) {
            Num += Value1[s + count];
            Denom += Value2[s + count];
        }        
        if (Denom != 0.0) {
            RVI[s] = Num / Denom;
        } else {
            RVI[s] = 0.0;
        }
        Trigger[s] = RVI[s + 1];        
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
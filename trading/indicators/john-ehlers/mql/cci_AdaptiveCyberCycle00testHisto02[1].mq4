//+------------------------------------------------------------------+
//|                                           AdaptiveCyberCycle.mq4 |
//|                                                                  |
//| Adaptive Cyber Cycle                                             |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
//mod cci
#property copyright "Coded by Witold Wozniak"
#property link      "www.mqlsoft.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

#property indicator_level1     100
#property indicator_level2     -100
#property indicator_levelcolor DarkSlateGray

double Cycle[];
double Trigger[];
double Smooth[];

//extern int CCI_Period      = 14;
extern int CCI_Price       = 5;

extern double Alpha = 0.07;
int buffers = 0;
int drawBegin = 0;

int init() {
    drawBegin = 8;      
    initBuffer(Trigger, "Trigger", DRAW_HISTOGRAM);
    initBuffer(Cycle, "Cycle", DRAW_HISTOGRAM);
    initBuffer(Smooth);
    IndicatorBuffers(buffers);
    IndicatorShortName("cci  Adaptive Cyber Cycle  [" + DoubleToStr(Alpha, 2) + "]");
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
        double period = iCustom(0, 0, "CyclePeriod", Alpha, 0, s);
//        double alpha1 = 2.0 / (period + 1.0);
        Cycle[s] = iCCI(NULL,0,period,CCI_Price,s);           
        if (s > Bars - 8) {
            Cycle[s] = (P(s) - 2.0 * P(s + 1) + P(s + 2)) / 4.0;
        }
        Trigger[s] = Cycle[s + 1];
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
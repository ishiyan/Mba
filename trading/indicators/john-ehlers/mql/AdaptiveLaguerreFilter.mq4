//+------------------------------------------------------------------+
//|   AdaptiveLaguerreFilter.mq4
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 DarkGray
#property indicator_width1 2
#include <stdlib.mqh>
extern int LookBack = 20;
extern int Median = 5;
extern int PriceType = PRICE_MEDIAN;
int ZeroCount, i,j;
double Price,HH,LL, alpha;
double Filter[], Diff[], L0[], L1[], L2[], L3[], sortDiff[];
//+------------------------------------------------------------------+
int init() {
   IndicatorBuffers(6);
   SetIndexBuffer(0,Filter);   SetIndexStyle(0,DRAW_LINE);   SetIndexLabel(0,"ALF");
   SetIndexBuffer(1,Diff);   SetIndexBuffer(2,L0);   SetIndexBuffer(3,L1);   SetIndexBuffer(4,L2);   SetIndexBuffer(5,L3);
   ArrayResize(sortDiff,Median);
   return (0);
}
//+------------------------------------------------------------------+
int start()  {
   int countedBars = IndicatorCounted(), limit = Bars-countedBars-1;
   for (i=limit;i>=0;i--)   {
      Price = iMA(NULL,0,1,0,MODE_SMA,PriceType,i);
      Diff[i] = MathAbs(Price - Filter[i+1]);
      HH = Diff[i];    LL = Diff[i];
      for (j=0;j<LookBack;j++)   {
        if (Diff[i+j] > HH)      HH = Diff[i+j];
        if (Diff[i+j] < LL)      LL = Diff[i+j];
      }
      if (!CompareDoubles(HH-LL,0))     {
        for (int j=0;j<Median;j++)      sortDiff[j] = (Diff[i+j] - LL) / (HH - LL);
        ArraySort(sortDiff,WHOLE_ARRAY,0,MODE_ASCEND);
        if (MathMod(Median,2.0) != 0)   alpha = sortDiff[Median/2];         
        else                            alpha = (sortDiff[Median/2]+sortDiff[(Median/2)-1])/2;
      }
      L0[i] = alpha*Price + (1 - alpha)*L0[i+1];
      L1[i] = -(1 - alpha)*L0[i] + L0[i+1] + (1 - alpha)*L1[i+1];
      L2[i] = -(1 - alpha)*L1[i] + L1[i+1] + (1 - alpha)*L2[i+1];
      L3[i] = -(1 - alpha)*L2[i] + L2[i+1] + (1 - alpha)*L3[i+1];
      Filter[i] = (L0[i] + 2.0 * L1[i] + 2.0 * L2[i] + L3[i]) / 6.0;
   }
   return (0);   
}




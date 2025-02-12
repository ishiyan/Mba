//+------------------------------------------------------------------+
//|                                             Fractal dimesion.mq4 |
//|                                                           mladen |
//|                              from Mark Jurik's tradestation code |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DimGray
#property indicator_color2 Red
#property indicator_style1 STYLE_DOT

//
//
//
//
//

extern int FDSize   = 20;
extern int FDCount  =  5;
extern int FDSmooth =  5;
extern int FDPrice  = PRICE_CLOSE;

//
//
//
//
//

double FdBuffer[];
double ZlBuffer[];
double tmpBuffer[];
double smlSumm[];
double smlRange[];


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(5);
      SetIndexBuffer(0,ZlBuffer); SetIndexLabel(0,NULL);
      SetIndexBuffer(1,FdBuffer);
      SetIndexBuffer(2,smlSumm);
      SetIndexBuffer(3,smlRange);
      SetIndexBuffer(4,tmpBuffer);
      
      //
      //
      //
      //
      //
      
         FDCount  = MathMax(FDCount,2);
         FDSmooth = MathMax(FDSmooth,1);
         FDSize   = MathMax(FDSize,2);
         
      //
      //
      //
      //
      //
               
   SetIndexEmptyValue(2,0.00);   
   SetIndexEmptyValue(3,0.00);
   IndicatorShortName("Fractal dimension ("+FDSize+","+FDCount+","+FDSmooth+")");
   return(0);
}
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int    counted_bars=IndicatorCounted();
   int    i,limit;
   
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
         limit = Bars-counted_bars;

   //
   //
   //
   //
   //
            
   for (i=limit; i>=0; i--) tmpBuffer[i] = iFD(FDSize,FDCount,i);
   for (i=limit; i>=0; i--)
      {  
         ZlBuffer[i] = 1.5;    
         FdBuffer[i] = iMAOnArray(tmpBuffer,0,FDSmooth,0,MODE_SMA,i);
      }         
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double iFD(int size, int count,int i)
{
   double bigRange = 0.00;
   int    window1  = size*(count-1);
   int    window2  = size* count;
   double nLog     = MathLog(count);

   
   
   smlRange[i] = MathMax(Close[size+i],maxHigh(size,i))
               - MathMin(Close[size+i],minLow(size,i));

   //
   //
   //
   //
   //

   smlSumm[i] = smlSumm[i+1]+smlRange[i];               
   if ((Bars-i)>window1)
   {
         bigRange = MathMax(Close[window2+i],maxHigh(window2,i))
                  - MathMin(Close[window2+i],minLow(window2,i));

         smlSumm[i] -= smlRange[window1+i];
         return( 2 - MathLog(bigRange/(smlSumm[i]/window1))/nLog);
   }
   else return(1.5);
}

//
//
//
//
//

double minLow(int period,int shift)
{
   double minValue = Low[shift];
            for (int i=1; i<period; i++) minValue = MathMin(minValue,Low[shift+i]);
   return(minValue);
}
double maxHigh(int period,int shift)
{
   double maxValue = High[shift];
            for (int i=1; i<period; i++) maxValue = MathMax(maxValue,High[shift+i]);
   return(maxValue);
}
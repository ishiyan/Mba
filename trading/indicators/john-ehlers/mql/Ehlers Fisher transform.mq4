//+----------------------------------------------------------+
//|                              Ehlers fisher transform.mq4 |
//|                                                   mladen |
//+----------------------------------------------------------+
#property  copyright "mladen"
#property  link      "mladenfx@gmail.com"

#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  DimGray
#property  indicator_color2  YellowGreen
#property  indicator_width1  2
#property  indicator_style2  STYLE_DOT

//
//
//
//
//
 
extern int  period         = 10;
extern int  PriceType      = PRICE_MEDIAN;
extern bool showSignalLine = true;

//
//
//
//
//

double buffer1[];
double buffer2[];
double Prices[];
double Values[];

   
//+----------------------------------------------------------+
//|                                                          |
//+----------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(4);
      SetIndexBuffer(0,buffer1);
      SetIndexBuffer(1,buffer2);
      SetIndexBuffer(2,Prices);
      SetIndexBuffer(3,Values);
   IndicatorShortName("Ehlers\' Fisher transform ("+period+")");
   return(0);
}


//+----------------------------------------------------------+
//|                                                          |
//+----------------------------------------------------------+
//
//
//
//
//

int start()
{
   int  counted_bars=IndicatorCounted();
   int  i,limit;

   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
           limit = Bars-counted_bars;

   //
   //
   //
   //
   //
         
   for(i=limit; i>=0; i--)
   {  
      Prices[i] = iMA(NULL,0,1,0,MODE_SMA,PriceType,i);
      
      //
      //
      //
      //
      //
                  
         double MaxH = Prices[ArrayMaximum(Prices,period,i)];
         double MinL = Prices[ArrayMinimum(Prices,period,i)];
         if (MaxH!=MinL)
               Values[i] = 0.33*2*((Prices[i]-MinL)/(MaxH-MinL)-0.5)+0.67*Values[i+1];
         else  Values[i] = 0.00;
               Values[i] = MathMin(MathMax(Values[i],-0.999),0.999); 

      // 
      //
      //
      //
      //

      buffer1[i] = 0.5*MathLog((1+Values[i])/(1-Values[i]))+0.5*buffer1[i+1];
      if (showSignalLine)
            buffer2[i] = buffer1[i+1];
   }
   return(0);
}
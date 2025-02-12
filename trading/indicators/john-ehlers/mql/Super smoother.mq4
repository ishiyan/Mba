//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  Orange
#property indicator_width1  2

//
//
//
//
//

extern int Price  =  PRICE_CLOSE;
double ssm[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define Pi 3.14159265358979323846264338327950288
double c1,c2,c3;
int init()
{
   SetIndexBuffer(0,ssm);
      double a1 = MathExp(-1.414*Pi/10.0);
      double b1 = 2.0*a1*MathCos(1.414*Pi/10.0);
             c2 = b1;
             c3 = -a1*a1;
             c1 = 1.0 - c2 - c3;
   IndicatorShortName ("roofing filter");
   return(0);
}
int deinit() { return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double work[][1];
#define _price 0

int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (ArrayRange(work,0)!= Bars) ArrayResize(work,Bars);

   //
   //
   //
   //
   //
   //

   for(i=limit, r =Bars-i-1; i >= 0; i--,r++)
   {
      work[r][_price] = iMA(NULL,0,1,0,MODE_SMA,Price,i);
      ssm[i] = c1*(work[r][_price]+work[r-1][_price])/2.0 + c2*ssm[i+1] + c3*ssm[i+2];
   }         
   return(0);
}
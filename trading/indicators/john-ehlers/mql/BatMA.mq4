//+------------------------------------------------------------------+
//|                                        Custom Moving Average.mq4 |
//|                      Copyright � 2004, MetaQuotes Software Corp. |
//|                      Copyright � 2008, YUBA                      |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2004, MetaQuotes Software Corp.,Copyright � 2008, YUBA"
#property link      "http://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
extern int MA_Period=13;
extern int MA_Shift=0;
extern int MA_Method=4;
//---- indicator buffers
double ExtMapBuffer[], pr;
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name;
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,MA_Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=13;
   draw_begin=MA_Period-1;
//---- indicator short name
   switch(MA_Method)
     {
      case 1 : short_name="EMA(";  draw_begin=0; break;
      case 2 : short_name="SMMA("; break;
      case 3 : short_name="LWMA("; break;
      case 4 : short_name="BatEMA("; break;
      default :
         MA_Method=1;
         short_name="EMA(";
     }
   IndicatorShortName(short_name+MA_Period+")");
   SetIndexDrawBegin(0,draw_begin);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
//----
   switch(MA_Method)
     {
      case 0 : sma();  break;
      case 1 : ema();  break;
      case 2 : smma(); break;
      case 3 : lwma(); break;
      case 4 : pr=MathSqrt(2.0/(1.0+MA_Period));
               BatMa(pr);
               
     }
   
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma()
  {
   double sum=0;
   int    i,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<MA_Period;i++,pos--)
      sum+=Close[pos];
//---- main calculation loop
   while(pos>=0)
     {
      sum+=Close[pos];
      ExtMapBuffer[pos]=sum/MA_Period;
	   sum-=Close[pos+MA_Period-1];
 	   pos--;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer[Bars-i]=0;
  }
//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
void ema()
  {
   double pr=2.0/(MA_Period+1),Y;
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
//---- main calculation loop
   while(pos>=0)
     {
      if(pos==Bars-2) ExtMapBuffer[pos+1]=Close[pos+1];
      
      ExtMapBuffer[pos]=Close[pos]*pr+ExtMapBuffer[pos+1]*(1-pr);
 	   pos--;
     }
  }
//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
void smma()
  {
   double sum=0;
   int    i,k,pos=Bars-ExtCountedBars+1;
//---- main calculation loop
   pos=Bars-MA_Period;
   if(pos>Bars-ExtCountedBars) pos=Bars-ExtCountedBars;
   while(pos>=0)
     {
      if(pos==Bars-MA_Period)
        {
         //---- initial accumulation
         for(i=0,k=pos;i<MA_Period;i++,k++)
           {
            sum+=Close[k];
            //---- zero initial bars
            ExtMapBuffer[k]=0;
           }
        }
      else sum=ExtMapBuffer[pos+1]*(MA_Period-1)+Close[pos];
      ExtMapBuffer[pos]=sum/MA_Period;
 	   pos--;
     }
  }
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma()
  {
   double sum=0.0,lsum=0.0;
   double price;
   int    i,weight=0,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<=MA_Period;i++,pos--)
     {
      price=Close[pos];
      sum+=price*i;
      lsum+=price;
      weight+=i;
     }
//---- main calculation loop
   pos++;
   i=pos+MA_Period;
   while(pos>=0)
     {
      ExtMapBuffer[pos]=sum/weight;
      if(pos==0) break;
      pos--;
      i--;
      price=Close[pos];
      sum=sum-lsum+price*MA_Period;
      lsum-=Close[i];
      lsum+=price;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer[Bars-i]=0;
  }
//+------------------------------------------------------------------+
//| Batterwort Moving Average                                       |
//+------------------------------------------------------------------+
void BatMa(double Kf)
  {
   double p=2.0/(MA_Period+1);
   double p1,p2,p3;
   int    pos=Bars-2;
   p1=Kf*Kf;
   p2=2.0*(1-Kf);
   p3=(1-Kf)*(1-Kf);
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
//---- main calculation loop
   while(pos>=0)
     {
      if(pos==Bars-2) ExtMapBuffer[pos+1]=Close[pos+1];
      
      ExtMapBuffer[pos]=p1*Close[pos]+p2*ExtMapBuffer[pos+1]-p3*ExtMapBuffer[pos+2];
 	   pos--;
     }
  }
//+------------------------------------------------------------------+


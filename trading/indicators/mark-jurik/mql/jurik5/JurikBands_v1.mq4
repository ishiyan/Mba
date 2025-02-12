//+------------------------------------------------------------------+
//|                                                JurikBands_v1.mq4 |
//|                             Copyright © 2008-09, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
// List of Prices:
// Price    = 0 - Close  
// Price    = 1 - Open  
// Price    = 2 - High  
// Price    = 3 - Low  
// Price    = 4 - Median Price   = (High+Low)/2  
// Price    = 5 - Typical Price  = (High+Low+Close)/3  
// Price    = 6 - Weighted Close = (High+Low+Close*2)/4
// Price    = 7 - Heiken Ashi Close  
// Price    = 8 - Heiken Ashi Open
// Price    = 9 - Heiken Ashi High
// Price    =10 - Heiken Ashi Low
// Jurik Spandex bands http://www.jurikres.com/gifs/amibroker_freebies.gif
//http://www.forex-tsd.com/283466-post1.html  mystified

#property copyright "Copyright © 2008-09, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  Blue
#property indicator_width1  1
#property indicator_color2  Red
#property indicator_width2  1

//---- 
extern int     TimeFrame         =   0;   //Time Frame in min
extern int     Price             =   0;   //Price Mode (0...10)
extern int     Length            =  14;   //Period of smoothing
//---- 
double Up[],Dn[];
//----
double haClose[], haOpen[], haHigh[], haLow[];
int    draw_begin, pBars, mcnt_bars; 
string short_name;
double len, len1, len2, pow1, bet, R;
int    AvgLen = 65;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- 
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
  
   if(TimeFrame == 0 || TimeFrame < Period()) TimeFrame = Period();
     
   draw_begin=AvgLen*TimeFrame/Period();
//---- 
   switch(TimeFrame)
   {
   case 1     : string TF = "M1"; break;
   case 5     : TF = "M5"; break;
   case 15    : TF = "M15"; break;
   case 30    : TF = "M30"; break;
   case 60    : TF = "H1"; break;
   case 240   : TF ="H4"; break;
   case 1440  : TF="D1"; break;
   case 10080 : TF="W1"; break;
   case 43200 : TF="MN1"; break;
   default    : TF="Current";
   } 
   short_name = "JurikBands_v1";
   IndicatorShortName(short_name+"("+Length+")"+" "+TF);
   SetIndexLabel(0,short_name+"("+Length+")"+" "+TF);
   SetIndexLabel(1,short_name+"_lower");
   
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
//---- 
   SetIndexBuffer(0,Up);
   SetIndexBuffer(1,Dn);   
//----
   len = 0.5*(Length - 1);
   
   len1 = MathLog(MathSqrt(len))/MathLog(2.0) + 2;
	if (len1 < 0) len1 = 0;
 	
	pow1 = len1 - 2;
	if (pow1 < 0.5) pow1 = 0.5;
    
	len2 = MathSqrt(len)*len1;
    
	bet = len2/(len2 + 1);   
//---- 
   return(0);
}
//+------------------------------------------------------------------+
//| JurikBands_v1                                                    |
//+------------------------------------------------------------------+
int start()
{
   int limit, y, i, shift, cnt_bars=IndicatorCounted(); 
   double price, bsmax[], bsmin[], Volty[], AvgVolty[], vSum[];
      
   if(TimeFrame!=Period()) int mBars = iBars(NULL,TimeFrame); else mBars = Bars; 
   if(mBars != pBars)
   {
   ArrayResize(bsmin,mBars);
   ArrayResize(bsmax,mBars);
   ArrayResize(AvgVolty,mBars);
   ArrayResize(Volty,mBars); 
   ArrayResize(vSum,mBars);    
      if(Price > 6 && Price <= 10)
      {
      ArrayResize(haClose,mBars);
      ArrayResize(haOpen,mBars);
      ArrayResize(haHigh,mBars);
      ArrayResize(haLow,mBars);
      }
  
   pBars = mBars;
   }  
   
   if(cnt_bars<1)
   {
      for(i=Bars-1;i>0;i--) 
      {
      Up[i]=EMPTY_VALUE; 
      Dn[i]=EMPTY_VALUE;
      }
   mcnt_bars = 0;
   }
//---- 
   if(mcnt_bars > 0) mcnt_bars--;
   
   for(y=mcnt_bars;y<mBars;y++)
   {
      if(Price <= 6) price = iMA(NULL,TimeFrame,1,0,0,Price,mBars-y-1);   
      else
      if(Price > 6 && Price <= 10) price = HeikenAshi(TimeFrame,Price-7,mBars-y-1);
   
      if(y == 1) {bsmax[y] = price; bsmin[y] = price;}
      else
      {  
	 	   double del1 = price - bsmax[y-1];
         double del2 = price - bsmin[y-1];
		
         if(MathAbs(del1) > MathAbs(del2)) Volty[y] = MathAbs(del1); 
         else 
	      if(MathAbs(del1) < MathAbs(del2)) Volty[y] = MathAbs(del2);
	      else
	      if(MathAbs(del1) == MathAbs(del2)) Volty[y] = 0;
		
	      vSum[y] = vSum[y-1] + 0.1*(Volty[y] - Volty[y-10]);
	      if(y <= AvgLen+1) AvgVolty[y] = AvgVolty[y-1] + 2.0*(vSum[y] - AvgVolty[y-1])/(AvgLen+1);	    
		   else
		   AvgVolty[y] = SMA(vSum,AvgLen,y);
	         
         if (AvgVolty[y] > 0) double dVolty = Volty[y]/AvgVolty[y];
	      if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
         if (dVolty < 1) dVolty = 1.0;
	   
	      double pow2 = MathPow(dVolty, pow1);
         double Kv = MathPow(bet, MathSqrt(pow2));		
	
         if (del1 > 0) bsmax[y] = price; else bsmax[y] = price - Kv*del1;
         if (del2 < 0) bsmin[y] = price; else bsmin[y] = price - Kv*del2;
	   
         if(TimeFrame == Period()) 
         {
         Up[mBars-y-1] = bsmax[y];
         Dn[mBars-y-1] = bsmin[y];
         }
      }
      mcnt_bars = mBars-1;
   }
   
   if(TimeFrame > Period())
   { 
      if(cnt_bars>0) cnt_bars--;
      limit = Bars-cnt_bars+TimeFrame/Period()-1;
      
      for(shift=0,y=0;shift<limit;shift++)
      {
      if (Time[shift] < iTime(NULL,TimeFrame,y)) y++; 
      Up[shift]=bsmax[mBars-y-1];
      Dn[shift]=bsmin[mBars-y-1];
      }
   }
   return(0);
}

double SMA(double array[],int per,int bar)
{
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar-i];
   
   return(Sum/per);
}                

double HeikenAshi(int tf,int price,int bar)
{ 
   if(bar == iBars(NULL,TimeFrame)- 1) 
   {
   haClose[bar] = iClose(NULL,tf,bar);
   haOpen[bar]  = iOpen(NULL,tf,bar);
   haHigh[bar]  = iHigh(NULL,tf,bar);
   haLow[bar]   = iLow(NULL,tf,bar);
   }
   else
   {
   haClose[bar] = (iOpen(NULL,tf,bar)+iHigh(NULL,tf,bar)+iLow(NULL,tf,bar)+iClose(NULL,tf,bar))/4;
   haOpen[bar]  = (haOpen[bar+1]+haClose[bar+1])/2;
   haHigh[bar]  = MathMax(iHigh(NULL,tf,bar),MathMax(haOpen[bar], haClose[bar]));
   haLow[bar]   = MathMin(iLow(NULL,tf,bar),MathMin(haOpen[bar], haClose[bar]));
   }
   
   switch(price)
   {
   case 0: return(haClose[bar]);break;
   case 1: return(haOpen[bar]);break;
   case 2: return(haHigh[bar]);break;
   case 3: return(haLow[bar]);break;
   }
}     


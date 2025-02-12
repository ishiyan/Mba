//+------------------------------------------------------------------+
//|                                            ATR_Normalized_v1.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
#property indicator_maximum 100
#property indicator_minimum 0
//---- input parameters
extern int AtrPeriod  =14;
extern int NormPeriod = 100;
extern int MA_Mode = 0;
//---- buffers
double NormAtrBuffer[];
double AtrBuffer[];
double TempBuffer[];

double MaxAtr = 0.0000001, MinAtr = 10000000;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 1 additional buffer used for counting.
   IndicatorBuffers(3);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,NormAtrBuffer);
   SetIndexBuffer(1,AtrBuffer);
   SetIndexBuffer(2,TempBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="ATR Normalized("+AtrPeriod+","+NormPeriod+","+MA_Mode+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,NormPeriod+AtrPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
//+------------------------------------------------------------------+
int start()
{
   int i,limit,counted_bars=IndicatorCounted();
//----
   if ( counted_bars < 0 ) return(-1);
   if ( counted_bars ==0 ) limit=Bars-1;
   if ( counted_bars < 1 ) 
   
   for( i=1;i<AtrPeriod+NormPeriod;i++) 
   {
   NormAtrBuffer[Bars-i]=0;    
   AtrBuffer[Bars-i]=0;  
   TempBuffer[Bars-i]=0;   
   }
   
   if(counted_bars>0) limit=Bars-counted_bars;
   limit--;
   
   for( i=limit; i>=0; i--)
   {
   double high=High[i];
   double low =Low[i];
      if(i==Bars-1) TempBuffer[i]=high-low;
      else
      {
      double prevclose=Close[i+1];
      TempBuffer[i]=MathMax(high,prevclose)-MathMin(low,prevclose);
      }
   }
//----
      
   for( i=limit; i>=0; i--) 
   {
   AtrBuffer[i]=iMAOnArray(TempBuffer,Bars,AtrPeriod,0,MA_Mode,i);
      
   MaxAtr=0.0000001;MinAtr = 1000000;
      for( int k=0; k<NormPeriod-1 ; k++)
      {
      MaxAtr = MathMax(MaxAtr,AtrBuffer[i+k]);
      MinAtr = MathMin(MinAtr,AtrBuffer[i+k]);        
      }
      
      if (MaxAtr-MinAtr>0) NormAtrBuffer[i]=100*(AtrBuffer[i]-MinAtr)/(MaxAtr-MinAtr);   
      Print("i=",i," MaxAtr=",MaxAtr," ATR=",AtrBuffer[i]," MinATR=",MinAtr);
   }        
//----
   return(0);
}
//+------------------------------------------------------------------+
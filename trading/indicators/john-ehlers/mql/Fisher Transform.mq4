//+------------------------------------------------------------------+
//|                                              Fisher_org_v1.2.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"


#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LightBlue
#property indicator_color2 Tomato
//---- input parameters
extern int Length=10;
extern int Price=4;
extern int NumBars=0;
extern bool ROCFish = false;  
//---- buffers
double Buffer[]; 
double Value [];
double Fisher[];   

int init()
  {
  IndicatorBuffers(3);
  
  SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
  SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1);
  
  SetIndexBuffer(1,Buffer);
  SetIndexBuffer(0,Fisher);
  SetIndexBuffer(2,Value);
  
  IndicatorShortName ("FisherTransform(" + Length + "," + Price + ")");
  SetIndexLabel (0, "Fish");
  SetIndexLabel (1, "Trigger");
  
  SetIndexDrawBegin(0,Length);
  SetIndexDrawBegin(1,Length);
   
  return(0);
  }


//+------------------------------------------------------------------+
//| Fisher_org_v1                                                         |
//+------------------------------------------------------------------+
int start()
  {
  int shift;
   
  double smin=0,smax=0,maxfish=-1000000,minfish=1000000;                    

if (NumBars>0) int NBars=NumBars; else NBars=Bars;

for(shift=NBars;shift>=0;shift--)
   {	
   Buffer[shift]=0.0;
   Value [shift]=0.0;
   Fisher[shift]=0.0;   
   }
   
for(shift=NBars-2-Length;shift>=0;shift--)
   {	
   smax = High[Highest(NULL,0,MODE_HIGH,Length,shift)];
   smin = Low[Lowest(NULL,0,MODE_LOW,Length,shift)];
  
   double price = iMA(NULL,0,1,0,0,Price,shift);
   
   if (smax==smin) smax=smin+Point; 
   
   double wpr=(price-smin)/(smax-smin);         
   
   Value[shift] = 0.33*2*(wpr-0.5) + 0.67*Value[shift+1];     
   
   if (Value[shift]> 0.99) Value[shift]= 0.999; 
   if (Value[shift]<-0.99) Value[shift]=-0.999; 
   
   
   Fisher[shift] = 0.5*MathLog((1.0+Value[shift])/(1.0-Value[shift]))+0.5*Fisher[shift+1];
      
   if (ROCFish)
   Buffer[shift] = (Fisher[shift]-Fisher [shift+1])*10;
   else Buffer[shift] = Fisher [shift+1];       
 
   }
  return(0);
  }
//+------------------------------------------------------------------+
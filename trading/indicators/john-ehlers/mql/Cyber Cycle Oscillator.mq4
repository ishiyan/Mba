//+------------------------------------------------------------------+
//|                                               Cyber Cycle        |
//|                         Copyright © 2006, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"

#property indicator_buffers 3
#property indicator_separate_window
//#property indicator_chart_window

#property indicator_color1 Red
#property indicator_color2 LightBlue
#property indicator_color3 Yellow

//---- input parameters
extern double       alpha=0.07;
//extern int       maxbars=2000;
extern double lag_signal2=9;
//extern bool stochfish=true;
//extern int stochfish_window=8;
extern string 
Price_Choice="-----  Typical or Median  --------------";
extern bool is_median=true;

//---- buffers
double ind1[];
double ind2[];
double ind3[];
double AuxBuffer[]; //Smooth

double alpha2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ind1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ind2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ind3);
   SetLevelValue(0,0.0);
//   SetLevelValue(1,-0.8);
   ArrayInitialize(ind1,0.0);
   ArrayInitialize(ind2,0.0);
   ArrayInitialize(ind3,0.0);
   ArrayResize(AuxBuffer,Bars);
   ArrayInitialize(AuxBuffer,0.0);
   alpha2=1/(lag_signal2+1);  
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
  {
      double pr0,pr1,pr2,pr3=0;
      
      int    counted_bars=IndicatorCounted();
    
      //---- check for possible errors
      if(counted_bars<0) return(-1);
      int limit=Bars-counted_bars;
  //    if(limit>maxbars)limit=maxbars;      
      //if (limit>Bars-1)limit=Bars-1;   
      //---- 
      for (int i = limit; i>=0;i--)
      {
         if(is_median)
         {
            pr0=(High[i]+Low[i])/2;
            pr1=(High[i+1]+Low[i+1])/2;
            pr2=(High[i+2]+Low[i+2])/2;
            pr3=(High[i+3]+Low[i+3])/2;            
         }
         else
         {
            pr0=(High[i]+Low[i]+Close[i])/3;
            pr1=(High[i+1]+Low[i+1]+Close[i+1])/3;
            pr2=(High[i+2]+Low[i+2]+Close[i+2])/3;      
            pr3=(High[i+3]+Low[i+3]+Close[i+3])/3;      
         }
	      
	      AuxBuffer[i]= (pr0+2*pr1+2*pr2+pr3)/6;
	      
	      ind1[i]=MathPow(1-0.5*alpha,2)*(AuxBuffer[i]-2*AuxBuffer[i+1]+AuxBuffer[i+2])
	              +2*(1-alpha)*ind1[i+1]
	              -MathPow(1-alpha,2)*ind1[i+2];
	      
	      ind2[i]=ind1[i+1];
	      ind3[i]=alpha2*ind1[i]+(1-alpha2)*ind3[i+1];
         
       }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
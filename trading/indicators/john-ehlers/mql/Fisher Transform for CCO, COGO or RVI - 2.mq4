//+------------------------------------------------------------------+
//|                                                                  |
//|                         Copyright © 2006, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"

#property indicator_buffers 2
#property indicator_separate_window
//#property indicator_chart_window

#property indicator_color1 Yellow
#property indicator_color2 Blue
#property indicator_maximum 0.8
//#property indicator_color3 Purple

//---- input parameters
extern int length=8;
extern int    maxbars=1000;
extern bool mean_signal=false;
extern string Base_Oscillator_Choice="0= Cyber Cycle, 1= CG, 2= RVI, other= RSI(12) ----------------";
extern int Osc_Choice=0;

//---- buffers
double ind1[];
double ind2[];
//double ind3[];
//double AuxBuffer[]; //Smooth

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
//   SetIndexStyle(2,DRAW_LINE);
 //  SetIndexBuffer(2,ind3);
   SetLevelValue(0,0.0);
//   SetLevelValue(1,-0.8);
   ArrayInitialize(ind1,0.0);
   ArrayInitialize(ind2,0.0);
//   ArrayInitialize(ind3,0.0);
///   ArrayResize(AuxBuffer,maxbars+3);
 //  ArrayInitialize(AuxBuffer,0.0);
 switch(Osc_Choice)
 {
 case 0: IndicatorShortName("StochFisher of Cyber Cycle     ");break;
 case 1: IndicatorShortName("StochFisher of CG Oscillator     ");break;
 case 2: IndicatorShortName("StochFisher of Relative Vigor Index      ");break;
 default: IndicatorShortName("StochFisher of RSI(12)        ");break;
 
 }  
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
  {//1
   
      int    counted_bars=IndicatorCounted();
      double num=0,denom=0;
      double indw[];
      double stoch[];
      double mstoch;
      ArrayResize(indw,length);
      ArrayInitialize(indw,0);  
      ArrayResize(stoch,Bars);
      ArrayInitialize(stoch,0);  
      //---- check for possible errors
      if(counted_bars<0) return(-1);
      int limit=Bars-2*length-counted_bars;
      if(limit>maxbars)limit=maxbars;      
      //if (limit>Bars-1)limit=Bars-1;   
      //---- 
      for (int i = limit; i>=0;i--)
      {//2
         for(int j=0;j<length;j++)
         {
            switch(Osc_Choice)
            {
             case 0: indw[j]=iCustom(NULL,0,"Cyber Cycle Oscillator",0,i+j);break;
             case 1: indw[j]=iCustom(NULL,0,"Center Of Gravity Oscillator",0,i+j);break;
             case 2: indw[j]=iCustom(NULL,0,"Relative Vigor Index",0,i+j);break;
             default:indw[j]=iRSI(NULL,0,12,PRICE_MEDIAN,i+j);break;
            } 
  	      }
  	      
  	      double max=indw[ArrayMaximum(indw)];
  	      double min=indw[ArrayMinimum(indw)];
  	      stoch[i]=(indw[0]-min)/(max-min);
  	      
  	      mstoch=(4*stoch[i]+3*stoch[i+1]+2*stoch[i+2]+stoch[i+3])/10;
  	      ind1[i]=0.5*(MathLog((1+0.98*(mstoch-0.5))/(1-0.98*(mstoch-0.5))));
         
         ind2[i]=ind1[i+1];	          
    //     ind3[i]=(4*ind1[i]+3*ind1[i+1]+2*ind1[i+2]+ind1[i+3])/10;
       }//2
      
//----
   return(0);
  }
//+------------------------------------------------------------------+
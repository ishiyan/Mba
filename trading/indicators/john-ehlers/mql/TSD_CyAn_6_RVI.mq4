//+------------------------------------------------------------------+
//|                                            Relative Vigor Index  |
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
#property indicator_color2 Green
//#property indicator_color3 Yellow

//---- input parameters
extern double length=10;
//extern int    maxbars=2000;

//extern string 
//Price_Choice="-----  Typical or Median  --------------";
//extern bool is_median=true;

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
  // SetIndexStyle(2,DRAW_LINE);
  // SetIndexBuffer(2,ind3);
   SetLevelValue(0,0.0);
//   SetLevelValue(1,-0.8);
//   ArrayInitialize(ind1,0.0);
//   ArrayInitialize(ind2,0.0);
//   ArrayInitialize(ind3,0.0);
///   ArrayResize(AuxBuffer,maxbars+3);
 //  ArrayInitialize(AuxBuffer,0.0);
 
   
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
   
      int    counted_bars=IndicatorCounted();
      double num=0,denom=0;  
      //---- check for possible errors
      if(counted_bars<0) return(-1);
      int limit=Bars-counted_bars;
  //    if(limit>maxbars)limit=maxbars;      
      //if (limit>Bars-1)limit=Bars-1;   
      //---- 
      for (int i = limit; i>=0;i--)
      {
         num=0;denom=0;
         for(int j=0;j<length;j++)
         {
            num=num+v1(i,j);
            denom=denom+v2(i,j);
         }
         if(denom!=0)ind1[i]=num/denom;
	      ind2[i]=ind1[i+1];	          
       }
      
//----
   return(0);
  }
  
 double v1(int x,int y)
 {
    double pr;
    pr=((Close[x+y]-Open[x+y])+2*(Close[x+y+1]-Open[x+y+1])+2*(Close[x+y+2]-Open[x+y+2])+(Close[x+y+3]-Open[x+y+3]))/6;
  return(pr);          
 }
 
 double v2(int x,int y)
 {
    double pr;
    pr=((High[x+y]-Low[x+y])+2*(High[x+y+1]-Low[x+y+1])+2*(High[x+y+2]-Low[x+y+2])+(High[x+y+3]-Low[x+y+3]))/6;
  return(pr);          
 }           
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                        Standard Dev Channels.mq4 |
//|                         Copyright © 2006, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2006, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"
#property indicator_chart_window
#property  indicator_buffers 5
#property  indicator_color1  Black //Moving Average
#property  indicator_color2  Violet // Lower band 1
#property  indicator_color3  Violet // Upper band 1
#property  indicator_color4  MediumSlateBlue // Lower band 2
#property  indicator_color5  MediumSlateBlue // Upper band 2
//#property  indicator_color6  BlueViolet // Lower band 3
//#property  indicator_color7  BlueViolet // Upper band 3
//---- indicator buffers
double     MA_Buffer0[];
double     Ch1up_Buffer1[];
double     Ch1dn_Buffer2[];
double     Ch2up_Buffer3[];
double     Ch2dn_Buffer4[];
double     MA2_Buffer5[];
//double     Ch3dn_Buffer6[];

//---- input parameters
extern int       PeriodsSD=15;
extern int       MA_Periods=10;
extern int       MA_Periods2=10;
int       MA_type=MODE_LWMA;
extern double       Mult_Factor1= 1.0;
extern double       Mult_Factor2= 2.0;
//extern double       Mult_Factor3= 4.8;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  string mat;
 
//---7- indicators
// MA
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,MA_Buffer0);
   SetIndexDrawBegin(0,0);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,MA2_Buffer5);
   SetIndexDrawBegin(5,0);
   /*if (MA_type==MODE_LWMA)SetIndexLabel(0,"WMA"+MA_Periods) else 
   {
      if (MA_type==MODE_SMA) SetIndexLabel(0,"SMA"+MA_Periods) else
      {
         if (MA_type==MODE_EMA) SetIndexLabel(0,"EMA"+MA_Periods) else 
         SetIndexLabel(0,"SMMA"+MA_Periods);
      }; 
   };*/      
  // ATR 1 up
   SetIndexStyle(1,DRAW_LINE,DRAW_LINE,3);
   SetIndexBuffer(1,Ch1up_Buffer1);
   SetIndexDrawBegin(1,0);
   SetIndexLabel(1,"SDRu "+PeriodsSD+", "+Mult_Factor1);
  // ATR 1 down
   SetIndexStyle(2,DRAW_LINE,DRAW_LINE,3);
   SetIndexBuffer(2,Ch1dn_Buffer2);
   SetIndexDrawBegin(2,0);
   SetIndexLabel(2,"SDd "+PeriodsSD+", "+Mult_Factor1);
// ATR 2 up
   SetIndexStyle(3,DRAW_LINE,DRAW_LINE,2);
   SetIndexBuffer(3,Ch2up_Buffer3);
   SetIndexDrawBegin(3,0);
   SetIndexLabel(3,"SDu "+PeriodsSD+", "+Mult_Factor2);
  // ATR 2 down
   SetIndexStyle(4,DRAW_LINE,DRAW_LINE,2);
   SetIndexBuffer(4,Ch2dn_Buffer4);
   SetIndexDrawBegin(4,0);
   SetIndexLabel(4,"SDd "+PeriodsSD+", "+Mult_Factor2);
/*   // ATR 3 up
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Ch3up_Buffer5);
   SetIndexDrawBegin(5,0);
   SetIndexLabel(5,"SDu "+PeriodsSD+", "+Mult_Factor3);
  // ATR 3 down
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,Ch3dn_Buffer6);
   SetIndexDrawBegin(6,0);
   SetIndexLabel(6,"ATRd "+PeriodsSD+", "+Mult_Factor3);*/
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int fixed_bars=IndicatorCounted();
   for(int i=0;i< Bars - fixed_bars;i++)
     {
         double atr=iStdDev(NULL,0,PeriodsSD,MODE_LWMA,0,PRICE_TYPICAL,i);
         double ma=iMA(NULL,0,MA_Periods,0,MA_type,PRICE_TYPICAL,i);
         double ma2=iMA(NULL,0,MA_Periods2,0,MA_type,PRICE_TYPICAL,i);
         MA_Buffer0[i]=ma;
         MA2_Buffer5[i]=ma2;
         Ch1up_Buffer1[i]=ma+atr*Mult_Factor1;
         Ch1dn_Buffer2[i]=ma-atr*Mult_Factor1;
         
         Ch2up_Buffer3[i]=ma2+atr*Mult_Factor2;
         Ch2dn_Buffer4[i]=ma2-atr*Mult_Factor2;
         
 //        Ch3up_Buffer5[i]=ma+atr*Mult_Factor3;
 //        Ch3dn_Buffer6[i]=ma-atr*Mult_Factor3;
      }  
   
//---- 
   
//----
   return(0);
  }


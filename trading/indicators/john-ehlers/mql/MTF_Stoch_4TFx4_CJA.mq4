//+------------------------------------------------------------------+
//|                             CIA     MTF Stochastic Standard .mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                            MTF_4Period STOCH.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Keris2112"
#property link      "http://www.forex-tsd.com"
#property link      " extra timeframes by cja" 

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Olive
#property indicator_color2 Olive
#property indicator_color3 SeaGreen
#property indicator_color4 SeaGreen
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 DodgerBlue
#property indicator_color8 DodgerBlue
#property indicator_level1 80
#property indicator_level2 20
#property indicator_levelcolor DarkSlateGray
#property indicator_width1  4
#property indicator_width3  3
#property indicator_width5  2
#property indicator_width7  2
/*
Price Options
PRICE_CLOSE = 0 Close price. 
PRICE_OPEN = 1 Open price. 
PRICE_HIGH = 2 High price. 
PRICE_LOW = 3 Low price. 
PRICE_MEDIAN = 4 Median price, (high+low)/2. 
PRICE_TYPICAL = 5 Typical price, (high+low+close)/3. 
PRICE_WEIGHTED = 6 Weighted close price, (high+low+close+close)/4. 

Line Style Options
STYLE_SOLID = 0 The line is solid. 
STYLE_DASH = 1 The line is dashed. 
STYLE_DOT = 2 The line is dotted. 
STYLE_DASHDOT = 3 The line has alternating dashes and dots. 
STYLE_DASHDOTDOT = 4 The line has alternating dashes and double dots. 

Ma Options
MODE_SMA = 0 Simple moving average, 
MODE_EMA = 1 Exponential moving average, 
MODE_SMMA = 2 Smoothed moving average, 
MODE_LWMA = 3 Linear weighted moving average. 
*/
extern bool Show_StochLabels = false;
extern int Shift_Text = 0; 
extern string IIIIIIIIIIIIIIIIIIIIIIIIIIII=">>> Stoch #1 Settings >>>>>>>>>>>>>>>";
extern int TimeFrame1=0;
extern bool Show_STOCH_1 = true;
extern int K_period1 = 14;
extern int D_period1 = 3;
extern int S_period1 = 3;
extern int STOCH_MAIN_Line_Style1 = 0;
extern int STOCH_SIGNAL_Line_Style1 = 2;
extern int STOCH_MAIN_Price1 = 0;
extern int STOCH_SIGNAL_Price1 = 0;
extern int STOCH_MAIN_Ma1 = 0;
extern int STOCH_SIGNAL_Ma1 = 0;
extern string IIIIIIIIIIIIIIIIIIIIIIIIIIIII=">>> Stoch #2 Settings >>>>>>>>>>>>>>>>>";
extern int TimeFrame2=60;
extern bool Show_STOCH_2 = true;
extern int K_period2 = 14;
extern int D_period2 = 3;
extern int S_period2 = 3;
extern int STOCH_MAIN_Line_Style2 = 0;
extern int STOCH_SIGNAL_Line_Style2 = 2;
extern int STOCH_MAIN_Price2 = 0;
extern int STOCH_SIGNAL_Price2 = 1;
extern int STOCH_MAIN_Ma2 = 0;
extern int STOCH_SIGNAL_Ma2 = 0;
extern string IIIIIIIIIIIIIIIIIIIIIIIIIIIIII=">>> Stoch #3 Settings >>>>>>>>>>>>>>>>>>>";
extern int TimeFrame3=240;
extern bool Show_STOCH_3 = true;
extern int K_period3 = 14;
extern int D_period3 = 3;
extern int S_period3 = 3;
extern int STOCH_MAIN_Line_Style3 = 0;
extern int STOCH_SIGNAL_Line_Style3 = 2;
extern int STOCH_MAIN_Price3 = 1;
extern int STOCH_SIGNAL_Price3 = 1;
extern int STOCH_MAIN_Ma3 = 0;
extern int STOCH_SIGNAL_Ma3 = 0;
extern string IIIIIIIIIIIIIIIIIIIIIIIIIIIIIII=">>> Stoch #4 Settings >>>>>>>>>>>>>>>>>>>>>";
extern int TimeFrame4=1440;
extern bool Show_STOCH_4 = false;
extern int K_period4 = 14;
extern int D_period4 = 3;
extern int S_period4 = 3;
extern int STOCH_MAIN_Line_Style4 = 0;
extern int STOCH_SIGNAL_Line_Style4 = 2;
extern int STOCH_MAIN_Price4 = 1;
extern int STOCH_SIGNAL_Price4 = 1;
extern int STOCH_MAIN_Ma4 = 0;
extern int STOCH_SIGNAL_Ma4 = 0;

double MainBuffer1[];
double SignalBuffer1[];
double MainBuffer2[];
double SignalBuffer2[];
double MainBuffer3[];
double SignalBuffer3[];
double MainBuffer4[];
double SignalBuffer4[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() 
  {
   //---- indicator line
  if(Show_STOCH_1 ==true){Show_STOCH_1=DRAW_LINE; }
    else {Show_STOCH_1=DRAW_NONE; }
  SetIndexBuffer(6,MainBuffer1);
   SetIndexStyle(6,Show_STOCH_1 ,STOCH_MAIN_Line_Style1);
   SetIndexLabel(6,"MAIN#1["+TimeFrame1+"] ( "+K_period1+","+D_period1+", "+S_period1+" )");
   SetIndexBuffer(7,SignalBuffer1);
   SetIndexStyle(7,Show_STOCH_1 ,STOCH_SIGNAL_Line_Style1);
   SetIndexLabel(7,"SIGNAL#1["+TimeFrame1+"]("+K_period1+","+D_period1+","+S_period1+" )");
   
 if(Show_STOCH_2 ==true){Show_STOCH_2=DRAW_LINE; }
    else {Show_STOCH_2=DRAW_NONE; }
  SetIndexBuffer(4,MainBuffer2);
   SetIndexStyle(4,Show_STOCH_2 ,STOCH_MAIN_Line_Style2);
   SetIndexLabel(4,"MAIN#2["+TimeFrame2+"]("+K_period2+","+D_period2+","+S_period2+")");
   SetIndexBuffer(5,SignalBuffer2);
   SetIndexStyle(5,Show_STOCH_2 ,STOCH_SIGNAL_Line_Style2);
   SetIndexLabel(5,"SIGNAL#2["+TimeFrame2+"]("+K_period2+","+D_period2+","+S_period2+")");
   
 if(Show_STOCH_3 ==true){Show_STOCH_3=DRAW_LINE; }
    else {Show_STOCH_3=DRAW_NONE; }
  SetIndexBuffer(2,MainBuffer3);
   SetIndexStyle(2,Show_STOCH_3 ,STOCH_MAIN_Line_Style3);
   SetIndexLabel(2,"MAIN#3["+TimeFrame3+"]("+K_period3+","+D_period3+","+S_period3+")");
   SetIndexBuffer(3,SignalBuffer3);
   SetIndexStyle(3,Show_STOCH_3 ,STOCH_SIGNAL_Line_Style3);
   SetIndexLabel(3,"SIGNAL#3["+TimeFrame3+"]("+K_period3+","+D_period3+","+S_period3+" )");
   
 if(Show_STOCH_4 ==true){Show_STOCH_4=DRAW_LINE; }
    else {Show_STOCH_4=DRAW_NONE; }
  SetIndexBuffer(0,MainBuffer4);
   SetIndexStyle(0,Show_STOCH_4 ,STOCH_MAIN_Line_Style4);
   SetIndexLabel(0,"MAIN#4["+TimeFrame4+"]("+K_period4+","+D_period4+","+S_period4+")");
   SetIndexBuffer(1,SignalBuffer4);
   SetIndexStyle(1,Show_STOCH_4 ,STOCH_SIGNAL_Line_Style4);
   SetIndexLabel(1,"SIGNAL#4["+TimeFrame4+"]("+K_period4+","+D_period4+","+S_period4+")");
   
//---- name for DataWindow and indicator subwindow label   
  
  
  IndicatorShortName("MTF_Stoch_4TFx4");  
  }
//----
   return(0);
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
  ObjectsDeleteAll(0,OBJ_LABEL);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| MTF Stochastic                                                   |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray1[],TimeArray2[],TimeArray3[],TimeArray4[];
   int    i,shift,limit,y1=0,y2=0,y3=0,y4=0,counted_bars=IndicatorCounted();
    
// Plot defined timeframe on to current timeframe   
   
   ArrayCopySeries(TimeArray1,MODE_TIME,Symbol(),TimeFrame1); 
   ArrayCopySeries(TimeArray2,MODE_TIME,Symbol(),TimeFrame2); 
   ArrayCopySeries(TimeArray3,MODE_TIME,Symbol(),TimeFrame3); 
   ArrayCopySeries(TimeArray4,MODE_TIME,Symbol(),TimeFrame4); 
  
   
   limit=Bars-counted_bars+TimeFrame1/Period();
   limit=Bars-counted_bars+TimeFrame2/Period();
   limit=Bars-counted_bars+TimeFrame3/Period();
   limit=Bars-counted_bars+TimeFrame4/Period();
   for(i=0,y1=0,y2=0,y3=0,y4=0;i<limit;i++)
   {
if (Time[i]<TimeArray1[y1]) y1++; 
if (Time[i]<TimeArray2[y2]) y2++; 
if (Time[i]<TimeArray3[y3]) y3++; 
if (Time[i]<TimeArray4[y4]) y4++; 
   

     
  MainBuffer1[i]=iStochastic(NULL,TimeFrame1,K_period1,D_period1,S_period1,STOCH_MAIN_Ma1,STOCH_MAIN_Price1,MODE_MAIN,y1);
  SignalBuffer1[i]=iStochastic(NULL,TimeFrame1,K_period1,D_period1,S_period1,STOCH_SIGNAL_Ma1,STOCH_SIGNAL_Price1,MODE_SIGNAL,y1);
  
     
  MainBuffer2[i]=iStochastic(NULL,TimeFrame2,K_period2,D_period2,S_period2,STOCH_MAIN_Ma2,STOCH_MAIN_Price2,MODE_MAIN,y2);
  SignalBuffer2[i]=iStochastic(NULL,TimeFrame2,K_period2,D_period2,S_period2,STOCH_SIGNAL_Ma2,STOCH_SIGNAL_Price2,MODE_SIGNAL,y2);
  
  MainBuffer3[i]=iStochastic(NULL,TimeFrame3,K_period3,D_period3,S_period3,STOCH_MAIN_Ma3,STOCH_MAIN_Price3,MODE_MAIN,y3);
  SignalBuffer3[i]=iStochastic(NULL,TimeFrame3,K_period3,D_period3,S_period3,STOCH_SIGNAL_Ma3,STOCH_SIGNAL_Price3,MODE_SIGNAL,y3);
  
  MainBuffer4[i]=iStochastic(NULL,TimeFrame4,K_period4,D_period4,S_period4,STOCH_MAIN_Ma4,STOCH_MAIN_Price4,MODE_MAIN,y4);
  SignalBuffer4[i]=iStochastic(NULL,TimeFrame4,K_period4,D_period4,S_period4,STOCH_SIGNAL_Ma4,STOCH_SIGNAL_Price4,MODE_SIGNAL,y4);
   
   
   }  
     
  string STF1="";  
  if(TimeFrame1<1){STF1 = "Current TimeFrame";}  
  if(TimeFrame1==1){STF1 = "Period M1";}  
  if(TimeFrame1==5){STF1 = "Period M5";} 
  if(TimeFrame1==15){STF1 = "Period M15";} 
  if(TimeFrame1==30){STF1 = "Period M30";} 
  if(TimeFrame1==60){STF1 = "Period H1";} 
  if(TimeFrame1==240){STF1 = "Period H4";}
  if(TimeFrame1==1440){STF1 = "Period Daily";} 
  if(TimeFrame1==10080){STF1 = "Period Weekly";}
  if(TimeFrame1==43200){STF1 = "Period Monthly";}  
   
   string STF2="";  
  if(TimeFrame2<1){STF2 = "Current TimeFrame";}  
  if(TimeFrame2==1){STF2 = "Period M1";}  
  if(TimeFrame2==5){STF2 = "Period M5";} 
  if(TimeFrame2==15){STF2 = "Period M15";} 
  if(TimeFrame2==30){STF2 = "Period M30";} 
  if(TimeFrame2==60){STF2 = "Period H1";} 
  if(TimeFrame2==240){STF2 = "Period H4";}
  if(TimeFrame2==1440){STF2 = "Period Daily";} 
  if(TimeFrame2==10080){STF2 = "Period Weekly";}
  if(TimeFrame2==43200){STF2 = "Period Monthly";} 
  
    string STF3="";  
  if(TimeFrame3<1){STF3 = "Current TimeFrame";}  
  if(TimeFrame3==1){STF3 = "Period M1";}  
  if(TimeFrame3==5){STF3 = "Period M5";} 
  if(TimeFrame3==15){STF3 = "Period M15";} 
  if(TimeFrame3==30){STF3 = "Period M30";} 
  if(TimeFrame3==60){STF3 = "Period H1";} 
  if(TimeFrame3==240){STF3 = "Period H4";}
  if(TimeFrame3==1440){STF3 = "Period Daily";} 
  if(TimeFrame3==10080){STF3 = "Period Weekly";}
  if(TimeFrame3==43200){STF3 = "Period Monthly";} 
  
     string STF4="";  
  if(TimeFrame4<1){STF4 = "Current TimeFrame";}  
  if(TimeFrame4==1){STF4 = "Period M1";}  
  if(TimeFrame4==5){STF4 = "Period M5";} 
  if(TimeFrame4==15){STF4 = "Period M15";} 
  if(TimeFrame4==30){STF4 = "Period M30";} 
  if(TimeFrame4==60){STF4 = "Period H1";} 
  if(TimeFrame4==240){STF4 = "Period H4";}
  if(TimeFrame4==1440){STF4 = "Period Daily";} 
  if(TimeFrame4==10080){STF4 = "Period Weekly";}
  if(TimeFrame4==43200){STF4 = "Period Monthly";} 
    
   
    if(Show_StochLabels==true){	          
              ObjectCreate("stoLABEL", OBJ_LABEL,WindowFind("MTF 4Period STOCH #1 "), 0, 0);
   ObjectSetText("stoLABEL","STOCH #1 :  "+K_period1+" "+D_period1+" "+S_period1+"  "+STF1+"", 9, "Tahoma Narrow", indicator_color1);
   ObjectSet("stoLABEL", OBJPROP_CORNER, 0);
   ObjectSet("stoLABEL", OBJPROP_XDISTANCE, 735+Shift_Text);
   ObjectSet("stoLABEL", OBJPROP_YDISTANCE, 5); 
    	          
              ObjectCreate("stoLABEL1", OBJ_LABEL,WindowFind("MTF 4Period STOCH #1 "), 0, 0);
   ObjectSetText("stoLABEL1","STOCH #2 :  "+K_period2+" "+D_period2+" "+S_period1+"  "+STF2+"", 9, "Tahoma Narrow", indicator_color3);
   ObjectSet("stoLABEL1", OBJPROP_CORNER, 0);
   ObjectSet("stoLABEL1", OBJPROP_XDISTANCE, 735+Shift_Text);
   ObjectSet("stoLABEL1", OBJPROP_YDISTANCE, 20); 
  
             ObjectCreate("stoLABEL2", OBJ_LABEL,WindowFind("MTF 4Period STOCH #1 "), 0, 0);
   ObjectSetText("stoLABEL2","STOCH #3 :  "+K_period3+" "+D_period3+" "+S_period1+"  "+STF3+"", 9, "Tahoma Narrow", indicator_color5);
   ObjectSet("stoLABEL2", OBJPROP_CORNER, 0);
   ObjectSet("stoLABEL2", OBJPROP_XDISTANCE, 735+Shift_Text);
   ObjectSet("stoLABEL2", OBJPROP_YDISTANCE, 35); 
   
   
             ObjectCreate("stoLABEL4", OBJ_LABEL,WindowFind("MTF 4Period STOCH #1 "), 0, 0);
   ObjectSetText("stoLABEL4","STOCH #4 :  "+K_period4+" "+D_period4+" "+S_period1+"  "+STF4+"", 9, "Tahoma Narrow", indicator_color7);
   ObjectSet("stoLABEL4", OBJPROP_CORNER, 0);
   ObjectSet("stoLABEL4", OBJPROP_XDISTANCE, 735+Shift_Text);
   ObjectSet("stoLABEL4", OBJPROP_YDISTANCE, 50); 
   }
  
   
  
  
   return(0);
  }
//+------------------------------------------------------------------+
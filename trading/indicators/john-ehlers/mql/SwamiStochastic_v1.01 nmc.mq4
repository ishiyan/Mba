//+------------------------------------------------------------------+
//|                                         SwamiStochastic_v1.1.mq4 |
//|                                Copyright © 2013, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_separate_window
#property indicator_buffers 4

#property indicator_color1  SteelBlue
#property indicator_color2  Chocolate
#property indicator_color3  CLR_NONE
#property indicator_color4  CLR_NONE

#property indicator_width1  2
#property indicator_width2  2  
//---- 
extern int     VisualMode     =        0;    //0-original,1-trend 
extern int     Price          =        0;    //Applied to
extern int     HiLoMode       =        0;    //HiLoMode
extern int     StartLength    =       12;    //Stochastic Start Period
extern int     EndLength      =       48;    //Stochastic End Period
extern int     SampleLength   =       12;    //Sample Stochastic Period(0-off)
extern int     PreSmooth      =        3;    //Pre-smoothing Period
extern int     Smooth         =        9;    //Smoothing Period         
extern color   UpTrendColor   =     Lime;    //UpTrend Color 
extern color   DnTrendColor   =      Red;    //DownTrend Color
extern bool    UseFlatColor   =    false;    //Using flat color or not
extern color   FlatColor      =   Yellow;    //Flat Color (if NONE-2 Color Mix)  
extern string  UniqueName     =  "Stoch";    //
extern int     ScaleMode      =        1;    //0-J.Ehlers,1-0...100
extern int     SwamiBars      =      100;    //-1-off,0-all Bars,>0-any number 

//---- 
double   Stoch[];
double   sumStoch[];
double   upValue[];
double   loValue[];
//----
int      draw_begin, win, upLineR, upLineG, upLineB, dnLineR, dnLineG, dnLineB, flLineR, flLineG, flLineB, trend[][2]; 
double   swamiStoch[], ema[][2], fuzzWidth, maxValue, minValue;
datetime prevtime[], swamisize, prevtrendtime;
string   short_name;     
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- 
   colorToRGB(UpTrendColor,upLineR,upLineG,upLineB);
   colorToRGB(DnTrendColor,dnLineR,dnLineG,dnLineB);
   colorToRGB(FlatColor   ,flLineR,flLineG,flLineB);
//---- 
   short_name = "SwamiStochastic_v1.1("+VisualMode+","+Price+","+HiLoMode+","+StartLength+","+EndLength+","+PreSmooth+","+Smooth+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Stoch("+SampleLength+")");
   SetIndexLabel(1,"SummaryStoch");
//---- 
   SetIndexBuffer(0,   Stoch); SetIndexStyle(0,DRAW_LINE); SetIndexDrawBegin(0,EndLength);
   SetIndexBuffer(1,sumStoch); SetIndexStyle(1,DRAW_LINE); SetIndexDrawBegin(1,EndLength);
   SetIndexBuffer(2, loValue); SetIndexStyle(2,DRAW_LINE); SetIndexDrawBegin(2,EndLength);
   SetIndexBuffer(3, upValue); SetIndexStyle(3,DRAW_LINE); SetIndexDrawBegin(3,EndLength);
//----
   swamisize   = EndLength-StartLength+1;
   
   ArrayResize(       ema,swamisize*3);
   ArrayResize(  prevtime,swamisize*3);
   ArrayResize(swamiStoch,swamisize  );
   ArrayResize(    trend ,swamisize  );
   
   if(SampleLength > 0)
   {
   if(SampleLength < StartLength) SampleLength = StartLength; 
   if(SampleLength > EndLength  ) SampleLength = EndLength;
   }
   
   if(ScaleMode == 0) {fuzzWidth = 1; maxValue = EndLength; minValue = StartLength;}
   else {fuzzWidth = 100.0/(EndLength-StartLength); maxValue = 100; minValue = 0;}
   
   return(0);
}

//----  
void deinit()
{ 
   ObjectsDeleteAll(win,OBJ_RECTANGLE);  
  
   return;
}
//+------------------------------------------------------------------+
//| SwamiStochastic_v1.1                                             |
//+------------------------------------------------------------------+
int start()
{
   int   i, shift, limit, Color1, Color2, Color3, counted_bars=IndicatorCounted();
   win = WindowFind(short_name); 
//---- 
   if (counted_bars > 0)  limit=Bars-counted_bars-1;
   if (counted_bars < 0)  return(0);
   if (counted_bars < 1)
   { 
   limit = Bars-1;   
   for(i=limit;i>=0;i--) {Stoch[i] = EMPTY_VALUE; sumStoch[i] = EMPTY_VALUE;} 
   ObjectsDeleteAll(win,OBJ_RECTANGLE);  
   }   
         
   for(shift=limit; shift>=0; shift--)
   {   
      if(prevtrendtime != Time[shift]) 
      {
      for(i=0;i<swamisize;i++) trend[i][1] = trend[i][0];
      prevtrendtime = Time[shift];
      }
   
   loValue[shift] = minValue;
   upValue[shift] = maxValue;
   
   double swamisum = 0;         
      
      for(i=0;i<swamisize;i++) 
      {
      double stoch = _Stoch(HiLoMode,i,shift);
      
      
      
         if(VisualMode == 0) 
         {
         swamiStoch[i] = stoch;
         swamisum += swamiStoch[i];
         }
         else
         {
         trend[i][0] = trend[i][1];
         if(stoch > 0.5) trend[i][0] = 1;
         if(stoch < 0.5) trend[i][0] = 0;        
         
         swamiStoch[i] = trend[i][0];
         
         swamisum += trend[i][0];
         }
      }   
   
      if(ScaleMode == 0)
      {
         
         if(SampleLength > 0) Stoch[shift] = StartLength + (swamisize - 1)*swamiStoch[SampleLength-StartLength]; 
         sumStoch[shift] = StartLength + (swamisize - 1)*swamisum/swamisize;
      }
      else
      {
      if(SampleLength > 0) Stoch[shift] = 100*swamiStoch[SampleLength-StartLength]; 
      sumStoch[shift] = 100*swamisum/swamisize;
      }
      
   if((SwamiBars > 0 && shift < SwamiBars)||(SwamiBars == 0 && shift < Bars-1)) 
      for(i=0;i<swamisize;i++)
      {
	      if(UseFlatColor) 
	      {
	      Color1 = dnLineR + swamiStoch[i]*(upLineR - dnLineR);
         Color2 = dnLineG + swamiStoch[i]*(upLineG - dnLineG);
         Color3 = dnLineB + swamiStoch[i]*(upLineB - dnLineB);
	      }
	      else
	      {
            if(swamiStoch[i] >= 0.5)
            {
            Color1 = upLineR + 2*(1 - swamiStoch[i])*(flLineR - upLineR);
            Color2 = upLineG + 2*(1 - swamiStoch[i])*(flLineG - upLineG);
            Color3 = upLineB + 2*(1 - swamiStoch[i])*(flLineB - upLineB);
            }
            else 
            if(swamiStoch[i] < 0.5)
            {
            Color1 = dnLineR + 2*swamiStoch[i]*(flLineR - dnLineR);
            Color2 = dnLineG + 2*swamiStoch[i]*(flLineG - dnLineG);
            Color3 = dnLineB + 2*swamiStoch[i]*(flLineB - dnLineB);
            }
         }
          
      if(ScaleMode == 0) double value = i+StartLength; else value = i*fuzzWidth; 
      
      string text = UniqueName+"("+(i+StartLength)+") "+win+" "+TimeToStr(Time[shift]); 
      Plot(value, text, rgbToColor(Color1, Color2, Color3),fuzzWidth,shift);
      }
   }

   WindowRedraw();
   
   return(0);
}

double _Stoch(int mode,int index,int shift)
{   
   double tStoch;
     
   double price = iMA(NULL,0,1,0,0,Price,shift);
   
   if(mode == 0) 
   {
   double HH = price;
	double LL = price;
	}
	else
	{
   double hi = iMA(NULL,0,1,0,0,PRICE_HIGH,shift);
   double lo = iMA(NULL,0,1,0,0,PRICE_LOW ,shift);
   HH = hi;
	LL = lo;
	}
	
	for(int j = 1;j<StartLength + index;j++)
	{
      if(mode == 0) 
      {	       
      hi = iMA(NULL,0,1,0,0,Price,shift+j);
      lo = hi;
	   }
      else
      {
      hi = iMA(NULL,0,1,0,0,PRICE_HIGH,shift+j);
      lo = iMA(NULL,0,1,0,0,PRICE_LOW ,shift+j);
      }  
    
    if(hi > HH) HH = hi;
 	 if(lo < LL) LL = lo;
 	 }
 	 
 	 double Num   = EMA(index            ,price - LL,PreSmooth,shift);  
	 double Denom = EMA(index + swamisize,HH    - LL,PreSmooth,shift);
	 
   if(Denom != 0) tStoch = EMA(index + 2*swamisize,Num/Denom,Smooth,shift);
 	else tStoch = 0.5;
 	             
   if(tStoch > 1) tStoch = 1;
   if(tStoch < 0) tStoch = 0; 
     
   return(tStoch);
}


double EMA(int index,double price,int per,int bar)
{
   if(prevtime[index] != Time[bar])
   {  
   ema[index][1]   = ema[index][0];
   prevtime[index] = Time[bar];
   }
   
   if(bar >= Bars - 2) ema[index][0] = price;
   else 
   ema[index][0] = ema[index][1] + 2.0/(1+per)*(price - ema[index][1]); 
   
   return(ema[index][0]);
}

   

int rgbToColor(int R, int G, int B)
{
   return (256*(256*B + G) + R);
}

void colorToRGB(color clr,int& R, int& G, int& B)
{
   R = clr&0x000000FF;
   G = (clr>>8)&0x000000FF;
   B = (clr>>16)&0x000000FF; 
}

void Plot(double value,string name,color clr,double width,int bar)
{   
   ObjectDelete(name); 
   ObjectCreate(name,OBJ_RECTANGLE,win,Time[bar+1],value-0.5*width,Time[bar],value+0.5*width);
   ObjectSet(name,OBJPROP_COLOR,clr);
}




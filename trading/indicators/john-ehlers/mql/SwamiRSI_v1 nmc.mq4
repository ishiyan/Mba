//+------------------------------------------------------------------+
//|                                                  SwamiRSI_v1.mq4 |
//|                                Copyright © 2012, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  DarkOrchid
#property indicator_color2  Chocolate
#property indicator_color3  CLR_NONE
#property indicator_color4  CLR_NONE

#property indicator_width1  2
#property indicator_width2  2  
//---- 

extern int     VisualMode     =        0;    //0-original,1-trend
extern int     Price          =        0;    //Applied Price(0-Close;1-Open;2-High;3-Low;4-Median;5-Typical;6-Weighted)
extern int     StartLength    =       12;    //RSI Start Period
extern int     EndLength      =       48;    //RSI End Period
extern int     SampleLength   =       48;    //Sample RSI Period(0-off)            
extern int     Smooth         =        5;    //Smoothing Period     
extern color   UpTrendColor   =     Lime;    //UpTrend Color 
extern color   DnTrendColor   =      Red;    //DownTrend Color
extern bool    UseFlatColor   =    false;
extern color   FlatColor      =   Yellow;    //Flat Color (if NONE-2 Color Mix)  
extern string  UniqueName     =    "RSI";    //
extern int     ScaleMode      =        1;    //0-J.Ehlers,1-0...100
extern int     SwamiBars      =      100;    //-1-off,0-all Bars,>0-any number 

//---- 
double   RSI[];
double   sumRSI[];
double   upValue[];
double   loValue[];
//----
int      draw_begin, win, upLineR, upLineG, upLineB, dnLineR, dnLineG, dnLineB, flLineR, flLineG, flLineB; 
string   short_name, uphex, dnhex;
double   swamiRSI[], ema[][2], price[2];
int      prevtime[], swamisize, trend[][2], prevtrendtime;
double   fuzzWidth, maxValue, minValue;           
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
   short_name = "SwamiRSI_v1("+StartLength+","+EndLength+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"SwamiRSI("+SampleLength+")");
   SetIndexLabel(1,"SummaryRSI");
//---- 
   SetIndexBuffer(0,    RSI); SetIndexStyle(0,DRAW_LINE); SetIndexDrawBegin(0,EndLength);
   SetIndexBuffer(1, sumRSI); SetIndexStyle(1,DRAW_LINE); SetIndexDrawBegin(1,EndLength);
   SetIndexBuffer(2,loValue); SetIndexStyle(2,DRAW_LINE); SetIndexDrawBegin(2,EndLength);
   SetIndexBuffer(3,upValue); SetIndexStyle(3,DRAW_LINE); SetIndexDrawBegin(3,EndLength);
//----
   swamisize   = EndLength-StartLength+1;
   ArrayResize(     ema,swamisize*3);
   ArrayResize(prevtime,swamisize*3);
   ArrayResize(swamiRSI,swamisize  );
   ArrayResize(  trend ,swamisize  );
   
   if(SampleLength > 0)
   {
   if(SampleLength < StartLength) SampleLength = StartLength; 
   if(SampleLength > EndLength) SampleLength = EndLength;
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
//| SwamiRSI_v1                                                      |
//+------------------------------------------------------------------+
int start()
{
   int   shift, limit, Color1, Color2, Color3, counted_bars=IndicatorCounted();
   win = WindowFind(short_name); 
//---- 
   if (counted_bars > 0)  limit=Bars-counted_bars-1;
   if (counted_bars < 0)  return(0);
   if (counted_bars < 1)
   { 
   limit = Bars-1;   
   for(int i=limit;i>=0;i--) RSI[i] = EMPTY_VALUE; 
   ObjectsDeleteAll(win,OBJ_RECTANGLE);  
   }   
         
   for(shift=limit; shift>=0; shift--)
   {   
      if(prevtrendtime != Time[shift]) 
      {
      for(i=0;i<swamisize;i++) trend[i][1] = trend[i][0];
      price[1]      = price[0];
      prevtrendtime = Time[shift];
      }
      
   loValue[shift] = minValue;
   upValue[shift] = maxValue;
      
   price[0] = iMA(NULL,0,1,0,0,Price,shift);
      
   double Change = price[0] - price[1];
   
   double swamisum = 0;    
   
      for(i=0;i<swamisize;i++) 
      {
      double rsi = _RSI(i,Change,shift);
         
         if(VisualMode == 0) 
         {
         swamiRSI[i] = rsi;
         swamisum   += swamiRSI[i];
         }
         else
         {
         trend[i][0] = trend[i][1];
         if(rsi > 0.5) trend[i][0] = 1;
         if(rsi < 0.5) trend[i][0] = 0;        
         
         swamiRSI[i] = trend[i][0];
         swamisum   += trend[i][0];
         }
      }
      
      if(ScaleMode == 0)
      {
         if(SampleLength > 0) RSI[shift] = StartLength + (swamisize - 1)*swamiRSI[SampleLength-StartLength]; 
      sumRSI[shift] = StartLength + (swamisize - 1)*swamisum/swamisize;
      }
      else
      {
         if(SampleLength > 0) RSI[shift] = 100*swamiRSI[SampleLength-StartLength]; 
      sumRSI[shift] = 100*swamisum/swamisize;
      }
     
   if((SwamiBars > 0 && shift < SwamiBars)||(SwamiBars == 0 && shift < Bars-1)) 
      for(i=0;i<swamisize;i++)
      {
	      if(UseFlatColor) 
	      {
	      Color1 = dnLineR + swamiRSI[i]*(upLineR - dnLineR);
         Color2 = dnLineG + swamiRSI[i]*(upLineG - dnLineG);
         Color3 = dnLineB + swamiRSI[i]*(upLineB - dnLineB);
	      }
	      else
	      {
            if(swamiRSI[i] >= 0.5)
            {
            Color1 = upLineR + 2*(1 - swamiRSI[i])*(flLineR - upLineR);
            Color2 = upLineG + 2*(1 - swamiRSI[i])*(flLineG - upLineG);
            Color3 = upLineB + 2*(1 - swamiRSI[i])*(flLineB - upLineB);
            }
            else 
            if(swamiRSI[i] < 0.5)
            {
            Color1 = dnLineR + 2*swamiRSI[i]*(flLineR - dnLineR);
            Color2 = dnLineG + 2*swamiRSI[i]*(flLineG - dnLineG);
            Color3 = dnLineB + 2*swamiRSI[i]*(flLineB - dnLineB);
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

double _RSI(int index,double change,int shift)
{   
   double NetChgAvg, TotChgAvg, tRSI;
   double TotChg = MathAbs(change);
  
   NetChgAvg = EMA(index              ,change,index+StartLength,shift);  
   TotChgAvg = EMA(index +   swamisize,TotChg,index+StartLength,shift);
      
   if(TotChgAvg!=0) double ChgRatio = NetChgAvg/TotChgAvg;  else ChgRatio = 0;        
      
   tRSI       = EMA(index + 2*swamisize,2*ChgRatio+0.5,Smooth,shift);
               
   if(tRSI > 1) tRSI = 1;
   if(tRSI < 0) tRSI = 0; 
     
   return(tRSI);
}

//-----
double EMA(int index,double tprice,int per,int bar)
{
   if(prevtime[index] != Time[bar])
   {  
   ema[index][1]   = ema[index][0];
   prevtime[index] = Time[bar];
   }
   
   if(bar >= Bars - 2) ema[index][0] = tprice;
   else 
   ema[index][0] = ema[index][1] + 1.0/per*(tprice - ema[index][1]); 
   
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
   if(ObjectFind(name) < 0) ObjectCreate(name,OBJ_RECTANGLE,win,Time[bar+1],value-0.5*width,Time[bar],value+0.5*width);
   ObjectSet(name,OBJPROP_COLOR,clr);
}



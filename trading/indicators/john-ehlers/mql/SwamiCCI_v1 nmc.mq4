//+------------------------------------------------------------------+
//|                                                  SwamiCCI_v1.mq4 |
//|                                Copyright © 2013, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, TrendLaboratory"
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
extern int     Price          =        5;    //Applied Price(0-Close;1-Open;2-High;3-Low;4-Median;5-Typical;6-Weighted)
extern int     StartLength    =       12;    //CCI Start Period
extern int     EndLength      =       48;    //CCI End Period
extern int     SampleLength   =       12;    //Sample CCI Period(0-off)
extern double  CCIrange       =      100;    //CCI range(ex.100 or 200)            
extern int     Smooth         =        5;    //Smoothing Period     
extern color   UpTrendColor   =     Lime;    //UpTrend Color 
extern color   DnTrendColor   =      Red;    //DownTrend Color
extern bool    UseFlatColor   =    false;
extern color   FlatColor      =   Yellow;    //Flat Color (if NONE-2 Color Mix)  
extern string  UniqueName     =    "CCI";    //
extern int     ScaleMode      =        1;    //0-J.Ehlers,1-0...100
extern int     SwamiBars      =      100;

//---- 
double   CCI[];
double   sumCCI[];
double   upValue[];
double   loValue[];
//----
int      draw_begin, win, upLineR, upLineG, upLineB, dnLineR, dnLineG, dnLineB, flLineR, flLineG, flLineB; 
string   short_name;
double   swamiCCI[], ema[][2], price[];
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
   short_name = "SwamiCCI_v1("+VisualMode+","+StartLength+","+EndLength+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"SwamiCCI");
   SetIndexLabel(1,"SummaryCCI");
//---- 
   SetIndexBuffer(0,    CCI); SetIndexStyle(0,DRAW_LINE); SetIndexDrawBegin(0,EndLength);
   SetIndexBuffer(1, sumCCI); SetIndexStyle(1,DRAW_LINE); SetIndexDrawBegin(1,EndLength);
   SetIndexBuffer(2,loValue); SetIndexStyle(2,DRAW_LINE); SetIndexDrawBegin(2,EndLength);
   SetIndexBuffer(3,upValue); SetIndexStyle(3,DRAW_LINE); SetIndexDrawBegin(3,EndLength);
   
//----
   swamisize   = EndLength-StartLength+1;
   ArrayResize(     ema,  swamisize);
   ArrayResize(prevtime,  swamisize);
   ArrayResize(swamiCCI,  swamisize);
   ArrayResize(  trend ,  swamisize);
   ArrayResize(   price,EndLength+1);
   
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
//| SwamiCCI_v1                                                      |
//+------------------------------------------------------------------+
int start()
{
   int   i,shift, limit, Color1, Color2, Color3, counted_bars=IndicatorCounted();
   win = WindowFind(short_name); 
//---- 
   if (counted_bars > 0)  limit=Bars-counted_bars-1;
   if (counted_bars < 0)  return(0);
   if (counted_bars < 1)
   { 
   limit = Bars-1;   
   for(i=limit;i>=0;i--) CCI[i] = EMPTY_VALUE; 
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
   
   for(i=0;i<EndLength;i++) price[i] = iMA(NULL,0,1,0,0,Price,shift+i);
   
   double swamisum = 0; 
   
      for(i=0;i<swamisize;i++) 
      {
      double cci = _CCI(i,price,shift);
      
         if(VisualMode == 0) 
         {
         swamiCCI[i] = cci;
         swamisum   += swamiCCI[i];
         }
         else
         {
         trend[i][0] = trend[i][1];
         if(cci > 0.5) trend[i][0] = 1;
         if(cci < 0.5) trend[i][0] = 0;        
         
         swamiCCI[i] = trend[i][0];
         swamisum   += trend[i][0];
         }
      }   
   
      if(ScaleMode == 0)
      {
      if(SampleLength > 0) CCI[shift] = StartLength + (swamisize - 1)*swamiCCI[SampleLength-StartLength]; 
      sumCCI[shift] = StartLength + (swamisize - 1)*swamisum/swamisize;
      }
      else
      {
      if(SampleLength > 0) CCI[shift] = 100*swamiCCI[SampleLength-StartLength]; 
      sumCCI[shift] = 100*swamisum/swamisize;
      }
   
   if((SwamiBars > 0 && shift < SwamiBars)||(SwamiBars == 0 && shift < Bars-1)) 
      for(i=0;i<swamisize;i++)
      {
	      if(UseFlatColor) 
	      {
	      Color1 = dnLineR + swamiCCI[i]*(upLineR - dnLineR);
         Color2 = dnLineG + swamiCCI[i]*(upLineG - dnLineG);
         Color3 = dnLineB + swamiCCI[i]*(upLineB - dnLineB);
	      }
	      else
	      {
            if(swamiCCI[i] >= 0.5)
            {
            Color1 = upLineR + 2*(1 - swamiCCI[i])*(flLineR - upLineR);
            Color2 = upLineG + 2*(1 - swamiCCI[i])*(flLineG - upLineG);
            Color3 = upLineB + 2*(1 - swamiCCI[i])*(flLineB - upLineB);
            }
            else 
            if(swamiCCI[i] < 0.5)
            {
            Color1 = dnLineR + 2*swamiCCI[i]*(flLineR - dnLineR);
            Color2 = dnLineG + 2*swamiCCI[i]*(flLineG - dnLineG);
            Color3 = dnLineB + 2*swamiCCI[i]*(flLineB - dnLineB);
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

//----
double _CCI(int index,double& tprice[],int shift)
{
   double mean = 0;
   for(int j=0;j<index+StartLength;j++) mean += tprice[j];
   
   mean = mean/(index + StartLength);
       
   double avgDev = 0 ;
   for(j=0;j<index+StartLength;j++) avgDev += MathAbs(tprice[j] - mean);
   
   avgDev = avgDev/(index+StartLength);

   if(avgDev > 0) double cci = (tprice[0] - mean)/(0.015*avgDev); else cci = 0;
              
   cci = EMA(index,(cci + CCIrange)/(2*CCIrange),Smooth,shift);
   
   if(cci > 1) cci = 1;
   if(cci < 0) cci = 0;
   
   return(cci);
}

//-----
double EMA(int index,double tprice,int per,int bar)
{
   double alpha = 2.0/(per + 1);
   
   if(prevtime[index] != Time[bar])
   {  
   ema[index][1]   = ema[index][0];
   prevtime[index] = Time[bar];
   }
   
   if(bar >= Bars - 2) ema[index][0] = tprice;
   else 
   ema[index][0] = ema[index][1] + alpha*(tprice - ema[index][1]); 
   
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
//+------------------------------------------------------------------+
//|                                     AdaptiveInverseFisher_v1.mq4 |
//|                                Copyright © 2013, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
// List of Prices:
// Price    = 0 - Close  
// Price    = 1 - Open  
// Price    = 2 - High  
// Price    = 3 - Low  
// Price    = 4 - Median Price   = (High+Low)/2  
// Price    = 5 - Typical Price  = (High+Low+Close)/3  
// Price    = 6 - Weighted Close = (High+Low+Close*2)/4

 
#property copyright "Copyright © 2013, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"


#property indicator_separate_window
#property indicator_buffers 2

#property indicator_color1 Tomato
#property indicator_color2 DeepSkyBlue

#property indicator_width1 2
#property indicator_width2 1

#define pi 3.14159265358979323846
//---- indicator parameters

extern int     TimeFrame               =     0;       // TimeFrame in min
extern int     Price                   =     4;       // Price = 0...6
extern double  Alpha                   =  0.07;       // Cycle Smoothing Factor
extern int     MedianPeriod            =     5;       // Period of Moving Median
extern int     DCsmooth                =     5;       // Period of Dominant Cycle Smoothing
extern double  AdvanceAngle            =    90;       // Advance Angle for lag compensation
extern double  LeadSineAngle           =    45;       // Leading Sine Angle
extern int     SupportResistanceMode   =     0;       // 0-off,1-on
extern color   SupportColor            = DeepSkyBlue;
extern color   ResistanceColor         = OrangeRed;
extern int     LineWidth               =     2;
extern int     LineStyle               =     0;
extern string  UniqueName              = "SineWave";    

//---- indicator buffers
double sine[];
double lead[];
double cycle[];

//----
int      draw_begin, trend[2];
string   TF, IndicatorName, short_name, price_name;
datetime prevtime[8], prevrstime, sTime[2], rTime[2];
double   support[2], resistance[2];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   if(TimeFrame <= Period()) TimeFrame = Period();
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- indicator buffers mapping
   IndicatorBuffers(3);
   SetIndexBuffer(0, sine); SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1, lead); SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,cycle); 
   
//---- indicator name
   switch(TimeFrame)
   {
   case 1     : TF = "M1" ; break;
   case 5     : TF = "M5" ; break;
   case 15    : TF = "M15"; break;
   case 30    : TF = "M30"; break;
   case 60    : TF = "H1" ; break;
   case 240   : TF = "H4" ; break;
   case 1440  : TF = "D1" ; break;
   case 10080 : TF = "W1" ; break;
   case 43200 : TF = "MN1"; break;
   } 
   
   
   switch(Price)
   {
   case 0 : price_name = "Close";   break;
   case 1 : price_name = "Open";    break;
   case 2 : price_name = "High";    break;
   case 3 : price_name = "Low";     break;
   case 4 : price_name = "Median";  break;
   case 5 : price_name = "Typical"; break;
   case 5 : price_name = "Weighted Close"; break;
   }
     
   IndicatorName = WindowExpertName(); 
   short_name = IndicatorName + "[" + TF + "]("+ price_name + "," + DoubleToStr(Alpha,3) + "," + DCsmooth +")";
   IndicatorShortName(short_name);
      
   SetIndexLabel(0,"Sine");
   SetIndexLabel(1,"Lead");
   
//----
   int draw_begin = Bars - iBars(NULL,TimeFrame)*TimeFrame/Period() + DCsmooth + MedianPeriod;
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
//---- initialization done
 
   return(0);
}


//----
int deinit()
{
   deleteObj(UniqueName);
   
   return(0);
}
//+------------------------------------------------------------------+
//| HilbertSineWave_v1                                               |
//+------------------------------------------------------------------+
int start()
{
   int limit, i, shift, counted_bars = IndicatorCounted(); 
   
   
   if(counted_bars > 0) limit=Bars-counted_bars-1;
   if(counted_bars < 0) return(0);
   if(counted_bars < 1)
   { 
   limit = Bars-1;   
      for(i=limit;i>=0;i--) 
      {
      sine[i] = EMPTY_VALUE; 
      lead[i] = EMPTY_VALUE; 
      }
   }   
  
   if(TimeFrame != Period())
	{
   limit = MathMax(limit,TimeFrame/Period());   
      
      for(shift = 0;shift < limit;shift++) 
      {	
      int y = iBarShift(NULL,TimeFrame,Time[shift]);
            
      sine[shift]  = iCustom(NULL,TimeFrame,IndicatorName,0,Price,Alpha,MedianPeriod,DCsmooth,AdvanceAngle,LeadSineAngle,SupportResistanceMode,SupportColor,ResistanceColor,LineWidth,LineStyle,UniqueName,0,y);      
      lead[shift]  = iCustom(NULL,TimeFrame,IndicatorName,0,Price,Alpha,MedianPeriod,DCsmooth,AdvanceAngle,LeadSineAngle,SupportResistanceMode,SupportColor,ResistanceColor,LineWidth,LineStyle,UniqueName,1,y);      
               
      }  
	
	return(0);
	}
	else _SineWave(limit);

   return(0);
}

//-----

void _SineWave(int limit)
{   
   
         
   for(int shift=limit;shift>=0;shift--) 
   {
      if(prevrstime != Time[shift])
      {
      support[1]    = support[0];   
      resistance[1] = resistance[0];
      trend[1]      = trend[0];
      sTime[1]      = sTime[0];
      rTime[1]      = rTime[0];
      prevrstime    = Time[shift];
      }
   double period = cyclePeriod(Price,Alpha,MedianPeriod,DCsmooth,shift);
   int Length = MathFloor(period);      
   
   if(Length == 0) continue;
    
   //Compute Dominant Cycle Phase

   double RealPart = 0, ImagPart = 0;
   
      for(int i=0;i<Length;i++)
      {
      RealPart += MathSin(2*pi*i/Length)*cycle[shift+i];
      ImagPart += MathCos(2*pi*i/Length)*cycle[shift+i];
      }

   if(MathAbs(ImagPart) > 0.00000001) double DcPhase = 180/pi*MathArctan(RealPart/ImagPart); 
   else {if(RealPart > 0) DcPhase = 90; else DcPhase = -90;}
   
   DcPhase += AdvanceAngle;
   
   if(ImagPart <   0) DcPhase += 180;
   if(DcPhase  > 315) DcPhase -= 360;
   
   sine[shift] = MathSin(DcPhase*pi/180);
   lead[shift] = MathSin((DcPhase + LeadSineAngle)*pi/180);
   
      if(SupportResistanceMode == 1)
      {
      trend[0] = trend[1];
      sTime[0] = sTime[1];
      rTime[0] = rTime[1];
      
      if(lead[shift] > sine[shift] && lead[shift+1] <= sine[shift+1]) trend[0] = 1;
      if(lead[shift] < sine[shift] && lead[shift+1] >= sine[shift+1]) trend[0] =-1;
        
         if(trend[0] > 0)
         {
         support[0] = support[1];
         
            if(trend[0] != trend[1])
            {
            support[0] = Low[shift];
            sTime[0]   = Time[shift];
            }
         
         if(sTime[0] > 0) PlotLine(UniqueName + "_sup_" + TimeToStr(sTime[0]),0,sTime[0],support[0],Time[shift],support[0],SupportColor,LineWidth,LineStyle);
         }               
            
         if(trend[0] < 0)
         {
         resistance[0] = resistance[1];
            
            if(trend[0] != trend[1])
            {
            resistance[0] = High[shift];
            rTime[0]      = Time[shift];
            }
         
         if(rTime[0] > 0) PlotLine(UniqueName + "_res_" + TimeToStr(rTime[0]),0,rTime[0],resistance[0],Time[shift],resistance[0],ResistanceColor,LineWidth,LineStyle);
         }               
      }    
   }
}
   
//-----
double   DeltaPhase[], aPrice[4], smooth[3], Q1[2], I1[2], iPeriod[2], cPeriod[4];
datetime prevcptime;

double cyclePeriod(int price,double alpha,int median,int dcsmooth,int bar)
{      
   if(ArraySize(DeltaPhase) != Bars) 
   {
   ArraySetAsSeries(DeltaPhase,false); 
   ArrayResize(DeltaPhase,Bars); 
   ArraySetAsSeries(DeltaPhase,true); 
   }   
      
   if(prevcptime != Time[bar])
   {
      for(int i=3;i>=1;i--) 
      {
      aPrice[i]  = aPrice[i-1];
      cPeriod[i] = cPeriod[i-1]; 
      if(i < 3) smooth[i] = smooth[i-1];
      }
   
   I1[1] = I1[0];
   Q1[1] = Q1[0];
   iPeriod[1] = iPeriod[0];
   prevcptime = Time[bar];
   }   

   aPrice[0] = iMA(NULL,0,1,0,0,price,bar);   
         
   if(bar < Bars - 3) smooth[0] = (aPrice[0] + 2*aPrice[1] + 2*aPrice[2] + aPrice[3])/6; 
	cycle[bar] = (1 - 0.5*alpha)*(1 - 0.5*alpha)*(smooth[0] - 2*smooth[1] + smooth[2]) + 2*(1-alpha)*cycle[bar+1] - (1-alpha)*(1-alpha)*cycle[bar+2];
	if(bar > Bars - 7) cycle[bar] = (aPrice[0] - 2*aPrice[1] + aPrice[2])/4;  
	
		   
   Q1[0] = (0.0962*cycle[bar] + 0.5769*cycle[bar+2] - 0.5769*cycle[bar+4] - 0.0962*cycle[bar+6])*(0.5+0.08*iPeriod[1]);
   I1[0] = cycle[bar+3];  
	
   if(Q1[0] != 0 && Q1[1] != 0) DeltaPhase[bar] = (I1[0]/Q1[0] - I1[1]/Q1[1])/(1 + I1[0]*I1[1]/(Q1[0]*Q1[1]));		
   if(DeltaPhase[bar] < 0.1) DeltaPhase[bar] = 0.1;  
   if(DeltaPhase[bar] > 1.1) DeltaPhase[bar] = 1.1;
   double MedianDelta = MedianOnArray(DeltaPhase,median,bar);

   if(MedianDelta == 0) double DC = 15; else DC = 6.28318/MedianDelta + 0.5;
	
   iPeriod[0] = 0.33*DC + (1 - 2.0/(dcsmooth + 1))*iPeriod[1];
   cPeriod[0] = 0.15*iPeriod[0] + 0.85*cPeriod[1];
   
   if(cPeriod[3] == 0) return(0);   
     
   return(cPeriod[0]);
}

double MedianOnArray(double price[],int per,int bar)
{
   double array[];
   ArrayResize(array,per);
   
   for(int i = 0; i < per;i++) array[i] = price[bar+i];
   ArraySort(array);
   
   int num = MathRound((per-1)/2); 
   if(MathMod(per,2) > 0) double median = array[num]; else median = 0.5*(array[num]+array[num+1]);
    
   return(median); 
}   
   
void PlotLine(string name,int win,datetime time1,double value1,datetime time2,double value2,color clr,int width,int style)
{
   ObjectDelete(name);
   bool res = ObjectCreate(name,OBJ_TREND,win,time1,value1,time2,value2);
   ObjectSet(name, OBJPROP_WIDTH,width);
   ObjectSet(name, OBJPROP_STYLE,style);
   ObjectSet(name, OBJPROP_RAY  ,false);
   ObjectSet(name, OBJPROP_BACK ,false);
   ObjectSet(name, OBJPROP_COLOR,clr  );
}        

bool deleteObj(string name)
{
   bool result = false;
   
   int length = StringLen(name);
   for(int i=ObjectsTotal()-1; i>=0; i--)
   {
   string objName = ObjectName(i); 
   if(StringSubstr(objName,0,length) == name) {ObjectDelete(objName); result = true;}
   }
   
   return(result);
}   








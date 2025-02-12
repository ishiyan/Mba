//+----------------------------------------------------------+
//|                              Ehlers fisher transform.mq4 |
//|                                                   mladen |
//+----------------------------------------------------------+
#property  copyright "mladen"
#property  link      "mladenfx@gmail.com"

#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  DimGray
#property  indicator_color2  YellowGreen
#property  indicator_width1  2
#property  indicator_style2  STYLE_DOT

//
//
//
//
//
 
extern int    period           = 10;
extern int    PriceType        = PRICE_MEDIAN;
extern bool   showSignalLine   = true;

extern string note             = "turn on Alert = true; turn off = false";
extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = true;
extern bool   alertsEmail      = false;
extern string soundfile        = "alert2.wav";

extern string  __              = "arrows settings";
extern bool   ShowArrows       = true; 
extern string ArrowsIdentifier = "EFTarrow";
extern color  ArrowUpColor     = Aqua;
extern color  ArrowDownColor   = Red; 
extern int    ArrowUpWidth     = 1; 
extern int    ArrowDownWidth   = 1; 

//
//
//
//
//

double buffer1[];
double buffer2[];
double Prices[];
double Values[];
double trend[];
double atrend[];
  
//+----------------------------------------------------------+
//|                                                          |
//+----------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(6);
      SetIndexBuffer(0,buffer1);
      SetIndexBuffer(1,buffer2);
      SetIndexBuffer(2,Prices);
      SetIndexBuffer(3,Values);
      SetIndexBuffer(4,trend);
      SetIndexBuffer(5,atrend);
      
   IndicatorShortName("Ehlers\' Fisher transform ("+period+")");
   return(0);
}

//
//
//
//
//

int deinit()
{
   if (ShowArrows)
   {
      int compareLength = StringLen(ArrowsIdentifier);
      for (int i=ObjectsTotal(); i>= 0; i--)
      {
         string name = ObjectName(i);
            if (StringSubstr(name,0,compareLength) == ArrowsIdentifier)
                ObjectDelete(name);  
      }
   }
   return(0);
}

//+----------------------------------------------------------+
//|                                                          |
//+----------------------------------------------------------+
//
//
//
//
//

int start()
{
   int  counted_bars=IndicatorCounted();
   int  i,limit;

   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
           limit = Bars-counted_bars;

   //
   //
   //
   //
   //
         
   for(i=limit; i>=0; i--)
   {  
      Prices[i] = iMA(NULL,0,1,0,MODE_SMA,PriceType,i);
      
      //
      //
      //
      //
      //
                  
         double MaxH = Prices[ArrayMaximum(Prices,period,i)];
         double MinL = Prices[ArrayMinimum(Prices,period,i)];
         if (MaxH!=MinL)
               Values[i] = 0.33*2*((Prices[i]-MinL)/(MaxH-MinL)-0.5)+0.67*Values[i+1];
         else  Values[i] = 0.00;
               Values[i] = MathMin(MathMax(Values[i],-0.999),0.999); 

      // 
      //
      //
      //
      //

      buffer1[i] = 0.5*MathLog((1+Values[i])/(1-Values[i]))+0.5*buffer1[i+1];
      if (showSignalLine)
            buffer2[i] = buffer1[i+1];
              trend[i] = trend[i+1];
             
      if (buffer1[i] > buffer2[i] && buffer1[i+1] <= buffer2[i+1]) trend[i] =  1; 
      if (buffer1[i] < buffer2[i] && buffer1[i+1] >= buffer2[i+1]) trend[i] = -1; 
      manageArrow(i);  
      
      }
      
      //
      //
      //
      //
      //
      
   
      if (alertsOn)
      {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;

         //
         //
         //
         //
         //
         
         if (trend[whichBar] != trend[whichBar+1])
         if (trend[whichBar] == 1)
               doAlert("uptrend");
         else  doAlert("downtrend");       
   }
   
   return(0);
}
//+------------------------------------------------------------------+


void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Ehlers fisher transform  ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Ehlers fisher transform "),message);
             if (alertsSound)   PlaySound(soundfile);
      }
}

//
//
//
//
//

void manageArrow(int i)
{
   if (ShowArrows)
   {
      double dist = iATR(NULL,0,20,i)/2.0;
      ObjectDelete(ArrowsIdentifier+Time[0]);         
            
      //
      //
      //
      //
      //
           
      atrend[i] = atrend[i+1];
         if (buffer1[i] > buffer2[i] && buffer1[i+1] <= buffer2[i+1]) atrend[i] =  1; 
         if (buffer1[i] < buffer2[i] && buffer1[i+1] >= buffer2[i+1]) atrend[i] = -1; 
      
         if (atrend[i] !=atrend[i+1])
         {
            string name = ArrowsIdentifier+Time[i];
            if (atrend[i] == 1)
            {
               ObjectCreate(name,OBJ_ARROW,0, Time[i],Low[i]-dist );
                  ObjectSet(name,OBJPROP_ARROWCODE,225);
                  ObjectSet(name,OBJPROP_COLOR,ArrowUpColor);
                  ObjectSet(name,OBJPROP_WIDTH,ArrowUpWidth);
            }
            else
            {
               ObjectCreate(name,OBJ_ARROW,0, Time[i],High[i]+dist );
                  ObjectSet(name,OBJPROP_ARROWCODE,226);
                  ObjectSet(name,OBJPROP_COLOR,ArrowDownColor);
                  ObjectSet(name,OBJPROP_WIDTH,ArrowDownWidth);
            }
         }
   }
}


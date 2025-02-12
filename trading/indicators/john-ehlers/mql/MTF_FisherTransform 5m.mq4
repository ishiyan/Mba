#property copyright "Kalenzo"
#property link      "http://www.fxservice.eu"
#property indicator_buffers 2

#property indicator_color1 Lime
#property indicator_color2 MediumOrchid

#property indicator_width1 3
#property indicator_width2 3

extern int  AlertDelay  = 0,
            TimeFrame   = 5;
 
extern int Length2=10;
extern int Price2=4;
extern int NumBars2=0;
extern bool ROCFish2 = false;  
extern bool TurnAlertOn = true;

double sUp1[],sDn1[];
 
int adU,adD;   
int a=0,b=0;

string signal;

SetLevelStyle(2,1,Lime);
SetLevelValue(1,0);

SetLevelStyle(2,1,Aqua);
SetLevelValue(2,-1);
SetLevelValue(3,1);


#property indicator_separate_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,sUp1);
   SetIndexBuffer(1,sDn1);
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);
   
   
    
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
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
     
     int counted_bars=IndicatorCounted();
     if(counted_bars<0) return(-1);
     if(counted_bars>0) counted_bars--;
     int limit=Bars-counted_bars;
     
     for(int i=0; i<=limit; i++)
     {
         sUp1[i] = 0; sDn1[i] = 0;
         
         int bbs = iBarShift(NULL,TimeFrame,Time[i],true);
         
         sUp1[i] = iCustom(Symbol(),TimeFrame,"Fisher Transform",Length2,Price2,NumBars2,ROCFish2,0,bbs);
         sDn1[i] = iCustom(Symbol(),TimeFrame,"Fisher Transform",Length2,Price2,NumBars2,ROCFish2,1,bbs);
         
        
     }
     
     if(TurnAlertOn && Time[0]>adU &&  sUp1[0]>sDn1[0] && sUp1[1]<=sDn1[1] )
	{	
		Alert(Symbol()+" 5m TREND IS LONG -> FISHER");
	   
		adU = Time[0]+(AlertDelay*60);
	}
	
	if(TurnAlertOn && Time[0]>adD &&  sUp1[0]<sDn1[0] && sUp1[1]>=sDn1[1] )
	{	
		Alert(Symbol()+" 5m TREND IS SHORT -> FISHER");
	
		adD = Time[0]+(AlertDelay*60);
	} 
	
   		    if(sUp1[0]>sDn1[0])
      {signal = "   5min TREND IS LONG       ";}
      if (sUp1[0]<sDn1[0])
      {signal = "   5min TREND IS SHORT       ";}
      if (sUp1[0]==sDn1[0])
      {signal = "   5min TREND IS NEUTRAL     ";}
     
 
    IndicatorShortName("FISHER TRANSFORM "+signal);
    
   return(0); 
  }
  
//+------------------------------------------------------------------+




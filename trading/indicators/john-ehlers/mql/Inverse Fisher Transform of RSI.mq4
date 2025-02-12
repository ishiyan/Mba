//+------------------------------------------------------------------+
//|                              Inverse Fisher Transform of RSI.mq4 |
//|                                             Treberk's Conversion |
//|                                             Treberk's Conversion |
//+------------------------------------------------------------------+
#property copyright "Treberk's Conversion"
#property link      "Treberk's Conversion"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 DimGray


//Inputs
 
 extern int  RsiBars=5; // default=5
 extern int  WmaBars=9; // default=9
 extern int  HiTrigger=0.5; // default=0.5
 extern int  LoTrigger=-0.5; // default=-0.5
 extern bool  info=0; // default=0


//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
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
//---- 
   
    // SetLoopCount(0);
//--------------------------------------------------------

//Variables: // Generic
int  shift;
int  loopBegin;
bool is_First=True;
double   prevbars;
int   count;

//Variables: // Specific
//   Name(\"InvFisher RSI\"),
double   Value2;
double    IFish;
   // for manual calc. RSI
double    SumUp;
double    SumDn;
double    AvgUp;
double    AvgDn;
double   Delta;
double   RSI;
   // for calc. WMA
double   WmaNumerator;
double   WmaDenominator;
datetime LastTime;
double   PrevAvgUp;
double   PrevAvgDn;
int      cntdown;
   
//Arrays:
   // for ( calc. generic WMA (weighted moving average)
   double Value1[40];
   



// Usage
/*[if (info ) {
   Alert(\"See Terminal>Journal Tab for ( usage of \\n\",Name);
   Print(\"|___________________\");
   Print(\"|* \",Name,\" *\");
   Print(\"|  \",\"Sell: cross under HiTrigger (or under LoTrigger if (no prior cross under  HiTrigger)\");
   Print(\"|  \",\"Buy: cross over LoTrigger (or over HiTrigger if (no prior cross over LoTrigger)\");
   Print(\"|* \",Name,\" *\");
   Print(\"|```````````````````\");
   }]*/
//--------------------------------------------------------

// Check Inputs
if (0>HiTrigger || HiTrigger>1 ) {
   Alert("Input Error:  must be 0< HiTrigger <1, Cannot=",HiTrigger);
   return(0);
}
if (-1>LoTrigger || LoTrigger>0 ) {
   Alert("Input Error:  must be -1< LoTrigger <0, Cannot=",LoTrigger);
   return(0);
}
if (0>RsiBars || RsiBars>50 ) {
   Alert("Input Error:  must be 0< RsiBars <50, Cannot=",RsiBars);
   return(0);
}
//--------------------------------------------------------

// Check for ( additional bars loading or total reloadng.
if (Bars<prevbars || Bars-prevbars>1 ) is_First=True;
prevbars=Bars;
//--------------------------------------------------------

// Pre-Loop setup
// loopbegin prevents counting of previously plotted bars excluding current Bars 
if (is_First ) {
   loopBegin=Bars-1-1;// BarIndexNumber=Shift=Bars-1...0

   // Compute the initial AvgUp & AvgDn for RSI
   for ( shift=loopBegin; shift>=loopBegin-RsiBars; shift--) {
      Delta=Close[shift]-Close[shift+1];
      SumUp=SumUp+MathMax(0,Delta);
      SumDn=SumDn-MathMin(0,Delta);
   }
   AvgUp=SumUp/RsiBars;
   AvgDn=SumDn/RsiBars;
   loopBegin=loopBegin-RsiBars;
}
//--------------------------------------------------------

// loop from loopbegin to current bar (shift=0)
if (! is_First ) {
   if ((Time[0]!=LastTime) ) {
     PrevAvgUp = AvgUp;
     PrevAvgDn = AvgDn;
     AvgUp = 0;
     AvgDn = 0;
     for ( count=WmaBars-1; count>=1; count--) {
        Value1[count]=Value1[count-1];
     }
     LastTime = Time[0];
   }
} else {
  cntdown = 1;
}

for ( shift=loopBegin; shift>=cntdown; shift--) {
   // Calc RSI manually
   Delta=Close[shift]-Close[shift+1];
   if (is_First ) {
     AvgUp=((RsiBars-1)*AvgUp+MathMax(0,Delta))/RsiBars;
     AvgDn=((RsiBars-1)*AvgDn-MathMin(0,Delta))/RsiBars;
   } else {
     AvgUp=((RsiBars-1)*PrevAvgUp+MathMax(0,Delta))/RsiBars;
     AvgDn=((RsiBars-1)*PrevAvgDn-MathMin(0,Delta))/RsiBars;
   }
   RSI=100-100/(1+AvgUp/AvgDn);
   // ) scale RSI to between -5 and +5
   /* Do not use iRSI fctn because it\'s too slow
   Value1=0.1*(iRSI(RsiBars,shift)-50); */
   Value1[0]=0.1*(RSI-50);

   // Use weighted moving average to smooth Value1.
   // Ehler suggests could also use EMA, which would be simpler coding at the expense of Alpha.
   WmaNumerator=0;
   WmaDenominator=0;
   for ( count=WmaBars; count>= 1; count--) {
      WmaNumerator=WmaNumerator+count*Value1[WmaBars-count-1];
      WmaDenominator=WmaDenominator+count;
   }
   Value2=WmaNumerator/WmaDenominator;
   IFish=(MathExp(2*Value2)-1)/(MathExp(2*Value2)+1); 

   ExtMapBuffer1[shift]=IFish;
//   SetIndexValue[shift]=RSI;

   // Plot dual-value Trigger Line
   if (IFish >0 )
      ExtMapBuffer2[shift]=HiTrigger;
   else
      ExtMapBuffer2[shift]=LoTrigger;
   //--------------------------------------------------------

   // Update arrays.  This technique minimizes array storage and thus allows more signal bars.
   if (is_First ) for ( count=WmaBars-1; count>= 1; count--) {
      Value1[count]=Value1[count-1];
   }
   //--------------------------------------------------------
}

is_First = False;
cntdown = 0;
loopBegin = 0;
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
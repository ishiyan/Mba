//+------------------------------------------------------------------+
//|                                                 Wilder's DMI.mq4 |
//|                                                  coded by mladen |
//|                                                                  |
//| Directional movement index was developed by Welles Wilder        |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property  indicator_buffers 5
#property indicator_minimum  0
#property indicator_color1   Lime
#property indicator_color2   Tomato
#property indicator_color3   DimGray
#property indicator_color4   Orange
#property indicator_color5   DimGray
#property indicator_width3   2 
#property indicator_width4   2 
#property indicator_style1   STYLE_DOT
#property indicator_style2   STYLE_DOT
#property indicator_style5   STYLE_DOT

//
//
//
//
//

extern int  DMI.Length = 14;
extern int  SS_Period  = 5;
extern bool ShowADX    = true;
extern bool ShowADXR   = false;
extern int  Level      = 20;

//
//
//
//
//

double DIp[];
double DIm[];
double ADX[];
double ADXR[];
double ADXLevel[];
double averageDIp[];
double averageDIm[];
double averageTR[];


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,DIp);      SetIndexLabel(0,"DI+");
   SetIndexBuffer(1,DIm);      SetIndexLabel(1,"DI-");
   SetIndexBuffer(2,ADX);      SetIndexLabel(2,"ADX");
   SetIndexBuffer(3,ADXR);     SetIndexLabel(3,"ADXR");
   SetIndexBuffer(4,ADXLevel); SetIndexLabel(4,NULL);
   SetIndexBuffer(5,averageDIp);
   SetIndexBuffer(6,averageDIm);
   SetIndexBuffer(7,averageTR);
      for (int i=0;i<8;i++) SetIndexEmptyValue(i,0.00);

   //
   //
   //
   //
   //

   IndicatorShortName("Wilder\'s super smoother DMI ("+DMI.Length+")");
   return(0);
}

int deinit()
{
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=Bars-counted_bars;
           limit=MathMin(limit,Bars-2);

   //
   //
   //
   //
   //
   
   double sf = (DMI.Length-1.0)/DMI.Length;
      for (i=limit;i>=0;i--)
      {
         double currTR  = MathMax(High[i],Close[i+1])-MathMin(Low[i],Close[i+1]);
         double DeltaHi = High[i] - High[i+1];
	      double DeltaLo = Low[i+1] - Low[i];
         double plusDM  = 0.00;
         double minusDM = 0.00;
         
            if ((DeltaHi > DeltaLo) && (DeltaHi > 0)) plusDM  = DeltaHi;
            if ((DeltaLo > DeltaHi) && (DeltaLo > 0)) minusDM = DeltaLo;      
         
         //
         //
         //
         //
         //
         
            averageDIp[i] = sf*averageDIp[i+1] + plusDM;
            averageDIm[i] = sf*averageDIm[i+1] + minusDM;
            averageTR[i]  = sf*averageTR[i+1]  + currTR;
            ADXLevel[i]   = Level;

         //
         //
         //
         //
         //
                  
            DIp[i] = 0.00;                   
            DIm[i] = 0.00;                   
            if (averageTR[i] > 0)
               {              
                  DIp[i] = 100.00 * iSsm(averageDIp[i]/averageTR[i],SS_Period,i,0);
                  DIm[i] = 100.00 * iSsm(averageDIm[i]/averageTR[i],SS_Period,i,1);
               }            

            if(ShowADX)
               {
                  double DX;
                  if((DIp[i] + DIm[i])>0) 
                       DX = 100*MathAbs(iSsm((DIp[i] - DIm[i])/(DIp[i] + DIm[i]),SS_Period,i,2)); 
                  else DX = iSsm(0.00                                           ,SS_Period,i,2);
                  ADX[i] = sf*ADX[i+1] + DX/DMI.Length; 
                  if(ShowADXR)
                         ADXR[i] = 0.5*(ADX[i] + ADX[i+DMI.Length]);
               }
      }   
   return(0);      
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workSsm[][6];
#define _price  0
#define _ssm    1

double workSsmCoeffs[][4];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define Pi 3.14159265358979323846264338327950288

//
//
//
//
//

double iSsm(double price, double period, int i, int instanceNo)
{
   if (ArrayRange(workSsm,0) !=Bars)                 ArrayResize(workSsm,Bars);
   if (ArrayRange(workSsmCoeffs,0) < (instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if (workSsmCoeffs[instanceNo][_period] != period)
   {
      workSsmCoeffs[instanceNo][_period] = period;
      double a1 = MathExp(-1.414*Pi/period);
      double b1 = 2.0*a1*MathCos(1.414*Pi/period);
         workSsmCoeffs[instanceNo][_c2] = b1;
         workSsmCoeffs[instanceNo][_c3] = -a1*a1;
         workSsmCoeffs[instanceNo][_c1] = 1.0 - workSsmCoeffs[instanceNo][_c2] - workSsmCoeffs[instanceNo][_c3];
   }

   //
   //
   //
   //
   //

      i = Bars-i-1;
      int s = instanceNo*2;   
          workSsm[i][s+_price] = price;
          workSsm[i][s+_ssm]   = workSsmCoeffs[instanceNo][_c1]*(workSsm[i][s+_price]+workSsm[i-1][s+_price])/2.0 + 
                                 workSsmCoeffs[instanceNo][_c2]*workSsm[i-1][s+_ssm]                              + 
                                 workSsmCoeffs[instanceNo][_c3]*workSsm[i-2][s+_ssm];
   return(workSsm[i][s+_ssm]);
}
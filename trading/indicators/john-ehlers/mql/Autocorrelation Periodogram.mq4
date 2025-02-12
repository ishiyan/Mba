//+------------------------------------------------------------------+
//|                                  Autocorrelation Periodogram.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1  Blue
#property indicator_width1  3
//#property indicator_minimum 0
extern int    AvgLength      = 3;
extern int    StartFrom      = 10;
extern int    EndWith        = 50;
extern int    BarsToDraw     = 200;
extern int    BarsWidth      = 12;
extern string UniqueID       = "Autocorrelation Periodogram";
extern bool   GenericVisible = true;
extern double Staturation=1.0;
extern double Lightness=0.5;

double HP[],Filt[],MaxPwr[],DominantCycle[];
double Pwr[100],Corr[100];
double R[][100];
double a1,b1,coef1,coef2,coef3,alpha1;
double Sx,Sy,Sxx,Sxy,Syy,X,Y,SqSum,Spx,Sp;
double CosPart,SinPart;
int    Lag,period,m,M,N;
int    window;
//------------------------------------------------------------------

int init()
{
   int type = DRAW_NONE; if (GenericVisible) type = DRAW_LINE;
   IndicatorBuffers(4);
   SetIndexBuffer(0,DominantCycle);
   SetIndexStyle(0,type);
   SetIndexBuffer(1,Filt);
   SetIndexBuffer(2,HP);
   SetIndexBuffer(3,MaxPwr);

   ArrayInitialize(MaxPwr,0);
      
      StartFrom  = MathMax(StartFrom, 6);
      EndWith    = MathMin(EndWith  ,99);
      IndicatorShortName(UniqueID);
      
   a1=MathExp(-1.414*M_PI/10);
   b1=2*a1*MathCos(1.414*M_PI/10);
   coef2=b1;
   coef3=-a1*a1;
   coef1=1-coef2-coef3;
   
   alpha1=(MathCos(1.414*M_PI/48)+MathSin(1.414*M_PI/48)-1)/MathCos(1.414*M_PI/48);
   return(0);
}

int deinit()
{
   string lookFor       = UniqueID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i); if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}
//------------------------------------------------------------------
int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if (counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (ArrayRange(R,0)!=Bars)
         {
            ArrayResize(R,Bars);
         }            
         window = WindowFind(UniqueID);
         
         for (i=limit, r= Bars-i-1; i>=0 ; i--,r++)
         {
            HP[i]=(1-alpha1/2)*(1-alpha1/2)*(Close[i]-2*Close[i+1]+Close[i+2])+2*(1-alpha1)*HP[i+1]-(1-alpha1)*(1-alpha1)*HP[i+2];
   
            Filt[i]=coef1*(HP[i]+HP[i+1])/2+coef2*Filt[i+1]+coef3*Filt[i+2];
            
            
            for(Lag=0;Lag<EndWith;Lag++){
               M=AvgLength;
               if(M==0) M=Lag;
            
               Sx=0;
               Sy=0;
               Sxx=0;
               Sxy=0;
               Syy=0;
               for(m=0;m<M;m++){
                  X=Filt[i+m];
                  Y=Filt[i+m+Lag];
                  Sx=Sx+X;
                  Sy=Sy+Y;
                  Sxx=Sxx+X*X;
                  Sxy=Sxy+X*Y;
                  Syy=Syy+Y*Y;
                  }
               if((M*Sxx-Sx*Sx)*(M*Syy-Sy*Sy)>0) Corr[Lag]=(M*Sxy-Sx*Sy)/MathSqrt((M*Sxx-Sx*Sx)*(M*Syy-Sy*Sy));   
   
               }
               for(period=StartFrom;period<EndWith;period++){
                  CosPart=0;
                  SinPart=0;
                   for(N=3;N<48;N++){
                     CosPart=CosPart+Corr[N]*MathCos(2*M_PI*N/period);
                     SinPart=SinPart+Corr[N]*MathSin(2*M_PI*N/period);      
                     }
                  SqSum=CosPart*CosPart+SinPart*SinPart;
                  R[r][period]=0.2*SqSum+0.8*R[r-1][period]; 
                  }
               MaxPwr[i]=0.991*MaxPwr[i+1];
               
            for(period=StartFrom;period<EndWith;period++){
      
      
               if(R[r][period]>MaxPwr[i]) MaxPwr[i]=R[r][period];
               if(MaxPwr[i]>0) Pwr[period]=MathPow(R[r][period]/MaxPwr[i],1);
               } 
               
            Spx=0;
            Sp=0;   
            for(period=StartFrom;period<EndWith;period++){ 
               if(Pwr[period]>0.5){
                  Spx=Spx+period*Pwr[period];
                  Sp=Sp+Pwr[period];
                  }
               else{
                  Spx=Spx;
                  Sp=Sp;
                  }   
               } 
               
               if(Sp!=0) DominantCycle[i]=Spx/Sp;
               if(DominantCycle[i]<StartFrom) DominantCycle[i]=StartFrom;
               if(DominantCycle[i]>EndWith) DominantCycle[i]=EndWith;          
            
            
            
           
            for (int k=StartFrom; k<EndWith; k++)
            {
           
               
                  if (i<BarsToDraw)
                  {
                      
                     if(Pwr[k]>0.5){
                        double Hue=0.33*(Pwr[k]-0.5);
                        color RGB = HSLtoRGB(Hue, Staturation, Lightness);
                        }
                     else RGB = CLR_NONE;      
                     plot(k,k,k,i,i,RGB,BarsWidth);
                     
                  }                        
               
            }
         }
         

   SetIndexDrawBegin(0,Bars-BarsToDraw);
   return(0);
}
//------------------------------------------------------------------
void plot(string namex,double valueA, double valueB, int shiftA, int shiftB, color theColor, int width=0,int style=STYLE_SOLID)
{
   string   name = UniqueID+":"+namex+Time[shiftA];
   
   if (ObjectFind(name) == -1) 
   {
       ObjectCreate(name,OBJ_TREND,window,Time[shiftA],valueA,Time[shiftB],valueB);
          ObjectSet(name,OBJPROP_RAY,false);
          ObjectSet(name,OBJPROP_BACK,true);
          ObjectSet(name,OBJPROP_STYLE,style);
          ObjectSet(name,OBJPROP_WIDTH,width);
   }
   ObjectSet(name,OBJPROP_COLOR,theColor);
   ObjectSet(name,OBJPROP_PRICE1,valueA);
   ObjectSet(name,OBJPROP_PRICE2,valueB);
}
//------------------------------------------------------------------

double Hue_To_RGB(double P,double Q,double Tc){
        if(Tc<0) Tc+=1.0;
        if(Tc>1.0) Tc-=1.0;
        if(Tc<1.0/6.0) return(P+(Q-P)*6.0*Tc);
        if(Tc<1.0/2.0) return(Q);
        if(Tc<2.0/3.0) return(P+(Q-P)*((2.0/3.0)-Tc)*6.0);
        return(P);
}

color HSLtoRGB(double aH,double aS,double aL){
        if(aS==0){
                int oR=aL*255;
                int oG=aL*255;
                int oB=aL*255;
        }else{
                double Q;
                if(aL<0.5) Q=aL*(1.0+aS); else Q=(aL+aS)-(aS*aL);
                double P=2.0*aL-Q;
                oR=255.0*Hue_To_RGB(P,Q,aH+(1.0/3.0));
                oG=255.0*Hue_To_RGB(P,Q,aH);
                oB=255.0*Hue_To_RGB(P,Q,aH-(1.0/3.0));
        }
        return(0x100*0x100*oB+0x100*oG+oR);
}
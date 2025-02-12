//+------------------------------------------------------------------+
//|                                        Convolution Indicator.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property indicator_separate_window
#property indicator_buffers  1
#property indicator_color1   CLR_NONE
#property indicator_minimum  0
extern int    ShortestPeriod = 40;
extern int    LongestPeriod  = 80;
extern int    MaxPeriod      = 50;
extern int    BarsToDraw     = 100;
extern int    BarsWidth      = 10;
extern string UniqueID       = "Convolution Indicator";
extern double Saturation     = 1.0;
extern double Lightness      = 0.5;

double HP[],Filt[],test[];
double Corr[100],Slope[100];
double Convolution[100];
double a1,b1,coef1,coef2,coef3,alpha1;
double Sx,Sy,Sxx,Sxy,Syy,X,Y;
int    Lag,period,m,M,N;
int    window;
//------------------------------------------------------------------

int init(){
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(1,Filt);
   SetIndexBuffer(2,HP);
      
   SetIndexBuffer(0,test);
   MaxPeriod    = MathMin(MaxPeriod  ,99);
   IndicatorShortName(UniqueID);
      
   a1=MathExp(-1.414*M_PI/ShortestPeriod);
   b1=2*a1*MathCos(1.414*M_PI/ShortestPeriod);
   coef2=b1;
   coef3=-a1*a1;
   coef1=1-coef2-coef3;
   
   alpha1=(MathCos(1.414*2*M_PI/LongestPeriod)+MathSin(1.414*2*M_PI/LongestPeriod)-1)/MathCos(1.414*2*M_PI/LongestPeriod);
   //2*M_PI or just M_PI???
   //
   return(0);
   }

int deinit(){
   string lookFor       = UniqueID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--){
      string objectName = ObjectName(i); if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
      }
   return(0);
   }
//------------------------------------------------------------------
int start(){
   int i,k,counted_bars=IndicatorCounted();
   if (counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit = MathMin(Bars-counted_bars,Bars-1);
   
   window = WindowFind(UniqueID);
         
   for (i=limit; i>=0 ; i--){
      HP[i]=(1-alpha1/2)*(1-alpha1/2)*(Close[i]-2*Close[i+1]+Close[i+2])+2*(1-alpha1)*HP[i+1]-(1-alpha1)*(1-alpha1)*HP[i+2];
   
      Filt[i]=coef1*(HP[i]+HP[i+1])/2+coef2*Filt[i+1]+coef3*Filt[i+2];
                   
      for(N=1;N<MaxPeriod;N++){   
         Sx=0;
         Sy=0;
         Sxx=0;
         Sxy=0;
         Syy=0;
         
         for(m=1;m<=N;m++){
             X=Filt[i+m-1];
             Y=Filt[i+N-m+1];
             Sx=Sx+X;
             Sy=Sy+Y;
             Sxx=Sxx+X*X;
             Sxy=Sxy+X*Y;
             Syy=Syy+Y*Y;
             }
             
         if((N*Sxx-Sx*Sx)*(N*Syy-Sy*Sy)>0) Corr[N]=(N*Sxy-Sx*Sy)/MathSqrt((N*Sxx-Sx*Sx)*(N*Syy-Sy*Sy));   
         Slope[N]=1;
         int temp=MathCeil(N/2);
         if(Filt[i+temp]<Filt[i]) Slope[N]=-1;
         Convolution[N]=0.5*(1+(MathExp(3*Corr[N])-1)/(MathExp(3*Corr[N])+1));
         }
         
      test[i]=MathMin(MaxPeriod,i);
           
      for (k=3; k<MaxPeriod; k++){
         if (i<BarsToDraw){
            double Hue=0.18*(1-Slope[k]*Convolution[k]);
            double RGB = HSLtoRGB(Hue, Saturation, Lightness);        
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
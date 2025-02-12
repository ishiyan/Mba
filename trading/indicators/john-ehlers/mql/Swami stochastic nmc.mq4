//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1  White
#property indicator_width1  3
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1  20
#property indicator_level2  80
#property indicator_levelcolor DarkGray

//
//
//
//
//

extern int    Price          = PRICE_CLOSE; 
extern int    StartFrom      = 6;
extern int    EndWith        = 48;
extern int    BarsToDraw     = 150;
extern int    BarsWidth      = 4;
extern string UniqueID       = "Swami Stochastic 2";
extern bool   GenericVisible = true;
extern color  ColorUp        = LimeGreen;
extern color  ColorDown      = HotPink;

double stochastic[];
double prices[];
double step;
double totalSteps;
int    window;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int init()
{
   int type = DRAW_NONE; if (GenericVisible) type = DRAW_LINE;
   IndicatorBuffers(2);
      SetIndexBuffer(0,stochastic); SetIndexStyle(0,type);
      SetIndexBuffer(1,prices);
      
         //
         //
         //
         //
         //
         
         StartFrom  = MathMax(StartFrom, 6);
         EndWith    = MathMin(EndWith  ,99);
         totalSteps = EndWith-StartFrom+1.0;
         step       = 100.0/(totalSteps-1);
      IndicatorShortName(UniqueID);
   return(0);
}

//
//
//
//
//

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
//
//------------------------------------------------------------------
//
//
//
//
//

double avgDen[][100];
double avgNum[][100];
double avgSto[][100];
int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if (counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (ArrayRange(avgDen,0)!=Bars)
         {
            ArrayResize(avgDen,Bars);
            ArrayResize(avgNum,Bars);
            ArrayResize(avgSto,Bars);
         }            
         window = WindowFind(UniqueID);

         //
         //
         //
         //
         //

         for (i=limit, r= Bars-i-1; i>=0 ; i--,r++) prices[i] = iMA(NULL,0,1,0,MODE_SMA,Price,i); limit = MathMin(limit,MathMin(BarsToDraw+EndWith,Bars-1));
         for (i=limit, r= Bars-i-1; i>=0 ; i--,r++)
         {
            double high   = prices[i];
            double low    = prices[i];
            
            //
            //
            //
            //
            //
   
            stochastic[i] = 0;         
            for (int k=1; k<EndWith; k++)
            {
               high = MathMax(high,prices[i+k]);
               low  = MathMin(low ,prices[i+k]);
               if (k>=StartFrom)
               {
                  avgNum[r][k] = 0.5*avgNum[r-1][k]+0.5*(prices[i]-low);
                  avgDen[r][k] = 0.5*avgDen[r-1][k]+0.5*(high     -low);
                  avgSto[r][k] = 0;
                  if (avgDen[r][k] != 0) avgSto[r][k] = 0.2*(avgNum[r][k]/avgDen[r][k])+0.8*avgSto[r-1][k];
                  if (i<BarsToDraw)
                  {
                     double colorR = 255;
                     double colorG = 255;
                     double colorB = 0;
                     if (avgSto[r][k] >= 0.5)
                           colorR = 255.0*(2.0-2.0*avgSto[r][k]);
                     else  colorG = 255.0     *2.0*avgSto[r][k];
                        
                     //
                     //
                     //
                     //
                     //
                        
                     plot(k,(k-StartFrom)*step,(k-StartFrom+1)*step,i,i,gradientColor(avgSto[r][k]*50.0,51,ColorDown,ColorUp),BarsWidth);
                     
                  }                        
               }
               stochastic[i] += avgSto[r][k];
            }
            stochastic[i] /= totalSteps/100.0;
         }
         
   //
   //
   //
   //
   //

   SetIndexDrawBegin(0,Bars-BarsToDraw);
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

void plot(string namex,double valueA, double valueB, int shiftA, int shiftB, color theColor, int width=0,int style=STYLE_SOLID)
{
   string   name = UniqueID+":"+namex+Time[shiftA];
   
   //
   //
   //
   //
   //
   
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
//
//------------------------------------------------------------------
//
//
//
//
//

color gradientColor(int tstep, int ttotalSteps, color from, color to)
{
   tstep = MathMax(MathMin(tstep,ttotalSteps-1),0);
      color newBlue  = getColor(tstep,ttotalSteps,(from & 0XFF0000)>>16,(to & 0XFF0000)>>16)<<16;
      color newGreen = getColor(tstep,ttotalSteps,(from & 0X00FF00)>> 8,(to & 0X00FF00)>> 8) <<8;
      color newRed   = getColor(tstep,ttotalSteps,(from & 0X0000FF)    ,(to & 0X0000FF)    )    ;
      return(newBlue+newGreen+newRed);
}
color getColor(int stepNo, int ttotalSteps, color from, color to)
{
   double tstep = (from-to)/(ttotalSteps-1.0);
   return(MathRound(from-tstep*stepNo));
}
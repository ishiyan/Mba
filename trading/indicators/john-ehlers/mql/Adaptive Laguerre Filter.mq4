//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 LimeGreen
#property indicator_color2 Orange
#property indicator_color3 Orange
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2

extern int LookBack = 20;
extern int Median   = 5;
extern int Price    = PRICE_MEDIAN;

double Filter[];
double Filterda[];
double Filterdb[];
double Diff[];
double Slope[];
double sortDiff[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init() 
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,Filter);
   SetIndexBuffer(1,Filterda);
   SetIndexBuffer(2,Filterdb);
   SetIndexBuffer(3,Diff);
   SetIndexBuffer(4,Slope);
      ArrayResize(sortDiff,Median);
   return (0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         
         //
         //
         //
         //
         //

   if (Slope[limit]==-1) CleanPoint(limit,Filterda,Filterdb);
   for (int i=limit; i>=0; i--)   
   {
      double price   = iMA(NULL,0,1,0,MODE_SMA,Price,i);
             Diff[i] = MathAbs(price - Filter[i+1]);
      double hi    = Diff[ArrayMaximum(Diff,LookBack,i)];
      double lo    = Diff[ArrayMinimum(Diff,LookBack,i)];
      double alpha = 0;
         if (hi!=lo)    
         {
            for (int j=0; j<Median; j++) sortDiff[j] = (Diff[i+j]-lo)/(hi-lo);
               ArraySort(sortDiff,WHOLE_ARRAY,0,MODE_ASCEND);
                  if (MathMod(Median,2.0) != 0)   alpha = sortDiff[Median/2];         
                  else                            alpha = (sortDiff[Median/2]+sortDiff[(Median/2)-1])/2;
         }
      Filter[i]   = iLaGuerreFilter(price, 1.0-alpha, i, 0);
      Filterda[i] = EMPTY_VALUE;
      Filterdb[i] = EMPTY_VALUE;
      Slope[i]    = Slope[i+1];
         if (Filter[i]>Filter[i+1]) Slope[i] =  1;
         if (Filter[i]<Filter[i+1]) Slope[i] = -1;
         if (Slope[i] == -1) PlotPoint(i,Filterda,Filterdb,Filter);
   }
   return (0);   
}


//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workLagFil[][4];
double iLaGuerreFilter(double price, double gamma, int i, int instanceNo=0)
{
   if (ArrayRange(workLagFil,0)!=Bars) ArrayResize(workLagFil,Bars); i=Bars-i-1; instanceNo*=4;
   if (gamma<=0) return(price);

   //
   //
   //
   //
   //
      
   workLagFil[i][instanceNo+0] = (1.0 - gamma)*price                                                + gamma*workLagFil[i-1][instanceNo+0];
	workLagFil[i][instanceNo+1] = -gamma*workLagFil[i][instanceNo+0] + workLagFil[i-1][instanceNo+0] + gamma*workLagFil[i-1][instanceNo+1];
	workLagFil[i][instanceNo+2] = -gamma*workLagFil[i][instanceNo+1] + workLagFil[i-1][instanceNo+1] + gamma*workLagFil[i-1][instanceNo+2];
	workLagFil[i][instanceNo+3] = -gamma*workLagFil[i][instanceNo+2] + workLagFil[i-1][instanceNo+2] + gamma*workLagFil[i-1][instanceNo+3];

   //
   //
   //
   //
   //
 
   return((workLagFil[i][instanceNo+0]+2.0*workLagFil[i][instanceNo+1]+2.0*workLagFil[i][instanceNo+2]+workLagFil[i][instanceNo+3])/6.0);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
}
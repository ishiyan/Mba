//+------------------------------------------------------------------+
//|                                                alert_gramski.mq4 |
//+------------------------------------------------------------------+

extern double Laguerre_parameter=0.7;
extern double Laguerre_level1=0.15;
extern double Laguerre_level2=0.75;


//parameters from AbsolteStrenghtHist0o_v1
extern int       Mode   =  0; // 0-RSI method; 1-Stoch method
extern int       Length =  9; // Period
extern int       Smooth =  1; // Period of smoothing
extern int       Signal =  4; // Period of Signal Line
extern int       Price  =  0; // Price mode : 0-Close,1-Open,2-High,3-Low,4-Median,5-Typical,6-Weighted
extern int       ModeMA =  3; // Mode of Moving Average
extern int       Mode_Histo  = 3; 



int ob=0;

bool bull1=false;
bool bear2=false;

int init(){return(0);}
int deinit(){return(0);}
int start()
  {
   double l1=iCustom(Symbol(),0,"Laguerre RSI",Laguerre_parameter,0,1);
   double l0=iCustom(Symbol(),0,"Laguerre RSI",Laguerre_parameter,0,0);
   
   double a_blue=iCustom(Symbol(),0,"AbsoluteStrenghtHisto_v1",Mode,Length,Smooth,Signal,Price,ModeMA,Mode_Histo,0,0);
   double a_red=iCustom(Symbol(),0,"AbsoluteStrenghtHisto_v1",Mode,Length,Smooth,Signal,Price,ModeMA,Mode_Histo,1,0);   
   //bull signals
   if (l1<Laguerre_level1 && l0>=Laguerre_level1 && a_blue>0 && !bull1){
         bull1=true;
         ObjectCreate("obj"+ob,22,0,Time[0],Open[0]);
         ObjectSet("obj"+ob,6,Blue);
         ob++;      
         PlaySound("Alert.wav");
         Alert("Bull signal at Laguerre:"+Laguerre_level1);
   
   
   }
   //bear signals

  
    if (l1>Laguerre_level2 && l0<=Laguerre_level2 && a_red>0 && !bear2){
         bear2=true;
         ObjectCreate("obj"+ob,22,0,Time[0],Open[0]);
         ObjectSet("obj"+ob,6,Red);
         ObjectSet("obj"+ob,14,242);
         ob++;
         PlaySound("Alert.wav");
         Alert("Bear signal at Laguerre:"+Laguerre_level2);
   }  
   
     
   
   if (a_red>0) {bull1=false;}
   if (a_blue>0) {bear2=false;}
   
   
   return(0);
  }


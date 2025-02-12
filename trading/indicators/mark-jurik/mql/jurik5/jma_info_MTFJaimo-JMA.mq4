//+------------------------------------------------------------------+
//|                                                MTF Jaimo-JMA.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Darkkiller"
#property indicator_chart_window
#property indicator_buffers 0

extern int Corner=3;
extern int x_distance=0;
extern int y_distance=0;
extern int window=0;
extern color title    =DimGray;
extern color stronguptrend    =Lime;
extern color strongdowntrend  =Red;
extern color weakuptrend      =LightGreen;
extern color weakdowntrend    =Pink;

int init()
  {
   
   string label6xx = "Jaimo-JMA_Title";
   ObjectDelete(label6xx);
   ObjectCreate( label6xx, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(label6xx,"___________Jaimo-JMA__________",9, "Arial Bold", title);
   ObjectSet( label6xx, OBJPROP_CORNER, Corner );
   ObjectSet( label6xx, OBJPROP_XDISTANCE, 10+x_distance );
   ObjectSet( label6xx, OBJPROP_YDISTANCE, 40+y_distance );

   string signature = "dk";
   ObjectDelete(signature);
   ObjectCreate( signature, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(signature,"|dk|",7, "Arial Bold", title);
   ObjectSet( signature, OBJPROP_CORNER, Corner );
   ObjectSet( signature, OBJPROP_XDISTANCE, 10+x_distance );
   ObjectSet( signature, OBJPROP_YDISTANCE, 42+y_distance );
   
//----
   return(0);
  }

int deinit()
  {

   ObjectDelete("Jaimo-JMA_Title");
   ObjectDelete("Jaimo-JMA MN1");  
   ObjectDelete("Jaimo-JMA W1");   
   ObjectDelete("Jaimo-JMA D1");
   ObjectDelete("Jaimo-JMA H4");
   ObjectDelete("Jaimo-JMA H1");
   ObjectDelete("Jaimo-JMA M30");
   ObjectDelete("Jaimo-JMA M15");
   ObjectDelete("Jaimo-JMA M5");
   ObjectDelete("Jaimo-JMA M1");
   ObjectDelete("dk");
   ObjectDelete("Jaimo-JMA MN1 Arrow");
   ObjectDelete("Jaimo-JMA W1 Arrow");
   ObjectDelete("Jaimo-JMA D1 Arrow");
   ObjectDelete("Jaimo-JMA H4 Arrow");
   ObjectDelete("Jaimo-JMA H1 Arrow");
   ObjectDelete("Jaimo-JMA M30 Arrow");
   ObjectDelete("Jaimo-JMA M15 Arrow");
   ObjectDelete("Jaimo-JMA M5 Arrow");
   ObjectDelete("Jaimo-JMA M1 Arrow");
   
   return(0);
  }

int start()
  {
   int    counted_bars=IndicatorCounted();
   
   int limit=Bars-counted_bars;
   if(counted_bars>0) limit++;
   
   string Sign,Arrow;   
   color Col;
  
   ////////////////////////////////////////////////////////////////////////////////////////////////////   
   double iJaimo_Curr=iCustom(NULL, PERIOD_MN1, "Jaimo-JMA",0,1);
   double iJaimo_Prev=iCustom(NULL, PERIOD_MN1, "Jaimo-JMA",1,0);
   //if (iJaimo_Curr==iJaimo_Prev) { Sign="ó"; Col=DarkOrange; } //Sideway   
   if (iJaimo_Curr>iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="MN"; Arrow="p";Col=stronguptrend; } //Trend Up Strong
   if (iJaimo_Curr<iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="MN"; Arrow="q";Col=strongdowntrend; } //Trend Down Strong
   if (iJaimo_Curr>iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="MN"; Arrow="k";Col=weakuptrend; } //Trend Up Weak
   if (iJaimo_Curr<iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="MN"; Arrow="m";Col=weakdowntrend; } //Trend Down Weak
   string sign112xx = "Jaimo-JMA MN1";
   ObjectDelete(sign112xx);
   ObjectCreate(sign112xx, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(sign112xx, Sign ,9, "Arial Bold", Col);
   ObjectSet(sign112xx, OBJPROP_CORNER, Corner );
   ObjectSet(sign112xx, OBJPROP_XDISTANCE, 13+x_distance );
   ObjectSet(sign112xx, OBJPROP_YDISTANCE, 10+y_distance );
   
   
   string signarrow_MN1 = "Jaimo-JMA MN1 Arrow";
   ObjectDelete(signarrow_MN1);
   ObjectCreate(signarrow_MN1, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(signarrow_MN1, Arrow ,9, "Wingdings 3", Col);
   ObjectSet(signarrow_MN1, OBJPROP_CORNER, Corner );
   ObjectSet(signarrow_MN1, OBJPROP_XDISTANCE, 16+x_distance );
   ObjectSet(signarrow_MN1, OBJPROP_YDISTANCE, 25+y_distance );
   ////////////////////////////////////////////////////////////////////////////////////////////////////   
   
   ////////////////////////////////////////////////////////////////////////////////////////////////////         
   iJaimo_Curr=iCustom(NULL, PERIOD_W1, "Jaimo-JMA",0,1);
   iJaimo_Prev=iCustom(NULL, PERIOD_W1, "Jaimo-JMA",1,0);
   //if (iJaimo_Curr==iJaimo_Prev) { Sign="ó"; Col=DarkOrange; } //Sideway   
   if (iJaimo_Curr>iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="W1"; Arrow="p";Col=stronguptrend; } //Trend Up Strong
   if (iJaimo_Curr<iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="W1"; Arrow="q";Col=strongdowntrend; } //Trend Down Strong
   if (iJaimo_Curr>iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="W1"; Arrow="k";Col=weakuptrend; } //Trend Up Weak
   if (iJaimo_Curr<iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="W1"; Arrow="m";Col=weakdowntrend; } //Trend Down Weak
   string sign1xx = "Jaimo-JMA W1";
   ObjectDelete(sign1xx);
   ObjectCreate(sign1xx, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(sign1xx, Sign ,9, "Arial Bold", Col);
   ObjectSet(sign1xx, OBJPROP_CORNER, Corner );
   ObjectSet(sign1xx, OBJPROP_XDISTANCE, 35+x_distance );
   ObjectSet(sign1xx, OBJPROP_YDISTANCE, 10+y_distance );

   string signarrow_W1 = "Jaimo-JMA W1 Arrow";
   ObjectDelete(signarrow_W1);
   ObjectCreate(signarrow_W1, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(signarrow_W1, Arrow ,9, "Wingdings 3", Col);
   ObjectSet(signarrow_W1, OBJPROP_CORNER, Corner );
   ObjectSet(signarrow_W1, OBJPROP_XDISTANCE, 38+x_distance );
   ObjectSet(signarrow_W1, OBJPROP_YDISTANCE, 25+y_distance );
   ////////////////////////////////////////////////////////////////////////////////////////////////////   

   ////////////////////////////////////////////////////////////////////////////////////////////////////   
   iJaimo_Curr=iCustom(NULL, PERIOD_D1, "Jaimo-JMA",0,1);
   iJaimo_Prev=iCustom(NULL, PERIOD_D1, "Jaimo-JMA",1,0);
   //if (iJaimo_Curr==iJaimo_Prev) { Sign="ó"; Col=DarkOrange; } //Sideway   
   if (iJaimo_Curr>iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="D1"; Arrow="p";Col=stronguptrend; } //Trend Up Strong
   if (iJaimo_Curr<iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="D1"; Arrow="q";Col=strongdowntrend; } //Trend Down Strong
   if (iJaimo_Curr>iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="D1"; Arrow="k";Col=weakuptrend; } //Trend Up Weak
   if (iJaimo_Curr<iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="D1"; Arrow="m";Col=weakdowntrend; } //Trend Down Weak
   string sign2xx = "Jaimo-JMA D1";
   ObjectDelete(sign2xx);
   ObjectCreate(sign2xx, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(sign2xx, Sign ,9, "Arial Bold", Col);
   ObjectSet(sign2xx, OBJPROP_CORNER, Corner );
   ObjectSet(sign2xx, OBJPROP_XDISTANCE, 60+x_distance );
   ObjectSet(sign2xx, OBJPROP_YDISTANCE, 10+y_distance );
   
   string signarrow_D1 = "Jaimo-JMA D1 Arrow";
   ObjectDelete(signarrow_D1);
   ObjectCreate(signarrow_D1, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(signarrow_D1, Arrow ,9, "Wingdings 3", Col);
   ObjectSet(signarrow_D1, OBJPROP_CORNER, Corner );
   ObjectSet(signarrow_D1, OBJPROP_XDISTANCE, 63+x_distance );
   ObjectSet(signarrow_D1, OBJPROP_YDISTANCE, 25+y_distance );
   ////////////////////////////////////////////////////////////////////////////////////////////////////   
  
   ////////////////////////////////////////////////////////////////////////////////////////////////////   
   iJaimo_Curr=iCustom(NULL, PERIOD_H4, "Jaimo-JMA",0,1);
   iJaimo_Prev=iCustom(NULL, PERIOD_H4, "Jaimo-JMA",1,0);
   //if (iJaimo_Curr==iJaimo_Prev) { Sign="ó"; Col=DarkOrange; } //Sideway   
   if (iJaimo_Curr>iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="H4";Arrow="p"; Col=stronguptrend; } //Trend Up Strong
   if (iJaimo_Curr<iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="H4";Arrow="q"; Col=strongdowntrend; } //Trend Down Strong
   if (iJaimo_Curr>iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="H4"; Arrow="k";Col=weakuptrend; } //Trend Up Weak
   if (iJaimo_Curr<iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="H4"; Arrow="m";Col=weakdowntrend; } //Trend Down Weak
   string sign13xx = "Jaimo-JMA H4";
   ObjectDelete(sign13xx);
   ObjectCreate(sign13xx, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(sign13xx, Sign ,9, "Arial Bold", Col);
   ObjectSet(sign13xx, OBJPROP_CORNER, Corner );
   ObjectSet(sign13xx, OBJPROP_XDISTANCE, 80+x_distance );
   ObjectSet(sign13xx, OBJPROP_YDISTANCE, 10+y_distance );
   
   string signarrow_H4 = "Jaimo-JMA H4 Arrow";
   ObjectDelete(signarrow_H4);
   ObjectCreate(signarrow_H4, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(signarrow_H4, Arrow ,9, "Wingdings 3", Col);
   ObjectSet(signarrow_H4, OBJPROP_CORNER, Corner );
   ObjectSet(signarrow_H4, OBJPROP_XDISTANCE, 83+x_distance );
   ObjectSet(signarrow_H4, OBJPROP_YDISTANCE, 25+y_distance );
   ////////////////////////////////////////////////////////////////////////////////////////////////////   
   
   
   ////////////////////////////////////////////////////////////////////////////////////////////////////   
   iJaimo_Curr=iCustom(NULL, PERIOD_H1, "Jaimo-JMA",0,1);
   iJaimo_Prev=iCustom(NULL, PERIOD_H1, "Jaimo-JMA",1,0);
   //if (iJaimo_Curr==iJaimo_Prev) { Sign="ó"; Col=DarkOrange; } //Sideway   
   if (iJaimo_Curr>iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="H1"; Arrow="p";Col=stronguptrend; } //Trend Up Strong
   if (iJaimo_Curr<iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="H1"; Arrow="q";Col=strongdowntrend; } //Trend Down Strong
   if (iJaimo_Curr>iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="H1"; Arrow="k";Col=weakuptrend; } //Trend Up Weak
   if (iJaimo_Curr<iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="H1"; Arrow="m";Col=weakdowntrend; } //Trend Down Weak
   string sign23xx = "Jaimo-JMA H1";
   ObjectDelete(sign23xx);
   ObjectCreate(sign23xx, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(sign23xx, Sign ,9, "Arial Bold", Col);
   ObjectSet(sign23xx, OBJPROP_CORNER, Corner );
   ObjectSet(sign23xx, OBJPROP_XDISTANCE, 100+x_distance );
   ObjectSet(sign23xx, OBJPROP_YDISTANCE, 10+y_distance );

   string signarrow_H1 = "Jaimo-JMA H1 Arrow";
   ObjectDelete(signarrow_H1);
   ObjectCreate(signarrow_H1, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(signarrow_H1, Arrow ,9, "Wingdings 3", Col);
   ObjectSet(signarrow_H1, OBJPROP_CORNER, Corner );
   ObjectSet(signarrow_H1, OBJPROP_XDISTANCE, 103+x_distance );
   ObjectSet(signarrow_H1, OBJPROP_YDISTANCE, 25+y_distance );
   ////////////////////////////////////////////////////////////////////////////////////////////////////   
 
   ////////////////////////////////////////////////////////////////////////////////////////////////////   
   iJaimo_Curr=iCustom(NULL, PERIOD_M30, "Jaimo-JMA",0,1);
   iJaimo_Prev=iCustom(NULL, PERIOD_M30, "Jaimo-JMA",1,0);
   //if (iJaimo_Curr==iJaimo_Prev) { Sign="ó"; Col=DarkOrange; } //Sideway   
   if (iJaimo_Curr>iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="M30"; Arrow="p";Col=stronguptrend; } //Trend Up Strong
   if (iJaimo_Curr<iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="M30"; Arrow="q";Col=strongdowntrend; } //Trend Down Strong
   if (iJaimo_Curr>iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="M30"; Arrow="k";Col=weakuptrend; } //Trend Up Weak
   if (iJaimo_Curr<iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="M30"; Arrow="m";Col=weakdowntrend; } //Trend Down Weak
   string sign33xx = "Jaimo-JMA M30";
   ObjectDelete(sign33xx);
   ObjectCreate(sign33xx, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(sign33xx, Sign ,9, "Arial Bold", Col);
   ObjectSet(sign33xx, OBJPROP_CORNER, Corner );
   ObjectSet(sign33xx, OBJPROP_XDISTANCE, 120+x_distance );
   ObjectSet(sign33xx, OBJPROP_YDISTANCE, 10+y_distance );

   string signarrow_m30 = "Jaimo-JMA M30 Arrow";
   ObjectDelete(signarrow_m30);
   ObjectCreate(signarrow_m30, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(signarrow_m30, Arrow ,9, "Wingdings 3", Col);
   ObjectSet(signarrow_m30, OBJPROP_CORNER, Corner );
   ObjectSet(signarrow_m30, OBJPROP_XDISTANCE, 123+x_distance );
   ObjectSet(signarrow_m30, OBJPROP_YDISTANCE, 25+y_distance );
   ////////////////////////////////////////////////////////////////////////////////////////////////////   


   ////////////////////////////////////////////////////////////////////////////////////////////////////   
   iJaimo_Curr=iCustom(NULL, PERIOD_M15, "Jaimo-JMA",0,1);
   iJaimo_Prev=iCustom(NULL, PERIOD_M15, "Jaimo-JMA",1,0);
   //if (iJaimo_Curr==iJaimo_Prev) { Sign="ó"; Col=DarkOrange; } //Sideway   
   if (iJaimo_Curr>iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="M15"; Arrow="p";Col=stronguptrend; } //Trend Up Strong
   if (iJaimo_Curr<iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="M15"; Arrow="q";Col=strongdowntrend; } //Trend Down Strong
   if (iJaimo_Curr>iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="M15"; Arrow="k";Col=weakuptrend; } //Trend Up Weak
   if (iJaimo_Curr<iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="M15"; Arrow="m";Col=weakdowntrend; } //Trend Down Weak
   string sign35xx = "Jaimo-JMA M15";
   ObjectDelete(sign35xx);
   ObjectCreate(sign35xx, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(sign35xx, Sign ,9, "Arial Bold", Col);
   ObjectSet(sign35xx, OBJPROP_CORNER, Corner );
   ObjectSet(sign35xx, OBJPROP_XDISTANCE, 150+x_distance );
   ObjectSet(sign35xx, OBJPROP_YDISTANCE, 10+y_distance );
   
   string signarrow_m15 = "Jaimo-JMA M15 Arrow";
   ObjectDelete(signarrow_m15);
   ObjectCreate(signarrow_m15, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(signarrow_m15, Arrow ,9, "Wingdings 3", Col);
   ObjectSet(signarrow_m15, OBJPROP_CORNER, Corner );
   ObjectSet(signarrow_m15, OBJPROP_XDISTANCE, 153+x_distance );
   ObjectSet(signarrow_m15, OBJPROP_YDISTANCE, 25+y_distance );
   ////////////////////////////////////////////////////////////////////////////////////////////////////   
   
   
   ////////////////////////////////////////////////////////////////////////////////////////////////////   
   iJaimo_Curr=iCustom(NULL, PERIOD_M5, "Jaimo-JMA",0,1);
   iJaimo_Prev=iCustom(NULL, PERIOD_M5, "Jaimo-JMA",1,0);
   //if (iJaimo_Curr==iJaimo_Prev) { Sign="ó"; Col=DarkOrange; } //Sideway   
   if (iJaimo_Curr>iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="M5"; Arrow="p"; Col=stronguptrend; } //Trend Up Strong
   if (iJaimo_Curr<iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="M5"; Arrow="q"; Col=strongdowntrend; } //Trend Down Strong
   if (iJaimo_Curr>iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="M5"; Arrow="k";Col=weakuptrend; } //Trend Up Weak
   if (iJaimo_Curr<iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="M5"; Arrow="m"; Col=weakdowntrend; } //Trend Down Weak
   string sign34xx = "Jaimo-JMA M5";
   ObjectDelete(sign34xx);
   ObjectCreate(sign34xx, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(sign34xx, Sign ,9, "Arial Bold", Col);
   ObjectSet(sign34xx, OBJPROP_CORNER, Corner );
   ObjectSet(sign34xx, OBJPROP_XDISTANCE, 180+x_distance );
   ObjectSet(sign34xx, OBJPROP_YDISTANCE, 10+y_distance );
     
      string signarrow_m5 = "Jaimo-JMA M5 Arrow";
   ObjectDelete(signarrow_m5);
   ObjectCreate(signarrow_m5, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(signarrow_m5, Arrow ,9, "Wingdings 3", Col);
   ObjectSet(signarrow_m5, OBJPROP_CORNER, Corner );
   ObjectSet(signarrow_m5, OBJPROP_XDISTANCE, 183+x_distance );
   ObjectSet(signarrow_m5, OBJPROP_YDISTANCE, 25+y_distance );
   ////////////////////////////////////////////////////////////////////////////////////////////////////   
   
   
   ////////////////////////////////////////////////////////////////////////////////////////////////////    
   iJaimo_Curr=iCustom(NULL, PERIOD_M1, "Jaimo-JMA",0,1);
   iJaimo_Prev=iCustom(NULL, PERIOD_M1, "Jaimo-JMA",1,0);
   //if (iJaimo_Curr==iJaimo_Prev) { Sign="ó"; Col=DarkOrange; } //Sideway   
   if (iJaimo_Curr>iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="M1"; Arrow="p"; Col=stronguptrend; }//Trend Up Strong
   if (iJaimo_Curr<iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="M1"; Arrow="q"; Col=strongdowntrend; }//Trend Down Strong
   if (iJaimo_Curr>iJaimo_Prev && Close[0]<iJaimo_Curr) { Sign="M1"; Arrow="k"; Col=weakuptrend; } //Trend Up Weak
   if (iJaimo_Curr<iJaimo_Prev && Close[0]>iJaimo_Curr) { Sign="M1"; Arrow="m"; Col=weakdowntrend; } //Trend Down Weak
   string sign343xx = "Jaimo-JMA M1";
   ObjectDelete(sign343xx);
   ObjectCreate(sign343xx, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(sign343xx, Sign ,9, "Arial Bold", Col);
   ObjectSet(sign343xx, OBJPROP_CORNER, Corner );
   ObjectSet(sign343xx, OBJPROP_XDISTANCE, 200+x_distance );
   ObjectSet(sign343xx, OBJPROP_YDISTANCE, 10+y_distance );

   string signarrow_m1 = "Jaimo-JMA M1 Arrow";
   ObjectDelete(signarrow_m1);
   ObjectCreate(signarrow_m1, OBJ_LABEL, window, 0, 0 );
   ObjectSetText(signarrow_m1, Arrow ,9, "Wingdings 3", Col);
   ObjectSet(signarrow_m1, OBJPROP_CORNER, Corner );
   ObjectSet(signarrow_m1, OBJPROP_XDISTANCE, 203+x_distance );
   ObjectSet(signarrow_m1, OBJPROP_YDISTANCE, 25+y_distance );
   ////////////////////////////////////////////////////////////////////////////////////////////////////   


   return(0);
  }


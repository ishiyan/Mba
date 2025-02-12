//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                       3Color.mqh | 
//|                           Copyright © 2006,     Nikolay Kositsin | 
//|                               Khabarovsk,  farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
/*
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 6
//---- цвета индикатора
#property indicator_color1 Lime
#property indicator_color2 Lime
#property indicator_color3 Red 
#property indicator_color4 Red 
#property indicator_color5 Gray
#property indicator_color6 Gray
*/
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА юююююююююююююююююююююююжжжжжжжжжжжжж+
extern int IndShift = 0;  // cдвиг индикатора вдоль оси времени 
extern int TrendMinimum = 0;  // минимальная скорость тренда в пунктах
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Buffer1 [];
double Buffer2 [];
double Buffer3 [];
double Buffer4 [];
double Buffer5 []; 
double Buffer6 []; 
double Value_Buffer []; 
//----  логические переменные
bool   ReStart=false;
//---- целые переменные
int    ind_N1,ind_N2,bar;
//---- переменные с плавающей точкой 
double Value1,Value0,Trend0,Trend1,Trend2,MINIMUM;
//----+ Введение функции INDICATOR_COUNTED 
//----+ (файл INDICATOR_COUNTED.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| Three Color initialization function                              |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init() 
  { 
//---- стили изображения индикатора
   SetIndexStyle  (0, DRAW_LINE); 
   SetIndexStyle  (1, DRAW_LINE);
   SetIndexStyle  (2, DRAW_LINE);
   SetIndexStyle  (3, DRAW_LINE); 
   SetIndexStyle  (4, DRAW_LINE);
   SetIndexStyle  (5, DRAW_LINE); 
//---- 8 индикаторных буфферов использованы для счёта. 
   IndicatorBuffers(7);   
   SetIndexBuffer (0, Buffer1);
   SetIndexBuffer (1, Buffer2);
   SetIndexBuffer (2, Buffer3);   
   SetIndexBuffer (3, Buffer4);
   SetIndexBuffer (4, Buffer5);   
   SetIndexBuffer (5, Buffer6);   
   SetIndexBuffer (6, Value_Buffer);     
//---- установка значений индикатора, которые не будут видимы на графике 
   SetIndexEmptyValue(0,EmptyValue);
   SetIndexEmptyValue(1,EmptyValue);
   SetIndexEmptyValue(2,EmptyValue);
   SetIndexEmptyValue(3,EmptyValue);
   SetIndexEmptyValue(4,EmptyValue);
   SetIndexEmptyValue(5,EmptyValue); 
//----  
//---- установка номера бара, начиная с которого будет отрисовываться индикатор  
   int drow_begin=COUNT_begin()+IndShift+3;  
   SetIndexDrawBegin(0,drow_begin);
   SetIndexDrawBegin(1,drow_begin);
   SetIndexDrawBegin(2,drow_begin); 
   SetIndexDrawBegin(3,drow_begin);
   SetIndexDrawBegin(4,drow_begin);
   SetIndexDrawBegin(5,drow_begin); 
//----   
   IndicatorDigits(MarketInfo(Symbol(),digits()));
//---- имена для окон данных и лэйбы для субъокон.
   IndicatorShortName(""+Label+"");
   SetIndexLabel(0,"Up_Trend");
   SetIndexLabel(1,"Up_Trend");
   SetIndexLabel(2,"Down_Trend");
   SetIndexLabel(3,"Down_Trend");
   SetIndexLabel(4,"Straight_Trend");
   SetIndexLabel(5,"Straight_Trend");  
//----   
   MINIMUM=TrendMinimum*Point;
//---- завершение инициализации
return(0); 
  } 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|  Three Color CODE                                                |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start() 
{ 
//---- получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int limit,MaxBar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1); 
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBar=Bars-1-COUNT_begin()-3;           
//---- Загрузка значений исходного индикатора в буффер
for(bar=limit; bar>=0; bar--)Value_Buffer[bar]=INDICATOR(bar);
//---- корекция максимального номера самого старого бара, начиная с которого будет произедён пересчёт новых баров 
//---- инициализация нуля
if (limit>MaxBar)
 {
  limit=MaxBar; 
  for(int ttt=Bars-1;ttt>MaxBar;ttt--)
   {
    Buffer1[ttt]=EmptyValue; Buffer2[ttt]=EmptyValue; 
    Buffer3[ttt]=EmptyValue; Buffer4[ttt]=EmptyValue;
    Buffer5[ttt]=EmptyValue; Buffer6[ttt]=EmptyValue; 
   }
 }
bar=limit;
//---- ОСНОВНОЙ ЦИКЛ РАСЧЁТА ИНДИКАТОРА
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|++++++++++++++++++++++++ <<< Three Color Indicator code >>> ++++++++++++++++++++++++++++++++++++++++++++|
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
// Input indicator buffer: Value_Buffer.                                                                   |
// Output indicator buffers: Buffer1, Buffer2, Buffer1, Buffer2, Buffer1, Buffer2.                         |                                                                                  |                                                                                          
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+   
while(bar>=0)   
 {    
     if (!ReStart)
       { 
        Trend2=Value_Buffer[bar+2]-Value_Buffer[bar+3]; 
        Trend1=Value_Buffer[bar+1]-Value_Buffer[bar+2];
          
        if (MathAbs(Trend2)<MINIMUM)Trend2=0;
        if (MathAbs(Trend1)<MINIMUM)Trend1=0;  
             
        if (Trend2>0) ind_N2=1; else {if (Trend2<0) ind_N2=3; else ind_N2=5;}    
        if (Trend1>0) ind_N1=1; else {if (Trend1<0) ind_N1=3; else ind_N1=5;}
       } 
     //----+---------------------------------------------------------------------------------------------------------------+  
     if((ReStart)&&(bar==limit))
       {
        Trend2=Value_Buffer[bar+2]-Value_Buffer[bar+3]; 
        Trend1=Value_Buffer[bar+1]-Value_Buffer[bar+2];
        
        if (MathAbs(Trend2)<MINIMUM)Trend2=0;
        if (MathAbs(Trend1)<MINIMUM)Trend1=0;   
        
        for(int iii=bar;iii<=bar;iii++)
         {
          if (Trend2> 0){if (Buffer1[iii+2]!=EmptyValue){ind_N2=1;break;} if (Buffer2[iii+2]!=EmptyValue){ind_N2=2;break;}}
          if (Trend2< 0){if (Buffer3[iii+2]!=EmptyValue){ind_N2=3;break;} if (Buffer4[iii+2]!=EmptyValue){ind_N2=4;break;}}
          if (Trend2==0){if (Buffer5[iii+2]!=EmptyValue){ind_N2=5;break;} if (Buffer6[iii+2]!=EmptyValue){ind_N2=6;break;}}
         }
        for(int kkk=bar;kkk<=bar;kkk++)
         {
          if (Trend1> 0){if (Buffer1[kkk+1]!=EmptyValue){ind_N1=1;break;} if (Buffer2[kkk+1]!=EmptyValue){ind_N1=2;break;}}
          if (Trend1< 0){if (Buffer3[kkk+1]!=EmptyValue){ind_N1=3;break;} if (Buffer4[kkk+1]!=EmptyValue){ind_N1=4;break;}}
          if (Trend1==0){if (Buffer5[kkk+1]!=EmptyValue){ind_N1=5;break;} if (Buffer6[kkk+1]!=EmptyValue){ind_N1=6;break;}}
         }
        }
     //----+---------------------------------------------------------------------------------------------------------------+   
     Value0 = Value_Buffer[bar+0];   
     Value1 = Value_Buffer[bar+1];             
     Trend0 = Value0 - Value1; 
     if (MathAbs(Trend0)<MINIMUM)Trend0=0;   
     //----+======================================================================+         
    switch(ind_N1)
            {  
            //----+----------------------------------------------------------+                     
             case 1 :{ Buffer2[bar+1]=EmptyValue;   Buffer3[bar+1]=EmptyValue;
                       Buffer4[bar+1]=EmptyValue;   Buffer5[bar+1]=EmptyValue;
                       Buffer6[bar+1]=EmptyValue;}  break;
            //----+----------------------------------------------------------+                                                                  
             case 2 :{ Buffer1[bar+1]=EmptyValue;   Buffer3[bar+1]=EmptyValue;
                       Buffer4[bar+1]=EmptyValue;   Buffer5[bar+1]=EmptyValue;
                       Buffer6[bar+1]=EmptyValue;}  break;
            //----+----------------------------------------------------------+                                                                                                                 
             case 3 :{ Buffer1[bar+1]=EmptyValue;   Buffer2[bar+1]=EmptyValue;
                       Buffer4[bar+1]=EmptyValue;   Buffer5[bar+1]=EmptyValue;
                       Buffer6[bar+1]=EmptyValue;}  break;
            //----+----------------------------------------------------------+                                                
             case 4 :{ Buffer1[bar+1]=EmptyValue;   Buffer2[bar+1]=EmptyValue;
                       Buffer3[bar+1]=EmptyValue;   Buffer5[bar+1]=EmptyValue;
                       Buffer6[bar+1]=EmptyValue;}  break;
            //----+----------------------------------------------------------+                                                          
             case 5 :{ Buffer1[bar+1]=EmptyValue;   Buffer2[bar+1]=EmptyValue;
                       Buffer3[bar+1]=EmptyValue;   Buffer4[bar+1]=EmptyValue;
                       Buffer6[bar+1]=EmptyValue;}  break;
            //----+----------------------------------------------------------+                                                                  
             case 6 :{ Buffer1[bar+1]=EmptyValue;   Buffer2[bar+1]=EmptyValue;
                       Buffer3[bar+1]=EmptyValue;   Buffer4[bar+1]=EmptyValue;
                       Buffer5[bar+1]=EmptyValue;}  break;  
            //----+----------------------------------------------------------+                                                                            
            } 
     //----+======================================================================+                 
                       Buffer1[bar+0]=EmptyValue;   Buffer2[bar+0]=EmptyValue;                                                                                                            
                       Buffer3[bar+0]=EmptyValue;   Buffer4[bar+0]=EmptyValue;                            
                       Buffer5[bar+0]=EmptyValue;   Buffer6[bar+0]=EmptyValue;  
//----+=============================================================================================+                           
        if(!ReStart)  
             {
              if(Trend0 >0){Buffer1[bar]=Value0; Buffer1[bar+1]=Value1; ind_N1=1; ReStart=true;}  
              if(Trend0 <0){Buffer3[bar]=Value0; Buffer3[bar+1]=Value1; ind_N1=3; ReStart=true;}  
              if(Trend0==0){Buffer5[bar]=Value0; Buffer5[bar+1]=Value1; ind_N1=5; ReStart=true;}
             }
//----+=============================================================================================+ 
        
        if(Trend0>0)Up_Trend();else if(Trend0<0)Down_Trend();else No_trend(); 
  bar--; 
 }
 //----ЗАВЕРШЕНИЕ ОСНОВНОГО ЦИКЛА       
// ++++++++++++++++ <<< Three Color Indicator code done >>> +++++++++++++++++++++++++++++  
return(0); 
} 

//----+ <<< Дополнительные функции для индикатора >>> SSSSSSSSSSSSSSSSSSSSSS+
//+================================================================================================+
void Up_Trend(){switch(ind_N1)
{   
 case 1 :          {Buffer1[bar]=Value0;  Buffer1[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=1;}break;
 case 2 :          {Buffer2[bar]=Value0;  Buffer2[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=2;}break;         
 case 3 :{switch(ind_N2)
         {case 1 : {Buffer2[bar]=Value0;  Buffer2[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=2;}break;          
         default : {Buffer1[bar]=Value0;  Buffer1[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=1;}}}break;                           
 case 4 :{switch(ind_N2)
         {case 1 : {Buffer2[bar]=Value0;  Buffer2[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=2;}break;  
         default : {Buffer1[bar]=Value0;  Buffer1[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=1;}}}break;                            
 case 5 :{switch(ind_N2)
         {case 1 : {Buffer2[bar]=Value0;  Buffer2[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=2;}break;    
         default : {Buffer1[bar]=Value0;  Buffer1[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=1;}}}break;         
 case 6 :{switch(ind_N2)
         {case 1 : {Buffer2[bar]=Value0;  Buffer2[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=2;}break;
         default : {Buffer1[bar]=Value0;  Buffer1[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=1;}}} }
}
//+================================================================================================+
void Down_Trend(){switch(ind_N1)
{   
 case 3 :          {Buffer3[bar]=Value0;  Buffer3[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=3;}break;
 case 4 :          {Buffer4[bar]=Value0;  Buffer4[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=4;}break;         
 case 1 :{switch(ind_N2)
         {case 3 : {Buffer4[bar]=Value0;  Buffer4[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=4;}break; 
         default : {Buffer3[bar]=Value0;  Buffer3[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=3;}}}break;                           
 case 2 :{switch(ind_N2)
         {case 3 : {Buffer4[bar]=Value0;  Buffer4[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=4;}break;
         default : {Buffer3[bar]=Value0;  Buffer3[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=3;}}}break;                           
 case 5 :{switch(ind_N2)
         {case 3 : {Buffer4[bar]=Value0;  Buffer4[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=4;}break;
         default : {Buffer3[bar]=Value0;  Buffer3[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=3;}}}break;       
 case 6 :{switch(ind_N2)
         {case 3 : {Buffer4[bar]=Value0;  Buffer4[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=4;}break;
         default : {Buffer3[bar]=Value0;  Buffer3[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=3;}}} }
}
//+================================================================================================+
void No_trend(){switch(ind_N1)
{   
 case 5 :          {Buffer5[bar]=Value0;  Buffer5[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=5;}break;
 case 6 :          {Buffer6[bar]=Value0;  Buffer6[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=6;}break;         
 case 1 :{switch(ind_N2)
         {case 5 : {Buffer6[bar]=Value0;  Buffer6[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=6;}break; 
         default : {Buffer5[bar]=Value0;  Buffer5[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=5;}}}break;                          
 case 2 :{switch(ind_N2)
         {case 5 : {Buffer6[bar]=Value0;  Buffer6[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=6;}break;
         default : {Buffer5[bar]=Value0;  Buffer5[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=5;}}}break;                           
 case 3 :{switch(ind_N2)
         {case 5 : {Buffer6[bar]=Value0;  Buffer6[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=6;}break;
         default : {Buffer5[bar]=Value0;  Buffer5[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=5;}}}break;         
 case 4 :{switch(ind_N2)
         {case 5 : {Buffer6[bar]=Value0;  Buffer6[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=6;}break;
         default : {Buffer5[bar]=Value0;  Buffer5[bar+1]=Value1;  ind_N2=ind_N1;  ind_N1=5;}}} }
}
//+================================================================================================+
                
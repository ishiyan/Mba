/*
              "Описание индикатора Т.ДеМарка " 
Во   вногие   пакеты   технического  включен  индикатор,  предложенный
Т.ДеМарком.  Близкий  по  смыслу  к  DMI,  но более просто вычисляемый
(DEMARK  в  отличие  от ADX, учитывает только экстремальные цены, а не
цены   закрытия)  он  дает  наглядные  сигналы  и  наравне  с  другими
осцилляторами  может  быть  применен  для  построения торговых систем.
Определение индикатора: если сегодняшний high выше вчерашнего high, то
аккумулируем  соответствующие  разности,  если  сегодняшний  low  ниже
вчерашнего,  то отдельно аккумулируем соответствующие разности (и те и
другие  -  положительные  величины).  Количество  свечей n, по которым
происходит    аккумулирование    (усреднение),   является   параметром
индикатора,  равного дроби: DEMARK = (накопленные за n свечей разности
high  -  high[-1]) / (  (накопленные  за  n  свечей  разности   high -
high[-1])  +  (накопленные  за  n свечей разности low[-1] - low) ) При
вызове   индикатора  он  запрашивает  длину  окна  усреденения  n;  по
умолчанию  предлагается  значение  n  = 13. Чтение этого индикатора во
многом  аналогично  RSI:  он  также образует области перекупленности и
перепроданности,  часто показывает хорошие дивергенции. В то же время,
во  вмогих  ситуациях  он  может  иметь  преимущества, так  как  более 
полно учитывает структуру свечи.
                © 1997-2005, «FOREX CLUB»
     http://www.fxclub.org/academy_lib_article/article17.html
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                 3c_JDemark_H.mq4 | 
//|                           Copyright © 2005,     Nikolay Kositsin | 
//|                                   Khabarovsk, violet@mail.kht.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "violet@mail.kht.ru" 
#property indicator_separate_window
#property indicator_level1   0.7
#property indicator_level2  -0.7
#property indicator_buffers  3
#property indicator_color1  Blue
#property indicator_color2  Magenta
#property indicator_color3  Purple
//---- input parameters
extern int DemarkLength=13;
extern int DemarkPhase =100;
extern int CountBars   =300;
//---- buffers
double ind_buffer1[];
double ind_buffer2[];
double ind_buffer3[];
double MinHigh,MinLow,Up,Down,Demark,trend;  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;

//---- 3 additional buffers are used for counting.
   if(!SetIndexBuffer(0,ind_buffer1) &&
      !SetIndexBuffer(1,ind_buffer2) &&
      !SetIndexBuffer(2,ind_buffer3))
       Print("cannot set indicator buffers!");   
//---- indicator drow line style.
   SetIndexStyle(0,DRAW_HISTOGRAM, STYLE_SOLID, 3); 
   SetIndexStyle(1,DRAW_HISTOGRAM, STYLE_SOLID, 3);
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID, 3);
//---- name for DataWindow and indicator subwindow label.
   short_name="Demark("+DemarkLength+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"DemarkUp");
   SetIndexLabel(1,"DemarkDown");
   SetIndexLabel(2,"DemarkSt");
//---------------------------------------   
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0); 
//---------------------------------------   
   SetIndexDrawBegin(0,Bars-CountBars);
   SetIndexDrawBegin(1,Bars-CountBars);
   SetIndexDrawBegin(2,Bars-CountBars);     
//--------------------------------------- 
   return(0);
  }
//+------------------------------------------------------------------+
//| Demark                                                           |
//+------------------------------------------------------------------+
int start()
     {   
   int limit,counted_bars=IndicatorCounted();
   //---- check for possible errors
   if(counted_bars<0)return(-1);
   if(Bars-1<=30)    return( 0);
   limit=Bars-counted_bars-1;
   if(limit>=Bars-1)limit=Bars-2;
   //----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=2(Два обращения к функции) 
   if (limit==Bars-2){int reset=-1;int set=JJMASeries(2,0,0,0,0,0,0,0,reset);if((reset!=0)||(set!=0))return(-1);}  
   //-------------------------------------------------------------------------------------------------------------+  
   for(int k=limit; k>=0; k--) 
     {   
        MinHigh=High[k] - High[k+1];
        MinLow =Low [k+1]- Low[k];
        //----
        if(MinHigh<=0) MinHigh=0.0; 
        if(MinLow <=0) MinLow =0.0;      
        //----           
        //----+ Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре во всех трёх обращениях к функции (nJMAdin=0)
        reset=1;Up  =JJMASeries(0,0,Bars-2,limit,DemarkPhase,DemarkLength,MinHigh,k,reset);if(reset!=0)return(-1);
        //----+ Обращение к функции JJMASeries за номером 1, параметры nJMAPhase и nJMALength не меняются на каждом баре во всех трёх обращениях к функции (nJMAdin=0)
        reset=1;Down=JJMASeries(1,0,Bars-2,limit,DemarkPhase,DemarkLength,MinLow, k,reset);if(reset!=0)return(-1);
        //----
        if(Up+Down!=0.0) Demark=2*Up/(Up+Down)-1; else Demark=1.0; 
                            
        //---- +SSSSSSSSSSSSSSSS <<< Three colore code >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
        trend=Demark-ind_buffer1[k+1]-ind_buffer2[k+1]-ind_buffer3[k+1];     
        if     (trend>0.0){ind_buffer1[k]=Demark; ind_buffer2[k]=0.0;    ind_buffer3[k]=0.0;}
        else{if(trend<0.0){ind_buffer1[k]=0.0;    ind_buffer2[k]=Demark; ind_buffer3[k]=0.0;}
        else              {ind_buffer1[k]=0.0;    ind_buffer2[k]=0.0;    ind_buffer3[k]=Demark;}}    
        //---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+          
     }      
//----
   return(0);
   }
   
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <JJMASeries.mqh>    
  
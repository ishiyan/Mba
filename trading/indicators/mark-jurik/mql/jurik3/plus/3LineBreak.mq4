//редактировано и исправлено 17.04.2006 Николай Косицин
/*
Для работы индикатора  следует  положить  файл  
INDICATOR_COUNTED.mqh    
в папку (директорию): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                   3LineBreak.mq4 |
//|                               Copyright © 2004, Poul_Trade_Forum |
//|                                                         Aborigen |
//|                                          http://forex.kbpauk.ru/ |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Poul Trade Forum"
#property link      "http://forex.kbpauk.ru/"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 2
//---- цвета индикатора
#property indicator_color1 Gold
#property indicator_color2 Magenta
//---- толщина индикаторных линий
#property indicator_width1 1
#property indicator_width2 1
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА 
extern int Lines_Break=3;
//---- индикаторные буфферы
double HighBuffer[];
double LowBuffer [];
int T2[2],Tnew,MEMORY[2];
//---- переменные с плавающей точкой  
double VALUE1,VALUE2,Swing=1,OLDSwing;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| 3LineBreak initialization function                               |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
  {   
//---- Стиль исполнения графика виде гистограммы 
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
//---- 2 индикаторных буффера использованы для счёта.
   SetIndexBuffer(0,HighBuffer);
   SetIndexBuffer(1,LowBuffer );
//---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
//---- имена для окон данных и лэйбы для субъокон.
   IndicatorShortName("3LineBreak");
   SetIndexLabel   (0,"3LineBreak");
//---- установка номера бара, начиная с которого будет отрисовываться индикатор  
   SetIndexDrawBegin(0,Lines_Break);
   SetIndexDrawBegin(1,Lines_Break);
//---- завершение инициализации

   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| 3LineBreak iteration function                                    |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
{
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int MaxBar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
MaxBar=Bars-1-Lines_Break;
limit=(Bars-1-counted_bars);
if (limit>MaxBar)limit=MaxBar;
//----
Tnew=Time[limit+1];
//+--- восстановление значений переменных +================+
if (limit<MaxBar)
 if (Tnew==T2[1])Swing=MEMORY[1]; 
 else 
 if (Tnew==T2[0]){Swing=MEMORY[0];MEMORY[1]=MEMORY[0];}  
 else
  {
   if (Tnew>T2[1])Print("ERROR01");
   else Print("ERROR02");
   INDICATOR_COUNTED(-1);return(-1);  
  }
//+--- +===================================================+
for (int bar=limit; bar>=0;bar--)
 {
  OLDSwing=Swing;
  //----
  VALUE1=High[Highest(NULL,0,MODE_HIGH,Lines_Break,bar+1)];
  VALUE2= Low[Lowest (NULL,0,MODE_LOW, Lines_Break,bar+1)];
  //----
  if (OLDSwing== 1 &&  Low [bar]<VALUE2) Swing=-1;
  if (OLDSwing==-1 &&  High[bar]>VALUE1) Swing= 1;
  //----
  if (Swing==1)
   { 
    HighBuffer[bar]=High[bar]; 
    LowBuffer [bar]=Low [bar]; 
   }

  if (Swing==-1)
   { 
    LowBuffer [bar]=High[bar]; 
    HighBuffer[bar]=Low [bar]; 
   }
  //+--- Сохранение значений переменных +====+
  if ((bar==2)||(bar==1))
   {
     MEMORY[bar-1]=Swing;
     T2[bar-1]=Time[bar];
   }
  //+---+====================================+     
 }
   return(0);
}
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции INDICATOR_COUNTED (файл INDICATOR_COUNTED.mqh следует положить в папку (директорию): 
#include <INDICATOR_COUNTED.mqh>                           //                                      MetaTrader\experts\include)
//+---------------------------------------------------------------------------------------------------------------------------+


/*
Для работы индикатора  следует  положить  файлs  INDICATOR_COUNTED.mqh
в папку (директорию): MetaTrader\experts\include\

//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                    3c_BB_Osc.mqh |
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
#property indicator_separate_window
//---- цвета индикатора
#property indicator_buffers 8 
#property indicator_color1 Blue
#property indicator_color2 Lime
#property indicator_color3 OrangeRed
#property indicator_color4 Gray
//---- цвета Bollinger Bands
#property indicator_color5 Gray
#property indicator_color6 Gray
#property indicator_color7 Gray
#property indicator_color8 Gray
*/
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Bands_Period = 100;// Bollinger Bands усреднение, если Bands_Period=0 , то Bollinger Bands удаляется из графика
extern double Bands_Deviations = 1.0; // девиатация 
extern int Drow_style  = 0;  // Стиль исполнения графика 0 - в виде точечной линии, 1 - в виде гистограммы, другое значение - просто линия
extern int Ind_Shift    = 0;  // cдвиг индикатора вдоль оси времени 
extern int BB_Shift     = 0;  // cдвиг BollingerBands вдоль оси времени 
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_Buffer1 [];
double Ind_Buffer2 [];
double Ind_Buffer3 [];
double Ind_Buffer4 [];
double Ind_Buffer5 [];
double Ind_Buffer6 [];
double Ind_Buffer7 [];
double Ind_Buffer8 [];
//---- целые переменные 
int bar; 
//---- переменные с плавающей точкой 
double Series,Out_Series,trend,deviation,sumtotal,midline,priceswing;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| Custom indicator initialization function                         | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{
//---- 4 индикаторных буффера использованы для счёта.  
SetIndexBuffer(0,Ind_Buffer1 );
SetIndexBuffer(1,Ind_Buffer2 );
SetIndexBuffer(2,Ind_Buffer3 );
SetIndexBuffer(3,Ind_Buffer4 );
if (Bands_Period>0)
{
//---- ещё 4 индикаторных буффера добавлены для счёта.
IndicatorBuffers(8);
 SetIndexBuffer(4,Ind_Buffer5 );
 SetIndexBuffer(5,Ind_Buffer6 );
 SetIndexBuffer(6,Ind_Buffer7 ); 
 SetIndexBuffer(7,Ind_Buffer8 ); 
//---- горизонтальный сдвиг Bollinger Bands
 SetIndexShift (4, BB_Shift ); 
 SetIndexShift (5, BB_Shift ); 
 SetIndexShift (6, BB_Shift ); 
 SetIndexShift (7, BB_Shift ); 
//---- установка номера бара, начиная с которого будет отрисовываться Bollinger Bands
 int draw_beginBB=COUNT_begin()+Bands_Period+BB_Shift+1;
 SetIndexDrawBegin(4,draw_beginBB+Bands_Period);
 SetIndexDrawBegin(5,draw_beginBB+Bands_Period);
 SetIndexDrawBegin(6,draw_beginBB+Bands_Period);
 SetIndexDrawBegin(7,draw_beginBB+Bands_Period);
//---- установка значений индикатора, которые не будут видимы на графике
 SetIndexEmptyValue(4,EmptyValue);
 SetIndexEmptyValue(5,EmptyValue);
 SetIndexEmptyValue(6,EmptyValue);
 SetIndexEmptyValue(7,EmptyValue);
//---- имена для окон данных и лэйбы для субъокон.  
 SetIndexLabel   (4,"BollingerBands+1"  );
 SetIndexLabel   (5,"BollingerBands-1"  );
 SetIndexLabel   (6,"BollingerBands+2"  );
 SetIndexLabel   (7,"BollingerBands-2"  );
}
//---- горизонтальный сдвиг индикаторных линий
SetIndexShift (0, Ind_Shift); 
SetIndexShift (1, Ind_Shift); 
SetIndexShift (2, Ind_Shift); 
SetIndexShift (3, Ind_Shift); 

//---- определение стиля исполнения графика
SetIndexStyle(0,DRAW_LINE);
if (Drow_style==0)
{
//---- Стиль исполнения графика виде точечной линии
 SetIndexStyle(1,DRAW_ARROW);
 SetIndexStyle(2,DRAW_ARROW);
 SetIndexStyle(3,DRAW_ARROW);
//---- Определение стиля точечных объектов
 SetIndexArrow(1,159);
 SetIndexArrow(2,159);
 SetIndexArrow(3,159);
//---- 
}
if (Drow_style==1)
{
//---- Стиль исполнения графика виде гистограммы
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexStyle(3,DRAW_HISTOGRAM);
//---- 
}
//---- установка значений индикатора, которые не будут видимы на графике
SetIndexEmptyValue(0,EmptyValue);
SetIndexEmptyValue(1,EmptyValue);
SetIndexEmptyValue(2,EmptyValue);
SetIndexEmptyValue(3,EmptyValue);
//---- имена для окон данных и лэйбы для субъокон.  
IndicatorShortName(""+Label+"");
SetIndexLabel   (0,NULL);
SetIndexLabel   (1,"Up_Trend");
SetIndexLabel   (2,"Down_Trend");
SetIndexLabel   (3,"Straight_Trend");
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
IndicatorDigits(digits());
//---- установка номера бара, начиная с которого будет отрисовываться индикатор
int draw_begin=COUNT_begin()+Ind_Shift+1;
SetIndexDrawBegin(0,draw_begin);
SetIndexDrawBegin(1,draw_begin);
SetIndexDrawBegin(2,draw_begin);
SetIndexDrawBegin(3,draw_begin);
//---- завершение инициализации
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JTRIX iteration function                                         | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int limit,kkk,MaxBar,MaxBarBB,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBar=Bars-1-COUNT_begin()-1; MaxBarBB=MaxBar+1-Bands_Period;          
//---- Загрузка значений исходного индикатора в буффер
for(bar=limit; bar>=0; bar--)Ind_Buffer1[bar]=INDICATOR(bar);
//---- корекция максимального номера самого старого бара, начиная с которого будет произедён пересчёт новых баров 
//---- инициализация нуля
if (limit>MaxBar)
 {
  limit=MaxBar; 
  for(int ttt=Bars-1;ttt>MaxBar;ttt--)
   {
    Ind_Buffer2[ttt]=EmptyValue; 
    Ind_Buffer3[ttt]=EmptyValue; 
    Ind_Buffer4[ttt]=EmptyValue;
    Ind_Buffer5[ttt]=EmptyValue; 
    Ind_Buffer6[ttt]=EmptyValue; 
    Ind_Buffer7[ttt]=EmptyValue;
    Ind_Buffer8[ttt]=EmptyValue; 
   }
 }

//---- Расчёт индикатора
for(bar=limit;bar>=0;bar--)
{
Out_Series=Ind_Buffer1[bar];

//---- +SSSSSSSSSSSSSSSS <<< Трёхцветный код индикатора >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
trend=Out_Series-Ind_Buffer1[bar+1];     
if(trend>0)     {Ind_Buffer2[bar]=Out_Series; Ind_Buffer3[bar]=EmptyValue; Ind_Buffer4[bar]=EmptyValue;}
else{if(trend<0){Ind_Buffer2[bar]=EmptyValue; Ind_Buffer3[bar]=Out_Series; Ind_Buffer4[bar]=EmptyValue;}
else            {Ind_Buffer2[bar]=EmptyValue; Ind_Buffer3[bar]=EmptyValue; Ind_Buffer4[bar]=Out_Series;}}    
//---- +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
} 

//---- Расчёт Bollinger Bands от индикатора

if (Bands_Period<=0)return(0);
//---- корекция максимального номера самого старого бара, начиная с которого будет произедён пересчёт новых баров 
//---- инициализация нуля
if(limit<MaxBarBB) bar=limit; 
else
 {
  bar=MaxBarBB;
  for(int yyy=MaxBar;yyy>MaxBarBB;yyy--)
   {
    Ind_Buffer5[yyy]=EmptyValue; 
    Ind_Buffer6[yyy]=EmptyValue; 
    Ind_Buffer7[yyy]=EmptyValue;
    Ind_Buffer8[yyy]=EmptyValue; 
   }
 }
//----+ 
while(bar>=0)
 {
  sumtotal=0.0;
  kkk=bar+Bands_Period-1;
  midline=0.0;
  for(int iii=0;iii<=Bands_Period-1;iii++)midline=midline+Ind_Buffer1[bar+iii];
  midline=midline/Bands_Period;
  while(kkk>=bar)
   {
    priceswing=Ind_Buffer1[kkk]-midline;
    sumtotal+=priceswing*priceswing;
    kkk--;
   }
  deviation=Bands_Deviations*MathSqrt(sumtotal/Bands_Period); 
  Ind_Buffer5[bar]=midline+deviation; Ind_Buffer6[bar]=midline-deviation;
  //----+ 
  deviation=2*deviation; 
  Ind_Buffer7[bar]=midline+deviation; Ind_Buffer8[bar]=midline-deviation;
  //----+ 
  bar--;
 }
//---- завершение вычислений значений индикатора

return(0); 
} 

//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции INDICATOR_COUNTED (файл INDICATOR_COUNTED.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+


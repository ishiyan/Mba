/*
ДДля  работы  индикатора  следует  положить файлы 
JJMASeries.mqh  
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
JFatl.mq4 
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\

На цыфровом дисплее справа отображаются значения скорости JFatl на 
втором, первом и нулевых барах
*/
//+KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK+
//|                                                  JFatlSpeedR.mq4 | 
//|                             Copyright © 2006,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK+
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буфферов
#property indicator_buffers  6
#property indicator_color1  MediumSeaGreen
#property indicator_color2  Crimson  
#property indicator_color3  Yellow
#property indicator_color4  Magenta 
#property indicator_color5  MediumSeaGreen  
#property indicator_color6  Crimson
//---- верхнее и нижнее ограничение шкалы окна индикатора
#property indicator_maximum 1.1
#property indicator_minimum 0.9
//---- толщина индикаторных линий
#property indicator_width1 0
#property indicator_width2 0
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 3
#property indicator_width6 3
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Noise     = 8;   // Величина изменения цены, принимаемая за шум;
extern int Length    = 3;   // глубина JFatl сглаживания; 
extern int Phase     = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного JFatl процесса; 
extern int Smooth   = 1;   // глубина сглаживания готового индикатора JFatlSpeed;
extern int Smooth_Phase    = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного JFatlSpeed процесса; 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора: 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.) 
extern int Simbol1=108; // внешний вид символа для скорости при её падении до шума
extern int Simbol2=108; // внешний вид символа для скорости при её падении до шума
extern int Simbol3=108; // внешний вид символа для скорости при её изменении вне шумового уровня
extern int Simbol4=108; // внешний вид символа для скорости при её изменении вне шумового уровня
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double UBuffer []; 
double DBuffer []; 
double Buffer1 [];
double Buffer2 []; 
double Buy1    [];
double Sell1   [];
double Buy2    [];
double Sell2   [];
//---- целые переменные
int Window;
double NOISE,VSHIFT; 
//---- переменные с плавающей точкой 
double JFatlSpeed,JFS0,JFS1,JFS2,JFatl0,JFatl1,Series;
//+KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK+
//| JFatlSpeedR initialization function                              |
//+KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK+
int init() 
{ 
//---- Стиль исполнения графика виде символов
SetIndexStyle(0,DRAW_ARROW);
SetIndexStyle(1,DRAW_ARROW);
SetIndexStyle(2,DRAW_ARROW);
SetIndexStyle(3,DRAW_ARROW);
SetIndexStyle(4,DRAW_ARROW);
SetIndexStyle(5,DRAW_ARROW);
//---- Определение стиля точечных объектов
SetIndexArrow(0,159);
SetIndexArrow(1,159);
SetIndexArrow(2,Simbol1);
SetIndexArrow(3,Simbol2);
SetIndexArrow(4,Simbol3);
SetIndexArrow(5,Simbol4);
//---- 8 индикаторных буфферов использованы для счёта
IndicatorBuffers(8);
SetIndexBuffer(0,UBuffer);
SetIndexBuffer(1,DBuffer);
SetIndexBuffer(2,Buy1);
SetIndexBuffer(3,Sell1);
SetIndexBuffer(4,Buy2);
SetIndexBuffer(5,Sell2); 
SetIndexBuffer(6,Buffer1);
SetIndexBuffer(7,Buffer2);
//---- установка номера бара, начиная с которого будет отрисовываться индикатор 
SetIndexDrawBegin(0,69); 
SetIndexDrawBegin(1,69);
SetIndexDrawBegin(2,69);
SetIndexDrawBegin(3,69);
SetIndexDrawBegin(4,69);
SetIndexDrawBegin(5,69);
//---- установка значений индикатора, которые не будут видимы на графике
SetIndexEmptyValue(0,0);
SetIndexEmptyValue(1,0);
SetIndexEmptyValue(2,0);
SetIndexEmptyValue(3,0);
SetIndexEmptyValue(4,0);
SetIndexEmptyValue(5,0);
IndicatorShortName("JFatlSpeed("+Noise+","+Length+","+Phase+","+Smooth+","+Smooth_Phase+","+Input_Price_Customs+","+Simbol1+","+Simbol2+","+Simbol3+","+Simbol4+")"); 
NOISE=Noise*Point;
//+=====================================================================================================================================================+ 
if(Smooth_Phase<-100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано -100");}
if(Smooth_Phase> 100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано  100");}
if(Smooth<  1) {Alert("Параметр Smooth должен быть не менее 1"      + " Вы ввели недопустимое " +Smooth+ " будет использовано  1"  );}
//+=====================================================================================================================================================+
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
IndicatorDigits(0);
//---- Определение номера окна индикатора
Window=WindowFind("JFatlSpeed("+Noise+","+Length+","+Phase+","+Smooth+","+
    Smooth_Phase+","+Input_Price_Customs+","+Simbol1+","+Simbol2+","+Simbol3+","+Simbol4+")");
//---- завершение инициализации
return(0); 
}
//+KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK+
//| JFatlSpeedR iteration function                                   |
//+KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK+
int start() 
{ 
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int bar,reset,MaxBar,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции) 
if (counted_bars==0)JJMASeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBar=Bars-1-38-30-1;
//----+  
for(bar=limit;bar>=0;bar--)Buffer1[bar]=iCustom( NULL, 0, "JFatl",Length,Phase,0,Input_Price_Customs,0,bar); 
//---- корекция стартового расчётого бара в цикле
//---- инициализация нуля          
if (limit>Bars-70)
  {
   for(bar=limit;bar>=MaxBar;bar--)
     {
      Buffer2[bar]=0.0;
      Buy1   [bar]=0.0;
      Sell1  [bar]=0.0;
      Buy2   [bar]=0.0;
      Sell2  [bar]=0.0;
     }
   limit=Bars-70;
  }

for(bar=limit;bar>=0;bar--)
  {
   JFatl0=Buffer1[bar+0];
   JFatl1=Buffer1[bar+1];    
   Series=JFatl0-JFatl1;
   //----+ Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
   JFatlSpeed=JJMASeries(0,0,MaxBar,limit,Smooth_Phase,Smooth,Series,bar,reset);
   //----+ проверка на отсутствие ошибки в предыдущей операции
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}  
   Buffer2[bar]=JFatlSpeed;
  }
//---- корекция стартового расчётого бара в цикле
//---- инициализация нуля          
if (limit>Bars-71)
  {
   for(bar=limit;bar>=MaxBar;bar--)
     {
      Buy1   [bar]=0.0;
      Sell1  [bar]=0.0;
      Buy2   [bar]=0.0;
      Sell2  [bar]=0.0;
     }
   limit=Bars-71;
  }
//----+
for(bar=limit;bar>=0;bar--)
  { 
   Buy1 [bar]=0;
   Sell1[bar]=0;
   Buy2 [bar]=0;
   Sell2[bar]=0;
   JFS0=Buffer2[bar+0];
   JFS1=Buffer2[bar+1];
   if (JFS0>0){UBuffer[bar]=1;DBuffer[bar]=0;}
   if (JFS0<0){UBuffer[bar]=0;DBuffer[bar]=1;}
   
   if (MathAbs(JFS1)<=NOISE)
    { 
     if(JFS0> NOISE)Buy2 [bar]=1;
     if(JFS0<-NOISE)Sell2[bar]=1;
    }
   else
    {
     if((JFS1<-NOISE)&&(MathAbs(JFS0)<=NOISE))Buy1 [bar]=1;
     if((JFS1> NOISE)&&(MathAbs(JFS0)<=NOISE))Sell1[bar]=1;
     if((JFS1<-NOISE)&&(JFS0> NOISE))Buy2 [bar]=1;
     if((JFS1> NOISE)&&(JFS0<-NOISE))Sell2[bar]=1; 
    }
  }
//----+
//----+ Создание текстовых объектов
JFS0=Buffer2[0];
JFS1=Buffer2[1];  
JFS2=Buffer2[2]; 
//---
int JFSpeed0=JFS0/Point;
int JFSpeed1=JFS1/Point;
int JFSpeed2=JFS2/Point;
//---  
int JFStime2=Time[0] +120*Period();
int JFStime1=JFStime2+240*Period();
int JFStime0=JFStime1+240*Period();    
//---
CreateTextObject("JFatlSpeed0"+Window+"",JFStime0,JFSpeed0,JFS0);
CreateTextObject("JFatlSpeed1"+Window+"",JFStime1,JFSpeed1,JFS1);
CreateTextObject("JFatlSpeed2"+Window+"",JFStime2,JFSpeed2,JFS2);
//----+ +-------------------------+
return(0); 
} 

//+-------------------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
//----+ Введение функции JJMASeriesReset  (дополнительная функция файла JJMASeries.mqh)
//----+ Введение функции INDICATOR_COUNTED(дополнительная функция файла JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+-------------------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции CreateTextObject
void CreateTextObject(string name,int time,int text,double param)
{ 
 ObjectDelete(name);
 ObjectCreate(name, OBJ_TEXT, Window, time, 1.08); 
 if (param >0)ObjectSetText(name, ""+text+"", 14, "Courier New", Lime);
 if (param <0)ObjectSetText(name, ""+text+"", 14, "Courier New", Red);
 if (param==0)ObjectSetText(name, ""+text+"", 14, "Courier New", DodgerBlue);
}
//+-------------------------------------------------------------------------------------------------------------------------------------+
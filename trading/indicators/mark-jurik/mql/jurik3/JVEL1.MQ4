/*
// Created by Starlight (extesy@y&&ex.ru). Don't remove this line even if you do conversion to EL,MQL etc!
/---- 
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                        JVEL1.mq4 |
//|         JVEL1: Copyright © 2005,            Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|   MQL4+3color: Copyright © 2006,                Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буфферов
#property indicator_buffers  2
//---- цвета индикатора 
#property indicator_color1  Gray
#property indicator_color2  Yellow
//---- стиль сигнальной линии индикатора
#property indicator_style1 0
#property indicator_style2 4
//---- параметры горизонтальных уровней индикатора
#property indicator_level1  0.0
#property indicator_levelcolor MediumBlue
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Depth=10;           // глубина сглаживания индикатора
extern int Sign.Length=12;     // глубина сглаживания сигнальной линии
extern int Sign.Phase =100;    // параметр сигнальной линии, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
extern int Input_Price_Customs = 4;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_Buffer1[];
double Ind_Buffer2[];
//---- переменные с плавающей точкой 
double jrc01, jrc04, jrc05, jrc06, jrc07, jrc08, jrc09, trend, JVEL1, Resalt;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JVEL1 initialization function                                    |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- стили изображения индикатора
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
//---- 2 индикаторных буффера использованы для счёта. 
   SetIndexBuffer(0,Ind_Buffer1);
   SetIndexBuffer(1,Ind_Buffer2);
//---- установка значений индикатора, которые не будут видимы на графике
   SetIndexEmptyValue(0,0); 
   SetIndexEmptyValue(1,0);
//---- имена для окон данных и лэйбы для субъокон.
   SetIndexLabel(0,"JVELaux"  );  
   SetIndexLabel(3,"Signal"  );    
   IndicatorShortName("JVELaux1( Depth="+Depth+"Input_Price_Customs="+Input_Price_Customs+")"); 
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
   IndicatorDigits(0);
//---- установка алертов на недопустимые значения входных параметров ===============================================================================+ 
if(Sign.Phase<-100){Alert("Параметр Sign.Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Sign.Phase+ " будет использовано -100");}//|
if(Sign.Phase> 100){Alert("Параметр Sign.Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Sign.Phase+ " будет использовано  100");}//|
if(Sign.Length< 1) {Alert("Параметр Sign.Length должен быть не менее 1"     + " Вы ввели недопустимое " +Sign.Length+ " будет использовано   1");}//|
if(Depth< 1)       {Alert("Параметр Depth должен быть не менее 1"           + " Вы ввели недопустимое " +Depth+ "       будет использовано   1");}//|
PriceSeriesAlert(Input_Price_Customs);//---- обращение к функции PriceSeriesAlert ////////////////////////////////////////////////////////////////////|
//---- =============================================================================================================================================+ 
//---- корекция недопустимого значения параметра Depth
   if(Depth<1)Depth=1; 
//---- инициализация коэфициентов
   jrc04 = Depth + 1.0;
   jrc05 = jrc04 * (jrc04+1.0)/2.0;
   jrc06 = jrc05 * (2*jrc04+1.0)/3.0;
   jrc07 = jrc05 * jrc05 * jrc05 - jrc06 * jrc06; 
//---- завершение инициализации
return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JVEL1 iteration function                                         |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
{
//---- проверка количества баров на достаточность для расчёта
if(Bars-1<=Depth)return(0);  
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,limit,MaxBar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0)counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции) 
if (counted_bars==0)JJMASeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBar=Bars-1-Depth;
//---- корекция максимального номера самого старого бара, начиная с которого будет произедён пересчёт новых баров 
//---- инициализация нуля
if (limit>MaxBar)
 {
  limit=MaxBar; 
  for(int ttt=Bars-1;ttt>MaxBar;ttt--)
   {
    Ind_Buffer1[ttt]=0.0; 
    Ind_Buffer2[ttt]=0.0; 
   }
 }

//----+ расчёт индикатора
for(int bar=limit; bar>=0; bar--)
  {
    jrc08 = 0.0;
    jrc09 = 0.0;
    for(int jj=0; jj<=Depth; jj++)
      {
       //----+ Обращение к функции PriceSeries для получения входной цены jrc01
       jrc01=PriceSeries(Input_Price_Customs, bar+jj);    
       //----+ 
       jrc08 = jrc08 + jrc01 * (jrc04 - jj);
       jrc09 = jrc09 + jrc01 * (jrc04 - jj) * (jrc04 - jj);
      }
    JVEL1 = (jrc09*jrc05 - jrc08*jrc06) / jrc07; 
    JVEL1 = JVEL1/Point;
    Ind_Buffer1[bar]=JVEL1;
    //----+ Вычисление сигнальной линии ( Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0))
    Resalt=JJMASeries(0,0,MaxBar,limit,Sign.Phase,Sign.Length,JVEL1,bar,reset);
    //----+ проверка на отсутствие ошибки в предыдущей операции
     if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
     Ind_Buffer2[bar]=Resalt; 
  }  
return(0);
//---- завершение вычислений значений индикатора
}

//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
//----+ Введение функции JJMASeriesReset  (дополнительная функция файла JJMASeries.mqh)
//----+ Введение функции INDICATOR_COUNTED(дополнительная функция файла JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции PriceSeries, файл PriceSeries.mqh следует положить в папку (директорию): MetaTrader\experts\include
//----+ Введение функции PriceSeriesAlert (дополнительная функция файла PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+
/*
Для  работы  индикатора  следует  положить  файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\

TRIX  –  это  моментум  осцилатор  цены,  введенный в оборот Джеком К.
Хатссоном (“Goog TRIX”, Technical Analysis of Stock & Commodities, том
1:5,  http://www.forexua.com/indicators/www.traders.com).
TRIX  –  однодневная  разность  тройного экспоненциального сглаживания
логарифма  цены  закрытия.  Индикатор  рассчитывается  в шесть этапов:
1. Получают логарифм дневной цены закрытия;
2. Сглаживают логарифм с помощью ЭСС;
3.  Получают ЭСС экспоненциального скользящего среднего, найденного на
этапе 2;
4.  Получают ЭСС экспоненциального скользящего среднего, найденного на
этапе 3;
5.   Вычисляют   однодневную   разность  между  результатами  тройного
сглаживания:  для  этого  значение  этапа  4  текущего дня вычитают из
значения этапа 4 предшествующего дня;
6. Значение, полученное на этапе 5, умножают (для удобного отображения
на графике) на 10 000.
Настройка   ТRIХ  в  соответствии  с  тем  или  иным  торговым  циклом
проводится,  как  и в случае других индикаторов, путем изменения числа
дней  в  экспоненциальном  скользящем  среднем.  Существует  несколько
возможных   путей  интерпретации  ТRIХ.  Самое  простое  прямолинейное
правило  принятия торговых решений для стратегии следования за трендом
гласит:  покупать,  когда  ТRIХ  меняет  направление  с  падающего  на
растущее.  Продавать,  когда  ТRIХ  меняет  направления с растущего на
падающее.
Copyright © 2003  Forex company http://www.forexua.com

В  данном  индикаторе  трёхкратное  сглаживание входной цены с помощью  
экспоненциального  скользящего  среднего  заменено  на двухкратное JMA 
сглаживание.
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                        JTRIX.mq4 | 
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буфферов
#property indicator_buffers 1 
//---- цвета индикатора
#property indicator_color1 Blue
//---- параметры горизонтальных уровней индикатора
#property indicator_level1 0.0
#property indicator_levelcolor BlueViolet
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Length = 5;  // глубина двойного сглаживания входной цены
extern int Phase = 100; // параметр двойного сглаживания, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Smooth = 5;  // глубина сглаживания готового индикатора
extern int Mom_Period = 1;  // Momentum период индикатора
extern int Ind_Shift   = 0; // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_Buffer1 [];
double Smooth_Price[];
//---- переменные с плавающей точкой 
double Series,Temp_Series,Trix,JTRIX;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JTRIX initialization function                                    | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{  
//---- 2 индикаторных буффера использованы для счёта. 
IndicatorBuffers(2);
SetIndexBuffer(0,Ind_Buffer1 );
SetIndexBuffer(1,Smooth_Price);
//---- установка значений индикатора, которые не будут видимы на графике 
SetIndexEmptyValue(0,0); 
//---- горизонтальный сдвиг индикаторных линий 
SetIndexShift (0, Ind_Shift); 
//---- Стиль исполнения графика виде точечной линии
SetIndexStyle(0,DRAW_LINE);
//---- имена для окон данных и лэйбы для субъокон. 
IndicatorShortName ("JTRIX( Length="+Length+", Smooth="+Smooth+", Mom_Period="+Mom_Period+")"); 
SetIndexLabel   (0, "JTRIX"); 
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора  
IndicatorDigits(0);
//---- установка алертов на недопустимые значения входных параметров =========================================================================+ 
if(Phase<-100)    {Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase+  " будет использовано -100");}//////|
if(Phase> 100)    {Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase+  " будет использовано  100");}//////|
if(Length<  1)    {Alert("Параметр Length должен быть не менее 1"     + " Вы ввели недопустимое " +Length+ " будет использовано  1"  );}//////|
if(Smooth<  1)    {Alert("Параметр Smooth должен быть не менее 1"     + " Вы ввели недопустимое " +Smooth+ " будет использовано  1"  );}//////|
if(Mom_Period<1)  {Alert("Параметр Mom_Period должен быть не менее 1"  + " Вы ввели недопустимое "+Mom_Period+ " будет использовано  1");}////|
PriceSeriesAlert(Input_Price_Customs);//---- обращение к функции PriceSeriesAlert ////////////////////////////////////////////////////////////|
//+===========================================================================================================================================+
//---- корекция недопустимого значения параметра Mom_Period
if(Mom_Period<1)Mom_Period=1; 
//---- завершение инициализации
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JTRIX iteration function                                         | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----  проверка количества баров на минимально необходимое для расчёта JTRIX
if (Bars-1<Mom_Period-60)return(0);
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,limit,MaxBar1,MaxBar2,MaxBarJ,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=3(Три обращения к функции)  
if (counted_bars==0)JJMASeriesReset(3);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1;
MaxBar1=Bars-1; MaxBar2=MaxBar1-30; MaxBarJ=MaxBar2-30-Mom_Period; 

//----+ цикл расчёта логарифма входной цены с двойным сглаживанием 
for(int bar=limit;bar>=0;bar--)
  {
  //----+ Обращение к функции TimeJJMASeries для получения входной цены
   Series=PriceSeries(Input_Price_Customs, bar);
   //----+ логарифмирование  входной цены
   Temp_Series=MathLog(Series);
   //----+ Два последовательных обращения к функции JJMASeries за номерами 0, 1 параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
   //----+ (Во втором обращении параметр nJMAMaxBar  уменьшен на 30  т. к. это повторное JMA сглаживание)  
   Temp_Series=JJMASeries(0,0,MaxBar1,limit,Phase,Length,Temp_Series,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   Temp_Series=JJMASeries(1,0,MaxBar2,limit,Phase,Length,Temp_Series,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   Smooth_Price[bar]=Temp_Series;
  }
//---- инициализация нерасчитываемых буферных элементов нулём и изменение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
if(limit>MaxBarJ)
 {
  for(bar=limit;bar>=MaxBarJ;bar--)Ind_Buffer1[bar]=0.0;
  limit=MaxBarJ;
 }

//----+ ОСНОВНОЙ ЦИКЛ ВЫЧИСЛЕНИЯ ИНДИКАТОРА JTRIX 
for(bar=limit;bar>=0;bar--)
  {
  Trix=10000*(Smooth_Price[bar]-Smooth_Price[bar+Mom_Period]);
  //----+ Обращение к функции JJMASeries за номером 2, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0) 
  //(В этом обращении параметр nJMAMaxBar уменьшен ещё на 30  т. к. это повторное JMA сглаживание) 
  JTRIX=JJMASeries(2,0,MaxBarJ,limit,100,Smooth,Trix,bar,reset); if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
  Ind_Buffer1[bar]=JTRIX; 
  }
//---- завершение вычислений значений индикатора

return(0); 
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
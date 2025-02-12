/*
Для  работы  индикатора  следует  положить   файлы      
JMASeries.mqh,
PriceSeries.mqh 
в папку (директорию):       MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\

Индикатор  Momentum  (Темп) измеряет величину изменения цены бумаги за
определенный  период. Основные способы использования индикатора темпа:
В  качестве  осциллятора, следующего за тенденцией, аналогично MACD. В
этом  случае  сигнал  к  покупке  возникает,  если  индикатор образует
впадину и начинает расти; а сигнал к продаже - когда он достигает пика
и  поворачивает вниз. Для более точного определения моментов разворота
индикатора  можно использовать его короткое скользящее среднее. Крайне
высокие  или низкие значения индикатора темпа предполагают продолжение
текущей  тенденции.  Так,  если  индикатор  достигает  крайне  высоких
значений  и затем поворачивает вниз, следует ожидать дальнейшего роста
цен.  Но  в  любом случае с открытием (или закрытием) позиции не нужно
спешить  до  тех  пор,  пока  цены  не подтвердят сигнал индикатора. В
качестве опережающего индикатора. Этот способ основан на предположении
о   том,   что   заключительная   фаза   восходящей  тенденции  обычно
сопровождается  стремительным  ростом  цен  (так  как  все верят в его
продолжение),  а  окончание медвежьего рынка - их резким падением (так
как все стремятся выйти из рынка). Именно так нередко и происходит, но
все же это слишком широкое обобщение. 
В  данном индикаторе классический Моментум сглажен с помощью алгоритма 
JMA. 
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                    JMomentum.mq4 | 
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
#property indicator_color1 Lime
//---- параметры горизонтальных уровней индикатора
#property indicator_level1 0.0
#property indicator_levelcolor Blue
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Mom_Period  = 8;  // Период Momentum
extern int Smooth      = 8;  // глубина JMA сглаживания готового индикатора
extern int Smooth_Phase = 100;// параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx JMA процессов сглаживания 
extern int Ind_Shift   = 0;  // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_Buffer1[];
//---- переменные с плавающей точкой 
double Momentum,JMomentum;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JMomentum initialization function                                | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{ 
//---- 1 индикаторный буффер использован для счёта.
SetIndexBuffer(0,Ind_Buffer1);
//---- установка значений индикатора, которые не будут видимы на графике 
SetIndexEmptyValue(0,0); 
//---- горизонтальный сдвиг индикаторных линий 
SetIndexShift (0, Ind_Shift); 
//---- Стиль исполнения графика виде точечной линии
SetIndexStyle(0,DRAW_LINE);
//---- имена для окон данных и лэйбы для субъокон.  
SetIndexLabel   (0, "JMomentum"); 
IndicatorShortName ("JMomentum"); 
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
IndicatorDigits(0);
//---- установка алертов на недопустимые значения входных параметров ======================================================================================+ 
if(Smooth_Phase<-100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+ " будет использовано -100");}///|
if(Smooth_Phase> 100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+ " будет использовано  100");}///|
if(Mom_Period< 1)   {Alert("Параметр Mom_Period должен быть не менее 1"  + " Вы ввели недопустимое " +Mom_Period+ " будет использовано  1");}//////////////|
if(Smooth< 1)       {Alert("Параметр Smooth должен быть не менее 1"      + " Вы ввели недопустимое " +Smooth+   " будет использовано  1");}////////////////|
PriceSeriesAlert(Input_Price_Customs);//---- обращение к функции PriceSeriesAlert ///////////////////////////////////////////////////////////////////////////|
//---- ====================================================================================================================================================+ 
//---- корекция недопустимого значения параметра Mom_Period
if(Mom_Period<1)Mom_Period=1; 
//---- установка номера бара, начиная с которого будет отрисовываться индикатор  
int draw_begin=Mom_Period+30; 
SetIndexDrawBegin(0,draw_begin); 
//---- завершение инициализации
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JMomentum iteration function                                     | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,bar,MaxBarM,limit,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции) 
if(counted_bars==0)JJMASeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBarM=Bars-1-Mom_Period;
//---- инициализация нулём неподсчитываемых буферных значений и коррекция номера самого старого бара, начиная с которого будет произедён пересчёт новых баров        
if (limit>=MaxBarM)
   {
    for(bar=limit;bar>=MaxBarM;bar--)Ind_Buffer1[bar]=0.0;
    limit=MaxBarM;
   }  
       
//----+ ОСНОВНОЙ ЦИКЛ ВЫЧИСЛЕНИЯ ИНДИКАТОРА JMomentum
for(bar=limit;bar>=0;bar--)
   {
    //----+ расчётная формула индикатора Mom_Period ( два обращения к функции PriceSeries )
    Momentum=PriceSeries(Input_Price_Customs,bar)-PriceSeries(Input_Price_Customs,bar+Mom_Period);  
    //----+ изменение единицы измерения JMomentum до пунктов 
    Momentum=Momentum/Point;
   
    //----+ Сглаживание индикатора Momentum
    //----+ Обращение к функции JJMASeries за номером 0, параметры nJMASmooth_Phase и nJMASmooth не меняются на каждом баре (nJMAdin=0)
    JMomentum=JJMASeries(0,0,MaxBarM,limit,Smooth_Phase,Smooth,Momentum,bar,reset);
    //----+ проверка на отсутствие ошибки в предыдущей операции
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}    
    Ind_Buffer1[bar]=JMomentum;
   }
//---- завершение вычислений значений индикатора
return(0);  
}
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
//----+ Введение функции JJMASeriesReset (дополнительная функция файла JJMASeries.mqh)
//----+ Введение функции INDICATOR_COUNTED(дополнительная функция файла JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции PriceSeries, файл PriceSeries.mqh следует положить в папку (директорию): MetaTrader\experts\include
//----+ Введение функции PriceSeriesAlert (дополнительная функция файла PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+


/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                        JFatl.mq4 | 
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в основном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 1 
//---- цвет индикатора
#property indicator_color1 Blue 
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Length = 3;   // глубина сглаживания 
extern int Phase  = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int Shift  = 0;   // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- буфферы
double JFatl  []; 
double Filter[1];
//---- переменные 
int nf; double FILTER,Price,Resalt;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JFATL initialization function                                    |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init() 
{ 
//---- установка стиля изображения индикатора 
SetIndexStyle(0,DRAW_LINE); 
//---- определение буффера для подсчёта 
SetIndexBuffer(0,JFatl);
//---- установка значений индикатора, которые не будут видимы на графике
SetIndexEmptyValue(0,0.0);  
//---- определение размера буффера Filter[]
nf=38;int count=ArrayResize(Filter,nf+1);if(count==0){Alert("Невозможно выделить память под массив Filter");return(0);}
//+=== Инициализация коэффициентов цифрового фильтра =======================================================================+
Filter[00]=+0.4360409450;Filter[01]=+0.3658689069;Filter[02]=+0.2460452079;Filter[03]=+0.1104506886;Filter[04]=-0.0054034585;
Filter[05]=-0.0760367731;Filter[06]=-0.0933058722;Filter[07]=-0.0670110374;Filter[08]=-0.0190795053;Filter[09]=+0.0259609206;
Filter[10]=+0.0502044896;Filter[11]=+0.0477818607;Filter[12]=+0.0249252327;Filter[13]=-0.0047706151;Filter[14]=-0.0272432537;
Filter[15]=-0.0338917071;Filter[16]=-0.0244141482;Filter[17]=-0.0055774838;Filter[18]=+0.0128149838;Filter[19]=+0.0226522218; 
Filter[20]=+0.0208778257;Filter[21]=+0.0100299086;Filter[22]=-0.0036771622;Filter[23]=-0.0136744850;Filter[24]=-0.0160483392;
Filter[25]=-0.0108597376;Filter[26]=-0.0016060704;Filter[27]=+0.0069480557;Filter[28]=+0.0110573605;Filter[29]=+0.0095711419;
Filter[30]=+0.0040444064;Filter[31]=-0.0023824623;Filter[32]=-0.0067093714;Filter[33]=-0.0072003400;Filter[34]=-0.0047717710;
Filter[35]=+0.0005541115;Filter[36]=+0.0007860160;Filter[37]=+0.0130129076;Filter[38]=+0.0040364019;
//+=========================================================================================================================+
//---- установка алертов на недопустимые значения входных параметров ==============================================================+ 
if(Phase<-100){Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase+  " будет использовано -100");}
if(Phase> 100){Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase+  " будет использовано  100");}
if(Length<  1){Alert("Параметр Length должен быть не менее 1"     + " Вы ввели недопустимое " +Length+ " будет использовано  1"  );}
PriceSeriesAlert(Input_Price_Customs);//---- обращение к функции PriceSeriesAlert ///////////////////////////////////////////////////|
//+================================================================================================================================+
//---- установка номера бара, начиная с которого будет отрисовываться индикатор 
SetIndexDrawBegin(0,nf+30); 
//---- завершение инициализации
return(0); 
}
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JFATL iteration function                                         | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start()
   {
//---- проверка количества баров на достаточность для расчёта
if(Bars-1<=nf)return(0);  
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,MaxBar,limit,bar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции) 
if (counted_bars==0)JJMASeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров 
limit=Bars-counted_bars-1; MaxBar=Bars-1-nf;
//---- корекция максимального номера самого старого бара, начиная с которого будет произедён пересчёт новых баров 
//---- инициализация нуля          
if (limit>=MaxBar)
 {
  for(bar=limit;bar>=MaxBar;bar--)JFatl[bar]=0.0; 
  limit=MaxBar;
 }

//----+ основной цикл расчёта индикатора
for(bar=limit;bar>=0;bar--)
 {
 FILTER=0.0;
  for(int ii=0;ii<=nf;ii++)
   {
    //----+ Обращение к функции PriceSeries для получения входной цены Series
    Price=PriceSeries(Input_Price_Customs, bar+ii);
    //----+ формула для фильтра FATL
    FILTER=FILTER+Filter[ii]*Price;
   }
  //----+ JMA сглаживание полученного индикатора, параметр nJMAMaxBar уменьшен на размер фильтра nf
  //----+ Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
  Resalt=JJMASeries(0,0,MaxBar,limit,Phase,Length,FILTER,bar,reset);
  //----+ проверка на отсутствие ошибки в предыдущей операции
  if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
  JFatl[bar]=Resalt;
     //----+
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
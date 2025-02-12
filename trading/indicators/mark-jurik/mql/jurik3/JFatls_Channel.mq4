/*
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                               JFatls_Channel.mq4 | 
//|                           Copyright © 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 3
//---- цвета индикатора
#property indicator_color1 Blue
#property indicator_color2 Magenta
#property indicator_color3 Blue
//---- стиль линий индикатора
#property indicator_style1 4
#property indicator_style2 0
#property indicator_style3 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Channel_width = 100; // ширина канала в пунктах
extern int        Length = 3;   // глубина сглаживания 
extern int        Phase  = 100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса; 
extern int        Shift  = 0;   // cдвиг индикатора вдоль оси времени 
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- буффер коэффициентов цифрового фильтра
double Filter[1];
//---- индикаторные буфферы
double JFilter[];
double UpperBuffer[];
double LowerBuffer[];
//---- целые переменные
int nf; 
//---- переменные с плавающей точкой 
double FILTER,Series,Half_Width,Resalt;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JFatls_Channel initialization function                           |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init() 
{ 
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE);
SetIndexStyle (1,DRAW_LINE);
SetIndexStyle (2,DRAW_LINE); 
//---- 3 индикаторных буффера использованы для счёта
SetIndexBuffer(0,UpperBuffer); 
SetIndexBuffer(1,JFilter);  
SetIndexBuffer(2,LowerBuffer); 
//---- установка значений индикатора, которые не будут видимы на графике
SetIndexEmptyValue(0,0.0);  
SetIndexEmptyValue(1,0.0); 
SetIndexEmptyValue(2,0.0); 
//---- изменение резмера буффера Filter[]
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
PriceSeriesAlert(Input_Price_Customs);////PriceSeriesAlert///////PriceSeriesAlert//////////PriceSeriesAlert/////////PriceSeriesAlert////|
//+================================================================================================================================+
//---- установка номера бара, начиная с которого будет отрисовываться индикатор 
int draw_begin=nf+30; 
SetIndexDrawBegin(0,draw_begin);
SetIndexDrawBegin(1,draw_begin);
SetIndexDrawBegin(2,draw_begin); 
//---- размер канала в пунктах
Half_Width = Channel_width*Point/2;
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
int reset,limit,MaxBar,bar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции) 
if (counted_bars==0)JJMASeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; 
MaxBar=Bars-1-nf;
//---- корекция максимального номера самого старого бара, начиная с которого будет произедён пересчёт новых баров 
//---- инициализация нуля          
if (limit>=MaxBar)
 {
  for(bar=limit;bar>=MaxBar;bar--)
   {
    JFilter[bar]=0.0; 
    UpperBuffer[bar]=0.0;    
    LowerBuffer[bar]=0.0; 
   }
  limit=MaxBar;
 }

//----+  Вычисление цифрового фильтра Fatl
for(bar=limit;bar>=0;bar--)
  {
   FILTER=0.0;
   for(int ii=0;ii<=nf;ii++)
    {
     //----+ Обращение к функции PriceSeries для получения входной цены Series
     Series=PriceSeries(Input_Price_Customs, bar+ii);
     FILTER=FILTER+Filter[ii]*Series;
    }
   //----+ JMA сглаживание полученного индикатора, параметр nJMAMaxBar уменьшен на размер фильтра nf  MaxBar=Bars-1-nf
   //----+ Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
   Resalt=JJMASeries(0,0,MaxBar,limit,Phase,Length,FILTER,bar,reset);
   //----+ проверка на отсутствие ошибки в предыдущей операции
   if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
   JFilter[bar]=Resalt; 
   //----+ расчёт канала
   UpperBuffer[bar]=Resalt+Half_Width;     
   LowerBuffer[bar]=Resalt-Half_Width;
   //---- завершение вычислений значений индикатора        
  }
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
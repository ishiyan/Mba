/*
Для  работы  индикатора  следует  положить файл 
JJMASeries.mqh 
в папку (директорию): MetaTrader\experts\include\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                         JADX.mq4 | 
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
#property indicator_color1 Magenta
//---- параметры горизонтальных уровней индикатора
#property indicator_level1 0.0
#property indicator_levelcolor SlateBlue
#property indicator_levelstyle 4
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int Length      = 15;  // глубина сглаживания DX
extern int Phase       =-100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов +DM и -DM 
extern int Smooth      = 3;   // глубина сглаживания готового индикатора
extern int Smooth_Phase=-100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса сглаживания 
extern int Ind_Shift   = 0;   // cдвиг индикатора вдоль оси времени 
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_Buffer1[];
//---- переменные с плавающей точкой 
double pDM,mDM,TRJ,JpDM,JmDM,ADX,JADX;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JADX initialization function                                     | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{ 
//---- 1 индикаторныq буффер использован для счёта.
SetIndexBuffer(0,Ind_Buffer1);
//---- установка значений индикатора, которые не будут видимы на графике 
SetIndexEmptyValue(0,0); 
//---- горизонтальный сдвиг индикаторных линий 
SetIndexShift (0, Ind_Shift); 
//---- Стиль исполнения графика виде точечной линии
SetIndexStyle(0,DRAW_LINE);
//---- имена для окон данных и лэйбы для субъокон. 
IndicatorShortName ("JADX"); 
SetIndexLabel (0,   "JADX"); 
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора 
IndicatorDigits(0);
//---- установка алертов на недопустимые значения входных параметров ======================================================================================+ 
if(Phase<-100)       {Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth+ " будет использовано -100");}////////////////|
if(Phase> 100)       {Alert("Параметр Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Phase+  " будет использовано  100");}////////////////|
if(Smooth_Phase<-100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано -100");}//|
if(Smooth_Phase> 100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано  100");}//|
if(Length< 1)        {Alert("Параметр Length должен быть не менее 1"     + " Вы ввели недопустимое " +Length+ " будет использовано  1");}//////////////////|
if(Smooth< 1)        {Alert("Параметр Smooth должен быть не менее 1"     + " Вы ввели недопустимое " +Smooth+ " будет использовано  1");}//////////////////|
//+========================================================================================================================================================+ 
//---- завершение инициализации
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| JADX iteration function                                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int start() 
{ 
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,MaxBar,MaxBarJ,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=3(Три обращения к функции)  
if (counted_bars==0)JJMASeriesReset(3);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
int limit=Bars-counted_bars-1; MaxBar=Bars-2; MaxBarJ=MaxBar-30; 
if (limit==Bars-1){limit=Bars-2;Ind_Buffer1[Bars-1]=0.0;}

//----+ ОСНОВНОЙ ЦИКЛ ВЫЧИСЛЕНИЯ ИНДИКАТОРА JADX
for(int bar=limit;bar>=0;bar--)
   {
    TRJ=iATR(NULL,Period(),1,bar);     
    pDM=High[bar]-High[bar+1];mDM=Low[bar+1]-Low[bar];
    if (pDM<0)pDM=0.0;
    if (mDM<0)mDM=0.0;
    if (pDM==mDM)  {pDM=0.0; mDM=0.0;}
    if((pDM> mDM)&&(pDM>0.0))mDM=0.0;
    if((pDM< mDM)&&(mDM>0.0))pDM=0.0;
    if((TRJ<0.00001)&&(bar<Bars-40)){pDM=0.0;mDM=0.0;}
    else{pDM=pDM/TRJ;mDM=mDM/TRJ;}
  
    //----+ Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре во всех трёх обращениях к функции (nJMAdin=0)
    JpDM=JJMASeries(0,0,MaxBar,limit,Phase,Length,pDM,bar,reset);
    //----+ проверка на отсутствие ошибки в предыдущей операции
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
     
    //----+ Обращение к функции JJMASeries за номером 1 
    JmDM=JJMASeries(1,0,MaxBar,limit,Phase,Length,mDM,bar,reset);
    //----+ проверка на отсутствие ошибки в предыдущей операции
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);} 
    
   
    if (JpDM+JmDM>0.00001) ADX=100*(JpDM-JmDM)/(JpDM+JmDM);else ADX=0.0;
  
    //----+ Сглаживание индикатора ADX
    //----+ Обращение к функции JJMASeries за номером 2 (В этом обращении параметр nJMAMaxBar уменьшен на 30  т. к. это повторное JMA сглаживание) 
    JADX=JJMASeries(2,0,MaxBarJ,limit,Smooth_Phase,Smooth,ADX,bar,reset);
    //----+ проверка на отсутствие ошибки в предыдущей операции
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}   
    Ind_Buffer1[bar]=JADX; 
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
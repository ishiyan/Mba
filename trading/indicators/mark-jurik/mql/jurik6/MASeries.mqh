//Version  January 14, 2007 Final
//+X================================================================X+
//|                                                   MASeries().mqh |
//|                MQL4 MASeries()Copyright © 2006, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+
  /*

  +---------------------------------------- <<< Функция MASeries() >>> -----------------------------------------------+

  +-----------------------------------------+ <<< Назначение >>> +----------------------------------------------------+

  Функция  MASeries()  предназначена  для  использования  алгоритмов обычного усреднения в случаях, когда её применение
  более  целесообразно,  чем  классических  технических  индикаторов  усреднения,  встроенных в Мететрейдер. Функция не
  работает,  если  параметр  MA.limit  принимает  значение, равное нулю! Все индикаторы, сделанные мною для MASeries(),
  выполнены  с  учётом  этого  ограничения.  Файл  следует  положить в папку (директорию): MetaTrader\experts\include\.
  Следует  учесть,  что  если nMA.bar больше, чем nMA.MaxBar, то функция MASeries() возвращает значение равное нулю! на
  этом  баре!  И,  следовательно,  такое  значение  не  может  присутствовать  в знаменателе какой-либо дроби в расчёте
  индикатора! Эта версия функции MASeries() поддерживает экспертов при её использовании в пользовательских индикаторах,
  к  которым  обращается  эксперт.  Эта  версия  функции  MASeries() поддерживает экспертов при её использовании в коде
  индикатора, который полностью помещён в код эксперта с сохранением всех операторов цикла! При написании индикаторов и
  экспертов  с  использованием  функции MASeries(), не рекомендуется переменным давать имена начинающиеся с nMA.... или
  dMA....  Функция  MASeries()  может быть использована во внутреннем коде других пользовательских функций, но при этом
  следует  учитывать тот факт, что в каждом обращении к такой пользовательской функции у каждого обращения к MASeries()
  должен быть свой уникальный номер (nMA.number). 

  +-------------------------------------+ <<< Входные параметры >>> +-------------------------------------------------+

  nMA.n      -   Порядковый номер обращения к функции MASeries(). (0, 1, 2, 3 и.т.д....)
  nMA.MaxBar -   Максимальное значение,  которое может  принимать номер  рассчитываемого бара (nMA.bar).   Обычно равно 
                 Bars-1-period;   Где "period" -  это количество баров,   на которых  исходная величина  dMA.series  не 
                 рассчитывается; 
  nMA.limit  -   Количество ещё не подсчитанных баров плюс один или номер последнего непосчитанного бара.   Должно быть 
                 обязательно равно  Bars-IndicatorCounted()-1;
  nMA.Period -   период сглаживания. Параметр не меняется на каждом баре!    Макимальное значение ограниченно величиной 
                 500.            При необходимости  большего  значения,   следует  изменить  второе  измерение  буферов 
                 dMA.TempBuffer[1][500] и   dMA.TEMPBUFFER[1][500].       Минимальное значение ограниченно величиной 3.
  dMA.series -   Входной  параметр, по которому производится расчёт функции MASeries();
  nMA.bar    -   номер рассчитываемого бара,  параметр  должен  изменяться оператором цикла от максимального значения к 
                 нулевому.   Причём его максимальное значение всегда должно равняться значению параметра nMA.limit!!!

  +------------------------------------+ <<< Выходные параметры >>> +-------------------------------------------------+

  MASeries() - значение функции MASeries. При значениях  nMA.bar  больше  чем  nMA.MaxBar-nMA.Length функция MASeries()
               всегда возвращает ноль!!!
  nMA.reset  - параметр, возвращающий по ссылке значение, отличенное от 0 ,  если  произошла ошибка  в расчёте функции,
               0, если расчёт прошёл нормально. Этот параметр может быть только переменной, но не значением!!!

  +-----------------------------------+ <<< Инициализация функции >>> +-----------------------------------------------+

  Перед  обращениями  к  функции  MASeries()  ,  когда  количество  уже  подсчитанных  баров  равно 0, следует ввести и
  инициализировать  внутренние  переменные  функции,  для  этого  необходимо  обратиться  к  функции  MASeries()  через
  вспомогательную  функцию  MASeriesResize()  со  следующими  параметрами:  MASeriesResize(MaxMA.number+1);  необходимо
  сделать  параметр  nMA.n(MaxMA.number) равным количеству обращений к функции MASeries, то есть на единицу больше, чем
  максимальный nMA.n.

  +--------------------------------------+ <<< Индикация ошибок >>> +-------------------------------------------------+
  
  При отладке индикаторов и экспертов их коды могут содержать ошибки, для выяснения причин которых следует смотреть лог
  файл.  Все  ошибки  функция  MASeries()  пишет в лог файл в папке \MetaTrader\EXPERTS\LOGS\. Если, перед обращением к
  функции  MASeries()  в  коде,  который предшествовал функции, возникла MQL4 ошибка, то функция запишет в лог файл код
  ошибки  и  содержание  ошибки. Если при выполнении функции MASeries()в алгоритме MASeries() произошла MQL4 ошибка, то
  функция  также запишет в лог файл код ошибки и содержание ошибки. При неправильном задании номера обращения к функции
  MASeries()  nMA.number или неверном определении размера буферных переменных nJMAResize.Size в лог файл будет записаны
  сообщения  о  неверном  определении этих параметров. Также в лог файл пишется информация при неправильном определении
  параметра  nMA.limit. Если при выполнении функции инициализации init() произошёл сбой при изменении размеров буферных
  переменных  функции  MASeries(),  то  функция  MASeriesResize()  запишет  в лог файл информацию о неудачном изменении
  размеров  буферных  переменных.  Если  при  обращении  к функции MASeries()через внешний оператор цикла была нарушена
  правильная  последовательность  изменения  параметра  nMA.bar, то в лог файл будет записана и эта информация. Следует
  учесть,  что  некоторые  ошибки  программного кода будут порождать дальнейшие ошибки в его исполнении и поэтому, если
  функция  MASeries() пишет в лог файл сразу несколько ошибок, то устранять их следует в порядке времени возникновения.
  В  правильно  написанном  индикаторе  функция  MASeries() может делать записи в лог файл только при нарушениях работы
  операционной системы. Исключение составляет запись изменения размеров буферных переменных при перезагрузке индикатора
  или эксперта, которая происходит при каждом вызове функции init(). 
  
  +---------------------------------+ <<< Пример обращения к функции >>> +--------------------------------------------+

//----+ определение функций MASeries()
#include <MASeries.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE); 
//---- 1 индикаторный буфер использован для счёта (без этого пересчёта функция MASeries() свой расчёт производить не будет!!!)
SetIndexBuffer(0,Ind_Buffer);
//----+ Изменение размеров буферных переменных функции MASeries, nMA.n=1(Одно обращение к функции MASeries)
if(MASeriesResize(1)==0)return(-1);
return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
int start()
{
//----+ Введение целых переменных и получение уже подсчитанных баров
int reset,bar,MaxBar,limit,counted_bars=IndicatorCounted(); 
//---- проверка на возможные ошибки
if (counted_bars<0)return(-1);
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
int limit=Bars-counted_bars-1;
MaxBar=Bars-1;
//----+ 
for(bar=limit;bar>=0;bar--)
 (
  double Series=Close[bar];
  //----+ Обращение к функции MASeries()за номером 0 для расчёта буфера Ind_Buffer[], 
  double Resalt=MASeries(0,1,MaxBar,limit,Length,Series,bar,reset);
  if (reset!=0)return(-1);
  Ind_Buffer[bar]=Resalt;
 }
return(0);
}
//----+ 

*/
//+X================================================================X+
//|  MASeries() function                                             |
//+X================================================================X+   
//----++ <<< Введение и инициализация переменных >>> +--------------------------+ 
double dMA.sum[1], dMA.SUM[1], dMA.TEMPBUFFER[1][501], dMA.TempBuffer[1][501];
double dMA.MA[1], dMA.MA1[1], dMA.pr[1], dMA.lsum[1], dMA.LSUM[1];
//----++
int    nMA.range1, nMA.range2, nMA.rangeMin, nMA.weight[1], nMA.iii; 
int    nMA.TIME[1], nMA.Error, nMA.Tnew, nMA.Told, nMA.n, nMA.Resize, nMA.cycle;
//----++ +----------------------------------------------------------------------+

   
//----++ <<< Объявление функции MASeries() >>> +----------------------------------------------------------------------------------+

double MASeries
 (
  int nMA.number, int nMA.MA_Method, int nMA.MaxBar, int nMA.limit, int nMA.period, double dMA.series, int nMA.bar, int& nMA.reset
 )
//----++--------------------------------------------------------------------------------------------------------------------------+
{
nMA.n = nMA.number;

nMA.reset = 1;
//=====+ <<< Проверки на ошибки >>> -------------------------------------------------------------------+
if (nMA.bar == nMA.limit)
 {
  //----++ проверка на инициализацию функции MASeries()
  if (nMA.Resize < 1)
   {
    Print(StringConcatenate("MASeries number = ", nMA.n,
         ". Не было сделано изменение размеров буферных переменных функцией MASeriesResize()"));
    if (nMA.Resize == 0)
          Print(StringConcatenate("MASeries number = ", nMA.n,
                ". Следует дописать обращение к функции MASeriesResize() в блок инициализации"));
         
    return(0.0);
   }
  //----++ проверка на ошибку в исполнении программного кода, предшествовавшего функции MASeries()
  nMA.Error = GetLastError();
  if(nMA.Error > 4000)
   {
    Print(StringConcatenate("MASeries number = ", nMA.n,
         ". В коде, предшествующем обращению к функции MASeries() number = "+nMA.n+" ошибка!!!"));
    Print(StringConcatenate("MASeries() number = ", nMA.n, ". ",MA_ErrDescr(nMA.Error)));  
   } 
                                                   
  //----++ проверка на ошибку в задании переменных nMA.number и nMAResize.Number
  if (ArraySize(nMA.TIME) < nMA.number) 
   {
    Print(StringConcatenate("MASeries number = ", nMA.n,
               ". Ошибка!!! Неправильно задано значение переменной nMA.number функции MASeries()"));
    Print(StringConcatenate("MASeries() number = ", nMA.n,
            ". Или неправильно задано значение  переменной nMAResize.Size функции MASeriesResize()"));
    return(0.0);
   }
 }
//----++ +----------------------------------------------------------------------------------------------+ 
  
if (nMA.bar > nMA.MaxBar){nMA.reset = 0; return(0.0);}
//----++ 
if (nMA.MA_Method != 1)
           if (nMA.bar != nMA.limit)
                     for(nMA.iii = nMA.period; nMA.iii >= 0; nMA.iii--)
                                           dMA.TempBuffer[nMA.n][nMA.iii + 1]=
                                                             dMA.TempBuffer[nMA.n][nMA.iii];
//----++                                                                                  
dMA.TempBuffer[nMA.n][0] = dMA.series;

//----++ проверка внешего параметра nMA.period на корректность ---------------------------------------------------+ 
if (nMA.bar == nMA.MaxBar)
  {
    if(nMA.period <3 )
          Print(StringConcatenate
                  ("MASeries number = ", nMA.n, ". Параметр nMA.period должен быть не менее 3",
                                       " Вы ввели недопустимое ", nMA.period,  " будет использовано  3"));  
    if (nMA.period > nMA.rangeMin)
       {
         Print(StringConcatenate("Параметр nMA.period должен быть не более ", nMA.rangeMin, ".", 
              " Вы ввели недопустимое ", nMA.period, " будет использовано  ", nMA.rangeMin, "."));
             Print(StringConcatenate
                   (" Если необходимо большее значение параметра nMA.period, измените вторые измерения буферов",
                                                           " dMA.TempBuffer и dMA.TEMPBUFFER функции MASeries()"));
       }
    if (nMA.MA_Method < 0 || nMA.MA_Method > 3)
          Alert(StringConcatenate("Параметр nMA.MA_Method должен быть от 0 до 3", 
                               " Вы ввели недопустимое ", nMA.MA_Method, " будет использовано 0"));
       
  }
if (nMA.MA_Method < 0) nMA.MA_Method = 0;
else if (nMA.MA_Method > 3) nMA.MA_Method = 0;
if (nMA.period < 3)nMA.period = 3;
else if (nMA.period > nMA.rangeMin)nMA.period = nMA.rangeMin;
//----++ +---------------------------------------------------------------------------------------------------------+ 

//----++ <<< Расчёт коэффициентов  >>> +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
switch(nMA.MA_Method)
 {
  //----++ <<< инициализация SMA >>> +---------------------------------------+
  case 0 : if (nMA.bar == nMA.MaxBar - nMA.period)
              for(nMA.iii = 1; nMA.iii < nMA.period; nMA.iii++)
                  dMA.sum[nMA.n] += dMA.TempBuffer[nMA.n][nMA.iii];
           else
            if (nMA.bar > nMA.MaxBar - nMA.period)
                               {nMA.reset = 0; return(0.0);}
           break;                
  //----++ <<< инициализация EMA >>> +---------------------------------------+
  case 1 : if (nMA.bar == nMA.MaxBar)dMA.pr[nMA.n] = 2.0 / (nMA.period + 1.0);
           else
            if (nMA.bar > nMA.MaxBar){nMA.reset = 0; return(0.0);}
           break;                
  //----++ <<< инициализация SSMA >>> +--------------------------------------+
  case 2 : if (nMA.bar == nMA.MaxBar - nMA.period + 1)
              for(nMA.iii = 0; nMA.iii < nMA.period; nMA.iii++)
                  dMA.sum[nMA.n] += dMA.TempBuffer[nMA.n][nMA.iii];
           else
            if (nMA.bar > nMA.MaxBar - nMA.period + 1)
                                        {nMA.reset = 0; return(0.0);}
           break;                
  //----++ <<< инициализация LWMA >>> +--------------------------------------+ 
  case 3 : if (nMA.bar == nMA.MaxBar - nMA.period)
              {    
               int nMA.kkk = nMA.period;
               for(nMA.iii = 1; nMA.iii <= nMA.period; nMA.iii++, nMA.kkk--)
                {
                 dMA.sum[nMA.n] += dMA.TempBuffer[nMA.n][nMA.kkk] * nMA.iii;
                 dMA.lsum[nMA.n] += dMA.TempBuffer[nMA.n][nMA.kkk];
                 nMA.weight[nMA.n] += nMA.iii;
                }
              }
           else
            if (nMA.bar > nMA.MaxBar - nMA.period)
                                   {nMA.reset = 0; return(0.0);}
           break;
  //----++ <<< инициализация SMA >>> +---------------------------------------+
  default : if (nMA.bar == nMA.MaxBar - nMA.period)
                for(nMA.iii = 1; nMA.iii < nMA.period; nMA.iii++)
                    dMA.sum[nMA.n] += dMA.TempBuffer[nMA.n][nMA.iii]; 
            else
             if (nMA.bar > nMA.MaxBar - nMA.period)
                                    {nMA.reset = 0; return(0.0);}                             
  //----++ +-----------------------------------------------------------------+      
 } 
//----++ ---------------------------------------------------------------------+  


//----++ проверка на ошибку в последовательности изменения переменной nMA.bar
if(nMA.limit >= nMA.MaxBar)
 if (nMA.bar == 0)
  if (nMA.MaxBar > nMA.period)
   if (nMA.TIME[nMA.n] == 0)
        Print(StringConcatenate("MASeries number = ", nMA.n,
                        ". Ошибка!!! Нарушена правильная последовательность",
                                  "изменения параметра nMA.bar внешним оператором цикла!!!"));  

//----+ <<< Восстановление значений переменных >>> +-----------------------------------------------+
if (nMA.bar == nMA.limit)
 while(nMA.cycle == 0)
  {
   switch(nMA.MA_Method)
     {
      case 0 : if (nMA.bar == nMA.MaxBar-nMA.period  )   break;
      case 1 : if (nMA.bar == nMA.MaxBar)                break;
      case 2 : if (nMA.bar == nMA.MaxBar-nMA.period + 1) break;
      case 3 : if (nMA.bar == nMA.MaxBar-nMA.period  )   break;
      default: if (nMA.bar == nMA.MaxBar-nMA.period  )   break; 
     }
   nMA.Tnew = Time[nMA.limit + 1];
   nMA.Told = nMA.TIME[nMA.n];
   //--+
   if(nMA.Tnew == nMA.Told)
     {
       for(nMA.iii = nMA.period;nMA.iii >= 1; nMA.iii--)
                               dMA.TempBuffer[nMA.n][nMA.iii]=
                                               dMA.TEMPBUFFER[nMA.n][nMA.iii]; 
       //--+                                       
       if (nMA.MA_Method != 1)dMA.sum[nMA.n] = dMA.SUM[nMA.n];
       if (nMA.MA_Method == 1 || nMA.MA_Method == 2)dMA.MA[nMA.n] = dMA.MA1[nMA.n];
       if (nMA.MA_Method == 3)dMA.lsum[nMA.n] = dMA.LSUM[nMA.n];
     }
   //--+ проверка на ошибки
   if(nMA.Tnew != nMA.Told)
    {
     nMA.reset = -1;
     //--+ индикация ошибки в расчёте входного параметра nMA.limit функции MASeries0()
     if (nMA.Tnew>nMA.Told)
       {
       Print(StringConcatenate("MASeries0 number = ", nMA.n,
                 ". Ошибка!!! Параметр nMA.limit функции MASeries0() меньше, чем необходимо"));
       }
     else 
       { 
       int nMA.LimitERROR = nMA.limit + 1 - iBarShift(NULL, 0, nMA.Told, TRUE);
       Print(StringConcatenate("MASeries0 number = ", nMA.n,
             ". Ошибка!!! Параметр nMA.limit функции MASeries0() больше, чем необходимо на ",
                                                                           nMA.LimitERROR,"."));
       }
     //--+ Возврат через nMA.reset=-1; ошибки в расчёте функции MASeries0
     return(0);
    } 
  break;
  }                   
//----+-------------------------------------------------------------------------------------------+

//+--- Сохранение значений переменных +-----------------------------+
if (nMA.bar == 1)
 if (nMA.limit != 1)
 {
   nMA.TIME[nMA.n] = Time[2];
   for(nMA.iii=nMA.period; nMA.iii >= 1; nMA.iii--)
                       dMA.TEMPBUFFER[nMA.n][nMA.iii] =
                                 dMA.TempBuffer[nMA.n][nMA.iii];  
   //+---+                                    
   if (nMA.MA_Method != 1)dMA.SUM[nMA.n] = dMA.sum[nMA.n]; 
   if (nMA.MA_Method == 1 || nMA.MA_Method == 2)
                            dMA.MA1[nMA.n] = dMA.MA[nMA.n];
   if (nMA.MA_Method == 3)dMA.LSUM[nMA.n] = dMA.lsum[nMA.n];  
 }
//+---+-------------------------------------------------------------+  

switch(nMA.MA_Method)
 {
//----++ <<< вычисление SMA >>> +---------------------------------------+
   case 0 :
    {
     dMA.sum[nMA.n] += dMA.series;
     dMA.MA[nMA.n] = dMA.sum[nMA.n] / nMA.period;
     dMA.sum[nMA.n] -= dMA.TempBuffer[nMA.n][nMA.period - 1];
    } 
   break;
//----++ <<< вычисление EMA >>> +---------------------------------------+
   case 1 :
    {
     if (nMA.bar != nMA.MaxBar)
          dMA.MA[nMA.n] = dMA.series * dMA.pr[nMA.n]
                                 + dMA.MA[nMA.n] * (1 - dMA.pr[nMA.n]);
     else dMA.MA[nMA.n] = dMA.series; 
    }
   break;
//----++ <<< вычисление SSMA >>> +--------------------------------------+
   case 2 :
    {  
     if(nMA.bar < nMA.MaxBar - nMA.period + 1)
           dMA.sum[nMA.n] = dMA.MA[nMA.n] * (nMA.period - 1) + dMA.series;
     dMA.MA[nMA.n] = dMA.sum[nMA.n] / nMA.period;     
    }
   break;
 
//----++ <<< вычисление LWMA >>> +--------------------------------------+
   case 3 :    
    {  
     dMA.sum[nMA.n] -= dMA.lsum[nMA.n] - dMA.series * nMA.period;
     dMA.lsum[nMA.n] += dMA.series - dMA.TempBuffer[nMA.n][nMA.period];
     dMA.MA[nMA.n] = dMA.sum[nMA.n] / nMA.weight[nMA.n]; 
    }
   break;
//----++ <<< вычисление SMA >>> +---------------------------------------+
   default :
    {
     dMA.sum[nMA.n] += dMA.series;
     dMA.MA[nMA.n] = dMA.sum[nMA.n] / nMA.period;
     dMA.sum[nMA.n] -= dMA.TempBuffer[nMA.n][nMA.period - 1];
    } 
//----++ +--------------------------------------------------------------+
 } 
//----++ проверка на ошибку в исполнении программного кода функции JMASeries()
 nMA.Error = GetLastError();
 if(nMA.Error > 4000)
   {
    Print(StringConcatenate("MASeries number = ",
        nMA.n, ". При исполнении функции MASeries() произошла ошибка!!!"));
    Print(StringConcatenate
               ("MASeries number = ", nMA.n, ". ",MA_ErrDescr(nMA.Error)));   
    return(0.0);
   }
  nMA.reset = 0;
  return(dMA.MA[nMA.n]);
  
//----+  завершение вычисления функции MASeries() --------------------------+  
}
//--+ --------------------------------------------------------------------------------------------+

//+X=============================================================================================X+
// MASeriesResize - Это дополнительная функция для изменения размеров буферных переменных         | 
// функции MASeries. Пример обращения: MASeriesResize(5); где 5 - это количество обращений к      | 
// MASeries()в тексте индикатора. Это обращение к функции  MASeriesResize следует поместить       |
// в блок инициализации пользовательского индикатора или эксперта                                 |
//+X=============================================================================================X+
int MASeriesResize(int nMAResize.Size)
 {
//----+
  if(nMAResize.Size<1)
   {
    Print("MASeriesResize: Ошибка!!! Параметр nMAResize.Size не может быть меньше единицы!!!"); 
    nMA.Resize = -1; 
    return(0);
   }
  //----+    
  nMA.range1 = ArrayRange(dMA.TempBuffer, 1) - 1; 
  nMA.range2 = ArrayRange(dMA.TEMPBUFFER, 1) - 1;   
  nMA.rangeMin = MathMin(nMA.range1, nMA.range2);
  if(nMAResize.Size == -2)
              return(nMA.rangeMin);
  //----+  
  int nMAResize.reset, nMAResize.cycle;
  //--+
  while(nMAResize.cycle == 0)
   {
    //----++ <<< изменение размеров буферных переменных >>>  +-----------------------+
    if(ArrayResize(dMA.TempBuffer, nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.TEMPBUFFER, nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.lsum,       nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.LSUM,       nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.sum,        nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.SUM,        nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.MA,         nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.MA1,        nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.pr,         nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(nMA.TIME,       nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(nMA.weight,     nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    //----++-------------------------------------------------------------------------+
    nMAResize.cycle = 1;
   }
  //--+
  if(nMAResize.reset == -1)
   {
    Print("MASeriesResize: Ошибка!!! Не удалось изменить размеры буферных переменных функции MASeries().");
    int nMAResize.Error = GetLastError();
    if(nMAResize.Error > 4000)
                Print(StringConcatenate("MASeriesResize: ", MA_ErrDescr(nMAResize.Error)));    
    nMA.Resize = -2;
    return(0);
   }
  else  
   {
    Print(StringConcatenate("MASeriesResize: MASeries Size = ", nMAResize.Size, "."));
    nMA.Resize = nMAResize.Size;
    return(nMAResize.Size);
   }  
//----+
 }
//--+ --------------------------------------------------------------------------------------------+
/*
//+X====================================================================================================X+
MASeriesAlert - Это дополнительная функция для индикации ошибки в задании внешних переменных             |
функции MASeries.                                                                                        |
  -------------------------- входные параметры  --------------------------                               |
MASeriesAlert.Number                                                                                     |
MASeriesAlert.ExternVar значение внешней переменной                                                      |
MASeriesAlert.name имя внешней переменной для параметра nMA1.period, если MASeriesAlert.Number=0,        | 
для параметра nMA1.MA_Method, если MASeriesAlert.Number=1.                                               | 
                                                                                                         |                                         
  -------------------------- Пример использования  -----------------------                               |
  int init()                                                                                             | 
{                                                                                                        |
//----                                                                                                   |
Здесь какая-нибудь инициализация переменных и буферов                                                    |
                                                                                                         |
//---- установка алертов на недопустимые значения внешних переменных                                     |                                                           
MASeriesAlert(0,"period1",period1);                                                                      |
MASeriesAlert(0,"period2",period2);                                                                      |
MASeriesAlert(1,"MA_Method1",MA_Method1);                                                                |
MASeriesAlert(1,"MA_Method2",MA_Method2);                                                                |
//---- завершение инициализации                                                                          |
return(0);                                                                                               |
}                                                                                                        |
//+X====================================================================================================X+
*/
void MASeriesAlert
  (int MASeriesAlert.Number, string MASeriesAlert.name, int MASeriesAlert.ExternVar)
 {
  //---- установка алертов на недопустимые значения входных параметров 
   if (MASeriesAlert.Number == 0)
      if (MASeriesAlert.ExternVar < 3)
          Alert(StringConcatenate("Параметр ", MASeriesAlert.ExternVar, " должен быть не менее 3", 
                                 " Вы ввели недопустимое ", MASeriesAlert.ExternVar, " будет использовано  3"));
   int MASeriesAlert.MaxPeriod = ArrayRange(dMA.TempBuffer, 1);  
   if (MASeriesAlert.Number == 0)
    if (MASeriesAlert.ExternVar > MASeriesAlert.MaxPeriod)
          Alert(StringConcatenate("Параметр ", MASeriesAlert.name, " должен быть не более ",
                  MASeriesAlert.MaxPeriod, ".", " Вы ввели недопустимое ", MASeriesAlert.ExternVar,
                                                   " будет использовано  ", MASeriesAlert.MaxPeriod, ".",
                                                               " Если необходимо большее значение параметра", 
                                                                " nMA.period, измените вторые измерения буферов",
                                                                 " dMA.TempBuffer и dMA.TEMPBUFFER функции MASeries" ));
          
 }
//--+ ----------------------------------------------------------------------------------------------------------------+

// перевод сделан Николаем Косициным 01.12.2006  
//+X================================================================X+
//|                                        MA_ErrDescr_RUS(MQL4).mqh |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+X================================================================X+
string MA_ErrDescr(int error_code)
 {
  string error_string;
//----
  switch(error_code)
    {
     //---- MQL4 ошибки 
     case 4000: error_string = StringConcatenate("Код ошибки = ",error_code,". нет ошибки");                                                  break;
     case 4001: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильный указатель функции");                              break;
     case 4002: error_string = StringConcatenate("Код ошибки = ",error_code,". индекс массива не соответствует его размеру");                 break;
     case 4003: error_string = StringConcatenate("Код ошибки = ",error_code,". Нет памяти для стека функций");                                break;
     case 4004: error_string = StringConcatenate("Код ошибки = ",error_code,". Переполнение стека после рекурсивного вызова");                break;
     case 4005: error_string = StringConcatenate("Код ошибки = ",error_code,". На стеке нет памяти для передачи параметров");                 break;
     case 4006: error_string = StringConcatenate("Код ошибки = ",error_code,". Нет памяти для строкового параметра");                         break;
     case 4007: error_string = StringConcatenate("Код ошибки = ",error_code,". Нет памяти для временной строки");                             break;
     case 4008: error_string = StringConcatenate("Код ошибки = ",error_code,". Неинициализированная строка");                                 break;
     case 4009: error_string = StringConcatenate("Код ошибки = ",error_code,". Неинициализированная строка в массиве");                       break;
     case 4010: error_string = StringConcatenate("Код ошибки = ",error_code,". Нет памяти для строкового массива");                           break;
     case 4011: error_string = StringConcatenate("Код ошибки = ",error_code,". Слишком длинная строка");                                      break;
     case 4012: error_string = StringConcatenate("Код ошибки = ",error_code,". Остаток от деления на ноль");                                  break;
     case 4013: error_string = StringConcatenate("Код ошибки = ",error_code,". Деление на ноль");                                             break;
     case 4014: error_string = StringConcatenate("Код ошибки = ",error_code,". Неизвестная команда");                                         break;
     case 4015: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильный переход (never generated error)");                break;
     case 4016: error_string = StringConcatenate("Код ошибки = ",error_code,". Неинициализированный массив");                                 break;
     case 4017: error_string = StringConcatenate("Код ошибки = ",error_code,". Вызовы DLL не разрешены");                                     break;
     case 4018: error_string = StringConcatenate("Код ошибки = ",error_code,". Невозможно загрузить библиотеку");                             break;
     case 4019: error_string = StringConcatenate("Код ошибки = ",error_code,". Невозможно вызвать функцию");                                  break;
     case 4020: error_string = StringConcatenate("Код ошибки = ",error_code,". Вызовы внешних библиотечных функций не разрешены");            break;
     case 4021: error_string = StringConcatenate("Код ошибки = ",error_code,". Недостаточно памяти для строки, возвращаемой из функции");     break;
     case 4022: error_string = StringConcatenate("Код ошибки = ",error_code,". Система занята (never generated error)");                      break;
     case 4050: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильное количество параметров функции");                  break;
     case 4051: error_string = StringConcatenate("Код ошибки = ",error_code,". Недопустимое значение параметра функции");                     break;
     case 4052: error_string = StringConcatenate("Код ошибки = ",error_code,". Внутренняя ошибка строковой функции");                         break;
     case 4053: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка массива");                                              break;
     case 4054: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильное использование массива-таймсерии");                break;
     case 4055: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка пользовательского индикатора");                         break;
     case 4056: error_string = StringConcatenate("Код ошибки = ",error_code,". Массивы несовместимы");                                        break;
     case 4057: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка обработки глобальныех переменных");                     break;
     case 4058: error_string = StringConcatenate("Код ошибки = ",error_code,". Глобальная переменная не обнаружена");                         break;
     case 4059: error_string = StringConcatenate("Код ошибки = ",error_code,". Функция не разрешена в тестовом режиме");                      break;
     case 4060: error_string = StringConcatenate("Код ошибки = ",error_code,". Функция не подтверждена");                                     break;
     case 4061: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка отправки почты");                                       break;
     case 4062: error_string = StringConcatenate("Код ошибки = ",error_code,". Ожидается параметр типа string");                              break;
     case 4063: error_string = StringConcatenate("Код ошибки = ",error_code,". Ожидается параметр типа integer");                             break;
     case 4064: error_string = StringConcatenate("Код ошибки = ",error_code,". Ожидается параметр типа double");                              break;
     case 4065: error_string = StringConcatenate("Код ошибки = ",error_code,". В качестве параметра ожидается массив");                       break;
     case 4066: error_string = StringConcatenate("Код ошибки = ",error_code,". Запрошенные исторические данные в состоянии обновления");      break;
     case 4067: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка при выполнении торговой операции");                     break;
     case 4099: error_string = StringConcatenate("Код ошибки = ",error_code,". Конец файла");                                                 break;
     case 4100: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка при работе с файлом");                                  break;
     case 4101: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильное имя файла");                                      break;
     case 4102: error_string = StringConcatenate("Код ошибки = ",error_code,". Слишком много открытых файлов");                               break;
     case 4103: error_string = StringConcatenate("Код ошибки = ",error_code,". Невозможно открыть файл");                                     break;
     case 4104: error_string = StringConcatenate("Код ошибки = ",error_code,". Несовместимый режим доступа к файлу");                         break;
     case 4105: error_string = StringConcatenate("Код ошибки = ",error_code,". Ни один ордер не выбран");                                     break;
     case 4106: error_string = StringConcatenate("Код ошибки = ",error_code,". Неизвестный символ");                                          break;
     case 4107: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильный параметр цены для торговой функции");             break;
     case 4108: error_string = StringConcatenate("Код ошибки = ",error_code,". Неверный номер тикета");                                       break;
     case 4109: error_string = StringConcatenate("Код ошибки = ",error_code,". Торговля не разрешена");                                       break;
     case 4110: error_string = StringConcatenate("Код ошибки = ",error_code,". Длинные позиции не разрешены");                                break;
     case 4111: error_string = StringConcatenate("Код ошибки = ",error_code,". Короткие позиции не разрешены");                               break;
     case 4200: error_string = StringConcatenate("Код ошибки = ",error_code,". Объект уже существует");                                       break;
     case 4201: error_string = StringConcatenate("Код ошибки = ",error_code,". Запрошено неизвестное свойство объекта");                      break;
     case 4202: error_string = StringConcatenate("Код ошибки = ",error_code,". Объект не существует");                                        break;
     case 4203: error_string = StringConcatenate("Код ошибки = ",error_code,". Неизвестный тип объекта");                                     break;
     case 4204: error_string = StringConcatenate("Код ошибки = ",error_code,". Нет имени объекта");                                           break;
     case 4205: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка координат объекта");                                    break;
     case 4206: error_string = StringConcatenate("Код ошибки = ",error_code,". Не найдено указанное подокно");                                break;
     case 4207: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка при работе с объектом");                                break;
     default:   error_string = StringConcatenate("Код ошибки = ",error_code,". неизвестная ошибка");
    }
//----
  return(error_string);
 }
//+------------------------------------------------------------------+



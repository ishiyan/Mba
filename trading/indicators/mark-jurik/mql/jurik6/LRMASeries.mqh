//Version  January 7, 2007 Final
//+X================================================================X+
//|                                                 LRMASeries().mqh |
//|                             LRMA code: Copyright © 2005, alexjou |
//|              MQL4 LRMASeries()Copyright © 2006, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+
  /*

  +-------------------------------------- <<< Функция LRMASeries() >>> -----------------------------------------------+

  +-----------------------------------------+ <<< Назначение >>> +----------------------------------------------------+

  Функция  LRMASeries()  предназначена  для  использования алгоритма линейной регрессии при написании любых индикаторов
  теханализа  и  экспертов,  для  замены  расчёта  классического усреднения на этот алгоритм. Функция не работает, если
  параметр  LRMA.limit  принимает  значение,  равное нулю! Все индикаторы, сделанные мною для LRMASeries(), выполнены с
  учётом  этого  ограничения.  Файл следует положить в папку (директорию): MetaTrader\experts\include\. Следует учесть,
  что  если  nLRMA.bar больше, чем nLRMA.MaxBar, то функция LRMASeries() возвращает значение равное нулю! на этом баре!
  И,  следовательно,  такое  значение  не может присутствовать в знаменателе какой-либо дроби в расчёте индикатора! Эта
  версия  функции  LRMASeries()  поддерживает  экспертов при её использовании в пользовательских индикаторах, к которым
  обращается  эксперт.  Эта  версия функции LRMASeries() поддерживает экспертов при её использовании в коде индикатора,
  который полностью помещён в код эксперта с сохранением всех операторов цикла! При написании индикаторов и экспертов с
  использованием  функции LRMASeries(), не рекомендуется переменным давать имена начинающиеся с nLRMA.... или dLRMA....
  Функция  LRMASeries() может быть использована во внутреннем коде других пользовательских функций, но при этом следует
  учитывать тот факт, что в каждом обращении к такой пользовательской функции у каждого обращения к LRMASeries() должен
  быть свой уникальный номер (nLRMA.number). 

  +-------------------------------------+ <<< Входные параметры >>> +-------------------------------------------------+

  nLRMA.n      - порядковый номер обращения к функции LRMASeries(). (0, 1, 2, 3 и.т.д....)
  nLRMA.MaxBar - Максимальное значение,  которое может  принимать номер  рассчитываемого бара (nLRMA.bar). Обычно равно 
                 Bars-1-period;  Где "period" -  это количество баров,  на которых  исходная величина  dLRMA.series  не 
                 рассчитывается; 
  nLRMA.limit  - Количество ещё не подсчитанных баров плюс один или номер последнего непосчитанного бара,   Должно быть 
                 обязательно равно  Bars-IndicatorCounted()-1;
  nLRMA.Period - период сглаживания. Параметр не меняется на каждом баре!    Макимальное значение ограниченно величиной 
                 500.            При необходимости  большего  значения,   следует  изменить  второе  измерение  буферов 
                 dLRMA.TempBuffer[1][500] и   dLRMA.TEMPBUFFER[1][500].   Минимальное значение ограниченно величиной 3.
  dLRMA.series - Входной  параметр, по которому производится расчёт функции LRMASeries();
  nLRMA.bar    - номер рассчитываемого бара,  параметр  должен  изменяться оператором цикла от максимального значения к 
                 нулевому.   Причём его максимальное значение всегда должно равняться значению параметра nLRMA.limit!!!

  +------------------------------------+ <<< Выходные параметры >>> +-------------------------------------------------+

  LRMASeries() - значение функции dLRMA.ret_val.       При значениях  nLRMA.bar  больше  чем  nLRMA.MaxBar-nLRMA.Length 
                 функция LRMASeries() всегда возвращает ноль!!!
  nLRMA.reset  - параметр, возвращающий по ссылке значение, отличенное от 0 ,  если произошла ошибка в расчёте функции,
                 0, если расчёт прошёл нормально. Этот параметр может быть только переменной, но не значением!!!

  +-----------------------------------+ <<< Инициализация функции >>> +-----------------------------------------------+

  Перед  обращениями  к  функции  LRMASeries()  ,  когда  количество  уже  подсчитанных баров равно 0, следует ввести и
  инициализировать  внутренние  переменные  функции,  для  этого  необходимо  обратиться  к  функции LRMASeries() через
  вспомогательную  функцию LRMASeriesResize() со следующими параметрами: LRMASeriesResize(MaxLRMA.number+1); необходимо
  сделать параметр nLRMA.n(MaxLRMA.number) равным количеству обращений к функции LRMASeries, то есть на единицу больше,
  чем максимальный nLRMA.n. 

  +--------------------------------------+ <<< Индикация ошибок >>> +-------------------------------------------------+
  
  При отладке индикаторов и экспертов их коды могут содержать ошибки, для выяснения причин которых следует смотреть лог
  файл.  Все  ошибки  функция LRMASeries() пишет в лог файл в папке \MetaTrader\EXPERTS\LOGS\. Если, перед обращением к
  функции  LRMASeries()  в коде, который предшествовал функции, возникла MQL4 ошибка, то функция запишет в лог файл код
  ошибки  и  содержание ошибки. Если при выполнении функции LRMASeries()в алгоритме LRMASeries() произошла MQL4 ошибка,
  то  функция  также  запишет  в  лог  файл код ошибки и содержание ошибки. При неправильном задании номера обращения к
  функции  LRMASeries()  nLRMA.number или неверном определении размера буферных переменных nJLRMAResize.Size в лог файл
  будет записаны сообщения о неверном определении этих параметров. Также в лог файл пишется информация при неправильном
  определении  параметра  nLRMA.limit.  Если  при  выполнении функции инициализации init() произошёл сбой при изменении
  размеров  буферных  переменных  функции  LRMASeries(),  то функция LRMASeriesResize() запишет в лог файл информацию о
  неудачном  изменении  размеров  буферных  переменных. Если при обращении к функции LRMASeries()через внешний оператор
  цикла  была  нарушена правильная последовательность изменения параметра nLRMA.bar, то в лог файл будет записана и эта
  информация. Следует учесть, что некоторые ошибки программного кода будут порождать дальнейшие ошибки в его исполнении
  и  поэтому,  если  функция  LRMASeries()  пишет  в лог файл сразу несколько ошибок, то устранять их следует в порядке
  времени  возникновения.  В правильно написанном индикаторе функция LRMASeries() может делать записи в лог файл только
  при  нарушениях  работы операционной системы. Исключение составляет запись изменения размеров буферных переменных при
  перезагрузке индикатора или эксперта, которая происходит при каждом вызове функции init(). 
  
  +---------------------------------+ <<< Пример обращения к функции >>> +--------------------------------------------+

//----+ определение функций LRMASeries()
#include <LRMASeries.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE); 
//---- 1 индикаторный буфер использован для счёта (без этого пересчёта функция LRMASeries() свой расчёт производить не будет!!!)
SetIndexBuffer(0,Ind_Buffer);
//----+ Изменение размеров буферных переменных функции LRMASeries, nLRMA.n=1(Одно обращение к функции LRMASeries)
if(LRMASeriesResize(1)==0)return(-1);
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
  //----+ Обращение к функции LRMASeries()за номером 0 для расчёта буфера Ind_Buffer[], 
  double Resalt=LRMASeries(0,MaxBar,limit,Length,Series,bar,reset);
  if (reset!=0)return(-1);
  Ind_Buffer[bar]=Resalt;
 }
return(0);
}
//----+ 

*/
//+X================================================================X+
//|  LRMASeries() function                                           |
//+X================================================================X+   

//----++ <<< Введение и инициализация переменных >>> 
double dLRMA.TempBuffer[1][501];
double dLRMA.TEMPBUFFER[1][501],dLRMA.den_x[1];
int nLRMA.range1, nLRMA.range2, nLRMA.rangeMin; 
int nLRMA.sum_x[1], nLRMA.sum_x2[1], nLRMA.TIME[1];
//----++
double dLRMA.sum_y, dLRMA.sum_xy, dLRMA.var_tmp;
double dLRMA.A, dLRMA.B, dLRMA.ret_val;
int    nLRMA.iii, nLRMA.loop_begin,nLRMA.Error;
int    nLRMA.Tnew,nLRMA.Told,nLRMA.n,nLRMA.Resize;

//----++ <<< Объявление функции LRMASeries() >>> +---------------------------------------------------------------------------+

double LRMASeries
 (
  int nLRMA.number, int nLRMA.MaxBar, int nLRMA.limit, int nLRMA.period, double dLRMA.series, int nLRMA.bar, int& nLRMA.reset
 )
//----++---------------------------------------------------------------------------------------------------------------------+
{
nLRMA.n = nLRMA.number;

nLRMA.reset = 1;
//=====+ <<< Проверки на ошибки >>> +--------------------------------------------------------------------+
if (nLRMA.bar == nLRMA.limit)
 {
  //----++ проверка на инициализацию функции LRMASeries()
  if (nLRMA.Resize < 1)
   {
    Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
         ". Не было сделано изменение размеров буферных переменных функцией LRMASeriesResize()"));
    if(nLRMA.Resize == 0)
          Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
                ". Следует дописать обращение к функции LRMASeriesResize() в блок инициализации"));
         
    return(0.0);
   }
  //----++ проверка на ошибку в исполнении программного кода, предшествовавшего функции LRMASeries()
  nLRMA.Error = GetLastError();
  if(nLRMA.Error > 4000)
   {
    Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
         ". В коде, предшествующем обращению к функции LRMASeries() number = ", nLRMA.n, " ошибка!!!"));
    Print(StringConcatenate("LRMASeries() number = ", nLRMA.n, ". ", LRMA_ErrDescr(nLRMA.Error)));  
   } 
                                                   
  //----++ проверка на ошибку в задании переменных nLRMA.number и nLRMAResize.Number
  if (ArraySize(nLRMA.sum_x) < nLRMA.number) 
   {
    Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
                 ". Ошибка!!! Неправильно задано значение переменной nLRMA.number функции LRMASeries()"));
    Print(StringConcatenate("LRMASeries() number = ", nLRMA.n,
            ". Или неправильно задано значение  переменной nLRMAResize.Size функции LRMASeriesResize()"));
    return(0.0);
   }
 }
//----++ +------------------------------------------------------------------------------------------------+ 
  
if (nLRMA.bar > nLRMA.MaxBar){nLRMA.reset = 0; return(0.0);}

if(nLRMA.bar != nLRMA.limit)
        for(nLRMA.iii = nLRMA.period; nLRMA.iii >= 0; nLRMA.iii--)
                                          dLRMA.TempBuffer[nLRMA.n][nLRMA.iii + 1] =
                                                                dLRMA.TempBuffer[nLRMA.n][nLRMA.iii];
dLRMA.TempBuffer[nLRMA.n][0] = dLRMA.series;

if (nLRMA.period < 3)nLRMA.period = 3;
else if (nLRMA.period > nLRMA.rangeMin){nLRMA.period = nLRMA.rangeMin;}

if (nLRMA.bar > nLRMA.MaxBar - nLRMA.period){nLRMA.reset = 0; return(0.0);}

//----++ <<< Расчёт коэффициентов  >>> +-------------------------+
if (nLRMA.bar == nLRMA.MaxBar - nLRMA.period)
 {
  for(nLRMA.iii = 1; nLRMA.iii <= nLRMA.period; nLRMA.iii++)
   {
    nLRMA.sum_x[nLRMA.n]  += nLRMA.iii;
    nLRMA.sum_x2[nLRMA.n] += nLRMA.iii * nLRMA.iii;
   }
  dLRMA.den_x[nLRMA.n] = nLRMA.period * nLRMA.sum_x2[nLRMA.n] 
                - nLRMA.sum_x[nLRMA.n] * nLRMA.sum_x[nLRMA.n];
 }
//----++ -------------------------------------------------------+  

if (nLRMA.period<1)nLRMA.period=1;

//----++ проверка на ошибку в последовательности изменения переменной nLRMA.bar
if (nLRMA.limit >= nLRMA.MaxBar)
 if (nLRMA.bar == 0)
  if (nLRMA.MaxBar > nLRMA.period)
   if (nLRMA.TIME[nLRMA.n] == 0)
                        Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
                        ". Ошибка!!! Нарушена правильная последовательность изменения ",
                                             "параметра nLRMA.bar внешним оператором цикла!!!"));  

//----+ <<< Восстановление значений переменных >>> +-----------------------------------------------------+
if (nLRMA.bar == nLRMA.limit)
 if (nLRMA.limit < nLRMA.MaxBar)
  {
   nLRMA.Tnew = Time[nLRMA.limit + 1];
   nLRMA.Told = nLRMA.TIME[nLRMA.n];
    //--+
   if(nLRMA.Tnew == nLRMA.Told)
   for(nLRMA.iii = nLRMA.period; nLRMA.iii >= 1; nLRMA.iii--)
                               dLRMA.TempBuffer[nLRMA.n][nLRMA.iii] =
                                               dLRMA.TEMPBUFFER[nLRMA.n][nLRMA.iii];  
   //--+ проверка на ошибки
   if(nLRMA.Tnew != nLRMA.Told)
    {
     nLRMA.reset = -1;
     //--+ индикация ошибки в расчёте входного параметра nLRMA.limit функции LRMASeries()
     if (nLRMA.Tnew > nLRMA.Told)
       {
       Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
                   ". Ошибка!!! Параметр nLRMA.limit функции LRMASeries() меньше, чем необходимо"));
       }
     else 
       { 
       int nLRMA.LimitERROR = nLRMA.limit + 1 - iBarShift(NULL, 0, nLRMA.Told, TRUE);
       Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
               ". Ошибка!!! Параметр nLRMA.limit функции LRMASeries() больше, чем необходимо на ",
                                                                                     nLRMA.LimitERROR));
       }
     //--+ Возврат через nLRMA.reset=-1; ошибки в расчёте функции LRMASeries
     return(0);
    } 
  }                    
//----++--------------------------------------------------------------------------------------------------+

//+--- Сохранение значений переменных +--------------------------------+
if (nLRMA.bar == 1)
 if (nLRMA.limit != 1)
  {
   nLRMA.TIME[nLRMA.n] = Time[2];
   for(nLRMA.iii = nLRMA.period; nLRMA.iii >= 1; nLRMA.iii--)
                           dLRMA.TEMPBUFFER[nLRMA.n][nLRMA.iii] =
                                dLRMA.TempBuffer[nLRMA.n][nLRMA.iii];      
  }
//+---++---------------------------------------------------------------+  

  nLRMA.loop_begin = nLRMA.period - 1;
  dLRMA.sum_y   = 0.0;
  dLRMA.sum_xy  = 0.0;
  for (nLRMA.iii = 1; nLRMA.iii <= nLRMA.period; nLRMA.iii++)
   {
    dLRMA.var_tmp  = dLRMA.TempBuffer[nLRMA.n][nLRMA.loop_begin - nLRMA.iii + 1];  
    dLRMA.sum_y   += dLRMA.var_tmp;
    dLRMA.sum_xy  += nLRMA.iii * dLRMA.var_tmp; 
   }
  dLRMA.B = (nLRMA.period * dLRMA.sum_xy - 
                      nLRMA.sum_x[nLRMA.n] * dLRMA.sum_y) / dLRMA.den_x[nLRMA.n];
                  
  dLRMA.A = (dLRMA.sum_y - dLRMA.B * nLRMA.sum_x[nLRMA.n]) / nLRMA.period;             
  //
  dLRMA.ret_val = dLRMA.A + dLRMA.B * nLRMA.period;   
 //----
 //----++ проверка на ошибку в исполнении программного кода функции JLRMASeries()
 nLRMA.Error = GetLastError();
 if(nLRMA.Error > 4000)
   {
    Print(StringConcatenate("LRMASeries number = ",
                nLRMA.n, ". При исполнении функции LRMASeries() произошла ошибка!!!"));
                
    Print(StringConcatenate
                  ("LRMASeries number = ", nLRMA.n, ". ", LRMA_ErrDescr(nLRMA.Error)));   
    return(0.0);
   }
  nLRMA.reset = 0;
  return(dLRMA.ret_val);
  
//----+  завершение вычисления функции LRMASeries() --------------------------+  
}
//+X==============================================================================================X+
// LRMASeriesResize - Это дополнительная функция для изменения размеров буферных переменных       | 
// функции LRMASeries. Пример обращения: LRMASeriesResize(5); где 5 - это количество обращений к  | 
// LRMASeries()в тексте индикатора. Это обращение к функции  LRMASeriesResize следует поместить   |
// в блок инициализации пользовательского индикатора или эксперта                                 |
//+X==============================================================================================X+
int LRMASeriesResize(int nLRMAResize.Size)
 {
//----+
  if (nLRMAResize.Size < 1)
   {
    Print("LRMASeriesResize: Ошибка!!! Параметр nLRMAResize.Size не может быть меньше единицы!!!"); 
    nLRMA.Resize = -1; 
    return(0);
   }
  //----+    
  nLRMA.range1 = ArrayRange(dLRMA.TempBuffer, 1) - 1; 
  nLRMA.range2 = ArrayRange(dLRMA.TEMPBUFFER, 1) - 1;   
  nLRMA.rangeMin = MathMin(nLRMA.range1, nLRMA.range2);
  if (nLRMAResize.Size == -2)return(nLRMA.rangeMin);
  //----+  
  int nLRMAResize.reset, nLRMAResize.cycle;
  //--+
  while(nLRMAResize.cycle == 0)
   {
    //----++ <<< изменение размеров буферных переменных >>>  +-----------------------------+
    if(ArrayResize(dLRMA.TempBuffer, nLRMAResize.Size) == 0){nLRMAResize.reset = -1; break;}
    if(ArrayResize(dLRMA.TEMPBUFFER, nLRMAResize.Size) == 0){nLRMAResize.reset = -1; break;}
    if(ArrayResize(nLRMA.sum_x ,     nLRMAResize.Size) == 0){nLRMAResize.reset = -1; break;}
    if(ArrayResize(nLRMA.sum_x2,     nLRMAResize.Size) == 0){nLRMAResize.reset = -1; break;}
    if(ArrayResize(dLRMA.den_x,      nLRMAResize.Size) == 0){nLRMAResize.reset = -1; break;}
    if(ArrayResize(nLRMA.TIME,       nLRMAResize.Size) == 0){nLRMAResize.reset = -1; break;}
    //----++-------------------------------------------------------------------------------+
    nLRMAResize.cycle = 1;
   }
  //--+
  if (nLRMAResize.reset == -1)
   {
    Print(StringConcatenate
        ("LRMASeriesResize: Ошибка!!! Не удалось ",
             "изменить размеры буферных переменных функции LRMASeries()."));
             
    int nLRMAResize.Error = GetLastError();
    if (nLRMAResize.Error > 4000)
            Print(StringConcatenate("LRMASeriesResize: ",
                                     LRMA_ErrDescr(nLRMAResize.Error)));    
    nLRMA.Resize = -2;
    return(0);
   }
  else  
   {
    Print(StringConcatenate
         ("LRMASeriesResize: LRMASeries Size = ", nLRMAResize.Size));
    nLRMA.Resize = nLRMAResize.Size;
    return(nLRMAResize.Size);
   }  
//----+
 }
/*
//+X====================================================================================================X+
LRMASeriesAlert - Это дополнительная функция для индикации ошибки в задании внешних переменных           |
функции LRMASeries.                                                                                      |
  -------------------------- входные параметры  --------------------------                               |
LRMASeriesAlert.Number                                                                                   |
LRMASeriesAlert.ExternVar значение внешней переменной для параметра nLRMA.Phase                          |
LRMASeriesAlert.name имя внешней переменной для параметра nLRMA.Length, если LRMASeriesAlert.Number=0.   |                                                  
  -------------------------- Пример использования  -----------------------                               |
  int init()                                                                                             |
//----                                                                                                   |
Здесь какая-нибудь инициализация переменных и буферов                                                    |
                                                                                                         |
//---- установка алертов на недопустимые значения внешних переменных                                     |                                                           
LRMASeriesAlert(0,"Length1",Length1);                                                                    |
LRMASeriesAlert(0,"Length2",Length2);                                                                    |
//---- завершение инициализации                                                                          |
return(0);                                                                                               |
}                                                                                                        |
//+X====================================================================================================X+
*/
void LRMASeriesAlert
 (
  int LRMASeriesAlert.Number, string LRMASeriesAlert.name, int LRMASeriesAlert.ExternVar
 )
 {
  //---- установка алертов на недопустимые значения входных параметров 
   if (LRMASeriesAlert.Number == 0)
     if (LRMASeriesAlert.ExternVar < 3)
          Alert(StringConcatenate("Параметр ", LRMASeriesAlert.ExternVar, " должен быть не менее 3", 
                            " Вы ввели недопустимое " ,LRMASeriesAlert.ExternVar," будет использовано  3"));
                            
   int LRMASeriesAlert.MaxPeriod = ArrayRange(dLRMA.TempBuffer, 1);  
   if (LRMASeriesAlert.Number == 0)
     if (LRMASeriesAlert.ExternVar > LRMASeriesAlert.MaxPeriod)
      Alert(StringConcatenate
               ("Параметр ",LRMASeriesAlert.name," должен быть не более ",
                           LRMASeriesAlert.MaxPeriod, " Вы ввели недопустимое ",
                                   LRMASeriesAlert.ExternVar," будет использовано  ",
                                       LRMASeriesAlert.MaxPeriod, " Если необходимо большее ",
                                         "значение параметра nLRMA.period, измените вторые измерения буферов",
                                                        " dLRMA.TempBuffer и dLRMA.TEMPBUFFER функции LRMASeries"));
          
 }
// перевод сделан Николаем Косициным 01.12.2006  
//+X================================================================X+
//|                                      LRMA_ErrDescr_RUS(MQL4).mqh |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+X================================================================X+
string LRMA_ErrDescr(int error_code)
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


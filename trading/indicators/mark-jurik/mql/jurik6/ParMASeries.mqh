//Version  January 7, 2007 Final
//+X================================================================X+
//|                                                ParMASeries().mqh |
//|          Parabolic approximation code: Copyright © 2005, alexjou |
//|        MQL4 ParMASeries() Copyright © 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+ 
  /*
  
  ---------------------------------------- <<< Функция ParMASeries() >>> ----------------------------------------------

  +-----------------------------------------+ <<< Назначение >>> +----------------------------------------------------+

  Функция  ParMASeries()  предназначена  для  использования  алгоритма  параболической апроксимации при написании любых
  индикаторов  теханализа  и  экспертов,  для  замены  расчёта  классического  усреднения  на этот алгоритм. Функция не
  работает,   если   параметр  ParMA.limit  принимает  значение,  равное  нулю!  Все  индикаторы,  сделанные  мною  для
  ParMASeries(),   выполнены   с   учётом   этого   ограничения.   Файл   следует   положить   в   папку  (директорию):
  MetaTrader\experts\include\.   Следует   учесть,   что   если   nParMA.bar  больше,  чем  nParMA.MaxBar,  то  функция
  ParMASeries()возвращает  значение равное нулю! на этом баре! И, следовательно, такое значение не может присутствовать
  в  знаменателе  какой-либо дроби в расчёте индикатора! Эта версия функции ParMASeries() поддерживает экспертов при её
  использовании  в  пользовательских  индикаторах,  к  которым  обращается  эксперт.  Эта  версия функции ParMASeries()
  поддерживает экспертов при её использовании в коде индикатора, который полностью помещён в код эксперта с сохранением
  всех операторов цикла! При написании индикаторов и экспертов с использованием функции ParMASeries(), не рекомендуется
  переменным  давать  имена  начинающиеся  с nParMA.... или dParMA.... Функция ParMASeries() может быть использована во
  внутреннем  коде  других  пользовательских  функций, но при этом следует учитывать тот факт, что в каждом обращении к
  такой пользовательской функции у каждого обращения к ParMASeries() должен быть свой уникальный номер (nParMA.number).

  +-------------------------------------+ <<< Входные параметры >>> +-------------------------------------------------+

  nParMA.n      - порядковый номер обращения к функции ParMASeries(). (0, 1, 2, 3 и.т.д....)
  nParMA.MaxBar - Максимальное значение, которое может  принимать номер рассчитываемого бара (nParMA.bar). Обычно равно 
                  Bars-1-period; Где "period" -  это количество баров,  на которых  исходная величина dParMA.series  не 
                  рассчитывается; 
  nParMA.limit  - Количество ещё не подсчитанных баров плюс один или номер последнего непосчитанного бара,  Должно быть 
                  обязательно равно  Bars-IndicatorCounted()-1;
  nParMA.Period - период сглаживания. Параметр не меняется на каждом баре!   Макимальное значение ограниченно величиной 
                  500.           При необходимости  большего  значения,   следует  изменить  второе  измерение  буферов 
                  dParMA.TempBuffer[1][500] и  dParMA.TEMPBUFFER[1][500]. Минимальное значение ограниченно величиной 3.
  dParMA.series - Входной  параметр, по которому производится расчёт функции ParMASeries();
  nParMA.bar    - номер рассчитываемого бара,  параметр  должен изменяться оператором цикла от максимального значения к 
                  нулевому. Причём его максимальное значение всегда должно равняться значению параметра nParMA.limit!!!

  +------------------------------------+ <<< Выходные параметры >>> +-------------------------------------------------+

  ParMASeries() - значение функции dParMA.ret_val.  При значениях  nParMA.bar  больше  чем  nParMA.MaxBar-nParMA.Length 
                  функция ParMASeries() всегда возвращает ноль!!!
  nParMA.reset  - параметр, возвращающий по ссылке значение, отличенное от 0 , если произошла ошибка в расчёте функции,
                  0, если расчёт прошёл нормально. Этот параметр может быть только переменной, но не значением!!!

  +-----------------------------------+ <<< Инициализация функции >>> +-----------------------------------------------+

  Перед  обращениями  к  функции  ParMASeries()  ,  когда  количество  уже подсчитанных баров равно 0, следует ввести и
  инициализировать  внутренние  переменные  функции,  для  этого  необходимо  обратиться  к  функции ParMASeries()через
  вспомогательную   функцию   ParMASeriesResize()   со  следующими  параметрами:  ParMASeriesResize(MaxParMA.number+1);
  необходимо сделать параметр nParMA.n(MaxParMA.number) равным количеству обращений к функции ParMASeries(), то есть на
  единицу больше, чем максимальный nParMA.n. 
  
  +--------------------------------------+ <<< Индикация ошибок >>> +-------------------------------------------------+
  
  При отладке индикаторов и экспертов их коды могут содержать ошибки, для выяснения причин которых следует смотреть лог
  файл.  Все  ошибки функция ParMASeries() пишет в лог файл в папке \MetaTrader\EXPERTS\LOGS\. Если, перед обращением к
  функции  ParMASeries() в коде, который предшествовал функции, возникла MQL4 ошибка, то функция запишет в лог файл код
  ошибки  и  содержание  ошибки.  Если  при  выполнении  функции ParMASeries() в алгоритме ParMASeries() произошла MQL4
  ошибка, то функция также запишет в лог файл код ошибки и содержание ошибки. При неправильном задании номера обращения
  к  функции  ParMASeries() nParMA.number или неверном определении размера буферных переменных nJParMAResize.Size в лог
  файл  будет  записаны  сообщения  о  неверном  определении  этих  параметров. Также в лог файл пишется информация при
  неправильном  определении параметра nParMA.limit. Если при выполнении функции инициализации init() произошёл сбой при
  изменении  размеров  буферных  переменных  функции  ParMASeries(),  то функция ParMASeriesResize() запишет в лог файл
  информацию  о  неудачном  изменении  размеров  буферных  переменных. Если при обращении к функции ParMASeries() через
  внешний  оператор  цикла  была  нарушена  правильная последовательность изменения параметра nParMA.bar, то в лог файл
  будет  записана  и  эта информация. Следует учесть, что некоторые ошибки программного кода будут порождать дальнейшие
  ошибки  в  его исполнении и поэтому, если функция ParMASeries() пишет в лог файл сразу несколько ошибок, то устранять
  их  следует  в  порядке  времени  возникновения. В правильно написанном индикаторе функция ParMASeries() может делать
  записи  в лог файл только при нарушениях работы операционной системы. Исключение составляет запись изменения размеров
  буферных переменных при перезагрузке индикатора или эксперта, которая происходит при каждом вызове функции init(). 
  +---------------------------------+ <<< Пример обращения к функции >>> +--------------------------------------------+

//----+ определение функций ParMASeries()
#include <ParMASeries.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE); 
//---- 1 индикаторный буфер использован для счёта
SetIndexBuffer(0,Ind_Buffer);
//----+ Изменение размеров буферных переменных функции ParMASeries, nParMA.n=1(Одно обращение к функции ParMASeries)
if(ParMASeriesResize(1)==0)return(-1);
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
//---- последний подсчитанный бар должен быть пересчитан (без этого пересчёта функция ParMASeries() свой расчёт производить не будет!!!)
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
int limit=Bars-counted_bars-1;
MaxBar=Bars-1;
//----+ 
for(bar=limit;bar>=0;bar--)
 (
  double Series=Close[bar];
  //----+ Обращение к функции ParMASeries()за номером 0 для расчёта буфера Ind_Buffer[], 
  double Resalt=ParMASeries(0,MaxBar,limit,Length,Series,bar,reset);
  if (reset!=0)return(-1);
  Ind_Buffer[bar]=Resalt;
 }
return(0);
}
//----+ 
//+X================================================================X+
//|  ParMASeries() function                                          |
//+X================================================================X+   
*/
//----++ <<< Введение и инициализация переменных >>> +--------------+ 
double dParMA.TempBuffer[1][501], dParMA.TEMPBUFFER[1][501];
int nParMA.range1, nParMA.range2, nParMA.rangeMin; 
int nParMA.sum_x [1], nParMA.sum_x2[1], nParMA.sum_x3[1];
int nParMA.sum_x4[1], nParMA.TIME[1];
//----++
double dParMA.sum_y, dParMA.sum_xy, dParMA.sum_x2y, dParMA.var_tmp;
double dParMA.A, dParMA.B, dParMA.C, dParMA.D, dParMA.E, dParMA.F; 
double dParMA.K, dParMA.L, dParMA.M, dParMA.P, dParMA.Q, dParMA.R; 
double dParMA.S, dParMA.B0, dParMA.B1, dParMA.B2, dParMA.ret_val;
int    nParMA.iii, nParMA.loop_begin,nParMA.Error,nParMA.Tnew;
int    nParMA.Told,nParMA.n,nParMA.Resize; 
//----++------------------------------------------------------------+
//----++ <<< Объявление функции ParMASeries() >>> +----------------------------------------------------------------------------------+
double ParMASeries
 (
  int nParMA.number, int nParMA.MaxBar, int nParMA.limit, int nParMA.period, double dParMA.series, int nParMA.bar, int& nParMA.reset
  )
//----++-----------------------------------------------------------------------------------------------------------------------------+
 
{
nParMA.n = nParMA.number;

nParMA.reset = 1;
//----++ <<< Проверки на ошибки >>> ----------------------------------------------------------------------+
if (nParMA.bar == nParMA.limit)
 {
  //----++ проверка на инициализацию функции ParMASeries()
  if(nParMA.Resize < 1)
   {
    Print(StringConcatenate("ParMASeries number = ",nParMA.n,
         ". Не было сделано изменение размеров буферных переменных функцией ParMASeriesResize()"));
    if(nParMA.Resize == 0)
       Print(StringConcatenate("ParMASeries number = ",nParMA.n,
                ". Следует дописать обращение к функции ParMASeriesResize() в блок инициализации"));
         
    return(0.0);
   }
  //----++ проверка на ошибку в исполнении программного кода, предшествовавшего функции ParMASeries()
  nParMA.Error = GetLastError();
  if(nParMA.Error > 4000)
   {
    Print(StringConcatenate("ParMASeries number = ",nParMA.n,
         ". В коде, предшествующем обращению к функции ParMASeries() number = ",nParMA.n," ошибка!!!"));
    Print(StringConcatenate("ParMASeries number = ",nParMA.n, ". ",ParMA_ErrDescr(nParMA.Error)));  
   } 
                                                   
  //----++ проверка на ошибку в задании переменных nParMA.number и nParMAResize.Number
  if (ArraySize(nParMA.sum_x)< nParMA.number) 
   {
    Print(StringConcatenate("ParMASeries number = ",nParMA.n,
                ". Ошибка!!! Неправильно задано значение переменной nParMA.number функции ParMASeries()"));
    Print(StringConcatenate("ParMASeries number = ",nParMA.n,
         ". Или неправильно задано значение  переменной nParMAResize.Size функции ParMASeriesResize()"));
    return(0.0);
   }
 }
//----++ +--------------------------------------------------------------------------------------------------+ 

if (nParMA.bar > nParMA.MaxBar)
               {nParMA.reset = 0; return(0.0);}

if(nParMA.bar != nParMA.limit)
        for(nParMA.iii = nParMA.period; nParMA.iii >= 0; nParMA.iii--)
                              dParMA.TempBuffer[nParMA.n][nParMA.iii+1] =
                                       dParMA.TempBuffer[nParMA.n][nParMA.iii];
                                 
dParMA.TempBuffer[nParMA.n][0] = dParMA.series;

if (nParMA.period < 3)nParMA.period = 3;
else if (nParMA.period > nParMA.rangeMin)nParMA.period = nParMA.rangeMin; 

if (nParMA.bar > nParMA.MaxBar - nParMA.period)
                               {nParMA.reset =0; return(0.0);}

//----++ <<< Расчёт коэффициентов  >>> +-------------------+
if (nParMA.bar == nParMA.MaxBar - nParMA.period)
{ 
 for(nParMA.iii = 1; nParMA.iii <= nParMA.period; nParMA.iii++)
   {
    dParMA.var_tmp  = nParMA.iii;
    nParMA.sum_x[nParMA.n]   += dParMA.var_tmp; 
    dParMA.var_tmp *= nParMA.iii;
    nParMA.sum_x2[nParMA.n]  += dParMA.var_tmp; 
    dParMA.var_tmp *= nParMA.iii;
    nParMA.sum_x3[nParMA.n]  += dParMA.var_tmp; 
    dParMA.var_tmp *= nParMA.iii;
    nParMA.sum_x4[nParMA.n]  += dParMA.var_tmp; 
   }
}
//----++ --------------------------------------------------+  

if (nParMA.period < 1)nParMA.period = 1;

//----++ проверка на ошибку в последовательности изменения переменной nParMA.bar
if (nParMA.limit >= nParMA.MaxBar)
 if (nParMA.bar == 0)
   if (nParMA.MaxBar > nParMA.period)
       if (nParMA.TIME[nParMA.n] == 0)
          Print(StringConcatenate("ParMASeries number = ", nParMA.n,
                     ". Ошибка!!! Нарушена правильная последовательность",
                         " изменения параметра nParMA.bar внешним оператором цикла!!!")); 
                        
if(nParMA.bar == nParMA.limit)
 if (nParMA.limit < nParMA.MaxBar)
{
//----+ <<< Восстановление значений переменных >>> +------------------------------------------------------------------+
nParMA.Tnew = Time[nParMA.limit + 1];
nParMA.Told = nParMA.TIME[nParMA.n];
 //--+
if(nParMA.Tnew == nParMA.Told)
         for(nParMA.iii = nParMA.period; nParMA.iii >= 1; nParMA.iii--)
                                     dParMA.TempBuffer[nParMA.n][nParMA.iii] =
                                                         dParMA.TEMPBUFFER[nParMA.n][nParMA.iii];  
//--+ проверка на ошибки
if(nParMA.Tnew != nParMA.Told)
    {
     nParMA.reset = -1;
     //--+ индикация ошибки в расчёте входного параметра nParMA.limit функции ParMASeries()
     if (nParMA.Tnew > nParMA.TIME[nParMA.n])
       {
       Print(StringConcatenate("ParMASeries number = ", nParMA.n,
                                 ". Ошибка!!! Параметр nParMA.limit функции ParMASeries() меньше, чем необходимо"));
       }
    else 
       { 
       int nParMA.LimitERROR = nParMA.limit + 1 - iBarShift(NULL, 0, nParMA.TIME[nParMA.n], TRUE);
       
       Print(StringConcatenate("ParMASeries number = ",nParMA.n,
                        ". Ошибка!!! Параметр nParMA.limit функции ParMASeries() больше, чем необходимо на ",
                                                                                                    nParMA.LimitERROR));
       }
  //--+ Возврат через nParMA.reset=-1; ошибки в расчёте функции ParMASeries
  return(0);
  }                     
//----+----------------------------------------------------------------------------------------------------------------+
} 

//+--- Сохранение значений переменных +---------------------------------------+
if (nParMA.bar == 1)
 if (nParMA.limit != 1)
  {
   nParMA.TIME[nParMA.n] = Time[2];
   for(nParMA.iii = nParMA.period; nParMA.iii >= 1; nParMA.iii--)
                             dParMA.TEMPBUFFER[nParMA.n][nParMA.iii]=
                                    dParMA.TempBuffer[nParMA.n][nParMA.iii];      
  }
//+---+-----------------------------------------------------------------------+  
 
  // main calculation loop
  nParMA.loop_begin = nParMA.period - 1;
  dParMA.sum_y   = 0.0;
  dParMA.sum_xy  = 0.0;
  dParMA.sum_x2y = 0.0;
  for (nParMA.iii = 1; nParMA.iii <= nParMA.period; nParMA.iii++)
   {
    dParMA.var_tmp  = dParMA.TempBuffer[nParMA.n][nParMA.loop_begin - nParMA.iii + 1];  
    dParMA.sum_y   += dParMA.var_tmp;
    dParMA.sum_xy  += nParMA.iii * dParMA.var_tmp;    
    dParMA.sum_x2y += nParMA.iii * nParMA.iii * dParMA.var_tmp; 
   }
  // initialization
  dParMA.A = nParMA.period;
  dParMA.B = nParMA.sum_x[nParMA.n];  
  dParMA.C = nParMA.sum_x2[nParMA.n]; 
  dParMA.F = nParMA.sum_x3[nParMA.n]; 
  dParMA.M = nParMA.sum_x4[nParMA.n]; 
  dParMA.P = dParMA.sum_y;                   
  dParMA.R = dParMA.sum_xy; 
  dParMA.S = dParMA.sum_x2y;
  // intermediates
  dParMA.D = dParMA.B;  dParMA.E = dParMA.C;  dParMA.K = dParMA.C;  dParMA.L = dParMA.F;
  dParMA.Q = dParMA.D / dParMA.A;  dParMA.E = dParMA.E - dParMA.Q * dParMA.B; 
  dParMA.F = dParMA.F - dParMA.Q * dParMA.C;  dParMA.R = dParMA.R - dParMA.Q * dParMA.P;  
  dParMA.Q = dParMA.K / dParMA.A;  dParMA.L = dParMA.L - dParMA.Q * dParMA.B;
  dParMA.M = dParMA.M - dParMA.Q * dParMA.C;  dParMA.S = dParMA.S - dParMA.Q * dParMA.P; 
  dParMA.Q = dParMA.L / dParMA.E;
  // calculate regression coefficients
  dParMA.B2 = (dParMA.S - dParMA.R * dParMA.Q) / (dParMA.M - dParMA.F * dParMA.Q);
  dParMA.B1 = (dParMA.R - dParMA.F * dParMA.B2) / dParMA.E;
  dParMA.B0 = (dParMA.P - dParMA.B * dParMA.B1 - dParMA.C * dParMA.B2) / dParMA.A;
  // value to be returned - parabolic MA
  dParMA.ret_val = dParMA.B0 + (dParMA.B1 + dParMA.B2 * dParMA.A) * dParMA.A;
 //----
 //----++ проверка на ошибку в исполнении программного кода функции JParMASeries()
nParMA.Error = GetLastError();
if(nParMA.Error > 000)
  {
    Print(StringConcatenate("ParMASeries number = ",
                         nParMA.n,". При исполнении функции ParMASeries() произошла ошибка!!!"));
    Print(StringConcatenate("ParMASeries number = ",nParMA.n,". ",ParMA_ErrDescr(nParMA.Error)));   
    return(0.0);
  }
  
  nParMA.reset = 0;
  return(dParMA.ret_val);
//---- завершение вычислений значения функции ParMASeries() ----------------+ 
}

//--+ --------------------------------------------------------------------------------------------+


//+X==============================================================================================X+
// ParMASeriesResize - Это дополнительная функция для изменения размеров буферных переменных       | 
// функции ParMASeries. Пример обращения: ParMASeriesResize(5); где 5 - это количество обращений к | 
// ParMASeries()в тексте индикатора. Это обращение к функции  ParMASeriesResize следует поместить  |
// в блок инициализации пользовательского индикатора или эксперта                                  |
//+X==============================================================================================X+
int ParMASeriesResize(int nParMAResize.Size)
 {
//----+
  if(nParMAResize.Size < 1)
   {
    Print("ParMASeriesResize: Ошибка!!! Параметр nParMAResize.Size не может быть меньше единицы!!!"); 
    nParMA.Resize = -1; 
    return(0);
   }
  //----+    
  nParMA.range1 = ArrayRange(dParMA.TempBuffer, 1) - 1; 
  nParMA.range2 = ArrayRange(dParMA.TEMPBUFFER, 1) - 1;   
  nParMA.rangeMin = MathMin(nParMA.range1, nParMA.range2);
  if (nParMAResize.Size == -2)return(nParMA.rangeMin);
  //----+
  int nParMAResize.reset, nParMAResize.cycle;
  //--+
  while(nParMAResize.cycle == 0)
   {
    //----++ <<< изменение размеров буферных переменных >>>  +--------------------------------+
    if(ArrayResize(dParMA.TempBuffer, nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(dParMA.TEMPBUFFER, nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(nParMA.sum_x ,     nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(nParMA.sum_x2,     nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(nParMA.sum_x3,     nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(nParMA.sum_x4,     nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(nParMA.TIME,       nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    //----++----------------------------------------------------------------------------------+
    nParMAResize.cycle = 1;
   }
  //--+
  if (nParMAResize.reset == -1)
   {
    Print("ParMASeriesResize: Ошибка!!! Не удалось изменить размеры буферных переменных функции ParMASeries().");
    int nParMAResize.Error = GetLastError();
    if(nParMAResize.Error > 4000)
               Print(StringConcatenate("ParMASeriesResize(): ", ParMA_ErrDescr(nParMAResize.Error)));    
    nParMA.Resize = -2;
    return(0);
   }
  else  
   {
    Print(StringConcatenate("ParMASeriesResize: ParMASeries()size = ", nParMAResize.Size));
    nParMA.Resize = nParMAResize.Size;
    return(nParMAResize.Size);
   }  
//----+
 }
//--+ --------------------------------------------------------------------------------------------+
/*
//+X====================================================================================================X+
ParMASeriesAlert - Это дополнительная функция для индикации ошибки в задании внешних переменных          |
функции ParMASeries.                                                                                     |
  -------------------------- входные параметры  --------------------------                               |
ParMASeriesAlert.Number                                                                                  |
ParMASeriesAlert.ExternVar значение внешней переменной для параметра nParMA.Phase                        |
ParMASeriesAlert.name имя внешней переменной для параметра nParMA.Length, если ParMASeriesAlert.Number=0.|                                                  
  -------------------------- Пример использования  -----------------------                               |
  int init()                                                                                             |
//----                                                                                                   |
Здесь какая-то инициализация переменных и буферов                                                        |
                                                                                                         |
//---- установка алертов на недопустимые значения внешних переменных                                     |                                                           
ParMASeriesAlert(0,"Length1",Length1);                                                                   |
ParMASeriesAlert(0,"Length2",Length2);                                                                   |
//---- завершение инициализации                                                                          |
return(0);                                                                                               |
}                                                                                                        |
//+X====================================================================================================X+
*/
void ParMASeriesAlert
 (int ParMASeriesAlert.Number, string ParMASeriesAlert.name, int ParMASeriesAlert.ExternVar)
 {
  //---- установка алертов на недопустимые значения входных параметров ==========================+ 
   if (ParMASeriesAlert.Number == 0)
     if (ParMASeriesAlert.ExternVar < 3)
          Alert(StringConcatenate("Параметр ", ParMASeriesAlert.name, " должен быть не менее 3", 
                      " Вы ввели недопустимое ", ParMASeriesAlert.ExternVar, " будет использовано  3"));
   int ParMASeriesAlert.MaxPeriod = ArrayRange(dParMA.TEMPBUFFER, 1); 
   if (ParMASeriesAlert.Number == 0)
    if (ParMASeriesAlert.ExternVar > ParMASeriesAlert.MaxPeriod)
          Alert(StringConcatenate("Параметр ", ParMASeriesAlert.name, " должен быть не более ", ParMASeriesAlert.MaxPeriod, 
                  " Вы ввели недопустимое ", ParMASeriesAlert.ExternVar, ". Будет использовано  ", ParMASeriesAlert.MaxPeriod, ".",
                                       " Если необходимо большее значение параметра nParMA.period, измените вторые измерения буферов",
                                                                            " dParMA.TempBuffer и dParMA.TEMPBUFFER функции ParMASeries"));       
 }
//--+ -------------------------------------------------------------------------------------------+

// перевод сделан Николаем Косициным 01.12.2006  
//+X================================================================X+
//|                                     ParMA_ErrDescr_RUS(MQL4).mqh |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+X================================================================X+
string ParMA_ErrDescr(int error_code)
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



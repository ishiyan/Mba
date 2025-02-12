//Version  January 7, 2009 Final
//+X================================================================X+
//|                                                 JurXSeries().mqh |
//|                      JurX code: Copyright © 1998, Jurik Research |
//|                                          http://www.jurikres.com | 
//|    JurXSeries()MQL4 CODE: Copyright © 2009,     Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+
  /*
  
  +-------------------------------------- <<< Функция JurXSeries() >>> -----------------------------------------------+

  +-----------------------------------------+ <<< Назначение >>> +----------------------------------------------------+

  Функция  JurXSeries()  предназначена  для  использования  алгоритма JurX при написании любых индикаторов теханализа и
  экспертов,  для  замены  расчёта  классического  усреднения  на  этот алгоритм. В основе алгоритма этой функции лежит
  ультралинейное  сглаживание,  которое  было  взято  из  индикатора  JRSX. Файл следует положить в папку (директорию):
  MetaTrader\experts\include\  Следует  учесть,  что если nJurX.bar больше, чем nJurX.MaxBar-3*nJurX.Length, то функция
  JurXSeries()  возвращает значение равное нулю! на этом баре! И, следовательно, такое значение не может присутствовать
  в  знаменателе  какой-либо  дроби в расчёте индикатора! Эта версия функции JurXSeries() поддерживает экспертов при её
  использовании  в  пользовательских  индикаторах,  к  которым  обращается  эксперт.  Эта  версия  функции JurXSeries()
  поддерживает экспертов при её использовании в коде индикатора, который полностью помещён в код эксперта с сохранением
  всех  операторов  цикла  и  переменных! При написании индикаторов и экспертов с использованием функции JurXSeries, не
  рекомендуется  переменным  давать  имена  начинающиеся  с  nJurX....  или  dJurX....  Функция JurXSeries() может быть
  использована во внутреннем коде других пользовательских функций, но при этом следует учитывать тот факт, что в каждом
  обращении  к  такой  пользовательской  функции  у  каждого обращения к JurXSeries() должен быть свой уникальный номер
  (nJurX.number). 
  

  +-------------------------------------+ <<< Входные параметры >>> +-------------------------------------------------+

  nJurX.number - порядковый номер обращения к функции JurX.Series(). (0, 1, 2, 3 и.т.д....)
  nJurX.din -    параметр, позволяющий изменять параметры nJurX.Length на каждом баре. 0 - запрет изменения параметров, 
                 любое другое значение - разрешение.
  nJurX.MaxBar - максимальное  значение,  которое  может  принимать  номер  рассчитываемого  бара(bar).   Обычно  равно 
                 Bars-1-period; Где Пример "period" - это количество баров, на которых исходная величина   dJurX.series 
                 не рассчитывается;
  nJurX.limit -  количество ещё не подсчитанных  баров плюс  один  и  ли  номер последнего непосчитанного бара,  Обычно 
                 равно Bars-IndicatorCounted()-1;
  nJurX.Length - глубина сглаживания
  dJurX.series - входной  параметр, по которому производится расчёт функции JurXSeries();
  nJurX.bar -    номер рассчитываемого  бара,  параметр должен  изменяться оператором цикла от максимального значения к 
                 нулевому.   Причём его максимальное значение всегда должно равняться значению параметра nJurX.limit!!!

  +------------------------------------+ <<< Выходные параметры >>> +-------------------------------------------------+

  JurXSeries() - значение функции dJurX.  При  значениях  nJurX.bar  больше  чем   nJurX.MaxBar-nJurX.Length    функция 
                 JurXSeries() всегда возвращает ноль!!!
  nJurX.reset -  параметр, возвращающий по ссылке значение,  отличенное от 0 , если произошла ошибка в расчёте функции,
                 0, если расчёт прошёл нормально. Этот параметр может быть только переменной, но не значением!!!

  +-----------------------------------+ <<< Инициализация функции >>> +-----------------------------------------------+

  Перед обращениями к функции JurXSeries(), когда количество уже подсчитанных баров равно 0, (а ещё лучше это сделать в
  блоке  инициализации  пользовательского  индикатора  или  эксперта)  следует  изменить  размеры  внутренних  буферных
  переменных   функции,   для  этого  необходимо  обратиться  к  функции  JurXSeries()  через  вспомогательную  функцию
  JurXSeriesResize()   со   следующими   параметрами:  JurXSeriesResize(nJurX.number+1);  необходимо  сделать  параметр
  nJurX.number(MaxJurX.number)  равным  количеству  обращений  к  функции  JurXSeries,  то  есть на единицу больше, чем
  максимальный nJurX.number. 
  
  +--------------------------------------+ <<< Индикация ошибок >>> +-------------------------------------------------+
  
  При отладке индикаторов и экспертов их коды могут содержать ошибки, для выяснения причин которых следует смотреть лог
  файл.  Все  ошибки  функция JurXSeries() пишет в лог файл в папке \MetaTrader\EXPERTS\LOGS\. Если, перед обращением к
  функции  JurXSeries()  в коде, который предшествовал функции, возникла MQL4 ошибка, то функция запишет в лог файл код
  ошибки  и содержание ошибки. Если при выполнении функции JurXSeries() в алгоритме JurXSeries() произошла MQL4 ошибка,
  то  функция  также  запишет  в  лог  файл код ошибки и содержание ошибки. При неправильном задании номера обращения к
  функции  JurXSeries()  nJurX.number  или неверном определении размера буферных переменных nJurXResize.Size в лог файл
  будет записаны сообщения о неверном определении этих параметров. Также в лог файл пишется информация при неправильном
  определении  параметра  nJurX.limit.  Если  при  выполнении функции инициализации init() произошёл сбой при изменении
  размеров  буферных  переменных  функции  JurXSeries(),  то функция JurXSeriesResize() запишет в лог файл информацию о
  неудачном  изменении  размеров  буферных переменных. Если при обращении к функции JurXSeries() через внешний оператор
  цикла  была  нарушена правильная последовательность изменения параметра nJurX.bar, то в лог файл будет записана и эта
  информация. Следует учесть, что некоторые ошибки программного кода будут порождать дальнейшие ошибки в его исполнении
  и  поэтому,  если  функция  JurXSeries()  пишет  в лог файл сразу несколько ошибок, то устранять их следует в порядке
  времени  возникновения.  В правильно написанном индикаторе функция JurXSeries() может делать записи в лог файл только
  при  нарушениях  работы операционной системы. Исключение составляет запись изменения размеров буферных переменных при
  перезагрузке индикатора или эксперта, которая происходит при каждом вызове функции init(). 
  
  +---------------------------------+ <<< Пример обращения к функции >>> +--------------------------------------------+


//----+ определение функций JurXSeries()
#include <JurXSeries.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE); 
//---- 1 индикаторный буффер использован для счёта (без этого пересчёта функция JurXSeries() свой расчёт производить не будет!!!)
SetIndexBuffer(0,Ind_Buffer);
//----+ Изменение размеров буфферных переменных функции JurXSeries, nJurX.number=1(Одно обращение к функции JurXSeries)
if(JurXSeriesResize(1)==0)return(-1);
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
  //----+ Обращение к функции JurXSeries()за номером 0 для расчёта буфера Ind_Buffer[], 
  //параметры nJurX.Phase и nJurX.Length не меняются на каждом баре (nJurX.din=0)
  double Resalt=JurXSeries(0,0,MaxBar,limit,Length,Series,bar,reset);
  if (reset!=0)return(-1);
  Ind_Buffer[bar]=Resalt;
 }
return(0);
}
//----+ 

*/
//+X================================================================X+
//|  JurXSeries() function                                           |
//+X================================================================X+    

//----++ <<< Введение и инициализация переменных >>> +-------------------+
double dJurX.f1[1], dJurX.f2[1], dJurX.f3[1], dJurX.f4[1], dJurX.f5[1];
double dJurX.f6[1], dJurX.Kg[1], dJurX.Hg[1], dJurX.F1[1], dJurX.F2[1];
double dJurX.F3[1], dJurX.F4[1], dJurX.F5[1], dJurX.F6[1];
int    nJurX.w [1], nJurX.TIME[1], nJurX.Error, nJurX.Tnew, nJurX.Told;
double dJurX.VEL1, dJurX.VEL2, dJurX.JurX, nJurX.Resize;
//----++ +---------------------------------------------------------------+
//----++ <<< Объявление функции JurXSeries() >>> +-------------------------+
double JurXSeries
 (
  int nJurX.number,int    nJurX.din,    int nJurX.MaxBar, int  nJurX.limit,
  int nJurX.Length,double dJurX.series, int nJurX.bar,    int& nJurX.reset
 )
//----++-------------------------------------------------------------------+
{
nJurX.reset = 1;
//=====+ <<< Проверки на ошибки >>> --------------------------------------------------------------------+
if (nJurX.bar == nJurX.limit)
 {
  //----++ проверка на инициализацию функции JurXSeries()
  if(nJurX.Resize < 1)
   {
    Print(StringConcatenate("JurXSeries number = ",nJurX.number,
         ". Не было сделано изменение размеров буфферных переменных функцией JurXSeriesResize()"));
    if(nJurX.Resize == 0)
        Print(StringConcatenate("JurXSeries number = ",nJurX.number,
                ". Следует дописать обращение к функции JurXSeriesResize() в блок инициализации"));
         
    return(0.0);
   }
  //----++ проверка на ошибку в исполнении программного кода, предшествовавшего функции JurXSeries()
  nJurX.Error = GetLastError();
  if(nJurX.Error > 4000)
   {
      Print(StringConcatenate("JurXSeries number = ",nJurX.number,
            ". В коде, предшествующем обращению к функции JurXSeries() number = ",
                                                                      nJurX.number," ошибка!!! "));
      Print(StringConcatenate("JurXSeries number = ",nJurX.number,". ", JurX_ErrDescr(nJurX.Error))); 
   } 

  //----++ проверка на ошибку в задании переменных nJurX.number и nJurXResize.Size
  if (ArraySize(dJurX.f1) < nJurX.number) 
   {
    Print(StringConcatenate("JurXSeries number = ",nJurX.number,
                ". Ошибка!!! Неправильно задано значение переменной nJurX.number функции JurXSeries()"));
    Print(StringConcatenate("JurXSeries number = ",nJurX.number,
           ". Или неправильно задано значение  переменной nJurXResize.Size функции JurXSeriesResize()"));
    return(0.0);
   }
 }
//----++ +-----------------------------------------------------------------------------------------------+ 
 
if (nJurX.bar > nJurX.MaxBar){nJurX.reset = 0; return(0.0);}
if (nJurX.bar == nJurX.MaxBar || nJurX.din != 0)
 {
  //----++ <<< Расчёт коэффициентов  >>> +------------------+
  if (nJurX.Length <1  ) nJurX.Length = 1;
  if (nJurX.Length >= 6) 
             nJurX.w[nJurX.number] = nJurX.Length - 1; 
  else nJurX.w[nJurX.number] = 5; 
  dJurX.Kg[nJurX.number] = 3 / (nJurX.Length + 2.0); 
  dJurX.Hg[nJurX.number] = 1.0 - dJurX.Kg[nJurX.number];
  //----++--------------------------------------------------+
 }
//----++ проверка на ошибку в последовательности изменения переменной nJurX.bar
if (nJurX.limit >= nJurX.MaxBar)
 if (nJurX.bar == 0)
  if (nJurX.din == 0)
   if (nJurX.MaxBar > 3 * nJurX.Length)
    if (nJurX.TIME[nJurX.number] == 0)
              Print(StringConcatenate("JurXSeries number = ",nJurX.number,
                              ". Ошибка!!! Нарушена правильная последовательность", 
                                 " изменения параметра nJurX.bar внешним оператором цикла!!!"));  
//----++      
if (nJurX.bar == nJurX.limit)
 if (nJurX.limit < nJurX.MaxBar)          
  {
  //----+ <<< Восстановление значений переменных >>> +-------------------------------------------------+
   nJurX.Tnew = Time[nJurX.limit + 1];
   nJurX.Told = nJurX.TIME[nJurX.number];
   //--+
   if (nJurX.Tnew == nJurX.Told)
     {
      dJurX.f1[nJurX.number] = dJurX.F1[nJurX.number]; dJurX.f2[nJurX.number] = dJurX.F2[nJurX.number]; 
      dJurX.f3[nJurX.number] = dJurX.F3[nJurX.number]; dJurX.f4[nJurX.number] = dJurX.F4[nJurX.number]; 
      dJurX.f5[nJurX.number] = dJurX.F5[nJurX.number]; dJurX.f6[nJurX.number] = dJurX.F6[nJurX.number];
     }
   //--+ проверка на ошибки
   if(nJurX.Tnew != nJurX.Told)
     {
      nJurX.reset = -1;
      //--+ индикация ошибки в расчёте входного параметра JurX.limit функции JurX.Series()
      if (nJurX.Tnew > nJurX.Told)
       {
        Print(StringConcatenate("JurXSeries number = ",nJurX.number,
               ". Ошибка!!! Параметр nJurX.limit функции JurX.Series() меньше чем необходимо"));
       }
      else 
       { 
        int nJurX.LimitERROR=nJurX.limit+1-iBarShift(NULL,0,nJurX.Told,TRUE);
        Print(StringConcatenate("JurX.Series number = ",nJurX.number,
             ". Ошибка!!! Параметр nJurX.limit функции JurX.Series() больше чем необходимо на ",
                                                                                 nJurX.LimitERROR));
       }
      //--+ 
      return(0);
     }
  //----+------------------------------------------------------------------------------------------------+
  }
//+--- Сохранение значений переменных +
if (nJurX.bar == 1)
 if (nJurX.limit != 1)
  {
   nJurX.TIME[nJurX.number] = Time[2];
   dJurX.F1[nJurX.number] = dJurX.f1[nJurX.number]; 
   dJurX.F2[nJurX.number] = dJurX.f2[nJurX.number]; 
   dJurX.F3[nJurX.number] = dJurX.f3[nJurX.number]; 
   dJurX.F4[nJurX.number] = dJurX.f4[nJurX.number]; 
   dJurX.F5[nJurX.number] = dJurX.f5[nJurX.number]; 
   dJurX.F6[nJurX.number] = dJurX.f6[nJurX.number];
  }
//+---+

//---- <<< вычисление dJurX.JurX >>> ----------------------------------------------------------------------------------------+
dJurX.f1[nJurX.number] = dJurX.Hg[nJurX.number] * dJurX.f1[nJurX.number] + dJurX.Kg[nJurX.number] * dJurX.series;
dJurX.f2[nJurX.number] = dJurX.Kg[nJurX.number] * dJurX.f1[nJurX.number] + dJurX.Hg[nJurX.number] * dJurX.f2[nJurX.number];
dJurX.VEL1             =        1.5             * dJurX.f1[nJurX.number] -        0.5             * dJurX.f2[nJurX.number];
dJurX.f3[nJurX.number] = dJurX.Hg[nJurX.number] * dJurX.f3[nJurX.number] + dJurX.Kg[nJurX.number] * dJurX.VEL1;
dJurX.f4[nJurX.number] = dJurX.Kg[nJurX.number] * dJurX.f3[nJurX.number] + dJurX.Hg[nJurX.number] * dJurX.f4[nJurX.number];
dJurX.VEL2             =        1.5             * dJurX.f3[nJurX.number] -        0.5             * dJurX.f4[nJurX.number];
dJurX.f5[nJurX.number] = dJurX.Hg[nJurX.number] * dJurX.f5[nJurX.number] + dJurX.Kg[nJurX.number] * dJurX.VEL2;
dJurX.f6[nJurX.number] = dJurX.Kg[nJurX.number] * dJurX.f5[nJurX.number] + dJurX.Hg[nJurX.number] * dJurX.f6[nJurX.number];
dJurX.JurX              =       1.5             * dJurX.f5[nJurX.number] -        0.5             * dJurX.f6[nJurX.number];
//---- ----------------------------------------------------------------------------------------------------------------------+

//----++ проверка на ошибку в исполнении программного кода функции JurXSeries()
nJurX.Error = GetLastError();
if(nJurX.Error > 4000)
  {
    Print(StringConcatenate("JurXSeries number = ",nJurX.number,
                                    ". При исполнении функции JurXSeries() произошла ошибка!!!"));
    Print(StringConcatenate("JurXSeries number = ",nJurX.number,". ",JurX_ErrDescr(nJurX.Error)));  
    return(0.0);
  }
nJurX.reset = 0;
if (nJurX.bar < nJurX.MaxBar - nJurX.Length)
                                   return(dJurX.JurX);
else return(0.0);

//---- завершение вычислений значения функции JurX.Series -------+ 
}
//+X=============================================================================================X+
// JurXSeriesResize - Это дополнительная функция для изменения размеров буфферных переменных      | 
// функции JurXSeries. Пример обращения: JurXSeriesResize(5); где 5 - это количество обращений к  | 
// JurXSeries()в тексте индикатора. Это обращение к функции  JurXSeriesResize следует поместить   |
// в блок инициализации пользовательского индикатора или эксперта                                 |
//+X=============================================================================================X+
int JurXSeriesResize(int nJurXResize.Size)
 {
//----+
  if(nJurXResize.Size < 1)
   {
    Print("JurXSeriesResize: Ошибка!!! Параметр nJurXResize.Size не может быть меньше единицы!!!"); 
    nJurX.Resize = -1; 
    return(0);
   }  
  int nJurXResize.reset,nJurXResize.cycle;
  //--+
  while(nJurXResize.cycle == 0)
   {
    //----++ <<< изменение размеров буфферных переменных >>>  +---------------------+
    if(ArrayResize(dJurX.f1,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.f2,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.f3,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.f4,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.f5,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.f6,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.Kg,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.Hg,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F1,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F2,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F3,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F4,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F5,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F6,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(nJurX.w,    nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(nJurX.TIME, nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    //----++------------------------------------------------------------------------+
    nJurXResize.cycle = 1;
   }
  //--+
  if(nJurXResize.reset == -1)
   {
    Print(StringConcatenate("JurXSeriesResize: Ошибка!!!",
                    " Не удалось изменить размеры буфферных переменных функции JurXSeries()."));
    int nJurXResize.Error = GetLastError();
    if(nJurXResize.Error > 4000)
                Print(StringConcatenate("JurXSeriesResize: ",JurX_ErrDescr(nJurXResize.Error)));             
    nJurX.Resize = -2;
    return(0);
   }
  else  
   {
    Print(StringConcatenate("JurXSeriesResize: JurXSeries Size = ",nJurXResize.Size));                                                                                                               
    nJurX.Resize = nJurXResize.Size;
    return(nJurXResize.Size);
   }  
//----+
 }

/*
//+X==================================================================================================X+
JurXSeriesAlert - Это дополнительная функция для индикации ошибки в задании внешних переменных         |
функции JurSeries.                                                                                     |
  -------------------------- входные параметры  --------------------------                             |
JurXSeriesAlert.Number                                                                                 |
JurXSeriesAlert.ExternVar значение внешней переменной для параметра nJurX.Phase                        |
JurXSeriesAlert.name имя внешней переменной для параметра nJurX.Length, если JurXSeriesAlert.Number=0. |                                                  
  -------------------------- Пример использования  -----------------------                             |
  int init()                                                                                           |
//----                                                                                                 |
Здесь какая-то инициализация переменных и буферов                                                      |
                                                                                                       |
//---- установка алертов на недопустимые значения внешних переменных                                   |                                                           
JurXSeriesAlert(0,"Length1",Length1);                                                                  |
JurXSeriesAlert(0,"Length2",Length2);                                                                  |
//---- завершение инициализации                                                                        |
return(0);                                                                                             |
}                                                                                                      |
//+X==================================================================================================X+
*/
void JurXSeriesAlert
 (
  int JurXSeriesAlert.Number, string JurXSeriesAlert.name, int JurXSeriesAlert.ExternVar
 )
 {
  //---- установка алертов на недопустимые значения входных параметров ==========================+ 
   if(JurXSeriesAlert.Number == 0)
     if(JurXSeriesAlert.ExternVar < 1)
          {Alert(StringConcatenate("Параметр ",JurXSeriesAlert.name," должен быть не менее 1", 
                  " Вы ввели недопустимое ",JurXSeriesAlert.ExternVar," будет использовано  1"));}
 }

// перевод сделан Николаем Косициным 01.12.2006  
//+X================================================================X+
//|                                      JurX_ErrDescr_RUS(MQL4).mqh |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+X================================================================X+
string JurX_ErrDescr(int error_code)
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



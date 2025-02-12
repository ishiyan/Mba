//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                   JurXSeries.mqh |
//|                JurX code: Copyright © 2005, Weld, Jurik Research |
//|                                          http://weld.torguem.net |
//|          MQL4+JurXSeries: Copyright © 2006,     Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
  /*
  SSSSSS <<< Функция JurXSeries >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS

  ----------------------------- Назначение -------------------------------

  Функция JurXSeries предназначена для использования алгоритма JurX при написании любых индикаторов теханализа, для замены расчёта
  классического усреднения на этот алгоритм.
  Файл следует положить в папку (директорию): MetaTrader\experts\include\

  -------------------------- input parameters ----------------------------

  nJurX.number - порядковый номер обращения к функции JurX.Series. (0, 1, 2, 3 и.т.д....)
  nJurX.din - параметр, позволяющий изменять параметры nJurX.Length на каждом баре. 0 - запрет изменения параметров, любое другое значение - разрешение.
  nJurX.numberMaxBar - Максимальное значение, которое может принимать номер расчитываемого бара(bar). Обычно равно Bars-1;
  nJurX.limit - Количество ещё не подсчитанных баров плюс один или номер поседнего неподсчитанного бара, Обычно равно: Bars-IndicatorCounted()-1;
  nJurX.Length - глубина сглаживания
  dJurX.series - Входной  параметр, по которому производится расчёт функции JurX.Series;
  nJurX.bar - номер расчитываемого бара, параметр должен изменяться оператором цикла от максимального значения к нулевому.
  nJurX.reset - параметр, при значении которого равным -1 происходит введение и инициализация внутренних переменных функции JurX.Series.

  ------------------------- output parameters ----------------------------

  JurXSeries() - значение функции dJurX..
  nJurX.reset - параметр, возвращающий по ссылке значение, отличинное от 0 , если произошла ошибка в расчёте функции,
   0, если расчёт прошёл нормально. Этот параметр может быть только переменной, но не значением!!!

  --------------------- Механизм обращения к функции ---------------------

  Перед обращениями к функции JurXSeries , когда количество уже подсчитанных баров равно 0, следует ввести и инициализировать
  внутренние переменные функции, для этого необходимо обратиться к функции со следующими параметрами:
  reset=-1; JurXSeries(MaxJurX.number+1,0,0,0,0,0,0,reset); или JurX.SeriesReset(MaxJurX.number+1);
  необходимо сделать параметр nJurX.number(MaxJurX.number) равным количеству обращений к функции JurXSeries,  то есть на единицу больше, чем
  максимальный nJurX.number. А параметру nJurX.reset присвоить через переменную reset значение -1(В саму функцию подставлять -1 нельзя!
  Только через параметр). Остальным параметрам присвоить 0. При написании индикаторов и экспертов с использованием функции JurXSeries, не
  рекомендуется переменным давать имена начинающиеся с nJurX.... или dJurX....

  --------------------- Пример обращения к функции -----------------------
int start()
{
int reset,counted_bars=IndicatorCounted();
//----+ check for possible errors
if (counted_bars<0) return (-1);
int limit=Bars-counted_bars-1;
//----+ введение и инициализация внутренних переменных функции JurX.Series (одно обращение к функции, параметры nJurX.Phase и nJurX.Length не меняются )
if (limit==Bars-1){JurX.SeriesReset(1);
//----+обращение к функции JurXSeries для расчёта буфера Ind_Buffer[]
for(int x=limit;x>=0;x--)
 (
  reset=1;
  Series=Close[x];
  Ind_Buffer[x]=JurXSeries(0,0,Bars-1,limit,Length,Series,x,reset);
  if (reset!=0)return(-1);
 }
return(0);
}
//----+ определение функции JurXSeries
#include <JurXSeries.mqh>

  */
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//+++++++++++++++++++++++++++++++++++++++++++++++++++++ <<< JurX.Series >>> +++++++++++++++++++++++++++++++++++++++++++++==+++++++++++|
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+

double JurXSeries
(int nJurX.number,int nJurX.din,int nJurX.numberMaxBar,int nJurX.limit,int nJurX.Length,double dJurX.series,int nJurX.bar,int& nJurX.reset)
{
if(nJurX.reset==-1)
{
//----++ <<< Введение и инициализация переменных >>> +SSSSSSSSSSSSSSSSSSSSSSSSSS+
static double dJurX.f1[1],dJurX.f2[1],dJurX.f3[1],dJurX.f4[1],dJurX.f5[1];
static double dJurX.f6[1],dJurX.Kg[1],dJurX.Hg[1],dJurX.F1[1],dJurX.F2[1];
static double dJurX.F3[1],dJurX.F4[1],dJurX.F5[1],dJurX.F6[1];
static double dJurX.VEL1,dJurX.VEL2,dJurX.OUT,dJurX.INPUT;
static int    nJurX.w [1],nJurX.T1[1],nJurX.T2[1];
//--+
if(ArrayResize(dJurX.f1,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.f2,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.f3,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.f4,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.f5,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.f6,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.Kg,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.Hg,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.F1,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.F2,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.F3,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.F4,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.F5,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(dJurX.F6,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(nJurX.T1,  nJurX.number)==0){nJurX.reset=1;return(0);}
if(ArrayResize(nJurX.T2,  nJurX.number)==0){nJurX.reset=1;return(0);}
//--+
ArrayInitialize(dJurX.f1,0.0);ArrayInitialize(dJurX.f2,0.0);
ArrayInitialize(dJurX.f3,0.0);ArrayInitialize(dJurX.f4,0.0);
ArrayInitialize(dJurX.f5,0.0);ArrayInitialize(dJurX.f6,0.0);
ArrayInitialize(dJurX.F1,0.0);ArrayInitialize(dJurX.F2,0.0);
ArrayInitialize(dJurX.F3,0.0);ArrayInitialize(dJurX.F4,0.0);
ArrayInitialize(dJurX.F5,0.0);ArrayInitialize(dJurX.F6,0.0);
ArrayInitialize(dJurX.Kg,0.0);ArrayInitialize(dJurX.Hg,0.0);
ArrayInitialize(nJurX.T1,0.0);ArrayInitialize(nJurX.T2,0.0);
//--+
nJurX.reset=0;return(1.0);
//----++SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
}

nJurX.reset=1;

if (nJurX.bar>nJurX.numberMaxBar){nJurX.reset=0;return(0.0);}
if((nJurX.bar==nJurX.numberMaxBar)||(nJurX.din!=0))
{
//----++ <<< Расчёт коэффициентов  >>> +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
if (nJurX.Length<1 ) nJurX.Length=1;
if (nJurX.Length>=6) nJurX.w[nJurX.number]=nJurX.Length-1; else nJurX.w[nJurX.number]=5; 
dJurX.Kg[nJurX.number]=3/(nJurX.Length+2.0); dJurX.Hg[nJurX.number]=1.0-dJurX.Kg[nJurX.number];
//----++SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
}

if((nJurX.bar==nJurX.limit)&&(nJurX.limit<nJurX.numberMaxBar))          
{
//----+ <<< Восстановление значений переменных >>> +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int nJurX.Tnew=Time[nJurX.limit+1];
//--+ проверка на ошибки
if(nJurX.Tnew!=nJurX.T2[nJurX.number])
{
      nJurX.reset=-1;
      //--+ индикация ошибки в расчёте входного параметра JurX.limit функции JurX.Series()
     if (nJurX.Tnew>nJurX.T2[nJurX.number])
       {
       Print("JurX.Series number ="+nJurX.number+". ERROR01");
       Print("JurX.Series number ="+nJurX.number+". Параметр nJMAlimit функции JurX.Series меньше чем необходимо");
       }
    else 
       { 
       int nJurX.LimitERROR=nJurX.limit+1-iBarShift(NULL,0,nJurX.T2[nJurX.number],TRUE);
       Print("JurX.Series number ="+nJurX.number+". ERROR02");
       Print("JurX.Series number ="+nJurX.number+". Параметр nJurX.limit функции JurX.Series больше чем необходимо на "+nJurX.LimitERROR+"");
       }
  //--+ 
  return(0);
  }
//--+
dJurX.f1[nJurX.number]=dJurX.F1[nJurX.number]; dJurX.f2[nJurX.number]=dJurX.F2[nJurX.number]; 
dJurX.f3[nJurX.number]=dJurX.F3[nJurX.number]; dJurX.f4[nJurX.number]=dJurX.F4[nJurX.number]; 
dJurX.f5[nJurX.number]=dJurX.F5[nJurX.number]; dJurX.f6[nJurX.number]=dJurX.F6[nJurX.number];
//----+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
}

dJurX.INPUT=dJurX.series;
//---- вычисление dJurX.OUT -------------------------------------------------------------------------------------+
dJurX.f1[nJurX.number] = dJurX.Hg[nJurX.number] * dJurX.f1[nJurX.number] + dJurX.Kg[nJurX.number] * dJurX.INPUT;
dJurX.f2[nJurX.number] = dJurX.Kg[nJurX.number] * dJurX.f1[nJurX.number] + dJurX.Hg[nJurX.number] * dJurX.f2[nJurX.number];
dJurX.VEL1             =        1.5             * dJurX.f1[nJurX.number] -        0.5             * dJurX.f2[nJurX.number];
dJurX.f3[nJurX.number] = dJurX.Hg[nJurX.number] * dJurX.f3[nJurX.number] + dJurX.Kg[nJurX.number] * dJurX.VEL1;
dJurX.f4[nJurX.number] = dJurX.Kg[nJurX.number] * dJurX.f3[nJurX.number] + dJurX.Hg[nJurX.number] * dJurX.f4[nJurX.number];
dJurX.VEL2             =        1.5             * dJurX.f3[nJurX.number] -        0.5             * dJurX.f4[nJurX.number];
dJurX.f5[nJurX.number] = dJurX.Hg[nJurX.number] * dJurX.f5[nJurX.number] + dJurX.Kg[nJurX.number] * dJurX.VEL2;
dJurX.f6[nJurX.number] = dJurX.Kg[nJurX.number] * dJurX.f5[nJurX.number] + dJurX.Hg[nJurX.number] * dJurX.f6[nJurX.number];
dJurX.OUT              =        1.5             * dJurX.f5[nJurX.number] -        0.5             * dJurX.f6[nJurX.number];
//---- ---------------------------------------------------------------------------------------------------------+

//+--- Сохранение значений переменных +SSSSSSSSSSSS+
if (nJurX.bar==2)
{
nJurX.T2[nJurX.number]=Time[2];
nJurX.T1[nJurX.number]=Time[1];
dJurX.F1[nJurX.number]=dJurX.f1[nJurX.number]; 
dJurX.F2[nJurX.number]=dJurX.f2[nJurX.number]; 
dJurX.F3[nJurX.number]=dJurX.f3[nJurX.number]; 
dJurX.F4[nJurX.number]=dJurX.f4[nJurX.number]; 
dJurX.F5[nJurX.number]=dJurX.f5[nJurX.number]; 
dJurX.F6[nJurX.number]=dJurX.f6[nJurX.number];
}
//+---+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+

nJurX.reset=0;
if (nJurX.bar<nJurX.numberMaxBar)return(dJurX.OUT);else return(0.0);
//---- завершение вычислений значения функции JurX.Series 
}

//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
// JurXSeriesReset - Это дополнительная функция для инициализации внутренних переменных функции   | 
// JurXSeries. Пример обращения: if (limit==Bars-1)JurX.SeriesReset(5); где 5 - это количество    | 
// обращений к JurX.Series в тексте индикатора                                                    |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
void JurXSeriesReset(int nJurX.Reset.Number)
 {
  int nJurX.Reset.reset=-1;
  int nJurX.Reset.set=JurXSeries(nJurX.Reset.Number,0,0,0,0,0,0,nJurX.Reset.reset);
  if((nJurX.Reset.set==1)&&(nJurX.Reset.reset==0))Print("JurX.SeriesReset is OK!!!");
  else Print("JurX.SeriesReset is ERROR!!!");
 }
//--+ --------------------------------------------------------------------------------------------+


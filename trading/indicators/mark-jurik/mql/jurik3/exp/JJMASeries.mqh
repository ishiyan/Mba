//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                              JJMASeries.Exp1.mqh |
//|                 JMA code: Copyright © 2005, Weld, Jurik Research |
//|                                          http://weld.torguem.net |
//|                MQL4+JJMA: Copyright © 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
  /*
  SSSSSS <<< Функция JJMASeries.Exp1 >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS

  ----------------------------- Назначение -------------------------------

  Функция JJMASeries.Exp1 предназначена для использования алгоритма JMA при написании экспертов, работающих с пользовательскими 
  индикаторами,  сделанными на  основе  функции JJMASeries. JJMASeries.EXP1 - это полный аналог функции JJMASeries, позволяющий 
  эксперту корректно работать  с пользовательским индикатором,  в  котором функция  JJMASeries  зенена  на JJMASeries.Exp1. Для 
  использования   этой   функции    следует   заменить  в    конце   текста   индикатора   строку     #include <JJMASeries.mqh>  
  на  #include <JJMASeries.Exp1.mqh> .   Функция не  работает,  если   параметр   nJMA.limit   принимает значение, равное нулю! 
  Все индикаторы, сделанные  мною  для  JJMASeries,  выполнены  с  учётом  этого  ограничения.    Файл следует положить в папку 
  (директорию): MetaTrader\experts\include\

  -------------------------- входные параметры  --------------------------

  nJMA.number - порядковый номер обращения к функции JJMASeries. (0, 1, 2, 3 и.т.д....)
  nJMA.dinJ - параметр, позволяющий изменять параметры nJMA.Length и nJMA.Phase на каждом баре. 0 - запрет изменения параметров, любое другое значение - разрешение.
  nJMA.MaxBar - Максимальное значение, которое может принимать номер расчитываемого бара(bar). Обычно равно Bars-1;
  nJMA.limit - Количество ещё не подсчитанных баров плюс один или номер поседнего неподсчитанного бара, Обычно равно: Bars-IndicatorCounted()-1;
  nJMA.Length - глубина сглаживания
  nJMA.Phase  - параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
  dJMA.series - Входной  параметр, по которому производится расчёт функции JJMASeries;
  nJMA.bar - номер расчитываемого бара, параметр должен изменяться оператором цикла от максимального значения к нулевому.
  nJMA.reset - параметр, при значении которого равным -1 происходит введение и инициализация внутренних переменных функции JJMASeries.

  ------------------------- выходные параметры ---------------------------

  JJMASeries() - значение функции dJMA.JMA
  nJMA.reset - параметр, возвращающий по ссылке значение, отличинное от 0 , если произошла ошибка в расчёте функции,
   0, если расчёт прошёл нормально. Этот параметр может быть только переменной, но не значением!!!

  --------------------- Механизм обращения к функции ---------------------

  Перед обращениями к функции JJMASeries , когда количество уже подсчитанных баров равно 0, следует ввести и инициализировать
  внутренние переменные функции, для этого необходимо обратиться к функции со следующими параметрами:
  reset=-1; JJMA(0,MaxJMA.number+1,0,0,0,0,0,0,reset);
  необходимо сделать параметр nJMA.number(MaxJMA.number) равным количеству обращений к функции JJMASeries,  то есть на единицу больше, чем
  максимальный nJMA.number. А параметру nJMA.reset присвоить через переменную reset значение -1(В саму функцию подставлять -1 нельзя!
  Только через параметр). Остальным параметрам присвоить 0. При написании индикаторов и экспертов с использованием функции JJMASeries, не
  рекомендуется переменным давать имена начинающиеся с nJMA.... или dJMA....

  --------------------- Пример обращения к функции -----------------------
//----+ Введение целых переменных и получение уже подсчитанных баров
int bar,MaxBar,limit,counted_bars=IndicatorCounted(); 
//---- проверка на возможные ошибки
if (counted_bars<0)return(-1);
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
int limit=Bars-counted_bars-1;
MaxBar=Bars-1;
//----+ Введение и инициализация внутренних переменных функции JJMASeries.Exp1, nJMA.number=1(Одно обращение к функции JJMASeries)
if(limit==MaxBar)JJMASeriesReset(1);
//----+ Обращение к функции JJMASeries за номером 0 для расчёта буфера Ind_Buffer[], параметры nJMA.Phase и nJMA.Length не меняются на каждом баре (nJMA.din=0)
for(bar=limit;bar>=0;bar--)
 (
  Series=Close[bar];
  Resalt=JJMASeries(0,0,Bars-1,limit,Phase,Length,Series,bar,reset);
  if (reset!=0)return(-1);
  Ind_Buffer[bar]=Resalt;
 }
return(0);
}
//----+ определение функции JJMASeries
#include <JJMASeries.Exp1.mqh>

  */
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//++++++++++++++++++++++++++++++++++++++++++++++++ <<< JJMASeries.Exp1 >>> ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+

double JJMASeries
(int nJMA.number,int nJMA.din,int nJMA.MaxBar,int nJMA.limit,int nJMA.Phase,int nJMA.Length,double dJMA.series,int nJMA.bar,int& nJMA.reset)
{
if(nJMA.reset==-1)
{
//----++ <<< Введение и инициализация переменных >>> +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
static double dJMA.f18[1],dJMA.f38[1],dJMA.fA0,dJMA.fA8[1],dJMA.fC0[1],dJMA.fC8[1],dJMA.s8[1],dJMA.s18[1],dJMA.vv,dJMA.v1[1],dJMA.v2[1];
static double dJMA.v3[1],dJMA.v4,dJMA.f90[1],dJMA.f78[1],dJMA.f88[1],dJMA.f98[1],dJMA.JMA[1],dJMA.list[1][128],dJMA.ring1[1][128];
static double dJMA.ring2[1][11],dJMA.buffer[1][62],dJMA.mem1[1][8],dJMA.mem3[1][128],dJMA.mem4[1][128],dJMA.mem5[1][11],dJMA.mem8[1][128];
static double dJMA.Kg[1],dJMA.Pf[1],dJMA.s20,dJMA.s10,dJMA.fB0,dJMA.fD0,dJMA.f8,dJMA.f60,dJMA.f20,dJMA.f28,dJMA.f30,dJMA.f40,dJMA.f48;
static double dJMA.f58,dJMA.f68,dJMA.f70,dJMA.MOM1[1][9],dJMA.MOM4[1][128],dJMA.MOM5[1][11],dJMA.MOM8[1][128];
static int    nJMA.s28[1],nJMA.s30[1],nJMA.s38[1],nJMA.s40[1],nJMA.v5,nJMA.v6,nJMA.fE0,nJMA.fD8,nJMA.fE8,nJMA.val,nJMA.s48[1];
static int    nJMA.s58,nJMA.s60,nJMA.s68,nJMA.f0[1],nJMA.aa,nJMA.size,nJMA.s50[1],nJMA.s70[1],nJMA.LP2[1],nJMA.LP1[1];
static int    nJMA.ii,nJMA.jj,nJMA.n,nJMA.m,nJMA.mem2[1][9],nJMA.MOM2[1][9];              
//--+
nJMA.m=nJMA.number;
if(ArrayResize(dJMA.list,   nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.ring1,  nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.ring2,  nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.buffer, nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.mem1,   nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(nJMA.mem2,   nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.MOM1,   nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(nJMA.MOM2,   nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.mem3,   nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.mem8,   nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.mem4,   nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.mem5,   nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.MOM4,   nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.MOM5,   nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.MOM8,   nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(nJMA.f0,     nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.Kg,     nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.Pf,     nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.f18,    nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.f38,    nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.fA8,    nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.fC0,    nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.fC8,    nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.s8,     nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.s18,    nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.JMA,    nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(nJMA.s50,    nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(nJMA.s70,    nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(nJMA.LP2,    nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(nJMA.LP1,    nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(nJMA.s38,    nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(nJMA.s40,    nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(nJMA.s48,    nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.v1,     nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.v2,     nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.v3,     nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.f90,    nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.f78,    nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(dJMA.f88,    nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(dJMA.f98,    nJMA.m)==0){nJMA.reset=1;return(0);}
if(ArrayResize(nJMA.s28,    nJMA.m)==0){nJMA.reset=1;return(0);}if(ArrayResize(nJMA.s30,    nJMA.m)==0){nJMA.reset=1;return(0);}
//--+
ArrayInitialize(dJMA.list,0.0);ArrayInitialize(dJMA.ring1,0.0);ArrayInitialize(dJMA.ring2,0.0);ArrayInitialize(dJMA.buffer,0.0);
ArrayInitialize(dJMA.mem1,0.0);ArrayInitialize(nJMA.mem2,0   );ArrayInitialize(dJMA.mem3, 0.0);ArrayInitialize(dJMA.mem4,  0.0);
ArrayInitialize(dJMA.mem5,0.0);ArrayInitialize(dJMA.mem8, 0.0);ArrayInitialize(dJMA.MOM1, 0.0);ArrayInitialize(nJMA.MOM2,  0  );
ArrayInitialize(dJMA.MOM4,0.0);ArrayInitialize(dJMA.MOM5, 0.0);ArrayInitialize(dJMA.MOM8, 0.0);ArrayInitialize(nJMA.f0,    1  );
ArrayInitialize(dJMA.Kg,  0.0);ArrayInitialize(dJMA.Pf,   0.0);ArrayInitialize(dJMA.f18,  0.0);ArrayInitialize(dJMA.f38,   0.0);
ArrayInitialize(dJMA.fA8, 0.0);ArrayInitialize(dJMA.fC0,  0.0);ArrayInitialize(dJMA.fC8,  0.0);ArrayInitialize(dJMA.s8,    0.0);
ArrayInitialize(dJMA.s18, 0.0);ArrayInitialize(dJMA.JMA,  0.0);ArrayInitialize(nJMA.s50,  0  );ArrayInitialize(nJMA.s70,   0  );
ArrayInitialize(nJMA.LP2, 0  );ArrayInitialize(nJMA.LP1,  0  );ArrayInitialize(nJMA.s38,  0  );ArrayInitialize(nJMA.s40,   0  );
ArrayInitialize(nJMA.s48, 0  );ArrayInitialize(dJMA.v1,   0  );ArrayInitialize(dJMA.v2,   0  );ArrayInitialize(dJMA.v3,    0  );
ArrayInitialize(dJMA.f90, 0.0);ArrayInitialize(dJMA.f78,  0.0);ArrayInitialize(dJMA.f88,  0.0);ArrayInitialize(dJMA.f98,   0.0);
ArrayInitialize(nJMA.s28, 0  );ArrayInitialize(nJMA.s30,  0  );
//--+
nJMA.reset=0;return(1);
//----++SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
}

nJMA.reset=1;

nJMA.n=nJMA.number;
if (nJMA.bar> nJMA.MaxBar){nJMA.reset=0;return(0.0);}
if((nJMA.bar==nJMA.MaxBar)||(nJMA.din!=0))
{
//----++ <<< Расчёт коэффициентов  >>> +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
double Dr,Ds,Dl;
if(nJMA.Length < 1.0000000002) Dr = 0.0000000001;
else Dr= (nJMA.Length - 1.0) / 2.0;
if((nJMA.Phase >= -100)&&(nJMA.Phase <= 100))dJMA.Pf[nJMA.n] = nJMA.Phase / 100.0 + 1.5;
if (nJMA.Phase > 100) dJMA.Pf[nJMA.n] = 2.5;
if (nJMA.Phase < -100) dJMA.Pf[nJMA.n] = 0.5;
Dr = Dr * 0.9; dJMA.Kg[nJMA.n] = Dr/(Dr + 2.0);
Ds=MathSqrt(Dr);Dl=MathLog(Ds); dJMA.v1[nJMA.n]= Dl;dJMA.v2[nJMA.n] = dJMA.v1[nJMA.n];
if((dJMA.v1[nJMA.n] / MathLog(2.0)) + 2.0 < 0.0) dJMA.v3[nJMA.n]= 0.0;
else dJMA.v3[nJMA.n]=(dJMA.v2[nJMA.n]/MathLog(2.0))+ 2.0;
dJMA.f98[nJMA.n]= dJMA.v3[nJMA.n];
if( dJMA.f98[nJMA.n] >= 2.5 ) dJMA.f88[nJMA.n] = dJMA.f98[nJMA.n] - 2.0;
else dJMA.f88[nJMA.n]= 0.5;
dJMA.f78[nJMA.n]= Ds * dJMA.f98[nJMA.n]; 
dJMA.f90[nJMA.n]= dJMA.f78[nJMA.n] / (dJMA.f78[nJMA.n] + 1.0);
//----++SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
}
//--+
if (nJMA.bar==nJMA.limit)
{
//----+ <<< Восстановление значений переменных >>> +WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW+
  int nJMA.Tnew=Time[nJMA.limit+1];  
  if((nJMA.Tnew==nJMA.MOM2[nJMA.n][01])||(nJMA.bar==nJMA.MaxBar)) 
  { 
//----+ <<< Восстановление значений переменных >>> +ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss+
for(nJMA.ii=127;nJMA.ii>=0;nJMA.ii--)dJMA.list [nJMA.n][nJMA.ii]=dJMA.MOM8[nJMA.n][nJMA.ii];
for(nJMA.ii=127;nJMA.ii>=0;nJMA.ii--)dJMA.ring1[nJMA.n][nJMA.ii]=dJMA.MOM4[nJMA.n][nJMA.ii];
for(nJMA.ii= 10;nJMA.ii>=0;nJMA.ii--)dJMA.ring2[nJMA.n][nJMA.ii]=dJMA.MOM5[nJMA.n][nJMA.ii];
//--+
dJMA.fC0[nJMA.n]=dJMA.MOM1[nJMA.n][00];dJMA.fC8[nJMA.n]=dJMA.MOM1[nJMA.n][01];dJMA.fA8[nJMA.n]=dJMA.MOM1[nJMA.n][02];
dJMA.s8 [nJMA.n]=dJMA.MOM1[nJMA.n][03];dJMA.f18[nJMA.n]=dJMA.MOM1[nJMA.n][04];dJMA.f38[nJMA.n]=dJMA.MOM1[nJMA.n][05];
dJMA.s18[nJMA.n]=dJMA.MOM1[nJMA.n][06];dJMA.JMA[nJMA.n]=dJMA.MOM1[nJMA.n][07];nJMA.s38[nJMA.n]=nJMA.MOM2[nJMA.n][02];
nJMA.s48[nJMA.n]=nJMA.MOM2[nJMA.n][03];nJMA.s50[nJMA.n]=nJMA.MOM2[nJMA.n][04];nJMA.LP1[nJMA.n]=nJMA.MOM2[nJMA.n][05];
nJMA.LP2[nJMA.n]=nJMA.MOM2[nJMA.n][06];nJMA.s40[nJMA.n]=nJMA.MOM2[nJMA.n][07];nJMA.s70[nJMA.n]=nJMA.MOM2[nJMA.n][08];
//----+sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss+
  }
  else
  {
  if((nJMA.Tnew==nJMA.mem2[nJMA.n][01])&&(nJMA.bar!=nJMA.MaxBar))  
  {
//----+ <<< Восстановление значений переменных >>> +ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss+
for(nJMA.ii=127;nJMA.ii>=0;nJMA.ii--)dJMA.list [nJMA.n][nJMA.ii]=dJMA.mem8[nJMA.n][nJMA.ii];
for(nJMA.ii=127;nJMA.ii>=0;nJMA.ii--)dJMA.ring1[nJMA.n][nJMA.ii]=dJMA.mem4[nJMA.n][nJMA.ii];
for(nJMA.ii= 10;nJMA.ii>=0;nJMA.ii--)dJMA.ring2[nJMA.n][nJMA.ii]=dJMA.mem5[nJMA.n][nJMA.ii];
//--+
dJMA.fC0[nJMA.n]=dJMA.mem1[nJMA.n][00];dJMA.fC8[nJMA.n]=dJMA.mem1[nJMA.n][01];dJMA.fA8[nJMA.n]=dJMA.mem1[nJMA.n][02];
dJMA.s8 [nJMA.n]=dJMA.mem1[nJMA.n][03];dJMA.f18[nJMA.n]=dJMA.mem1[nJMA.n][04];dJMA.f38[nJMA.n]=dJMA.mem1[nJMA.n][05];
dJMA.s18[nJMA.n]=dJMA.mem1[nJMA.n][06];dJMA.JMA[nJMA.n]=dJMA.mem1[nJMA.n][07];nJMA.s38[nJMA.n]=nJMA.mem2[nJMA.n][02];
nJMA.s48[nJMA.n]=nJMA.mem2[nJMA.n][03];nJMA.s50[nJMA.n]=nJMA.mem2[nJMA.n][04];nJMA.LP1[nJMA.n]=nJMA.mem2[nJMA.n][05];
nJMA.LP2[nJMA.n]=nJMA.mem2[nJMA.n][06];nJMA.s40[nJMA.n]=nJMA.mem2[nJMA.n][07];nJMA.s70[nJMA.n]=nJMA.mem2[nJMA.n][08];
//----+ <<< Пересохранение значений переменных >>> --------------------------------------------------------------------+
for(nJMA.ii=127;nJMA.ii>=0;nJMA.ii--)dJMA.mem8[nJMA.n][nJMA.ii]=dJMA.MOM8[nJMA.n][nJMA.ii];
for(nJMA.ii=127;nJMA.ii>=0;nJMA.ii--)dJMA.mem4[nJMA.n][nJMA.ii]=dJMA.MOM4[nJMA.n][nJMA.ii];
for(nJMA.ii=10; nJMA.ii>=0;nJMA.ii--)dJMA.mem5[nJMA.n][nJMA.ii]=dJMA.MOM5[nJMA.n][nJMA.ii];
//--+
dJMA.MOM1[nJMA.n][00]=dJMA.mem1[nJMA.n][00];dJMA.MOM1[nJMA.n][01]=dJMA.mem1[nJMA.n][01];
dJMA.MOM1[nJMA.n][02]=dJMA.mem1[nJMA.n][02];dJMA.MOM1[nJMA.n][03]=dJMA.mem1[nJMA.n][03];  
dJMA.MOM1[nJMA.n][04]=dJMA.mem1[nJMA.n][04];dJMA.MOM1[nJMA.n][05]=dJMA.mem1[nJMA.n][05];
dJMA.MOM1[nJMA.n][06]=dJMA.mem1[nJMA.n][06];dJMA.MOM1[nJMA.n][07]=dJMA.mem1[nJMA.n][07];
nJMA.MOM2[nJMA.n][00]=nJMA.mem2[nJMA.n][00];nJMA.MOM2[nJMA.n][01]=nJMA.mem2[nJMA.n][01];
nJMA.MOM2[nJMA.n][02]=nJMA.mem2[nJMA.n][02];nJMA.MOM2[nJMA.n][03]=nJMA.mem2[nJMA.n][03];
nJMA.MOM2[nJMA.n][04]=nJMA.mem2[nJMA.n][04];nJMA.MOM2[nJMA.n][05]=nJMA.mem2[nJMA.n][05];
nJMA.MOM2[nJMA.n][06]=nJMA.mem2[nJMA.n][06];nJMA.MOM2[nJMA.n][07]=nJMA.mem2[nJMA.n][07];
nJMA.MOM2[nJMA.n][08]=nJMA.mem2[nJMA.n][08];
//----+sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss+ 
  } 
  else   
    {
      nJMA.reset=-1;
      //--+ индикация ошибки в расчёте входного параметра nJMA.limit функции JJMASeries()
     if (nJMA.Tnew>nJMA.mem2[nJMA.n][01])
       {
       Print("JJMASerries number ="+nJMA.n+". ERROR01");
       Print("JJMASerries number ="+nJMA.n+". Параметр nJMA.limit функции JJMASeries меньше, чем необходимо");
       }
    else 
       { 
       int nJMA.LimitERROR=nJMA.limit+1-iBarShift(NULL,0,nJMA.mem2[nJMA.n][01],TRUE);
       Print("JMA.Serries number ="+nJMA.n+". ERROR02");
       Print("JJMASerries number ="+nJMA.n+". Параметр nJMA.limit функции JJMASeries больше, чем необходимо на "+nJMA.LimitERROR+"");
       }
  //--+ 
  return(0);
  }
//--+   
  } 
}
//----+WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW+

if(nJMA.bar==nJMA.MaxBar)
{
//----+----------------------------------------------------------------+
nJMA.f0[nJMA.n]=1; nJMA.s28[nJMA.n]=63; nJMA.s30[nJMA.n]=64;
for(int kk=0;kk<=nJMA.s28[nJMA.n];kk++)dJMA.list[nJMA.n][kk]=-1000000.0;
for(kk=nJMA.s30[nJMA.n]; kk<=127; kk++)dJMA.list[nJMA.n][kk]= 1000000.0;
//----+----------------------------------------------------------------+
}
//----+
if (nJMA.LP1[nJMA.n]<61){nJMA.LP1[nJMA.n]++; dJMA.buffer[nJMA.n][nJMA.LP1[nJMA.n]]=dJMA.series;}
if (nJMA.LP1[nJMA.n]>30)
{
//++++++++++++++++++
if (nJMA.f0[nJMA.n] != 0)
{
nJMA.f0[nJMA.n] = 0; nJMA.v5 = 0;
for( nJMA.ii=0; nJMA.ii<=29; nJMA.ii++) if (dJMA.buffer[nJMA.n][nJMA.ii+1] != dJMA.buffer[nJMA.n][nJMA.ii]){ nJMA.v5 = 1; break; }
nJMA.fD8 = nJMA.v5*30;
if (nJMA.fD8 == 0) dJMA.f38[nJMA.n] = dJMA.series; else dJMA.f38[nJMA.n] = dJMA.buffer[nJMA.n][1];
dJMA.f18[nJMA.n] = dJMA.f38[nJMA.n];
if (nJMA.fD8 > 29) nJMA.fD8 = 29;
}
else nJMA.fD8 = 0;
for(nJMA.ii=nJMA.fD8; nJMA.ii>=0; nJMA.ii--)
{
nJMA.val=31-nJMA.ii;
if (nJMA.ii == 0) dJMA.f8 = dJMA.series; else dJMA.f8 = dJMA.buffer[nJMA.n][nJMA.val];
dJMA.f28 = dJMA.f8 - dJMA.f18[nJMA.n]; dJMA.f48 = dJMA.f8 - dJMA.f38[nJMA.n];
if (MathAbs(dJMA.f28) > MathAbs(dJMA.f48)) dJMA.v2[nJMA.n] = MathAbs(dJMA.f28); else dJMA.v2[nJMA.n] = MathAbs(dJMA.f48);
dJMA.fA0 = dJMA.v2[nJMA.n]; dJMA.vv = dJMA.fA0 + 0.0000000001; //{1.0e-10;}
if (nJMA.s48[nJMA.n] <= 1) nJMA.s48[nJMA.n] = 127; else nJMA.s48[nJMA.n] = nJMA.s48[nJMA.n] - 1;
if (nJMA.s50[nJMA.n] <= 1) nJMA.s50[nJMA.n] = 10;  else nJMA.s50[nJMA.n] = nJMA.s50[nJMA.n] - 1;
if (nJMA.s70[nJMA.n] < 128) nJMA.s70[nJMA.n] = nJMA.s70[nJMA.n] + 1;
dJMA.s8[nJMA.n] = dJMA.s8[nJMA.n] + dJMA.vv - dJMA.ring2[nJMA.n][nJMA.s50[nJMA.n]];
dJMA.ring2[nJMA.n][nJMA.s50[nJMA.n]] = dJMA.vv;
if (nJMA.s70[nJMA.n] > 10) dJMA.s20 = dJMA.s8[nJMA.n] / 10.0; else dJMA.s20 = dJMA.s8[nJMA.n] / nJMA.s70[nJMA.n];
if (nJMA.s70[nJMA.n] > 127)
{
dJMA.s10 = dJMA.ring1[nJMA.n][nJMA.s48[nJMA.n]];
dJMA.ring1[nJMA.n][nJMA.s48[nJMA.n]] = dJMA.s20; nJMA.s68 = 64; nJMA.s58 = nJMA.s68;
while (nJMA.s68 > 1)
{
if (dJMA.list[nJMA.n][nJMA.s58] < dJMA.s10){nJMA.s68 = nJMA.s68 *0.5; nJMA.s58 = nJMA.s58 + nJMA.s68;}
else 
if (dJMA.list[nJMA.n][nJMA.s58]<= dJMA.s10) nJMA.s68 = 1; else{nJMA.s68 = nJMA.s68 *0.5; nJMA.s58 = nJMA.s58 - nJMA.s68;}
}
}
else
{
dJMA.ring1[nJMA.n][nJMA.s48[nJMA.n]] = dJMA.s20;
if  (nJMA.s28[nJMA.n] + nJMA.s30[nJMA.n] > 127){nJMA.s30[nJMA.n] = nJMA.s30[nJMA.n] - 1; nJMA.s58 = nJMA.s30[nJMA.n];}
else{nJMA.s28[nJMA.n] = nJMA.s28[nJMA.n] + 1; nJMA.s58 = nJMA.s28[nJMA.n];}
if  (nJMA.s28[nJMA.n] > 96) nJMA.s38[nJMA.n] = 96; else nJMA.s38[nJMA.n] = nJMA.s28[nJMA.n];
if  (nJMA.s30[nJMA.n] < 32) nJMA.s40[nJMA.n] = 32; else nJMA.s40[nJMA.n] = nJMA.s30[nJMA.n];
}
nJMA.s68 = 64; nJMA.s60 = nJMA.s68;
while (nJMA.s68 > 1)
{
if (dJMA.list[nJMA.n][nJMA.s60] >= dJMA.s20)
{
if (dJMA.list[nJMA.n][nJMA.s60 - 1] <= dJMA.s20) nJMA.s68 = 1; else {nJMA.s68 = nJMA.s68 *0.5; nJMA.s60 = nJMA.s60 - nJMA.s68; }
}
else{nJMA.s68 = nJMA.s68 *0.5; nJMA.s60 = nJMA.s60 + nJMA.s68;}
if ((nJMA.s60 == 127) && (dJMA.s20 > dJMA.list[nJMA.n][127])) nJMA.s60 = 128;
}
if (nJMA.s70[nJMA.n] > 127)
{
if (nJMA.s58 >= nJMA.s60)
{
if ((nJMA.s38[nJMA.n] + 1 > nJMA.s60) && (nJMA.s40[nJMA.n] - 1 < nJMA.s60)) dJMA.s18[nJMA.n] = dJMA.s18[nJMA.n] + dJMA.s20;
else 
if ((nJMA.s40[nJMA.n] + 0 > nJMA.s60) && (nJMA.s40[nJMA.n] - 1 < nJMA.s58)) dJMA.s18[nJMA.n] 
= dJMA.s18[nJMA.n] + dJMA.list[nJMA.n][nJMA.s40[nJMA.n] - 1];
}
else
if (nJMA.s40[nJMA.n] >= nJMA.s60) {if ((nJMA.s38[nJMA.n] + 1 < nJMA.s60) && (nJMA.s38[nJMA.n] + 1 > nJMA.s58)) dJMA.s18[nJMA.n] 
= dJMA.s18[nJMA.n] + dJMA.list[nJMA.n][nJMA.s38[nJMA.n] + 1]; }
else if  (nJMA.s38[nJMA.n] + 2 > nJMA.s60) dJMA.s18[nJMA.n] = dJMA.s18[nJMA.n] + dJMA.s20; 
else if ((nJMA.s38[nJMA.n] + 1 < nJMA.s60) && (nJMA.s38[nJMA.n] + 1 > nJMA.s58)) dJMA.s18[nJMA.n] 
= dJMA.s18[nJMA.n] + dJMA.list[nJMA.n][nJMA.s38[nJMA.n] + 1];
if (nJMA.s58 > nJMA.s60)
{
if ((nJMA.s40[nJMA.n] - 1 < nJMA.s58) && (nJMA.s38[nJMA.n] + 1 > nJMA.s58)) dJMA.s18[nJMA.n] = dJMA.s18[nJMA.n] - dJMA.list[nJMA.n][nJMA.s58];
else 
if ((nJMA.s38[nJMA.n]     < nJMA.s58) && (nJMA.s38[nJMA.n] + 1 > nJMA.s60)) dJMA.s18[nJMA.n] = dJMA.s18[nJMA.n] - dJMA.list[nJMA.n][nJMA.s38[nJMA.n]];
}
else
{
if ((nJMA.s38[nJMA.n] + 1 > nJMA.s58) && (nJMA.s40[nJMA.n] - 1 < nJMA.s58)) dJMA.s18[nJMA.n] = dJMA.s18[nJMA.n] - dJMA.list[nJMA.n][nJMA.s58];
else
if ((nJMA.s40[nJMA.n] + 0 > nJMA.s58) && (nJMA.s40[nJMA.n] - 0 < nJMA.s60)) dJMA.s18[nJMA.n] = dJMA.s18[nJMA.n] - dJMA.list[nJMA.n][nJMA.s40[nJMA.n]];
}
}
if (nJMA.s58 <= nJMA.s60)
{
if (nJMA.s58 >= nJMA.s60)
{
dJMA.list[nJMA.n][nJMA.s60] = dJMA.s20;
}
else
{
for( nJMA.jj = nJMA.s58 + 1; nJMA.jj<=nJMA.s60 - 1 ;nJMA.jj++)dJMA.list[nJMA.n][nJMA.jj - 1] = dJMA.list[nJMA.n][nJMA.jj];
dJMA.list[nJMA.n][nJMA.s60 - 1] = dJMA.s20;
}
}
else
{
for( nJMA.jj = nJMA.s58 - 1; nJMA.jj>=nJMA.s60 ;nJMA.jj--) dJMA.list[nJMA.n][nJMA.jj + 1] = dJMA.list[nJMA.n][nJMA.jj];
dJMA.list[nJMA.n][nJMA.s60] = dJMA.s20;
}
if (nJMA.s70[nJMA.n] <= 127)
{
dJMA.s18[nJMA.n] = 0;
for( nJMA.jj = nJMA.s40[nJMA.n] ; nJMA.jj<=nJMA.s38[nJMA.n] ;nJMA.jj++) dJMA.s18[nJMA.n] = dJMA.s18[nJMA.n] + dJMA.list[nJMA.n][nJMA.jj];
}
dJMA.f60 = dJMA.s18[nJMA.n] / (nJMA.s38[nJMA.n] - nJMA.s40[nJMA.n] + 1.0);
if (nJMA.LP2[nJMA.n] + 1 > 31) nJMA.LP2[nJMA.n] = 31; else nJMA.LP2[nJMA.n] = nJMA.LP2[nJMA.n] + 1;
if (nJMA.LP2[nJMA.n] <= 30)
{
if (dJMA.f28 > 0.0) dJMA.f18[nJMA.n] = dJMA.f8; else dJMA.f18[nJMA.n] = dJMA.f8 - dJMA.f28 * dJMA.f90[nJMA.n];
if (dJMA.f48 < 0.0) dJMA.f38[nJMA.n] = dJMA.f8; else dJMA.f38[nJMA.n] = dJMA.f8 - dJMA.f48 * dJMA.f90[nJMA.n];
dJMA.JMA[nJMA.n] = dJMA.series;
if (nJMA.LP2[nJMA.n]!=30) continue;
if (nJMA.LP2[nJMA.n]==30)
{
dJMA.fC0[nJMA.n] = dJMA.series;
if ( MathCeil(dJMA.f78[nJMA.n]) >= 1) dJMA.v4 = MathCeil(dJMA.f78[nJMA.n]); else dJMA.v4 = 1.0;

if(dJMA.v4>0)nJMA.fE8 = MathFloor(dJMA.v4);else{if(dJMA.v4<0)nJMA.fE8 = MathCeil (dJMA.v4);else nJMA.fE8 = 0.0;}

if (MathFloor(dJMA.f78[nJMA.n]) >= 1) dJMA.v2[nJMA.n] = MathFloor(dJMA.f78[nJMA.n]); else dJMA.v2[nJMA.n] = 1.0;

if(dJMA.v2[nJMA.n]>0)nJMA.fE0 = MathFloor(dJMA.v2[nJMA.n]);else{if(dJMA.v2[nJMA.n]<0)nJMA.fE0 = MathCeil (dJMA.v2[nJMA.n]);else nJMA.fE0 = 0.0;}

if (nJMA.fE8== nJMA.fE0) dJMA.f68 = 1.0; else {dJMA.v4 = nJMA.fE8 - nJMA.fE0; dJMA.f68 = (dJMA.f78[nJMA.n] - nJMA.fE0) / dJMA.v4;}
if (nJMA.fE0 <= 29) nJMA.v5 = nJMA.fE0; else nJMA.v5 = 29;
if (nJMA.fE8 <= 29) nJMA.v6 = nJMA.fE8; else nJMA.v6 = 29;
dJMA.fA8[nJMA.n] = (dJMA.series - dJMA.buffer[nJMA.n][nJMA.LP1[nJMA.n] - nJMA.v5]) * (1.0 - dJMA.f68) / nJMA.fE0 + (dJMA.series 
- dJMA.buffer[nJMA.n][nJMA.LP1[nJMA.n] - nJMA.v6]) * dJMA.f68 / nJMA.fE8;
}
}
else
{
if (dJMA.f98[nJMA.n] >= MathPow(dJMA.fA0/dJMA.f60, dJMA.f88[nJMA.n])) dJMA.v1[nJMA.n] = MathPow(dJMA.fA0/dJMA.f60, dJMA.f88[nJMA.n]);
else dJMA.v1[nJMA.n] = dJMA.f98[nJMA.n];
if (dJMA.v1[nJMA.n] < 1.0) dJMA.v2[nJMA.n] = 1.0;
else
{if(dJMA.f98[nJMA.n] >= MathPow(dJMA.fA0/dJMA.f60, dJMA.f88[nJMA.n])) dJMA.v3[nJMA.n] = MathPow(dJMA.fA0/dJMA.f60, dJMA.f88[nJMA.n]);
else dJMA.v3[nJMA.n] = dJMA.f98[nJMA.n]; dJMA.v2[nJMA.n] = dJMA.v3[nJMA.n];}
dJMA.f58 = dJMA.v2[nJMA.n]; dJMA.f70 = MathPow(dJMA.f90[nJMA.n], MathSqrt(dJMA.f58));
if (dJMA.f28 > 0.0) dJMA.f18[nJMA.n] = dJMA.f8; else dJMA.f18[nJMA.n] = dJMA.f8 - dJMA.f28 * dJMA.f70;
if (dJMA.f48 < 0.0) dJMA.f38[nJMA.n] = dJMA.f8; else dJMA.f38[nJMA.n] = dJMA.f8 - dJMA.f48 * dJMA.f70;
}
}
if (nJMA.LP2[nJMA.n] >30)
{
dJMA.f30 = MathPow(dJMA.Kg[nJMA.n], dJMA.f58);
dJMA.fC0[nJMA.n] =(1.0 - dJMA.f30) * dJMA.series + dJMA.f30 * dJMA.fC0[nJMA.n];
dJMA.fC8[nJMA.n] =(dJMA.series - dJMA.fC0[nJMA.n]) * (1.0 - dJMA.Kg[nJMA.n]) + dJMA.Kg[nJMA.n] * dJMA.fC8[nJMA.n];
dJMA.fD0 = dJMA.Pf[nJMA.n] * dJMA.fC8[nJMA.n] + dJMA.fC0[nJMA.n];
dJMA.f20 = dJMA.f30 *(-2.0);
dJMA.f40 = dJMA.f30 * dJMA.f30;
dJMA.fB0 = dJMA.f20 + dJMA.f40 + 1.0;
dJMA.fA8[nJMA.n] =(dJMA.fD0 - dJMA.JMA[nJMA.n]) * dJMA.fB0 + dJMA.f40 * dJMA.fA8[nJMA.n];
dJMA.JMA[nJMA.n] = dJMA.JMA[nJMA.n] + dJMA.fA8[nJMA.n];
}
}
//++++++++++++++++++
if (nJMA.LP1[nJMA.n] <=30)dJMA.JMA[nJMA.n]=0.0;
if((nJMA.bar==1)&&(nJMA.Tnew!=nJMA.MOM2[nJMA.n][01])&&(nJMA.limit==1))
{
//--+ <<< Сохранение значений переменных >>> +XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX+
dJMA.mem1[nJMA.n][00]=dJMA.fC0[nJMA.n];dJMA.mem1[nJMA.n][01]=dJMA.fC8[nJMA.n];dJMA.mem1[nJMA.n][02]=dJMA.fA8[nJMA.n];
dJMA.mem1[nJMA.n][03]= dJMA.s8[nJMA.n];dJMA.mem1[nJMA.n][04]=dJMA.f18[nJMA.n];dJMA.mem1[nJMA.n][05]=dJMA.f38[nJMA.n];
dJMA.mem1[nJMA.n][06]=dJMA.s18[nJMA.n];dJMA.mem1[nJMA.n][07]=dJMA.JMA[nJMA.n];nJMA.mem2[nJMA.n][02]=nJMA.s38[nJMA.n];
nJMA.mem2[nJMA.n][03]=nJMA.s48[nJMA.n];nJMA.mem2[nJMA.n][04]=nJMA.s50[nJMA.n];nJMA.mem2[nJMA.n][05]=nJMA.LP1[nJMA.n];
nJMA.mem2[nJMA.n][06]=nJMA.LP2[nJMA.n];nJMA.mem2[nJMA.n][07]=nJMA.s40[nJMA.n];nJMA.mem2[nJMA.n][08]=nJMA.s70[nJMA.n];
nJMA.mem2[nJMA.n][00]=Time[0];nJMA.mem2[nJMA.n][01]=Time[1];
for(nJMA.ii=127;nJMA.ii>=0;nJMA.ii--)dJMA.mem8[nJMA.n][nJMA.ii]=dJMA.list [nJMA.n][nJMA.ii];
for(nJMA.ii=127;nJMA.ii>=0;nJMA.ii--)dJMA.mem4[nJMA.n][nJMA.ii]=dJMA.ring1[nJMA.n][nJMA.ii];
for(nJMA.ii= 10;nJMA.ii>=0;nJMA.ii--)dJMA.mem5[nJMA.n][nJMA.ii]=dJMA.ring2[nJMA.n][nJMA.ii];
//--+XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX+
}
if (nJMA.bar==2)
{
//--+ <<< Сохранение значений переменных >>> +XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX+
dJMA.MOM1[nJMA.n][00]=dJMA.fC0[nJMA.n];dJMA.MOM1[nJMA.n][01]=dJMA.fC8[nJMA.n];dJMA.MOM1[nJMA.n][02]=dJMA.fA8[nJMA.n];
dJMA.MOM1[nJMA.n][03]= dJMA.s8[nJMA.n];dJMA.MOM1[nJMA.n][04]=dJMA.f18[nJMA.n];dJMA.MOM1[nJMA.n][05]=dJMA.f38[nJMA.n];
dJMA.MOM1[nJMA.n][06]=dJMA.s18[nJMA.n];dJMA.MOM1[nJMA.n][07]=dJMA.JMA[nJMA.n];nJMA.MOM2[nJMA.n][02]=nJMA.s38[nJMA.n];
nJMA.MOM2[nJMA.n][03]=nJMA.s48[nJMA.n];nJMA.MOM2[nJMA.n][04]=nJMA.s50[nJMA.n];nJMA.MOM2[nJMA.n][05]=nJMA.LP1[nJMA.n];
nJMA.MOM2[nJMA.n][06]=nJMA.LP2[nJMA.n];nJMA.MOM2[nJMA.n][07]=nJMA.s40[nJMA.n];nJMA.MOM2[nJMA.n][08]=nJMA.s70[nJMA.n];
nJMA.MOM2[nJMA.n][00]=Time[0];nJMA.MOM2[nJMA.n][01]=Time[2];
for(nJMA.ii=127;nJMA.ii>=0;nJMA.ii--)dJMA.MOM8[nJMA.n][nJMA.ii]=dJMA.list [nJMA.n][nJMA.ii];
for(nJMA.ii=127;nJMA.ii>=0;nJMA.ii--)dJMA.MOM4[nJMA.n][nJMA.ii]=dJMA.ring1[nJMA.n][nJMA.ii];
for(nJMA.ii= 10;nJMA.ii>=0;nJMA.ii--)dJMA.MOM5[nJMA.n][nJMA.ii]=dJMA.ring2[nJMA.n][nJMA.ii];
//--+XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX+
}
//----+  done --------------------------+
nJMA.reset=0;
return(dJMA.JMA[nJMA.n]);
}

//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
// JJMASeriesReset - Это дополнительная функция для инициализации внутренних переменных функции   | 
// JJMASeries.Exp1. Пример обращения: if (limit==Bars-1)JJMASeriesReset(5); где 5 - это количество| 
// обращений к JJMASeries.Exp1 в тексте индикатора                                                |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
void JJMASeriesReset(int nJJMAReset.Number)
 {
  int nJJMAReset.reset=-1;
  int nJJMAReset.set=JJMASeries(nJJMAReset.Number,0,0,0,0,0,0,0,nJJMAReset.reset);
  if((nJJMAReset.set==1)&&(nJJMAReset.reset==0))Print("JJMASeriesReset is OK!!!");
  else Print("JJMASeriesReset is ERROR!!!");
 }
//--+ --------------------------------------------------------------------------------------------+

/*
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
 INDICATOR_COUNTED() - Это дополнительная функция для возврата количества уже подсчитанных баров  | 
 индикатора. Её главная особенность заключается в том, что она позволяет не пересчитывать         |
 индикатор на всех барах при подключении к интернету. То есть при подключении к интернету эта     |
 функция в отличие от  стандартной функции IndicatorCounted() всё равно возвращает количество     |
 подсчитанных до подключения к интернету баров, а не ноль!          Функция  INDICATOR_COUNTED()  | 
 предназначена для замены функции IndicatorCounted() При значении параметра                       |
 INDICATOR_COUNTED.Input=0; функция возвращает количество уже подсчитанных баров, при значении    |
 параметра INDICATOR_COUNTED.Input = 1; происходит фиксация времени нулевого бара, для расчёта    |
 по его номеру при следующем старте функции int start() истинного значения количества уже         | 
 подсчитанных баров.    При значении параметра INDICATOR_COUNTED.Input = -1; происходит           |             
 обнуление времени нулевого бара, если это необходимо, при использовании оператора return(-1);    |
 для функции int start().                                                                         |
 Пример обращения:                                                                                |
                                                                                                  |
//----+ Введение целых переменных и получение уже подсчитанных баров                              |
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету  |
incounted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);                                        |
//---- проверка на возможные ошибки                                                               |
if (counted_bars<0){INDICATOR_COUNTED(-1); return(-1);}                                           |
//---- последний подсчитанный бар должен быть пересчитан                                          |
if (counted_bars>0) counted_bars--;                                                               |
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт  баров |
int limit=Bars-1-counted_bars;                                                                    |
//----                                                                                            |
for(bar=limit;bar>=0;bar--) { код вашего индикатора }                                             |
Если в тексте индикатора есть выражение return(-1) для функции int start(); то его следует        |
заменить на {INDICATOR_COUNTED(-1);return(-1);}                                                   |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
*/
int  INDICATOR_COUNTED(int INDICATOR_COUNTED.Input) 
//----+ 
{   
  int INDICATOR_COUNTED.counted_bars;
  //----+ xxxxxxxxxxx
  if (INDICATOR_COUNTED.Input == 1)
    {
      //---- введение переменных и получение их значений
      static int INDICATOR_COUNTED.T2, INDICATOR_COUNTED.Period; 
      INDICATOR_COUNTED.counted_bars=IndicatorCounted(); 
      if (INDICATOR_COUNTED.counted_bars<0)
       {
        //INDICATOR_COUNTED.T2=0; 
        return(INDICATOR_COUNTED.counted_bars);
       }
       //----+ фиксация времени открытия предпоследнего подсчитанного бара 
      INDICATOR_COUNTED.T2 =Time[2]; 
      INDICATOR_COUNTED.Period=Period();
      return(INDICATOR_COUNTED.counted_bars);
    }
  INDICATOR_COUNTED.counted_bars=IndicatorCounted(); 
  if (INDICATOR_COUNTED.counted_bars<0)
    {
    INDICATOR_COUNTED.T2=0; 
    return(INDICATOR_COUNTED.counted_bars);
    }
  //----+
  if((INDICATOR_COUNTED.counted_bars!=0)&&(IsConnected()==TRUE)&&(INDICATOR_COUNTED.T2==0))return(0);
  //----+ xxxxxxxxxxx
  if ((INDICATOR_COUNTED.Input==0)&&(INDICATOR_COUNTED.Period==Period()))
    {
     if((INDICATOR_COUNTED.counted_bars==0)&&(IsConnected()==TRUE))
      { 
       //Print("INDICATOR_COUNTED: Торговый Терминал только что подключился к интернету");  
       //Print("INDICATOR_COUNTED: Сейчас Функция INDICATOR_COUNTED() определит количество фактически подсчитанных баров");
       if (INDICATOR_COUNTED.T2 == 0)
         {
          //Печать результата обращения к функции INDICATOR_COUNTED при некорректной работе индикатора 
          Print("INDICATOR_COUNTED: Торговый Терминал только что подключился к интернету");
          Print("INDICATOR_COUNTED: Предпоследний подсчитанный бар не найден");
          Print("INDICATOR_COUNTED: Истинное количество уже подсчитанных баров определить невозможно ");
          Print("INDICATOR_COUNTED: Функция вернёт количество уже подсчитанных баров равное нулю");
          Print("INDICATOR_COUNTED: Будет произведён полный пересчёт индикатора на всех барах");
        //PlaySound("wait.wav");
          return(0); 
         }
        //----+ поиск предпоследнего подсчитанного бара по времени его открытия 
       int INDICATOR_COUNTED.BarShift=iBarShift(NULL,0,INDICATOR_COUNTED.T2,TRUE); 
       if (INDICATOR_COUNTED.BarShift<2)
         {
          //Печать результата обращения к функции INDICATOR_COUNTED при некорректной работе индикатора 
          Print("INDICATOR_COUNTED: Торговый Терминал только что подключился к интернету");
          Print("INDICATOR_COUNTED: Предпоследний подсчитанный бар не найден");
          Print("INDICATOR_COUNTED: Истинное количество уже подсчитанных баров определить невозможно ");
          Print("INDICATOR_COUNTED: Функция вернёт количество уже подсчитанных баров равное нулю");
          Print("INDICATOR_COUNTED: Будет произведён полный пересчёт индикатора на всех барах");
        //PlaySound("wait.wav");
          return(0); 
         }
       int INDICATOR_COUNTED.Resalt=Bars-1-INDICATOR_COUNTED.BarShift+2;
       //Печать результата обращения к функции INDICATOR_COUNTED при корректной работе индикатора 
     //Print("INDICATOR_COUNTED: Торговый Терминал только что подключился к интернету"); 
     //Print("INDICATOR_COUNTED: Сейчас Функция определит количество фактически подсчитанных баров"); 
     //Print("INDICATOR_COUNTED: Предпоследний подсчитанный бар найден");
     //Print("INDICATOR_COUNTED: Количество уже подсчитанных баров будет равно "+INDICATOR_COUNTED.Resalt+"");
     //Print("INDICATOR_COUNTED: Будет произведён пересчёт индикатора всего на "+INDICATOR_COUNTED.BarShift+" барах");
     //Print("INDICATOR_COUNTED: BarShift ="+INDICATOR_COUNTED.BarShift+" INDICATOR_COUNTED.T2 ="+INDICATOR_COUNTED.T2+""); 
       return(INDICATOR_COUNTED.Resalt); 
      }
     else return(INDICATOR_COUNTED.counted_bars);
    }
   //----+ xxxxxxxxxxx
  if (INDICATOR_COUNTED.Input ==-1)
   { 
    INDICATOR_COUNTED.T2 =0; 
    INDICATOR_COUNTED.Period=-1; 
    Print("INDICATOR_COUNTED: Ошибка в расчёте индикатора");
    Print("INDICATOR_COUNTED: Работа функции int start() будет прервана оператором return(-1)");
  //PlaySound("stops.wav");  
    return(0); 
   }
  return(INDICATOR_COUNTED.counted_bars);
}
//--+ --------------------------------------------------------------------------------------------+


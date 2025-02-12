//Version  January 7, 2007 Final
//+X================================================================X+
//|                                                 JJMASeries().mqh |
//|                       JMA code: Copyright © 1998, Jurik Research |
//|                                          http://www.jurikres.com | 
//|              MQL4 JJMASeries: Copyright © 2006, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+ 
  /*
  +-------------------------------------- <<< Функция JJMASeries() >>> -----------------------------------------------+

  +-----------------------------------------+ <<< Назначение >>> +----------------------------------------------------+

  Функция  JJMASeries()  предназначена  для  использования  алгоритма  JMA при написании любых индикаторов теханализа и
  экспертов,  для  замены  расчёта  классического  усреднения  на  этот  алгоритм.  Функция  не работает, если параметр
  nJMA.limit принимает значение, равное нулю! Все индикаторы, сделанные мною для JJMASeries(), выполнены с учётом этого
  ограничения.  Файл следует положить в папку MetaTrader\experts\include\ Следует учесть, что если nJMA.bar больше, чем
  nJMA.MaxBar,  то функция JJMASeries() возвращает значение равное нулю! на этом баре! И, следовательно, такое значение
  не  может  присутствовать  в  знаменателе  какой-либо  дроби  в  расчёте  индикатора! Эта версия функции JJMASeries()
  поддерживает  экспертов при её использовании в пользовательских индикаторах, к которым обращается эксперт. Эта версия
  функции  JJMASeries()  поддерживает экспертов при её использовании в коде индикатора, который полностью помещён в код
  эксперта  с  сохранением  всех  операторов цикла и переменных! При написании индикаторов и экспертов с использованием
  функции  JJMASeries(),  не  рекомендуется  переменным  давать  имена  начинающиеся  с  nJMA....  или dJMA.... Функция
  JJMASeries()  может  быть  использована  во  внутреннем  коде  других  пользовательских  функций, но при этом следует
  учитывать тот факт, что в каждом обращении к такой пользовательской функции у каждого обращения к JJMASeries() должен
  быть  свой  уникальный  номер  nJMA.number.  Функция  JJMASeries()  может быть использована во внутреннем коде других
  пользовательских  функций,  но  при  этом следует учитывать тот факт, что в каждом обращении к такой пользовательской
  функции у каждого обращения к JJMASeries() должен быть свой уникальный номер (nJMA.number). 
  
  +-------------------------------------+ <<< Входные параметры >>> +-------------------------------------------------+

  nJMA.number - порядковый номер обращения к функции JJMASeries(). (0, 1, 2, 3 и.т.д....)
  nJMA.dinJ   - параметр, позволяющий изменять параметры nJMA.Length и nJMA.Phase на каждом баре. 0 -  запрет изменения 
                параметров, любое другое значение - разрешение.
  nJMA.MaxBar - Максимальное  значение,  которое  может  принимать  номер  рассчитываемого  бара(bar).     Обычно равно 
                Bars-1-period;    Где "period" - это количество баров,  на которых  исходная  величина  dJMA.series  не 
                рассчитывается;
  nJMA.limit  - Количество ещё не подсчитанных баров плюс один или номер последнего непосчитанного бара,    Должно быть 
                обязательно равно  Bars-IndicatorCounted()-1;
  nJMA.Length - глубина сглаживания
  nJMA.Phase  - параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
  dJMA.series - Входной  параметр, по которому производится расчёт функции JJMASeries();
  nJMA.bar    - номер рассчитываемого бара, параметр должен  изменяться  оператором  цикла  от максимального значения к 
                нулевому. Причём его максимальное значение всегда должно равняться значению параметра nJMA.limit!!!

  +------------------------------------+ <<< Выходные параметры >>> +-------------------------------------------------+

  JJMASeries()- значение функции dJMA.JMA.   При  значениях  nJMA.bar  больше  чем  nJMA.MaxBar-30 функция JJMASeries() 
                всегда возвращает ноль!!!
  nJMA.reset  - параметр,  возвращающий по ссылке значение, отличенное от 0 , если  произошла ошибка в расчёте функции,
                0, если расчёт прошёл нормально. Этот параметр может быть только переменной, но не значением!!!!
                 
  +-----------------------------------+ <<< Инициализация функции >>> +-----------------------------------------------+
  
  Перед обращениями к функции JJMASeries(), когда количество уже подсчитанных баров равно 0, (а ещё лучше это сделать в
  блоке  инициализации  пользовательского  индикатора  или  эксперта)   следует  изменить  размеры  внутренних буферных
  переменных   функции,  для   этого   необходимо  обратиться  к  функции  JJMASeries() через  вспомогательную  функцию
  JJMASeriesResize() со   следующими   параметрами:   JJMASeriesResize(nJMA.number+1);   необходимо   сделать  параметр
  nJMA.number(MaxJMA.number) равным  количеству обращений  к  функции  JJMASeries(),  то  есть  на  единицу больше, чем
  максимальный nJMA.number. 
  
  +--------------------------------------+ <<< Индикация ошибок >>> +-------------------------------------------------+
  
  При отладке индикаторов и экспертов их коды могут содержать ошибки, для выяснения причин которых следует смотреть лог
  файл.  Все  ошибки  функция JJMASeries() пишет в лог файл в папке \MetaTrader\EXPERTS\LOGS\. Если, перед обращением к
  функции  JJMASeries()  в коде, который предшествовал функции, возникла MQL4 ошибка, то функция запишет в лог файл код
  ошибки  и содержание ошибки. Если при выполнении функции JJMASeries() в алгоритме JJMASeries() произошла MQL4 ошибка,
  то  функция  также  запишет  в  лог  файл код ошибки и содержание ошибки. При неправильном задании номера обращения к
  функции  JJMASeries()  nJMA.number  или  неверном определении размера буферных переменных nJJMAResize.Size в лог файл
  будет записаны сообщения о неверном определении этих параметров. Также в лог файл пишется информация при неправильном
  определении  параметра  nJMA.limit.  Если  при  выполнении  функции инициализации init() произошёл сбой при изменении
  размеров  буферных  переменных  функции  JJMASeries(),  то  функция  JJMASeriesResize запишет в лог файл информацию о
  неудачном  изменении  размеров  буферных  переменных. Если при обращении к функции JJMASeries()через внешний оператор
  цикла  была  нарушена  правильная последовательность изменения параметра nJMA.bar, то в лог файл будет записана и эта
  информация. Следует учесть, что некоторые ошибки программного кода будут порождать дальнейшие ошибки в его исполнении
  и  поэтому,  если  функция  JJMASeries()пишет  в  лог  файл сразу несколько ошибок, то устранять их следует в порядке
  времени  возникновения.  В правильно написанном индикаторе функция JJMASeries() может делать записи в лог файл только
  при  нарушениях  работы операционной системы. Исключение составляет запись изменения размеров буферных переменных при
  перезагрузке индикатора или эксперта, которая происходит при каждом вызове функции init(). 
  
  +---------------------------------+ <<< Пример обращения к функции >>> +--------------------------------------------+

//----+ определение функций JJMASeries()
#include <JJMASeries.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE); 
//---- 1 индикаторный буфер использован для счёта
SetIndexBuffer(0,Ind_Buffer);
//----+ Изменение размеров буферных переменных функции JJMASeries, nJMA.number=1(Одно обращение к функции JJMASeries)
if(JJMASeriesResize(1)==0)return(-1);
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
//---- последний подсчитанный бар должен быть пересчитан (без этого пересчёта функция JJMASeries() свой расчёт производить не будет!!!)
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
int limit=Bars-counted_bars-1;
MaxBar=Bars-1;
//----+ 
for(bar=limit;bar>=0;bar--)
 (
  double Series=Close[bar];
  //----+ Обращение к функции JJMASeries() за номером 0 для расчёта буфера Ind_Buffer[], 
  //параметры nJMA.Phase и nJMA.Length не меняются на каждом баре (nJMA.din=0)
  double Resalt=JJMASeries(0,0,MaxBar,limit,Phase,Length,Series,bar,reset);
  if (reset!=0)return(-1);
  Ind_Buffer[bar]=Resalt;
 }
return(0);
}
//----+ 

  */
//+X================================================================X+
//|  JJMASeries() function                                           |
//+X================================================================X+  

//----++ <<< Объявление глобальных переменных >>> +-----------------------------------------------------------------+
double dJMA.f18[1],dJMA.f38[1],dJMA.fA8[1],dJMA.fC0[1],dJMA.fC8[1],dJMA.s8[1],dJMA.s18[1],dJMA.v1[1],dJMA.v2[1];
double dJMA.v3[1],dJMA.f90[1],dJMA.f78[1],dJMA.f88[1],dJMA.f98[1],dJMA.JMA[1],dJMA.list[1][128],dJMA.ring1[1][128];
double dJMA.ring2[1][11],dJMA.buffer[1][62],dJMA.mem1[1][8],dJMA.mem3[1][128],dJMA.RING1[1][128],dJMA.RING2[1][11];
double dJMA.LIST[1][128],dJMA.Kg[1],dJMA.Pf[1];
//--+
int    nJMA.s28[1],nJMA.s30[1],nJMA.s38[1],nJMA.s40[1],nJMA.s48[1],nJMA.f0[1],nJMA.s50[1],nJMA.s70[1],nJMA.LP2[1];   
int    nJMA.LP1[1],nJMA.mem2[1][7],nJMA.mem7[1][11];
int    nJMA.TIME[1];
//--+ +-------------------------------------------------------------------------------------------------------------+
double dJMA.fA0,dJMA.vv,dJMA.v4,dJMA.f70,dJMA.s20,dJMA.s10,dJMA.fB0,dJMA.fD0,dJMA.f8,dJMA.f60,dJMA.f20,dJMA.f28;
double dJMA.f30,dJMA.f40,dJMA.f48,dJMA.f58,dJMA.f68;
//--+
int    nJMA.v5,nJMA.v6,nJMA.fE0,nJMA.fD8,nJMA.fE8,nJMA.val,nJMA.s58,nJMA.s60,nJMA.s68,nJMA.aa,nJMA.size;
int    nJMA.ii,nJMA.jj,nJMA.m,nJMA.n,nJMA.Tnew,nJMA.Told,nJMA.Error,nJMA.Resize;

//----++ <<< Объявление функции JJMASeries() >>> +--------------------------------------+

double JJMASeries
(
int nJMA.number, int nJMA.din,       int nJMA.MaxBar, int nJMA.limit,
int nJMA.Phase,  int nJMA.Length, double dJMA.series, int nJMA.bar,   int& nJMA.reset
)
//----++ +------------------------------------------------------------------------------+
{
nJMA.n = nJMA.number;

nJMA.reset = 1;
//=====+ <<< Проверки на ошибки >>> --------------------------------+
if (nJMA.bar == nJMA.limit)
 {
  //----++ проверка на инициализацию функции JJMASeries()
  if(nJMA.Resize < 1)
   {
    Print(StringConcatenate("JJMASeries number =", nJMA.n,
         ". Не было сделано изменение размеров буферных переменных функцией JJMASeriesResize()"));
    if(nJMA.Resize == 0)
        Print(StringConcatenate("JJMASeries number =", nJMA.n,
                ". Следует дописать обращение к функции JJMASeriesResize() в блок инициализации"));
    return(0.0);
   }
  //----++ проверка на ошибку в исполнении программного кода, предшествовавшего функции JJMASeries()
  nJMA.Error = GetLastError();
  if(nJMA.Error > 4000)
   {
    Print(StringConcatenate("JJMASeries number =", nJMA.n,
         ". В коде, предшествующем обращению к функции JJMASeries() number = ", nJMA.n, " ошибка!!!"));
         
    Print(StringConcatenate("JJMASeries number =", nJMA.n+ ". ", JMA_ErrDescr(nJMA.Error)));  
   } 
                                                   
  //----++ проверка на ошибку в задании переменных nJMA.number и nJMAResize.Number
  nJMA.size = ArraySize(dJMA.JMA);
  if (nJMA.size < nJMA.n) 
   {
    Print(StringConcatenate("JJMASeries number =", nJMA.n, 
          ". Ошибка!!! Неправильно задано значение переменной nJMA.number=",
                                                        nJMA.n, " функции JJMASeries()"));
    Print(StringConcatenate("JJMASeries number =", nJMA.n,
          ". Или неправильно задано значение  переменной nJJMAResize.Size=",
                                               nJMA.size, " функции JJMASeriesResize()"));
    return(0.0);
   }
 }
//----++ проверка на ошибку в последовательности изменения переменной nJMA.bar
if (nJMA.limit >= nJMA.MaxBar && nJMA.bar == 0)
    if(nJMA.MaxBar > 30 && nJMA.TIME[nJMA.n] == 0)
                  Print(StringConcatenate("JJMASeries number =", nJMA.n,
                        ". Ошибка!!! Нарушена правильная последовательность",
                               " изменения параметра nJMA.bar внешним оператором цикла!!!"));  
//----++ +----------------------------------------------------------------+ 
if (nJMA.bar > nJMA.MaxBar){nJMA.reset = 0; return(0.0);}
if(nJMA.bar == nJMA.MaxBar || nJMA.din != 0) 
  {
   //----++ <<< Расчёт коэффициентов  >>> +--------------------------------------------------+
   double nJMA.Dr, nJMA.Ds, nJMA.Dl;
   if(nJMA.Length < 1.0000000002) nJMA.Dr = 0.0000000001;
   else nJMA.Dr = (nJMA.Length - 1.0) / 2.0;
   if(nJMA.Phase >= -100 && nJMA.Phase <= 100)dJMA.Pf[nJMA.n] = nJMA.Phase / 100.0 + 1.5;
   if (nJMA.Phase > 100) dJMA.Pf[nJMA.n] = 2.5;
   if (nJMA.Phase < -100) dJMA.Pf[nJMA.n] = 0.5;
   nJMA.Dr = nJMA.Dr * 0.9; dJMA.Kg[nJMA.n] = nJMA.Dr / (nJMA.Dr + 2.0);
   nJMA.Ds = MathSqrt(nJMA.Dr); 
   nJMA.Dl = MathLog(nJMA.Ds); 
   dJMA.v1[nJMA.n]= nJMA.Dl;
   dJMA.v2[nJMA.n] = dJMA.v1[nJMA.n];
   if (dJMA.v1[nJMA.n] / MathLog(2.0) + 2.0 < 0.0) dJMA.v3[nJMA.n]= 0.0;
   else dJMA.v3[nJMA.n] = (dJMA.v2[nJMA.n] / MathLog(2.0)) + 2.0;
   dJMA.f98[nJMA.n] = dJMA.v3[nJMA.n];
   if (dJMA.f98[nJMA.n] >= 2.5) dJMA.f88[nJMA.n] = dJMA.f98[nJMA.n] - 2.0;
   else dJMA.f88[nJMA.n]= 0.5;
   dJMA.f78[nJMA.n] = nJMA.Ds * dJMA.f98[nJMA.n]; 
   dJMA.f90[nJMA.n]= dJMA.f78[nJMA.n] / (dJMA.f78[nJMA.n] + 1.0);
   //----++----------------------------------------------------------------------------------+
  }
//--+
if (nJMA.bar == nJMA.limit && nJMA.limit < nJMA.MaxBar)
  {
   //----+ <<< Восстановление значений переменных >>> +----------------------------------------------------------------------------+
   nJMA.Tnew = Time[nJMA.limit + 1];
   nJMA.Told = nJMA.TIME[nJMA.n];
   //--+
   if(nJMA.Tnew == nJMA.Told)
     {
      for(nJMA.aa = 127; nJMA.aa >= 0; nJMA.aa--)dJMA.list [nJMA.n][nJMA.aa] = dJMA.LIST [nJMA.n][nJMA.aa];
      for(nJMA.aa = 127; nJMA.aa >= 0; nJMA.aa--)dJMA.ring1[nJMA.n][nJMA.aa] = dJMA.RING1[nJMA.n][nJMA.aa];
      for(nJMA.aa = 10;  nJMA.aa >= 0; nJMA.aa--)dJMA.ring2[nJMA.n][nJMA.aa] = dJMA.RING2[nJMA.n][nJMA.aa];
      //--+
      dJMA.fC0[nJMA.n] = dJMA.mem1[nJMA.n][00]; dJMA.fC8[nJMA.n] = dJMA.mem1[nJMA.n][01]; dJMA.fA8[nJMA.n] = dJMA.mem1[nJMA.n][02];
      dJMA.s8 [nJMA.n] = dJMA.mem1[nJMA.n][03]; dJMA.f18[nJMA.n] = dJMA.mem1[nJMA.n][04]; dJMA.f38[nJMA.n] = dJMA.mem1[nJMA.n][05];
      dJMA.s18[nJMA.n] = dJMA.mem1[nJMA.n][06]; dJMA.JMA[nJMA.n] = dJMA.mem1[nJMA.n][07]; nJMA.s38[nJMA.n] = nJMA.mem2[nJMA.n][00];
      nJMA.s48[nJMA.n] = nJMA.mem2[nJMA.n][01]; nJMA.s50[nJMA.n] = nJMA.mem2[nJMA.n][02]; nJMA.LP1[nJMA.n] = nJMA.mem2[nJMA.n][03];
      nJMA.LP2[nJMA.n] = nJMA.mem2[nJMA.n][04]; nJMA.s40[nJMA.n] = nJMA.mem2[nJMA.n][05]; nJMA.s70[nJMA.n] = nJMA.mem2[nJMA.n][06];
     } 
   //--+ проверка на ошибки
   if(nJMA.Tnew != nJMA.Told)
    {
     nJMA.reset = -1;
     //--+ индикация ошибки в расчёте входного параметра nJMA.limit функции JJMASeries()
     if (nJMA.Tnew > nJMA.Told)
       {
        Print(StringConcatenate("JJMASeries number =", nJMA.n,
                 ". Ошибка!!! Параметр nJMA.limit функции JJMASeries() меньше, чем необходимо"));
       }
     else 
       { 
        int nJMA.LimitERROR = nJMA.limit + 1 - iBarShift(NULL, 0, nJMA.Told, TRUE);
        
        Print(StringConcatenate("JMASerries number =", nJMA.n,
                ". Ошибка!!! Параметр nJMA.limit функции JJMASeries() больше, чем необходимо на ",
                                                                                        nJMA.LimitERROR, ""));
       }
     //--+ Возврат через nJMA.reset=-1; ошибки в расчёте функции JJMASeries
     return(0);
    }
  //----+--------------------------------------------------------------------------------------------------------------------------+
  } 
if (nJMA.bar == 1)    
if (nJMA.limit != 1 || Time[nJMA.limit + 2] == nJMA.TIME[nJMA.n])
  {
   //--+ <<< Сохранение значений переменных >>> +-------------------------------------------------------------------------------+
   for(nJMA.aa = 127; nJMA.aa >= 0; nJMA.aa--)dJMA.LIST [nJMA.n][nJMA.aa] = dJMA.list [nJMA.n][nJMA.aa];
   for(nJMA.aa = 127; nJMA.aa >= 0; nJMA.aa--)dJMA.RING1[nJMA.n][nJMA.aa] = dJMA.ring1[nJMA.n][nJMA.aa];
   for(nJMA.aa = 10;  nJMA.aa >= 0; nJMA.aa--)dJMA.RING2[nJMA.n][nJMA.aa] = dJMA.ring2[nJMA.n][nJMA.aa];
   //--+
   dJMA.mem1[nJMA.n][00] = dJMA.fC0[nJMA.n]; dJMA.mem1[nJMA.n][01] = dJMA.fC8[nJMA.n]; dJMA.mem1[nJMA.n][02] = dJMA.fA8[nJMA.n];
   dJMA.mem1[nJMA.n][03] = dJMA.s8 [nJMA.n]; dJMA.mem1[nJMA.n][04] = dJMA.f18[nJMA.n]; dJMA.mem1[nJMA.n][05] = dJMA.f38[nJMA.n];
   dJMA.mem1[nJMA.n][06] = dJMA.s18[nJMA.n]; dJMA.mem1[nJMA.n][07] = dJMA.JMA[nJMA.n]; nJMA.mem2[nJMA.n][00] = nJMA.s38[nJMA.n];
   nJMA.mem2[nJMA.n][01] = nJMA.s48[nJMA.n]; nJMA.mem2[nJMA.n][02] = nJMA.s50[nJMA.n]; nJMA.mem2[nJMA.n][03] = nJMA.LP1[nJMA.n];
   nJMA.mem2[nJMA.n][04] = nJMA.LP2[nJMA.n]; nJMA.mem2[nJMA.n][05] = nJMA.s40[nJMA.n]; nJMA.mem2[nJMA.n][06] = nJMA.s70[nJMA.n];
   nJMA.TIME[nJMA.n] = Time[2];
   //--+-------------------------------------------------------------------------------------------------------------------------+
  } 
//----+
if (nJMA.LP1[nJMA.n] < 61){nJMA.LP1[nJMA.n]++; dJMA.buffer[nJMA.n][nJMA.LP1[nJMA.n]] = dJMA.series;}
if (nJMA.LP1[nJMA.n] > 30)
{
//++++++++++++++++++
if (nJMA.f0[nJMA.n] != 0)
{
nJMA.f0[nJMA.n] = 0; 
nJMA.v5 = 1;
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
if (nJMA.LP2[nJMA.n] > 30)
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
if (nJMA.LP1[nJMA.n] <= 30)dJMA.JMA[nJMA.n] = 0.0;
//----+ 

//----++ проверка на ошибку в исполнении программного кода функции JJMASeries()
nJMA.Error = GetLastError();
if(nJMA.Error > 4000)
  {
    Print(StringConcatenate("JJMASeries number =", nJMA.n, 
                                 ". При исполнении функции JJMASeries() произошла ошибка!!!"));
    Print(StringConcatenate("JJMASeries number =", nJMA.n, ". ", JMA_ErrDescr(nJMA.Error)));   
    return(0.0);
  }

nJMA.reset = 0;
return(dJMA.JMA[nJMA.n]);
//----+  Завершение вычислений функции JJMASeries() --------------------------+
}

//+X=============================================================================================X+
// JJMASeriesResize - Это дополнительная функция для изменения размеров буферных переменных       | 
// функции JJMASeries. Пример обращения: JJMASeriesResize(5); где 5 - это количество обращений к  | 
// JJMASeries()в тексте индикатора. Это обращение к функции  JJMASeriesResize следует поместить   |
// в блок инициализации пользовательского индикатора или эксперта                                 |
//+X=============================================================================================X+
int JJMASeriesResize(int nJJMAResize.Size)
 {
//----+
  if(nJJMAResize.Size < 1)
   {
    Print("JJMASeriesResize: Ошибка!!! Параметр nJJMAResize.Size не может быть меньше единицы!!!"); 
    nJMA.Resize = -1; 
    return(0);
   }  
  int nJJMAResize.reset, nJJMAResize.cycle;
  //--+
  while(nJJMAResize.cycle == 0)
   {
    //----++ <<< изменение размеров буферных переменных >>> +------------------------+
    if(ArrayResize(dJMA.list,  nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.ring1, nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.ring2, nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.buffer,nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.mem1,  nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.mem2,  nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.mem7,  nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.mem3,  nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.LIST,  nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.RING1, nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.RING2, nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.Kg,    nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.Pf,    nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.f18,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.f38,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.fA8,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.fC0,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.fC8,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.s8,    nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.s18,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.JMA,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.s50,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.s70,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.LP2,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.LP1,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.s38,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.s40,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.s48,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.v1,    nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.v2,    nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.v3,    nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.f90,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.f78,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.f88,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(dJMA.f98,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.s28,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.s30,   nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.f0,    nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    if(ArrayResize(nJMA.TIME,  nJJMAResize.Size) == 0){nJJMAResize.reset = -1; break;}
    //+------------------------------------------------------------------------------+
    nJJMAResize.cycle = 1;
   }
  //--+
  if(nJJMAResize.reset == -1)
   {
    Print("JJMASeriesResize: Ошибка!!! Не удалось изменить размеры буферных переменных функции JJMASeries().");   
    int nJJMAResize.Error = GetLastError();
    if(nJJMAResize.Error > 4000)
                         Print(StringConcatenate("JJMASeriesResize(): ", JMA_ErrDescr(nJJMAResize.Error)));                                                                                                                                                                                                            
    nJMA.Resize = -2;
    return(0);
   }
  else  
   {
    Print(StringConcatenate("JJMASeriesResize: JJMASeries()size = ", nJJMAResize.Size, ""));

    //----+-------------------------------------------------------------------+
    ArrayInitialize(nJMA.f0,   1);
    ArrayInitialize(nJMA.s28, 63);
    ArrayInitialize(nJMA.s30, 64);
    for(int rrr = 0; rrr < nJJMAResize.Size; rrr++)
     {
       for(int kkk = 0; kkk <= nJMA.s28[rrr]; kkk++)dJMA.list[rrr][kkk] = -1000000.0;
       for(kkk = nJMA.s30[rrr]; kkk <= 127; kkk++)dJMA.list[rrr][kkk] = 1000000.0;
     }
    //----+-------------------------------------------------------------------+
    nJMA.Resize = nJJMAResize.Size;
    return(nJJMAResize.Size);
   }  
//----+
 }

/*
//+X=================================================================================================X+
JJMASeriesAlert  -  Это  дополнительная  функция  для  индикации ошибки в задании внешних переменных  | 
nJMA.Length и nJMA.Phase функции JJMASeries.                                                          |
  -------------------------- входные параметры  --------------------------                            |
JJMASeriesAlert.Number                                                                                |
JJMASeriesAlert.ExternVar значение внешней переменной для параметра nJMA.Length                       |
JJMASeriesAlert.name имя внешней переменной для параметра nJMA.Phase, если JJMASeriesAlert.Number=0   |
или nJMA.Phase, если JJMASeriesAlert.Number=1.                                                        |
  -------------------------- Пример использования  -----------------------                            |
  int init()                                                                                          |
//----                                                                                                |
Здесь какая-то инициализация переменных и буферов                                                     |
                                                                                                      |
//---- установка алертов на недопустимые значения внешних переменных                                  |
JJMASeriesAlert(0,"Length1",Length1);                                                                 |
JJMASeriesAlert(0,"Length2",Length2);                                                                 |
JJMASeriesAlert(1,"Phase1",Phase1);                                                                   |                                                            
JJMASeriesAlert(1,"Phase2",Phase2);                                                                   |                                                          
//---- завершение инициализации                                                                       |
return(0);                                                                                            |
}                                                                                                     |
//+X=================================================================================================X+
*/
void JJMASeriesAlert
 (
  int JJMASeriesAlert.Number, string JJMASeriesAlert.name, int JJMASeriesAlert.ExternVar
 )
 {
  //---- установка алертов на недопустимые значения входных параметров 
  if (JJMASeriesAlert.Number==0)if(JJMASeriesAlert.ExternVar<1)
          Alert(StringConcatenate("Параметр ", JJMASeriesAlert.name, " должен быть не менее 1", 
                   " Вы ввели недопустимое ", JJMASeriesAlert.ExternVar, " будет использовано  1"));
  if (JJMASeriesAlert.Number==1)
   {
    if (JJMASeriesAlert.ExternVar < -100 || JJMASeriesAlert.ExternVar > 100)
          Alert(StringConcatenate("Параметр ", JJMASeriesAlert.name, " должен быть от -100 до +100", 
          " Вы ввели недопустимое ", JJMASeriesAlert.ExternVar, " будет использовано -100"));
   }
 }

/*
перевод сделан Николаем Косициным 01.12.2006  
//+X================================================================X+
                                          JMA_ErrDescr(MQL4_RUS).mqh |
                         Copyright © 2004, MetaQuotes Software Corp. |
                                          http://www.metaquotes.net/ |
 функция JMA_ErrDescr() по коду MQL4 ошибки возвращает стринговую    |
 строку с кодом и содержанием ошибки.                                |
  -------------------- Пример использования  ----------------------- | 
 int Error=GetLastError();                                           |
 if(Error>4000)Print(JMA_ErrDescr(Error));                           |
//+X================================================================X+
*/
string JMA_ErrDescr(int error_code)
 {
  string error_string;
//----
  switch(error_code)
    {
     //---- MQL4 ошибки 
     case 4000: error_string = StringConcatenate("Код ошибки = ",error_code,". нет ошибки");                                              break;
     case 4001: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильный указатель функции");                          break;
     case 4002: error_string = StringConcatenate("Код ошибки = ",error_code,". индекс массива не соответствует его размеру");             break;
     case 4003: error_string = StringConcatenate("Код ошибки = ",error_code,". Нет памяти для стека функций");                            break;
     case 4004: error_string = StringConcatenate("Код ошибки = ",error_code,". Переполнение стека после рекурсивного вызова");            break;
     case 4005: error_string = StringConcatenate("Код ошибки = ",error_code,". На стеке нет памяти для передачи параметров");             break;
     case 4006: error_string = StringConcatenate("Код ошибки = ",error_code,". Нет памяти для строкового параметра");                     break;
     case 4007: error_string = StringConcatenate("Код ошибки = ",error_code,". Нет памяти для временной строки");                         break;
     case 4008: error_string = StringConcatenate("Код ошибки = ",error_code,". Неинициализированная строка");                             break;
     case 4009: error_string = StringConcatenate("Код ошибки = ",error_code,". Неинициализированная строка в массиве");                   break;
     case 4010: error_string = StringConcatenate("Код ошибки = ",error_code,". Нет памяти для строкового массива");                       break;
     case 4011: error_string = StringConcatenate("Код ошибки = ",error_code,". Слишком длинная строка");                                  break;
     case 4012: error_string = StringConcatenate("Код ошибки = ",error_code,". Остаток от деления на ноль");                              break;
     case 4013: error_string = StringConcatenate("Код ошибки = ",error_code,". Деление на ноль");                                         break;
     case 4014: error_string = StringConcatenate("Код ошибки = ",error_code,". Неизвестная команда");                                     break;
     case 4015: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильный переход (never generated error)");            break;
     case 4016: error_string = StringConcatenate("Код ошибки = ",error_code,". Неинициализированный массив");                             break;
     case 4017: error_string = StringConcatenate("Код ошибки = ",error_code,". Вызовы DLL не разрешены");                                 break;
     case 4018: error_string = StringConcatenate("Код ошибки = ",error_code,". Невозможно загрузить библиотеку");                         break;
     case 4019: error_string = StringConcatenate("Код ошибки = ",error_code,". Невозможно вызвать функцию");                              break;
     case 4020: error_string = StringConcatenate("Код ошибки = ",error_code,". Вызовы внешних библиотечных функций не разрешены");        break;
     case 4021: error_string = StringConcatenate("Код ошибки = ",error_code,". Недостаточно памяти для строки, возвращаемой из функции"); break;
     case 4022: error_string = StringConcatenate("Код ошибки = ",error_code,". Система занята (never generated error)");                  break;
     case 4050: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильное количество параметров функции");              break;
     case 4051: error_string = StringConcatenate("Код ошибки = ",error_code,". Недопустимое значение параметра функции");                 break;
     case 4052: error_string = StringConcatenate("Код ошибки = ",error_code,". Внутренняя ошибка строковой функции");                     break;
     case 4053: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка массива");                                          break;
     case 4054: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильное использование массива-таймсерии");            break;
     case 4055: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка пользовательского индикатора");                     break;
     case 4056: error_string = StringConcatenate("Код ошибки = ",error_code,". Массивы несовместимы");                                    break;
     case 4057: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка обработки глобальныех переменных");                 break;
     case 4058: error_string = StringConcatenate("Код ошибки = ",error_code,". Глобальная переменная не обнаружена");                     break;
     case 4059: error_string = StringConcatenate("Код ошибки = ",error_code,". Функция не разрешена в тестовом режиме");                  break;
     case 4060: error_string = StringConcatenate("Код ошибки = ",error_code,". Функция не подтверждена");                                 break;
     case 4061: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка отправки почты");                                   break;
     case 4062: error_string = StringConcatenate("Код ошибки = ",error_code,". Ожидается параметр типа string");                          break;
     case 4063: error_string = StringConcatenate("Код ошибки = ",error_code,". Ожидается параметр типа integer");                         break;
     case 4064: error_string = StringConcatenate("Код ошибки = ",error_code,". Ожидается параметр типа double");                          break;
     case 4065: error_string = StringConcatenate("Код ошибки = ",error_code,". В качестве параметра ожидается массив");                   break;
     case 4066: error_string = StringConcatenate("Код ошибки = ",error_code,". Запрошенные исторические данные в состоянии обновления");  break;
     case 4067: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка при выполнении торговой операции");                 break;
     case 4099: error_string = StringConcatenate("Код ошибки = ",error_code,". Конец файла");                                             break;
     case 4100: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка при работе с файлом");                              break;
     case 4101: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильное имя файла");                                  break;
     case 4102: error_string = StringConcatenate("Код ошибки = ",error_code,". Слишком много открытых файлов");                           break;
     case 4103: error_string = StringConcatenate("Код ошибки = ",error_code,". Невозможно открыть файл");                                 break;
     case 4104: error_string = StringConcatenate("Код ошибки = ",error_code,". Несовместимый режим доступа к файлу");                     break;
     case 4105: error_string = StringConcatenate("Код ошибки = ",error_code,". Ни один ордер не выбран");                                 break;
     case 4106: error_string = StringConcatenate("Код ошибки = ",error_code,". Неизвестный символ");                                      break;
     case 4107: error_string = StringConcatenate("Код ошибки = ",error_code,". Неправильный параметр цены для торговой функции");         break;
     case 4108: error_string = StringConcatenate("Код ошибки = ",error_code,". Неверный номер тикета");                                   break;
     case 4109: error_string = StringConcatenate("Код ошибки = ",error_code,". Торговля не разрешена");                                   break;
     case 4110: error_string = StringConcatenate("Код ошибки = ",error_code,". Длинные позиции не разрешены");                            break;
     case 4111: error_string = StringConcatenate("Код ошибки = ",error_code,". Короткие позиции не разрешены");                           break;
     case 4200: error_string = StringConcatenate("Код ошибки = ",error_code,". Объект уже существует");                                   break;
     case 4201: error_string = StringConcatenate("Код ошибки = ",error_code,". Запрошено неизвестное свойство объекта");                  break;
     case 4202: error_string = StringConcatenate("Код ошибки = ",error_code,". Объект не существует");                                    break;
     case 4203: error_string = StringConcatenate("Код ошибки = ",error_code,". Неизвестный тип объекта");                                 break;
     case 4204: error_string = StringConcatenate("Код ошибки = ",error_code,". Нет имени объекта");                                       break;
     case 4205: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка координат объекта");                                break;
     case 4206: error_string = StringConcatenate("Код ошибки = ",error_code,". Не найдено указанное подокно");                            break;
     case 4207: error_string = StringConcatenate("Код ошибки = ",error_code,". Ошибка при работе с объектом");                            break;
     default:   error_string = StringConcatenate("Код ошибки = ",error_code,". неизвестная ошибка");
    }
//----
  return(error_string);
 }
//+------------------------------------------------------------------+



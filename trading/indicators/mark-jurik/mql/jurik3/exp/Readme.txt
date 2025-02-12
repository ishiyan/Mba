//Пример обращения к индикатору в эксперте(экспертные варианты JJMASeries и JurXSeries):

int bar=0;// бар должен быть только нулевым
//----+ Получение и сохранение в буффер значений индикатора
//----+ Буффер Buffer следует прописать в индикаторные буфферы
Buffer[bar]=iCustom( NULL, 0, "JFatl",Length,Phase,0,Input_Price_Customs,0,bar);
//----+ проверка количества баров на достаточность для дальнейшего расчёта
if (Bars-1<39+30+3)return(0);
int NewTime=Time[1];
double Trend1=Buffer[1]-Buffer[2];
double Trend2=Buffer[2]-Buffer[3];
//----+ переменную OldTime следует ввести до функций int start() и int init() 
if((NewTime!=OldTime)&&(Trend2<0)&&(Trend1>0))Открывается позиция на покупку
if((NewTime!=OldTime)&&(Trend2>0)&&(Trend1<0))Открывается позиция на продажу
OldTime=NewTime;


//Пример обращения к JJMASeries (экспертный вариант JJMASeries) в эксперте:

int MaxBar=Bars-1;
//----+ Обращение следует делать только через цикл, где переменная bar принимает значения 0 и 1
int reset,limit=1;// переменную reset в обращении к JJMASeries  нельзя заменять числом
double Series,Resalt;
for(int bar=limit;bar>=0;bar--)
 {
  Series=PriceSeries(Input_Price_Customs, bar);// если проще Series=Close[bar];
  //----+ Обращение к функции JJMASeries за номером 0 (nJMAdin=0)
  Resalt=JJMASeries(0,0,MaxBar,limit,Phase,Smooth,Series,bar,reset);
  //----+ проверка на отсутствие ошибки в предыдущей операции (Эту проверку в эксперте можно и не делать!)
  if(reset!=0)return(-1);  
  Buffer[bar]=Resalt;
 }
//----+ проверка количества баров на достаточность для дальнейшего расчёта
if (Bars-1<30+3)return(0);
//----+
int NewTime=Time[1];
double Trend1=Buffer[1]-Buffer[2];
double Trend2=Buffer[2]-Buffer[3];
//----+ переменную OldTime следует ввести до функций int start() и int init() 
if((NewTime!=OldTime)&&(Trend2<0)&&(Trend1>0))Открывается позиция на покупку
if((NewTime!=OldTime)&&(Trend2>0)&&(Trend1<0))Открывается позиция на продажу
OldTime=NewTime;
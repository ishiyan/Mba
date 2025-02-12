 /*
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                            INDICATOR_COUNTED.mqh |
//|                           Copyright © 2006,     Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
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
  if((INDICATOR_COUNTED.counted_bars!=0)&&(IsConnected()==TRUE)&&(INDICATOR_COUNTED.T2==0))
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
       int  INDICATOR_COUNTED.BarShift=iBarShift(NULL,0,INDICATOR_COUNTED.T2,TRUE); 
       if ((INDICATOR_COUNTED.BarShift<2)||(INDICATOR_COUNTED.T2!=Time[INDICATOR_COUNTED.BarShift]))
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


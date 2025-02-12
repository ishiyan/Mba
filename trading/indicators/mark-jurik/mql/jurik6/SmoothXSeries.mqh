//Version  June 15, 2007 Final
//+X================================================================X+
//|                                                SmoothXSeries.mqh |
//|                               Copyright © 2007, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+

//+X================================================================X+
//| include functions                                                |
//+X================================================================X+
#include <T3Series.mqh>
#include <MASeries.mqh>
#include <LRMASeries.mqh>
#include <JJMASeries.mqh>
#include <JurXSeries.mqh>
#include <ParMASeries.mqh>
//+X================================================================X+
//| SmoothXSeries() functions                                        |
//+X================================================================X+

//----+ <<< Объявление функции SmoothXSeries() >>> +-----------------+

double SmoothXSeries
       (int number, int SmoothMode, int din,   
              int MaxBar, int limit, int Phase, int Length,
                                 double Series, int bar, int& reset)
//----+ +------------------------------------------------------------+
 {
//----+
  double SmoothX;
  //----+
  switch(SmoothMode)
  {
   //----++ <<< Расчёт JJMASeries >>> +---------------------------------------+
   case 0 : SmoothX = JJMASeries(number, din, MaxBar, 
                                   limit, Phase, Length, Series, bar, reset); 
   break;            
   //----++ <<< Расчёт JurXSeries >>> +---------------------------------------+
   case 1 : SmoothX = JurXSeries(number, din, MaxBar, 
                                   limit, Length, Series, bar, reset); 
   break;         
   //----++ <<< Расчёт ParMASeries >>> +--------------------------------------+
   case 2 : SmoothX = ParMASeries(number, MaxBar, 
                                   limit, Length, Series, bar, reset); 
   break;          
   //----++ <<< Расчёт LRMASeries >>> +---------------------------------------+
   case 3 : SmoothX = LRMASeries(number, MaxBar,
                                   limit, Length, Series, bar, reset); 
   break; 
   //----++ <<< Расчёт T3Series >>> +-----------------------------------------+
   case 4 : SmoothX = T3Series(number, din, MaxBar,
                                   limit, Phase, Length, Series, bar, reset); 
   break;   
   //----++ <<< Расчёт SMASeries >>> +----------------------------------------+
   case 5 : SmoothX = MASeries(number, 0, MaxBar,
                                   limit, Length, Series, bar, reset); 
   break; 
   //----++ <<< Расчёт EMASeries >>> +----------------------------------------+
   case 6 : SmoothX = MASeries(number, 1, MaxBar,
                                   limit, Length, Series, bar, reset); 
   break; 
   //----++ <<< Расчёт SSMASeries >>> +---------------------------------------+
   case 7 : SmoothX = MASeries(number, 2, MaxBar,
                                   limit, Length, Series, bar, reset); 
   break; 
   //----++ <<< Расчёт LWMASeries >>> +---------------------------------------+
   case 8 : SmoothX = MASeries(number, 3, MaxBar,
                                   limit, Length, Series, bar, reset); 
   break;     
   //----++ <<< Расчёт JJMASeries >>> +---------------------------------------+
   default : SmoothX = JJMASeries(number, din, MaxBar,
                                   limit, Phase, Length, Series, bar, reset);                     
   //----++ +-----------------------------------------------------------------+      
  } 
//----+
return(SmoothX);
//----+
 }
//+X=============================================================================================X+
// SmoothXSeriesResize - Это дополнительная функция для изменения размеров буферных переменных    | 
// функции SmoothXSeries. Пример обращения: SmoothXSeriesResize(5); где 5 - это количество        | 
// обращений к SmoothXSeries()в тексте индикатора. Это обращение к функции  SmoothXSeriesResize   |
// следует поместить в блок инициализации пользовательского индикатора или эксперта               |
//+X=============================================================================================X+

int SmoothXSeriesResize(int Size)
 {
//----+
  if(Size < 1)
   {
    Print("SmoothXSeriesResize: Ошибка!!! Параметр Size не может быть меньше единицы!!!"); 
    Print("SmoothXSeriesResize: Ошибка!!! Не удалось изменить размеры буферных переменных!!!");
    return(0);
   } 
   string PrintWord1 = 
             "SmoothXSeriesResize: Ошибка!!! Не удалось изменить размеры буферных переменных!!!";
   
   string PrintWord2 = "SmoothXSeriesResize: SmoothXSeries Size = ";   
  //--+
  if (ParMASeriesResize(Size) !=  Size){Print(PrintWord1); return(0);}   
  if (LRMASeriesResize (Size) !=  Size){Print(PrintWord1); return(0);}   
  if (JJMASeriesResize (Size) !=  Size){Print(PrintWord1); return(0);}   
  if (JurXSeriesResize (Size) !=  Size){Print(PrintWord1); return(0);}   
  if (T3SeriesResize   (Size) !=  Size){Print(PrintWord1); return(0);}   
  if (MASeriesResize (4 * Size) != 4 * Size){Print(PrintWord1); return(0);}   
  //--+
  Print(StringConcatenate(PrintWord2, Size, "."));
  return(Size); 
//----+
 }
//+X-------------------------------------+ <<< The End >>> +-------------------------------------X+





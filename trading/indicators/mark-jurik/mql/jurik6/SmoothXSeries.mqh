//Version  June 15, 2007 Final
//+X================================================================X+
//|                                                SmoothXSeries.mqh |
//|                               Copyright � 2007, Nikolay Kositsin | 
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

//----+ <<< ���������� ������� SmoothXSeries() >>> +-----------------+

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
   //----++ <<< ������ JJMASeries >>> +---------------------------------------+
   case 0 : SmoothX = JJMASeries(number, din, MaxBar, 
                                   limit, Phase, Length, Series, bar, reset); 
   break;            
   //----++ <<< ������ JurXSeries >>> +---------------------------------------+
   case 1 : SmoothX = JurXSeries(number, din, MaxBar, 
                                   limit, Length, Series, bar, reset); 
   break;         
   //----++ <<< ������ ParMASeries >>> +--------------------------------------+
   case 2 : SmoothX = ParMASeries(number, MaxBar, 
                                   limit, Length, Series, bar, reset); 
   break;          
   //----++ <<< ������ LRMASeries >>> +---------------------------------------+
   case 3 : SmoothX = LRMASeries(number, MaxBar,
                                   limit, Length, Series, bar, reset); 
   break; 
   //----++ <<< ������ T3Series >>> +-----------------------------------------+
   case 4 : SmoothX = T3Series(number, din, MaxBar,
                                   limit, Phase, Length, Series, bar, reset); 
   break;   
   //----++ <<< ������ SMASeries >>> +----------------------------------------+
   case 5 : SmoothX = MASeries(number, 0, MaxBar,
                                   limit, Length, Series, bar, reset); 
   break; 
   //----++ <<< ������ EMASeries >>> +----------------------------------------+
   case 6 : SmoothX = MASeries(number, 1, MaxBar,
                                   limit, Length, Series, bar, reset); 
   break; 
   //----++ <<< ������ SSMASeries >>> +---------------------------------------+
   case 7 : SmoothX = MASeries(number, 2, MaxBar,
                                   limit, Length, Series, bar, reset); 
   break; 
   //----++ <<< ������ LWMASeries >>> +---------------------------------------+
   case 8 : SmoothX = MASeries(number, 3, MaxBar,
                                   limit, Length, Series, bar, reset); 
   break;     
   //----++ <<< ������ JJMASeries >>> +---------------------------------------+
   default : SmoothX = JJMASeries(number, din, MaxBar,
                                   limit, Phase, Length, Series, bar, reset);                     
   //----++ +-----------------------------------------------------------------+      
  } 
//----+
return(SmoothX);
//----+
 }
//+X=============================================================================================X+
// SmoothXSeriesResize - ��� �������������� ������� ��� ��������� �������� �������� ����������    | 
// ������� SmoothXSeries. ������ ���������: SmoothXSeriesResize(5); ��� 5 - ��� ����������        | 
// ��������� � SmoothXSeries()� ������ ����������. ��� ��������� � �������  SmoothXSeriesResize   |
// ������� ��������� � ���� ������������� ����������������� ���������� ��� ��������               |
//+X=============================================================================================X+

int SmoothXSeriesResize(int Size)
 {
//----+
  if(Size < 1)
   {
    Print("SmoothXSeriesResize: ������!!! �������� Size �� ����� ���� ������ �������!!!"); 
    Print("SmoothXSeriesResize: ������!!! �� ������� �������� ������� �������� ����������!!!");
    return(0);
   } 
   string PrintWord1 = 
             "SmoothXSeriesResize: ������!!! �� ������� �������� ������� �������� ����������!!!";
   
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





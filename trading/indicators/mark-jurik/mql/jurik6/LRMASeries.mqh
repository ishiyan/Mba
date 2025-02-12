//Version  January 7, 2007 Final
//+X================================================================X+
//|                                                 LRMASeries().mqh |
//|                             LRMA code: Copyright � 2005, alexjou |
//|              MQL4 LRMASeries()Copyright � 2006, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+
  /*

  +-------------------------------------- <<< ������� LRMASeries() >>> -----------------------------------------------+

  +-----------------------------------------+ <<< ���������� >>> +----------------------------------------------------+

  �������  LRMASeries()  �������������  ���  ������������� ��������� �������� ��������� ��� ��������� ����� �����������
  ����������  �  ���������,  ���  ������  �������  ������������� ���������� �� ���� ��������. ������� �� ��������, ����
  ��������  LRMA.limit  ���������  ��������,  ������ ����! ��� ����������, ��������� ���� ��� LRMASeries(), ��������� �
  ������  �����  �����������.  ���� ������� �������� � ����� (����������): MetaTrader\experts\include\. ������� ������,
  ���  ����  nLRMA.bar ������, ��� nLRMA.MaxBar, �� ������� LRMASeries() ���������� �������� ������ ����! �� ���� ����!
  �,  �������������,  �����  ��������  �� ����� �������������� � ����������� �����-���� ����� � ������� ����������! ���
  ������  �������  LRMASeries()  ������������  ��������� ��� � ������������� � ���������������� �����������, � �������
  ����������  �������.  ���  ������ ������� LRMASeries() ������������ ��������� ��� � ������������� � ���� ����������,
  ������� ��������� ������� � ��� �������� � ����������� ���� ���������� �����! ��� ��������� ����������� � ��������� �
  ��������������  ������� LRMASeries(), �� ������������� ���������� ������ ����� ������������ � nLRMA.... ��� dLRMA....
  �������  LRMASeries() ����� ���� ������������ �� ���������� ���� ������ ���������������� �������, �� ��� ���� �������
  ��������� ��� ����, ��� � ������ ��������� � ����� ���������������� ������� � ������� ��������� � LRMASeries() ������
  ���� ���� ���������� ����� (nLRMA.number). 

  +-------------------------------------+ <<< ������� ��������� >>> +-------------------------------------------------+

  nLRMA.n      - ���������� ����� ��������� � ������� LRMASeries(). (0, 1, 2, 3 �.�.�....)
  nLRMA.MaxBar - ������������ ��������,  ������� �����  ��������� �����  ��������������� ���� (nLRMA.bar). ������ ����� 
                 Bars-1-period;  ��� "period" -  ��� ���������� �����,  �� �������  �������� ��������  dLRMA.series  �� 
                 ��������������; 
  nLRMA.limit  - ���������� ��� �� ������������ ����� ���� ���� ��� ����� ���������� �������������� ����,   ������ ���� 
                 ����������� �����  Bars-IndicatorCounted()-1;
  nLRMA.Period - ������ �����������. �������� �� �������� �� ������ ����!    ����������� �������� ����������� ��������� 
                 500.            ��� �������������  ��������  ��������,   �������  ��������  ������  ���������  ������� 
                 dLRMA.TempBuffer[1][500] �   dLRMA.TEMPBUFFER[1][500].   ����������� �������� ����������� ��������� 3.
  dLRMA.series - �������  ��������, �� �������� ������������ ������ ������� LRMASeries();
  nLRMA.bar    - ����� ��������������� ����,  ��������  ������  ���������� ���������� ����� �� ������������� �������� � 
                 ��������.   ������ ��� ������������ �������� ������ ������ ��������� �������� ��������� nLRMA.limit!!!

  +------------------------------------+ <<< �������� ��������� >>> +-------------------------------------------------+

  LRMASeries() - �������� ������� dLRMA.ret_val.       ��� ���������  nLRMA.bar  ������  ���  nLRMA.MaxBar-nLRMA.Length 
                 ������� LRMASeries() ������ ���������� ����!!!
  nLRMA.reset  - ��������, ������������ �� ������ ��������, ���������� �� 0 ,  ���� ��������� ������ � ������� �������,
                 0, ���� ������ ������ ���������. ���� �������� ����� ���� ������ ����������, �� �� ���������!!!

  +-----------------------------------+ <<< ������������� ������� >>> +-----------------------------------------------+

  �����  �����������  �  �������  LRMASeries()  ,  �����  ����������  ���  ������������ ����� ����� 0, ������� ������ �
  ����������������  ����������  ����������  �������,  ���  �����  ����������  ����������  �  ������� LRMASeries() �����
  ���������������  ������� LRMASeriesResize() �� ���������� �����������: LRMASeriesResize(MaxLRMA.number+1); ����������
  ������� �������� nLRMA.n(MaxLRMA.number) ������ ���������� ��������� � ������� LRMASeries, �� ���� �� ������� ������,
  ��� ������������ nLRMA.n. 

  +--------------------------------------+ <<< ��������� ������ >>> +-------------------------------------------------+
  
  ��� ������� ����������� � ��������� �� ���� ����� ��������� ������, ��� ��������� ������ ������� ������� �������� ���
  ����.  ���  ������  ������� LRMASeries() ����� � ��� ���� � ����� \MetaTrader\EXPERTS\LOGS\. ����, ����� ���������� �
  �������  LRMASeries()  � ����, ������� ������������� �������, �������� MQL4 ������, �� ������� ������� � ��� ���� ���
  ������  �  ���������� ������. ���� ��� ���������� ������� LRMASeries()� ��������� LRMASeries() ��������� MQL4 ������,
  ��  �������  �����  �������  �  ���  ���� ��� ������ � ���������� ������. ��� ������������ ������� ������ ��������� �
  �������  LRMASeries()  nLRMA.number ��� �������� ����������� ������� �������� ���������� nJLRMAResize.Size � ��� ����
  ����� �������� ��������� � �������� ����������� ���� ����������. ����� � ��� ���� ������� ���������� ��� ������������
  �����������  ���������  nLRMA.limit.  ����  ���  ���������� ������� ������������� init() ��������� ���� ��� ���������
  ��������  ��������  ����������  �������  LRMASeries(),  �� ������� LRMASeriesResize() ������� � ��� ���� ���������� �
  ���������  ���������  ��������  ��������  ����������. ���� ��� ��������� � ������� LRMASeries()����� ������� ��������
  �����  ����  �������� ���������� ������������������ ��������� ��������� nLRMA.bar, �� � ��� ���� ����� �������� � ���
  ����������. ������� ������, ��� ��������� ������ ������������ ���� ����� ��������� ���������� ������ � ��� ����������
  �  �������,  ����  �������  LRMASeries()  �����  � ��� ���� ����� ��������� ������, �� ��������� �� ������� � �������
  �������  �������������.  � ��������� ���������� ���������� ������� LRMASeries() ����� ������ ������ � ��� ���� ������
  ���  ����������  ������ ������������ �������. ���������� ���������� ������ ��������� �������� �������� ���������� ���
  ������������ ���������� ��� ��������, ������� ���������� ��� ������ ������ ������� init(). 
  
  +---------------------------------+ <<< ������ ��������� � ������� >>> +--------------------------------------------+

//----+ ����������� ������� LRMASeries()
#include <LRMASeries.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE); 
//---- 1 ������������ ����� ����������� ��� ����� (��� ����� ��������� ������� LRMASeries() ���� ������ ����������� �� �����!!!)
SetIndexBuffer(0,Ind_Buffer);
//----+ ��������� �������� �������� ���������� ������� LRMASeries, nLRMA.n=1(���� ��������� � ������� LRMASeries)
if(LRMASeriesResize(1)==0)return(-1);
return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
int start()
{
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
int reset,bar,MaxBar,limit,counted_bars=IndicatorCounted(); 
//---- �������� �� ��������� ������
if (counted_bars<0)return(-1);
//---- ��������� ������������ ��� ������ ���� ����������
if (counted_bars>0) counted_bars--;
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
int limit=Bars-counted_bars-1;
MaxBar=Bars-1;
//----+ 
for(bar=limit;bar>=0;bar--)
 (
  double Series=Close[bar];
  //----+ ��������� � ������� LRMASeries()�� ������� 0 ��� ������� ������ Ind_Buffer[], 
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

//----++ <<< �������� � ������������� ���������� >>> 
double dLRMA.TempBuffer[1][501];
double dLRMA.TEMPBUFFER[1][501],dLRMA.den_x[1];
int nLRMA.range1, nLRMA.range2, nLRMA.rangeMin; 
int nLRMA.sum_x[1], nLRMA.sum_x2[1], nLRMA.TIME[1];
//----++
double dLRMA.sum_y, dLRMA.sum_xy, dLRMA.var_tmp;
double dLRMA.A, dLRMA.B, dLRMA.ret_val;
int    nLRMA.iii, nLRMA.loop_begin,nLRMA.Error;
int    nLRMA.Tnew,nLRMA.Told,nLRMA.n,nLRMA.Resize;

//----++ <<< ���������� ������� LRMASeries() >>> +---------------------------------------------------------------------------+

double LRMASeries
 (
  int nLRMA.number, int nLRMA.MaxBar, int nLRMA.limit, int nLRMA.period, double dLRMA.series, int nLRMA.bar, int& nLRMA.reset
 )
//----++---------------------------------------------------------------------------------------------------------------------+
{
nLRMA.n = nLRMA.number;

nLRMA.reset = 1;
//=====+ <<< �������� �� ������ >>> +--------------------------------------------------------------------+
if (nLRMA.bar == nLRMA.limit)
 {
  //----++ �������� �� ������������� ������� LRMASeries()
  if (nLRMA.Resize < 1)
   {
    Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
         ". �� ���� ������� ��������� �������� �������� ���������� �������� LRMASeriesResize()"));
    if(nLRMA.Resize == 0)
          Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
                ". ������� �������� ��������� � ������� LRMASeriesResize() � ���� �������������"));
         
    return(0.0);
   }
  //----++ �������� �� ������ � ���������� ������������ ����, ����������������� ������� LRMASeries()
  nLRMA.Error = GetLastError();
  if(nLRMA.Error > 4000)
   {
    Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
         ". � ����, �������������� ��������� � ������� LRMASeries() number = ", nLRMA.n, " ������!!!"));
    Print(StringConcatenate("LRMASeries() number = ", nLRMA.n, ". ", LRMA_ErrDescr(nLRMA.Error)));  
   } 
                                                   
  //----++ �������� �� ������ � ������� ���������� nLRMA.number � nLRMAResize.Number
  if (ArraySize(nLRMA.sum_x) < nLRMA.number) 
   {
    Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
                 ". ������!!! ����������� ������ �������� ���������� nLRMA.number ������� LRMASeries()"));
    Print(StringConcatenate("LRMASeries() number = ", nLRMA.n,
            ". ��� ����������� ������ ��������  ���������� nLRMAResize.Size ������� LRMASeriesResize()"));
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

//----++ <<< ������ �������������  >>> +-------------------------+
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

//----++ �������� �� ������ � ������������������ ��������� ���������� nLRMA.bar
if (nLRMA.limit >= nLRMA.MaxBar)
 if (nLRMA.bar == 0)
  if (nLRMA.MaxBar > nLRMA.period)
   if (nLRMA.TIME[nLRMA.n] == 0)
                        Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
                        ". ������!!! �������� ���������� ������������������ ��������� ",
                                             "��������� nLRMA.bar ������� ���������� �����!!!"));  

//----+ <<< �������������� �������� ���������� >>> +-----------------------------------------------------+
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
   //--+ �������� �� ������
   if(nLRMA.Tnew != nLRMA.Told)
    {
     nLRMA.reset = -1;
     //--+ ��������� ������ � ������� �������� ��������� nLRMA.limit ������� LRMASeries()
     if (nLRMA.Tnew > nLRMA.Told)
       {
       Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
                   ". ������!!! �������� nLRMA.limit ������� LRMASeries() ������, ��� ����������"));
       }
     else 
       { 
       int nLRMA.LimitERROR = nLRMA.limit + 1 - iBarShift(NULL, 0, nLRMA.Told, TRUE);
       Print(StringConcatenate("LRMASeries number = ", nLRMA.n,
               ". ������!!! �������� nLRMA.limit ������� LRMASeries() ������, ��� ���������� �� ",
                                                                                     nLRMA.LimitERROR));
       }
     //--+ ������� ����� nLRMA.reset=-1; ������ � ������� ������� LRMASeries
     return(0);
    } 
  }                    
//----++--------------------------------------------------------------------------------------------------+

//+--- ���������� �������� ���������� +--------------------------------+
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
 //----++ �������� �� ������ � ���������� ������������ ���� ������� JLRMASeries()
 nLRMA.Error = GetLastError();
 if(nLRMA.Error > 4000)
   {
    Print(StringConcatenate("LRMASeries number = ",
                nLRMA.n, ". ��� ���������� ������� LRMASeries() ��������� ������!!!"));
                
    Print(StringConcatenate
                  ("LRMASeries number = ", nLRMA.n, ". ", LRMA_ErrDescr(nLRMA.Error)));   
    return(0.0);
   }
  nLRMA.reset = 0;
  return(dLRMA.ret_val);
  
//----+  ���������� ���������� ������� LRMASeries() --------------------------+  
}
//+X==============================================================================================X+
// LRMASeriesResize - ��� �������������� ������� ��� ��������� �������� �������� ����������       | 
// ������� LRMASeries. ������ ���������: LRMASeriesResize(5); ��� 5 - ��� ���������� ��������� �  | 
// LRMASeries()� ������ ����������. ��� ��������� � �������  LRMASeriesResize ������� ���������   |
// � ���� ������������� ����������������� ���������� ��� ��������                                 |
//+X==============================================================================================X+
int LRMASeriesResize(int nLRMAResize.Size)
 {
//----+
  if (nLRMAResize.Size < 1)
   {
    Print("LRMASeriesResize: ������!!! �������� nLRMAResize.Size �� ����� ���� ������ �������!!!"); 
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
    //----++ <<< ��������� �������� �������� ���������� >>>  +-----------------------------+
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
        ("LRMASeriesResize: ������!!! �� ������� ",
             "�������� ������� �������� ���������� ������� LRMASeries()."));
             
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
LRMASeriesAlert - ��� �������������� ������� ��� ��������� ������ � ������� ������� ����������           |
������� LRMASeries.                                                                                      |
  -------------------------- ������� ���������  --------------------------                               |
LRMASeriesAlert.Number                                                                                   |
LRMASeriesAlert.ExternVar �������� ������� ���������� ��� ��������� nLRMA.Phase                          |
LRMASeriesAlert.name ��� ������� ���������� ��� ��������� nLRMA.Length, ���� LRMASeriesAlert.Number=0.   |                                                  
  -------------------------- ������ �������������  -----------------------                               |
  int init()                                                                                             |
//----                                                                                                   |
����� �����-������ ������������� ���������� � �������                                                    |
                                                                                                         |
//---- ��������� ������� �� ������������ �������� ������� ����������                                     |                                                           
LRMASeriesAlert(0,"Length1",Length1);                                                                    |
LRMASeriesAlert(0,"Length2",Length2);                                                                    |
//---- ���������� �������������                                                                          |
return(0);                                                                                               |
}                                                                                                        |
//+X====================================================================================================X+
*/
void LRMASeriesAlert
 (
  int LRMASeriesAlert.Number, string LRMASeriesAlert.name, int LRMASeriesAlert.ExternVar
 )
 {
  //---- ��������� ������� �� ������������ �������� ������� ���������� 
   if (LRMASeriesAlert.Number == 0)
     if (LRMASeriesAlert.ExternVar < 3)
          Alert(StringConcatenate("�������� ", LRMASeriesAlert.ExternVar, " ������ ���� �� ����� 3", 
                            " �� ����� ������������ " ,LRMASeriesAlert.ExternVar," ����� ������������  3"));
                            
   int LRMASeriesAlert.MaxPeriod = ArrayRange(dLRMA.TempBuffer, 1);  
   if (LRMASeriesAlert.Number == 0)
     if (LRMASeriesAlert.ExternVar > LRMASeriesAlert.MaxPeriod)
      Alert(StringConcatenate
               ("�������� ",LRMASeriesAlert.name," ������ ���� �� ����� ",
                           LRMASeriesAlert.MaxPeriod, " �� ����� ������������ ",
                                   LRMASeriesAlert.ExternVar," ����� ������������  ",
                                       LRMASeriesAlert.MaxPeriod, " ���� ���������� ������� ",
                                         "�������� ��������� nLRMA.period, �������� ������ ��������� �������",
                                                        " dLRMA.TempBuffer � dLRMA.TEMPBUFFER ������� LRMASeries"));
          
 }
// ������� ������ �������� ��������� 01.12.2006  
//+X================================================================X+
//|                                      LRMA_ErrDescr_RUS(MQL4).mqh |
//|                      Copyright � 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+X================================================================X+
string LRMA_ErrDescr(int error_code)
 {
  string error_string;
//----
  switch(error_code)
    {
     //---- MQL4 ������ 
     case 4000: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ������");                                                  break;
     case 4001: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ��������� �������");                              break;
     case 4002: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ������� �� ������������� ��� �������");                 break;
     case 4003: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ������ ��� ����� �������");                                break;
     case 4004: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ����� ����� ������������ ������");                break;
     case 4005: error_string = StringConcatenate("��� ������ = ",error_code,". �� ����� ��� ������ ��� �������� ����������");                 break;
     case 4006: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ������ ��� ���������� ���������");                         break;
     case 4007: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ������ ��� ��������� ������");                             break;
     case 4008: error_string = StringConcatenate("��� ������ = ",error_code,". �������������������� ������");                                 break;
     case 4009: error_string = StringConcatenate("��� ������ = ",error_code,". �������������������� ������ � �������");                       break;
     case 4010: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ������ ��� ���������� �������");                           break;
     case 4011: error_string = StringConcatenate("��� ������ = ",error_code,". ������� ������� ������");                                      break;
     case 4012: error_string = StringConcatenate("��� ������ = ",error_code,". ������� �� ������� �� ����");                                  break;
     case 4013: error_string = StringConcatenate("��� ������ = ",error_code,". ������� �� ����");                                             break;
     case 4014: error_string = StringConcatenate("��� ������ = ",error_code,". ����������� �������");                                         break;
     case 4015: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ������� (never generated error)");                break;
     case 4016: error_string = StringConcatenate("��� ������ = ",error_code,". �������������������� ������");                                 break;
     case 4017: error_string = StringConcatenate("��� ������ = ",error_code,". ������ DLL �� ���������");                                     break;
     case 4018: error_string = StringConcatenate("��� ������ = ",error_code,". ���������� ��������� ����������");                             break;
     case 4019: error_string = StringConcatenate("��� ������ = ",error_code,". ���������� ������� �������");                                  break;
     case 4020: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ������� ������������ ������� �� ���������");            break;
     case 4021: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ������ ��� ������, ������������ �� �������");     break;
     case 4022: error_string = StringConcatenate("��� ������ = ",error_code,". ������� ������ (never generated error)");                      break;
     case 4050: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ���������� ���������� �������");                  break;
     case 4051: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ �������� ��������� �������");                     break;
     case 4052: error_string = StringConcatenate("��� ������ = ",error_code,". ���������� ������ ��������� �������");                         break;
     case 4053: error_string = StringConcatenate("��� ������ = ",error_code,". ������ �������");                                              break;
     case 4054: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ������������� �������-���������");                break;
     case 4055: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ����������������� ����������");                         break;
     case 4056: error_string = StringConcatenate("��� ������ = ",error_code,". ������� ������������");                                        break;
     case 4057: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��������� ����������� ����������");                     break;
     case 4058: error_string = StringConcatenate("��� ������ = ",error_code,". ���������� ���������� �� ����������");                         break;
     case 4059: error_string = StringConcatenate("��� ������ = ",error_code,". ������� �� ��������� � �������� ������");                      break;
     case 4060: error_string = StringConcatenate("��� ������ = ",error_code,". ������� �� ������������");                                     break;
     case 4061: error_string = StringConcatenate("��� ������ = ",error_code,". ������ �������� �����");                                       break;
     case 4062: error_string = StringConcatenate("��� ������ = ",error_code,". ��������� �������� ���� string");                              break;
     case 4063: error_string = StringConcatenate("��� ������ = ",error_code,". ��������� �������� ���� integer");                             break;
     case 4064: error_string = StringConcatenate("��� ������ = ",error_code,". ��������� �������� ���� double");                              break;
     case 4065: error_string = StringConcatenate("��� ������ = ",error_code,". � �������� ��������� ��������� ������");                       break;
     case 4066: error_string = StringConcatenate("��� ������ = ",error_code,". ����������� ������������ ������ � ��������� ����������");      break;
     case 4067: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��� ���������� �������� ��������");                     break;
     case 4099: error_string = StringConcatenate("��� ������ = ",error_code,". ����� �����");                                                 break;
     case 4100: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��� ������ � ������");                                  break;
     case 4101: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ��� �����");                                      break;
     case 4102: error_string = StringConcatenate("��� ������ = ",error_code,". ������� ����� �������� ������");                               break;
     case 4103: error_string = StringConcatenate("��� ������ = ",error_code,". ���������� ������� ����");                                     break;
     case 4104: error_string = StringConcatenate("��� ������ = ",error_code,". ������������� ����� ������� � �����");                         break;
     case 4105: error_string = StringConcatenate("��� ������ = ",error_code,". �� ���� ����� �� ������");                                     break;
     case 4106: error_string = StringConcatenate("��� ������ = ",error_code,". ����������� ������");                                          break;
     case 4107: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ �������� ���� ��� �������� �������");             break;
     case 4108: error_string = StringConcatenate("��� ������ = ",error_code,". �������� ����� ������");                                       break;
     case 4109: error_string = StringConcatenate("��� ������ = ",error_code,". �������� �� ���������");                                       break;
     case 4110: error_string = StringConcatenate("��� ������ = ",error_code,". ������� ������� �� ���������");                                break;
     case 4111: error_string = StringConcatenate("��� ������ = ",error_code,". �������� ������� �� ���������");                               break;
     case 4200: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��� ����������");                                       break;
     case 4201: error_string = StringConcatenate("��� ������ = ",error_code,". ��������� ����������� �������� �������");                      break;
     case 4202: error_string = StringConcatenate("��� ������ = ",error_code,". ������ �� ����������");                                        break;
     case 4203: error_string = StringConcatenate("��� ������ = ",error_code,". ����������� ��� �������");                                     break;
     case 4204: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ����� �������");                                           break;
     case 4205: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��������� �������");                                    break;
     case 4206: error_string = StringConcatenate("��� ������ = ",error_code,". �� ������� ��������� �������");                                break;
     case 4207: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��� ������ � ��������");                                break;
     default:   error_string = StringConcatenate("��� ������ = ",error_code,". ����������� ������");
    }
//----
  return(error_string);
 }
//+------------------------------------------------------------------+


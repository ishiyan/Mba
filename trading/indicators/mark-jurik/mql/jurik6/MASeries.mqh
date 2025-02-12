//Version  January 14, 2007 Final
//+X================================================================X+
//|                                                   MASeries().mqh |
//|                MQL4 MASeries()Copyright � 2006, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+
  /*

  +---------------------------------------- <<< ������� MASeries() >>> -----------------------------------------------+

  +-----------------------------------------+ <<< ���������� >>> +----------------------------------------------------+

  �������  MASeries()  �������������  ���  �������������  ���������� �������� ���������� � �������, ����� � ����������
  �����  �������������,  ���  ������������  �����������  �����������  ����������,  ���������� � �����������. ������� ��
  ��������,  ����  ��������  MA.limit  ���������  ��������, ������ ����! ��� ����������, ��������� ���� ��� MASeries(),
  ���������  �  ������  �����  �����������.  ����  �������  �������� � ����� (����������): MetaTrader\experts\include\.
  �������  ������,  ���  ���� nMA.bar ������, ��� nMA.MaxBar, �� ������� MASeries() ���������� �������� ������ ����! ��
  ����  ����!  �,  �������������,  �����  ��������  ��  �����  ��������������  � ����������� �����-���� ����� � �������
  ����������! ��� ������ ������� MASeries() ������������ ��������� ��� � ������������� � ���������������� �����������,
  �  �������  ����������  �������.  ���  ������  �������  MASeries() ������������ ��������� ��� � ������������� � ����
  ����������, ������� ��������� ������� � ��� �������� � ����������� ���� ���������� �����! ��� ��������� ����������� �
  ���������  �  ��������������  ������� MASeries(), �� ������������� ���������� ������ ����� ������������ � nMA.... ���
  dMA....  �������  MASeries()  ����� ���� ������������ �� ���������� ���� ������ ���������������� �������, �� ��� ����
  �������  ��������� ��� ����, ��� � ������ ��������� � ����� ���������������� ������� � ������� ��������� � MASeries()
  ������ ���� ���� ���������� ����� (nMA.number). 

  +-------------------------------------+ <<< ������� ��������� >>> +-------------------------------------------------+

  nMA.n      -   ���������� ����� ��������� � ������� MASeries(). (0, 1, 2, 3 �.�.�....)
  nMA.MaxBar -   ������������ ��������,  ������� �����  ��������� �����  ��������������� ���� (nMA.bar).   ������ ����� 
                 Bars-1-period;   ��� "period" -  ��� ���������� �����,   �� �������  �������� ��������  dMA.series  �� 
                 ��������������; 
  nMA.limit  -   ���������� ��� �� ������������ ����� ���� ���� ��� ����� ���������� �������������� ����.   ������ ���� 
                 ����������� �����  Bars-IndicatorCounted()-1;
  nMA.Period -   ������ �����������. �������� �� �������� �� ������ ����!    ����������� �������� ����������� ��������� 
                 500.            ��� �������������  ��������  ��������,   �������  ��������  ������  ���������  ������� 
                 dMA.TempBuffer[1][500] �   dMA.TEMPBUFFER[1][500].       ����������� �������� ����������� ��������� 3.
  dMA.series -   �������  ��������, �� �������� ������������ ������ ������� MASeries();
  nMA.bar    -   ����� ��������������� ����,  ��������  ������  ���������� ���������� ����� �� ������������� �������� � 
                 ��������.   ������ ��� ������������ �������� ������ ������ ��������� �������� ��������� nMA.limit!!!

  +------------------------------------+ <<< �������� ��������� >>> +-------------------------------------------------+

  MASeries() - �������� ������� MASeries. ��� ���������  nMA.bar  ������  ���  nMA.MaxBar-nMA.Length ������� MASeries()
               ������ ���������� ����!!!
  nMA.reset  - ��������, ������������ �� ������ ��������, ���������� �� 0 ,  ����  ��������� ������  � ������� �������,
               0, ���� ������ ������ ���������. ���� �������� ����� ���� ������ ����������, �� �� ���������!!!

  +-----------------------------------+ <<< ������������� ������� >>> +-----------------------------------------------+

  �����  �����������  �  �������  MASeries()  ,  �����  ����������  ���  ������������  �����  ����� 0, ������� ������ �
  ����������������  ����������  ����������  �������,  ���  �����  ����������  ����������  �  �������  MASeries()  �����
  ���������������  �������  MASeriesResize()  ��  ����������  �����������:  MASeriesResize(MaxMA.number+1);  ����������
  �������  ��������  nMA.n(MaxMA.number) ������ ���������� ��������� � ������� MASeries, �� ���� �� ������� ������, ���
  ������������ nMA.n.

  +--------------------------------------+ <<< ��������� ������ >>> +-------------------------------------------------+
  
  ��� ������� ����������� � ��������� �� ���� ����� ��������� ������, ��� ��������� ������ ������� ������� �������� ���
  ����.  ���  ������  �������  MASeries()  ����� � ��� ���� � ����� \MetaTrader\EXPERTS\LOGS\. ����, ����� ���������� �
  �������  MASeries()  �  ����,  ������� ������������� �������, �������� MQL4 ������, �� ������� ������� � ��� ���� ���
  ������  �  ����������  ������. ���� ��� ���������� ������� MASeries()� ��������� MASeries() ��������� MQL4 ������, ��
  �������  ����� ������� � ��� ���� ��� ������ � ���������� ������. ��� ������������ ������� ������ ��������� � �������
  MASeries()  nMA.number ��� �������� ����������� ������� �������� ���������� nJMAResize.Size � ��� ���� ����� ��������
  ���������  �  ��������  ����������� ���� ����������. ����� � ��� ���� ������� ���������� ��� ������������ �����������
  ���������  nMA.limit. ���� ��� ���������� ������� ������������� init() ��������� ���� ��� ��������� �������� ��������
  ����������  �������  MASeries(),  ��  �������  MASeriesResize()  �������  � ��� ���� ���������� � ��������� ���������
  ��������  ��������  ����������.  ����  ���  ���������  � ������� MASeries()����� ������� �������� ����� ���� ��������
  ����������  ������������������  ���������  ���������  nMA.bar, �� � ��� ���� ����� �������� � ��� ����������. �������
  ������,  ���  ���������  ������  ������������ ���� ����� ��������� ���������� ������ � ��� ���������� � �������, ����
  �������  MASeries() ����� � ��� ���� ����� ��������� ������, �� ��������� �� ������� � ������� ������� �������������.
  �  ���������  ����������  ����������  �������  MASeries() ����� ������ ������ � ��� ���� ������ ��� ���������� ������
  ������������ �������. ���������� ���������� ������ ��������� �������� �������� ���������� ��� ������������ ����������
  ��� ��������, ������� ���������� ��� ������ ������ ������� init(). 
  
  +---------------------------------+ <<< ������ ��������� � ������� >>> +--------------------------------------------+

//----+ ����������� ������� MASeries()
#include <MASeries.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE); 
//---- 1 ������������ ����� ����������� ��� ����� (��� ����� ��������� ������� MASeries() ���� ������ ����������� �� �����!!!)
SetIndexBuffer(0,Ind_Buffer);
//----+ ��������� �������� �������� ���������� ������� MASeries, nMA.n=1(���� ��������� � ������� MASeries)
if(MASeriesResize(1)==0)return(-1);
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
  //----+ ��������� � ������� MASeries()�� ������� 0 ��� ������� ������ Ind_Buffer[], 
  double Resalt=MASeries(0,1,MaxBar,limit,Length,Series,bar,reset);
  if (reset!=0)return(-1);
  Ind_Buffer[bar]=Resalt;
 }
return(0);
}
//----+ 

*/
//+X================================================================X+
//|  MASeries() function                                             |
//+X================================================================X+   
//----++ <<< �������� � ������������� ���������� >>> +--------------------------+ 
double dMA.sum[1], dMA.SUM[1], dMA.TEMPBUFFER[1][501], dMA.TempBuffer[1][501];
double dMA.MA[1], dMA.MA1[1], dMA.pr[1], dMA.lsum[1], dMA.LSUM[1];
//----++
int    nMA.range1, nMA.range2, nMA.rangeMin, nMA.weight[1], nMA.iii; 
int    nMA.TIME[1], nMA.Error, nMA.Tnew, nMA.Told, nMA.n, nMA.Resize, nMA.cycle;
//----++ +----------------------------------------------------------------------+

   
//----++ <<< ���������� ������� MASeries() >>> +----------------------------------------------------------------------------------+

double MASeries
 (
  int nMA.number, int nMA.MA_Method, int nMA.MaxBar, int nMA.limit, int nMA.period, double dMA.series, int nMA.bar, int& nMA.reset
 )
//----++--------------------------------------------------------------------------------------------------------------------------+
{
nMA.n = nMA.number;

nMA.reset = 1;
//=====+ <<< �������� �� ������ >>> -------------------------------------------------------------------+
if (nMA.bar == nMA.limit)
 {
  //----++ �������� �� ������������� ������� MASeries()
  if (nMA.Resize < 1)
   {
    Print(StringConcatenate("MASeries number = ", nMA.n,
         ". �� ���� ������� ��������� �������� �������� ���������� �������� MASeriesResize()"));
    if (nMA.Resize == 0)
          Print(StringConcatenate("MASeries number = ", nMA.n,
                ". ������� �������� ��������� � ������� MASeriesResize() � ���� �������������"));
         
    return(0.0);
   }
  //----++ �������� �� ������ � ���������� ������������ ����, ����������������� ������� MASeries()
  nMA.Error = GetLastError();
  if(nMA.Error > 4000)
   {
    Print(StringConcatenate("MASeries number = ", nMA.n,
         ". � ����, �������������� ��������� � ������� MASeries() number = "+nMA.n+" ������!!!"));
    Print(StringConcatenate("MASeries() number = ", nMA.n, ". ",MA_ErrDescr(nMA.Error)));  
   } 
                                                   
  //----++ �������� �� ������ � ������� ���������� nMA.number � nMAResize.Number
  if (ArraySize(nMA.TIME) < nMA.number) 
   {
    Print(StringConcatenate("MASeries number = ", nMA.n,
               ". ������!!! ����������� ������ �������� ���������� nMA.number ������� MASeries()"));
    Print(StringConcatenate("MASeries() number = ", nMA.n,
            ". ��� ����������� ������ ��������  ���������� nMAResize.Size ������� MASeriesResize()"));
    return(0.0);
   }
 }
//----++ +----------------------------------------------------------------------------------------------+ 
  
if (nMA.bar > nMA.MaxBar){nMA.reset = 0; return(0.0);}
//----++ 
if (nMA.MA_Method != 1)
           if (nMA.bar != nMA.limit)
                     for(nMA.iii = nMA.period; nMA.iii >= 0; nMA.iii--)
                                           dMA.TempBuffer[nMA.n][nMA.iii + 1]=
                                                             dMA.TempBuffer[nMA.n][nMA.iii];
//----++                                                                                  
dMA.TempBuffer[nMA.n][0] = dMA.series;

//----++ �������� ������� ��������� nMA.period �� ������������ ---------------------------------------------------+ 
if (nMA.bar == nMA.MaxBar)
  {
    if(nMA.period <3 )
          Print(StringConcatenate
                  ("MASeries number = ", nMA.n, ". �������� nMA.period ������ ���� �� ����� 3",
                                       " �� ����� ������������ ", nMA.period,  " ����� ������������  3"));  
    if (nMA.period > nMA.rangeMin)
       {
         Print(StringConcatenate("�������� nMA.period ������ ���� �� ����� ", nMA.rangeMin, ".", 
              " �� ����� ������������ ", nMA.period, " ����� ������������  ", nMA.rangeMin, "."));
             Print(StringConcatenate
                   (" ���� ���������� ������� �������� ��������� nMA.period, �������� ������ ��������� �������",
                                                           " dMA.TempBuffer � dMA.TEMPBUFFER ������� MASeries()"));
       }
    if (nMA.MA_Method < 0 || nMA.MA_Method > 3)
          Alert(StringConcatenate("�������� nMA.MA_Method ������ ���� �� 0 �� 3", 
                               " �� ����� ������������ ", nMA.MA_Method, " ����� ������������ 0"));
       
  }
if (nMA.MA_Method < 0) nMA.MA_Method = 0;
else if (nMA.MA_Method > 3) nMA.MA_Method = 0;
if (nMA.period < 3)nMA.period = 3;
else if (nMA.period > nMA.rangeMin)nMA.period = nMA.rangeMin;
//----++ +---------------------------------------------------------------------------------------------------------+ 

//----++ <<< ������ �������������  >>> +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
switch(nMA.MA_Method)
 {
  //----++ <<< ������������� SMA >>> +---------------------------------------+
  case 0 : if (nMA.bar == nMA.MaxBar - nMA.period)
              for(nMA.iii = 1; nMA.iii < nMA.period; nMA.iii++)
                  dMA.sum[nMA.n] += dMA.TempBuffer[nMA.n][nMA.iii];
           else
            if (nMA.bar > nMA.MaxBar - nMA.period)
                               {nMA.reset = 0; return(0.0);}
           break;                
  //----++ <<< ������������� EMA >>> +---------------------------------------+
  case 1 : if (nMA.bar == nMA.MaxBar)dMA.pr[nMA.n] = 2.0 / (nMA.period + 1.0);
           else
            if (nMA.bar > nMA.MaxBar){nMA.reset = 0; return(0.0);}
           break;                
  //----++ <<< ������������� SSMA >>> +--------------------------------------+
  case 2 : if (nMA.bar == nMA.MaxBar - nMA.period + 1)
              for(nMA.iii = 0; nMA.iii < nMA.period; nMA.iii++)
                  dMA.sum[nMA.n] += dMA.TempBuffer[nMA.n][nMA.iii];
           else
            if (nMA.bar > nMA.MaxBar - nMA.period + 1)
                                        {nMA.reset = 0; return(0.0);}
           break;                
  //----++ <<< ������������� LWMA >>> +--------------------------------------+ 
  case 3 : if (nMA.bar == nMA.MaxBar - nMA.period)
              {    
               int nMA.kkk = nMA.period;
               for(nMA.iii = 1; nMA.iii <= nMA.period; nMA.iii++, nMA.kkk--)
                {
                 dMA.sum[nMA.n] += dMA.TempBuffer[nMA.n][nMA.kkk] * nMA.iii;
                 dMA.lsum[nMA.n] += dMA.TempBuffer[nMA.n][nMA.kkk];
                 nMA.weight[nMA.n] += nMA.iii;
                }
              }
           else
            if (nMA.bar > nMA.MaxBar - nMA.period)
                                   {nMA.reset = 0; return(0.0);}
           break;
  //----++ <<< ������������� SMA >>> +---------------------------------------+
  default : if (nMA.bar == nMA.MaxBar - nMA.period)
                for(nMA.iii = 1; nMA.iii < nMA.period; nMA.iii++)
                    dMA.sum[nMA.n] += dMA.TempBuffer[nMA.n][nMA.iii]; 
            else
             if (nMA.bar > nMA.MaxBar - nMA.period)
                                    {nMA.reset = 0; return(0.0);}                             
  //----++ +-----------------------------------------------------------------+      
 } 
//----++ ---------------------------------------------------------------------+  


//----++ �������� �� ������ � ������������������ ��������� ���������� nMA.bar
if(nMA.limit >= nMA.MaxBar)
 if (nMA.bar == 0)
  if (nMA.MaxBar > nMA.period)
   if (nMA.TIME[nMA.n] == 0)
        Print(StringConcatenate("MASeries number = ", nMA.n,
                        ". ������!!! �������� ���������� ������������������",
                                  "��������� ��������� nMA.bar ������� ���������� �����!!!"));  

//----+ <<< �������������� �������� ���������� >>> +-----------------------------------------------+
if (nMA.bar == nMA.limit)
 while(nMA.cycle == 0)
  {
   switch(nMA.MA_Method)
     {
      case 0 : if (nMA.bar == nMA.MaxBar-nMA.period  )   break;
      case 1 : if (nMA.bar == nMA.MaxBar)                break;
      case 2 : if (nMA.bar == nMA.MaxBar-nMA.period + 1) break;
      case 3 : if (nMA.bar == nMA.MaxBar-nMA.period  )   break;
      default: if (nMA.bar == nMA.MaxBar-nMA.period  )   break; 
     }
   nMA.Tnew = Time[nMA.limit + 1];
   nMA.Told = nMA.TIME[nMA.n];
   //--+
   if(nMA.Tnew == nMA.Told)
     {
       for(nMA.iii = nMA.period;nMA.iii >= 1; nMA.iii--)
                               dMA.TempBuffer[nMA.n][nMA.iii]=
                                               dMA.TEMPBUFFER[nMA.n][nMA.iii]; 
       //--+                                       
       if (nMA.MA_Method != 1)dMA.sum[nMA.n] = dMA.SUM[nMA.n];
       if (nMA.MA_Method == 1 || nMA.MA_Method == 2)dMA.MA[nMA.n] = dMA.MA1[nMA.n];
       if (nMA.MA_Method == 3)dMA.lsum[nMA.n] = dMA.LSUM[nMA.n];
     }
   //--+ �������� �� ������
   if(nMA.Tnew != nMA.Told)
    {
     nMA.reset = -1;
     //--+ ��������� ������ � ������� �������� ��������� nMA.limit ������� MASeries0()
     if (nMA.Tnew>nMA.Told)
       {
       Print(StringConcatenate("MASeries0 number = ", nMA.n,
                 ". ������!!! �������� nMA.limit ������� MASeries0() ������, ��� ����������"));
       }
     else 
       { 
       int nMA.LimitERROR = nMA.limit + 1 - iBarShift(NULL, 0, nMA.Told, TRUE);
       Print(StringConcatenate("MASeries0 number = ", nMA.n,
             ". ������!!! �������� nMA.limit ������� MASeries0() ������, ��� ���������� �� ",
                                                                           nMA.LimitERROR,"."));
       }
     //--+ ������� ����� nMA.reset=-1; ������ � ������� ������� MASeries0
     return(0);
    } 
  break;
  }                   
//----+-------------------------------------------------------------------------------------------+

//+--- ���������� �������� ���������� +-----------------------------+
if (nMA.bar == 1)
 if (nMA.limit != 1)
 {
   nMA.TIME[nMA.n] = Time[2];
   for(nMA.iii=nMA.period; nMA.iii >= 1; nMA.iii--)
                       dMA.TEMPBUFFER[nMA.n][nMA.iii] =
                                 dMA.TempBuffer[nMA.n][nMA.iii];  
   //+---+                                    
   if (nMA.MA_Method != 1)dMA.SUM[nMA.n] = dMA.sum[nMA.n]; 
   if (nMA.MA_Method == 1 || nMA.MA_Method == 2)
                            dMA.MA1[nMA.n] = dMA.MA[nMA.n];
   if (nMA.MA_Method == 3)dMA.LSUM[nMA.n] = dMA.lsum[nMA.n];  
 }
//+---+-------------------------------------------------------------+  

switch(nMA.MA_Method)
 {
//----++ <<< ���������� SMA >>> +---------------------------------------+
   case 0 :
    {
     dMA.sum[nMA.n] += dMA.series;
     dMA.MA[nMA.n] = dMA.sum[nMA.n] / nMA.period;
     dMA.sum[nMA.n] -= dMA.TempBuffer[nMA.n][nMA.period - 1];
    } 
   break;
//----++ <<< ���������� EMA >>> +---------------------------------------+
   case 1 :
    {
     if (nMA.bar != nMA.MaxBar)
          dMA.MA[nMA.n] = dMA.series * dMA.pr[nMA.n]
                                 + dMA.MA[nMA.n] * (1 - dMA.pr[nMA.n]);
     else dMA.MA[nMA.n] = dMA.series; 
    }
   break;
//----++ <<< ���������� SSMA >>> +--------------------------------------+
   case 2 :
    {  
     if(nMA.bar < nMA.MaxBar - nMA.period + 1)
           dMA.sum[nMA.n] = dMA.MA[nMA.n] * (nMA.period - 1) + dMA.series;
     dMA.MA[nMA.n] = dMA.sum[nMA.n] / nMA.period;     
    }
   break;
 
//----++ <<< ���������� LWMA >>> +--------------------------------------+
   case 3 :    
    {  
     dMA.sum[nMA.n] -= dMA.lsum[nMA.n] - dMA.series * nMA.period;
     dMA.lsum[nMA.n] += dMA.series - dMA.TempBuffer[nMA.n][nMA.period];
     dMA.MA[nMA.n] = dMA.sum[nMA.n] / nMA.weight[nMA.n]; 
    }
   break;
//----++ <<< ���������� SMA >>> +---------------------------------------+
   default :
    {
     dMA.sum[nMA.n] += dMA.series;
     dMA.MA[nMA.n] = dMA.sum[nMA.n] / nMA.period;
     dMA.sum[nMA.n] -= dMA.TempBuffer[nMA.n][nMA.period - 1];
    } 
//----++ +--------------------------------------------------------------+
 } 
//----++ �������� �� ������ � ���������� ������������ ���� ������� JMASeries()
 nMA.Error = GetLastError();
 if(nMA.Error > 4000)
   {
    Print(StringConcatenate("MASeries number = ",
        nMA.n, ". ��� ���������� ������� MASeries() ��������� ������!!!"));
    Print(StringConcatenate
               ("MASeries number = ", nMA.n, ". ",MA_ErrDescr(nMA.Error)));   
    return(0.0);
   }
  nMA.reset = 0;
  return(dMA.MA[nMA.n]);
  
//----+  ���������� ���������� ������� MASeries() --------------------------+  
}
//--+ --------------------------------------------------------------------------------------------+

//+X=============================================================================================X+
// MASeriesResize - ��� �������������� ������� ��� ��������� �������� �������� ����������         | 
// ������� MASeries. ������ ���������: MASeriesResize(5); ��� 5 - ��� ���������� ��������� �      | 
// MASeries()� ������ ����������. ��� ��������� � �������  MASeriesResize ������� ���������       |
// � ���� ������������� ����������������� ���������� ��� ��������                                 |
//+X=============================================================================================X+
int MASeriesResize(int nMAResize.Size)
 {
//----+
  if(nMAResize.Size<1)
   {
    Print("MASeriesResize: ������!!! �������� nMAResize.Size �� ����� ���� ������ �������!!!"); 
    nMA.Resize = -1; 
    return(0);
   }
  //----+    
  nMA.range1 = ArrayRange(dMA.TempBuffer, 1) - 1; 
  nMA.range2 = ArrayRange(dMA.TEMPBUFFER, 1) - 1;   
  nMA.rangeMin = MathMin(nMA.range1, nMA.range2);
  if(nMAResize.Size == -2)
              return(nMA.rangeMin);
  //----+  
  int nMAResize.reset, nMAResize.cycle;
  //--+
  while(nMAResize.cycle == 0)
   {
    //----++ <<< ��������� �������� �������� ���������� >>>  +-----------------------+
    if(ArrayResize(dMA.TempBuffer, nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.TEMPBUFFER, nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.lsum,       nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.LSUM,       nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.sum,        nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.SUM,        nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.MA,         nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.MA1,        nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(dMA.pr,         nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(nMA.TIME,       nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    if(ArrayResize(nMA.weight,     nMAResize.Size) == 0){nMAResize.reset =- 1; break;}
    //----++-------------------------------------------------------------------------+
    nMAResize.cycle = 1;
   }
  //--+
  if(nMAResize.reset == -1)
   {
    Print("MASeriesResize: ������!!! �� ������� �������� ������� �������� ���������� ������� MASeries().");
    int nMAResize.Error = GetLastError();
    if(nMAResize.Error > 4000)
                Print(StringConcatenate("MASeriesResize: ", MA_ErrDescr(nMAResize.Error)));    
    nMA.Resize = -2;
    return(0);
   }
  else  
   {
    Print(StringConcatenate("MASeriesResize: MASeries Size = ", nMAResize.Size, "."));
    nMA.Resize = nMAResize.Size;
    return(nMAResize.Size);
   }  
//----+
 }
//--+ --------------------------------------------------------------------------------------------+
/*
//+X====================================================================================================X+
MASeriesAlert - ��� �������������� ������� ��� ��������� ������ � ������� ������� ����������             |
������� MASeries.                                                                                        |
  -------------------------- ������� ���������  --------------------------                               |
MASeriesAlert.Number                                                                                     |
MASeriesAlert.ExternVar �������� ������� ����������                                                      |
MASeriesAlert.name ��� ������� ���������� ��� ��������� nMA1.period, ���� MASeriesAlert.Number=0,        | 
��� ��������� nMA1.MA_Method, ���� MASeriesAlert.Number=1.                                               | 
                                                                                                         |                                         
  -------------------------- ������ �������������  -----------------------                               |
  int init()                                                                                             | 
{                                                                                                        |
//----                                                                                                   |
����� �����-������ ������������� ���������� � �������                                                    |
                                                                                                         |
//---- ��������� ������� �� ������������ �������� ������� ����������                                     |                                                           
MASeriesAlert(0,"period1",period1);                                                                      |
MASeriesAlert(0,"period2",period2);                                                                      |
MASeriesAlert(1,"MA_Method1",MA_Method1);                                                                |
MASeriesAlert(1,"MA_Method2",MA_Method2);                                                                |
//---- ���������� �������������                                                                          |
return(0);                                                                                               |
}                                                                                                        |
//+X====================================================================================================X+
*/
void MASeriesAlert
  (int MASeriesAlert.Number, string MASeriesAlert.name, int MASeriesAlert.ExternVar)
 {
  //---- ��������� ������� �� ������������ �������� ������� ���������� 
   if (MASeriesAlert.Number == 0)
      if (MASeriesAlert.ExternVar < 3)
          Alert(StringConcatenate("�������� ", MASeriesAlert.ExternVar, " ������ ���� �� ����� 3", 
                                 " �� ����� ������������ ", MASeriesAlert.ExternVar, " ����� ������������  3"));
   int MASeriesAlert.MaxPeriod = ArrayRange(dMA.TempBuffer, 1);  
   if (MASeriesAlert.Number == 0)
    if (MASeriesAlert.ExternVar > MASeriesAlert.MaxPeriod)
          Alert(StringConcatenate("�������� ", MASeriesAlert.name, " ������ ���� �� ����� ",
                  MASeriesAlert.MaxPeriod, ".", " �� ����� ������������ ", MASeriesAlert.ExternVar,
                                                   " ����� ������������  ", MASeriesAlert.MaxPeriod, ".",
                                                               " ���� ���������� ������� �������� ���������", 
                                                                " nMA.period, �������� ������ ��������� �������",
                                                                 " dMA.TempBuffer � dMA.TEMPBUFFER ������� MASeries" ));
          
 }
//--+ ----------------------------------------------------------------------------------------------------------------+

// ������� ������ �������� ��������� 01.12.2006  
//+X================================================================X+
//|                                        MA_ErrDescr_RUS(MQL4).mqh |
//|                      Copyright � 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+X================================================================X+
string MA_ErrDescr(int error_code)
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



//Version  January 7, 2007 Final
//+X================================================================X+
//|                                                ParMASeries().mqh |
//|          Parabolic approximation code: Copyright � 2005, alexjou |
//|        MQL4 ParMASeries() Copyright � 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+ 
  /*
  
  ---------------------------------------- <<< ������� ParMASeries() >>> ----------------------------------------------

  +-----------------------------------------+ <<< ���������� >>> +----------------------------------------------------+

  �������  ParMASeries()  �������������  ���  �������������  ���������  �������������� ������������ ��� ��������� �����
  �����������  ����������  �  ���������,  ���  ������  �������  �������������  ����������  �� ���� ��������. ������� ��
  ��������,   ����   ��������  ParMA.limit  ���������  ��������,  ������  ����!  ���  ����������,  ���������  ����  ���
  ParMASeries(),   ���������   �   ������   �����   �����������.   ����   �������   ��������   �   �����  (����������):
  MetaTrader\experts\include\.   �������   ������,   ���   ����   nParMA.bar  ������,  ���  nParMA.MaxBar,  ��  �������
  ParMASeries()����������  �������� ������ ����! �� ���� ����! �, �������������, ����� �������� �� ����� ��������������
  �  �����������  �����-���� ����� � ������� ����������! ��� ������ ������� ParMASeries() ������������ ��������� ��� �
  �������������  �  ����������������  �����������,  �  �������  ����������  �������.  ���  ������ ������� ParMASeries()
  ������������ ��������� ��� � ������������� � ���� ����������, ������� ��������� ������� � ��� �������� � �����������
  ���� ���������� �����! ��� ��������� ����������� � ��������� � �������������� ������� ParMASeries(), �� �������������
  ����������  ������  �����  ������������  � nParMA.... ��� dParMA.... ������� ParMASeries() ����� ���� ������������ ��
  ����������  ����  ������  ����������������  �������, �� ��� ���� ������� ��������� ��� ����, ��� � ������ ��������� �
  ����� ���������������� ������� � ������� ��������� � ParMASeries() ������ ���� ���� ���������� ����� (nParMA.number).

  +-------------------------------------+ <<< ������� ��������� >>> +-------------------------------------------------+

  nParMA.n      - ���������� ����� ��������� � ������� ParMASeries(). (0, 1, 2, 3 �.�.�....)
  nParMA.MaxBar - ������������ ��������, ������� �����  ��������� ����� ��������������� ���� (nParMA.bar). ������ ����� 
                  Bars-1-period; ��� "period" -  ��� ���������� �����,  �� �������  �������� �������� dParMA.series  �� 
                  ��������������; 
  nParMA.limit  - ���������� ��� �� ������������ ����� ���� ���� ��� ����� ���������� �������������� ����,  ������ ���� 
                  ����������� �����  Bars-IndicatorCounted()-1;
  nParMA.Period - ������ �����������. �������� �� �������� �� ������ ����!   ����������� �������� ����������� ��������� 
                  500.           ��� �������������  ��������  ��������,   �������  ��������  ������  ���������  ������� 
                  dParMA.TempBuffer[1][500] �  dParMA.TEMPBUFFER[1][500]. ����������� �������� ����������� ��������� 3.
  dParMA.series - �������  ��������, �� �������� ������������ ������ ������� ParMASeries();
  nParMA.bar    - ����� ��������������� ����,  ��������  ������ ���������� ���������� ����� �� ������������� �������� � 
                  ��������. ������ ��� ������������ �������� ������ ������ ��������� �������� ��������� nParMA.limit!!!

  +------------------------------------+ <<< �������� ��������� >>> +-------------------------------------------------+

  ParMASeries() - �������� ������� dParMA.ret_val.  ��� ���������  nParMA.bar  ������  ���  nParMA.MaxBar-nParMA.Length 
                  ������� ParMASeries() ������ ���������� ����!!!
  nParMA.reset  - ��������, ������������ �� ������ ��������, ���������� �� 0 , ���� ��������� ������ � ������� �������,
                  0, ���� ������ ������ ���������. ���� �������� ����� ���� ������ ����������, �� �� ���������!!!

  +-----------------------------------+ <<< ������������� ������� >>> +-----------------------------------------------+

  �����  �����������  �  �������  ParMASeries()  ,  �����  ����������  ��� ������������ ����� ����� 0, ������� ������ �
  ����������������  ����������  ����������  �������,  ���  �����  ����������  ����������  �  ������� ParMASeries()�����
  ���������������   �������   ParMASeriesResize()   ��  ����������  �����������:  ParMASeriesResize(MaxParMA.number+1);
  ���������� ������� �������� nParMA.n(MaxParMA.number) ������ ���������� ��������� � ������� ParMASeries(), �� ���� ��
  ������� ������, ��� ������������ nParMA.n. 
  
  +--------------------------------------+ <<< ��������� ������ >>> +-------------------------------------------------+
  
  ��� ������� ����������� � ��������� �� ���� ����� ��������� ������, ��� ��������� ������ ������� ������� �������� ���
  ����.  ���  ������ ������� ParMASeries() ����� � ��� ���� � ����� \MetaTrader\EXPERTS\LOGS\. ����, ����� ���������� �
  �������  ParMASeries() � ����, ������� ������������� �������, �������� MQL4 ������, �� ������� ������� � ��� ���� ���
  ������  �  ����������  ������.  ����  ���  ����������  ������� ParMASeries() � ��������� ParMASeries() ��������� MQL4
  ������, �� ������� ����� ������� � ��� ���� ��� ������ � ���������� ������. ��� ������������ ������� ������ ���������
  �  �������  ParMASeries() nParMA.number ��� �������� ����������� ������� �������� ���������� nJParMAResize.Size � ���
  ����  �����  ��������  ���������  �  ��������  �����������  ����  ����������. ����� � ��� ���� ������� ���������� ���
  ������������  ����������� ��������� nParMA.limit. ���� ��� ���������� ������� ������������� init() ��������� ���� ���
  ���������  ��������  ��������  ����������  �������  ParMASeries(),  �� ������� ParMASeriesResize() ������� � ��� ����
  ����������  �  ���������  ���������  ��������  ��������  ����������. ���� ��� ��������� � ������� ParMASeries() �����
  �������  ��������  �����  ����  ��������  ���������� ������������������ ��������� ��������� nParMA.bar, �� � ��� ����
  �����  ��������  �  ��� ����������. ������� ������, ��� ��������� ������ ������������ ���� ����� ��������� ����������
  ������  �  ��� ���������� � �������, ���� ������� ParMASeries() ����� � ��� ���� ����� ��������� ������, �� ���������
  ��  �������  �  �������  �������  �������������. � ��������� ���������� ���������� ������� ParMASeries() ����� ������
  ������  � ��� ���� ������ ��� ���������� ������ ������������ �������. ���������� ���������� ������ ��������� ��������
  �������� ���������� ��� ������������ ���������� ��� ��������, ������� ���������� ��� ������ ������ ������� init(). 
  +---------------------------------+ <<< ������ ��������� � ������� >>> +--------------------------------------------+

//----+ ����������� ������� ParMASeries()
#include <ParMASeries.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE); 
//---- 1 ������������ ����� ����������� ��� �����
SetIndexBuffer(0,Ind_Buffer);
//----+ ��������� �������� �������� ���������� ������� ParMASeries, nParMA.n=1(���� ��������� � ������� ParMASeries)
if(ParMASeriesResize(1)==0)return(-1);
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
//---- ��������� ������������ ��� ������ ���� ���������� (��� ����� ��������� ������� ParMASeries() ���� ������ ����������� �� �����!!!)
if (counted_bars>0) counted_bars--;
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
int limit=Bars-counted_bars-1;
MaxBar=Bars-1;
//----+ 
for(bar=limit;bar>=0;bar--)
 (
  double Series=Close[bar];
  //----+ ��������� � ������� ParMASeries()�� ������� 0 ��� ������� ������ Ind_Buffer[], 
  double Resalt=ParMASeries(0,MaxBar,limit,Length,Series,bar,reset);
  if (reset!=0)return(-1);
  Ind_Buffer[bar]=Resalt;
 }
return(0);
}
//----+ 
//+X================================================================X+
//|  ParMASeries() function                                          |
//+X================================================================X+   
*/
//----++ <<< �������� � ������������� ���������� >>> +--------------+ 
double dParMA.TempBuffer[1][501], dParMA.TEMPBUFFER[1][501];
int nParMA.range1, nParMA.range2, nParMA.rangeMin; 
int nParMA.sum_x [1], nParMA.sum_x2[1], nParMA.sum_x3[1];
int nParMA.sum_x4[1], nParMA.TIME[1];
//----++
double dParMA.sum_y, dParMA.sum_xy, dParMA.sum_x2y, dParMA.var_tmp;
double dParMA.A, dParMA.B, dParMA.C, dParMA.D, dParMA.E, dParMA.F; 
double dParMA.K, dParMA.L, dParMA.M, dParMA.P, dParMA.Q, dParMA.R; 
double dParMA.S, dParMA.B0, dParMA.B1, dParMA.B2, dParMA.ret_val;
int    nParMA.iii, nParMA.loop_begin,nParMA.Error,nParMA.Tnew;
int    nParMA.Told,nParMA.n,nParMA.Resize; 
//----++------------------------------------------------------------+
//----++ <<< ���������� ������� ParMASeries() >>> +----------------------------------------------------------------------------------+
double ParMASeries
 (
  int nParMA.number, int nParMA.MaxBar, int nParMA.limit, int nParMA.period, double dParMA.series, int nParMA.bar, int& nParMA.reset
  )
//----++-----------------------------------------------------------------------------------------------------------------------------+
 
{
nParMA.n = nParMA.number;

nParMA.reset = 1;
//----++ <<< �������� �� ������ >>> ----------------------------------------------------------------------+
if (nParMA.bar == nParMA.limit)
 {
  //----++ �������� �� ������������� ������� ParMASeries()
  if(nParMA.Resize < 1)
   {
    Print(StringConcatenate("ParMASeries number = ",nParMA.n,
         ". �� ���� ������� ��������� �������� �������� ���������� �������� ParMASeriesResize()"));
    if(nParMA.Resize == 0)
       Print(StringConcatenate("ParMASeries number = ",nParMA.n,
                ". ������� �������� ��������� � ������� ParMASeriesResize() � ���� �������������"));
         
    return(0.0);
   }
  //----++ �������� �� ������ � ���������� ������������ ����, ����������������� ������� ParMASeries()
  nParMA.Error = GetLastError();
  if(nParMA.Error > 4000)
   {
    Print(StringConcatenate("ParMASeries number = ",nParMA.n,
         ". � ����, �������������� ��������� � ������� ParMASeries() number = ",nParMA.n," ������!!!"));
    Print(StringConcatenate("ParMASeries number = ",nParMA.n, ". ",ParMA_ErrDescr(nParMA.Error)));  
   } 
                                                   
  //----++ �������� �� ������ � ������� ���������� nParMA.number � nParMAResize.Number
  if (ArraySize(nParMA.sum_x)< nParMA.number) 
   {
    Print(StringConcatenate("ParMASeries number = ",nParMA.n,
                ". ������!!! ����������� ������ �������� ���������� nParMA.number ������� ParMASeries()"));
    Print(StringConcatenate("ParMASeries number = ",nParMA.n,
         ". ��� ����������� ������ ��������  ���������� nParMAResize.Size ������� ParMASeriesResize()"));
    return(0.0);
   }
 }
//----++ +--------------------------------------------------------------------------------------------------+ 

if (nParMA.bar > nParMA.MaxBar)
               {nParMA.reset = 0; return(0.0);}

if(nParMA.bar != nParMA.limit)
        for(nParMA.iii = nParMA.period; nParMA.iii >= 0; nParMA.iii--)
                              dParMA.TempBuffer[nParMA.n][nParMA.iii+1] =
                                       dParMA.TempBuffer[nParMA.n][nParMA.iii];
                                 
dParMA.TempBuffer[nParMA.n][0] = dParMA.series;

if (nParMA.period < 3)nParMA.period = 3;
else if (nParMA.period > nParMA.rangeMin)nParMA.period = nParMA.rangeMin; 

if (nParMA.bar > nParMA.MaxBar - nParMA.period)
                               {nParMA.reset =0; return(0.0);}

//----++ <<< ������ �������������  >>> +-------------------+
if (nParMA.bar == nParMA.MaxBar - nParMA.period)
{ 
 for(nParMA.iii = 1; nParMA.iii <= nParMA.period; nParMA.iii++)
   {
    dParMA.var_tmp  = nParMA.iii;
    nParMA.sum_x[nParMA.n]   += dParMA.var_tmp; 
    dParMA.var_tmp *= nParMA.iii;
    nParMA.sum_x2[nParMA.n]  += dParMA.var_tmp; 
    dParMA.var_tmp *= nParMA.iii;
    nParMA.sum_x3[nParMA.n]  += dParMA.var_tmp; 
    dParMA.var_tmp *= nParMA.iii;
    nParMA.sum_x4[nParMA.n]  += dParMA.var_tmp; 
   }
}
//----++ --------------------------------------------------+  

if (nParMA.period < 1)nParMA.period = 1;

//----++ �������� �� ������ � ������������������ ��������� ���������� nParMA.bar
if (nParMA.limit >= nParMA.MaxBar)
 if (nParMA.bar == 0)
   if (nParMA.MaxBar > nParMA.period)
       if (nParMA.TIME[nParMA.n] == 0)
          Print(StringConcatenate("ParMASeries number = ", nParMA.n,
                     ". ������!!! �������� ���������� ������������������",
                         " ��������� ��������� nParMA.bar ������� ���������� �����!!!")); 
                        
if(nParMA.bar == nParMA.limit)
 if (nParMA.limit < nParMA.MaxBar)
{
//----+ <<< �������������� �������� ���������� >>> +------------------------------------------------------------------+
nParMA.Tnew = Time[nParMA.limit + 1];
nParMA.Told = nParMA.TIME[nParMA.n];
 //--+
if(nParMA.Tnew == nParMA.Told)
         for(nParMA.iii = nParMA.period; nParMA.iii >= 1; nParMA.iii--)
                                     dParMA.TempBuffer[nParMA.n][nParMA.iii] =
                                                         dParMA.TEMPBUFFER[nParMA.n][nParMA.iii];  
//--+ �������� �� ������
if(nParMA.Tnew != nParMA.Told)
    {
     nParMA.reset = -1;
     //--+ ��������� ������ � ������� �������� ��������� nParMA.limit ������� ParMASeries()
     if (nParMA.Tnew > nParMA.TIME[nParMA.n])
       {
       Print(StringConcatenate("ParMASeries number = ", nParMA.n,
                                 ". ������!!! �������� nParMA.limit ������� ParMASeries() ������, ��� ����������"));
       }
    else 
       { 
       int nParMA.LimitERROR = nParMA.limit + 1 - iBarShift(NULL, 0, nParMA.TIME[nParMA.n], TRUE);
       
       Print(StringConcatenate("ParMASeries number = ",nParMA.n,
                        ". ������!!! �������� nParMA.limit ������� ParMASeries() ������, ��� ���������� �� ",
                                                                                                    nParMA.LimitERROR));
       }
  //--+ ������� ����� nParMA.reset=-1; ������ � ������� ������� ParMASeries
  return(0);
  }                     
//----+----------------------------------------------------------------------------------------------------------------+
} 

//+--- ���������� �������� ���������� +---------------------------------------+
if (nParMA.bar == 1)
 if (nParMA.limit != 1)
  {
   nParMA.TIME[nParMA.n] = Time[2];
   for(nParMA.iii = nParMA.period; nParMA.iii >= 1; nParMA.iii--)
                             dParMA.TEMPBUFFER[nParMA.n][nParMA.iii]=
                                    dParMA.TempBuffer[nParMA.n][nParMA.iii];      
  }
//+---+-----------------------------------------------------------------------+  
 
  // main calculation loop
  nParMA.loop_begin = nParMA.period - 1;
  dParMA.sum_y   = 0.0;
  dParMA.sum_xy  = 0.0;
  dParMA.sum_x2y = 0.0;
  for (nParMA.iii = 1; nParMA.iii <= nParMA.period; nParMA.iii++)
   {
    dParMA.var_tmp  = dParMA.TempBuffer[nParMA.n][nParMA.loop_begin - nParMA.iii + 1];  
    dParMA.sum_y   += dParMA.var_tmp;
    dParMA.sum_xy  += nParMA.iii * dParMA.var_tmp;    
    dParMA.sum_x2y += nParMA.iii * nParMA.iii * dParMA.var_tmp; 
   }
  // initialization
  dParMA.A = nParMA.period;
  dParMA.B = nParMA.sum_x[nParMA.n];  
  dParMA.C = nParMA.sum_x2[nParMA.n]; 
  dParMA.F = nParMA.sum_x3[nParMA.n]; 
  dParMA.M = nParMA.sum_x4[nParMA.n]; 
  dParMA.P = dParMA.sum_y;                   
  dParMA.R = dParMA.sum_xy; 
  dParMA.S = dParMA.sum_x2y;
  // intermediates
  dParMA.D = dParMA.B;  dParMA.E = dParMA.C;  dParMA.K = dParMA.C;  dParMA.L = dParMA.F;
  dParMA.Q = dParMA.D / dParMA.A;  dParMA.E = dParMA.E - dParMA.Q * dParMA.B; 
  dParMA.F = dParMA.F - dParMA.Q * dParMA.C;  dParMA.R = dParMA.R - dParMA.Q * dParMA.P;  
  dParMA.Q = dParMA.K / dParMA.A;  dParMA.L = dParMA.L - dParMA.Q * dParMA.B;
  dParMA.M = dParMA.M - dParMA.Q * dParMA.C;  dParMA.S = dParMA.S - dParMA.Q * dParMA.P; 
  dParMA.Q = dParMA.L / dParMA.E;
  // calculate regression coefficients
  dParMA.B2 = (dParMA.S - dParMA.R * dParMA.Q) / (dParMA.M - dParMA.F * dParMA.Q);
  dParMA.B1 = (dParMA.R - dParMA.F * dParMA.B2) / dParMA.E;
  dParMA.B0 = (dParMA.P - dParMA.B * dParMA.B1 - dParMA.C * dParMA.B2) / dParMA.A;
  // value to be returned - parabolic MA
  dParMA.ret_val = dParMA.B0 + (dParMA.B1 + dParMA.B2 * dParMA.A) * dParMA.A;
 //----
 //----++ �������� �� ������ � ���������� ������������ ���� ������� JParMASeries()
nParMA.Error = GetLastError();
if(nParMA.Error > 000)
  {
    Print(StringConcatenate("ParMASeries number = ",
                         nParMA.n,". ��� ���������� ������� ParMASeries() ��������� ������!!!"));
    Print(StringConcatenate("ParMASeries number = ",nParMA.n,". ",ParMA_ErrDescr(nParMA.Error)));   
    return(0.0);
  }
  
  nParMA.reset = 0;
  return(dParMA.ret_val);
//---- ���������� ���������� �������� ������� ParMASeries() ----------------+ 
}

//--+ --------------------------------------------------------------------------------------------+


//+X==============================================================================================X+
// ParMASeriesResize - ��� �������������� ������� ��� ��������� �������� �������� ����������       | 
// ������� ParMASeries. ������ ���������: ParMASeriesResize(5); ��� 5 - ��� ���������� ��������� � | 
// ParMASeries()� ������ ����������. ��� ��������� � �������  ParMASeriesResize ������� ���������  |
// � ���� ������������� ����������������� ���������� ��� ��������                                  |
//+X==============================================================================================X+
int ParMASeriesResize(int nParMAResize.Size)
 {
//----+
  if(nParMAResize.Size < 1)
   {
    Print("ParMASeriesResize: ������!!! �������� nParMAResize.Size �� ����� ���� ������ �������!!!"); 
    nParMA.Resize = -1; 
    return(0);
   }
  //----+    
  nParMA.range1 = ArrayRange(dParMA.TempBuffer, 1) - 1; 
  nParMA.range2 = ArrayRange(dParMA.TEMPBUFFER, 1) - 1;   
  nParMA.rangeMin = MathMin(nParMA.range1, nParMA.range2);
  if (nParMAResize.Size == -2)return(nParMA.rangeMin);
  //----+
  int nParMAResize.reset, nParMAResize.cycle;
  //--+
  while(nParMAResize.cycle == 0)
   {
    //----++ <<< ��������� �������� �������� ���������� >>>  +--------------------------------+
    if(ArrayResize(dParMA.TempBuffer, nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(dParMA.TEMPBUFFER, nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(nParMA.sum_x ,     nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(nParMA.sum_x2,     nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(nParMA.sum_x3,     nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(nParMA.sum_x4,     nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    if(ArrayResize(nParMA.TIME,       nParMAResize.Size) == 0){nParMAResize.reset = -1; break;}
    //----++----------------------------------------------------------------------------------+
    nParMAResize.cycle = 1;
   }
  //--+
  if (nParMAResize.reset == -1)
   {
    Print("ParMASeriesResize: ������!!! �� ������� �������� ������� �������� ���������� ������� ParMASeries().");
    int nParMAResize.Error = GetLastError();
    if(nParMAResize.Error > 4000)
               Print(StringConcatenate("ParMASeriesResize(): ", ParMA_ErrDescr(nParMAResize.Error)));    
    nParMA.Resize = -2;
    return(0);
   }
  else  
   {
    Print(StringConcatenate("ParMASeriesResize: ParMASeries()size = ", nParMAResize.Size));
    nParMA.Resize = nParMAResize.Size;
    return(nParMAResize.Size);
   }  
//----+
 }
//--+ --------------------------------------------------------------------------------------------+
/*
//+X====================================================================================================X+
ParMASeriesAlert - ��� �������������� ������� ��� ��������� ������ � ������� ������� ����������          |
������� ParMASeries.                                                                                     |
  -------------------------- ������� ���������  --------------------------                               |
ParMASeriesAlert.Number                                                                                  |
ParMASeriesAlert.ExternVar �������� ������� ���������� ��� ��������� nParMA.Phase                        |
ParMASeriesAlert.name ��� ������� ���������� ��� ��������� nParMA.Length, ���� ParMASeriesAlert.Number=0.|                                                  
  -------------------------- ������ �������������  -----------------------                               |
  int init()                                                                                             |
//----                                                                                                   |
����� �����-�� ������������� ���������� � �������                                                        |
                                                                                                         |
//---- ��������� ������� �� ������������ �������� ������� ����������                                     |                                                           
ParMASeriesAlert(0,"Length1",Length1);                                                                   |
ParMASeriesAlert(0,"Length2",Length2);                                                                   |
//---- ���������� �������������                                                                          |
return(0);                                                                                               |
}                                                                                                        |
//+X====================================================================================================X+
*/
void ParMASeriesAlert
 (int ParMASeriesAlert.Number, string ParMASeriesAlert.name, int ParMASeriesAlert.ExternVar)
 {
  //---- ��������� ������� �� ������������ �������� ������� ���������� ==========================+ 
   if (ParMASeriesAlert.Number == 0)
     if (ParMASeriesAlert.ExternVar < 3)
          Alert(StringConcatenate("�������� ", ParMASeriesAlert.name, " ������ ���� �� ����� 3", 
                      " �� ����� ������������ ", ParMASeriesAlert.ExternVar, " ����� ������������  3"));
   int ParMASeriesAlert.MaxPeriod = ArrayRange(dParMA.TEMPBUFFER, 1); 
   if (ParMASeriesAlert.Number == 0)
    if (ParMASeriesAlert.ExternVar > ParMASeriesAlert.MaxPeriod)
          Alert(StringConcatenate("�������� ", ParMASeriesAlert.name, " ������ ���� �� ����� ", ParMASeriesAlert.MaxPeriod, 
                  " �� ����� ������������ ", ParMASeriesAlert.ExternVar, ". ����� ������������  ", ParMASeriesAlert.MaxPeriod, ".",
                                       " ���� ���������� ������� �������� ��������� nParMA.period, �������� ������ ��������� �������",
                                                                            " dParMA.TempBuffer � dParMA.TEMPBUFFER ������� ParMASeries"));       
 }
//--+ -------------------------------------------------------------------------------------------+

// ������� ������ �������� ��������� 01.12.2006  
//+X================================================================X+
//|                                     ParMA_ErrDescr_RUS(MQL4).mqh |
//|                      Copyright � 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+X================================================================X+
string ParMA_ErrDescr(int error_code)
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



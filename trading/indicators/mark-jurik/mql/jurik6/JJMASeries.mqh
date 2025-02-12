//Version  January 7, 2007 Final
//+X================================================================X+
//|                                                 JJMASeries().mqh |
//|                       JMA code: Copyright � 1998, Jurik Research |
//|                                          http://www.jurikres.com | 
//|              MQL4 JJMASeries: Copyright � 2006, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+ 
  /*
  +-------------------------------------- <<< ������� JJMASeries() >>> -----------------------------------------------+

  +-----------------------------------------+ <<< ���������� >>> +----------------------------------------------------+

  �������  JJMASeries()  �������������  ���  �������������  ���������  JMA ��� ��������� ����� ����������� ���������� �
  ���������,  ���  ������  �������  �������������  ����������  ��  ����  ��������.  �������  �� ��������, ���� ��������
  nJMA.limit ��������� ��������, ������ ����! ��� ����������, ��������� ���� ��� JJMASeries(), ��������� � ������ �����
  �����������.  ���� ������� �������� � ����� MetaTrader\experts\include\ ������� ������, ��� ���� nJMA.bar ������, ���
  nJMA.MaxBar,  �� ������� JJMASeries() ���������� �������� ������ ����! �� ���� ����! �, �������������, ����� ��������
  ��  �����  ��������������  �  �����������  �����-����  �����  �  �������  ����������! ��� ������ ������� JJMASeries()
  ������������  ��������� ��� � ������������� � ���������������� �����������, � ������� ���������� �������. ��� ������
  �������  JJMASeries()  ������������ ��������� ��� � ������������� � ���� ����������, ������� ��������� ������� � ���
  ��������  �  �����������  ����  ���������� ����� � ����������! ��� ��������� ����������� � ��������� � ��������������
  �������  JJMASeries(),  ��  �������������  ����������  ������  �����  ������������  �  nJMA....  ��� dJMA.... �������
  JJMASeries()  �����  ����  ������������  ��  ����������  ����  ������  ����������������  �������, �� ��� ���� �������
  ��������� ��� ����, ��� � ������ ��������� � ����� ���������������� ������� � ������� ��������� � JJMASeries() ������
  ����  ����  ����������  �����  nJMA.number.  �������  JJMASeries()  ����� ���� ������������ �� ���������� ���� ������
  ����������������  �������,  ��  ���  ���� ������� ��������� ��� ����, ��� � ������ ��������� � ����� ����������������
  ������� � ������� ��������� � JJMASeries() ������ ���� ���� ���������� ����� (nJMA.number). 
  
  +-------------------------------------+ <<< ������� ��������� >>> +-------------------------------------------------+

  nJMA.number - ���������� ����� ��������� � ������� JJMASeries(). (0, 1, 2, 3 �.�.�....)
  nJMA.dinJ   - ��������, ����������� �������� ��������� nJMA.Length � nJMA.Phase �� ������ ����. 0 -  ������ ��������� 
                ����������, ����� ������ �������� - ����������.
  nJMA.MaxBar - ������������  ��������,  �������  �����  ���������  �����  ���������������  ����(bar).     ������ ����� 
                Bars-1-period;    ��� "period" - ��� ���������� �����,  �� �������  ��������  ��������  dJMA.series  �� 
                ��������������;
  nJMA.limit  - ���������� ��� �� ������������ ����� ���� ���� ��� ����� ���������� �������������� ����,    ������ ���� 
                ����������� �����  Bars-IndicatorCounted()-1;
  nJMA.Length - ������� �����������
  nJMA.Phase  - ��������, ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������;
  dJMA.series - �������  ��������, �� �������� ������������ ������ ������� JJMASeries();
  nJMA.bar    - ����� ��������������� ����, �������� ������  ����������  ����������  �����  �� ������������� �������� � 
                ��������. ������ ��� ������������ �������� ������ ������ ��������� �������� ��������� nJMA.limit!!!

  +------------------------------------+ <<< �������� ��������� >>> +-------------------------------------------------+

  JJMASeries()- �������� ������� dJMA.JMA.   ���  ���������  nJMA.bar  ������  ���  nJMA.MaxBar-30 ������� JJMASeries() 
                ������ ���������� ����!!!
  nJMA.reset  - ��������,  ������������ �� ������ ��������, ���������� �� 0 , ����  ��������� ������ � ������� �������,
                0, ���� ������ ������ ���������. ���� �������� ����� ���� ������ ����������, �� �� ���������!!!!
                 
  +-----------------------------------+ <<< ������������� ������� >>> +-----------------------------------------------+
  
  ����� ����������� � ������� JJMASeries(), ����� ���������� ��� ������������ ����� ����� 0, (� ��� ����� ��� ������� �
  �����  �������������  �����������������  ����������  ���  ��������)   �������  ��������  �������  ���������� ��������
  ����������   �������,  ���   �����   ����������  ����������  �  �������  JJMASeries() �����  ���������������  �������
  JJMASeriesResize() ��   ����������   �����������:   JJMASeriesResize(nJMA.number+1);   ����������   �������  ��������
  nJMA.number(MaxJMA.number) ������  ���������� ���������  �  �������  JJMASeries(),  ��  ����  ��  ������� ������, ���
  ������������ nJMA.number. 
  
  +--------------------------------------+ <<< ��������� ������ >>> +-------------------------------------------------+
  
  ��� ������� ����������� � ��������� �� ���� ����� ��������� ������, ��� ��������� ������ ������� ������� �������� ���
  ����.  ���  ������  ������� JJMASeries() ����� � ��� ���� � ����� \MetaTrader\EXPERTS\LOGS\. ����, ����� ���������� �
  �������  JJMASeries()  � ����, ������� ������������� �������, �������� MQL4 ������, �� ������� ������� � ��� ���� ���
  ������  � ���������� ������. ���� ��� ���������� ������� JJMASeries() � ��������� JJMASeries() ��������� MQL4 ������,
  ��  �������  �����  �������  �  ���  ���� ��� ������ � ���������� ������. ��� ������������ ������� ������ ��������� �
  �������  JJMASeries()  nJMA.number  ���  �������� ����������� ������� �������� ���������� nJJMAResize.Size � ��� ����
  ����� �������� ��������� � �������� ����������� ���� ����������. ����� � ��� ���� ������� ���������� ��� ������������
  �����������  ���������  nJMA.limit.  ����  ���  ����������  ������� ������������� init() ��������� ���� ��� ���������
  ��������  ��������  ����������  �������  JJMASeries(),  ��  �������  JJMASeriesResize ������� � ��� ���� ���������� �
  ���������  ���������  ��������  ��������  ����������. ���� ��� ��������� � ������� JJMASeries()����� ������� ��������
  �����  ����  ��������  ���������� ������������������ ��������� ��������� nJMA.bar, �� � ��� ���� ����� �������� � ���
  ����������. ������� ������, ��� ��������� ������ ������������ ���� ����� ��������� ���������� ������ � ��� ����������
  �  �������,  ����  �������  JJMASeries()�����  �  ���  ���� ����� ��������� ������, �� ��������� �� ������� � �������
  �������  �������������.  � ��������� ���������� ���������� ������� JJMASeries() ����� ������ ������ � ��� ���� ������
  ���  ����������  ������ ������������ �������. ���������� ���������� ������ ��������� �������� �������� ���������� ���
  ������������ ���������� ��� ��������, ������� ���������� ��� ������ ������ ������� init(). 
  
  +---------------------------------+ <<< ������ ��������� � ������� >>> +--------------------------------------------+

//----+ ����������� ������� JJMASeries()
#include <JJMASeries.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE); 
//---- 1 ������������ ����� ����������� ��� �����
SetIndexBuffer(0,Ind_Buffer);
//----+ ��������� �������� �������� ���������� ������� JJMASeries, nJMA.number=1(���� ��������� � ������� JJMASeries)
if(JJMASeriesResize(1)==0)return(-1);
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
//---- ��������� ������������ ��� ������ ���� ���������� (��� ����� ��������� ������� JJMASeries() ���� ������ ����������� �� �����!!!)
if (counted_bars>0) counted_bars--;
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
int limit=Bars-counted_bars-1;
MaxBar=Bars-1;
//----+ 
for(bar=limit;bar>=0;bar--)
 (
  double Series=Close[bar];
  //----+ ��������� � ������� JJMASeries() �� ������� 0 ��� ������� ������ Ind_Buffer[], 
  //��������� nJMA.Phase � nJMA.Length �� �������� �� ������ ���� (nJMA.din=0)
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

//----++ <<< ���������� ���������� ���������� >>> +-----------------------------------------------------------------+
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

//----++ <<< ���������� ������� JJMASeries() >>> +--------------------------------------+

double JJMASeries
(
int nJMA.number, int nJMA.din,       int nJMA.MaxBar, int nJMA.limit,
int nJMA.Phase,  int nJMA.Length, double dJMA.series, int nJMA.bar,   int& nJMA.reset
)
//----++ +------------------------------------------------------------------------------+
{
nJMA.n = nJMA.number;

nJMA.reset = 1;
//=====+ <<< �������� �� ������ >>> --------------------------------+
if (nJMA.bar == nJMA.limit)
 {
  //----++ �������� �� ������������� ������� JJMASeries()
  if(nJMA.Resize < 1)
   {
    Print(StringConcatenate("JJMASeries number =", nJMA.n,
         ". �� ���� ������� ��������� �������� �������� ���������� �������� JJMASeriesResize()"));
    if(nJMA.Resize == 0)
        Print(StringConcatenate("JJMASeries number =", nJMA.n,
                ". ������� �������� ��������� � ������� JJMASeriesResize() � ���� �������������"));
    return(0.0);
   }
  //----++ �������� �� ������ � ���������� ������������ ����, ����������������� ������� JJMASeries()
  nJMA.Error = GetLastError();
  if(nJMA.Error > 4000)
   {
    Print(StringConcatenate("JJMASeries number =", nJMA.n,
         ". � ����, �������������� ��������� � ������� JJMASeries() number = ", nJMA.n, " ������!!!"));
         
    Print(StringConcatenate("JJMASeries number =", nJMA.n+ ". ", JMA_ErrDescr(nJMA.Error)));  
   } 
                                                   
  //----++ �������� �� ������ � ������� ���������� nJMA.number � nJMAResize.Number
  nJMA.size = ArraySize(dJMA.JMA);
  if (nJMA.size < nJMA.n) 
   {
    Print(StringConcatenate("JJMASeries number =", nJMA.n, 
          ". ������!!! ����������� ������ �������� ���������� nJMA.number=",
                                                        nJMA.n, " ������� JJMASeries()"));
    Print(StringConcatenate("JJMASeries number =", nJMA.n,
          ". ��� ����������� ������ ��������  ���������� nJJMAResize.Size=",
                                               nJMA.size, " ������� JJMASeriesResize()"));
    return(0.0);
   }
 }
//----++ �������� �� ������ � ������������������ ��������� ���������� nJMA.bar
if (nJMA.limit >= nJMA.MaxBar && nJMA.bar == 0)
    if(nJMA.MaxBar > 30 && nJMA.TIME[nJMA.n] == 0)
                  Print(StringConcatenate("JJMASeries number =", nJMA.n,
                        ". ������!!! �������� ���������� ������������������",
                               " ��������� ��������� nJMA.bar ������� ���������� �����!!!"));  
//----++ +----------------------------------------------------------------+ 
if (nJMA.bar > nJMA.MaxBar){nJMA.reset = 0; return(0.0);}
if(nJMA.bar == nJMA.MaxBar || nJMA.din != 0) 
  {
   //----++ <<< ������ �������������  >>> +--------------------------------------------------+
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
   //----+ <<< �������������� �������� ���������� >>> +----------------------------------------------------------------------------+
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
   //--+ �������� �� ������
   if(nJMA.Tnew != nJMA.Told)
    {
     nJMA.reset = -1;
     //--+ ��������� ������ � ������� �������� ��������� nJMA.limit ������� JJMASeries()
     if (nJMA.Tnew > nJMA.Told)
       {
        Print(StringConcatenate("JJMASeries number =", nJMA.n,
                 ". ������!!! �������� nJMA.limit ������� JJMASeries() ������, ��� ����������"));
       }
     else 
       { 
        int nJMA.LimitERROR = nJMA.limit + 1 - iBarShift(NULL, 0, nJMA.Told, TRUE);
        
        Print(StringConcatenate("JMASerries number =", nJMA.n,
                ". ������!!! �������� nJMA.limit ������� JJMASeries() ������, ��� ���������� �� ",
                                                                                        nJMA.LimitERROR, ""));
       }
     //--+ ������� ����� nJMA.reset=-1; ������ � ������� ������� JJMASeries
     return(0);
    }
  //----+--------------------------------------------------------------------------------------------------------------------------+
  } 
if (nJMA.bar == 1)    
if (nJMA.limit != 1 || Time[nJMA.limit + 2] == nJMA.TIME[nJMA.n])
  {
   //--+ <<< ���������� �������� ���������� >>> +-------------------------------------------------------------------------------+
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

//----++ �������� �� ������ � ���������� ������������ ���� ������� JJMASeries()
nJMA.Error = GetLastError();
if(nJMA.Error > 4000)
  {
    Print(StringConcatenate("JJMASeries number =", nJMA.n, 
                                 ". ��� ���������� ������� JJMASeries() ��������� ������!!!"));
    Print(StringConcatenate("JJMASeries number =", nJMA.n, ". ", JMA_ErrDescr(nJMA.Error)));   
    return(0.0);
  }

nJMA.reset = 0;
return(dJMA.JMA[nJMA.n]);
//----+  ���������� ���������� ������� JJMASeries() --------------------------+
}

//+X=============================================================================================X+
// JJMASeriesResize - ��� �������������� ������� ��� ��������� �������� �������� ����������       | 
// ������� JJMASeries. ������ ���������: JJMASeriesResize(5); ��� 5 - ��� ���������� ��������� �  | 
// JJMASeries()� ������ ����������. ��� ��������� � �������  JJMASeriesResize ������� ���������   |
// � ���� ������������� ����������������� ���������� ��� ��������                                 |
//+X=============================================================================================X+
int JJMASeriesResize(int nJJMAResize.Size)
 {
//----+
  if(nJJMAResize.Size < 1)
   {
    Print("JJMASeriesResize: ������!!! �������� nJJMAResize.Size �� ����� ���� ������ �������!!!"); 
    nJMA.Resize = -1; 
    return(0);
   }  
  int nJJMAResize.reset, nJJMAResize.cycle;
  //--+
  while(nJJMAResize.cycle == 0)
   {
    //----++ <<< ��������� �������� �������� ���������� >>> +------------------------+
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
    Print("JJMASeriesResize: ������!!! �� ������� �������� ������� �������� ���������� ������� JJMASeries().");   
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
JJMASeriesAlert  -  ���  ��������������  �������  ���  ��������� ������ � ������� ������� ����������  | 
nJMA.Length � nJMA.Phase ������� JJMASeries.                                                          |
  -------------------------- ������� ���������  --------------------------                            |
JJMASeriesAlert.Number                                                                                |
JJMASeriesAlert.ExternVar �������� ������� ���������� ��� ��������� nJMA.Length                       |
JJMASeriesAlert.name ��� ������� ���������� ��� ��������� nJMA.Phase, ���� JJMASeriesAlert.Number=0   |
��� nJMA.Phase, ���� JJMASeriesAlert.Number=1.                                                        |
  -------------------------- ������ �������������  -----------------------                            |
  int init()                                                                                          |
//----                                                                                                |
����� �����-�� ������������� ���������� � �������                                                     |
                                                                                                      |
//---- ��������� ������� �� ������������ �������� ������� ����������                                  |
JJMASeriesAlert(0,"Length1",Length1);                                                                 |
JJMASeriesAlert(0,"Length2",Length2);                                                                 |
JJMASeriesAlert(1,"Phase1",Phase1);                                                                   |                                                            
JJMASeriesAlert(1,"Phase2",Phase2);                                                                   |                                                          
//---- ���������� �������������                                                                       |
return(0);                                                                                            |
}                                                                                                     |
//+X=================================================================================================X+
*/
void JJMASeriesAlert
 (
  int JJMASeriesAlert.Number, string JJMASeriesAlert.name, int JJMASeriesAlert.ExternVar
 )
 {
  //---- ��������� ������� �� ������������ �������� ������� ���������� 
  if (JJMASeriesAlert.Number==0)if(JJMASeriesAlert.ExternVar<1)
          Alert(StringConcatenate("�������� ", JJMASeriesAlert.name, " ������ ���� �� ����� 1", 
                   " �� ����� ������������ ", JJMASeriesAlert.ExternVar, " ����� ������������  1"));
  if (JJMASeriesAlert.Number==1)
   {
    if (JJMASeriesAlert.ExternVar < -100 || JJMASeriesAlert.ExternVar > 100)
          Alert(StringConcatenate("�������� ", JJMASeriesAlert.name, " ������ ���� �� -100 �� +100", 
          " �� ����� ������������ ", JJMASeriesAlert.ExternVar, " ����� ������������ -100"));
   }
 }

/*
������� ������ �������� ��������� 01.12.2006  
//+X================================================================X+
                                          JMA_ErrDescr(MQL4_RUS).mqh |
                         Copyright � 2004, MetaQuotes Software Corp. |
                                          http://www.metaquotes.net/ |
 ������� JMA_ErrDescr() �� ���� MQL4 ������ ���������� ����������    |
 ������ � ����� � ����������� ������.                                |
  -------------------- ������ �������������  ----------------------- | 
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
     //---- MQL4 ������ 
     case 4000: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ������");                                              break;
     case 4001: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ��������� �������");                          break;
     case 4002: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ������� �� ������������� ��� �������");             break;
     case 4003: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ������ ��� ����� �������");                            break;
     case 4004: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ����� ����� ������������ ������");            break;
     case 4005: error_string = StringConcatenate("��� ������ = ",error_code,". �� ����� ��� ������ ��� �������� ����������");             break;
     case 4006: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ������ ��� ���������� ���������");                     break;
     case 4007: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ������ ��� ��������� ������");                         break;
     case 4008: error_string = StringConcatenate("��� ������ = ",error_code,". �������������������� ������");                             break;
     case 4009: error_string = StringConcatenate("��� ������ = ",error_code,". �������������������� ������ � �������");                   break;
     case 4010: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ������ ��� ���������� �������");                       break;
     case 4011: error_string = StringConcatenate("��� ������ = ",error_code,". ������� ������� ������");                                  break;
     case 4012: error_string = StringConcatenate("��� ������ = ",error_code,". ������� �� ������� �� ����");                              break;
     case 4013: error_string = StringConcatenate("��� ������ = ",error_code,". ������� �� ����");                                         break;
     case 4014: error_string = StringConcatenate("��� ������ = ",error_code,". ����������� �������");                                     break;
     case 4015: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ������� (never generated error)");            break;
     case 4016: error_string = StringConcatenate("��� ������ = ",error_code,". �������������������� ������");                             break;
     case 4017: error_string = StringConcatenate("��� ������ = ",error_code,". ������ DLL �� ���������");                                 break;
     case 4018: error_string = StringConcatenate("��� ������ = ",error_code,". ���������� ��������� ����������");                         break;
     case 4019: error_string = StringConcatenate("��� ������ = ",error_code,". ���������� ������� �������");                              break;
     case 4020: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ������� ������������ ������� �� ���������");        break;
     case 4021: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ������ ��� ������, ������������ �� �������"); break;
     case 4022: error_string = StringConcatenate("��� ������ = ",error_code,". ������� ������ (never generated error)");                  break;
     case 4050: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ���������� ���������� �������");              break;
     case 4051: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ �������� ��������� �������");                 break;
     case 4052: error_string = StringConcatenate("��� ������ = ",error_code,". ���������� ������ ��������� �������");                     break;
     case 4053: error_string = StringConcatenate("��� ������ = ",error_code,". ������ �������");                                          break;
     case 4054: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ������������� �������-���������");            break;
     case 4055: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ����������������� ����������");                     break;
     case 4056: error_string = StringConcatenate("��� ������ = ",error_code,". ������� ������������");                                    break;
     case 4057: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��������� ����������� ����������");                 break;
     case 4058: error_string = StringConcatenate("��� ������ = ",error_code,". ���������� ���������� �� ����������");                     break;
     case 4059: error_string = StringConcatenate("��� ������ = ",error_code,". ������� �� ��������� � �������� ������");                  break;
     case 4060: error_string = StringConcatenate("��� ������ = ",error_code,". ������� �� ������������");                                 break;
     case 4061: error_string = StringConcatenate("��� ������ = ",error_code,". ������ �������� �����");                                   break;
     case 4062: error_string = StringConcatenate("��� ������ = ",error_code,". ��������� �������� ���� string");                          break;
     case 4063: error_string = StringConcatenate("��� ������ = ",error_code,". ��������� �������� ���� integer");                         break;
     case 4064: error_string = StringConcatenate("��� ������ = ",error_code,". ��������� �������� ���� double");                          break;
     case 4065: error_string = StringConcatenate("��� ������ = ",error_code,". � �������� ��������� ��������� ������");                   break;
     case 4066: error_string = StringConcatenate("��� ������ = ",error_code,". ����������� ������������ ������ � ��������� ����������");  break;
     case 4067: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��� ���������� �������� ��������");                 break;
     case 4099: error_string = StringConcatenate("��� ������ = ",error_code,". ����� �����");                                             break;
     case 4100: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��� ������ � ������");                              break;
     case 4101: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ ��� �����");                                  break;
     case 4102: error_string = StringConcatenate("��� ������ = ",error_code,". ������� ����� �������� ������");                           break;
     case 4103: error_string = StringConcatenate("��� ������ = ",error_code,". ���������� ������� ����");                                 break;
     case 4104: error_string = StringConcatenate("��� ������ = ",error_code,". ������������� ����� ������� � �����");                     break;
     case 4105: error_string = StringConcatenate("��� ������ = ",error_code,". �� ���� ����� �� ������");                                 break;
     case 4106: error_string = StringConcatenate("��� ������ = ",error_code,". ����������� ������");                                      break;
     case 4107: error_string = StringConcatenate("��� ������ = ",error_code,". ������������ �������� ���� ��� �������� �������");         break;
     case 4108: error_string = StringConcatenate("��� ������ = ",error_code,". �������� ����� ������");                                   break;
     case 4109: error_string = StringConcatenate("��� ������ = ",error_code,". �������� �� ���������");                                   break;
     case 4110: error_string = StringConcatenate("��� ������ = ",error_code,". ������� ������� �� ���������");                            break;
     case 4111: error_string = StringConcatenate("��� ������ = ",error_code,". �������� ������� �� ���������");                           break;
     case 4200: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��� ����������");                                   break;
     case 4201: error_string = StringConcatenate("��� ������ = ",error_code,". ��������� ����������� �������� �������");                  break;
     case 4202: error_string = StringConcatenate("��� ������ = ",error_code,". ������ �� ����������");                                    break;
     case 4203: error_string = StringConcatenate("��� ������ = ",error_code,". ����������� ��� �������");                                 break;
     case 4204: error_string = StringConcatenate("��� ������ = ",error_code,". ��� ����� �������");                                       break;
     case 4205: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��������� �������");                                break;
     case 4206: error_string = StringConcatenate("��� ������ = ",error_code,". �� ������� ��������� �������");                            break;
     case 4207: error_string = StringConcatenate("��� ������ = ",error_code,". ������ ��� ������ � ��������");                            break;
     default:   error_string = StringConcatenate("��� ������ = ",error_code,". ����������� ������");
    }
//----
  return(error_string);
 }
//+------------------------------------------------------------------+



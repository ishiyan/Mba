//Version  January 1, 2009 Final
//+X================================================================X+
//|                                                   T3Series().mqh |
//|                                T3 code: Copyright � 1998, Tilson |
//|            MQL4 T3Series: Copyright � 2009,     Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+
  /*

  +--------------------------------------- <<< ������� T3Series() >>> ------------------------------------------------+

  +-----------------------------------------+ <<< ���������� >>> +----------------------------------------------------+

  �������  T3Series()  �������������  ��� ������������� ��������� �������� ��� ��������� ����� ����������� ���������� �
  ���������,  ��� ������ ������� ������������� ���������� �� ���� ��������. ���� ������� �������� � ����� (����������):
  MetaTrader\experts\include\  �������  ������,  ���  ����  nT3.bar  ������,  ���  nT3.MaxBar-3*nT3.Period,  �� �������
  T3Series()  ���������� �������� ������ ����! �� ���� ����! �, �������������, ����� �������� �� ����� �������������� �
  �����������  �����-����  �����  �  �������  ����������!  ���  ������ ������� T3Series() ������������ ��������� ��� �
  �������������   �  ����������������  �����������,  �  �������  ����������  �������.  ���  ������  �������  T3Series()
  ������������ ��������� ��� � ������������� � ���� ����������, ������� ��������� ������� � ��� �������� � �����������
  ����  ����������  �����!  ��� ��������� ����������� � ��������� � �������������� ������� T3Series(), �� �������������
  ����������  ������  ����� ������������ � nT3.... ��� dT3.... ������� T3Series() ����� ���� ������������ �� ����������
  ����  ������  ����������������  �������,  ��  ���  ����  �������  ���������  ��� ����, ��� � ������ ��������� � �����
  ���������������� ������� � ������� ��������� � T3Series() ������ ���� ���� ���������� ����� (nT3.number). 

  +-------------------------------------+ <<< ������� ��������� >>> +-------------------------------------------------+

  nT3.number    - ���������� ����� ��������� � ������� T3Series(). (0, 1, 2, 3 �.�.�....)
  nT3.din       - ��������,  ����������� �������� ���������  nT3.Period �� ������ ����. 0 - ������ ��������� ����������, 
                  ����� ������ �������� - ����������.
  nT3.MaxBar    - ������������  ��������, �������  ����� ���������  �����  ���������������  ����(nT3.bar). ������ ����� 
                  Bars-1-period;  ��� "period" -  ���  ����������  �����,  ��  �������  �������� �������� dT3.series �� 
                  ��������������; 
  nT3.limit     - ����������  ���  ��  ������������ ����� ���� ���� ���  ����� ����������  �������������� ����,  ������ 
                  ����� Bars-IndicatorCounted()-1;  
  nT3.Curvature - �������� ������������ � �������� 0 ... +100, ������ �� �������� ����������� ��������; 
  nT3.Period    - ������� �����������
  dT3.series    - �������  ��������, �� �������� ������������ ������ ������� T3Series();
  nT3.bar       - ����� ���������������  ����, �������� ������  ���������� ���������� ����� �� ������������� �������� �
                  ��������.   ������ ��� ������������ �������� ������ ������ ��������� �������� ��������� nT3.limit!!!

  +------------------------------------+ <<< �������� ��������� >>> +-------------------------------------------------+

  T3Series()    - �������� ������� T3.  ��� ���������  nT3.bar ������ ���  nT3.MaxBar-nT3.Length  �������  T3MASeries() 
                  ������ ���������� ����!!!
  nT3.reset     - ��������, ������������  ��  ������  ��������,  ����������  �� 0,  ����  ���������  ������  �  ������� 
                  �������, 0,  ����  ������  ������  ���������.    ���� ��������  �����  ����  ������ ����������, �� �� 
                  ���������!!!

  +-----------------------------------+ <<< ������������� ������� >>> +-----------------------------------------------+

  �����  �����������  � ������� T3Series(), ����� ���������� ��� ������������ ����� ����� 0, (� ��� ����� ��� ������� �
  �����  �������������  �����������������  ����������  ���  ��������),  �������  ������  �  ���������������� ����������
  ����������   �������,   ���   �����   ����������  ����������  �  �������  T3Series()  �����  ���������������  �������
  T3SeriesResize()   ��   ����������   �����������:   T3SeriesResize(MaxT3.number+1);   ����������   �������   ��������
  nT3.number(MaxT3.number)  ������  ����������  ���������  �  �������  T3Series(),  ��  ����  ��  �������  ������,  ���
  ������������ nT3.number. 

  +--------------------------------------+ <<< ��������� ������ >>> +-------------------------------------------------+
  
  ��� ������� ����������� � ��������� �� ���� ����� ��������� ������, ��� ��������� ������ ������� ������� �������� ���
  ����.  ���  ������  �������  T3Series()  ����� � ��� ���� � ����� \MetaTrader\EXPERTS\LOGS\. ����, ����� ���������� �
  �������  T3Series()  �  ����,  ������� ������������� �������, �������� MQL4 ������, �� ������� ������� � ��� ���� ���
  ������  �  ���������� ������. ���� ��� ���������� ������� T3Series() � ��������� T3Series() ��������� MQL4 ������, ��
  �������  ����� ������� � ��� ���� ��� ������ � ���������� ������. ��� ������������ ������� ������ ��������� � �������
  T3Series()  nT3.number ��� �������� ����������� ������� �������� ���������� nJT3Resize.Size � ��� ���� ����� ��������
  ���������  �  ��������  ����������� ���� ����������. ����� � ��� ���� ������� ���������� ��� ������������ �����������
  ���������  nT3.limit. ���� ��� ���������� ������� ������������� init() ��������� ���� ��� ��������� �������� ��������
  ����������  �������  T3Series(),  ��  �������  T3SeriesResize()  �������  � ��� ���� ���������� � ��������� ���������
  ��������  ��������  ����������.  ����  ���  ��������� � ������� T3Series() ����� ������� �������� ����� ���� ��������
  ����������  ������������������  ���������  ���������  nT3.bar, �� � ��� ���� ����� �������� � ��� ����������. �������
  ������,  ���  ���������  ������  ������������ ���� ����� ��������� ���������� ������ � ��� ���������� � �������, ����
  �������  T3Series() ����� � ��� ���� ����� ��������� ������, �� ��������� �� ������� � ������� ������� �������������.
  �  ���������  ����������  ����������  �������  T3Series() ����� ������ ������ � ��� ���� ������ ��� ���������� ������
  ������������ �������. ���������� ���������� ������ ��������� �������� �������� ���������� ��� ������������ ����������
  ��� ��������, ������� ���������� ��� ������ ������ ������� init(). 
  
  +---------------------------------+ <<< ������ ��������� � ������� >>> +--------------------------------------------+


//----+ ����������� ������� T3Series()
#include <T3Series.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE); 
//---- 1 ������������ ����� ����������� ��� ����� (��� ����� ��������� ������� T3Series() ���� ������ ����������� �� �����!!!)
SetIndexBuffer(0,Ind_Buffer);
//----+ ��������� �������� �������� ���������� ������� T3Series, nT3.number=1(���� ��������� � ������� T3Series)
if(T3SeriesResize(1)==0)return(-1);
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
  //----+ ��������� � ������� T3Series()�� ������� 0 ��� ������� ������ Ind_Buffer[], 
  //��������� nT3.Curvature � nT3.Length �� �������� �� ������ ���� (nT3.din=0)
  double Resalt=T3Series(0,0,MaxBar,limit,Curvature,Length,Series,bar,reset);
  if (reset!=0)return(-1);
  Ind_Buffer[bar]=Resalt;
 }
return(0);
}
//----+ 
  */
//+X================================================================X+
//|  T3Series() function                                             |
//+X================================================================X+   

//----++ <<< �������� � ������������� ���������� >>> +----------------------------+
double dT3.e1[1], dT3.e2[1], dT3.e3[1], dT3.e4[1], dT3.e5[1], dT3.e6[1];
double dT3.E1[1], dT3.E2[1], dT3.E3[1], dT3.E4[1], dT3.E5[1], dT3.E6[1];
double dT3.c1[1], dT3.c2[1], dT3.c3[1], dT3.c4[1], dT3.w1[1], dT3.w2[1];
double dT3.n[1], dT3.b2[1], dT3.b3[1], dT3.T3;
int    nT3.TIME[1], nT3.Error, nT3.num, nT3.Tnew, nT3.Old, nT3.size, nT3.Resize;
//----++ <<< ���������� ������� T3Series() >>> +-------------------------------------------------+
double T3Series
 (
  int nT3.number,    int nT3.din,     int    nT3.MaxBar,      int nT3.limit,
  int nT3.Curvature, int nT3.Period,  double dT3.series,       int nT3.bar,    int& nT3.reset
 )
//----+ +----------------------------------------------------------------------------------------+
{
nT3.num = nT3.number;

nT3.reset = 1;
//=====+ <<< �������� �� ������ >>> +--------------------------------------------------------------+
if (nT3.bar == nT3.limit)
 {
  //----++ �������� �� ������������� ������� T3Series()
  if(nT3.Resize < 1)
   {
    Print(StringConcatenate("T3Series number = ", nT3.num,
         ". �� ���� ������� ��������� �������� �������� ���������� �������� T3SeriesResize()"));
    if(nT3.Resize == 0)
       Print(StringConcatenate("T3Series number = ", nT3.num,
                ". ������� �������� ��������� � ������� T3SeriesResize() � ���� �������������"));
         
    return(0.0);
   }
  //----++ �������� �� ������ � ���������� ������������ ����, ����������������� ������� T3Series()
  nT3.Error = GetLastError();
  if(nT3.Error > 4000)
    {
      Print(StringConcatenate("T3Series number = ", nT3.num,
            ". � ����, �������������� ��������� � ������� T3Series() number = ",
                                                                 nT3.num, " ������!!!"));
      Print(StringConcatenate("T3Series() number = ", nT3.num, ". ", T3_ErrDescr(nT3.Error)));  
    }

  //----++ �������� �� ������ � ������� ���������� nT3.number � nT3Resize.Size
  nT3.size = ArraySize(dT3.e1);
  if (nT3.size < nT3.num) 
   {
    Print(StringConcatenate("T3Series number = ", nT3.num,
                   ". ������!!! ����������� ������ �������� ���������� nT3.number=",
                                                            nT3.num, " ������� T3Series()"));
    Print(StringConcatenate("T3Series number = ", nT3.num,
                    ". ��� ����������� ������ ��������  ���������� nT3Resize.Size=",
                                                     nT3.size, " ������� T3SeriesResize()"));
    return(0.0);
   }
 }
//----++ +------------------------------------------------------------------------------------------+

if (nT3.bar > nT3.MaxBar){nT3.reset = 0; return(0.0);}
if (nT3.bar == nT3.MaxBar || nT3.din != 0)
  {
   //----++ <<< ������ �������������  >>> +----------------------------------+
   double dT3.b = nT3.Curvature / 100.0;
   dT3.b2[nT3.num] = dT3.b * dT3.b;
   dT3.b3[nT3.num] = dT3.b2[nT3.num] * dT3.b;
   dT3.c1[nT3.num] = -dT3.b3[nT3.num];
   dT3.c2[nT3.num] = (3 * (dT3.b2[nT3.num] + dT3.b3[nT3.num]));
   dT3.c3[nT3.num] = -3 * (2 * dT3.b2[nT3.num] + dT3.b + dT3.b3[nT3.num]);
   dT3.c4[nT3.num] = (1 + 3 * dT3.b + dT3.b3[nT3.num] + 3 * dT3.b2[nT3.num]);
   if (nT3.Period < 1) nT3.Period = 1;
   dT3.n [nT3.num] = 1 + 0.5 * (nT3.Period - 1);
   dT3.w1[nT3.num] = 2 / (dT3.n[nT3.num] + 1);
   dT3.w2[nT3.num] = 1 - dT3.w1[nT3.num];
   //----++------------------------------------------------------------------+
  }
if (nT3.Period < 1)nT3.Period = 1;

//----++ �������� �� ������ � ������������������ ��������� ���������� nT3.bar
if (nT3.limit >= nT3.MaxBar)
 if (nT3.bar == 0)
  if (nT3.din == 0)
      if (nT3.MaxBar > nT3.Period * 3)
       if (nT3.TIME[nT3.num] == 0)
               Print(StringConcatenate("T3Series number = ", nT3.num,
                        ". ������!!! �������� ���������� ������������������ ",
                               "��������� ��������� nT3.bar ������� ���������� �����!!!")); 

if (nT3.bar == nT3.limit)
  if (nT3.limit < nT3.MaxBar)          
  {
   //----+ <<< �������������� �������� ���������� >>> +----------------------------------------------+
   nT3.Tnew = Time[nT3.limit + 1];
   nT3.Old = nT3.TIME[nT3.num];
   //--+ �������� �� ������
   if(nT3.Tnew==nT3.Old)
    {
     dT3.e1[nT3.num] = dT3.E1[nT3.num]; dT3.e2[nT3.num] = dT3.E2[nT3.num]; 
     dT3.e3[nT3.num] = dT3.E3[nT3.num]; dT3.e4[nT3.num] = dT3.E4[nT3.num]; 
     dT3.e5[nT3.num] = dT3.E5[nT3.num]; dT3.e6[nT3.num] = dT3.E6[nT3.num];
    }

   if(nT3.Tnew != nT3.Old)
    {
     nT3.reset = -1;
     //--+ ��������� ������ � ������� �������� ��������� T3.limit ������� T3Series()
     if (nT3.Tnew > nT3.Old)
       {
        Print(StringConcatenate("T3Series number = ", nT3.num,
                   ". ������!!! �������� nT3.limit ������� T3Series() ������ ��� ����������"));
       }
     else 
       { 
        int nT3.LimitERROR = nT3.limit + 1 - iBarShift(NULL, 0, nT3.Old, TRUE);
        Print(StringConcatenate("T3Series number = ", nT3.num,
            ". ������!!! �������� nT3.limit ������� T3Series() ������ ��� ���������� �� ",
                                                                                nT3.LimitERROR));
       }
     //--+ 
     return(0);
   }
  //----+ +------------------------------------------------------------------------------------------++
  }
//+--- ���������� �������� ���������� +--+
if (nT3.bar == 1)
 if (nT3.limit != 1)
  {
   nT3.TIME[nT3.num] = Time[2];
   dT3.E1[nT3.num] = dT3.e1[nT3.num]; 
   dT3.E2[nT3.num] = dT3.e2[nT3.num]; 
   dT3.E3[nT3.num] = dT3.e3[nT3.num]; 
   dT3.E4[nT3.num] = dT3.e4[nT3.num]; 
   dT3.E5[nT3.num] = dT3.e5[nT3.num]; 
   dT3.E6[nT3.num] = dT3.e6[nT3.num];
  }
//+---+ +--------------------------------+

//---- <<< ���������� dT3.T3 >>> --------------------------------------------------------------------+
dT3.e1[nT3.num] = dT3.w1[nT3.num] * dT3.series      + dT3.w2[nT3.num] * dT3.e1[nT3.num];
dT3.e2[nT3.num] = dT3.w1[nT3.num] * dT3.e1[nT3.num] + dT3.w2[nT3.num] * dT3.e2[nT3.num];
dT3.e3[nT3.num] = dT3.w1[nT3.num] * dT3.e2[nT3.num] + dT3.w2[nT3.num] * dT3.e3[nT3.num];
dT3.e4[nT3.num] = dT3.w1[nT3.num] * dT3.e3[nT3.num] + dT3.w2[nT3.num] * dT3.e4[nT3.num];
dT3.e5[nT3.num] = dT3.w1[nT3.num] * dT3.e4[nT3.num] + dT3.w2[nT3.num] * dT3.e5[nT3.num];
dT3.e6[nT3.num] = dT3.w1[nT3.num] * dT3.e5[nT3.num] + dT3.w2[nT3.num] * dT3.e6[nT3.num];
//----  
dT3.T3 = dT3.c1[nT3.num] * dT3.e6[nT3.num] 
                      + dT3.c2[nT3.num] * dT3.e5[nT3.num] 
                                     + dT3.c3[nT3.num] * dT3.e4[nT3.num] 
                                                   + dT3.c4[nT3.num] * dT3.e3[nT3.num];
//---- ----------------------------------------------------------------------------------------------+

//----++ �������� �� ������ � ���������� ������������ ���� ������� T3Series()
nT3.Error = GetLastError();
if (nT3.Error > 4000)
  {
    Print(StringConcatenate("T3Series number = ", nT3.num,
                            ". ��� ���������� ������� T3Series() ��������� ������!!!"));
    Print(StringConcatenate("T3Series number = ", nT3.num, ". ", T3_ErrDescr(nT3.Error)));  
    return(0.0);
  }
nT3.reset = 0;
if (nT3.bar < nT3.MaxBar - nT3.Period)
                             return(dT3.T3);
else return(0.0);
//---- ���������� ���������� �������� ������� T3.Series 
}
//---- ---------------------------------------------------------------------------------------------------------+


//+X=============================================================================================X+
// T3SeriesResize - ��� �������������� ������� ��� ��������� �������� �������� ����������         | 
// ������� T3Series. ������ ���������: T3SeriesResize(5); ��� 5 - ��� ���������� ��������� �      | 
// T3Series()� ������ ����������. ��� ��������� � �������  T3SeriesResize ������� ���������       |
// � ���� ������������� ����������������� ���������� ��� ��������                                 |
//+X=============================================================================================X+
int T3SeriesResize(int nT3Resize.Size)
 {
//----+
  if(nT3Resize.Size < 1)
   {
    Print("T3SeriesResize: ������!!! �������� nT3Resize.Size �� ����� ���� ������ �������!!!");
    nT3.Resize = -1;  
    return(0);
   }
  //----+    
  int nT3Resize.reset, nT3Resize.cycle;
  //--+
  while(nT3Resize.cycle == 0)
   {
    //----++ <<< ��������� �������� �������� ���������� >>>  +-----------------+
    if(ArrayResize(dT3.e1,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.e2,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.e3,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.e4,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.e5,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.e6,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.E1,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.E2,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.E3,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.E4,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.E5,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.E6,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.n,    nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.c1,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.c2,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.c3,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.c4,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.w1,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.w2,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.b2,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(dT3.b3,   nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    if(ArrayResize(nT3.TIME, nT3Resize.Size) == 0){nT3Resize.reset = -1; break;}
    //----++-------------------------------------------------------------------+
    nT3Resize.cycle = 1;
   }
  //--+
  if(nT3Resize.reset==-1)
   {
    Print("T3SeriesResize: ������!!! �� ������� �������� ������� �������� ���������� ������� T3Series().");
    int nT3Resize.Error = GetLastError();
    if(nT3Resize.Error > 4000)
              Print(StringConcatenate("T3SeriesResize(): ", T3_ErrDescr(nT3Resize.Error)));       
    nT3.Resize = -2;
    return(0);
   }
  else  
   {
    Print(StringConcatenate("T3SeriesResize: T3Series Size = ", nT3Resize.Size));
    nT3.Resize = nT3Resize.Size;
    return(nT3Resize.Size);
   }  
//----+
 }
//--+ --------------------------------------------------------------------------------------------+
/*
//+X=============================================================================================X+
T3SeriesAlert - ��� �������������� ������� ��� ��������� ������ � ������� ������� ����������      |
������� T3Series.                                                                                 |
  -------------------------- ������� ���������  --------------------------                        |
T3SeriesAlert.Number                                                                              |
T3SeriesAlert.ExternVar �������� ������� ���������� ��� ��������� nT3.Length                      |
T3SeriesAlert.name ��� ������� ���������� ��� nT3.Phase, ���� T3SeriesAlert.Number=1              |
  -------------------------- ������ �������������  -----------------------                        |
  int init()                                                                                      |
//----                                                                                            |
����� �����-�� ������������� ���������� � �������                                                 |
                                                                                                  |
//---- ��������� ������� �� ������������ �������� ������� ����������                              |                                                                                                                  
T3SeriesAlert(0,"Length1",Length1);                                                               |
T3SeriesAlert(0,"Length2",Length2);                                                               |
//---- ���������� �������������                                                                   |
return(0);                                                                                        |
}                                                                                                 |
//+X=============================================================================================X+
*/
void T3SeriesAlert(int T3SeriesAlert.Number, string T3SeriesAlert.name, int T3SeriesAlert.ExternVar)
 {
  //---- ��������� ������� �� ������������ �������� ������� ���������� 
  if (T3SeriesAlert.Number == 0)
      if (T3SeriesAlert.ExternVar < 1)
          Alert(StringConcatenate("�������� ", T3SeriesAlert.name, " ������ ���� �� ����� 1",
                  " �� ����� ������������ ", T3SeriesAlert.ExternVar, " ����� ������������  1"));
   /*  
  if(T3SeriesAlert.Number==1)
   {
    if(T3SeriesAlert.ExternVar<-100)
          {Alert("�������� "+T3SeriesAlert.name+" ������ ���� �� -100 �� +100" 
          + " �� ����� ������������ "+T3SeriesAlert.ExternVar+  " ����� ������������ -100");}
    if(T3SeriesAlert.ExternVar> 100)
          {Alert("�������� "+T3SeriesAlert.name+" ������ ���� �� -100 �� +100" 
          + " �� ����� ������������ "+T3SeriesAlert.ExternVar+  " ����� ������������  100");}
   }
   */
 }
//--+ -------------------------------------------------------------------------------------------+


// ������� ������ �������� ��������� 01.12.2006  
//+X================================================================X+
//|                                        T3_ErrDescr_RUS(MQL4).mqh |
//|                      Copyright � 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+X================================================================X+
string T3_ErrDescr(int error_code)
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


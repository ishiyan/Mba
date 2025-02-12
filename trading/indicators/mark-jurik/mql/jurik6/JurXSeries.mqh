//Version  January 7, 2009 Final
//+X================================================================X+
//|                                                 JurXSeries().mqh |
//|                      JurX code: Copyright � 1998, Jurik Research |
//|                                          http://www.jurikres.com | 
//|    JurXSeries()MQL4 CODE: Copyright � 2009,     Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+
  /*
  
  +-------------------------------------- <<< ������� JurXSeries() >>> -----------------------------------------------+

  +-----------------------------------------+ <<< ���������� >>> +----------------------------------------------------+

  �������  JurXSeries()  �������������  ���  �������������  ��������� JurX ��� ��������� ����� ����������� ���������� �
  ���������,  ���  ������  �������  �������������  ����������  ��  ���� ��������. � ������ ��������� ���� ������� �����
  ��������������  �����������,  �������  ����  �����  ��  ����������  JRSX. ���� ������� �������� � ����� (����������):
  MetaTrader\experts\include\  �������  ������,  ��� ���� nJurX.bar ������, ��� nJurX.MaxBar-3*nJurX.Length, �� �������
  JurXSeries()  ���������� �������� ������ ����! �� ���� ����! �, �������������, ����� �������� �� ����� ��������������
  �  �����������  �����-����  ����� � ������� ����������! ��� ������ ������� JurXSeries() ������������ ��������� ��� �
  �������������  �  ����������������  �����������,  �  �������  ����������  �������.  ���  ������  ������� JurXSeries()
  ������������ ��������� ��� � ������������� � ���� ����������, ������� ��������� ������� � ��� �������� � �����������
  ����  ����������  �����  �  ����������! ��� ��������� ����������� � ��������� � �������������� ������� JurXSeries, ��
  �������������  ����������  ������  �����  ������������  �  nJurX....  ���  dJurX....  ������� JurXSeries() ����� ����
  ������������ �� ���������� ���� ������ ���������������� �������, �� ��� ���� ������� ��������� ��� ����, ��� � ������
  ���������  �  �����  ����������������  �������  �  ������� ��������� � JurXSeries() ������ ���� ���� ���������� �����
  (nJurX.number). 
  

  +-------------------------------------+ <<< ������� ��������� >>> +-------------------------------------------------+

  nJurX.number - ���������� ����� ��������� � ������� JurX.Series(). (0, 1, 2, 3 �.�.�....)
  nJurX.din -    ��������, ����������� �������� ��������� nJurX.Length �� ������ ����. 0 - ������ ��������� ����������, 
                 ����� ������ �������� - ����������.
  nJurX.MaxBar - ������������  ��������,  �������  �����  ���������  �����  ���������������  ����(bar).   ������  ����� 
                 Bars-1-period; ��� ������ "period" - ��� ���������� �����, �� ������� �������� ��������   dJurX.series 
                 �� ��������������;
  nJurX.limit -  ���������� ��� �� ������������  ����� ����  ����  �  ��  ����� ���������� �������������� ����,  ������ 
                 ����� Bars-IndicatorCounted()-1;
  nJurX.Length - ������� �����������
  dJurX.series - �������  ��������, �� �������� ������������ ������ ������� JurXSeries();
  nJurX.bar -    ����� ���������������  ����,  �������� ������  ���������� ���������� ����� �� ������������� �������� � 
                 ��������.   ������ ��� ������������ �������� ������ ������ ��������� �������� ��������� nJurX.limit!!!

  +------------------------------------+ <<< �������� ��������� >>> +-------------------------------------------------+

  JurXSeries() - �������� ������� dJurX.  ���  ���������  nJurX.bar  ������  ���   nJurX.MaxBar-nJurX.Length    ������� 
                 JurXSeries() ������ ���������� ����!!!
  nJurX.reset -  ��������, ������������ �� ������ ��������,  ���������� �� 0 , ���� ��������� ������ � ������� �������,
                 0, ���� ������ ������ ���������. ���� �������� ����� ���� ������ ����������, �� �� ���������!!!

  +-----------------------------------+ <<< ������������� ������� >>> +-----------------------------------------------+

  ����� ����������� � ������� JurXSeries(), ����� ���������� ��� ������������ ����� ����� 0, (� ��� ����� ��� ������� �
  �����  �������������  �����������������  ����������  ���  ��������)  �������  ��������  �������  ����������  ��������
  ����������   �������,   ���  �����  ����������  ����������  �  �������  JurXSeries()  �����  ���������������  �������
  JurXSeriesResize()   ��   ����������   �����������:  JurXSeriesResize(nJurX.number+1);  ����������  �������  ��������
  nJurX.number(MaxJurX.number)  ������  ����������  ���������  �  �������  JurXSeries,  ��  ���� �� ������� ������, ���
  ������������ nJurX.number. 
  
  +--------------------------------------+ <<< ��������� ������ >>> +-------------------------------------------------+
  
  ��� ������� ����������� � ��������� �� ���� ����� ��������� ������, ��� ��������� ������ ������� ������� �������� ���
  ����.  ���  ������  ������� JurXSeries() ����� � ��� ���� � ����� \MetaTrader\EXPERTS\LOGS\. ����, ����� ���������� �
  �������  JurXSeries()  � ����, ������� ������������� �������, �������� MQL4 ������, �� ������� ������� � ��� ���� ���
  ������  � ���������� ������. ���� ��� ���������� ������� JurXSeries() � ��������� JurXSeries() ��������� MQL4 ������,
  ��  �������  �����  �������  �  ���  ���� ��� ������ � ���������� ������. ��� ������������ ������� ������ ��������� �
  �������  JurXSeries()  nJurX.number  ��� �������� ����������� ������� �������� ���������� nJurXResize.Size � ��� ����
  ����� �������� ��������� � �������� ����������� ���� ����������. ����� � ��� ���� ������� ���������� ��� ������������
  �����������  ���������  nJurX.limit.  ����  ���  ���������� ������� ������������� init() ��������� ���� ��� ���������
  ��������  ��������  ����������  �������  JurXSeries(),  �� ������� JurXSeriesResize() ������� � ��� ���� ���������� �
  ���������  ���������  ��������  �������� ����������. ���� ��� ��������� � ������� JurXSeries() ����� ������� ��������
  �����  ����  �������� ���������� ������������������ ��������� ��������� nJurX.bar, �� � ��� ���� ����� �������� � ���
  ����������. ������� ������, ��� ��������� ������ ������������ ���� ����� ��������� ���������� ������ � ��� ����������
  �  �������,  ����  �������  JurXSeries()  �����  � ��� ���� ����� ��������� ������, �� ��������� �� ������� � �������
  �������  �������������.  � ��������� ���������� ���������� ������� JurXSeries() ����� ������ ������ � ��� ���� ������
  ���  ����������  ������ ������������ �������. ���������� ���������� ������ ��������� �������� �������� ���������� ���
  ������������ ���������� ��� ��������, ������� ���������� ��� ������ ������ ������� init(). 
  
  +---------------------------------+ <<< ������ ��������� � ������� >>> +--------------------------------------------+


//----+ ����������� ������� JurXSeries()
#include <JurXSeries.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- ����������� ����� ���������� �������
SetIndexStyle (0,DRAW_LINE); 
//---- 1 ������������ ������ ����������� ��� ����� (��� ����� ��������� ������� JurXSeries() ���� ������ ����������� �� �����!!!)
SetIndexBuffer(0,Ind_Buffer);
//----+ ��������� �������� ��������� ���������� ������� JurXSeries, nJurX.number=1(���� ��������� � ������� JurXSeries)
if(JurXSeriesResize(1)==0)return(-1);
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
  //----+ ��������� � ������� JurXSeries()�� ������� 0 ��� ������� ������ Ind_Buffer[], 
  //��������� nJurX.Phase � nJurX.Length �� �������� �� ������ ���� (nJurX.din=0)
  double Resalt=JurXSeries(0,0,MaxBar,limit,Length,Series,bar,reset);
  if (reset!=0)return(-1);
  Ind_Buffer[bar]=Resalt;
 }
return(0);
}
//----+ 

*/
//+X================================================================X+
//|  JurXSeries() function                                           |
//+X================================================================X+    

//----++ <<< �������� � ������������� ���������� >>> +-------------------+
double dJurX.f1[1], dJurX.f2[1], dJurX.f3[1], dJurX.f4[1], dJurX.f5[1];
double dJurX.f6[1], dJurX.Kg[1], dJurX.Hg[1], dJurX.F1[1], dJurX.F2[1];
double dJurX.F3[1], dJurX.F4[1], dJurX.F5[1], dJurX.F6[1];
int    nJurX.w [1], nJurX.TIME[1], nJurX.Error, nJurX.Tnew, nJurX.Told;
double dJurX.VEL1, dJurX.VEL2, dJurX.JurX, nJurX.Resize;
//----++ +---------------------------------------------------------------+
//----++ <<< ���������� ������� JurXSeries() >>> +-------------------------+
double JurXSeries
 (
  int nJurX.number,int    nJurX.din,    int nJurX.MaxBar, int  nJurX.limit,
  int nJurX.Length,double dJurX.series, int nJurX.bar,    int& nJurX.reset
 )
//----++-------------------------------------------------------------------+
{
nJurX.reset = 1;
//=====+ <<< �������� �� ������ >>> --------------------------------------------------------------------+
if (nJurX.bar == nJurX.limit)
 {
  //----++ �������� �� ������������� ������� JurXSeries()
  if(nJurX.Resize < 1)
   {
    Print(StringConcatenate("JurXSeries number = ",nJurX.number,
         ". �� ���� ������� ��������� �������� ��������� ���������� �������� JurXSeriesResize()"));
    if(nJurX.Resize == 0)
        Print(StringConcatenate("JurXSeries number = ",nJurX.number,
                ". ������� �������� ��������� � ������� JurXSeriesResize() � ���� �������������"));
         
    return(0.0);
   }
  //----++ �������� �� ������ � ���������� ������������ ����, ����������������� ������� JurXSeries()
  nJurX.Error = GetLastError();
  if(nJurX.Error > 4000)
   {
      Print(StringConcatenate("JurXSeries number = ",nJurX.number,
            ". � ����, �������������� ��������� � ������� JurXSeries() number = ",
                                                                      nJurX.number," ������!!! "));
      Print(StringConcatenate("JurXSeries number = ",nJurX.number,". ", JurX_ErrDescr(nJurX.Error))); 
   } 

  //----++ �������� �� ������ � ������� ���������� nJurX.number � nJurXResize.Size
  if (ArraySize(dJurX.f1) < nJurX.number) 
   {
    Print(StringConcatenate("JurXSeries number = ",nJurX.number,
                ". ������!!! ����������� ������ �������� ���������� nJurX.number ������� JurXSeries()"));
    Print(StringConcatenate("JurXSeries number = ",nJurX.number,
           ". ��� ����������� ������ ��������  ���������� nJurXResize.Size ������� JurXSeriesResize()"));
    return(0.0);
   }
 }
//----++ +-----------------------------------------------------------------------------------------------+ 
 
if (nJurX.bar > nJurX.MaxBar){nJurX.reset = 0; return(0.0);}
if (nJurX.bar == nJurX.MaxBar || nJurX.din != 0)
 {
  //----++ <<< ������ �������������  >>> +------------------+
  if (nJurX.Length <1  ) nJurX.Length = 1;
  if (nJurX.Length >= 6) 
             nJurX.w[nJurX.number] = nJurX.Length - 1; 
  else nJurX.w[nJurX.number] = 5; 
  dJurX.Kg[nJurX.number] = 3 / (nJurX.Length + 2.0); 
  dJurX.Hg[nJurX.number] = 1.0 - dJurX.Kg[nJurX.number];
  //----++--------------------------------------------------+
 }
//----++ �������� �� ������ � ������������������ ��������� ���������� nJurX.bar
if (nJurX.limit >= nJurX.MaxBar)
 if (nJurX.bar == 0)
  if (nJurX.din == 0)
   if (nJurX.MaxBar > 3 * nJurX.Length)
    if (nJurX.TIME[nJurX.number] == 0)
              Print(StringConcatenate("JurXSeries number = ",nJurX.number,
                              ". ������!!! �������� ���������� ������������������", 
                                 " ��������� ��������� nJurX.bar ������� ���������� �����!!!"));  
//----++      
if (nJurX.bar == nJurX.limit)
 if (nJurX.limit < nJurX.MaxBar)          
  {
  //----+ <<< �������������� �������� ���������� >>> +-------------------------------------------------+
   nJurX.Tnew = Time[nJurX.limit + 1];
   nJurX.Told = nJurX.TIME[nJurX.number];
   //--+
   if (nJurX.Tnew == nJurX.Told)
     {
      dJurX.f1[nJurX.number] = dJurX.F1[nJurX.number]; dJurX.f2[nJurX.number] = dJurX.F2[nJurX.number]; 
      dJurX.f3[nJurX.number] = dJurX.F3[nJurX.number]; dJurX.f4[nJurX.number] = dJurX.F4[nJurX.number]; 
      dJurX.f5[nJurX.number] = dJurX.F5[nJurX.number]; dJurX.f6[nJurX.number] = dJurX.F6[nJurX.number];
     }
   //--+ �������� �� ������
   if(nJurX.Tnew != nJurX.Told)
     {
      nJurX.reset = -1;
      //--+ ��������� ������ � ������� �������� ��������� JurX.limit ������� JurX.Series()
      if (nJurX.Tnew > nJurX.Told)
       {
        Print(StringConcatenate("JurXSeries number = ",nJurX.number,
               ". ������!!! �������� nJurX.limit ������� JurX.Series() ������ ��� ����������"));
       }
      else 
       { 
        int nJurX.LimitERROR=nJurX.limit+1-iBarShift(NULL,0,nJurX.Told,TRUE);
        Print(StringConcatenate("JurX.Series number = ",nJurX.number,
             ". ������!!! �������� nJurX.limit ������� JurX.Series() ������ ��� ���������� �� ",
                                                                                 nJurX.LimitERROR));
       }
      //--+ 
      return(0);
     }
  //----+------------------------------------------------------------------------------------------------+
  }
//+--- ���������� �������� ���������� +
if (nJurX.bar == 1)
 if (nJurX.limit != 1)
  {
   nJurX.TIME[nJurX.number] = Time[2];
   dJurX.F1[nJurX.number] = dJurX.f1[nJurX.number]; 
   dJurX.F2[nJurX.number] = dJurX.f2[nJurX.number]; 
   dJurX.F3[nJurX.number] = dJurX.f3[nJurX.number]; 
   dJurX.F4[nJurX.number] = dJurX.f4[nJurX.number]; 
   dJurX.F5[nJurX.number] = dJurX.f5[nJurX.number]; 
   dJurX.F6[nJurX.number] = dJurX.f6[nJurX.number];
  }
//+---+

//---- <<< ���������� dJurX.JurX >>> ----------------------------------------------------------------------------------------+
dJurX.f1[nJurX.number] = dJurX.Hg[nJurX.number] * dJurX.f1[nJurX.number] + dJurX.Kg[nJurX.number] * dJurX.series;
dJurX.f2[nJurX.number] = dJurX.Kg[nJurX.number] * dJurX.f1[nJurX.number] + dJurX.Hg[nJurX.number] * dJurX.f2[nJurX.number];
dJurX.VEL1             =        1.5             * dJurX.f1[nJurX.number] -        0.5             * dJurX.f2[nJurX.number];
dJurX.f3[nJurX.number] = dJurX.Hg[nJurX.number] * dJurX.f3[nJurX.number] + dJurX.Kg[nJurX.number] * dJurX.VEL1;
dJurX.f4[nJurX.number] = dJurX.Kg[nJurX.number] * dJurX.f3[nJurX.number] + dJurX.Hg[nJurX.number] * dJurX.f4[nJurX.number];
dJurX.VEL2             =        1.5             * dJurX.f3[nJurX.number] -        0.5             * dJurX.f4[nJurX.number];
dJurX.f5[nJurX.number] = dJurX.Hg[nJurX.number] * dJurX.f5[nJurX.number] + dJurX.Kg[nJurX.number] * dJurX.VEL2;
dJurX.f6[nJurX.number] = dJurX.Kg[nJurX.number] * dJurX.f5[nJurX.number] + dJurX.Hg[nJurX.number] * dJurX.f6[nJurX.number];
dJurX.JurX              =       1.5             * dJurX.f5[nJurX.number] -        0.5             * dJurX.f6[nJurX.number];
//---- ----------------------------------------------------------------------------------------------------------------------+

//----++ �������� �� ������ � ���������� ������������ ���� ������� JurXSeries()
nJurX.Error = GetLastError();
if(nJurX.Error > 4000)
  {
    Print(StringConcatenate("JurXSeries number = ",nJurX.number,
                                    ". ��� ���������� ������� JurXSeries() ��������� ������!!!"));
    Print(StringConcatenate("JurXSeries number = ",nJurX.number,". ",JurX_ErrDescr(nJurX.Error)));  
    return(0.0);
  }
nJurX.reset = 0;
if (nJurX.bar < nJurX.MaxBar - nJurX.Length)
                                   return(dJurX.JurX);
else return(0.0);

//---- ���������� ���������� �������� ������� JurX.Series -------+ 
}
//+X=============================================================================================X+
// JurXSeriesResize - ��� �������������� ������� ��� ��������� �������� ��������� ����������      | 
// ������� JurXSeries. ������ ���������: JurXSeriesResize(5); ��� 5 - ��� ���������� ��������� �  | 
// JurXSeries()� ������ ����������. ��� ��������� � �������  JurXSeriesResize ������� ���������   |
// � ���� ������������� ����������������� ���������� ��� ��������                                 |
//+X=============================================================================================X+
int JurXSeriesResize(int nJurXResize.Size)
 {
//----+
  if(nJurXResize.Size < 1)
   {
    Print("JurXSeriesResize: ������!!! �������� nJurXResize.Size �� ����� ���� ������ �������!!!"); 
    nJurX.Resize = -1; 
    return(0);
   }  
  int nJurXResize.reset,nJurXResize.cycle;
  //--+
  while(nJurXResize.cycle == 0)
   {
    //----++ <<< ��������� �������� ��������� ���������� >>>  +---------------------+
    if(ArrayResize(dJurX.f1,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.f2,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.f3,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.f4,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.f5,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.f6,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.Kg,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.Hg,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F1,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F2,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F3,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F4,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F5,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(dJurX.F6,   nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(nJurX.w,    nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    if(ArrayResize(nJurX.TIME, nJurXResize.Size) == 0){nJurXResize.Size = -1; break;}
    //----++------------------------------------------------------------------------+
    nJurXResize.cycle = 1;
   }
  //--+
  if(nJurXResize.reset == -1)
   {
    Print(StringConcatenate("JurXSeriesResize: ������!!!",
                    " �� ������� �������� ������� ��������� ���������� ������� JurXSeries()."));
    int nJurXResize.Error = GetLastError();
    if(nJurXResize.Error > 4000)
                Print(StringConcatenate("JurXSeriesResize: ",JurX_ErrDescr(nJurXResize.Error)));             
    nJurX.Resize = -2;
    return(0);
   }
  else  
   {
    Print(StringConcatenate("JurXSeriesResize: JurXSeries Size = ",nJurXResize.Size));                                                                                                               
    nJurX.Resize = nJurXResize.Size;
    return(nJurXResize.Size);
   }  
//----+
 }

/*
//+X==================================================================================================X+
JurXSeriesAlert - ��� �������������� ������� ��� ��������� ������ � ������� ������� ����������         |
������� JurSeries.                                                                                     |
  -------------------------- ������� ���������  --------------------------                             |
JurXSeriesAlert.Number                                                                                 |
JurXSeriesAlert.ExternVar �������� ������� ���������� ��� ��������� nJurX.Phase                        |
JurXSeriesAlert.name ��� ������� ���������� ��� ��������� nJurX.Length, ���� JurXSeriesAlert.Number=0. |                                                  
  -------------------------- ������ �������������  -----------------------                             |
  int init()                                                                                           |
//----                                                                                                 |
����� �����-�� ������������� ���������� � �������                                                      |
                                                                                                       |
//---- ��������� ������� �� ������������ �������� ������� ����������                                   |                                                           
JurXSeriesAlert(0,"Length1",Length1);                                                                  |
JurXSeriesAlert(0,"Length2",Length2);                                                                  |
//---- ���������� �������������                                                                        |
return(0);                                                                                             |
}                                                                                                      |
//+X==================================================================================================X+
*/
void JurXSeriesAlert
 (
  int JurXSeriesAlert.Number, string JurXSeriesAlert.name, int JurXSeriesAlert.ExternVar
 )
 {
  //---- ��������� ������� �� ������������ �������� ������� ���������� ==========================+ 
   if(JurXSeriesAlert.Number == 0)
     if(JurXSeriesAlert.ExternVar < 1)
          {Alert(StringConcatenate("�������� ",JurXSeriesAlert.name," ������ ���� �� ����� 1", 
                  " �� ����� ������������ ",JurXSeriesAlert.ExternVar," ����� ������������  1"));}
 }

// ������� ������ �������� ��������� 01.12.2006  
//+X================================================================X+
//|                                      JurX_ErrDescr_RUS(MQL4).mqh |
//|                      Copyright � 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+X================================================================X+
string JurX_ErrDescr(int error_code)
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



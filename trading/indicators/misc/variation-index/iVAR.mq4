//+------------------------------------------------------------------+
//|                                                         iVAR.mq4 |
//|                                        (C)opyright � 2008, Ilnur |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

//   ��������� ���������� ������ �������� �������� ����, ������������
// �� ����������� �������������� ��������� ����� 2^n. ������ ��������
// ����������, ��� ����������� �� ��������� ���� � ��������� ��� ��������
// ������������, ��� �� ��� ����� ���� ��������.

// �.�. ��������� � ��. - ����������� ������������ �������� � ���������
// ������ ����������� ��������� �����.

#property copyright "(C)opyright � 2008, Ilnur"
#property link      "http://www.metaquotes.net"
//---- ��������� ����������
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_level1 0.5
//---- ������� ���������
extern int n = 5;
extern int nBars = 1000;
//---- ����� ����������
double ibuffer[];
//+------------------------------------------------------------------+
//| ������� ������������� ����������                                 |
//+------------------------------------------------------------------+
int init()
{
//---- ��������� ���������� ���������
   SetIndexBuffer(0,ibuffer);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexDrawBegin(0,Bars-nBars);
   SetIndexLabel(0,"iVAR");
//---- "�������� ���" ������������ � ���� ����������
   IndicatorShortName("iVAR("+n+")");
   return(0);
}
//+------------------------------------------------------------------+
//| �������� ������� ����������                                      |
//+------------------------------------------------------------------+
int start()
{
   int i, j, k, nTotal, nCountedBars = IndicatorCounted();
   int ihigh, ilow, nInterval;
   double Delta, X�, Y�, Sx, Sy, Sxx, Sxy;
//---- ��������� ����������� ��� ����� ����������
   if(nCountedBars==0) nTotal = nBars;
   if(nCountedBars>0) nTotal = Bars-nCountedBars-1;
//---- �������� ���� ����������
   for(j=nTotal; j>=0; j--)
   {
      Sx = 0; Sy = 0; Sxx = 0; Sxy = 0;
      for(i=0; i<=n; i++)
      {
         nInterval = MathPow(2,n-i);
      //---- ��������� ������� ������������ � ����������� ��� �� ���������
         for(Delta=0, k=0; k<MathPow(2,i); k++)
         {
            ihigh = iHighest(Symbol(),0,MODE_HIGH,nInterval,nInterval*k+j);
            ilow = iLowest(Symbol(),0,MODE_LOW,nInterval,nInterval*k+j);
            Delta += High[ihigh]-Low[ilow];
         }
      //---- ��������� ���������� �������� � ������� ��������������� ��������
         X� = (n-i)*MathLog(2.0);
         Y� = MathLog(Delta);
      //---- ����������� ������ ��� ���������� ������������� ����� ��������� � ������� ���
         Sx += X�; 
         Sy += Y�;
         Sxx += X�*X�; 
         Sxy += X�*Y�;
      }
   //---- ��������� ������ �������� (����������� ������� ����� ���������)
      ibuffer[j] = -(Sx*Sy-(n+1)*Sxy)/(Sx*Sx-(n+1)*Sxx);
   }
   return(0);
}
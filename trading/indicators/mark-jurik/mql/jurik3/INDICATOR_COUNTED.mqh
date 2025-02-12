 /*
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                            INDICATOR_COUNTED.mqh |
//|                           Copyright � 2006,     Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
/*
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
 INDICATOR_COUNTED() - ��� �������������� ������� ��� �������� ���������� ��� ������������ �����  | 
 ����������. Ÿ ������� ����������� ����������� � ���, ��� ��� ��������� �� �������������         |
 ��������� �� ���� ����� ��� ����������� � ���������. �� ���� ��� ����������� � ��������� ���     |
 ������� � ������� ��  ����������� ������� IndicatorCounted() �� ����� ���������� ����������     |
 ������������ �� ����������� � ��������� �����, � �� ����!          �������  INDICATOR_COUNTED()  | 
 ������������� ��� ������ ������� IndicatorCounted() ��� �������� ���������                       |
 INDICATOR_COUNTED.Input=0; ������� ���������� ���������� ��� ������������ �����, ��� ��������    |
 ��������� INDICATOR_COUNTED.Input = 1; ���������� �������� ������� �������� ����, ��� �������    |
 �� ��� ������ ��� ��������� ������ ������� int start() ��������� �������� ���������� ���         | 
 ������������ �����.    ��� �������� ��������� INDICATOR_COUNTED.Input = -1; ����������           |       
 ��������� ������� �������� ����, ���� ��� ����������, ��� ������������� ��������� return(-1);    |
 ��� ������� int start().                                                                         |
 ������ ���������:                                                                                |
                                                                                                  |
//----+ �������� ����� ���������� � ��������� ��� ������������ �����                              |
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������  |
incounted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);                                        |
//---- �������� �� ��������� ������                                                               |
if (counted_bars<0){INDICATOR_COUNTED(-1); return(-1);}                                           |
//---- ��������� ������������ ��� ������ ���� ����������                                          |
if (counted_bars>0) counted_bars--;                                                               |
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� ��������  ����� |
int limit=Bars-1-counted_bars;                                                                    |
//----                                                                                            |
for(bar=limit;bar>=0;bar--) { ��� ������ ���������� }                                             |
���� � ������ ���������� ���� ��������� return(-1) ��� ������� int start(); �� ��� �������        |
�������� �� {INDICATOR_COUNTED(-1);return(-1);}                                                   |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
*/
int  INDICATOR_COUNTED(int INDICATOR_COUNTED.Input) 
//----+ 
{   
  int INDICATOR_COUNTED.counted_bars;
  //----+ xxxxxxxxxxx
  if (INDICATOR_COUNTED.Input == 1)
    {
      //---- �������� ���������� � ��������� �� ��������
      static int INDICATOR_COUNTED.T2, INDICATOR_COUNTED.Period; 
      INDICATOR_COUNTED.counted_bars=IndicatorCounted(); 
      if (INDICATOR_COUNTED.counted_bars<0)
       {
        //INDICATOR_COUNTED.T2=0; 
        return(INDICATOR_COUNTED.counted_bars);
       }
       //----+ �������� ������� �������� �������������� ������������� ���� 
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
          //������ ���������� ��������� � ������� INDICATOR_COUNTED ��� ������������ ������ ���������� 
          Print("INDICATOR_COUNTED: �������� �������� ������ ��� ����������� � ���������");
          Print("INDICATOR_COUNTED: ������������� ������������ ��� �� ������");
          Print("INDICATOR_COUNTED: �������� ���������� ��� ������������ ����� ���������� ���������� ");
          Print("INDICATOR_COUNTED: ������� ����� ���������� ��� ������������ ����� ������ ����");
          Print("INDICATOR_COUNTED: ����� ��������� ������ �������� ���������� �� ���� �����");
        //PlaySound("wait.wav");
          return(0); 
         }
  //----+ xxxxxxxxxxx
  if ((INDICATOR_COUNTED.Input==0)&&(INDICATOR_COUNTED.Period==Period()))
    {
     if((INDICATOR_COUNTED.counted_bars==0)&&(IsConnected()==TRUE))
      { 
       //Print("INDICATOR_COUNTED: �������� �������� ������ ��� ����������� � ���������");  
       //Print("INDICATOR_COUNTED: ������ ������� INDICATOR_COUNTED() ��������� ���������� ���������� ������������ �����");
       if (INDICATOR_COUNTED.T2 == 0)
         {
          //������ ���������� ��������� � ������� INDICATOR_COUNTED ��� ������������ ������ ���������� 
          Print("INDICATOR_COUNTED: �������� �������� ������ ��� ����������� � ���������");
          Print("INDICATOR_COUNTED: ������������� ������������ ��� �� ������");
          Print("INDICATOR_COUNTED: �������� ���������� ��� ������������ ����� ���������� ���������� ");
          Print("INDICATOR_COUNTED: ������� ����� ���������� ��� ������������ ����� ������ ����");
          Print("INDICATOR_COUNTED: ����� ��������� ������ �������� ���������� �� ���� �����");
        //PlaySound("wait.wav");
          return(0); 
         }
        //----+ ����� �������������� ������������� ���� �� ������� ��� �������� 
       int  INDICATOR_COUNTED.BarShift=iBarShift(NULL,0,INDICATOR_COUNTED.T2,TRUE); 
       if ((INDICATOR_COUNTED.BarShift<2)||(INDICATOR_COUNTED.T2!=Time[INDICATOR_COUNTED.BarShift]))
         {
          //������ ���������� ��������� � ������� INDICATOR_COUNTED ��� ������������ ������ ���������� 
          Print("INDICATOR_COUNTED: �������� �������� ������ ��� ����������� � ���������");
          Print("INDICATOR_COUNTED: ������������� ������������ ��� �� ������");
          Print("INDICATOR_COUNTED: �������� ���������� ��� ������������ ����� ���������� ���������� ");
          Print("INDICATOR_COUNTED: ������� ����� ���������� ��� ������������ ����� ������ ����");
          Print("INDICATOR_COUNTED: ����� ��������� ������ �������� ���������� �� ���� �����");
        //PlaySound("wait.wav");
          return(0); 
         }
       int INDICATOR_COUNTED.Resalt=Bars-1-INDICATOR_COUNTED.BarShift+2;
       //������ ���������� ��������� � ������� INDICATOR_COUNTED ��� ���������� ������ ���������� 
     //Print("INDICATOR_COUNTED: �������� �������� ������ ��� ����������� � ���������"); 
     //Print("INDICATOR_COUNTED: ������ ������� ��������� ���������� ���������� ������������ �����"); 
     //Print("INDICATOR_COUNTED: ������������� ������������ ��� ������");
     //Print("INDICATOR_COUNTED: ���������� ��� ������������ ����� ����� ����� "+INDICATOR_COUNTED.Resalt+"");
     //Print("INDICATOR_COUNTED: ����� ��������� �������� ���������� ����� �� "+INDICATOR_COUNTED.BarShift+" �����");
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
    Print("INDICATOR_COUNTED: ������ � ������� ����������");
    Print("INDICATOR_COUNTED: ������ ������� int start() ����� �������� ���������� return(-1)");
  //PlaySound("stops.wav");  
    return(0); 
   }
  return(INDICATOR_COUNTED.counted_bars);
}
//--+ --------------------------------------------------------------------------------------------+


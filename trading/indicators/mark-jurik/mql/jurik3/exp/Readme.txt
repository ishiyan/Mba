//������ ��������� � ���������� � ��������(���������� �������� JJMASeries � JurXSeries):

int bar=0;// ��� ������ ���� ������ �������
//----+ ��������� � ���������� � ������ �������� ����������
//----+ ������ Buffer ������� ��������� � ������������ �������
Buffer[bar]=iCustom( NULL, 0, "JFatl",Length,Phase,0,Input_Price_Customs,0,bar);
//----+ �������� ���������� ����� �� ������������� ��� ����������� �������
if (Bars-1<39+30+3)return(0);
int NewTime=Time[1];
double Trend1=Buffer[1]-Buffer[2];
double Trend2=Buffer[2]-Buffer[3];
//----+ ���������� OldTime ������� ������ �� ������� int start() � int init() 
if((NewTime!=OldTime)&&(Trend2<0)&&(Trend1>0))����������� ������� �� �������
if((NewTime!=OldTime)&&(Trend2>0)&&(Trend1<0))����������� ������� �� �������
OldTime=NewTime;


//������ ��������� � JJMASeries (���������� ������� JJMASeries) � ��������:

int MaxBar=Bars-1;
//----+ ��������� ������� ������ ������ ����� ����, ��� ���������� bar ��������� �������� 0 � 1
int reset,limit=1;// ���������� reset � ��������� � JJMASeries  ������ �������� ������
double Series,Resalt;
for(int bar=limit;bar>=0;bar--)
 {
  Series=PriceSeries(Input_Price_Customs, bar);// ���� ����� Series=Close[bar];
  //----+ ��������� � ������� JJMASeries �� ������� 0 (nJMAdin=0)
  Resalt=JJMASeries(0,0,MaxBar,limit,Phase,Smooth,Series,bar,reset);
  //----+ �������� �� ���������� ������ � ���������� �������� (��� �������� � �������� ����� � �� ������!)
  if(reset!=0)return(-1);  
  Buffer[bar]=Resalt;
 }
//----+ �������� ���������� ����� �� ������������� ��� ����������� �������
if (Bars-1<30+3)return(0);
//----+
int NewTime=Time[1];
double Trend1=Buffer[1]-Buffer[2];
double Trend2=Buffer[2]-Buffer[3];
//----+ ���������� OldTime ������� ������ �� ������� int start() � int init() 
if((NewTime!=OldTime)&&(Trend2<0)&&(Trend1>0))����������� ������� �� �������
if((NewTime!=OldTime)&&(Trend2>0)&&(Trend1<0))����������� ������� �� �������
OldTime=NewTime;
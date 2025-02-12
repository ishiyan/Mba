/*
���  ������  ����������  �������  �������� ���� 
  
INDICATOR_COUNTED.mqh   

� ����� (����������): MetaTrader\experts\include\

���������  ������������  ���  ������  ������ �����������  ��  ������ 
�������������.
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                              VGridLinesX4.LC.mq4 |
//|                             Copyright � 2006,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� �� ���� �����
#property indicator_chart_window 
//---- ������� ��������� ���������� ���������������������������������������������������+
extern int   Ind_Shift = 0;     // c���� ���������� ����� ��� �������  � ����� 
extern int   Count_Bar = 300;   // ���������� ��������� ����� ��� ������� ����������
extern int   Ind_Style = 0;     // ����� ����������� ���������� (0 - �� ���������)
extern bool  AllDelate = false; // �������� ���� ������ � ���� ������������ �����  
//--+
extern int   Hour_Shift0 = 0;   // c���� ��������� ����� � ����� 
extern int   Hour_Shift1 = 0;   // c���� �������  ���������������������� ����� � �����
extern int   Hour_Shift2 = 8;   // c���� �������  ���������������������� ����� � �����
extern int   Hour_Shift3 = 16;  // c���� �������� ���������������������� ����� � ����� 
//--+
extern color      COLOR0 = C'148,135,218';// ���� ����� ���������� �����
extern int   Line_Style0 = 3;             // ����� ����������� �����  ���������� �����
extern int   Line_Width0 = 0;             // ������� ����� ���������� �����
//--+
extern color      COLOR1 = C'176,0,176';  // ���� ����� ��������� ����� 1 
extern int   Line_Style1 = 4;             // ����� ����������� ����� ��������� ����� 1 
extern int   Line_Width1 = 0;             // ������� ����� ��������� ����� 1 
//--+
extern color      COLOR2 = C'0,119,119';  // ���� ����� ��������� ����� 2
extern int   Line_Style2 = 4;             // ����� ����������� ����� ��������� ����� 2
extern int   Line_Width2 = 0;             // ������� ����� ��������� ����� 2
//--+
extern color      COLOR3 = C'119,0,170';  // ���� ����� ��������� ����� 3
extern int   Line_Style3 = 4;             // ����� ����������� ����� ��������� ����� 3
extern int   Line_Width3 = 0;             // ������� ����� ��������� ����� 3
//---- ��������������������������������������������������������������������������������+
//---- ������������ �������
double Buffer[];

//---- ����� ����������  
int   time0,time1,fix0,fix1,fix2,fix3,Wind_total,Del_time,Start_Time,ii,bar;
color COLOR0x,COLOR1x,COLOR2x,COLOR3x;
int Line_Style0x,Line_Style1x,Line_Style2x,Line_Style3x,Line_Width0x,Line_Width1x,Line_Width2x,Line_Width3x;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| VGridLinesX4.LC initialization function                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{
if (Period()>240)return(0);
//--+ �������� ���� ������������ ����� � ������ � ������� 
if (AllDelate==true){ObjectsDeleteAll(EMPTY, OBJ_VLINE);ObjectsDeleteAll(EMPTY,OBJ_CYCLES);}
//--+ ������� ���� ������������ ���� �������
Wind_total=WindowsTotal();
//---- 1 ������������ ������ ����������� ��� �����
SetIndexBuffer(0,Buffer);
//---- ����� ����� ����������� ����� ����������
switch(Ind_Style)
 {
 case  0: StileCreat(COLOR0,COLOR1,COLOR2,COLOR3,Line_Style0,Line_Style1,Line_Style2,Line_Style3,Line_Width0,Line_Width1,Line_Width2,Line_Width3);break;
 case  1: StileCreat(Red,C'198,0,198',C'0,119,119',C'119,0,170',4,4,4,4,0,0,0,0);break;
 case  2: StileCreat(Magenta,Red,SpringGreen,C'128,0,255',4,4,4,4,0,0,0,0);break;
 case  3: StileCreat(Magenta,Red,SpringGreen,C'128,0,255',0,0,0,0,2,2,2,3);break;
 case  4: StileCreat(Red,Magenta,MediumSeaGreen,Blue,0,0,0,0,2,2,2,2);break;
 case  5: StileCreat(Orange,Red,SpringGreen,C'128,0,255',0,0,0,0,3,2,2,3);break;
 case  6: StileCreat(Yellow,Red,C'0,217,108',C'170,85,255',1,1,1,1,0,0,0,0);break;
 case  7: StileCreat(Yellow,Red,C'0,217,108',C'170,85,255',4,4,4,4,0,0,0,0);break;
 case  8: StileCreat(Gold,C'236,0,0',C'0,147,73',C'116,0,232',4,4,4,4,0,0,0,0);break;
 case  9: StileCreat(Orange,C'213,0,0',C'0,125,63',C'99,0,198',4,4,4,4,0,0,0,0);break;
  
 default: StileCreat(COLOR0,COLOR1,COLOR2,COLOR3,Line_Style0,Line_Style1,Line_Style2,Line_Style3,Line_Width0,Line_Width1,Line_Width2,Line_Width3);
 }           
//---- ���������� �������������
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| VGridLinesX4.LC deinitialization function                        |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int deinit()
  {
//--+ ������� ���� ���� �� ������������ ����� � ������ , ��������� ��� ������ ���������� 
VLineDelateAll("VLine_Grid");
CycleDelateAll();
//ObjectsDeleteAll(EMPTY,OBJ_VLINE) ;
//ObjectsDeleteAll(EMPTY,OBJ_CYCLES); 
//---- ���������� ���������������
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| VGridLinesX4.LC iteration function                               |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
{
if (Period()>240)return(0);
//----+ �������� ���������� ����� �� �������������
if (Count_Bar<7500/Period())Count_Bar=7500/Period();
if((Count_Bar==7500/Period())&&(Count_Bar>Bars-1))COLOR0x=CLR_NONE;
if (Count_Bar>Bars-1)Count_Bar=Bars-1;
if (Count_Bar<4500/Period())Count_Bar=4500/Period();
if (Count_Bar>Bars-1)return(0);
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
//---- ������������ ��������� ���� ������������ � ������������ ����� ��� ����������� � ���������
int daily_lewel,weekl_lewel,Hour_ShiftW,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- �������� �� ��������� ������
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- ��������� ������������ ��� ������ ���� ���������� 
if (counted_bars>0) counted_bars--;
//---- 
Hour_ShiftW=Hour_Shift0+48;
//+---+ ������������� ���� ��� ����� ��� ������
time0=Time[0];
time1=Time[1];
weekl_lewel=168*MathFloor(time0/604800);
fix0=3600*(weekl_lewel+Hour_ShiftW);
if((time0>=fix0)&&(time1<fix0))counted_bars=0;
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
int limit=Count_Bar-counted_bars-1; 
//+---+ ������� ���� �� ������������ �����, ��������� �� ������� ������ ����������
//---- ������������� ���� ��������� ������� ��������� -1
if (counted_bars==0)
  {
   VLineDelateAll("VLine_Grid");
   CycleDelateAll();
   ArrayInitialize(Buffer,-1);
  }
//+---+ ���������� ������������ ����� � ���� ������������������ ��������� ������������ ����� 
for(int bar=limit;bar>=0;bar--)
  //+------+
 {
  if(Buffer[bar]!=-1)continue; 
  else                   
   //+---+ 
   {
   ObjectDelete("VLine_Grid"+Time[bar]+"");                   
   time0=Time[bar+0];
   time1=Time[bar+1];
   //+---+
   daily_lewel=024*MathFloor(time0/086400);
   weekl_lewel=168*MathFloor(time0/604800);
   //+---+
   fix1=3600*(daily_lewel+Hour_Shift1);
   fix2=3600*(daily_lewel+Hour_Shift2);
   fix3=3600*(daily_lewel+Hour_Shift3);
   fix0=3600*(weekl_lewel+Hour_ShiftW);
   //+---+
   //+---+ ��� ��������� � ������� VLineCreate ��� ���������� ������������ �����
         if((time0>=fix0)&&(time1<fix0)){VLineCreate("VLine_Grid",time0,COLOR0x,Line_Style0x,Line_Width0x);Buffer[bar]=0;}
   else {if((time0>=fix1)&&(time1<fix1)){VLineCreate("VLine_Grid",time0,COLOR1x,Line_Style1x,Line_Width1x);Buffer[bar]=1;}
   else {if((time0>=fix2)&&(time1<fix2)){VLineCreate("VLine_Grid",time0,COLOR2x,Line_Style2x,Line_Width2x);Buffer[bar]=2;}
   else  if((time0>=fix3)&&(time1<fix3)){VLineCreate("VLine_Grid",time0,COLOR3x,Line_Style3x,Line_Width3x);Buffer[bar]=3;}}}
   //+---+   
   } 
   //+---+ �������� ������������ �����, ��������� �� ������� Count_Bar                                 
  Del_time=Time[bar+Count_Bar];
  ObjectDelete("VLine_Grid"+Del_time+"");
   //+---+
 }
//+---+ ��������� ����� ����� �������� ���� �� ������
if(Buffer[0]==-1)
 {  
   //+---+ ������� ���� �� ����� ������, ��������� �� ������� ������ ����������
   CycleDelateAll();
   //+---+ ����� ������ �����
   for(int aa=0;aa<=Bars-1;aa++){if (Buffer[aa]!=-1)break;}  
   Start_Time=3600*(24*MathCeil(Time[aa]/86400)-Ind_Shift+0);
   //+---+  
  for(ii=0;ii<Wind_total;ii++)
    {
     //+---+ ��� ��������� � ������� CycleCreate ��� �������� ��� ������
     CycleCreate("Cycle_Grid1",Start_Time,Hour_Shift1,024,COLOR1x,Line_Style1x,Line_Width1x,ii);
     CycleCreate("Cycle_Grid2",Start_Time,Hour_Shift2,024,COLOR2x,Line_Style2x,Line_Width2x,ii);
     CycleCreate("Cycle_Grid3",Start_Time,Hour_Shift3,024,COLOR3x,Line_Style3x,Line_Width3x,ii);
    }  
  //+---+ ����� ������ �����   
  for(int bb=0;bb<=Bars-1;bb++){if (Buffer[bb]==0)break;}  
  Start_Time=3600*(168*MathCeil(Time[bb]/604800)-Ind_Shift);
  int Hour_ShiftX=Hour_Shift0+96;
  CycleDelate("Cycle_GridW");
  //+---+ ���� ��������� � ������� CycleCreate ��� �������� ������ �����
  for(ii=0;ii<Wind_total;ii++) CycleCreate("Cycle_GridW",Start_Time,Hour_ShiftX,120,COLOR0x,Line_Style0x,Line_Width0x,ii);  
//+---+ 
 } 
//+---+ ���������� ���������� ������
  
return(0);
}
//+---+ << �������� ������� StileCreat >>-----------------------------------------------------------------------------------------------+
void StileCreat
(
color COLOR0g,   color COLOR1g,   color COLOR2g,   color COLOR3g,
int Line_Style0g,int Line_Style1g,int Line_Style2g,int Line_Style3g,
int Line_Width0g,int Line_Width1g,int Line_Width2g,int Line_Width3g
)
{
COLOR0x=COLOR0g; COLOR1x=COLOR1g; COLOR2x=COLOR2g; COLOR3x=COLOR3g;
Line_Style0x=Line_Style0g;Line_Style1x=Line_Style1g;Line_Style2x=Line_Style2g;Line_Style3x=Line_Style3g;
Line_Width0x=Line_Width0g;Line_Width1x=Line_Width1g;Line_Width2x=Line_Width2g;Line_Width3x=Line_Width3g;
}         
//+---+ << �������� ������� VLineDelateAll >>-------------------------------------------------------------------------------------------+
void  VLineDelateAll(string  VLineDelateAll.Line_Name)
  {
   for(int pp=Bars-1;pp>=0;pp--)ObjectDelete(VLineDelateAll.Line_Name+Time[pp]+"");
  }
//+---+ << �������� ������� CycleDelate >> ---------------------------------------------------------------------------------------------+
void  CycleDelate(string CycleDelate.Cycle_Name)
  {
   int TT=WindowsTotal();
   for(int rr=0; rr<TT; rr++)ObjectDelete(CycleDelate.Cycle_Name+rr+"");  
  } 
//+---+ << �������� ������� CycleDelateAll >> ------------------------------------------------------------------------------------------+
void  CycleDelateAll()
  {
   CycleDelate("Cycle_GridW");CycleDelate("Cycle_Grid1");CycleDelate("Cycle_Grid2");CycleDelate("Cycle_Grid3"); 
  } 
//+---+ << �������� ������� VLineCreate >>----------------------------------------------------------------------------------------------+
void VLineCreate
(
string VLineCreate.Line_Name, int VLineCreate.time, color VLineCreate.Color, int VLineCreate.Line_Style, int VLineCreate.width
)
//+---+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -   - - - + 
{
   for(int ii=0;ii<WindowsTotal();ii++)
   ObjectCreate(VLineCreate.Line_Name+VLineCreate.time+"", OBJ_VLINE, ii, VLineCreate.time, EMPTY);  
   ObjectSet   (VLineCreate.Line_Name+VLineCreate.time+"", OBJPROP_BACK, true);
   ObjectSet   (VLineCreate.Line_Name+VLineCreate.time+"", OBJPROP_STYLE, VLineCreate.Line_Style);
   ObjectSet   (VLineCreate.Line_Name+VLineCreate.time+"", OBJPROP_COLOR, VLineCreate.Color);  
   ObjectSet   (VLineCreate.Line_Name+VLineCreate.time+"", OBJPROP_WIDTH, VLineCreate.width); 
}  

//+---+ << �������� ������� CycleCreate >> ---------------------------------------------------------------------------------------------+
void CycleCreate
(
string CycleCreate.Cycle_Name, int CycleCreate.Start_Time, int CycleCreate.Hour_Shift,  int CycleCreate.Period, 
color  CycleCreate.Color,      int CycleCreate.Style,      int CycleCreate.Width,       int CycleCreate.Window
)
//+---+ �������� CycleCreate.Period ���������� � ����
//+---+ �������� CycleCreate.Start_Time ���������� � �������� 
//+---+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + 
{  
  int CycleCreate.St_time=CycleCreate.Start_Time+CycleCreate.Hour_Shift*3600; 
  int CycleCreate.Object_time=CycleCreate.St_time+CycleCreate.Period*3600;
  
  ObjectCreate(CycleCreate.Cycle_Name+CycleCreate.Window+"", OBJ_CYCLES,CycleCreate.Window,CycleCreate.St_time,-1000,CycleCreate.Object_time,-1000);  
  ObjectSet   (CycleCreate.Cycle_Name+CycleCreate.Window+"", OBJPROP_BACK, true);
  ObjectSet   (CycleCreate.Cycle_Name+CycleCreate.Window+"", OBJPROP_STYLE,  CycleCreate.Style);
  ObjectSet   (CycleCreate.Cycle_Name+CycleCreate.Window+"", OBJPROP_COLOR,  CycleCreate.Color);
  ObjectSet   (CycleCreate.Cycle_Name+CycleCreate.Window+"", OBJPROP_WIDTH,  CycleCreate.Width);
}
//+-----+ << �������� ������� INDICATOR_COUNTED >> --------------------------------------------------------------------------------------+
//----+(���� INDICATOR_COUNTED.mqh ������� �������� � ����� (����������): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+--------------------------------------------------------------------------------------------------------------------------------------+
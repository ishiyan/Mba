/*
Для  работы  индикатора  следует  положить файл 
  
INDICATOR_COUNTED.mqh   

в папку (директорию): MetaTrader\experts\include\

Индикатор предназначен  для  работы только на  четырёхчасовом формате.
Ввиду привязки алгоритма построения циклов в  Метатрейдере к  номерам  
свеч,  а не  ко времени,  использовать  этот  индикатор на графиках с 
периодом, меньшим четырёхчасового, безсмысленно. Имеет  преимущество,
по сравнению с VGridLinesX4.LC.mq4 в том,  что  создаёт  всего четыре 
графических объекта. 
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                VGridCycle_H4.mq4 |
//|                             Copyright © 2006,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора во всех окнах
#property indicator_chart_window 
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА юююююююююююююююююжжжжюююююююююжжжжжжжжжжюююююююжжжжж+
extern int  Ind_Shift = 0;     // cдвиг индикатора вдоль оси времени  в барах 
extern int  Count_Bar = 600;   // Количество последних баров для расчёта индикатора
extern int  Ind_Style = 0;     // Стиль изображения индикатора (0 - по умолчанию)
extern bool AllDelate = false; // удаление всех циклов при работе 
//--+
extern int  Shift0 = 0;        // недельного цикла в барах
extern int  Shift1 = 0;        // cдвиг первого  суточного цикла в барах
extern int  Shift2 = 2;        // cдвиг второго  суточного в барах
extern int  Shift3 = 4;        // cдвиг третьего суточного цикла в барах 
//--+
extern color      COLOR0 = C'148,135,218';// цвет линии недельного цикла
extern int   Line_Style0 = 3;             // Стиль изображения линии  недельного цикла
extern int   Line_Width0 = 0;             // Толщина линии недельного цикла
//--+
extern color      COLOR1 = C'176,0,176';  // цвет линии суточного цикла 1 
extern int   Line_Style1 = 4;             // Стиль изображения линии суточного цикла 1 
extern int   Line_Width1 = 0;             // Толщина линии суточного цикла 1 
//--+
extern color      COLOR2 = C'0,119,119';  // цвет линии суточного цикла 2
extern int   Line_Style2 = 4;             // Стиль изображения линии суточного цикла 2
extern int   Line_Width2 = 0;             // Толщина линии суточного цикла 2
//--+
extern color      COLOR3 = C'119,0,170';  // цвет линии суточного цикла 3
extern int   Line_Style3 = 4;             // Стиль изображения линии суточного цикла 3
extern int   Line_Width3 = 0;             // Толщина линии суточного цикла 3
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
int    Start_Bar,Wind_total,ii;
string short_name[1][4];
color  COLOR0x,COLOR1x,COLOR2x,COLOR3x;
int    Line_Style0x,Line_Style1x,Line_Style2x,Line_Style3x;
int    Line_Width0x,Line_Width1x,Line_Width2x,Line_Width3x;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|  VGridCycle_H4 initialization function                           | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{
if (Period()!=240)return(0);
//--+ удаление всех вертикальных циклов с графика 
if (AllDelate==true)ObjectsDeleteAll(EMPTY,OBJ_CYCLES);
//--+ подсчёт всех существующих окон графика
Wind_total=WindowsTotal();
//--+ изменение размеров буфферов 
ArrayResize(short_name, Wind_total); 
//--+ индивидуальные имена для каждого цикла на каждом окне;
for(int ii=0;ii<Wind_total;ii++)
  {
   short_name[ii][1]="CycleLine Shift1="+Shift1+""+ii+"";
   short_name[ii][2]="CycleLine Shift2="+Shift2+""+ii+"";
   short_name[ii][3]="CycleLine Shift3="+Shift3+""+ii+"";
   short_name[ii][0]="CycleLine ShiftW="+Shift0+""+ii+"";
  }
//---- выбор стиля изображения линий индикатора
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
//---- завершение инициализации
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| VGridCycle_H4 deinitialization function                          |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int deinit()
  {
//+---+ Очистка всех окон сетки линий циклов, созданной при работе индикатора  
CycleDelateAll(); 
//+---+ Очистка всех окон от всех сеток циклов
//ObjectsDeleteAll(EMPTY,OBJ_CYCLES); 
//----
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|  VGridCycle_H4 iteration function                                |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
{ 
if (Period()!=240)return(0);
//----+ проверки количества баров на достаточность
if (Count_Bar<7500/Period())Count_Bar=7500/Period();
if((Count_Bar==7500/Period())&&(Count_Bar>Bars-1))COLOR0x=CLR_NONE;
if (Count_Bar>Bars-1)Count_Bar=Bars-1;
if (Count_Bar<4500/Period())Count_Bar=4500/Period();
if (Count_Bar>Bars-1)return(0);
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
if (counted_bars==0)
 {
 //+---+ Очистка окон от старой сетки циклов, созданной на прежнем старте индикатора
 CycleDelateAll(); 
 //----
 for(int bar=Count_Bar;bar>=0;bar--)
  {
   //+---+ создание новой сетки циклов
   int time0=Time[bar+0];
   int time1=Time[bar+1];
   int TimeDay0=TimeDayOfWeek(time0);
   int TimeDay1=TimeDayOfWeek(time1);
   
 //if((TimeDay0!=TimeDay1)&&(TimeDay0==3))break;  
 //if((TimeDay0!=TimeDay1)&&(TimeDay0==3)&&(Period()==240))break;  //замена предыдущей строки 
 if((TimeDay0!=TimeDay1)&&(TimeDay0==3)&&(TimeHour(time0)==0)&&(TimeMinute(time0)==0)&&(TimeSeconds(time0)==0))break;
  } 
 Start_Bar=bar-Ind_Shift;
 int ShiftX=Shift0-54;
 for(ii=0;ii<Wind_total;ii++)
  {
   //+---+ четыре обращения к функции CycleCreate для создания четырёх циклов
   CycleCreate(short_name[ii][1],Start_Bar,Shift1,086400,COLOR1x,Line_Style1x,Line_Width1x,ii);
   CycleCreate(short_name[ii][2],Start_Bar,Shift2,086400,COLOR2x,Line_Style2x,Line_Width2x,ii);
   CycleCreate(short_name[ii][3],Start_Bar,Shift3,086400,COLOR3x,Line_Style3x,Line_Width3x,ii);
   CycleCreate(short_name[ii][0],Start_Bar,ShiftX,604800,COLOR0x,Line_Style0x,Line_Width0x,ii);
  }
 } 
//+---+ завершение построения сетки
return(0);
}  
//+---+ << Введение функции StileCreat >>-----------------------------------------------------------------------------------------------+
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
//+---+ << Введение функции CycleDelateAll >> ------------------------------------------------------------------------------------------+
void  CycleDelateAll()
{
int CycleDelateAll.Tot=WindowsTotal();
int CycleDelateAll.Range=ArrayRange(short_name,1);
for(int rr=0;rr<CycleDelateAll.Tot;rr++)for(int ww=0;ww<CycleDelateAll.Range;ww++)ObjectDelete(short_name[rr][ww]);
} 
//+---+ << Введение функции CycleCreate >>----------------------------------------------------------------------------------------------+
void CycleCreate
(
string CycleCreate.Cycle_Name, int CycleCreate.Start_Bar, int CycleCreate.Shift,  int CycleCreate.Period, 
color  CycleCreate.Color,      int CycleCreate.Style,     int CycleCreate.Width,  int CycleCreate.Window
)
//+---+ Параметр CycleCreate.Period измеряется в секундах
//+---+ Параметр CycleCreate.Start_Bar измкряется в номерах баров 
//+---+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + 
{  
  int CycleCreate.St_time=Time[CycleCreate.Start_Bar]+CycleCreate.Shift*Period()*60; 
  int CycleCreate.Object_time=CycleCreate.St_time+CycleCreate.Period;
   
  ObjectCreate(CycleCreate.Cycle_Name, OBJ_CYCLES,CycleCreate.Window,CycleCreate.St_time,0,CycleCreate.Object_time,0);  
  ObjectSet   (CycleCreate.Cycle_Name, OBJPROP_BACK, true);
  ObjectSet   (CycleCreate.Cycle_Name, OBJPROP_TIMEFRAMES, OBJ_PERIOD_H4);
  ObjectSet   (CycleCreate.Cycle_Name, OBJPROP_STYLE,  CycleCreate.Style);
  ObjectSet   (CycleCreate.Cycle_Name, OBJPROP_COLOR,  CycleCreate.Color);
  ObjectSet   (CycleCreate.Cycle_Name, OBJPROP_WIDTH,  CycleCreate.Width);
}

//+-----+ << Введение функции INDICATOR_COUNTED >> --------------------------------------------------------------------------------------+
//----+(файл INDICATOR_COUNTED.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+--------------------------------------------------------------------------------------------------------------------------------------+



/*
Для  работы  индикатора  следует  положить файл 
  
INDICATOR_COUNTED.mqh   

в папку (директорию): MetaTrader\experts\include\

Индикатор предназначен  для работы только на дневном формате графика.
На других таймфреймах индикатор не работает!
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                              VGridLinesD4.LC.mq4 |
//|                             Copyright © 2006,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- отрисовка индикатора во всех окнах
#property indicator_chart_window 
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА юююююююююююююююююжжжжюююююююююжжжжжжжжжжюююююжжжжжжжююжж+
extern int   Ind_Shift = 0;     // cдвиг индикатора вдоль оси времени  в барах 
extern int   Count_Bar = 300;   // Количество последних баров для расчёта индикатора
extern int   Ind_Style = 0;     // Стиль изображения индикатора (0 - по умолчанию)
extern bool  AllDelate = false; // удаление всех циклов и всех вертикальных линий  
//--+
extern int        Shift0 = 0;            // cдвиг четырёхнедельного цикла в барах 
extern color      COLOR0 = C'193,0,193'; // цвет линии четырёхнедельного цикла
extern int   Line_Style0 = 3;            // Стиль изображения линии четырёхнедельного цикла
extern int   Line_Width0 = 0;            // Толщина линии четырёхнедельного цикла
//--+
extern int        Shift1 = 0;            // cдвиг недельного цикла в барах
extern color      COLOR1 = C'130,0,185'; // цвет линии недельного цикла 
extern int   Line_Style1 = 4;            // Стиль изображения линии недельного цикла
extern int   Line_Width1 = 0;            // Толщина линии недельного цикла
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Buffer[];
//---- целые переменные 
int time0,time1,Wind_total,Del_time,Start_Time,ii,bar;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| VGridLinesD4.LC initialization function                          | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init() 
{
if (Period()!=1440)return(0);
//--+ удаление всех вертикальных линий и циклов с графика 
if (AllDelate==true){ObjectsDeleteAll(EMPTY, OBJ_VLINE);ObjectsDeleteAll(EMPTY,OBJ_CYCLES);}
//--+ подсчёт всех существующих окон графика
Wind_total=WindowsTotal();
//---- 1 индикаторный буффер использован для счёта
SetIndexBuffer(0,Buffer);
//---- завершение инициализации
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| VGridLinesD4.LC deinitialization function                        |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int deinit()
  {
//--+ Очистка всех окон от вертикальных линий и циклов , созданных при работе индикатора 
VLineDelateAll("VLine_Grid");
CycleDelateAll();
//ObjectsDeleteAll(EMPTY,OBJ_VLINE) ;
//ObjectsDeleteAll(EMPTY,OBJ_CYCLES); 
//---- завершение деинициализации
   return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| VGridLinesD4.LC iteration function                               |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
{
if (Period()!=1440)return(0);
//----+ проверки количества баров на достаточность
if (Count_Bar<7500/Period())Count_Bar=7500/Period();
if (Count_Bar>Bars-1)Count_Bar=Bars-1;
if (Count_Bar<4500/Period())Count_Bar=4500/Period();
if (Count_Bar>Bars-1)return(0);
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int weekl_lewelx1,weekl_lewelx4,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан 
if (counted_bars>0) counted_bars--;
//+---+ Инициализация нуля при смене дня недели
time0=Time[0];
time1=Time[1];
weekl_lewelx1=086400*(07*MathFloor(time0/0604800)+Shift1+Ind_Shift+2); 
weekl_lewelx4=086400*(28*MathFloor(time0/2419200)+Shift0+Ind_Shift+2+21);   
if((time0>=weekl_lewelx4)&&(time1<weekl_lewelx4))counted_bars=0;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
int limit=Count_Bar-counted_bars-1; 
//+---+ Очистка окон от вертикальных линий, созданных на прежнем старте индикатора
//---- инициализация всех элементов массива значением -1
if (counted_bars==0)
  {
   VLineDelateAll("VLine_Grid");
   CycleDelateAll();
   ArrayInitialize(Buffer,-1);
  }
//+---+ Построение вертикальной сетки в виде последовательности отдельных вертикальных линий 
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
   weekl_lewelx1=086400*(07*MathFloor(time0/0604800)+Shift1+Ind_Shift+2); 
   weekl_lewelx4=086400*(28*MathFloor(time0/2419200)+Shift0+Ind_Shift+2+21);   
   //+---+
   //+---+ три обращения к функции VLineCreate для построения вертикальных линий
   if((time0>=weekl_lewelx4)&&(time1<weekl_lewelx4)){VLineCreate("VLine_Grid",time0,COLOR0,Line_Style0,Line_Width0);Buffer[bar]=0;}else
   if((time0>=weekl_lewelx1)&&(time1<weekl_lewelx1)){VLineCreate("VLine_Grid",time0,COLOR1,Line_Style1,Line_Width1);Buffer[bar]=1;}  
   //+---+   
  } 
  //+---+ Удаление вертикальных линий, выходящих за границу Count_Bar                                 
  Del_time=Time[bar+Count_Bar];
  ObjectDelete("VLine_Grid"+Del_time+"");
  //+---+
 }
//+---+ Дорисовка сетки после нулевого бара из циклов
if(Buffer[0]==-1)
 {
   //+---+ Очистка окон от линий циклов, созданных на прежнем старте индикатора
   CycleDelateAll();
   //+---+ поиск начала недельного цикла
   for(int aa=0;aa<=Bars-1;aa++){if (Buffer[aa]==0)break;}  
   Start_Time=86400*(MathCeil(Time[aa]/86400)-Ind_Shift+5);
   //+---+ 
   //+---+ Одно обращение к функции CycleCreate для создания одного недельного цикла  
   for(ii=0;ii<Wind_total;ii++)CycleCreate("Cycle_Grid1",Start_Time,Shift1,05,COLOR1,Line_Style1,Line_Width1,ii);  
   CycleDelate("Cycle_GridW");
   //+---+ поиск начала четырёхнедельного цикла
   for(int bb=0;bb<=Bars-1;bb++){if (Buffer[bb]==1)break;}  
   Start_Time=86400*(MathCeil(Time[bb]/86400)-Ind_Shift+12+15);
   //+---+ 
   //+---+ одно обращение к функции CycleCreate для создания одного  четырёхнедельного цикла
   for(ii=0;ii<Wind_total;ii++)CycleCreate("Cycle_GridW",Start_Time,Shift0,20,COLOR0,Line_Style0,Line_Width0,ii);   
 }
   //+---+ завершение построения циклов  
return(0);
}
//+---+ << Введение функции VLineDelateAll >>-------------------------------------------------------------------------------------------+
void  VLineDelateAll(string  VLineDelateAll.Line_Name)
  {
   for(int pp=Bars-1;pp>=0;pp--)ObjectDelete(VLineDelateAll.Line_Name+Time[pp]+"");
  }
//+---+ << Введение функции CycleDelate >> ---------------------------------------------------------------------------------------------+
void  CycleDelate(string CycleDelate.Cycle_Name)
  {
   int TT=WindowsTotal();
   for(int rr=0; rr<TT; rr++)ObjectDelete(CycleDelate.Cycle_Name+rr+"");  
  } 
//+---+ << Введение функции CycleDelateAll >> ------------------------------------------------------------------------------------------+
void  CycleDelateAll()
  {
   CycleDelate("Cycle_GridW");CycleDelate("Cycle_Grid1"); 
  } 
//+---+ << Введение функции VLineCreate >>----------------------------------------------------------------------------------------------+
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

//+---+ << Введение функции CycleCreate >> ---------------------------------------------------------------------------------------------+
void CycleCreate
(
string CycleCreate.Cycle_Name, int CycleCreate.Start_Time, int CycleCreate.Shift,  int CycleCreate.Period, 
color  CycleCreate.Color,      int CycleCreate.Style,      int CycleCreate.Width,  int CycleCreate.Window
)
//+---+ Параметр CycleCreate.Period измеряется в днях
//+---+ Параметр CycleCreate.Start_Time измкряется в секундах 
//+---+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - + 
{  
  int CycleCreate.St_time=CycleCreate.Start_Time+CycleCreate.Shift*86400; 
  int CycleCreate.Object_time=CycleCreate.St_time+CycleCreate.Period*86400;
   
  ObjectCreate(CycleCreate.Cycle_Name+CycleCreate.Window+"", OBJ_CYCLES,CycleCreate.Window,CycleCreate.St_time,-1000,CycleCreate.Object_time,-1000);  
  ObjectSet   (CycleCreate.Cycle_Name+CycleCreate.Window+"", OBJPROP_BACK, true);
  ObjectSet   (CycleCreate.Cycle_Name+CycleCreate.Window+"", OBJPROP_STYLE,  CycleCreate.Style);
  ObjectSet   (CycleCreate.Cycle_Name+CycleCreate.Window+"", OBJPROP_COLOR,  CycleCreate.Color);
  ObjectSet   (CycleCreate.Cycle_Name+CycleCreate.Window+"", OBJPROP_WIDTH,  CycleCreate.Width);
}
//+-----+ << Введение функции INDICATOR_COUNTED >> --------------------------------------------------------------------------------------+
//----+(файл INDICATOR_COUNTED.mqh следует положить в папку (директорию): MetaTrader\experts\include)
#include <INDICATOR_COUNTED.mqh> 
//+--------------------------------------------------------------------------------------------------------------------------------------+
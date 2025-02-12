//+------------------------------------------------------------------+
//|                                             Nearest_Neighbor.mq5 |
//|                                             Copyright 2010, gpwr |
//+------------------------------------------------------------------+
#property copyright "gpwr"
#property version   "1.00"
#property description "Предсказание будущего основано на ближайшем соседе в прошлом"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- future model outputs
#property indicator_label1  "NN будущие"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- past model outputs
#property indicator_label2  "NN прошлые"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Blue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- глобальные константы
#define pi 3.141592653589793238462643383279502884197169399375105820974944592

//--- входные параметры
input int    Npast   =300; // Количество баров прошлого в паттерне
input int    Nfut    =50;  // Количество баров будущего в паттерне (должно быть < Npast)

//--- глобальные переменные
int PrevBars;
double mx[],sxx[],denx[];
bool FirstTime;

//--- индикаторные буферы
double ynn[],xnn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- инициализируем глобальные переменные
   PrevBars=Bars(_Symbol,_Period)-1;
   FirstTime=true;

//--- маппинг индикаторных буферов
   SetIndexBuffer(0,ynn,INDICATOR_DATA);
   SetIndexBuffer(1,xnn,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,"1NN("+string(Npast)+")");
   PlotIndexSetInteger(0,PLOT_SHIFT,Nfut);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка на наличие необходимого количества данных и нового бара
   int bars=rates_total;
   if(bars<Npast+Nfut)
     {
      Print("Ошибка: Недостаточно баров в истории!");
      return(0);
     }
   if(PrevBars==bars) return(rates_total);
   PrevBars=bars;

//--- инициализируем индикаторные буферы значением EMPTY_VALUE
   ArrayInitialize(xnn,EMPTY_VALUE);
   ArrayInitialize(ynn,EMPTY_VALUE);

//--- главный цикл
//--- расчет корреляционных сумм для текущего паттерна
//--- текущий паттерн начинается при i=bars-Npast и заканчивается при i=bars-1
   double my=0.0;
   double syy=0.0;
   for(int i=0;i<Npast;i++)
     {
      double y=Open[bars-Npast+i];
      my +=y;
      syy+=y*y;
     }
   double deny=syy*Npast-my*my;
   if(deny<=0)
     {
      Print("Нулевое или отрицательное значение выражения: syy*Npast-my*my = ",deny);
      return(0);
     }
   deny=MathSqrt(deny);

//--- расчет корреляционных сумм для паттернов прошлого
//--- паттерны прошлого начинаются при k=0 и заканчиваются при k=bars-Npast-Nfut
   ArrayResize(mx,bars-Npast-Nfut+1);
   ArrayResize(sxx,bars-Npast-Nfut+1);
   ArrayResize(denx,bars-Npast-Nfut+1);
   int kstart;
   if(FirstTime) kstart=0;
   else kstart=bars-Npast-Nfut;
   FirstTime=false;
   for(int k=kstart;k<=bars-Npast-Nfut;k++)
     {
      if(k==0)
        {
         mx[0] =0.0;
         sxx[0]=0.0;
         for(int i=0;i<Npast;i++)
           {
            double x=Open[i];
            mx[0] +=x;
            sxx[0]+=x*x;
           }
        }
      else
        {
         double xnew=Open[k+Npast-1];
         double xold=Open[k-1];
         mx[k] =mx[k-1]+xnew-xold;
         sxx[k]=sxx[k-1]+xnew*xnew-xold*xold;
        }
      denx[k]=sxx[k]*Npast-mx[k]*mx[k];
     }

//--- расчет кросс-корреляционных сумм, 
//--- коэффициентов корреляции и нахождение ближайших соседей
   double sxy[];
   ArrayResize(sxy,bars-Npast-Nfut+1);
   double b,corrMax=0;
   int knn=0;
   for(int k=0;k<=bars-Npast-Nfut;k++)
     {
      //--- вычисляем sxy
      sxy[k]=0.0;
      for(int i=0;i<Npast;i++) sxy[k]+=Open[k+i]*Open[bars-Npast+i];

      //--- вычисляем коэффициент корреляции
      if(denx[k]<=0)
        {
         Print("Нулевое или отрицательное значение выражения sxx[k]*Npast-mx[k]*mx[k]. Пропускаем паттерн # ",k);
         continue;
        }
      double num=sxy[k]*Npast-mx[k]*my;
      double corr=num/MathSqrt(denx[k])/deny;
      if(corr>corrMax)
        {
         corrMax=corr;
         knn=k;
         b=num/denx[k];
        }
     }
   Print("Дата ближайшего соседа ",Time[knn]," коэффициент корреляции с текущим паттерном равен ",corrMax);

//--- вычисляем xm[] и ym[] масштабированием ближайшего соседа
   double delta=Open[bars-1]-b*Open[knn+Npast-1];
   for(int i=0;i<Npast+Nfut;i++)
     {
      if(i<=Npast-1) xnn[bars-Npast+i]=b*Open[knn+i]+delta;
      if(i>=Npast-1) ynn[bars-Npast-Nfut+i]=b*Open[knn+i]+delta;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+

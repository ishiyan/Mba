//+X================================================================X+
//|                                                 Heiken AshiR.mq4 |
//|                      Copyright c 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+X================================================================X+
//| For Heiken Ashi we recommend next chart settings ( press F8 or   |
//| select on menu 'Charts'->'Properties...'):                       |
//|  - On 'Color' Tab select 'Black' for 'Line Graph'                |
//|  - On 'Common' Tab disable 'Chart on Foreground' checkbox and    |
//|    select 'Line Chart' radiobutton                               |
//+X================================================================X+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буфферов
#property indicator_buffers 4 
//---- цвета индикатора 
#property indicator_color1 Red  
#property indicator_color2 LimeGreen 
#property indicator_color3 Red
#property indicator_color4 LimeGreen
//---- толщина индикаторных линий
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3 
#property indicator_width4 3
//---- индикаторные буфферы
double L_Buffer[];
double H_Buffer[];
double O_Buffer[];
double C_Buffer[];
//+X===========================================================X+
//| Heiken Ashi# initialization function                        |
//+X===========================================================X+
int init()
 {
//----+
   //---- стиль изображения индикатора
   SetIndexStyle(0, DRAW_HISTOGRAM, 0);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0);
   SetIndexStyle(2, DRAW_HISTOGRAM, 0);
   SetIndexStyle(3, DRAW_HISTOGRAM, 0);
   //---- установка номера бара, 
              //начиная с которого будет отрисовываться индикатор  
   SetIndexDrawBegin(0, 10);
   SetIndexDrawBegin(1, 10);
   SetIndexDrawBegin(2, 10);
   SetIndexDrawBegin(3, 10);
   //---- 4 индикаторных буффера использованы для счёта
   SetIndexBuffer(0, L_Buffer);
   SetIndexBuffer(1, H_Buffer);
   SetIndexBuffer(2, O_Buffer);
   SetIndexBuffer(3, C_Buffer);
   //---- завершение инициализации
   return(0);
//----+
 }
//+X===========================================================X+
//| Heiken Ashii# teration function                             |
//+X===========================================================X+
int start()
 {
//----+
   //---- проверка количества баров на достаточность для расчёта
   if (Bars < 2)
             return(-1);
   //---- Объявление статических переменных              
   static bool TrueStart;
   //---- Объявление переменных с плавающей точкой  
   double haOpen, haHigh, haLow, haClose; 
   //---- Объявление целых переменных и получение уже посчитанных баров
   int limit, bar, MaxBar, counted_bars = IndicatorCounted(); 
   //---- Проверка на возможные ошибки
   if (counted_bars < 0)
                return(-1);
   //---- Последний подсчитанный бар должен быть пересчитан 
   if (counted_bars > 0)
              counted_bars--;
   //---- Определение номера самого старого бара, 
            //начиная с которого будет произедён пересчёт новых баров
   limit = Bars - counted_bars - 1;
   //---- Определение номера самого старого бара,
            // начиная с которого будет произедён пересчёт всех баров 
   MaxBar = Bars - 2;
   //---- Инициализация нуля
   if (limit >= MaxBar || !TrueStart)
    {
     limit = MaxBar;
     TrueStart = true;
     //----
     bar = MaxBar + 1;
     C_Buffer[bar] = (Open[bar] + High[bar] + 
                                        Low[bar] + Close[bar]) / 4.0;
     O_Buffer[bar] = Open[bar];
    }
              
   //----+ Основной цикл расчёта индикатора
   for(bar = limit; bar >= 0; bar--)
     {
      haOpen = (O_Buffer[bar + 1] + C_Buffer[bar + 1]) / 2.0;
      //----
      haClose = (Open[bar] + High[bar] + Low[bar] + Close[bar]) / 4.0;
      //----
      haHigh = MathMax(High[bar], MathMax(haOpen, haClose));
      //----
      haLow = MathMin(Low[bar], MathMin(haOpen, haClose));
      //----
      if (haOpen < haClose) 
        {
         L_Buffer[bar] = haLow;
         H_Buffer[bar] = haHigh;
        } 
      else
        {
         L_Buffer[bar] = haHigh;
         H_Buffer[bar] = haLow;
        }
      //----   
      O_Buffer[bar] = haOpen;
      C_Buffer[bar] = haClose;
     }
   //----+ завершение вычислений значений индикатора
   return(0);
//----+
 }
//+X--------------------+ <<< The End >>> +--------------------X+


/*
/---- 
Для  работы  индикатора  следует  положить файлы 
JJMASeries.mqh 
PriceSeries.mqh 
в папку (директорию): MetaTrader\experts\include\
Heiken Ashi#.mq4
в папку (директорию): MetaTrader\indicators\
*/
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//|                                                    FTLM,STLM.mq4 | 
//|           FTLM,STLM:      Copyright © 2002,      Finware.ru Ltd. |
//|                                           http://www.finware.ru/ |
//|      Mq4+JJMAsmooth:      Copyright © 2006,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
#property copyright "Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- отрисовка индикатора в отдельном окне 
#property indicator_separate_window
//---- количество индикаторных буфферов
#property indicator_buffers 1 
//---- цвет индикатора
#property indicator_color1 Red 
//---- ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА ююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююююжж+
extern int JMAsmooth=4; // глубина сглаживания полученного индикатора
extern int Smooth_Phase=100; // параметр, изменяющийся в пределах -100 ... +100, влияет на качество переходныx процессов сглаживания
extern int Input_Price_Customs = 0;//Выбор цен, по которым производится расчёт индикатора 
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.)
//---- жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж+
//---- индикаторные буфферы
double Ind_Buffer1 [];
double DPoint      [];
double Value       [];
double Series      [];
//---- целые переменные
int bar;
//---- переменные с плавающей точкой  
double DValue,value1,value2,FTLM.STLM;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| FTLM,STLM initialization function                                | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
int init()
{ 
//---- определение стиля исполнения графика
SetIndexStyle(0, DRAW_LINE); 
SetIndexDrawBegin(0,128);
//---- 4 индикаторных буффера использованы для счёта.
IndicatorBuffers(4);
SetIndexBuffer(0, Ind_Buffer1);
SetIndexBuffer(1, DPoint);
SetIndexBuffer(2, Value );
SetIndexBuffer(3, Series);
//---- установка значений индикатора, которые не будут видимы на графике
SetIndexEmptyValue(0,0.0); 
SetIndexEmptyValue(1,0.0); 
//---- имя для окон данных и лэйба для субъокон. 
SetIndexLabel     (0,"FTLM,STLM");
IndicatorShortName("FTLM,STLM");
//---- Установка формата точности (количество знаков после десятичной точки) для визуализации значений индикатора  
IndicatorDigits(0);
//---- установка алертов на недопустимые значения входных параметров ======================================================================================+ 
if(Smooth_Phase<-100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано -100");}//|
if(Smooth_Phase> 100){Alert("Параметр Smooth_Phase должен быть от -100 до +100" + " Вы ввели недопустимое " +Smooth_Phase+  " будет использовано  100");}//|
if(JMAsmooth<1){Alert("Параметр M_Period должен быть не менее 1"   + " Вы ввели недопустимое " +JMAsmooth+ " будет использовано  1");}/////////////////////|
PriceSeriesAlert(Input_Price_Customs);/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|
//+========================================================================================================================================================+ 
//---- завершение инициализации
return(0); 
} 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
//| FTLM,STLM  iteration function                                    | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
 int start() 
{
//---- проверка количества баров на достаточность для расчёта
if(Bars-1<=128+30)return(0);
//----+ Введение целых переменных и получение уже подсчитанных баров
//---- блокирование пересчёта всех подсчитанных и отрисованных баров при подключении к интернету
int reset,limit,MaxBar,counted_bars=INDICATOR_COUNTED(0); INDICATOR_COUNTED(1);
//---- проверка на возможные ошибки
if (counted_bars<0){INDICATOR_COUNTED(-1);return(-1);}
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//----+ Введение и инициализация внутренних переменных функции JJMASeries, nJMAnumber=1(Одно обращение к функции) 
if (counted_bars==0)JJMASeriesReset(1);
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
limit=Bars-counted_bars-1; MaxBar=Bars-1-128;
//----+ 
if (limit>Bars-1-90)
  { 
   for(bar=limit;bar>=Bars-1-90;bar--)
    { 
     Series[bar]=PriceSeries(Input_Price_Customs,bar); 
     Ind_Buffer1[bar]=0.0;
     Value      [bar]=0.0;
     DPoint     [bar]=0.0;
    }
    limit=Bars-1-90;
   }
//----+  
bar=limit; 
//----+ 
for(bar=limit;bar>=0;bar--)
  {
    Series[bar]=PriceSeries(Input_Price_Customs, bar);    
    //----+ 
    value1 = DigitFilter1(bar);  value2 = DigitFilter2(bar);
    //----+ 
    Value[bar] = (2*(value1-value2)+ Value[bar+1])/3;  
    //----+ 
    DPoint[bar] = Value[bar] - Value[bar+1];
  }
//----+  
if (limit>MaxBar)
  { 
   for(bar=limit;bar>=MaxBar;bar--)Ind_Buffer1[bar]=0.0;
   limit=MaxBar;
  }
//----+  
for(bar=limit;bar>=0;bar--)
  {
    DValue = DigitFilter3(bar);
    //---- нормализация индикаторного значения
    DValue = DValue/Point;
    //----+ JMA сглаживание полученного индикатора, параметр nJMAMaxBar уменьшен на размер фильтра 128
    //----+ Обращение к функции JJMASeries за номером 0, параметры nJMAPhase и nJMALength не меняются на каждом баре (nJMAdin=0)
    FTLM.STLM=JJMASeries(0,0,MaxBar,limit,Smooth_Phase,JMAsmooth,DValue,bar,reset);
    //----+ проверка на отсутствие ошибки в предыдущей операции
    if(reset!=0){INDICATOR_COUNTED(-1);return(-1);}
    Ind_Buffer1[bar]=FTLM.STLM; 
  }
//---- завершение вычислений значений индикатора
return(0); 
}

//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции JJMASeries (файл JJMASeries.mqh следует положить в папку (директорию): MetaTrader\experts\include)
//----+ Введение функции JJMASeriesReset (дополнительная функция файла JJMASeries.mqh)
//----+ Введение функции INDICATOR_COUNTED(дополнительная функция файла JJMASeries.mqh)
#include <JJMASeries.mqh> 
//+---------------------------------------------------------------------------------------------------------------------------+
//----+ Введение функции PriceSeries, файл PriceSeries.mqh следует положить в папку (директорию): MetaTrader\experts\include
//----+ Введение функции PriceSeriesAlert (дополнительная функция файла PriceSeries.mqh)
#include <PriceSeries.mqh>
//+---------------------------------------------------------------------------------------------------------------------------+

//----+ Введение функции DigitFilter1
double DigitFilter1(int DigitFilter1.bar)
{
double DigitFilter1.Rezalt=    
+0.0982862174*Series[bar+0]
+0.0975682269*Series[bar+1]
+0.0961401078*Series[bar+2]
+0.0940230544*Series[bar+3]
+0.0912437090*Series[bar+4]
+0.0878391006*Series[bar+5]
+0.0838544303*Series[bar+6]
+0.0793406350*Series[bar+7]
+0.0743569346*Series[bar+8]
+0.0689666682*Series[bar+9]
+0.0632381578*Series[bar+10]
+0.0572428925*Series[bar+11]
+0.0510534242*Series[bar+12]
+0.0447468229*Series[bar+13]
+0.0383959950*Series[bar+14]
+0.0320735368*Series[bar+15]
+0.0258537721*Series[bar+16]
+0.0198005183*Series[bar+17]
+0.0139807863*Series[bar+18]
+0.0084512448*Series[bar+19]
+0.0032639979*Series[bar+20]
-0.0015350359*Series[bar+21]
-0.0059060082*Series[bar+22]
-0.0098190256*Series[bar+23]
-0.0132507215*Series[bar+24]
-0.0161875265*Series[bar+25]
-0.0186164872*Series[bar+26]
-0.0205446727*Series[bar+27]
-0.0219739146*Series[bar+28]
-0.0229204861*Series[bar+29]
-0.0234080863*Series[bar+30]
-0.0234566315*Series[bar+31]
-0.0231017777*Series[bar+32]
-0.0223796900*Series[bar+33]
-0.0213300463*Series[bar+34]
-0.0199924534*Series[bar+35]
-0.0184126992*Series[bar+36]
-0.0166377699*Series[bar+37]
-0.0147139428*Series[bar+38]
-0.0126796776*Series[bar+39]
-0.0105938331*Series[bar+40]
-0.0084736770*Series[bar+41]
-0.0063841850*Series[bar+42]
-0.0043466731*Series[bar+43]
-0.0023956944*Series[bar+44]
-0.0005535180*Series[bar+45]
+0.0011421469*Series[bar+46]
+0.0026845693*Series[bar+47]
+0.0040471369*Series[bar+48]
+0.0052380201*Series[bar+49]
+0.0062194591*Series[bar+50]
+0.0070340085*Series[bar+51]
+0.0076266453*Series[bar+52]
+0.0080376628*Series[bar+53]
+0.0083037666*Series[bar+54]
+0.0083694798*Series[bar+55]
+0.0082901022*Series[bar+56]
+0.0080741359*Series[bar+57]
+0.0077543820*Series[bar+58]
+0.0073260526*Series[bar+59]
+0.0068163569*Series[bar+60]
+0.0062325477*Series[bar+61]
+0.0056078229*Series[bar+62]
+0.0049516078*Series[bar+63]
+0.0161380976*Series[bar+64];
return(DigitFilter1.Rezalt);
}
//----+

//----+ Введение функции DigitFilter2
double DigitFilter2(int DigitFilter2.bar)
{
double DigitFilter2.Rezalt=
-0.0074151919*Series[bar+0]
-0.0060698985*Series[bar+1]
-0.0044979052*Series[bar+2]
-0.0027054278*Series[bar+3]
-0.0007031702*Series[bar+4]
+0.0014951741*Series[bar+5]
+0.0038713513*Series[bar+6]
+0.0064043271*Series[bar+7]
+0.0090702334*Series[bar+8]
+0.0118431116*Series[bar+9]
+0.0146922652*Series[bar+10]
+0.0175884606*Series[bar+11]
+0.0204976517*Series[bar+12]
+0.0233865835*Series[bar+13]
+0.0262218588*Series[bar+14]
+0.0289681736*Series[bar+15]
+0.0315922931*Series[bar+16]
+0.0340614696*Series[bar+17]
+0.0363444061*Series[bar+18]
+0.0384120882*Series[bar+19]
+0.0402373884*Series[bar+20]
+0.0417969735*Series[bar+21]
+0.0430701377*Series[bar+22]
+0.0440399188*Series[bar+23]
+0.0446941124*Series[bar+24]
+0.0450230100*Series[bar+25]
+0.0450230100*Series[bar+26]
+0.0446941124*Series[bar+27]
+0.0440399188*Series[bar+28]
+0.0430701377*Series[bar+29]
+0.0417969735*Series[bar+30]
+0.0402373884*Series[bar+31]
+0.0384120882*Series[bar+32]
+0.0363444061*Series[bar+33]
+0.0340614696*Series[bar+34]
+0.0315922931*Series[bar+35]
+0.0289681736*Series[bar+36]
+0.0262218588*Series[bar+37]
+0.0233865835*Series[bar+38]
+0.0204976517*Series[bar+39]
+0.0175884606*Series[bar+40]
+0.0146922652*Series[bar+41]
+0.0118431116*Series[bar+42]
+0.0090702334*Series[bar+43]
+0.0064043271*Series[bar+44]
+0.0038713513*Series[bar+45]
+0.0014951741*Series[bar+46]
-0.0007031702*Series[bar+47]
-0.0027054278*Series[bar+48]
-0.0044979052*Series[bar+49]
-0.0060698985*Series[bar+50]
-0.0074151919*Series[bar+51]
-0.0085278517*Series[bar+52]
-0.0094111161*Series[bar+53]
-0.0100658241*Series[bar+54]
-0.0104994302*Series[bar+55]
-0.0107227904*Series[bar+56]
-0.0107450280*Series[bar+57]
-0.0105824763*Series[bar+58]
-0.0102517019*Series[bar+59]
-0.0097708805*Series[bar+60]
-0.0091581551*Series[bar+61]
-0.0084345004*Series[bar+62]
-0.0076214397*Series[bar+63]
-0.0067401718*Series[bar+64]
-0.0058083144*Series[bar+65]
-0.0048528295*Series[bar+66]
-0.0038816271*Series[bar+67]
-0.0029244713*Series[bar+68]
-0.0019911267*Series[bar+69]
-0.0010974211*Series[bar+70]
-0.0002535559*Series[bar+71]
+0.0005231953*Series[bar+72]
+0.0012297491*Series[bar+73]
+0.0018539149*Series[bar+74]
+0.0023994354*Series[bar+75]
+0.0028490136*Series[bar+76]
+0.0032221429*Series[bar+77]
+0.0034936183*Series[bar+78]
+0.0036818974*Series[bar+79]
+0.0038037944*Series[bar+80]
+0.0038338964*Series[bar+81]
+0.0037975350*Series[bar+82]
+0.0036986051*Series[bar+83]
+0.0035521320*Series[bar+84]
+0.0033559226*Series[bar+85]
+0.0031224409*Series[bar+86]
+0.0028550092*Series[bar+87]
+0.0025688349*Series[bar+88]
+0.0022682355*Series[bar+89]
+0.0073925495*Series[bar+90];
return(DigitFilter2.Rezalt);
}
//----+

//----+ Введение функции DigitFilter3
double DigitFilter3(int DigitFilter3.bar)
{
double DigitFilter3.Rezalt=
+0.4360409450*DPoint[bar+0]
+0.3658689069*DPoint[bar+1]
+0.2460452079*DPoint[bar+2]
+0.1104506886*DPoint[bar+3]
-0.0054034585*DPoint[bar+4]
-0.0760367731*DPoint[bar+5]
-0.0933058722*DPoint[bar+6]
-0.0670110374*DPoint[bar+7]
-0.0190795053*DPoint[bar+8]
+0.0259609206*DPoint[bar+9]
+0.0502044896*DPoint[bar+10]
+0.0477818607*DPoint[bar+11]
+0.0249252327*DPoint[bar+12]
-0.0047706151*DPoint[bar+13]
-0.0272432537*DPoint[bar+14]
-0.0338917071*DPoint[bar+15]
-0.0244141482*DPoint[bar+16]
-0.0055774838*DPoint[bar+17]
+0.0128149838*DPoint[bar+18]
+0.0226522218*DPoint[bar+19]
+0.0208778257*DPoint[bar+20]
+0.0100299086*DPoint[bar+21]
-0.0036771622*DPoint[bar+22]
-0.0136744850*DPoint[bar+23]
-0.0160483392*DPoint[bar+24]
-0.0108597376*DPoint[bar+25]
-0.0016060704*DPoint[bar+26]
+0.0069480557*DPoint[bar+27]
+0.0110573605*DPoint[bar+28]
+0.0095711419*DPoint[bar+29]
+0.0040444064*DPoint[bar+30]
-0.0023824623*DPoint[bar+31]
-0.0067093714*DPoint[bar+32]
-0.0072003400*DPoint[bar+33]
-0.0047717710*DPoint[bar+34]
+0.0005541115*DPoint[bar+35]
+0.0007860160*DPoint[bar+36]
+0.0130129076*DPoint[bar+37]
+0.0040364019*DPoint[bar+38];
return(DigitFilter3.Rezalt);  
}
//----+
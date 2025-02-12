//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                  PriceSeries.mqh |
//|                        Copyright © 2006,        Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+ 
// Функция PriceSeries() возвращает входную цену бара по его номеру nPriceSeries.Bar и
// по номеру цены PriceSeries.Input_Price_Customs:
//(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
//11-Heiken Ashi High, 12-Heiken Ashi Low, 13-Heiken Ashi Open, 14-Heiken Ashi Close,
// пример: minuse = PriceSeries(Input_Price_Customs, bar) - PriceSeries(Input_Price_Customs, bar+1);
// или;  Momentum = PriceSeries(Input_Price_Customs, bar) - PriceSeries(Input_Price_Customs, bar+Momentum_Period); 
  
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//++++++++++++++++++++++++++++++++++++ <<< PriceSeries >>> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+

double PriceSeries(int PriceSeries.Input_Price_Customs, int nPriceSeries.Bar)
{
double dPriceSeries;
switch(PriceSeries.Input_Price_Customs)
{
case  0: dPriceSeries = Close[nPriceSeries.Bar];break;
case  1: dPriceSeries = Open [nPriceSeries.Bar];break;
case  2: dPriceSeries =(High [nPriceSeries.Bar]+Low  [nPriceSeries.Bar])/2;break;
case  3: dPriceSeries = High [nPriceSeries.Bar];break;
case  4: dPriceSeries = Low  [nPriceSeries.Bar];break;
case  5: dPriceSeries =(Open [nPriceSeries.Bar]+High [nPriceSeries.Bar]+Low[nPriceSeries.Bar]+Close[nPriceSeries.Bar])/4;break;
case  6: dPriceSeries =(Open [nPriceSeries.Bar]+Close[nPriceSeries.Bar])/2;break;
case  7: dPriceSeries =(Close[nPriceSeries.Bar]+High [nPriceSeries.Bar]+Low[nPriceSeries.Bar])/3;break;
case  8: dPriceSeries =(Close[nPriceSeries.Bar]+High [nPriceSeries.Bar]+Low[nPriceSeries.Bar]+Close[nPriceSeries.Bar])/4;break;
case  9: dPriceSeries = TrendFollow00(nPriceSeries.Bar);break;
case 10: dPriceSeries = TrendFollow01(nPriceSeries.Bar);break;
case 11: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",0,nPriceSeries.Bar);break;
case 12: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",1,nPriceSeries.Bar);break;
case 13: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",2,nPriceSeries.Bar);break;
case 14: dPriceSeries = iCustom(NULL,0,"Heiken Ashi#",3,nPriceSeries.Bar);break;

default: dPriceSeries = Close[nPriceSeries.Bar];
}
return(dPriceSeries);
}
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+

//----+ введение функции PriceSeriesAlert -------------------------------------------------------+
// Функция PriceSeriesAlert() предназначена для индикации недопустимого значения параметра       |
// PriceSeries.Input_Price_Customs передаваемого в функцию PriceSeries().                        |
//----+ -----------------------------------------------------------------------------------------+
void PriceSeriesAlert(int nPriceSeriesAlert.IPC)
{
//+===================================================================================================================================================================+
if(nPriceSeriesAlert.IPC< 0){Alert("Параметр Input_Price_Customs должен быть не менее  0" + " Вы ввели недопустимое "+nPriceSeriesAlert.IPC+ " будет использовано 0");}
if(nPriceSeriesAlert.IPC>14){Alert("Параметр Input_Price_Customs должен быть не более 14" + " Вы ввели недопустимое "+nPriceSeriesAlert.IPC+ " будет использовано 0");}
//+===================================================================================================================================================================+
}
//----+ ----------------------------------------------------------------------------------------+

//----+ введение функции TrendFollow00. для case 9 ---------------------------------------------+
double TrendFollow00(int nTrendFollow00.Bar)
{
double dTrendFollow00;
if(Close[nTrendFollow00.Bar]>Open[nTrendFollow00.Bar])dTrendFollow00 = High [nTrendFollow00.Bar];
else
{
if(Close[nTrendFollow00.Bar]<Open[nTrendFollow00.Bar])dTrendFollow00 = Low  [nTrendFollow00.Bar];
                                                 else dTrendFollow00 = Close[nTrendFollow00.Bar];
}
return(dTrendFollow00);
}
//----+ ---------------------------------------------------------------------------------------+

//----+ введение функции TrendFollow01. для case 10 -------------------------------------------+
double TrendFollow01(int nTrendFollow01.Bar)
{
double dTrendFollow01;
if(Close[nTrendFollow01.Bar]>Open[nTrendFollow01.Bar])
                        dTrendFollow01 =(High [nTrendFollow01.Bar]+Close[nTrendFollow01.Bar])/2;
else
 {
if(Close[nTrendFollow01.Bar]<Open[nTrendFollow01.Bar])
                        dTrendFollow01 = (Low [nTrendFollow01.Bar]+Close[nTrendFollow01.Bar])/2;
                   else dTrendFollow01 = Close[nTrendFollow01.Bar];
 }
return(dTrendFollow01);
}
//----+ --------------------------------------------------------------------------------------+
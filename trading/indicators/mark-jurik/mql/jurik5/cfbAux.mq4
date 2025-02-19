//+------------------------------------------------------------------+
//|                                                          cfb.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1  Red

//
//
//
//
//

extern int    Depth = 30;
extern int    Price = PRICE_CLOSE;

//
//
//
//
//

double buffer1[];
double stored[][5];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,buffer1); SetIndexDrawBegin(0,Depth);
   return(0);
}
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;
   
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
           limit = Bars-counted_bars;
           if (ArrayRange(stored,0) != Bars) ArrayResize(stored,Bars);

   //
   //
   //
   //
   //

   for(i=limit, r=Bars-i-1; i>=0; i--, r++)
   {
      buffer1[i] = calculateCFB(i,r,Depth);
   }
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define _prices 0
#define _roc    1
#define _value1 2
#define _value2 3
#define _value3 4

//
//
//
//
//

double calculateCFB(int i, int r, int depth)
{
   stored[r][_prices] = iMA(NULL,0,1,0,MODE_SMA,Price,i);

   //
   //
   //
   //
   //

      stored[r][_roc]    = MathAbs(stored[r][_prices] - stored[r-1][_prices]);
      stored[r][_value1] = stored[r-1][_value1] - stored[r-depth][_roc] + stored[r][_roc];
      stored[r][_value2] = stored[r-1][_value2] - stored[r-1][_value1] + stored[r][_roc]*depth;
      stored[r][_value3] = stored[r-1][_value3] - stored[r-1-depth][_prices] + stored[r-1][_prices];
   
      double dividend = MathAbs(depth*stored[r][_prices]-stored[r][_value3]);

      //
      //
      //
      //
      //
         
   if (stored[r][_value2] != 0)
         return( dividend / stored[r][_value2]);
   else  return(0.00);            
}  

//+------------------------------------------------------------------+
/*
function JCFBaux(Series: Integer; Depth: Integer): integer;
begin
var Bar: integer;
var sName: string;
var Value: float;

sName := 'JCFBaux(' + GetDescription(Series) + ',' + IntToStr(Depth) + ')';
Result := FindNamedSeries(sName);
if Result >= 0 then Exit;
Result := CreateNamedSeries(sName);

var jrc04, jrc05, jrc06, jrc08: float;
var jrc03, jrc07: integer;

jrc03 := CreateSeries;
for Bar := 1 to BarCount() - 1 do
@jrc03[Bar] := abs(@Series[Bar] - @Series[Bar-1]);

for Bar := Depth to BarCount() - 1 do
begin
if Bar <= Depth*2 then begin
jrc04 := 0;
jrc05 := 0;
jrc06 := 0;
for jrc07 := 0 to Depth-1 do begin
jrc04 := jrc04 + abs(@Series[Bar-jrc07] - @Series[Bar-jrc07-1]);
jrc05 := jrc05 + (Depth - jrc07) * abs(@Series[Bar-jrc07] - @Series[Bar-jrc07-1]);
jrc06 := jrc06 + @Series[Bar-jrc07-1];
end
end else begin
jrc05 := jrc05 - jrc04 + @jrc03[Bar] * Depth;
jrc04 := jrc04 - @jrc03[Bar-Depth] + @jrc03[Bar];
jrc06 := jrc06 - @Series[Bar-Depth-1] + @Series[Bar-1];
end;
jrc08 := abs(Depth * @Series[Bar] - jrc06);
if (jrc05 = 0) then Value := 0 else Value := jrc08 / jrc05;
@Result[Bar] := Value;
end;
end;

function JCFB24(Series: Integer; Smooth: Integer): integer;
begin
var Bar: integer;
var sName: string;
var Value: float;

sName := 'JCFB24(' + GetDescription(Series) + ',' + IntToStr(Smooth) + ')';
Result := FindNamedSeries(sName);
if Result >= 0 then Exit;
Result := CreateNamedSeries(sName);

var er1, er2, er3, er4, er5, er6, er7, er8, er20, er21, er29: integer;
var er15, er16, er17, er18, er19: float;
var er22, er23: array[1..8] of float;

er15 := 1;
er16 := 1;
er19 := 20;
er29 := Smooth;
er1 := JCFBaux(Series, 2);
er2 := JCFBaux(Series, 3);
er3 := JCFBaux(Series, 4);
er4 := JCFBaux(Series, 6);
er5 := JCFBaux(Series, 8);
er6 := JCFBaux(Series, 12);
er7 := JCFBaux(Series, 16);
er8 := JCFBaux(Series, 24);

for Bar := 1 to BarCount() - 1 do
begin
if (Bar <= er29) then begin
for er21 := 1 to 8 do
er23[er21] := 0;
for er20 := 0 to Bar-1 do begin
er23[1] := er23[1] + @er1[Bar-er20];
er23[2] := er23[2] + @er2[Bar-er20];
er23[3] := er23[3] + @er3[Bar-er20];
er23[4] := er23[4] + @er4[Bar-er20];
er23[5] := er23[5] + @er5[Bar-er20];
er23[6] := er23[6] + @er6[Bar-er20];
er23[7] := er23[7] + @er7[Bar-er20];
er23[8] := er23[8] + @er8[Bar-er20];
end;
for er21 := 1 to 8 do
er23[er21] := er23[er21] / Bar;
end else begin
er23[1] := er23[1] + (@er1[Bar] - @er1[Bar-er29]) / er29;
er23[2] := er23[2] + (@er2[Bar] - @er2[Bar-er29]) / er29;
er23[3] := er23[3] + (@er3[Bar] - @er3[Bar-er29]) / er29;
er23[4] := er23[4] + (@er4[Bar] - @er4[Bar-er29]) / er29;
er23[5] := er23[5] + (@er5[Bar] - @er5[Bar-er29]) / er29;
er23[6] := er23[6] + (@er6[Bar] - @er6[Bar-er29]) / er29;
er23[7] := er23[7] + (@er7[Bar] - @er7[Bar-er29]) / er29;
er23[8] := er23[8] + (@er8[Bar] - @er8[Bar-er29]) / er29;
end;
if Bar > 5 then begin
er15 := 1;                    er22[8] := er15 * er23[8];
er15 := er15 * (1 - er22[8]); er22[6] := er15 * er23[6];
er15 := er15 * (1 - er22[6]); er22[4] := er15 * er23[4];
er15 := er15 * (1 - er22[4]); er22[2] := er15 * er23[2];
er16 := 1;                    er22[7] := er16 * er23[7];
er16 := er16 * (1 - er22[7]); er22[5] := er16 * er23[5];
er16 := er16 * (1 - er22[5]); er22[3] := er16 * er23[3];
er16 := er16 * (1 - er22[3]); er22[1] := er16 * er23[1];

er17 := er22[1]*er22[1]*2 + 
        er22[3]*er22[3]*4 +
        er22[5]*er22[5]*8 + 
        er22[7]*er22[7]*16 +
        er22[2]*er22[2]*3 +
        er22[4]*er22[4]*6 +
        er22[6]*er22[6]*12 +
        er22[8]*er22[8]*24;
er18 := er22[1]*er22[1] + er22[3]*er22[3] +
er22[5]*er22[5] + er22[7]*er22[7] +

er22[2]*er22[2] + er22[4]*er22[4] +
er22[6]*er22[6] + er22[8]*er22[8];
if (er18 = 0) then er19 := 0 else er19 := er17 / er18;
end;
@Result[Bar] := er19;
end;
end;

function JCFB48(Series: Integer; Smooth: Integer): integer;
begin
var Bar: integer;
var sName: string;
var Value: float;

sName := 'JCFB48(' + GetDescription(Series) + ',' + IntToStr(Smooth) + ')';
Result := FindNamedSeries(sName);
if Result >= 0 then Exit;
Result := CreateNamedSeries(sName);

var er1, er2, er3, er4, er5, er6, er7, er8, er9, er10, er20, er21, er29: integer;
var er15, er16, er17, er18, er19: float;
var er22, er23: array[1..10] of float;

er15 := 1;
er16 := 1;
er19 := 20;
er29 := Smooth;
er1 := JCFBaux(Series, 2);
er2 := JCFBaux(Series, 3);
er3 := JCFBaux(Series, 4);
er4 := JCFBaux(Series, 6);
er5 := JCFBaux(Series, 8);
er6 := JCFBaux(Series, 12);
er7 := JCFBaux(Series, 16);
er8 := JCFBaux(Series, 24);
er9 := JCFBaux(Series, 32);
er10 := JCFBaux(Series, 48);

for Bar := 1 to BarCount() - 1 do
begin
if Bar <= er29 then begin
for er21 := 1 to 10 do
er23[er21] := 0;
for er20 := 0 to Bar-1 do begin
er23[1] := er23[1] + @er1[Bar-er20];
er23[2] := er23[2] + @er2[Bar-er20];
er23[3] := er23[3] + @er3[Bar-er20];
er23[4] := er23[4] + @er4[Bar-er20];
er23[5] := er23[5] + @er5[Bar-er20];
er23[6] := er23[6] + @er6[Bar-er20];
er23[7] := er23[7] + @er7[Bar-er20];
er23[8] := er23[8] + @er8[Bar-er20];
er23[9] := er23[9] + @er9[Bar-er20];
er23[10] := er23[10] + @er10[Bar-er20];
end;
for er21 := 1 to 10 do
er23[er21] := er23[er21] / Bar;
end else begin
er23[1] := er23[1] + (@er1[Bar] - @er1[Bar-er29]) / er29;
er23[2] := er23[2] + (@er2[Bar] - @er2[Bar-er29]) / er29;
er23[3] := er23[3] + (@er3[Bar] - @er3[Bar-er29]) / er29;
er23[4] := er23[4] + (@er4[Bar] - @er4[Bar-er29]) / er29;
er23[5] := er23[5] + (@er5[Bar] - @er5[Bar-er29]) / er29;
er23[6] := er23[6] + (@er6[Bar] - @er6[Bar-er29]) / er29;
er23[7] := er23[7] + (@er7[Bar] - @er7[Bar-er29]) / er29;
er23[8] := er23[8] + (@er8[Bar] - @er8[Bar-er29]) / er29;
er23[9] := er23[9] + (@er9[Bar] - @er9[Bar-er29]) / er29;
er23[10] := er23[10] + (@er10[Bar] - @er10[Bar-er29]) / er29;
end;
if Bar > 5 then begin
er15 := 1;
er22[10] := er15 * er23[10];
er15 := er15 * (1 - er22[10]);
er22[8] := er15 * er23[8];
er15 := er15 * (1 - er22[8]);
er22[6] := er15 * er23[6];
er15 := er15 * (1 - er22[6]);
er22[4] := er15 * er23[4];
er15 := er15 * (1 - er22[4]);
er22[2] := er15 * er23[2];
er16 := 1;
er22[9] := er16 * er23[9];
er16 := er16 * (1 - er22[9]);
er22[7] := er16 * er23[7];
er16 := er16 * (1 - er22[7]);
er22[5] := er16 * er23[5];
er16 := er16 * (1 - er22[5]);
er22[3] := er16 * er23[3];
er16 := er16 * (1 - er22[3]);
er22[1] := er16 * er23[1];
er17 := er22[1]*er22[1]*2 + er22[3]*er22[3]*4 +
er22[5]*er22[5]*8 + er22[7]*er22[7]*16 +
er22[9]*er22[9]*32 + er22[2]*er22[2]*3 +
er22[4]*er22[4]*6 + er22[6]*er22[6]*12 +
er22[8]*er22[8]*24 + er22[10]*er22[10]*48;
er18 := er22[1]*er22[1] + er22[3]*er22[3] +
er22[5]*er22[5] + er22[7]*er22[7] +
er22[9]*er22[9] + er22[2]*er22[2] +
er22[4]*er22[4] + er22[6]*er22[6] +
er22[8]*er22[8] + er22[10]*er22[10];
if (er18 = 0) then er19 := 0 else er19 := er17 / er18;
end;
@Result[Bar] := er19;
end;
end;

function JCFB96(Series: Integer; Smooth: Integer): integer;
begin
var Bar: integer;
var sName: string;
var Value: float;

sName := 'JCFB96(' + GetDescription(Series) + ',' + IntToStr(Smooth) + ')';
Result := FindNamedSeries(sName);
if Result >= 0 then Exit;
Result := CreateNamedSeries(sName);

var er1, er2, er3, er4, er5, er6, er7, er8, er9, er10, er11, er12, er20, er21, er29: integer;
var er15, er16, er17, er18, er19: float;
var er22, er23: array[1..12] of float;

er15 := 1;
er16 := 1;
er19 := 20;
er29 := Smooth;
er1 := JCFBaux(Series, 2);
er2 := JCFBaux(Series, 3);
er3 := JCFBaux(Series, 4);
er4 := JCFBaux(Series, 6);
er5 := JCFBaux(Series, 8);
er6 := JCFBaux(Series, 12);
er7 := JCFBaux(Series, 16);
er8 := JCFBaux(Series, 24);
er9 := JCFBaux(Series, 32);
er10 := JCFBaux(Series, 48);
er11 := JCFBaux(Series, 64);
er12 := JCFBaux(Series, 96);

for Bar := 1 to BarCount() - 1 do
begin
if Bar <= er29 then begin
for er21 := 1 to 12 do
er23[er21] := 0;
for er20 := 0 to Bar-1 do begin
er23[1] := er23[1] + @er1[Bar-er20];
er23[2] := er23[2] + @er2[Bar-er20];
er23[3] := er23[3] + @er3[Bar-er20];
er23[4] := er23[4] + @er4[Bar-er20];
er23[5] := er23[5] + @er5[Bar-er20];
er23[6] := er23[6] + @er6[Bar-er20];
er23[7] := er23[7] + @er7[Bar-er20];
er23[8] := er23[8] + @er8[Bar-er20];
er23[9] := er23[9] + @er9[Bar-er20];
er23[10] := er23[10] + @er10[Bar-er20];
er23[11] := er23[11] + @er11[Bar-er20];
er23[12] := er23[12] + @er12[Bar-er20];
end;
for er21 := 1 to 12 do
er23[er21] := er23[er21] / Bar;
end else begin
er23[1] := er23[1] + (@er1[Bar] - @er1[Bar-er29]) / er29;
er23[2] := er23[2] + (@er2[Bar] - @er2[Bar-er29]) / er29;
er23[3] := er23[3] + (@er3[Bar] - @er3[Bar-er29]) / er29;
er23[4] := er23[4] + (@er4[Bar] - @er4[Bar-er29]) / er29;
er23[5] := er23[5] + (@er5[Bar] - @er5[Bar-er29]) / er29;
er23[6] := er23[6] + (@er6[Bar] - @er6[Bar-er29]) / er29;
er23[7] := er23[7] + (@er7[Bar] - @er7[Bar-er29]) / er29;
er23[8] := er23[8] + (@er8[Bar] - @er8[Bar-er29]) / er29;
er23[9] := er23[9] + (@er9[Bar] - @er9[Bar-er29]) / er29;
er23[10] := er23[10] + (@er10[Bar] - @er10[Bar-er29]) / er29;
er23[11] := er23[11] + (@er11[Bar] - @er11[Bar-er29]) / er29;
er23[12] := er23[12] + (@er12[Bar] - @er12[Bar-er29]) / er29;
end;
if Bar > 5 then begin
er15 := 1;
er22[12] := er15 * er23[12];
er15 := er15 * (1 - er22[12]);
er22[10] := er15 * er23[10];
er15 := er15 * (1 - er22[10]);
er22[8] := er15 * er23[8];
er15 := er15 * (1 - er22[8]);
er22[6] := er15 * er23[6];
er15 := er15 * (1 - er22[6]);
er22[4] := er15 * er23[4];
er15 := er15 * (1 - er22[4]);
er22[2] := er15 * er23[2];
er16 := 1;
er22[11] := er16 * er23[11];
er16 := er16 * (1 - er22[11]);
er22[9] := er16 * er23[9];
er16 := er16 * (1 - er22[9]);
er22[7] := er16 * er23[7];
er16 := er16 * (1 - er22[7]);
er22[5] := er16 * er23[5];
er16 := er16 * (1 - er22[5]);
er22[3] := er16 * er23[3];
er16 := er16 * (1 - er22[3]);
er22[1] := er16 * er23[1];
er17 := er22[1]*er22[1]*2 + er22[3]*er22[3]*4 +
er22[5]*er22[5]*8 + er22[7]*er22[7]*16 +
er22[9]*er22[9]*32 + er22[11]*er22[11]*64 +
er22[2]*er22[2]*3 + er22[4]*er22[4]*6 +
er22[6]*er22[6]*12 + er22[8]*er22[8]*24 +
er22[10]*er22[10]*48 + er22[12]*er22[12]*96;
er18 := er22[1]*er22[1] + er22[3]*er22[3] +
er22[5]*er22[5] + er22[7]*er22[7] +
er22[9]*er22[9] + er22[11]*er22[11] +
er22[2]*er22[2] + er22[4]*er22[4] +
er22[6]*er22[6] + er22[8]*er22[8] +
er22[10]*er22[10] + er22[12]*er22[12];
if (er18 = 0) then er19 := 0 else er19 := er17 / er18;
end;
@Result[Bar] := er19;
end;
end;

function JCFB192(Series: Integer; Smooth: Integer): integer;
begin
var Bar: integer;
var sName: string;
var Value: float;

sName := 'JCFB192(' + GetDescription(Series) + ',' + IntToStr(Smooth) + ')';
Result := FindNamedSeries(sName);
if Result >= 0 then Exit;
Result := CreateNamedSeries(sName);

var er1, er2, er3, er4, er5, er6, er7, er8, er9, er10, er11, er12, er13, er14, er20, er21, er29: integer;
var er15, er16, er17, er18, er19: float;
var er22, er23: array[1..14] of float;

er15 := 1;
er16 := 1;
er19 := 20;
er29 := Smooth;
er1 := JCFBaux(Series, 2);
er2 := JCFBaux(Series, 3);
er3 := JCFBaux(Series, 4);
er4 := JCFBaux(Series, 6);
er5 := JCFBaux(Series, 8);
er6 := JCFBaux(Series, 12);
er7 := JCFBaux(Series, 16);
er8 := JCFBaux(Series, 24);
er9 := JCFBaux(Series, 32);
er10 := JCFBaux(Series, 48);
er11 := JCFBaux(Series, 64);
er12 := JCFBaux(Series, 96);
er13 := JCFBaux(Series, 128);
er14 := JCFBaux(Series, 192);

for Bar := 1 to BarCount() - 1 do
begin
if Bar <= er29 then begin
for er21 := 1 to 14 do
er23[er21] := 0;
for er20 := 0 to Bar-1 do begin
er23[1] := er23[1] + @er1[Bar-er20];
er23[2] := er23[2] + @er2[Bar-er20];
er23[3] := er23[3] + @er3[Bar-er20];
er23[4] := er23[4] + @er4[Bar-er20];
er23[5] := er23[5] + @er5[Bar-er20];
er23[6] := er23[6] + @er6[Bar-er20];
er23[7] := er23[7] + @er7[Bar-er20];
er23[8] := er23[8] + @er8[Bar-er20];
er23[9] := er23[9] + @er9[Bar-er20];
er23[10] := er23[10] + @er10[Bar-er20];
er23[11] := er23[11] + @er11[Bar-er20];
er23[12] := er23[12] + @er12[Bar-er20];
er23[13] := er23[13] + @er13[Bar-er20];
er23[14] := er23[14] + @er14[Bar-er20];
end;
for er21 := 1 to 14 do
er23[er21] := er23[er21] / Bar;
end else begin
er23[1] := er23[1] + (@er1[Bar] - @er1[Bar-er29]) / er29;
er23[2] := er23[2] + (@er2[Bar] - @er2[Bar-er29]) / er29;
er23[3] := er23[3] + (@er3[Bar] - @er3[Bar-er29]) / er29;
er23[4] := er23[4] + (@er4[Bar] - @er4[Bar-er29]) / er29;
er23[5] := er23[5] + (@er5[Bar] - @er5[Bar-er29]) / er29;
er23[6] := er23[6] + (@er6[Bar] - @er6[Bar-er29]) / er29;
er23[7] := er23[7] + (@er7[Bar] - @er7[Bar-er29]) / er29;
er23[8] := er23[8] + (@er8[Bar] - @er8[Bar-er29]) / er29;
er23[9] := er23[9] + (@er9[Bar] - @er9[Bar-er29]) / er29;
er23[10] := er23[10] + (@er10[Bar] - @er10[Bar-er29]) / er29;
er23[11] := er23[11] + (@er11[Bar] - @er11[Bar-er29]) / er29;
er23[12] := er23[12] + (@er12[Bar] - @er12[Bar-er29]) / er29;
er23[13] := er23[13] + (@er13[Bar] - @er13[Bar-er29]) / er29;
er23[14] := er23[14] + (@er14[Bar] - @er14[Bar-er29]) / er29;
end;
if Bar > 5 then begin
er15 := 1;
er22[14] := er15 * er23[14];
er15 := er15 * (1 - er22[14]);
er22[12] := er15 * er23[12];
er15 := er15 * (1 - er22[12]);
er22[10] := er15 * er23[10];
er15 := er15 * (1 - er22[10]);
er22[8] := er15 * er23[8];
er15 := er15 * (1 - er22[8]);
er22[6] := er15 * er23[6];
er15 := er15 * (1 - er22[6]);
er22[4] := er15 * er23[4];
er15 := er15 * (1 - er22[4]);
er22[2] := er15 * er23[2];
er16 := 1;
er22[13] := er16 * er23[13];
er16 := er16 * (1 - er22[13]);
er22[11] := er16 * er23[11];
er16 := er16 * (1 - er22[11]);
er22[9] := er16 * er23[9];
er16 := er16 * (1 - er22[9]);
er22[7] := er16 * er23[7];
er16 := er16 * (1 - er22[7]);
er22[5] := er16 * er23[5];
er16 := er16 * (1 - er22[5]);
er22[3] := er16 * er23[3];
er16 := er16 * (1 - er22[3]);
er22[1] := er16 * er23[1];
er17 := er22[1]*er22[1]*2 + er22[3]*er22[3]*4 +
er22[5]*er22[5]*8 + er22[7]*er22[7]*16 +
er22[9]*er22[9]*32 + er22[11]*er22[11]*64 +
er22[13]*er22[13]*128 + er22[2]*er22[2]*3 +
er22[4]*er22[4]*6 + er22[6]*er22[6]*12 +
er22[8]*er22[8]*24 + er22[10]*er22[10]*48 +
er22[12]*er22[12]*96 + er22[14]*er22[14]*192;
er18 := er22[1]*er22[1] + er22[3]*er22[3] +
er22[5]*er22[5] + er22[7]*er22[7] +
er22[9]*er22[9] + er22[11]*er22[11] +
er22[13]*er22[13] + er22[2]*er22[2] +
er22[4]*er22[4] + er22[6]*er22[6] +
er22[8]*er22[8] + er22[10]*er22[10] +
er22[12]*er22[12] + er22[14]*er22[14];
if (er18 = 0) then er19 := 0 else er19 := er17 / er18;
end;
@Result[Bar] := er19;
end;
end;

function JCFBSeries(Series: Integer; FractalType: Integer; Smooth: Integer): integer;
begin
var Bar: integer;
var sName: string;
var Value: integer;

sName := 'JCFB(' + GetDescription(Series) + ',' + IntToStr(FractalType) + ',' + IntToStr(Smooth) + ')';
Result := FindNamedSeries(sName);
if Result >= 0 then Exit;
Result := CreateNamedSeries(sName);

for Bar := 0 to BarCount() - 1 do
begin
if (FractalType = 1) then Value := JCFB24(Series, Smooth);
if (FractalType = 2) then Value := JCFB48(Series, Smooth);
if (FractalType = 3) then Value := JCFB96(Series, Smooth);
if (FractalType = 4) then Value := JCFB192(Series, Smooth);
@Result[Bar] := @Value[Bar];
end;
end;

function JCFB(Bar: integer; Series: Integer; FractalType: Integer; Smooth: Integer): float;
begin
Result := GetSeriesValue(Bar, JCFBSeries(Series, FractalType, Smooth));
end;

var my_JJMASeries1,RI, my_JJMASeries2, PctRPane,my_JJMASeries3,P, BAR : integer;
var rv,rn: float;
PctRPane := CreatePane( 75, true, true );
const Period = 15;
my_JJMASeries2:=createSeries();
my_JJMASeries3:=createSeries();

for Bar := Period to BarCount - 2 do begin

my_JJMASeries1 := jcfbSeries(#close,2,14);
ri:=Int(jcfb(bar,#close,2,14));

rv:=Highest(bar-1,#high,ri);
rn:=Lowest(bar-1,#Low,ri);

PlotSeries( my_JJMASeries1, PctRPane, #Green, #Thin );

SetSeriesValue(bar, my_JJMASeries2, rv);
PlotSeries( my_JJMASeries2, 0, #Red, #Thin );
SetSeriesValue(bar, my_JJMASeries3, rn);
PlotSeries( my_JJMASeries3, 0, #Green, #Thin );
{ position entry rules }
If MarketPosition<=0 then
begin
if PriceHigh(bar)>rv then
BuyAtMarket(bar+1,'BuyStop');
end;

if MarketPosition>=0 then
if PriceLow(bar)<rn then
begin
SellAtStop(bar,rn,Lastposition,'StopL');
end;
end;
*/


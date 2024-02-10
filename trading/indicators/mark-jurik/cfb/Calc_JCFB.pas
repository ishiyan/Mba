unit Calc;
{  Декомпиляция индикаторов от M.Jurik          }
{  Created by Starlight (extesy@yandex.ru)      }

interface
uses
  Math;

type
  TSeries = array of Double;            // Серия данных

function JCFBSeries (const SrcA: TSeries; AFractalType: Integer; ASmooth: Integer): TSeries;

implementation

function JCFBaux(SrcA: TSeries; Depth: Integer): TSeries;
var
  Bar: integer;
  Value: Double;
  jrc04, jrc05, jrc06, jrc08: Double;
  jrc07: integer;
  IntA: TSeries;
begin
  SetLength (Result, High(SrcA) + 1);
  jrc04 := 0; jrc05 := 0;
  jrc06 := 0; jrc08 := 0;
  jrc07 := 0;

  SetLength (IntA, High(SrcA) + 1);
  for Bar := 1 to High (SrcA) do
    IntA[Bar] := abs(SrcA[Bar] - SrcA[Bar-1]);

  for Bar := Depth to High (SrcA) - 1 do begin
    if Bar <= Depth*2 then begin
      jrc04 := 0;
      jrc05 := 0;
      jrc06 := 0;
      for jrc07 := 0 to Depth-1 do begin
        jrc04 := jrc04 + abs(SrcA[Bar-jrc07] - SrcA[Bar-jrc07-1]);
        jrc05 := jrc05 + (Depth - jrc07) * abs(SrcA[Bar-jrc07] - SrcA[Bar-jrc07-1]);
        jrc06 := jrc06 + SrcA[Bar-jrc07-1];
      end
    end else begin
      jrc05 := jrc05 - jrc04 + IntA[Bar] * Depth;
      jrc04 := jrc04 - IntA[Bar-Depth] + IntA[Bar];
      jrc06 := jrc06 - SrcA[Bar-Depth-1] + SrcA[Bar-1];
    end;
    jrc08 := abs(Depth * SrcA[Bar] - jrc06);
    if (jrc05 = 0) then Value := 0 else Value := jrc08 / jrc05;
    Result[Bar] := Value;
  end;
end;

function JCFB24(SrcA: TSeries; Smooth: Integer): TSeries;
var
  Bar: integer;
  Value: Double;
  er1, er2, er3, er4, er5, er6, er7, er8: TSeries;
  er20, er21, er29: integer;
  er15, er16, er17, er18, er19: Double;
  er22, er23: array[1..8] of Double;
begin
  SetLength (Result, High(SrcA) + 1);
  er20 := 0; er21 := 0; er29 := 0; er15 := 0; er16 := 0; er17 := 0; er18 := 0;
  er19 := 0;
  FillChar (er22, sizeof(er22), 0);
  FillChar (er23, sizeof(er23), 0);

  er15 := 1;
  er16 := 1;
  er19 := 20;
  er29 := Smooth;

  er1 := JCFBaux (SrcA, 2);     //  er1 := JCFBaux(Series, 2);
  er2 := JCFBaux (SrcA, 3);     //  JCFBaux(Series, 3);
  er3 := JCFBaux (SrcA, 4);     //  JCFBaux(Series, 4);
  er4 := JCFBaux (SrcA, 6);     //  JCFBaux(Series, 6);
  er5 := JCFBaux (SrcA, 8);     //  JCFBaux(Series, 8);
  er6 := JCFBaux (SrcA, 12);    //  JCFBaux(Series, 12);
  er7 := JCFBaux (SrcA, 16);    //  JCFBaux(Series, 16);
  er8 := JCFBaux (SrcA, 24);    //  JCFBaux(Series, 24);

  for Bar := 1 to High (SrcA) do begin
    if (Bar <= er29) then begin
      for er21 := 1 to 8 do
        er23[er21] := 0;
    	for er20 := 0 to Bar-1 do begin
    	  er23[1] := er23[1] + er1[Bar-er20];
          er23[2] := er23[2] + er2[Bar-er20];
    	  er23[3] := er23[3] + er3[Bar-er20];
          er23[4] := er23[4] + er4[Bar-er20];
    	  er23[5] := er23[5] + er5[Bar-er20];
          er23[6] := er23[6] + er6[Bar-er20];
	  er23[7] := er23[7] + er7[Bar-er20];
          er23[8] := er23[8] + er8[Bar-er20];
    	end;
    	for er21 := 1 to 8 do
    	  er23[er21] := er23[er21] / Bar;
    end else begin
    	er23[1] := er23[1] + (er1[Bar] - er1[Bar-er29]) / er29;
        er23[2] := er23[2] + (er2[Bar] - er2[Bar-er29]) / er29;
    	er23[3] := er23[3] + (er3[Bar] - er3[Bar-er29]) / er29;
        er23[4] := er23[4] + (er4[Bar] - er4[Bar-er29]) / er29;
    	er23[5] := er23[5] + (er5[Bar] - er5[Bar-er29]) / er29;
        er23[6] := er23[6] + (er6[Bar] - er6[Bar-er29]) / er29;
    	er23[7] := er23[7] + (er7[Bar] - er7[Bar-er29]) / er29;
      er23[8] := er23[8] + (er8[Bar] - er8[Bar-er29]) / er29;
    end;
    if Bar > 5 then begin
    	er15 := 1;
    	er22[8] := er15 * er23[8];
        er15 := er15 * (1 - er22[8]);
    	er22[6] := er15 * er23[6];
        er15 := er15 * (1 - er22[6]);
    	er22[4] := er15 * er23[4];
        er15 := er15 * (1 - er22[4]);
    	er22[2] := er15 * er23[2];
    	er16 := 1;
    	er22[7] := er16 * er23[7];
        er16 := er16 * (1 - er22[7]);
    	er22[5] := er16 * er23[5];
        er16 := er16 * (1 - er22[5]);
    	er22[3] := er16 * er23[3];
        er16 := er16 * (1 - er22[3]);
    	er22[1] := er16 * er23[1];
    	er17 := er22[1]*er22[1]*2 + er22[3]*er22[3]*4 +
              er22[5]*er22[5]*8 + er22[7]*er22[7]*16 +
              er22[2]*er22[2]*3 + er22[4]*er22[4]*6 +
              er22[6]*er22[6]*12 + er22[8]*er22[8]*24;
    	er18 := er22[1]*er22[1] + er22[3]*er22[3] +
              er22[5]*er22[5] + er22[7]*er22[7] +
              er22[2]*er22[2] + er22[4]*er22[4] +
              er22[6]*er22[6] + er22[8]*er22[8];
      if (er18 = 0) then er19 := 0 else er19 := er17 / er18;
    end;
    Result[Bar] := er19;
  end;
end;

function JCFB48(SrcA: TSeries; Smooth: Integer): TSeries;
var
  Bar: integer;
  Value: Double;
  er1, er2, er3, er4, er5, er6, er7, er8, er9, er10: TSeries;
  er20, er21, er29: integer;
  er15, er16, er17, er18, er19: Double;
  er22, er23: array[1..10] of Double;
begin
  SetLength (Result, High(SrcA) + 1);
  er20 := 0; er21 := 0; er29 := 0;
  er15 := 0; er16 := 0; er17 := 0; er18 := 0; er19 := 0;

  FillChar (er22, sizeof(er22), 0);
  FillChar (er23, sizeof(er23), 0);

  er15 := 1;
  er16 := 1;
  er19 := 20;
  er29 := Smooth;

  er1 := JCFBaux(SrcA, 2);
  er2 := JCFBaux(SrcA, 3);
  er3 := JCFBaux(SrcA, 4);
  er4 := JCFBaux(SrcA, 6);
  er5 := JCFBaux(SrcA, 8);
  er6 := JCFBaux(SrcA, 12);
  er7 := JCFBaux(SrcA, 16);
  er8 := JCFBaux(SrcA, 24);
  er9 := JCFBaux(SrcA, 32);
  er10 := JCFBaux(SrcA, 48);

  for Bar := 1 to High(SrcA) do begin
    if Bar <= er29 then begin
      for er21 := 1 to 10 do
        er23[er21] := 0;
      for er20 := 0 to Bar-1 do begin
        er23[1] := er23[1] + er1[Bar-er20];
        er23[2] := er23[2] + er2[Bar-er20];
        er23[3] := er23[3] + er3[Bar-er20];
        er23[4] := er23[4] + er4[Bar-er20];
        er23[5] := er23[5] + er5[Bar-er20];
        er23[6] := er23[6] + er6[Bar-er20];
        er23[7] := er23[7] + er7[Bar-er20];
        er23[8] := er23[8] + er8[Bar-er20];
        er23[9] := er23[9] + er9[Bar-er20];
        er23[10] := er23[10] + er10[Bar-er20];
      end;
      for er21 := 1 to 10 do
        er23[er21] := er23[er21] / Bar;
    end else begin
      er23[1] := er23[1] + (er1[Bar] - er1[Bar-er29]) / er29;
      er23[2] := er23[2] + (er2[Bar] - er2[Bar-er29]) / er29;
      er23[3] := er23[3] + (er3[Bar] - er3[Bar-er29]) / er29;
      er23[4] := er23[4] + (er4[Bar] - er4[Bar-er29]) / er29;
      er23[5] := er23[5] + (er5[Bar] - er5[Bar-er29]) / er29;
      er23[6] := er23[6] + (er6[Bar] - er6[Bar-er29]) / er29;
      er23[7] := er23[7] + (er7[Bar] - er7[Bar-er29]) / er29;
      er23[8] := er23[8] + (er8[Bar] - er8[Bar-er29]) / er29;
      er23[9] := er23[9] + (er9[Bar] - er9[Bar-er29]) / er29;
      er23[10] := er23[10] + (er10[Bar] - er10[Bar-er29]) / er29;
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
    Result[Bar] := er19;
  end;
end;


function JCFB96(SrcA: TSeries; Smooth: Integer): TSeries;
var
  Bar: integer;
  Value: Double;
  er1, er2, er3, er4, er5, er6, er7, er8, er9, er10, er11, er12: TSeries;
  er20, er21, er29: integer;
  er15, er16, er17, er18, er19: Double;
  er22, er23: array[1..12] of Double;
begin
  SetLength (Result, High(SrcA) + 1);
  er20 := 0; er21 := 0; er29 := 0;
  er15 := 0; er16 := 0; er17 := 0; er18 := 0; er19 := 0;

  FillChar (er22, sizeof(er22), 0);
  FillChar (er23, sizeof(er23), 0);

  er15 := 1;
  er16 := 1;
  er19 := 20;
  er29 := Smooth;

  er1 := JCFBaux(SrcA, 2);
  er2 := JCFBaux(SrcA, 3);
  er3 := JCFBaux(SrcA, 4);
  er4 := JCFBaux(SrcA, 6);
  er5 := JCFBaux(SrcA, 8);
  er6 := JCFBaux(SrcA, 12);
  er7 := JCFBaux(SrcA, 16);
  er8 := JCFBaux(SrcA, 24);
  er9 := JCFBaux(SrcA, 32);
  er10 := JCFBaux(SrcA, 48);
  er11 := JCFBaux(SrcA, 64);
  er12 := JCFBaux(SrcA, 96);

  for Bar := 1 to High (SrcA) do begin
    if Bar <= er29 then begin
      for er21 := 1 to 12 do
        er23[er21] := 0;
      for er20 := 0 to Bar-1 do begin
        er23[1] := er23[1] + er1[Bar-er20];
        er23[2] := er23[2] + er2[Bar-er20];
        er23[3] := er23[3] + er3[Bar-er20];
        er23[4] := er23[4] + er4[Bar-er20];
        er23[5] := er23[5] + er5[Bar-er20];
        er23[6] := er23[6] + er6[Bar-er20];
        er23[7] := er23[7] + er7[Bar-er20];
        er23[8] := er23[8] + er8[Bar-er20];
        er23[9] := er23[9] + er9[Bar-er20];
        er23[10] := er23[10] + er10[Bar-er20];
        er23[11] := er23[11] + er11[Bar-er20];
        er23[12] := er23[12] + er12[Bar-er20];
      end;
      for er21 := 1 to 12 do
        er23[er21] := er23[er21] / Bar;
    end else begin
      er23[1] := er23[1] + (er1[Bar] - er1[Bar-er29]) / er29;
      er23[2] := er23[2] + (er2[Bar] - er2[Bar-er29]) / er29;
      er23[3] := er23[3] + (er3[Bar] - er3[Bar-er29]) / er29;
      er23[4] := er23[4] + (er4[Bar] - er4[Bar-er29]) / er29;
      er23[5] := er23[5] + (er5[Bar] - er5[Bar-er29]) / er29;
      er23[6] := er23[6] + (er6[Bar] - er6[Bar-er29]) / er29;
      er23[7] := er23[7] + (er7[Bar] - er7[Bar-er29]) / er29;
      er23[8] := er23[8] + (er8[Bar] - er8[Bar-er29]) / er29;
      er23[9] := er23[9] + (er9[Bar] - er9[Bar-er29]) / er29;
      er23[10] := er23[10] + (er10[Bar] - er10[Bar-er29]) / er29;
      er23[11] := er23[11] + (er11[Bar] - er11[Bar-er29]) / er29;
      er23[12] := er23[12] + (er12[Bar] - er12[Bar-er29]) / er29;
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
    Result[Bar] := er19;
  end;
end;

function JCFB192(SrcA: TSeries; Smooth: Integer): TSeries;
var
  Bar: integer;
  Value: Double;
  er1, er2, er3, er4, er5, er6, er7, er8, er9, er10, er11, er12, er13, er14: TSeries;
  er20, er21, er29: integer;
  er15, er16, er17, er18, er19: Double;
  er22, er23: array[1..14] of Double;
begin
  SetLength (Result, High(SrcA) + 1);
  er20 := 0; er21 := 0; er29 := 0;
  er15 := 0; er16 := 0; er17 := 0; er18 := 0; er19 := 0;

  FillChar (er22, sizeof(er22), 0);
  FillChar (er23, sizeof(er23), 0);

  er15 := 1;
  er16 := 1;
  er19 := 20;
  er29 := Smooth;

  er1 := JCFBaux(SrcA, 2);
  er2 := JCFBaux(SrcA, 3);
  er3 := JCFBaux(SrcA, 4);
  er4 := JCFBaux(SrcA, 6);
  er5 := JCFBaux(SrcA, 8);
  er6 := JCFBaux(SrcA, 12);
  er7 := JCFBaux(SrcA, 16);
  er8 := JCFBaux(SrcA, 24);
  er9 := JCFBaux(SrcA, 32);
  er10 := JCFBaux(SrcA, 48);
  er11 := JCFBaux(SrcA, 64);
  er12 := JCFBaux(SrcA, 96);
  er13 := JCFBaux(SrcA, 128);
  er14 := JCFBaux(SrcA, 192);

  for Bar := 1 to High (SrcA) do
  begin
    if Bar <= er29 then begin
      for er21 := 1 to 14 do
        er23[er21] := 0;
      for er20 := 0 to Bar-1 do begin
        er23[1] := er23[1] + er1[Bar-er20];
        er23[2] := er23[2] + er2[Bar-er20];
        er23[3] := er23[3] + er3[Bar-er20];
        er23[4] := er23[4] + er4[Bar-er20];
        er23[5] := er23[5] + er5[Bar-er20];
        er23[6] := er23[6] + er6[Bar-er20];
        er23[7] := er23[7] + er7[Bar-er20];
        er23[8] := er23[8] + er8[Bar-er20];
        er23[9] := er23[9] + er9[Bar-er20];
        er23[10] := er23[10] + er10[Bar-er20];
        er23[11] := er23[11] + er11[Bar-er20];
        er23[12] := er23[12] + er12[Bar-er20];
        er23[13] := er23[13] + er13[Bar-er20];
        er23[14] := er23[14] + er14[Bar-er20];
      end;
      for er21 := 1 to 14 do
        er23[er21] := er23[er21] / Bar;
    end else begin
      er23[1] := er23[1] + (er1[Bar] - er1[Bar-er29]) / er29;
      er23[2] := er23[2] + (er2[Bar] - er2[Bar-er29]) / er29;
      er23[3] := er23[3] + (er3[Bar] - er3[Bar-er29]) / er29;
      er23[4] := er23[4] + (er4[Bar] - er4[Bar-er29]) / er29;
      er23[5] := er23[5] + (er5[Bar] - er5[Bar-er29]) / er29;
      er23[6] := er23[6] + (er6[Bar] - er6[Bar-er29]) / er29;
      er23[7] := er23[7] + (er7[Bar] - er7[Bar-er29]) / er29;
      er23[8] := er23[8] + (er8[Bar] - er8[Bar-er29]) / er29;
      er23[9] := er23[9] + (er9[Bar] - er9[Bar-er29]) / er29;
      er23[10] := er23[10] + (er10[Bar] - er10[Bar-er29]) / er29;
      er23[11] := er23[11] + (er11[Bar] - er11[Bar-er29]) / er29;
      er23[12] := er23[12] + (er12[Bar] - er12[Bar-er29]) / er29;
      er23[13] := er23[13] + (er13[Bar] - er13[Bar-er29]) / er29;
      er23[14] := er23[14] + (er14[Bar] - er14[Bar-er29]) / er29;
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
    Result[Bar] := er19;
  end;
end;

function JCFBSeries(const SrcA: TSeries; AFractalType: Integer; ASmooth: Integer): TSeries;
var
  Bar: integer;
begin
  SetLength (Result, High(SrcA) + 1);
  case AFractalType of
    1: Result := JCFB24(SrcA, ASmooth);
    2: Result := JCFB48(SrcA, ASmooth);
    3: Result := JCFB96(SrcA, ASmooth);
    4: Result := JCFB192(SrcA, ASmooth);
  end;
end;

end.


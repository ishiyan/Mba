unit Calc;
{  Декомпиляция индикаторов от M.Jurik          }
{  Created by Starlight (extesy@yandex.ru)      }

interface
uses
  Math;

type
  TSeries = array of Double;            // Серия данных

function JXRSXSeries (const SrcA, LenA: TSeries): TSeries;

implementation

function JXRSXSeries (const SrcA, LenA: TSeries): TSeries;
// Вычисляет RSX переменной длины, заданной отдельно на каждом баре (в серии LenA)
var
  Bar: integer;
  Value: Double;
  f0, f88, f90: integer;
  f8, f10, f18, f20, f28, f30, f38, f40, f48, f50, f58, f60, f68, f70, f78, f80: Double;
  v4, v8, vC, v10, v14, v18, v1C, v20: Double;
begin
  SetLength (Result, High(SrcA)+1);

  f0 := 0; f88 := 0; f90 := 0;
  f8 := 0; f10 := 0; f18 := 0; f20 := 0; f28 := 0; f30 := 0; f38 := 0; f40 := 0;
  f48 := 0; f50 := 0; f58 := 0; f60 := 0; f68 := 0; f70 := 0; f78 := 0; f80 := 0;
  v4 := 0; v8 := 0; vC := 0; v10 := 0; v14 := 0; v18 := 0; v1C := 0; v20 := 0;

  for Bar := 0 to High (SrcA) do begin
    if (f90 = 0) then begin
      f90 := 1;
      f0 := 0;
      if (Trunc(LenA[Bar])-1 >= 5) then f88 := Trunc(LenA[Bar])-1 else f88 := 5;
      f8 := 100*SrcA[Bar];
      f18 := 3 / (Trunc(LenA[Bar]) + 2);
      f20 := 1 - f18;
    end else begin
      if (f88 <= f90) then f90 := f88 + 1 else f90 := f90 + 1;
      f10 := f8;
      f8 := 100*SrcA[Bar];
      v8 := f8 - f10;
      f28 := f20 * f28 + f18 * v8;
      f30 := f18 * f28 + f20 * f30;
      vC := f28 * 1.5 - f30 * 0.5;
      f38 := f20 * f38 + f18 * vC;
      f40 := f18 * f38 + f20 * f40;
      v10 := f38 * 1.5 - f40 * 0.5;
      f48 := f20 * f48 + f18 * v10;
      f50 := f18 * f48 + f20 * f50;
      v14 := f48 * 1.5 - f50 * 0.5;
      f58 := f20 * f58 + f18 * abs(v8);
      f60 := f18 * f58 + f20 * f60;
      v18 := f58 * 1.5 - f60 * 0.5;
      f68 := f20 * f68 + f18 * v18;
      f70 := f18 * f68 + f20 * f70;
      v1C := f68 * 1.5 - f70 * 0.5;
      f78 := f20 * f78 + f18 * v1C;
      f80 := f18 * f78 + f20 * f80;
      v20 := f78 * 1.5 - f80 * 0.5;
      if ((f88 >= f90) and (f8 <> f10)) then f0 := 1;
      if ((f88 = f90) and (f0 = 0)) then f90 := 0;
    end;
    if ((f88 < f90) and (v20 > 1.0e-10)) then begin
      v4 := (v14 / v20 + 1) * 50;
      if (v4 > 100) then v4 := 100;
      if (v4 < 0) then v4 := 0;
    end else
      v4 := 50;
    Value := v4;
    Result[Bar] := Value;
  end;
end;

end.

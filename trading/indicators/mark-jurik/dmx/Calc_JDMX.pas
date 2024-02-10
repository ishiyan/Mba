unit Calc;
{  Декомпиляция индикаторов от M.Jurik          }
{  Created by Starlight (extesy@yandex.ru)      }

interface
uses
  Math;

type
  TSeries = array of Double;            // Серия данных

function JJMASeries (const SrcA: TSeries; ALength, APhase: Integer): TSeries;

function JDMXminusSeries (const SrcA, HighA, LowA: TSeries; ALen: Integer): TSeries;
function JDMXplusSeries (const SrcA, HighA, LowA: TSeries; ALen: Integer): TSeries;
function JDMXSeries (const SrcA, HighA, LowA: TSeries; ALen: Integer): TSeries;

implementation

function JJMASeries(const SrcA: TSeries; ALength, APhase: Integer): TSeries;
begin
end;

function TrueRangeSeries (const CloseA, HighA, LowA: TSeries): TSeries;
var
  Bar: Integer;
  m1, m2, m3: Double;
begin
  SetLength (Result, High(CloseA)+1);
  // TR = max(abs(High - Low), abs(High - Closei-1), abs(Low - Closei-1)).
  for Bar := 2 to High (CloseA) do begin
    m1 := abs(HighA[Bar] - LowA[Bar]);
    m2 := abs(HighA[Bar] - CloseA [Bar-1]);
    m3 := abs(LowA[Bar] - CloseA [Bar-1]);
    Result[Bar] := Max (Max (m1, m2), m3);
  end;
end;

function JDMXplusSeries(const SrcA, HighA, LowA: TSeries; ALen: Integer): TSeries;
var
  upward, numer, denom: TSeries;
  Bar: integer;
  v1, v2, Value: Double;
begin
  SetLength (Result, High(SrcA)+1);
  SetLength (upward, High(SrcA)+1);
  SetLength (numer, High(SrcA)+1);
  SetLength (denom, High(SrcA)+1);

  for Bar := 1 to High (SrcA) do begin
    v1 := 100 * (HighA[Bar] - HighA[Bar-1]);
    v2 := 100 * (LowA[Bar-1] - LowA[Bar]);
    if ((v1 > v2) and (v1 > 0)) then upward[Bar] := v1 else upward[Bar] := 0;
  end;

  numer := JJMASeries(upward, ALen, -100);
  denom := JJMASeries(TrueRangeSeries(SrcA, HighA, LowA), ALen, -100);

  for Bar := 0 to High (SrcA) do begin
    if (denom[Bar] > 0.00001) and (Bar > 40)
      then Value := 100 * numer[Bar] / denom[Bar]
      else Value := 0;
    Result[Bar] := Value;
  end;
end;

function JDMXminusSeries(const SrcA, HighA, LowA: TSeries; ALen: Integer): TSeries;
var
  downward, numer, denom: TSeries;
  Bar: integer;
  v1, v2, Value: Double;
begin
  SetLength (Result, High(SrcA)+1);
  SetLength (downward, High(SrcA)+1);
  SetLength (numer, High(SrcA)+1);
  SetLength (denom, High(SrcA)+1);

  for Bar := 1 to High (SrcA) do begin
    v1 := 100 * (HighA[Bar] - HighA[Bar-1]);
    v2 := 100 * (LowA[Bar-1] - LowA[Bar]);
    if ((v2 > v1) and (v2 > 0)) then downward[Bar] := v2 else downward[Bar] := 0;
  end;

  numer := JJMASeries(downward, ALen, -100);
  denom := JJMASeries(TrueRangeSeries(SrcA, HighA, LowA), ALen, -100);

  for Bar := 0 to High (SrcA) do begin
    if (denom[Bar] > 0.00001) and (Bar > 40)
      then Value := 100 * numer[Bar] / denom[Bar]
      else Value := 0;
    Result[Bar] := Value;
  end;
end;

function JDMXSeries(const SrcA, HighA, LowA: TSeries; ALen: Integer): TSeries;
var
  DMXplus, DMXminus: TSeries;
  Bar: integer;
  Value: Double;
begin
  SetLength (Result, High(SrcA)+1);

  DMXplus := JDMXplusSeries(SrcA, HighA, LowA, ALen);
  DMXminus := JDMXminusSeries(SrcA, HighA, LowA, ALen);

  for Bar := 0 to High (SrcA) do begin
    if (DMXplus[Bar] + DMXminus[Bar] > 0.00001)
      then Value := 100 * (DMXplus[Bar] - DMXminus[Bar]) / (DMXplus[Bar] + DMXminus[Bar])
      else Value := 0;
    Result[Bar] := Value;
  end;
end;

end.


// Created by Starlight (extesy@yandex.ru). Compiled into dll by _landy
// JJMA
function AJJMASeries(Series: number, Len: number, Phase: number): number {
  let sName: string;
  let lib: any;
  lib = CreateOleObject('Jurik.Indicator');
  sName = 'JJMA(' + GetDescription(Series) + ',' + Len.toString() + ',' + Phase.toString() + ')';
  let Result: number = FindNamedSeries(sName);
  if (Result >= 0) return Result;
  Result = CreateNamedSeries(sName);
  lib.JJMA(Result, Series, Len, Phase, IWealthLabAuto);
  return Result;
}
function AJJMA(Bar: number, Series: number, Len: number, Phase: number): number {
  return GetSeriesValue(Bar, AJJMASeries(Series, Len, Phase));
}

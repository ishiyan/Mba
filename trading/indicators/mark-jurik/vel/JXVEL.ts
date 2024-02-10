// Created by Starlight (extesy@yandex.ru). Don't remove this line even if you do conversion to EL,MQL etc!
function JXVELaux1(Series: number[], DepthSeries: number[]): number[] {
  const Bar: number;
  const sName: string;
  const jrc05: number, jrc06: number, jrc07: number, jrc08: number, jrc09: number;
  const jrc02: number, jrc04: number, jrc10: number;
  sName = 'JXVELaux1(' + GetDescription(Series) + ',' + GetDescription(DepthSeries) + ')';
  Result = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  for (Bar = 0; Bar < BarCount() - 1; Bar++) {
    jrc02 = Math.ceil(DepthSeries[Bar]);
    jrc04 = jrc02 + 1;
    if (Bar < jrc04) {
      continue;
    }
    jrc05 = jrc04 * (jrc04 + 1) / 2;
    jrc06 = jrc05 * (2 * jrc04 + 1) / 3;
    jrc07 = jrc05 * jrc05 * jrc05 - jrc06 * jrc06;
    jrc08 = 0;
    jrc09 = 0;
    for (jrc10 = 0; jrc10 <= jrc02; jrc10++) {
      jrc08 += Series[Bar - jrc10] * (jrc04 - jrc10);
      jrc09 += Series[Bar - jrc10] * (jrc04 - jrc10) * (jrc04 - jrc10);
    }
    Result[Bar] = (jrc09 * jrc05 - jrc08 * jrc06) / jrc07;
  }
  return Result;
}
function JXVELaux3(Series: number[], Period: number): number[] {
  const Bar: number;
  const sName: string;
  sName = 'JXVELaux3(' + GetDescription(Series) + ',' + Period.toString() + ')';
  Result = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  let input1: number, jrc02: number, jrc03: number, jrc04: number, jrc05: number, jrc07: number, jrc08: number, jrc09: number, jrc10: number, jrc12: number, jrc13: number, jrc14: number, jrc16: number, jrc17: number, jrc18: number, jrc19: number, jrc20: number, jrc21: number, jrc22: number, jrc23: number, jrc24: number, jrc25: number;
  let jrc01: number, jrc06: number, jrc11: number, jrc15: number, jrc26: number, jrc27: number, jrc28: number, jrc29: number;
  let jrc30: number[] = new Array(1001);
  jrc01 = 30;
  jrc02 = 0.0001;
  jrc28 = 1;
  jrc29 = 1;
  for (Bar = 0; Bar < BarCount() - 1; Bar++) {
    input1 = Series[Bar];
    jrc27 = Bar;
    if (Bar === 0) {
      jrc26 = jrc27;
    }
    if (Bar > 0) {
      if (jrc24 <= 0) {
        jrc24 = 1001;
      }
      jrc24 = jrc24 - 1;
      jrc30[jrc24] = input1;
    }
    if (jrc27 < jrc26 + jrc01) {
      jrc20 = input1;
    } else {
      jrc03 = Math.min(500, Math.max(jrc02, Period));
      jrc07 = Math.min(jrc01, Math.ceil(jrc03));
      jrc04 = 0.86 - 0.55 / Math.sqrt(jrc03);
      jrc05 = 1 - Math.exp(-Math.log(4) / jrc03 / 2);
      jrc06 = Math.floor(Math.max(jrc01 + 1, Math.ceil(2 * jrc03)));
      jrc11 = Math.floor(Math.min(jrc27 - jrc26 + 1, jrc06));
      jrc12 = jrc11 * (jrc11 + 1) * (jrc11 - 1) / 12;
      jrc13 = (jrc11 + 1) / 2;
      jrc14 = (jrc11 - 1) / 2;
      jrc09 = 0;
      jrc10 = 0;
      for (jrc15 = jrc11 - 1; jrc15 >= 0; jrc15--) {
        jrc23 = (jrc24 + jrc15) % 1001;
        jrc09 += jrc30[jrc23];
        jrc10 += jrc30[jrc23] * (jrc14 - jrc15);
      }
      jrc16 = jrc10 / jrc12;
      jrc17 = jrc09 / jrc11 - jrc16 * jrc13;
      jrc18 = 0;
      for (jrc15 = jrc11 - 1; jrc15 >= 0; jrc15--) {
        jrc17 += jrc16;
        jrc23 = (jrc24 + jrc15) % 1001;
        jrc18 += Math.abs(jrc30[jrc23] - jrc17);
      }
      jrc25 = 1.2 * jrc18 / jrc11;
      if (jrc11 < jrc06) {
        jrc25 *= Math.pow(jrc06 / jrc11, 0.25);
      }
      if (jrc28 === 1) {
        jrc28 = 0;
        jrc19 = jrc25;
      } else {
        jrc19 += (jrc25 - jrc19) * jrc05;
      }
      jrc19 = Math.max(jrc02, jrc19);
      if (jrc29 === 1) {
        jrc29 = 0;
        jrc08 = (jrc30[jrc24] - jrc30[(jrc24 + jrc07) % 1001]) / jrc07;
      }
      jrc21 = input1 - (jrc20 + jrc08 * jrc04);
      jrc22 = 1 - Math.exp(-Math.abs(jrc21) / jrc19 / jrc03);
      jrc08 = jrc22 * jrc21 + jrc08 * jrc04;
      jrc20 += jrc08;
    }
    Result[Bar] = jrc20;
  }
  return Result;
}
function JXVELSeries(Series: number[], DepthSeries: number[], Period: number): number[] {
  const Bar: number;
  const sName: string;
  let Value: number;
  sName = 'JXVEL(' + GetDescription(Series) + ',' + GetDescription(DepthSeries) + ',' + Period.toString() + ')';
  Result = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  for (Bar = 0; Bar < BarCount() - 1; Bar++) {
    Result[Bar] = GetSeriesValue(Bar, JXVELaux3(JXVELaux1(Series, DepthSeries), Period));
  }
  return Result;
}
function JXVEL(Bar: number, Series: number[], DepthSeries: number[], Period: number): number {
  return GetSeriesValue(Bar, JXVELSeries(Series, DepthSeries, Period));
}



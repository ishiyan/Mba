import { ceil, min, max, exp, ln, sqrt, power } from 'Math';

type TSeries = Array<number>;

function JXVELaux1(SrcA: TSeries, DepthSeries: TSeries): TSeries {
  let Result: TSeries = [];
  let jrc05 = 0, jrc06 = 0, jrc07 = 0, jrc08 = 0, jrc09 = 0;
  let jrc02 = 0, jrc04 = 0, jrc10 = 0;
  for (let Bar = 0; Bar <= SrcA.length - 1; Bar++) {
    jrc02 = ceil(DepthSeries[Bar]);
    jrc04 = jrc02 + 1;
    if (Bar < jrc04) continue;
    jrc05 = jrc04 * (jrc04 + 1) / 2;
    jrc06 = jrc05 * (2 * jrc04 + 1) / 3;
    jrc07 = jrc05 * jrc05 * jrc05 - jrc06 * jrc06;
    jrc08 = 0;
    jrc09 = 0;
    for (jrc10 = 0; jrc10 <= jrc02; jrc10++) {
      jrc08 = jrc08 + SrcA[Bar - jrc10] * (jrc04 - jrc10);
      jrc09 = jrc09 + SrcA[Bar - jrc10] * (jrc04 - jrc10) * (jrc04 - jrc10);
    }
    Result[Bar] = (jrc09 * jrc05 - jrc08 * jrc06) / jrc07;
  }
  return Result;
}

function JXVELaux3(SrcA: TSeries, Period: number): TSeries {
  let Result: TSeries = [];
  let input1 = 0, jrc02 = 0, jrc03 = 0, jrc04 = 0, jrc05 = 0, jrc08 = 0, jrc09 = 0, jrc10 = 0, jrc12 = 0, jrc13 = 0;
  let jrc14 = 0, jrc16 = 0, jrc17 = 0, jrc18 = 0, jrc19 = 0, jrc20 = 0, jrc21 = 0, jrc22 = 0, jrc25 = 0;
  let jrc01 = 0, jrc06 = 0, jrc07 = 0, jrc11 = 0, jrc15 = 0, jrc23 = 0, jrc24 = 0, jrc26 = 0, jrc27 = 0, jrc28 = 0, jrc29 = 0;
  let jrc30: Array<number> = [];
  Result = [];
  input1 = 0; jrc02 = 0; jrc03 = 0; jrc04 = 0; jrc05 = 0; jrc07 = 0; jrc08 = 0;
  jrc09 = 0; jrc10 = 0; jrc12 = 0; jrc13 = 0; jrc14 = 0; jrc16 = 0; jrc17 = 0;
  jrc18 = 0; jrc19 = 0; jrc20 = 0; jrc21 = 0; jrc22 = 0; jrc23 = 0; jrc24 = 0;
  jrc25 = 0; jrc01 = 0; jrc06 = 0; jrc11 = 0; jrc15 = 0; jrc26 = 0; jrc27 = 0;
  jrc28 = 0; jrc29 = 0;
  jrc30 = new Array(1001).fill(0);
  jrc01 = 30;
  jrc02 = 0.0001;
  jrc28 = 1;
  jrc29 = 1;
  for (let Bar = 0; Bar <= SrcA.length - 1; Bar++) {
    input1 = SrcA[Bar];
    jrc27 = Bar;
    if (Bar === 0) jrc26 = jrc27;
    if (Bar > 0) {
      if (jrc24 <= 0) jrc24 = 1001;
      jrc24 = jrc24 - 1;
      jrc30[jrc24] = input1;
    }
    if (jrc27 < jrc26 + jrc01) jrc20 = input1;
    else {
      jrc03 = min(500, max(jrc02, Period));
      jrc07 = min(jrc01, ceil(jrc03));
      jrc04 = 0.86 - 0.55 / sqrt(jrc03);
      jrc05 = 1 - exp(-ln(4) / jrc03 / 2);
      jrc06 = Math.trunc(max(jrc01 + 1, ceil(2 * jrc03)));
      jrc11 = Math.trunc(min(jrc27 - jrc26 + 1, jrc06));
      jrc12 = jrc11 * (jrc11 + 1) * (jrc11 - 1) / 12;
      jrc13 = (jrc11 + 1) / 2;
      jrc14 = (jrc11 - 1) / 2;
      jrc09 = 0;
      jrc10 = 0;
      for (jrc15 = jrc11 - 1; jrc15 >= 0; jrc15--) {
        jrc23 = (jrc24 + jrc15) % 1001;
        jrc09 = jrc09 + jrc30[jrc23];
        jrc10 = jrc10 + jrc30[jrc23] * (jrc14 - jrc15);
      }
      jrc16 = jrc10 / jrc12;
      jrc17 = jrc09 / jrc11 - jrc16 * jrc13;
      jrc18 = 0;
      for (jrc15 = jrc11 - 1; jrc15 >= 0; jrc15--) {
        jrc17 = jrc17 + jrc16;
        jrc23 = (jrc24 + jrc15) % 1001;
        jrc18 = jrc18 + Math.abs(jrc30[jrc23] - jrc17);
      }
      jrc25 = 1.2 * jrc18 / jrc11;
      if (jrc11 < jrc06) jrc25 = jrc25 * Math.pow(jrc06 / jrc11, 0.25);
      if (jrc28 === 1) {
        jrc28 = 0;
        jrc19 = jrc25;
      } else jrc19 = jrc19 + (jrc25 - jrc19) * jrc05;
      jrc19 = max(jrc02, jrc19);
      if (jrc29 === 1) {
        jrc29 = 0;
        jrc08 = (jrc30[jrc24] - jrc30[(jrc24 + jrc07) % 1001]) / jrc07;
      }
      jrc21 = input1 - (jrc20 + jrc08 * jrc04);
      jrc22 = 1 - exp(-Math.abs(jrc21) / jrc19 / jrc03);
      jrc08 = jrc22 * jrc21 + jrc08 * jrc04;
      jrc20 = jrc20 + jrc08;
    }
    Result[Bar] = jrc20;
  }
  return Result;
}

function JXVELSeries(SrcA: TSeries, DepthSrcA: TSeries, APeriod: number): TSeries {
  return JXVELaux3(JXVELaux1(SrcA, DepthSrcA), APeriod);
}

function JVELaux1(SrcA: TSeries, Depth: number): TSeries {
  let Result: TSeries = [];
  let jrc04 = 0, jrc05 = 0, jrc06 = 0, jrc07 = 0, jrc08 = 0, jrc09 = 0;
  let jrc01: TSeries = [];
  let jrc02 = 0, jrc10 = 0;
  Result = [];
  jrc04 = 0; jrc05 = 0; jrc06 = 0; jrc07 = 0; jrc08 = 0; jrc09 = 0;
  jrc01 = SrcA;
  jrc02 = Depth;
  jrc04 = jrc02 + 1;
  jrc05 = jrc04 * (jrc04 + 1) / 2;
  jrc06 = jrc05 * (2 * jrc04 + 1) / 3;
  jrc07 = jrc05 * jrc05 * jrc05 - jrc06 * jrc06;
  for (let Bar = jrc02; Bar <= SrcA.length - 1; Bar++) {
    jrc08 = 0;
    jrc09 = 0;
    for (jrc10 = 0; jrc10 <= jrc02; jrc10++) {
      jrc08 = jrc08 + jrc01[Bar - jrc10] * (jrc04 - jrc10);
      jrc09 = jrc09 + jrc01[Bar - jrc10] * (jrc04 - jrc10) * (jrc04 - jrc10);
    }
    Result[Bar] = (jrc09 * jrc05 - jrc08 * jrc06) / jrc07;
  }
  return Result;
}

function JVELaux3(SrcA: TSeries): TSeries {
  let Result: TSeries = [];
  let JR02 = 0, JR04 = 0, JR05 = 0, JR08 = 0, JR09 = 0, JR10 = 0, JR12 = 0, JR13 = 0, JR14 = 0, JR16 = 0, JR17 = 0, JR19 = 0, JR20 = 0, JR22 = 0, JR23 = 0, JR28 = 0;
  let JR01 = 0, JR03 = 0, JR06 = 0, JR07 = 0, JR11 = 0, JR15 = 0, JR18 = 0, JR24 = 0, JR25 = 0, JR26 = 0, JR27 = 0, JR29 = 0;
  let JR21 = 0, JR21a = 0, JR21b = 0;
  let JR40: Array<number> = [];
  let JR41: Array<number> = [];
  Result = [];
  JR02 = 0; JR04 = 0; JR05 = 0; JR08 = 0; JR09 = 0; JR10 = 0; JR12 = 0; JR13 = 0;
  JR14 = 0; JR16 = 0; JR17 = 0; JR19 = 0; JR20 = 0; JR22 = 0; JR23 = 0; JR28 = 0;
  JR01 = 0; JR03 = 0; JR06 = 0; JR07 = 0; JR11 = 0; JR15 = 0; JR18 = 0;
  JR24 = 0; JR25 = 0; JR26 = 0; JR27 = 0; JR29 = 0;
  JR21 = 0; JR21a = 0; JR21b = 0;
  JR40 = new Array(100);
  JR41 = new Array(100);
  JR01 = 30;
  JR02 = 0.0001;
  for (let Bar = JR01; Bar <= SrcA.length - 1; Bar++) {
    JR27 = Bar;
    if (Bar === JR01) {
      JR28 = 0;
      for (JR29 = 1; JR29 <= JR01 - 1; JR29++)
        if (SrcA[Bar - JR29] === SrcA[Bar - JR29 - 1]) JR28 = JR28 + 1;
      if (JR28 < (JR01 - 1)) JR26 = JR27 - JR01;
      else JR26 = JR27;
      JR18 = 0;
      JR25 = 0;
      JR21 = SrcA[Bar - 1];
      JR03 = 3;
      JR04 = 0.86 - 0.55 / sqrt(JR03);
      JR05 = 1 - exp(-ln(4) / JR03);
      JR06 = JR01 + 1;
      JR07 = 3;
      JR08 = (SrcA[Bar] - SrcA[Bar - JR07]) / JR07;
      JR11 = Math.trunc(min(1 + JR27 - JR26, JR06));
      for (JR15 = JR11 - 1; JR15 >= 1; JR15--) {
        if (JR25 <= 0) JR25 = 100;
        JR25 = JR25 - 1;
        JR41[JR25] = SrcA[Bar - JR15];
      }
    }
    if (JR25 <= 0) JR25 = 100;
    JR25 = JR25 - 1;
    JR41[JR25] = SrcA[Bar];
    if (JR11 <= JR01) {
      if (Bar === JR01) JR21 = SrcA[Bar];
      else JR21 = sqrt(JR05) * SrcA[Bar] + (1 - sqrt(JR05)) * JR21a;
      if (Bar > JR01 + 1) JR08 = (JR21 - JR21b) / 2;
      else JR08 = 0;
      JR11 = JR11 + 1;
    } else {
      if (JR11 <= JR06) {
        JR12 = JR11 * (JR11 + 1) * (JR11 - 1) / 12;
        JR13 = (JR11 + 1) / 2;
        JR14 = (JR11 - 1) / 2;
        JR09 = 0;
        JR10 = 0;
        for (JR15 = JR11 - 1; JR15 >= 0; JR15--) {
          JR24 = (JR25 + JR15) % 100;
          JR09 = JR09 + JR41[JR24];
          JR10 = JR10 + JR41[JR24] * (JR14 - JR15);
        }
        JR16 = JR10 / JR12;
        JR17 = JR09 / JR11 - JR16 * JR13;
        JR19 = 0;
        for (JR15 = JR11 - 1; JR15 >= 0; JR15--) {
          JR17 = JR17 + JR16;
          JR24 = (JR25 + JR15) % 100;
          JR19 = JR19 + Math.abs(JR41[JR24] - JR17);
        }
        JR20 = 1.2 * JR19 / JR11;
        if (JR11 < JR06) JR20 = JR20 * Math.pow(JR06 / JR11, 0.25);
        if (JR28 === 1) {
          JR28 = 0;
          JR19 = JR20;
        } else JR19 = JR19 + (JR20 - JR19) * JR05;
        JR19 = max(JR02, JR19);
        if (JR29 === 1) {
          JR29 = 0;
          JR08 = (JR41[JR24] - JR41[(JR24 + JR07) % 100]) / JR07;
        }
        JR21 = SrcA[Bar] - (JR20 + JR08 * JR04);
        JR22 = 1 - exp(-Math.abs(JR21) / JR19 / JR03);
        JR08 = JR22 * JR21 + JR08 * JR04;
        JR20 = JR20 + JR08;
      } else {
        if ((Bar % 1000) === 0) {
          JR09 = 0;
          JR10 = 0;
          for (JR15 = JR06 - 1; JR15 >= 0; JR15--) {
            JR24 = (JR25 + JR15) % 100;
            JR09 = JR09 + JR41[JR24];
            JR10 = JR10 + JR41[JR24] * (JR14 - JR15);
          }
        } else {
          JR24 = (JR25 + JR06) % 100;
          JR10 = JR10 - JR09 + JR41[JR24] * JR13 + SrcA[Bar] * JR14;
          JR09 = JR09 - JR41[JR24] + SrcA[Bar];
        }
        if (JR18 <= 0) JR18 = JR06;
        JR18 = JR18 - 1;
        JR19 = JR19 - JR40[JR18];
        JR16 = JR10 / JR12;
        JR17 = (JR09 / JR06) + (JR16 * JR14);
        JR40[JR18] = Math.abs(SrcA[Bar] - JR17);
        JR19 = max(JR02, (JR19 + JR40[JR18]));
        JR20 = JR20 + ((JR19 / JR06) - JR20) * JR05;
      }
      JR20 = max(JR02, JR20);
      JR22 = SrcA[Bar] - (JR21 + JR08 * JR04);
      JR23 = 1 - exp(-Math.abs(JR22) / JR20 / JR03);
      JR08 = JR23 * JR22 + JR08 * JR04;
      JR21 = JR21 + JR08;
    }
    JR21b = JR21a; JR21a = JR21;
    Result[Bar] = JR21;
  }
  return Result;
}

function JVELSeries(SrcA: TSeries, ADepth: number): TSeries {
  let Result: TSeries = [];
  Result = JVELaux3(JVELaux1(SrcA, ADepth));
  return Result;
}

function JAVELSeries(SrcA: TSeries, ALoLen: number, AHiLen: number, ASensitivity: number, APeriod: number): TSeries {
  let Result: TSeries = [];
  let j, k: number;
  let avg1, avg2, value2, value3: number;
  let eps: number;
  let value1: TSeries = [];
  let value4: TSeries = [];
  Result = [];
  value1 = [];
  value4 = [];
  eps = 0.001;
  for (let Bar = 1; Bar <= SrcA.length - 1; Bar++)
    value1[Bar] = Math.abs(SrcA[Bar] - SrcA[Bar - 1]);
  for (let Bar = 0; Bar <= SrcA.length - 1; Bar++) {
    avg1 = 0;
    if (Bar < 99) k = Bar;
    else k = 99;
    for (j = 0; j <= k; j++)
      avg1 = avg1 + value1[Bar - j];
    avg1 = avg1 / (k + 1);
    avg2 = 0;
    if (Bar < 9) k = Bar;
    else k = 9;
    for (j = 0; j <= k; j++)
      avg2 = avg2 + value1[Bar - j];
    avg2 = avg2 / (k + 1);
    value2 = ASensitivity * Math.log((eps + avg1) / (eps + avg2));
    value3 = value2 / (1 + Math.abs(value2));
    value4[Bar] = ALoLen + (AHiLen - ALoLen) * (1 + value3) / 2;
  }
  Result = JXVELaux3(JXVELaux1(SrcA, value4), APeriod);
  return Result;
}



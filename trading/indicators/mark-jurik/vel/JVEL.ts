// Created by Starlight (extesy@yandex.ru). Don't remove this line even if you do conversion to EL,MQL etc!
function JVELaux1(Series: number, Depth: number): number {
  let Bar: number;
  let sName: string;
  let jrc04, jrc05, jrc06, jrc07, jrc08, jrc09: number;
  let jrc01, jrc02, jrc10: number;
  sName = 'JVELaux1(' + GetDescription(Series) + ',' + Depth.toString() + ')';
  Result = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  jrc01 = Series;
  jrc02 = Depth;
  jrc04 = jrc02 + 1;
  jrc05 = jrc04 * (jrc04+1) / 2;
  jrc06 = jrc05 * (2*jrc04+1) / 3;
  jrc07 = jrc05 * jrc05 * jrc05 - jrc06 * jrc06;
  for (Bar = jrc02; Bar <= BarCount() - 1; Bar++) {
    jrc08 = 0;
    jrc09 = 0;
    for (jrc10 = 0; jrc10 <= jrc02; jrc10++) {
      jrc08 = jrc08 + Series[Bar-jrc10] * (jrc04 - jrc10);
      jrc09 = jrc09 + Series[Bar-jrc10] * (jrc04 - jrc10) * (jrc04 - jrc10);
    }
    Result[Bar] = (jrc09*jrc05 - jrc08*jrc06) / jrc07;
  }
  return Result;
}
function JVELaux3(Series: number): number {
  let Bar: number;
  let sName: string;
  sName = 'JVELaux3(' + GetDescription(Series) + ')';
  Result = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  let JR02, JR04, JR05, JR08, JR09, JR10, JR12, JR13, JR14, JR16, JR17, JR19, JR20, JR22, JR23, JR28: number;
  let JR01, JR03, JR06, JR07, JR11, JR15, JR18, JR24, JR25, JR26, JR27, JR29: number;
  let JR21, JR21a, JR21b: number;
  let JR40, JR41 : number[] = new Array(100);
  JR01 = 30;
  JR02 = 0.0001;
  for (Bar = JR01; Bar <= BarCount() - 1; Bar++) {
    JR27 = Bar;
    if (Bar == JR01) {
      JR28 = 0;
      for (JR29 = 1; JR29 <= JR01-1; JR29++) {
        if (Series[Bar-JR29] == Series[Bar-JR29-1]) {
          JR28 = JR28 + 1;
        }
      }
      if (JR28 < (JR01-1)) {
        JR26 = JR27-JR01;
      } else {
        JR26 = JR27;
      }
      JR18 = 0;
      JR25 = 0;
      JR21 = Series[Bar-1];
      JR03 = 3;
      JR04 = 0.86 - 0.55 / Math.sqrt(JR03);
      JR05 = 1 - Math.exp(-Math.log(4) / JR03);
      JR06 = JR01+1;
      JR07 = 3;
      JR08 = (Series[Bar] - Series[Bar-JR07]) / JR07;
      JR11 = Math.floor(Math.min(1+JR27-JR26, JR06));
      for (JR15 = JR11-1; JR15 >= 1; JR15--) {
        if (JR25 <= 0) {
          JR25 = 100;
        }
        JR25 = JR25-1;
        JR41[JR25] = Series[Bar-JR15];
      }
    }
    if (JR25 <= 0) {
      JR25 = 100;
    }
    JR25 = JR25-1;
    JR41[JR25] = Series[Bar];
    if (JR11 <= JR01) {
      if (Bar == JR01) {
        JR21 = Series[Bar];
      } else {
        JR21 = Math.sqrt(JR05)*Series[Bar] + (1-Math.sqrt(JR05))*JR21a;
      }
      if (Bar > JR01+1) {
        JR08 = (JR21 - JR21b)/2;
      } else {
        JR08 = 0;
      }
      JR11 = JR11 + 1;
    } else {
      if (JR11 <= JR06) {
        JR12 = JR11 * (JR11+1) * (JR11-1) / 12;
        JR13 = (JR11+1)/2;
        JR14 = (JR11-1)/2;
        JR09 = 0;
        JR10 = 0;
        for (JR15 = JR11-1; JR15 >= 0; JR15--) {
          JR24 = (JR25+JR15) % 100;
          JR09 = JR09 + JR41[JR24];
          JR10 = JR10 + JR41[JR24]*(JR14 - JR15);
        }
        JR16 = JR10/JR12;
        JR17 = (JR09/JR11) - (JR16*JR13);
        JR19 = 0;
        for (JR15 = JR11-1; JR15 >= 0; JR15--) {
          JR17 = JR17+JR16;
          JR24 = (JR25+JR15) % 100;
          JR40[JR15] = Math.abs(JR41[JR24]-JR17);
          JR19 = JR19 + JR40[JR15];
        }
        JR20 = (JR19/JR11) * Math.pow(JR06/JR11, 0.25);
        JR11 = JR11+1;
      } else {
        if ((Bar % 1000)==0) {
          JR09 = 0;
          JR10 = 0;
          for (JR15 = JR06-1; JR15 >= 0; JR15--) {
            JR24 = (JR25+JR15) % 100;
            JR09 = JR09 + JR41[JR24];
            JR10 = JR10 + JR41[JR24]*(JR14 - JR15);
          }
        } else {
          JR24 = (JR25+JR06) % 100;
          JR10 = JR10 - JR09 + JR41[JR24]*JR13 + Series[Bar]*JR14;
          JR09 = JR09 - JR41[JR24] + Series[Bar];
        }
        if (JR18 <= 0) {
          JR18 = JR06;
        }
        JR18 = JR18 - 1;
        JR19 = JR19 - JR40[JR18];
        JR16 = JR10/JR12;
        JR17 = (JR09/JR06) + (JR16*JR14);
        JR40[JR18] = Math.abs(Series[Bar]-JR17);
        JR19 = Math.max(JR02, (JR19 + JR40[JR18]));
        JR20 = JR20 + ((JR19/JR06) - JR20) * JR05;
      }
      JR20 = Math.max(JR02, JR20);
      JR22 = Series[Bar] - (JR21 + JR08*JR04);
      JR23 = 1-Math.exp(-Math.abs(JR22)/JR20/JR03);
      JR08 = JR23*JR22 + JR08*JR04;
      JR21 = JR21 + JR08;
    }
    JR21b = JR21a; JR21a = JR21;
    Result[Bar] = JR21;
  }
  return Result;
}
function JVELSeries(Series: number, Depth: number): number {
  let Bar: number;
  let sName: string;
  let Value: number;
  sName = 'JVEL(' + GetDescription( Series ) + ',' + Depth.toString() + ')';
  Result = FindNamedSeries( sName );
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries( sName );
  for (Bar = 0; Bar <= BarCount() - 1; Bar++) {
    Result[Bar] = GetSeriesValue(Bar, JVELaux3(JVELaux1(Series, Depth)));
  }
  return Result;
}
function JVEL(Bar: number, Series: number, Depth: number): number {
  return GetSeriesValue(Bar, JVELSeries(Series, Depth));



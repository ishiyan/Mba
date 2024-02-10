function JCFBaux(Series: number[], Depth: number): number[] {
  const Bar: number[] = [];
  const sName: string = '';
  const Value: number = 0;
  sName = 'JCFBaux(' + GetDescription(Series) + ',' + Depth.toString() + ')';
  Result = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  const jrc04: number = 0;
  const jrc05: number = 0;
  const jrc06: number = 0;
  const jrc08: number = 0;
  const jrc03: number = CreateSeries();
  for (let Bar = 1; Bar <= BarCount() - 1; Bar++) {
    jrc03[Bar] = Math.abs(Series[Bar] - Series[Bar - 1]);
  }
  for (let Bar = Depth; Bar <= BarCount() - 1; Bar++) {
    if (Bar <= Depth * 2) {
      jrc04 = 0;
      jrc05 = 0;
      jrc06 = 0;
      for (let jrc07 = 0; jrc07 <= Depth - 1; jrc07++) {
        jrc04 = jrc04 + Math.abs(Series[Bar - jrc07] - Series[Bar - jrc07 - 1]);
        jrc05 = jrc05 + (Depth - jrc07) * Math.abs(Series[Bar - jrc07] - Series[Bar - jrc07 - 1]);
        jrc06 = jrc06 + Series[Bar - jrc07 - 1];
      }
    } else {
      jrc05 = jrc05 - jrc04 + jrc03[Bar] * Depth;
      jrc04 = jrc04 - jrc03[Bar - Depth] + jrc03[Bar];
      jrc06 = jrc06 - Series[Bar - Depth - 1] + Series[Bar - 1];
    }
    jrc08 = Math.abs(Depth * Series[Bar] - jrc06);
    if (jrc05 === 0) {
      Value = 0;
    } else {
      Value = jrc08 / jrc05;
    }
    Result[Bar] = Value;
  }
  return Result;
}

function JCFB24(Series: number[], Smooth: number): number[] {
  const Bar: number[] = [];
  const sName: string = '';
  const Value: number = 0;
  sName = 'JCFB24(' + GetDescription(Series) + ',' + Smooth.toString() + ')';
  Result = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  const er1: number = 0;
  const er2: number = 0;
  const er3: number = 0;
  const er4: number = 0;
  const er5: number = 0;
  const er6: number = 0;
  const er7: number = 0;
  const er8: number = 0;
  const er20: number = 0;
  const er21: number = 0;
  const er29: number = 0;
  const er15: number = 1;
  const er16: number = 1;
  const er19: number = 20;
  const er22: number[] = [];
  const er23: number[] = [];
  er15 = 1;
  er16 = 1;
  er19 = 20;
  er1 = JCFBaux(Series, 2);
  er2 = JCFBaux(Series, 3);
  er3 = JCFBaux(Series, 4);
  er4 = JCFBaux(Series, 6);
  er5 = JCFBaux(Series, 8);
  er6 = JCFBaux(Series, 12);
  er7 = JCFBaux(Series, 16);
  er8 = JCFBaux(Series, 24);
  for (let Bar = 1; Bar <= BarCount() - 1; Bar++) {
    if (Bar <= er29) {
      for (let er21 = 1; er21 <= 8; er21++) {
        er23[er21] = 0;
      }
      for (let er20 = 0; er20 <= Bar - 1; er20++) {
        er23[1] = er23[1] + er1[Bar - er20];
        er23[2] = er23[2] + er2[Bar - er20];
        er23[3] = er23[3] + er3[Bar - er20];
        er23[4] = er23[4] + er4[Bar - er20];
        er23[5] = er23[5] + er5[Bar - er20];
        er23[6] = er23[6] + er6[Bar - er20];
        er23[7] = er23[7] + er7[Bar - er20];
        er23[8] = er23[8] + er8[Bar - er20];
      }
      for (let er21 = 1; er21 <= 8; er21++) {
        er23[er21] = er23[er21] / Bar;
      }
    } else {
      er23[1] = er23[1] + (er1[Bar] - er1[Bar - er29]) / er29;
      er23[2] = er23[2] + (er2[Bar] - er2[Bar - er29]) / er29;
      er23[3] = er23[3] + (er3[Bar] - er3[Bar - er29]) / er29;
      er23[4] = er23[4] + (er4[Bar] - er4[Bar - er29]) / er29;
      er23[5] = er23[5] + (er5[Bar] - er5[Bar - er29]) / er29;
      er23[6] = er23[6] + (er6[Bar] - er6[Bar - er29]) / er29;
      er23[7] = er23[7] + (er7[Bar] - er7[Bar - er29]) / er29;
      er23[8] = er23[8] + (er8[Bar] - er8[Bar - er29]) / er29;
    }
    if (Bar > 5) {
      er15 = 1;
      er22[8] = er15 * er23[8];
      er15 = er15 * (1 - er22[8]);
      er22[6] = er15 * er23[6];
      er15 = er15 * (1 - er22[6]);
      er22[4] = er15 * er23[4];
      er15 = er15 * (1 - er22[4]);
      er22[2] = er15 * er23[2];
      er16 = 1;
      er22[7] = er16 * er23[7];
      er16 = er16 * (1 - er22[7]);
      er22[5] = er16 * er23[5];
      er16 = er16 * (1 - er22[5]);
      er22[3] = er16 * er23[3];
      er16 = er16 * (1 - er22[3]);
      er22[1] = er16 * er23[1];
      er17 = er22[1] * er22[1] * 2 + er22[3] * er22[3] * 4 +
        er22[5] * er22[5] * 8 + er22[7] * er22[7] * 16 +
        er22[2] * er22[2] * 3 + er22[4] * er22[4] * 6 +
        er22[6] * er22[6] * 12 + er22[8] * er22[8] * 24;
      er18 = er22[1] * er22[1] + er22[3] * er22[3] +
        er22[5] * er22[5] + er22[7] * er22[7] +
        er22[2] * er22[2] + er22[4] * er22[4] +
        er22[6] * er22[6] + er22[8] * er22[8];
      if (er18 === 0) {
        er19 = 0;
      } else {
        er19 = er17 / er18;
      }
    }
    Result[Bar] = er19;
  }
  return Result;
}

function JCFB48(Series: number[], Smooth: number): number[] {
  const Bar: number[] = [];
  const sName: string = '';
  const Value: number = 0;
  sName = 'JCFB48(' + GetDescription(Series) + ',' + Smooth.toString() + ')';
  Result = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  const er1: number = 0;
  const er2: number = 0;
  const er3: number = 0;
  const er4: number = 0;
  const er5: number = 0;
  const er6: number = 0;
  const er7: number = 0;
  const er8: number = 0;
  const er9: number = 0;
  const er10: number = 0;
  const er20: number = 0;
  const er21: number = 0;
  const er29: number = 0;
  const er15: number = 1;
  const er16: number = 1;
  const er19: number = 20;
  const er22: number[] = [];
  const er23: number[] = [];
  er15 = 1;
  er16 = 1;
  er19 = 20;
  er1 = JCFBaux(Series, 2);
  er2 = JCFBaux(Series, 3);
  er3 = JCFBaux(Series, 4);
  er4 = JCFBaux(Series, 6);
  er5 = JCFBaux(Series, 8);
  er6 = JCFBaux(Series, 12);
  er7 = JCFBaux(Series, 16);
  er8 = JCFBaux(Series, 24);
  er9 = JCFBaux(Series, 32);
  er10 = JCFBaux(Series, 48);
  for (let Bar = 1; Bar <= BarCount() - 1; Bar++) {
    if (Bar <= er29) {
      for (let er21 = 1; er21 <= 10; er21++) {
        er23[er21] = 0;
      }
      for (let er20 = 0; er20 <= Bar - 1; er20++) {
        er23[1] = er23[1] + er1[Bar - er20];
        er23[2] = er23[2] + er2[Bar - er20];
        er23[3] = er23[3] + er3[Bar - er20];
        er23[4] = er23[4] + er4[Bar - er20];
        er23[5] = er23[5] + er5[Bar - er20];
        er23[6] = er23[6] + er6[Bar - er20];
        er23[7] = er23[7] + er7[Bar - er20];
        er23[8] = er23[8] + er8[Bar - er20];
        er23[9] = er23[9] + er9[Bar - er20];
        er23[10] = er23[10] + er10[Bar - er20];
      }
      for (let er21 = 1; er21 <= 10; er21++) {
        er23[er21] = er23[er21] / Bar;
      }
    } else {
      er23[1] = er23[1] + (er1[Bar] - er1[Bar - er29]) / er29;
      er23[2] = er23[2] + (er2[Bar] - er2[Bar - er29]) / er29;
      er23[3] = er23[3] + (er3[Bar] - er3[Bar - er29]) / er29;
      er23[4] = er23[4] + (er4[Bar] - er4[Bar - er29]) / er29;
      er23[5] = er23[5] + (er5[Bar] - er5[Bar - er29]) / er29;
      er23[6] = er23[6] + (er6[Bar] - er6[Bar - er29]) / er29;
      er23[7] = er23[7] + (er7[Bar] - er7[Bar - er29]) / er29;
      er23[8] = er23[8] + (er8[Bar] - er8[Bar - er29]) / er29;
      er23[9] = er23[9] + (er9[Bar] - er9[Bar - er29]) / er29;
      er23[10] = er23[10] + (er10[Bar] - er10[Bar - er29]) / er29;
    }
    if (Bar > 5) {
      er15 = 1;
      er22[10] = er15 * er23[10];
      er15 = er15 * (1 - er22[10]);
      er22[8] = er15 * er23[8];
      er15 = er15 * (1 - er22[8]);
      er22[6] = er15 * er23[6];
      er15 = er15 * (1 - er22[6]);
      er22[4] = er15 * er23[4];
      er15 = er15 * (1 - er22[4]);
      er22[2] = er15 * er23[2];
      er16 = 1;
      er22[9] = er16 * er23[9];
      er16 = er16 * (1 - er22[9]);
      er22[7] = er16 * er23[7];
      er16 = er16 * (1 - er22[7]);
      er22[5] = er16 * er23[5];
      er16 = er16 * (1 - er22[5]);
      er22[3] = er16 * er23[3];
      er16 = er16 * (1 - er22[3]);
      er22[1] = er16 * er23[1];
      er17 = er22[1] * er22[1] * 2 + er22[3] * er22[3] * 4 +
        er22[5] * er22[5] * 8 + er22[7] * er22[7] * 16 +
        er22[9] * er22[9] * 32 + er22[2] * er22[2] * 3 +
        er22[4] * er22[4] * 6 + er22[6] * er22[6] * 12 +
        er22[8] * er22[8] * 24 + er22[10] * er22[10] * 48;
      er18 = er22[1] * er22[1] + er22[3] * er22[3] +
        er22[5] * er22[5] + er22[7] * er22[7] +
        er22[9] * er22[9] + er22[2] * er22[2] +
        er22[4] * er22[4] + er22[6] * er22[6] +
        er22[8] * er22[8] + er22[10] * er22[10];
      if (er18 === 0) {
        er19 = 0;
      } else {
        er19 = er17 / er18;
      }
    }
    Result[Bar] = er19;
  }
  return Result;
}

function JCFB96(Series: number[], Smooth: number): number[] {
  const Bar: number[] = [];
  const sName: string = '';
  const Value: number = 0;
  sName = 'JCFB96(' + GetDescription(Series) + ',' + Smooth.toString() + ')';
  Result = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  const er1: number = 0;
  const er2: number = 0;
  const er3: number = 0;
  const er4: number = 0;
  const er5: number = 0;
  const er6: number = 0;
  const er7: number = 0;
  const er8: number = 0;
  const er9: number = 0;
  const er10: number = 0;
  const er11: number = 0;
  const er12: number = 0;
  const er20: number = 0;
  const er21: number = 0;
  const er29: number = 0;
  const er15: number = 1;
  const er16: number = 1;
  const er19: number = 20;
  const er22: number[] = [];
  const er23: number[] = [];
  er15 = 1;
  er16 = 1;
  er19 = 20;
  er1 = JCFBaux(Series, 2);
  er2 = JCFBaux(Series, 3);
  er3 = JCFBaux(Series, 4);
  er4 = JCFBaux(Series, 6);
  er5 = JCFBaux(Series, 8);
  er6 = JCFBaux(Series, 12);
  er7 = JCFBaux(Series, 16);
  er8 = JCFBaux(Series, 24);
  er9 = JCFBaux(Series, 32);
  er10 = JCFBaux(Series, 48);
  er11 = JCFBaux(Series, 64);
  er12 = JCFBaux(Series, 96);
  for (let Bar = 1; Bar <= BarCount() - 1; Bar++) {
    if (Bar <= er29) {
      for (let er21 = 1; er21 <= 12; er21++) {
        er23[er21] = 0;
      }
      for (let er20 = 0; er20 <= Bar - 1; er20++) {
        er23[1] = er23[1] + er1[Bar - er20];
        er23[2] = er23[2] + er2[Bar - er20];
        er23[3] = er23[3] + er3[Bar - er20];
        er23[4] = er23[4] + er4[Bar - er20];
        er23[5] = er23[5] + er5[Bar - er20];
        er23[6] = er23[6] + er6[Bar - er20];
        er23[7] = er23[7] + er7[Bar - er20];
        er23[8] = er23[8] + er8[Bar - er20];
        er23[9] = er23[9] + er9[Bar - er20];
        er23[10] = er23[10] + er10[Bar - er20];
        er23[11] = er23[11] + er11[Bar - er20];
        er23[12] = er23[12] + er12[Bar - er20];
      }
      for (let er21 = 1; er21 <= 12; er21++) {
        er23[er21] = er23[er21] / Bar;
      }
    } else {
      er23[1] = er23[1] + (er1[Bar] - er1[Bar - er29]) / er29;
      er23[2] = er23[2] + (er2[Bar] - er2[Bar - er29]) / er29;
      er23[3] = er23[3] + (er3[Bar] - er3[Bar - er29]) / er29;
      er23[4] = er23[4] + (er4[Bar] - er4[Bar - er29]) / er29;
      er23[5] = er23[5] + (er5[Bar] - er5[Bar - er29]) / er29;
      er23[6] = er23[6] + (er6[Bar] - er6[Bar - er29]) / er29;
      er23[7] = er23[7] + (er7[Bar] - er7[Bar - er29]) / er29;
      er23[8] = er23[8] + (er8[Bar] - er8[Bar - er29]) / er29;
      er23[9] = er23[9] + (er9[Bar] - er9[Bar - er29]) / er29;
      er23[10] = er23[10] + (er10[Bar] - er10[Bar - er29]) / er29;
      er23[11] = er23[11] + (er11[Bar] - er11[Bar - er29]) / er29;
      er23[12] = er23[12] + (er12[Bar] - er12[Bar - er29]) / er29;
    }
    if (Bar > 5) {
      er15 = 1;
      er22[12] = er15 * er23[12];
      er15 = er15 * (1 - er22[12]);
      er22[10] = er15 * er23[10];
      er15 = er15 * (1 - er22[10]);
      er22[8] = er15 * er23[8];
      er15 = er15 * (1 - er22[8]);
      er22[6] = er15 * er23[6];
      er15 = er15 * (1 - er22[6]);
      er22[4] = er15 * er23[4];
      er15 = er15 * (1 - er22[4]);
      er22[2] = er15 * er23[2];
      er16 = 1;
      er22[11] = er16 * er23[11];
      er16 = er16 * (1 - er22[11]);
      er22[9] = er16 * er23[9];
      er16 = er16 * (1 - er22[9]);
      er22[7] = er16 * er23[7];
      er16 = er16 * (1 - er22[7]);
      er22[5] = er16 * er23[5];
      er16 = er16 * (1 - er22[5]);
      er22[3] = er16 * er23[3];
      er16 = er16 * (1 - er22[3]);
      er22[1] = er16 * er23[1];
      er17 = er22[1] * er22[1] * 2 + er22[3] * er22[3] * 4 +
        er22[5] * er22[5] * 8 + er22[7] * er22[7] * 16 +
        er22[9] * er22[9] * 32 + er22[11] * er22[11] * 64 +
        er22[2] * er22[2] * 3 + er22[4] * er22[4] * 6 +
        er22[6] * er22[6] * 12 + er22[8] * er22[8] * 24 +
        er22[10] * er22[10] * 48 + er22[12] * er22[12] * 96;
      er18 = er22[1] * er22[1] + er22[3] * er22[3] +
        er22[5] * er22[5] + er22[7] * er22[7] +
        er22[9] * er22[9] + er22[11] * er22[11] +
        er22[2] * er22[2] + er22[4] * er22[4] +
        er22[6] * er22[6] + er22[8] * er22[8] +
        er22[10] * er22[10] + er22[12] * er22[12];
      if (er18 === 0) {
        er19 = 0;
      } else {
        er19 = er17 / er18;
      }
    }
    Result[Bar] = er19;
  }
  return Result;
}

function JCFB192(Series: number[], Smooth: number): number[] {
  const Bar: number[] = [];
  const sName: string = '';
  const Value: number = 0;
  sName = 'JCFB192(' + GetDescription(Series) + ',' + Smooth.toString() + ')';
  Result = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  const er1: number = 0;
  const er2: number = 0;
  const er3: number = 0;
  const er4: number = 0;
  const er5: number = 0;
  const er6: number = 0;
  const er7: number = 0;
  const er8: number = 0;
  const er9: number = 0;
  const er10: number = 0;
  const er11: number = 0;
  const er12: number = 0;
  const er13: number = 0;
  const er14: number = 0;
  const er20: number = 0;
  const er21: number = 0;
  const er29: number = 0;
  const er15: number = 1;
  const er16: number = 1;
  const er19: number = 20;
  const er22: number[] = [];
  const er23: number[] = [];
  er15 = 1;
  er16 = 1;
  er19 = 20;
  er1 = JCFBaux(Series, 2);
  er2 = JCFBaux(Series, 3);
  er3 = JCFBaux(Series, 4);
  er4 = JCFBaux(Series, 6);
  er5 = JCFBaux(Series, 8);
  er6 = JCFBaux(Series, 12);
  er7 = JCFBaux(Series, 16);
  er8 = JCFBaux(Series, 24);
  er9 = JCFBaux(Series, 32);
  er10 = JCFBaux(Series, 48);
  er11 = JCFBaux(Series, 64);
  er12 = JCFBaux(Series, 96);
  er13 = JCFBaux(Series, 128);
  er14 = JCFBaux(Series, 192);
  for (let Bar = 1; Bar <= BarCount() - 1; Bar++) {
    if (Bar <= er29) {
      for (let er21 = 1; er21 <= 14; er21++) {
        er23[er21] = 0;
      }
      for (let er20 = 0; er20 <= Bar - 1; er20++) {
        er23[1] = er23[1] + er1[Bar - er20];
        er23[2] = er23[2] + er2[Bar - er20];
        er23[3] = er23[3] + er3[Bar - er20];
        er23[4] = er23[4] + er4[Bar - er20];
        er23[5] = er23[5] + er5[Bar - er20];
        er23[6] = er23[6] + er6[Bar - er20];
        er23[7] = er23[7] + er7[Bar - er20];
        er23[8] = er23[8] + er8[Bar - er20];
        er23[9] = er23[9] + er9[Bar - er20];
        er23[10] = er23[10] + er10[Bar - er20];
        er23[11] = er23[11] + er11[Bar - er20];
        er23[12] = er23[12] + er12[Bar - er20];
        er23[13] = er23[13] + er13[Bar - er20];
        er23[14] = er23[14] + er14[Bar - er20];
      }
      for (let er21 = 1; er21 <= 14; er21++) {
        er23[er21] = er23[er21] / Bar;
      }
    } else {
      er23[1] = er23[1] + (er1[Bar] - er1[Bar - er29]) / er29;
      er23[2] = er23[2] + (er2[Bar] - er2[Bar - er29]) / er29;
      er23[3] = er23[3] + (er3[Bar] - er3[Bar - er29]) / er29;
      er23[4] = er23[4] + (er4[Bar] - er4[Bar - er29]) / er29;
      er23[5] = er23[5] + (er5[Bar] - er5[Bar - er29]) / er29;
      er23[6] = er23[6] + (er6[Bar] - er6[Bar - er29]) / er29;
      er23[7] = er23[7] + (er7[Bar] - er7[Bar - er29]) / er29;
      er23[8] = er23[8] + (er8[Bar] - er8[Bar - er29]) / er29;
      er23[9] = er23[9] + (er9[Bar] - er9[Bar - er29]) / er29;
      er23[10] = er23[10] + (er10[Bar] - er10[Bar - er29]) / er29;
      er23[11] = er23[11] + (er11[Bar] - er11[Bar - er29]) / er29;
      er23[12] = er23[12] + (er12[Bar] - er12[Bar - er29]) / er29;
      er23[13] = er23[13] + (er13[Bar] - er13[Bar - er29]) / er29;
      er23[14] = er23[14] + (er14[Bar] - er14[Bar - er29]) / er29;
    }
    if (Bar > 5) {
      er15 = 1;
      er22[14] = er15 * er23[14];
      er15 = er15 * (1 - er22[14]);
      er22[12] = er15 * er23[12];
      er15 = er15 * (1 - er22[12]);
      er22[10] = er15 * er23[10];
      er15 = er15 * (1 - er22[10]);
      er22[8] = er15 * er23[8];
      er15 = er15 * (1 - er22[8]);
      er22[6] = er15 * er23[6];
      er15 = er15 * (1 - er22[6]);
      er22[4] = er15 * er23[4];
      er15 = er15 * (1 - er22[4]);
      er22[2] = er15 * er23[2];
      er16 = 1;
      er22[13] = er16 * er23[13];
      er16 = er16 * (1 - er22[13]);
      er22[11] = er16 * er23[11];
      er16 = er16 * (1 - er22[11]);
      er22[9] = er16 * er23[9];
      er16 = er16 * (1 - er22[9]);
      er22[7] = er16 * er23[7];
      er16 = er16 * (1 - er22[7]);
      er22[5] = er16 * er23[5];
      er16 = er16 * (1 - er22[5]);
      er22[3] = er16 * er23[3];
      er16 = er16 * (1 - er22[3]);
      er22[1] = er16 * er23[1];
      er17 = er22[1] * er22[1] * 2 + er22[3] * er22[3] * 4 +
        er22[5] * er22[5] * 8 + er22[7] * er22[7] * 16 +
        er22[9] * er22[9] * 32 + er22[11] * er22[11] * 64 +
        er22[13] * er22[13] * 128 + er22[2] * er22[2] * 3 +
        er22[4] * er22[4] * 6 + er22[6] * er22[6] * 12 +
        er22[8] * er22[8] * 24 + er22[10] * er22[10] * 48 +
        er22[12] * er22[12] * 96 + er22[14] * er22[14] * 192;
      er18 = er22[1] * er22[1] + er22[3] * er22[3] +
        er22[5] * er22[5] + er22[7] * er22[7] +
        er22[9] * er22[9] + er22[11] * er22[11] +
        er22[13] * er22[13] + er22[2] * er22[2] +
        er22[4] * er22[4] + er22[6] * er22[6] +
        er22[8] * er22[8] + er22[10] * er22[10] +
        er22[12] * er22[12] + er22[14] * er22[14];
      if (er18 === 0) {
        er19 = 0;
      } else {
        er19 = er17 / er18;
      }
    }
    Result[Bar] = er19;
  }
  return Result;
}

function JCFBSeries(Series: number[], FractalType: number, Smooth: number): number[] {
  const Bar: number[] = [];
  const sName: string = '';
  const Value: number = 0;
  sName = 'JCFB(' + GetDescription(Series) + ',' + FractalType.toString() + ',' + Smooth.toString() + ')';
  Result = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  for (let Bar = 0; Bar <= BarCount() - 1; Bar++) {
    if (FractalType === 1) {
      Value = JCFB24(Series, Smooth);
    }
    if (FractalType === 2) {
      Value = JCFB48(Series, Smooth);
    }
    if (FractalType === 3) {
      Value = JCFB96(Series, Smooth);
    }
    if (FractalType === 4) {
      Value = JCFB192(Series, Smooth);
    }
    Result[Bar] = Value[Bar];
  }
  return Result;
}

function JCFB(Bar: number, Series: number[], FractalType: number, Smooth: number): number {
  return GetSeriesValue(Bar, JCFBSeries(Series, FractalType, Smooth));
}



interface Math {
  abs(x: number): number;
}

type TSeries = number[];

function JCFBaux(SrcA: TSeries, Depth: number): TSeries {
  let Result: TSeries = [];
  let Bar: number;
  let Value: number;
  let jrc04: number, jrc05: number, jrc06: number, jrc08: number;
  let jrc07: number;
  let IntA: TSeries = [];
  Result = new Array(SrcA.length);
  jrc04 = 0; jrc05 = 0;
  jrc06 = 0; jrc08 = 0;
  jrc07 = 0;
  IntA = new Array(SrcA.length);
  for (Bar = 1; Bar < SrcA.length; Bar++) {
    IntA[Bar] = Math.abs(SrcA[Bar] - SrcA[Bar-1]);
  }
  for (Bar = Depth; Bar < SrcA.length - 1; Bar++) {
    if (Bar <= Depth*2) {
      jrc04 = 0;
      jrc05 = 0;
      jrc06 = 0;
      for (jrc07 = 0; jrc07 < Depth; jrc07++) {
        jrc04 = jrc04 + Math.abs(SrcA[Bar-jrc07] - SrcA[Bar-jrc07-1]);
        jrc05 = jrc05 + (Depth - jrc07) * Math.abs(SrcA[Bar-jrc07] - SrcA[Bar-jrc07-1]);
        jrc06 = jrc06 + SrcA[Bar-jrc07-1];
      }
    } else {
      jrc05 = jrc05 - jrc04 + IntA[Bar] * Depth;
      jrc04 = jrc04 - IntA[Bar-Depth] + IntA[Bar];
      jrc06 = jrc06 - SrcA[Bar-Depth-1] + SrcA[Bar-1];
    }
    jrc08 = Math.abs(Depth * SrcA[Bar] - jrc06);
    if (jrc05 === 0) {
      Value = 0;
    } else {
      Value = jrc08 / jrc05;
    }
    Result[Bar] = Value;
  }
  return Result;
}

function JCFB24(SrcA: TSeries, Smooth: number): TSeries {
  let Result: TSeries = [];
  let Bar: number;
  let Value: number;
  let er1: TSeries, er2: TSeries, er3: TSeries, er4: TSeries, er5: TSeries, er6: TSeries, er7: TSeries, er8: TSeries;
  let er20: number, er21: number, er29: number;
  let er15: number, er16: number, er17: number, er18: number, er19: number;
  let er22: number[], er23: number[];
  Result = new Array(SrcA.length);
  er20 = 0; er21 = 0; er29 = 0; er15 = 0; er16 = 0; er17 = 0; er18 = 0;
  er19 = 0;
  er22 = new Array(8);
  er23 = new Array(8);
  er15 = 1;
  er16 = 1;
  er19 = 20;
  er29 = Smooth;
  er1 = JCFBaux(SrcA, 2);
  er2 = JCFBaux(SrcA, 3);
  er3 = JCFBaux(SrcA, 4);
  er4 = JCFBaux(SrcA, 6);
  er5 = JCFBaux(SrcA, 8);
  er6 = JCFBaux(SrcA, 12);
  er7 = JCFBaux(SrcA, 16);
  er8 = JCFBaux(SrcA, 24);
  for (Bar = 1; Bar < SrcA.length; Bar++) {
    if (Bar <= er29) {
      for (er21 = 1; er21 <= 8; er21++) {
        er23[er21] = 0;
      }
      for (er20 = 0; er20 <= Bar-1; er20++) {
        er23[1] = er23[1] + er1[Bar-er20];
        er23[2] = er23[2] + er2[Bar-er20];
        er23[3] = er23[3] + er3[Bar-er20];
        er23[4] = er23[4] + er4[Bar-er20];
        er23[5] = er23[5] + er5[Bar-er20];
        er23[6] = er23[6] + er6[Bar-er20];
        er23[7] = er23[7] + er7[Bar-er20];
        er23[8] = er23[8] + er8[Bar-er20];
      }
      for (er21 = 1; er21 <= 8; er21++) {
        er23[er21] = er23[er21] / Bar;
      }
    } else {
      er23[1] = er23[1] + (er1[Bar] - er1[Bar-er29]) / er29;
      er23[2] = er23[2] + (er2[Bar] - er2[Bar-er29]) / er29;
      er23[3] = er23[3] + (er3[Bar] - er3[Bar-er29]) / er29;
      er23[4] = er23[4] + (er4[Bar] - er4[Bar-er29]) / er29;
      er23[5] = er23[5] + (er5[Bar] - er5[Bar-er29]) / er29;
      er23[6] = er23[6] + (er6[Bar] - er6[Bar-er29]) / er29;
      er23[7] = er23[7] + (er7[Bar] - er7[Bar-er29]) / er29;
      er23[8] = er23[8] + (er8[Bar] - er8[Bar-er29]) / er29;
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
      er17 = er22[1]*er22[1]*2 + er22[3]*er22[3]*4 +
              er22[5]*er22[5]*8 + er22[7]*er22[7]*16 +
              er22[2]*er22[2]*3 + er22[4]*er22[4]*6 +
              er22[6]*er22[6]*12 + er22[8]*er22[8]*24;
      er18 = er22[1]*er22[1] + er22[3]*er22[3] +
              er22[5]*er22[5] + er22[7]*er22[7] +
              er22[2]*er22[2] + er22[4]*er22[4] +
              er22[6]*er22[6] + er22[8]*er22[8];
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

function JCFB48(SrcA: TSeries, Smooth: number): TSeries {
  let Result: TSeries = [];
  let Bar: number;
  let Value: number;
  let er1: TSeries, er2: TSeries, er3: TSeries, er4: TSeries, er5: TSeries, er6: TSeries, er7: TSeries, er8: TSeries, er9: TSeries, er10: TSeries;
  let er20: number, er21: number, er29: number;
  let er15: number, er16: number, er17: number, er18: number, er19: number;
  let er22: number[], er23: number[];
  Result = new Array(SrcA.length);
  er20 = 0; er21 = 0; er29 = 0;
  er15 = 0; er16 = 0; er17 = 0; er18 = 0; er19 = 0;
  er22 = new Array(10);
  er23 = new Array(10);
  er15 = 1;
  er16 = 1;
  er19 = 20;
  er29 = Smooth;
  er1 = JCFBaux(SrcA, 2);
  er2 = JCFBaux(SrcA, 3);
  er3 = JCFBaux(SrcA, 4);
  er4 = JCFBaux(SrcA, 6);
  er5 = JCFBaux(SrcA, 8);
  er6 = JCFBaux(SrcA, 12);
  er7 = JCFBaux(SrcA, 16);
  er8 = JCFBaux(SrcA, 24);
  er9 = JCFBaux(SrcA, 32);
  er10 = JCFBaux(SrcA, 48);
  for (Bar = 1; Bar < SrcA.length; Bar++) {
    if (Bar <= er29) {
      for (er21 = 1; er21 <= 10; er21++) {
        er23[er21] = 0;
      }
      for (er20 = 0; er20 <= Bar-1; er20++) {
        er23[1] = er23[1] + er1[Bar-er20];
        er23[2] = er23[2] + er2[Bar-er20];
        er23[3] = er23[3] + er3[Bar-er20];
        er23[4] = er23[4] + er4[Bar-er20];
        er23[5] = er23[5] + er5[Bar-er20];
        er23[6] = er23[6] + er6[Bar-er20];
        er23[7] = er23[7] + er7[Bar-er20];
        er23[8] = er23[8] + er8[Bar-er20];
        er23[9] = er23[9] + er9[Bar-er20];
        er23[10] = er23[10] + er10[Bar-er20];
      }
      for (er21 = 1; er21 <= 10; er21++) {
        er23[er21] = er23[er21] / Bar;
      }
    } else {
      er23[1] = er23[1] + (er1[Bar] - er1[Bar-er29]) / er29;
      er23[2] = er23[2] + (er2[Bar] - er2[Bar-er29]) / er29;
      er23[3] = er23[3] + (er3[Bar] - er3[Bar-er29]) / er29;
      er23[4] = er23[4] + (er4[Bar] - er4[Bar-er29]) / er29;
      er23[5] = er23[5] + (er5[Bar] - er5[Bar-er29]) / er29;
      er23[6] = er23[6] + (er6[Bar] - er6[Bar-er29]) / er29;
      er23[7] = er23[7] + (er7[Bar] - er7[Bar-er29]) / er29;
      er23[8] = er23[8] + (er8[Bar] - er8[Bar-er29]) / er29;
      er23[9] = er23[9] + (er9[Bar] - er9[Bar-er29]) / er29;
      er23[10] = er23[10] + (er10[Bar] - er10[Bar-er29]) / er29;
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
      er17 = er22[1]*er22[1]*2 + er22[3]*er22[3]*4 +
              er22[5]*er22[5]*8 + er22[7]*er22[7]*16 +
              er22[9]*er22[9]*32 + er22[2]*er22[2]*3 +
              er22[4]*er22[4]*6 + er22[6]*er22[6]*12 +
              er22[8]*er22[8]*24 + er22[10]*er22[10]*48;
      er18 = er22[1]*er22[1] + er22[3]*er22[3] +
              er22[5]*er22[5] + er22[7]*er22[7] +
              er22[9]*er22[9] + er22[2]*er22[2] +
              er22[4]*er22[4] + er22[6]*er22[6] +
              er22[8]*er22[8] + er22[10]*er22[10];
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

function JCFB96(SrcA: TSeries, Smooth: number): TSeries {
  let Result: TSeries = [];
  let Bar: number;
  let Value: number;
  let er1: TSeries, er2: TSeries, er3: TSeries, er4: TSeries, er5: TSeries, er6: TSeries, er7: TSeries, er8: TSeries, er9: TSeries, er10: TSeries, er11: TSeries, er12: TSeries;
  let er20: number, er21: number, er29: number;
  let er15: number, er16: number, er17: number, er18: number, er19: number;
  let er22: number[], er23: number[];
  Result = new Array(SrcA.length);
  er20 = 0; er21 = 0; er29 = 0;
  er15 = 0; er16 = 0; er17 = 0; er18 = 0; er19 = 0;
  er22 = new Array(12);
  er23 = new Array(12);
  er15 = 1;
  er16 = 1;
  er19 = 20;
  er29 = Smooth;
  er1 = JCFBaux(SrcA, 2);
  er2 = JCFBaux(SrcA, 3);
  er3 = JCFBaux(SrcA, 4);
  er4 = JCFBaux(SrcA, 6);
  er5 = JCFBaux(SrcA, 8);
  er6 = JCFBaux(SrcA, 12);
  er7 = JCFBaux(SrcA, 16);
  er8 = JCFBaux(SrcA, 24);
  er9 = JCFBaux(SrcA, 32);
  er10 = JCFBaux(SrcA, 48);
  er11 = JCFBaux(SrcA, 64);
  er12 = JCFBaux(SrcA, 96);
  for (Bar = 1; Bar < SrcA.length; Bar++) {
    if (Bar <= er29) {
      for (er21 = 1; er21 <= 12; er21++) {
        er23[er21] = 0;
      }
      for (er20 = 0; er20 <= Bar-1; er20++) {
        er23[1] = er23[1] + er1[Bar-er20];
        er23[2] = er23[2] + er2[Bar-er20];
        er23[3] = er23[3] + er3[Bar-er20];
        er23[4] = er23[4] + er4[Bar-er20];
        er23[5] = er23[5] + er5[Bar-er20];
        er23[6] = er23[6] + er6[Bar-er20];
        er23[7] = er23[7] + er7[Bar-er20];
        er23[8] = er23[8] + er8[Bar-er20];
        er23[9] = er23[9] + er9[Bar-er20];
        er23[10] = er23[10] + er10[Bar-er20];
        er23[11] = er23[11] + er11[Bar-er20];
        er23[12] = er23[12] + er12[Bar-er20];
      }
      for (er21 = 1; er21 <= 12; er21++) {
        er23[er21] = er23[er21] / Bar;
      }
    } else {
      er23[1] = er23[1] + (er1[Bar] - er1[Bar-er29]) / er29;
      er23[2] = er23[2] + (er2[Bar] - er2[Bar-er29]) / er29;
      er23[3] = er23[3] + (er3[Bar] - er3[Bar-er29]) / er29;
      er23[4] = er23[4] + (er4[Bar] - er4[Bar-er29]) / er29;
      er23[5] = er23[5] + (er5[Bar] - er5[Bar-er29]) / er29;
      er23[6] = er23[6] + (er6[Bar] - er6[Bar-er29]) / er29;
      er23[7] = er23[7] + (er7[Bar] - er7[Bar-er29]) / er29;
      er23[8] = er23[8] + (er8[Bar] - er8[Bar-er29]) / er29;
      er23[9] = er23[9] + (er9[Bar] - er9[Bar-er29]) / er29;
      er23[10] = er23[10] + (er10[Bar] - er10[Bar-er29]) / er29;
      er23[11] = er23[11] + (er11[Bar] - er11[Bar-er29]) / er29;
      er23[12] = er23[12] + (er12[Bar] - er12[Bar-er29]) / er29;
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
      er17 = er22[1]*er22[1]*2 + er22[3]*er22[3]*4 +
              er22[5]*er22[5]*8 + er22[7]*er22[7]*16 +
              er22[9]*er22[9]*32 + er22[11]*er22[11]*64 +
              er22[2]*er22[2]*3 + er22[4]*er22[4]*6 +
              er22[6]*er22[6]*12 + er22[8]*er22[8]*24 +
              er22[10]*er22[10]*48 + er22[12]*er22[12]*96;
      er18 = er22[1]*er22[1] + er22[3]*er22[3] +
              er22[5]*er22[5] + er22[7]*er22[7] +
              er22[9]*er22[9] + er22[11]*er22[11] +
              er22[2]*er22[2] + er22[4]*er22[4] +
              er22[6]*er22[6] + er22[8]*er22[8] +
              er22[10]*er22[10] + er22[12]*er22[12];
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

function JCFB192(SrcA: TSeries, Smooth: number): TSeries {
  let Result: TSeries = [];
  let Bar: number;
  let Value: number;
  let er1: TSeries, er2: TSeries, er3: TSeries, er4: TSeries, er5: TSeries, er6: TSeries, er7: TSeries, er8: TSeries, er9: TSeries, er10: TSeries, er11: TSeries, er12: TSeries, er13: TSeries, er14: TSeries;
  let er20: number, er21: number, er29: number;
  let er15: number, er16: number, er17: number, er18: number, er19: number;
  let er22: number[], er23: number[];
  Result = new Array(SrcA.length);
  er20 = 0; er21 = 0; er29 = 0;
  er15 = 0; er16 = 0; er17 = 0; er18 = 0; er19 = 0;
  er22 = new Array(14);
  er23 = new Array(14);
  er15 = 1;
  er16 = 1;
  er19 = 20;
  er29 = Smooth;
  er1 = JCFBaux(SrcA, 2);
  er2 = JCFBaux(SrcA, 3);
  er3 = JCFBaux(SrcA, 4);
  er4 = JCFBaux(SrcA, 6);
  er5 = JCFBaux(SrcA, 8);
  er6 = JCFBaux(SrcA, 12);
  er7 = JCFBaux(SrcA, 16);
  er8 = JCFBaux(SrcA, 24);
  er9 = JCFBaux(SrcA, 32);
  er10 = JCFBaux(SrcA, 48);
  er11 = JCFBaux(SrcA, 64);
  er12 = JCFBaux(SrcA, 96);
  er13 = JCFBaux(SrcA, 128);
  er14 = JCFBaux(SrcA, 192);
  for (Bar = 1; Bar < SrcA.length; Bar++) {
    if (Bar <= er29) {
      for (er21 = 1; er21 <= 14; er21++) {
        er23[er21] = 0;
      }
      for (er20 = 0; er20 <= Bar-1; er20++) {
        er23[1] = er23[1] + er1[Bar-er20];
        er23[2] = er23[2] + er2[Bar-er20];
        er23[3] = er23[3] + er3[Bar-er20];
        er23[4] = er23[4] + er4[Bar-er20];
        er23[5] = er23[5] + er5[Bar-er20];
        er23[6] = er23[6] + er6[Bar-er20];
        er23[7] = er23[7] + er7[Bar-er20];
        er23[8] = er23[8] + er8[Bar-er20];
        er23[9] = er23[9] + er9[Bar-er20];
        er23[10] = er23[10] + er10[Bar-er20];
        er23[11] = er23[11] + er11[Bar-er20];
        er23[12] = er23[12] + er12[Bar-er20];
        er23[13] = er23[13] + er13[Bar-er20];
        er23[14] = er23[14] + er14[Bar-er20];
      }
      for (er21 = 1; er21 <= 14; er21++) {
        er23[er21] = er23[er21] / Bar;
      }
    } else {
      er23[1] = er23[1] + (er1[Bar] - er1[Bar-er29]) / er29;
      er23[2] = er23[2] + (er2[Bar] - er2[Bar-er29]) / er29;
      er23[3] = er23[3] + (er3[Bar] - er3[Bar-er29]) / er29;
      er23[4] = er23[4] + (er4[Bar] - er4[Bar-er29]) / er29;
      er23[5] = er23[5] + (er5[Bar] - er5[Bar-er29]) / er29;
      er23[6] = er23[6] + (er6[Bar] - er6[Bar-er29]) / er29;
      er23[7] = er23[7] + (er7[Bar] - er7[Bar-er29]) / er29;
      er23[8] = er23[8] + (er8[Bar] - er8[Bar-er29]) / er29;
      er23[9] = er23[9] + (er9[Bar] - er9[Bar-er29]) / er29;
      er23[10] = er23[10] + (er10[Bar] - er10[Bar-er29]) / er29;
      er23[11] = er23[11] + (er11[Bar] - er11[Bar-er29]) / er29;
      er23[12] = er23[12] + (er12[Bar] - er12[Bar-er29]) / er29;
      er23[13] = er23[13] + (er13[Bar] - er13[Bar-er29]) / er29;
      er23[14] = er23[14] + (er14[Bar] - er14[Bar-er29]) / er29;
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
      er17 = er22[1]*er22[1]*2 + er22[3]*er22[3]*4 +
              er22[5]*er22[5]*8 + er22[7]*er22[7]*16 +
              er22[9]*er22[9]*32 + er22[11]*er22[11]*64 +
              er22[13]*er22[13]*128 + er22[2]*er22[2]*3 +
              er22[4]*er22[4]*6 + er22[6]*er22[6]*12 +
              er22[8]*er22[8]*24 + er22[10]*er22[10]*48 +
              er22[12]*er22[12]*96 + er22[14]*er22[14]*192;
      er18 = er22[1]*er22[1] + er22[3]*er22[3] +
              er22[5]*er22[5] + er22[7]*er22[7] +
              er22[9]*er22[9] + er22[11]*er22[11] +
              er22[13]*er22[13] + er22[2]*er22[2] +
              er22[4]*er22[4] + er22[6]*er22[6] +
              er22[8]*er22[8] + er22[10]*er22[10] +
              er22[12]*er22[12] + er22[14]*er22[14];
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

function JCFBSeries(SrcA: TSeries, AFractalType: number, ASmooth: number): TSeries {
  let Result: TSeries = [];
  let Bar: number;
  Result = new Array(SrcA.length);
  switch (AFractalType) {
    case 1:
      Result = JCFB24(SrcA, ASmooth);
      break;
    case 2:
      Result = JCFB48(SrcA, ASmooth);
      break;
    case 3:
      Result = JCFB96(SrcA, ASmooth);
      break;
    case 4:
      Result = JCFB192(SrcA, ASmooth);
      break;
  }
  return Result;
}



import { max } from 'mathjs';

type TSeries = number[];

function JJMASeries(SrcA: TSeries, ALength: number, APhase: number): TSeries {
  // implementation
  return [];
}

function TrueRangeSeries(CloseA: TSeries, HighA: TSeries, LowA: TSeries): TSeries {
  const Result: TSeries = [];
  for (let Bar = 2; Bar < CloseA.length; Bar++) {
    const m1 = Math.abs(HighA[Bar] - LowA[Bar]);
    const m2 = Math.abs(HighA[Bar] - CloseA[Bar - 1]);
    const m3 = Math.abs(LowA[Bar] - CloseA[Bar - 1]);
    Result[Bar] = max(max(m1, m2), m3);
  }
  return Result;
}

function JDMXplusSeries(SrcA: TSeries, HighA: TSeries, LowA: TSeries, ALen: number): TSeries {
  const Result: TSeries = [];
  const upward: TSeries = [];
  const numer: TSeries = [];
  const denom: TSeries = [];
  for (let Bar = 1; Bar < SrcA.length; Bar++) {
    const v1 = 100 * (HighA[Bar] - HighA[Bar - 1]);
    const v2 = 100 * (LowA[Bar - 1] - LowA[Bar]);
    if (v1 > v2 && v1 > 0) {
      upward[Bar] = v1;
    } else {
      upward[Bar] = 0;
    }
  }
  numer = JJMASeries(upward, ALen, -100);
  denom = JJMASeries(TrueRangeSeries(SrcA, HighA, LowA), ALen, -100);
  for (let Bar = 0; Bar < SrcA.length; Bar++) {
    let Value: number;
    if (denom[Bar] > 0.00001 && Bar > 40) {
      Value = 100 * numer[Bar] / denom[Bar];
    } else {
      Value = 0;
    }
    Result[Bar] = Value;
  }
  return Result;
}

function JDMXminusSeries(SrcA: TSeries, HighA: TSeries, LowA: TSeries, ALen: number): TSeries {
  const Result: TSeries = [];
  const downward: TSeries = [];
  const numer: TSeries = [];
  const denom: TSeries = [];
  for (let Bar = 1; Bar < SrcA.length; Bar++) {
    const v1 = 100 * (HighA[Bar] - HighA[Bar - 1]);
    const v2 = 100 * (LowA[Bar - 1] - LowA[Bar]);
    if (v2 > v1 && v2 > 0) {
      downward[Bar] = v2;
    } else {
      downward[Bar] = 0;
    }
  }
  numer = JJMASeries(downward, ALen, -100);
  denom = JJMASeries(TrueRangeSeries(SrcA, HighA, LowA), ALen, -100);
  for (let Bar = 0; Bar < SrcA.length; Bar++) {
    let Value: number;
    if (denom[Bar] > 0.00001 && Bar > 40) {
      Value = 100 * numer[Bar] / denom[Bar];
    } else {
      Value = 0;
    }
    Result[Bar] = Value;
  }
  return Result;
}

function JDMXSeries(SrcA: TSeries, HighA: TSeries, LowA: TSeries, ALen: number): TSeries {
  const Result: TSeries = [];
  const DMXplus: TSeries = JDMXplusSeries(SrcA, HighA, LowA, ALen);
  const DMXminus: TSeries = JDMXminusSeries(SrcA, HighA, LowA, ALen);
  for (let Bar = 0; Bar < SrcA.length; Bar++) {
    let Value: number;
    if (DMXplus[Bar] + DMXminus[Bar] > 0.00001) {
      Value = 100 * (DMXplus[Bar] - DMXminus[Bar]) / (DMXplus[Bar] + DMXminus[Bar]);
    } else {
      Value = 0;
    }
    Result[Bar] = Value;
  }
  return Result;
}



interface TSeries extends Array<number> {}

function JXRSXSeries(SrcA: TSeries, LenA: TSeries): TSeries {
  let Result: TSeries = [];
  let Bar: number;
  let Value: number;
  let f0: number, f88: number, f90: number;
  let f8: number, f10: number, f18: number, f20: number, f28: number, f30: number, f38: number, f40: number, f48: number, f50: number, f58: number, f60: number, f68: number, f70: number, f78: number, f80: number;
  let v4: number, v8: number, vC: number, v10: number, v14: number, v18: number, v1C: number, v20: number;

  Result = new Array(SrcA.length);
  f0 = 0; f88 = 0; f90 = 0;
  f8 = 0; f10 = 0; f18 = 0; f20 = 0; f28 = 0; f30 = 0; f38 = 0; f40 = 0;
  f48 = 0; f50 = 0; f58 = 0; f60 = 0; f68 = 0; f70 = 0; f78 = 0; f80 = 0;
  v4 = 0; v8 = 0; vC = 0; v10 = 0; v14 = 0; v18 = 0; v1C = 0; v20 = 0;

  for (Bar = 0; Bar < SrcA.length; Bar++) {
    if (f90 === 0) {
      f90 = 1;
      f0 = 0;
      if (Math.trunc(LenA[Bar]) - 1 >= 5) f88 = Math.trunc(LenA[Bar]) - 1;
      else f88 = 5;
      f8 = 100 * SrcA[Bar];
      f18 = 3 / (Math.trunc(LenA[Bar]) + 2);
      f20 = 1 - f18;
    } else {
      if (f88 <= f90) f90 = f88 + 1;
      else f90 = f90 + 1;
      f10 = f8;
      f8 = 100 * SrcA[Bar];
      v8 = f8 - f10;
      f28 = f20 * f28 + f18 * v8;
      f30 = f18 * f28 + f20 * f30;
      vC = f28 * 1.5 - f30 * 0.5;
    }
  }

  return Result;
}


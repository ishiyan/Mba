/**
 * Calculates the JVELCFB series for a given input series
 * @param Series The input series
 * @param LoDepth The lower depth
 * @param HiDepth The higher depth
 * @param FractalType The type of fractal
 * @param Smooth The smooth factor
 * @returns The JVELCFB series
 */
function JVELCFBSeries(Series: number, LoDepth: number, HiDepth: number, FractalType: number, Smooth: number): number[] {
  let vl: number, cfb: number, Bar: number;
  let sName: string;
  let sr: number, cfbmin: number, cfbmax: number, Value: number;
  sName = `JVELCFB(${GetDescription(Series)},${LoDepth},${HiDepth},${FractalType},${Smooth})`;
  let Result: number = FindNamedSeries(sName);
  if (Result >= 0) {
    return Result;
  }
  Result = CreateNamedSeries(sName);
  cfbmin = 99999;
  cfbmax = 0;
  cfb = JCFBSeries(Series, FractalType, Smooth);
  vl = CreateSeries();
  for (Bar = 0; Bar < BarCount() - 1; Bar++) {
    if (cfb[Bar] > cfbmax) cfbmax = cfb[Bar];
    if (cfb[Bar] < cfbmin) cfbmin = cfb[Bar];
    if (cfbmax > cfbmin) {
      sr = (cfb[Bar] - cfbmin) / (cfbmax - cfbmin);
    } else {
      sr = 0.5;
    }
    vl[Bar] = Math.floor(LoDepth + sr * (HiDepth - LoDepth));
  }
  for (Bar = 0; Bar < BarCount() - 1; Bar++) {
    Result[Bar] = GetSeriesValue(Bar, JXVELaux3(JXVELaux1(Series, vl), 3));
  }
  return Result;
}

/**
 * Calculates the JVELCFB for a given bar
 * @param Bar The bar index
 * @param Series The input series
 * @param LoDepth The lower depth
 * @param HiDepth The higher depth
 * @param FractalType The type of fractal
 * @param Smooth The smooth factor
 * @returns The JVELCFB value for the given bar
 */
function JVELCFB(Bar: number, Series: number, LoDepth: number, HiDepth: number, FractalType: number, Smooth: number): number {
  return GetSeriesValue(Bar, JVELCFBSeries(Series, LoDepth, HiDepth, FractalType, Smooth));
}

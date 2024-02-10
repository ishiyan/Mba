package main

import (
	"math"
)

type TSeries []float64

func JAVELSeries(SrcA TSeries, ALoLen, AHiLen int, ASensitivity, APeriod float64) TSeries {
	var value1, value4 TSeries
	eps := 0.001
	value1 = make(TSeries, len(SrcA))
	value4 = make(TSeries, len(SrcA))
	for Bar := 1; Bar < len(SrcA); Bar++ {
		value1[Bar] = math.Abs(SrcA[Bar] - SrcA[Bar-1])
	}
	for Bar := 0; Bar < len(SrcA); Bar++ {
		avg1 := 0.0
		k := 0
		if Bar < 99 {
			k = Bar
		} else {
			k = 99
		}
		for j := 0; j <= k; j++ {
			avg1 += value1[Bar-j]
		}
		avg1 /= float64(k+1)
		avg2 := 0.0
		if Bar < 9 {
			k = Bar
		} else {
			k = 9
		}
		for j := 0; j <= k; j++ {
			avg2 += value1[Bar-j]
		}
		avg2 /= float64(k+1)
		value2 := ASensitivity * math.Log((eps+avg1) / (eps+avg2))
		value3 := value2 / (1 + math.Abs(value2))
		value4[Bar] = float64(ALoLen) + (float64(AHiLen)-float64(ALoLen)) * (1+value3) / 2
	}
	return JXVELaux3(JXVELaux1(SrcA, value4), APeriod)
}

func JXVELSeries(SrcA, DepthSrcA TSeries, APeriod float64) TSeries {
	return JXVELaux3(JXVELaux1(SrcA, DepthSrcA), APeriod)
}

func JVELSeries(SrcA TSeries, ADepth int) TSeries {
	return JVELaux3(JVELaux1(SrcA, ADepth))
}

func JXVELaux1(SrcA, DepthSeries TSeries) TSeries {
	Result := make(TSeries, len(SrcA))
	jrc05 := 0.0
	jrc06 := 0.0
	jrc07 := 0.0
	jrc08 := 0.0
	jrc09 := 0.0
	jrc02 := 0
	jrc04 := 0
	jrc10 := 0
	for Bar := 0; Bar < len(SrcA); Bar++ {
		jrc02 = int(math.Ceil(DepthSeries[Bar]))
		jrc04 = jrc02 + 1
		if Bar < jrc04 {
			continue
		}
		jrc05 = float64(jrc04 * (jrc04+1) / 2)
		jrc06 = float64(jrc05 * (2*jrc04+1) / 3)
		jrc07 = jrc05 * jrc05 * jrc05 - jrc06 * jrc06
		jrc08 = 0.0
		jrc09 = 0.0
		for jrc10 = 0; jrc10 <= jrc02; jrc10++ {
			jrc08 += SrcA[Bar-jrc10] * float64(jrc04 - jrc10)
			jrc09 += SrcA[Bar-jrc10] * float64(jrc04 - jrc10) * float64(jrc04 - jrc10)
		}
		Result[Bar] = (jrc09*jrc05 - jrc08*jrc06) / jrc07
	}
	return Result
}

func JXVELaux3(SrcA TSeries, Period float64) TSeries {
	Result := make(TSeries, len(SrcA))
	input1 := 0.0
	jrc02 := 0
	jrc03 := 0.0
	jrc04 := 0.0
	jrc05 := 0.0
	jrc08 := 0.0
	jrc09 := 0.0
	jrc10 := 0
	jrc12 := 0.0
	jrc13 := 0.0
	jrc14 := 0.0
	jrc16 := 0.0
	jrc17 := 0.0
	jrc18 := 0.0
	jrc19 := 0.0
	jrc20 := 0.0
	jrc21 := 0.0
	jrc22 := 0.0
	jrc25 := 0.0
	jrc01 := 0
	jrc06 := 0
	jrc07 := 0
	jrc11 := 0
	jrc15 := 0
	jrc23 := 0
	jrc24 := 0
	jrc26 := 0
	jrc27 := 0
	jrc28 := 0
	jrc29 := 0
	jrc30 := make([]float64, 1001)
	for Bar := 0; Bar < len(SrcA); Bar++ {
		input1 = SrcA[Bar]
		jrc27 = Bar
		if Bar == 0 {
			jrc26 = jrc27
		}
		if Bar > 0 {
			if jrc24 <= 0 {
				jrc24 = 1001
			}
			jrc24 -= 1
			jrc30[jrc24] = input1
		}
		if jrc27 < jrc26 + jrc01 {
			jrc20 = input1
		} else {
			jrc03 = math.Min(500, math.Max(jrc02, Period))
			jrc07 = int(math.Min(float64(jrc01), math.Ceil(jrc03)))
			jrc04 = 0.86 - 0.55 / math.Sqrt(jrc03)
			jrc05 = 1 - math.Exp(-math.Log(4) / jrc03 / 2)
			jrc06 = math.Trunc(math.Max(float64(jrc01 + 1), math.Ceil(2*jrc03)))
			jrc11 = int(math.Trunc(math.Min(float64(jrc27 - jrc26 + 1), float64(jrc06))))
			jrc12 = jrc11 * (jrc11+1) * (jrc11-1) / 12
			jrc13 = (jrc11+1) / 2
			jrc14 = (jrc11-1) / 2
			jrc09 = 0.0
			jrc10 = 0
			for jrc15 = jrc11 - 1; jrc15 >= 0; jrc15-- {
				jrc23 = (jrc24 + jrc15) % 1001
				jrc09 += jrc30[jrc23]
				jrc10 += jrc30[jrc23] * (jrc14 - jrc15)
			}
			jrc16 = jrc10 / jrc12
			jrc17 = jrc09 / float64(jrc11) - jrc16 * jrc13
			jrc18 = 0.0
			for jrc15 = jrc11 - 1; jrc15 >= 0; jrc15-- {
				jrc17 += jrc16
				jrc23 = (jrc24+jrc15) % 1001
				jrc18 += math.Abs(jrc30[jrc23] - jrc17)
			}
			jrc25 = 1.2 * jrc18 / float64(jrc11)
			if jrc11 < jrc06 {
				jrc25 *= math.Pow(jrc06 / float64(jrc11), 0.25)
			}
			if jrc28 == 1 {
				jrc28 = 0
				jrc19 = jrc25
			} else {
				jrc19 += (jrc25 - jrc19) * jrc05
			}
			jrc19 = math.Max(jrc02, jrc19)
			if jrc29 == 1 {
				jrc29 = 0
				jrc08 = (jrc30[jrc24] - jrc30[(jrc24+jrc07) % 1001]) / float64(jrc07)
			}
			jrc21 = input1 - (jrc20 + jrc08 * jrc04)
			jrc22 = 1 - math.Exp(-math.Abs(jrc21) / jrc19 / jrc03)
			jrc08 = jrc22 * jrc21 + jrc08 * jrc04
			jrc20 += jrc08
		}
		Result[Bar] = jrc20
	}
	return Result
}

func JVELaux1(SrcA TSeries, Depth int) TSeries {
	Result := make(TSeries, len(SrcA))
	jrc04 := 0.0
	jrc05 := 0.0
	jrc06 := 0.0
	jrc07 := 0.0
	jrc08 := 0.0
	jrc09 := 0.0
	jrc01 := SrcA
	jrc02 := Depth
	jrc04 = float64(jrc02 + 1)
	jrc05 = jrc04 * (jrc04+1) / 2
	jrc06 = jrc05 * (2*jrc04+1) / 3
	jrc07 = jrc05 * jrc05 * jrc05 - jrc06 * jrc06
	for Bar := jrc02; Bar < len(SrcA); Bar++ {
		jrc08 = 0.0
		jrc09 = 0.0
		for jrc10 := 0; jrc10 <= jrc02; jrc10++ {
			jrc08 += jrc01[Bar-jrc10] * (jrc04 - jrc10)
			jrc09 += jrc01[Bar-jrc10] * (jrc04 - jrc10) * (jrc04 - jrc10)
		}
		Result[Bar] = (jrc09*jrc05 - jrc08*jrc06) / jrc07
	}
	return Result
}

func JVELaux3(SrcA TSeries) TSeries {
	Result := make(TSeries, len(SrcA))
	JR02 := 0.0
	JR04 := 0.0
	JR05 := 0.0
	JR08 := 0.0
	JR09 := 0.0
	JR10 := 0.0
	JR12 := 0.0
	JR13 := 0.0
	JR14 := 0.0
	JR16 := 0.0
	JR17 := 0.0
	JR19 := 0.0
	JR20 := 0.0
	JR22 := 0.0
	JR23 := 0.0
	JR28 := 0.0
	JR01 := 0
	JR03 := 0
	JR06 := 0
	JR07 := 0
	JR11 := 0
	JR15 := 0
	JR18 := 0
	JR24 := 0
	JR25 := 0
	JR26 := 0
	JR27 := 0
	JR29 := 0
	JR21 := 0.0
	JR21a := 0.0
	JR21b := 0.0
	JR40 := make([]float64, 100)
	JR41 := make([]float64, 100)
	JR01 = 30
	JR02 = 0.0001
	for Bar := JR01; Bar < len(SrcA); Bar++ {
		JR27 = Bar
		if Bar == JR01 {
			JR28 = 0.0
			for JR29 := 1; JR29 <= JR01-1; JR29++ {
				if SrcA[Bar-JR29] == SrcA[Bar-JR29-1] {
					JR28 += 1
				}
			}
			if JR28 < float64(JR01-1) {
				JR26 = JR27-JR01
			} else {
				JR26 = JR27
			}
			JR18 = 0
			JR25 = 0
			JR21 = SrcA[Bar-1]
			JR03 = 3
			JR04 = 0.86 - 0.55 / math.Sqrt(float64(JR03))
			JR05 = 1 - math.Exp(-math.Log(4) / float64(JR03) / 2)
			JR06 = float64(JR01+1)
			JR07 = 3
			JR08 = (SrcA[Bar] - SrcA[Bar-JR07]) / float64(JR07)
			JR11 = int(math.Trunc(math.Min(1+float64(JR27-JR26), float64(JR06))))
			for JR15 := JR11-1; JR15 >= 1; JR15-- {
				if JR25 <= 0 {
					JR25 = 100
				}
				JR25 -= 1
				JR41[JR25] = SrcA[Bar-JR15]
			}
		}
		if JR25 <= 0 {
			JR25 = 100
		}
		JR25 -= 1
		JR41[JR25] = SrcA[Bar]
		if JR11 <= JR01 {
			if Bar == JR01 {
				JR21 = SrcA[Bar]
			} else {
				JR21 = math.Sqrt(JR05)*SrcA[Bar] + (1-math.Sqrt(JR05))*JR21a
			}
			if Bar > JR01+1 {
				JR08 = (JR21 - JR21b)/2
			} else {
				JR08 = 0
			}
			JR11 += 1
		} else {
			if JR11 <= JR06 {
				JR12 = JR11 * (JR11+1) * (JR11-1) / 12
				JR13 = (JR11+1) / 2
				JR14 = (JR11-1) / 2
				JR09 = 0.0
				JR10 = 0
				for JR15 := JR11-1; JR15 >= 0; JR15-- {
					JR24 = (JR25+JR15) % 100
					JR09 += JR41[JR24]
					JR10 += JR41[JR24]*(JR14 - JR15)
				}
				JR16 = JR10/JR12
				JR17 = (JR09/float64(JR11)) - (JR16*JR13)
				JR19 = 0.0
				for JR15 := JR11-1; JR15 >= 0; JR15-- {
					JR17 += JR16
					JR24 = (JR25+JR15) % 100
					JR19 += math.Abs(JR41[JR24]-JR17)
				}
				JR20 = (JR19/float64(JR11)) * math.Pow(JR06/float64(JR11), 0.25)
				JR11 += 1
			} else {
				if (Bar % 1000) == 0 {
					JR09 = 0.0
					JR10 = 0
					for JR15 := JR06-1; JR15 >= 0; JR15-- {
						JR24 = (JR25+JR15) % 100
						JR09 += JR41[JR24]
						JR10 += JR41[JR24]*(JR14 - JR15)
					}
				} else {
					JR24 = (JR25+JR06) % 100
					JR10 = JR10 - JR09 + JR41[JR24]*JR13 + SrcA[Bar]*JR14
					JR09 = JR09 - JR41[JR24] + SrcA[Bar]
				}
				if JR18 <= 0 {
					JR18 = JR06
				}
				JR18 -= 1
				JR19 -= JR40[JR18]
				JR16 = JR10/JR12
				JR17 = (JR09/float64(JR06)) + (JR16*JR14)
				JR40[JR18] = math.Abs(SrcA[Bar]-JR17)
				JR19 = math.Max(JR02, (JR19 + JR40[JR18]))
				JR20 += ((JR19/float64(JR06)) - JR20) * JR05
			}
			JR20 = math.Max(JR02, JR20)
			JR22 = SrcA[Bar] - (JR21 + JR08*JR04)
			JR23 = 1 - math.Exp(-math.Abs(JR22) / JR20 / JR03)
			JR08 = JR23*JR22 + JR08*JR04
			JR21 += JR08
		}
		JR21b = JR21a
		JR21a = JR21
		Result[Bar] = JR21
	}
	return Result
}

func JVELaux1(SrcA TSeries, Depth int) TSeries {
	Result := make(TSeries, len(SrcA))
	jrc04 := 0.0
	jrc05 := 0.0
	jrc06 := 0.0
	jrc07 := 0.0
	jrc08 := 0.0
	jrc09 := 0.0
	jrc01 := SrcA
	jrc02 := Depth
	jrc04 = float64(jrc02 + 1)
	jrc05 = jrc04 * (jrc04+1) / 2
	jrc06 = jrc05 * (2*jrc04+1) / 3
	jrc07 = jrc05 * jrc05 * jrc05 - jrc06 * jrc06
	for Bar := jrc02; Bar < len(SrcA); Bar++ {
		jrc08 = 0.0
		jrc09 = 0.0
		for jrc10 := 0; jrc10 <= jrc02; jrc10++ {
			jrc08 += jrc01[Bar-jrc10] * (jrc04 - jrc10)
			jrc09 += jrc01[Bar-jrc10] * (jrc04 - jrc10) * (jrc04 - jrc10)
		}
		Result[Bar] = (jrc09*jrc05 - jrc08*jrc06) / jrc07
	}
	return Result
}

func JVELSeries(SrcA TSeries, ADepth int) TSeries {
	return JVELaux3(JVELaux1(SrcA, ADepth))
}

func JXVELaux1(SrcA, DepthSeries TSeries) TSeries {
	Result := make(TSeries, len(SrcA))
	Bar := 0
	jrc05 := 0.0
	jrc06 := 0.0
	jrc07 := 0.0
	jrc08 := 0.0
	jrc09 := 0.0
	jrc02 := 0
	jrc04 := 0
	jrc10 := 0
	for Bar = 0; Bar < len(SrcA); Bar++ {
		jrc02 = int(math.Ceil(DepthSeries[Bar]))
		jrc04 = jrc02 + 1
		if Bar < jrc04 {
			continue
		}
		jrc05 = float64(jrc04 * (jrc04+1) / 2)
		jrc06 = float64(jrc05 * (2*jrc04+1) / 3)
		jrc07 = jrc05 * jrc05 * jrc05 - jrc06 * jrc06
		jrc08 = 0.0
		jrc09 = 0.0
		for jrc10 = 0; jrc10 <= jrc02; jrc10++ {
			jrc08 += SrcA[Bar-jrc10] * float64(jrc04 - jrc10)
			jrc09 += SrcA[Bar-jrc10] * float64(jrc04 - jrc10) * float64(jrc04 - jrc10)
		}
		Result[Bar] = (jrc09*jrc05 - jrc08*jrc06) / jrc07
	}
	return Result
}

func JXVELaux3(SrcA TSeries, Period float64) TSeries {
	Result := make(TSeries, len(SrcA))
	Bar := 0
	input1 := 0.0
	jrc02 := 0
	jrc03 := 0.0
	jrc04 := 0.0
	jrc05 := 0.0
	jrc08 := 0.0
	jrc09 := 0.0
	jrc10 := 0
	jrc12 := 0.0
	jrc13 := 0.0
	jrc14 := 0.0
	jrc16 := 0.0
	jrc17 := 0.0
	jrc18 := 0.0
	jrc19 := 0.0
	jrc20 := 0.0
	jrc21 := 0.0
	jrc22 := 0.0
	jrc25 := 0.0
	jrc01 := 0
	jrc06 := 0
	jrc07 := 0
	jrc11 := 0
	jrc15 := 0
	jrc23 := 0
	jrc24 := 0
	jrc26 := 0
	jrc27 := 0
	jrc28 := 0
	jrc29 := 0
	jrc30 := make([]float64, 1001)
	for Bar = 0; Bar < len(SrcA); Bar++ {
		input1 = SrcA[Bar]
		jrc27 = Bar
		if Bar == 0 {
			jrc26 = jrc27
		}
		if Bar > 0 {
			if jrc24 <= 0 {
				jrc24 = 1001
			}
			jrc24 -= 1
			jrc30[jrc24] = input1
		}
		if jrc27 < jrc26 + jrc01 {
			jrc20 = input1
		} else {
			jrc03 = math.Min(500, math.Max(float64(jrc02), Period))
			jrc07 = int(math.Min(float64(jrc01), math.Ceil(jrc03)))
			jrc04 = 0.86 - 0.55 / math.Sqrt(jrc03)
			jrc05 = 1 - math.Exp(-math.Log(4) / jrc03 / 2)
			jrc06 = math.Trunc(math.Max(float64(jrc01 + 1), math.Ceil(2*jrc03)))
			jrc11 = int(math.Trunc(math.Min(float64(jrc27 - jrc26 + 1), float64(jrc06))))
			jrc12 = jrc11 * (jrc11+1) * (jrc11-1) / 12
			jrc13 = (jrc11+1) / 2
			jrc14 = (jrc11-1) / 2
			jrc09 = 0.0
			jrc10 = 0
			for jrc15 = jrc11 - 1; jrc15 >= 0; jrc15-- {
				jrc23 = (jrc24 + jrc15) % 1001
				jrc09 += jrc30[jrc23]
				jrc10 += jrc30[jrc23] * (jrc14 - jrc15)
			}
			jrc16 = jrc10 / jrc12
			jrc17 = jrc09 / float64(jrc11) - jrc16 * jrc13
			jrc18 = 0.0
			for jrc15 = jrc11 - 1; jrc15 >= 0; jrc15-- {
				jrc17 += jrc16
				jrc23 = (jrc24+jrc15) % 1001
				jrc18 += math.Abs(jrc30[jrc23] - jrc17)
			}
			jrc25 = 1.2 * jrc18 / float64(jrc11)
			if jrc11 < jrc06 {
				jrc25 *= math.Pow(jrc06 / float64(jrc11), 0.25)
			}
			if jrc28 == 1 {
				jrc28 = 0
				jrc19 = jrc25
			} else {
				jrc19 += (jrc25 - jrc19) * jrc05
			}
			jrc19 = math.Max(jrc02, jrc19)
			if jrc29 == 1 {
				jrc29 = 0
				jrc08 = (jrc30[jrc24] - jrc30[(jrc24+jrc07) % 1001]) / float64(jrc07)
			}
			jrc21 = input1 - (jrc20 + jrc08 * jrc04)
			jrc22 = 1 - math.Exp(-math.Abs(jrc21) / jrc19 / jrc03)
			jrc08 = jrc22 * jrc21 + jrc08 * jrc04
			jrc20 += jrc08
		}
		Result[Bar] = jrc20
	}
	return Result
}

func main() {
	// Test code
}
// Note:** The code provided is a direct translation of the Pascal code to Go. However, it is important to note that the code may not be idiomatic Go code and may require further modifications to adhere to Go best practices.



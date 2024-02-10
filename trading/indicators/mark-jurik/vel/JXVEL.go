package main

import (
	"fmt"
	"math"
)

func JXVELaux1(Series []int, DepthSeries []int) []int {
	Bar := 0
	sName := ""
	jrc05, jrc06, jrc07, jrc08, jrc09 := 0.0, 0.0, 0.0, 0.0, 0.0
	jrc02, jrc04, jrc10 := 0, 0, 0
	sName = fmt.Sprintf("JXVELaux1(%d,%d)", Series, DepthSeries)
	Result := FindNamedSeries(sName)
	if Result >= 0 {
		return Result
	}
	Result = CreateNamedSeries(sName)
	for Bar := 0; Bar < len(BarCount()); Bar++ {
		jrc02 = int(math.Ceil(float64(DepthSeries[Bar])))
		jrc04 = jrc02 + 1
		if Bar < jrc04 {
			continue
		}
		jrc05 = float64(jrc04 * (jrc04+1) / 2)
		jrc06 = float64(jrc05 * (2*jrc04+1) / 3)
		jrc07 = float64(jrc05 * jrc05 * jrc05 - jrc06 * jrc06)
		jrc08 = 0
		jrc09 = 0
		for jrc10 := 0; jrc10 <= jrc02; jrc10++ {
			jrc08 += Series[Bar-jrc10] * (jrc04 - jrc10)
			jrc09 += Series[Bar-jrc10] * (jrc04 - jrc10) * (jrc04 - jrc10)
		}
		Result[Bar] = int((jrc09*jrc05 - jrc08*jrc06) / jrc07)
	}
	return Result
}

func JXVELaux3(Series []int, Period float64) []int {
	Bar := 0
	sName := ""
	sName = fmt.Sprintf("JXVELaux3(%d,%f)", Series, Period)
	Result := FindNamedSeries(sName)
	if Result >= 0 {
		return Result
	}
	Result = CreateNamedSeries(sName)
	input1, jrc02, jrc03, jrc04, jrc05, jrc07, jrc08, jrc09, jrc10, jrc12, jrc13, jrc14, jrc16, jrc17, jrc18, jrc19, jrc20, jrc21, jrc22, jrc23, jrc24, jrc25 := 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
	jrc01, jrc06, jrc11, jrc15, jrc26, jrc27, jrc28, jrc29 := 0, 0, 0, 0, 0, 0, 0, 0
	jrc30 := make([]float64, 1001)
	jrc01 = 30
	jrc02 = 0.0001
	jrc28 = 1
	jrc29 = 1
	for Bar := 0; Bar < len(BarCount()); Bar++ {
		input1 = float64(Series[Bar])
		jrc27 = Bar
		if Bar == 0 {
			jrc26 = jrc27
		}
		if Bar > 0 {
			if jrc24 <= 0 {
				jrc24 = 1001
			}
			jrc24 = jrc24 - 1
			jrc30[jrc24] = input1
		}
		if jrc27 < jrc26+jrc01 {
			jrc20 = input1
		} else {
			jrc03 = math.Min(500, math.Max(jrc02, Period))
			jrc07 = math.Min(jrc01, math.Ceil(jrc03))
			jrc04 = 0.86 - 0.55 / math.Sqrt(jrc03)
			jrc05 = 1 - math.Exp(-math.Log(4) / jrc03 / 2)
			jrc06 = int(math.Max(jrc01+1, math.Ceil(2*jrc03)))
			jrc11 = int(math.Min(jrc27-jrc26+1, jrc06))
			jrc12 = jrc11 * (jrc11+1) * (jrc11-1) / 12
			jrc13 = (jrc11+1) / 2
			jrc14 = (jrc11-1) / 2
			jrc09 = 0
			jrc10 = 0
			for jrc15 := jrc11 - 1; jrc15 >= 0; jrc15-- {
				jrc23 = (jrc24 + jrc15) % 1001
				jrc09 += jrc30[jrc23]
				jrc10 += jrc30[jrc23] * (jrc14 - jrc15)
			}
			jrc16 = jrc10 / jrc12
			jrc17 = jrc09 / jrc11 - jrc16 * jrc13
			jrc18 = 0
			for jrc15 := jrc11 - 1; jrc15 >= 0; jrc15-- {
				jrc17 += jrc16
				jrc23 = (jrc24+jrc15) % 1001
				jrc18 += math.Abs(jrc30[jrc23] - jrc17)
			}
			jrc25 = 1.2 * jrc18 / jrc11
			if jrc11 < jrc06 {
				jrc25 = jrc25 * math.Pow(jrc06 / jrc11, 0.25)
			}
			if jrc28 == 1 {
				jrc28 = 0
				jrc19 = jrc25
			} else {
				jrc19 = jrc19 + (jrc25 - jrc19) * jrc05
			}
			jrc19 = math.Max(jrc02, jrc19)
			if jrc29 == 1 {
				jrc29 = 0
				jrc08 = (jrc30[jrc24] - jrc30[(jrc24+jrc07) % 1001]) / jrc07
			}
			jrc21 = input1 - (jrc20 + jrc08 * jrc04)
			jrc22 = 1 - math.Exp(-math.Abs(jrc21) / jrc19 / jrc03)
			jrc08 = jrc22 * jrc21 + jrc08 * jrc04
			jrc20 = jrc20 + jrc08
		}
		Result[Bar] = int(jrc20)
	}
	return Result
}

func JXVELSeries(Series []int, DepthSeries []int, Period float64) []int {
	Bar := 0
	sName := ""
	Value := 0.0
	sName = fmt.Sprintf("JXVEL(%d,%d,%f)", Series, DepthSeries, Period)
	Result := FindNamedSeries(sName)
	if Result >= 0 {
		return Result
	}
	Result = CreateNamedSeries(sName)
	for Bar := 0; Bar < len(BarCount()); Bar++ {
		Result[Bar] = GetSeriesValue(Bar, JXVELaux3(JXVELaux1(Series, DepthSeries), Period))
	}
	return Result
}

func JXVEL(Bar int, Series []int, DepthSeries []int, Period float64) float64 {
	return GetSeriesValue(Bar, JXVELSeries(Series, DepthSeries, Period))
}



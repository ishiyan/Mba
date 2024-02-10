package main

import (
	"fmt"
)

func JTPOSeries(Series []int, Len int) []int {
	var Bar int
	var sName string
	var Value float64
	sName = fmt.Sprintf("JTPO(%s,%d)", GetDescription(Series), Len)
	Result := FindNamedSeries(sName)
	if Result >= 0 {
		return Result
	}
	Result = CreateNamedSeries(sName)
	var f0, f8, f10, f18, f20, f28 float64
	var f30, f38, f40, f48 int
	var var6, varA, varE, var12, var14 int
	var var18, var1C, var20, var24 float64
	var arr0, arr1, arr2, arr3 [301]float64
	for Bar := 0; Bar < BarCount()-1; Bar++ {
		var14 = 0
		var1C = 0
		if f38 == 0 {
			f38 = 1
			f40 = 0
			if Len-1 >= 2 {
				f30 = Len - 1
			} else {
				f30 = 2
			}
			f48 = f30 + 1
			f10 = Series[Bar]
			arr0[f38] = Series[Bar]
			f18 = 12 / (f48 * (f48 - 1) * (f48 + 1))
			f20 = (f48 + 1) * 0.5
		} else {
			if f38 <= f48 {
				f38 = f38 + 1
			} else {
				f38 = f48 + 1
			}
			f8 = f10
			f10 = Series[Bar]
			if f38 > f48 {
				for var6 := 2; var6 <= f48; var6++ {
					arr0[var6-1] = arr0[var6]
				}
				arr0[f48] = Series[Bar]
			} else {
				arr0[f38] = Series[Bar]
			}
			if f30 >= f38 && f8 != f10 {
				f40 = 1
			}
			if f30 == f38 && f40 == 0 {
				f38 = 0
			}
		}
		if f38 >= f48 {
			for varA := 1; varA <= f48; varA++ {
				arr2[varA] = varA
				arr3[varA] = varA
				arr1[varA] = arr0[varA]
			}
			for varA := 1; varA <= f48-1; varA++ {
				var24 = arr1[varA]
				var12 = varA
				var6 = varA + 1
				for var6 := varA + 1; var6 <= f48; var6++ {
					if arr1[var6] < var24 {
						var24 = arr1[var6]
						var12 = var6
					}
				}
				var20 = arr1[varA]
				arr1[varA] = arr1[var12]
				arr1[var12] = var20
				var20 = arr2[varA]
				arr2[varA] = arr2[var12]
				arr2[var12] = var20
			}
			varA = 1
			for f48 > varA {
				var6 = varA + 1
				var14 = 1
				var1C = arr3[varA]
				for var14 != 0 {
					if arr1[varA] != arr1[var6] {
						if var6-varA > 1 {
							var1C = var1C / (var6 - varA)
							varE = varA
							for varE := varA; varE <= var6-1; varE++ {
								arr3[varE] = var1C
							}
						}
						var14 = 0
					} else {
						var1C = var1C + arr3[var6]
						var6 = var6 + 1
					}
				}
				varA = var6
			}
			var1C = 0
			for varA := 1; varA <= f48; varA++ {
				var1C = var1C + (arr3[varA] - f20) * (arr2[varA] - f20)
			}
			var18 = f18 * var1C
		} else {
			var18 = 0
		}
		Value = var18
		Result[Bar] = Value
	}
	return Result
}

func JTPO(Bar int, Series []int, Len int) float64 {
	return GetSeriesValue(Bar, JTPOSeries(Series, Len))
}



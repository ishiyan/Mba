package main

import (
	"fmt"
)

type TSeries []float64

func JXRSXSeries(SrcA, LenA TSeries) TSeries {
	var Result TSeries
	Result = make(TSeries, len(SrcA))
	f0 := 0
	f88 := 0
	f90 := 0
	f8 := 0.0
	f10 := 0.0
	f18 := 0.0
	f20 := 0.0
	f28 := 0.0
	f30 := 0.0
	f38 := 0.0
	f40 := 0.0
	f48 := 0.0
	f50 := 0.0
	f58 := 0.0
	f60 := 0.0
	f68 := 0.0
	f70 := 0.0
	f78 := 0.0
	f80 := 0.0
	v4 := 0.0
	v8 := 0.0
	vC := 0.0
	v10 := 0.0
	v14 := 0.0
	v18 := 0.0
	v1C := 0.0
	v20 := 0.0

	for Bar := 0; Bar < len(SrcA); Bar++ {
		if f90 == 0 {
			f90 = 1
			f0 = 0
			if int(LenA[Bar])-1 >= 5 {
				f88 = int(LenA[Bar]) - 1
			} else {
				f88 = 5
			}
			f8 = 100 * SrcA[Bar]
			f18 = 3 / (float64(LenA[Bar]) + 2)
			f20 = 1 - f18
		} else {
			if f88 <= f90 {
				f90 = f88 + 1
			} else {
				f90 = f90 + 1
			}
			f10 = f8
			f8 = 100 * SrcA[Bar]
			v8 = f8 - f10
			f28 = f20*f28 + f18*v8
			f30 = f18*f28 + f20*f30
			vC = f28*1.5 - f30*0.5
			f38 = f20*f38 + f18*vC
			f40 = f18*f38 + f20*f40
			v10 = f38*1.5 - f40*0.5
			f48 = f20*f48 + f18*v10
			f50 = f18*f48 + f20*f50
			v14 = f48*1.5 - f50*0.5
			f58 = f20*f58 + f18*abs(v8)
			f60 = f18*f58 + f20*f60
			v18 = f58*1.5 - f60*0.5
			f68 = f20*f68 + f18*v18
			f70 = f18*f68 + f20*f70
			v1C = f68*1.5 - f70*0.5
			f78 = f20*f78 + f18*v1C
			f80 = f18*f78 + f20*f80
			v20 = f78*1.5 - f80*0.5
			if f88 >= f90 && f8 != f10 {
				f0 = 1
			}
			if f88 == f90 && f0 == 0 {
				f90 = 0
			}
		}
		if f88 < f90 && v20 > 1.0e-10 {
			v4 = (v14/v20 + 1) * 50
			if v4 > 100 {
				v4 = 100
			}
			if v4 < 0 {
				v4 = 0
			}
		} else {
			v4 = 50
		}
		Value := v4
		Result[Bar] = Value
	}
	return Result
}

func main() {
	SrcA := TSeries{1.0, 2.0, 3.0, 4.0, 5.0}
	LenA := TSeries{5.0, 5.0, 5.0, 5.0, 5.0}
	Result := JXRSXSeries(SrcA, LenA)
	fmt.Println(Result)
}
// above Pascal code has been translated to Golang. The `TSeries` type has been defined as a slice of `float64` in Golang. The `JXRSXSeries` function has been translated to Golang, using the appropriate Golang syntax and data types. The resulting Golang code can be executed to test the translated function.


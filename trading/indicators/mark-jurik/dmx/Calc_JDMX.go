package main

import (
	"fmt"
	"math"
)

type TSeries []float64

func JJMASeries(SrcA TSeries, ALength, APhase int) TSeries {
	// TODO: Implement JJMASeries function
	return nil
}

func TrueRangeSeries(CloseA, HighA, LowA TSeries) TSeries {
	Result := make(TSeries, len(CloseA))
	for Bar := 2; Bar < len(CloseA); Bar++ {
		m1 := math.Abs(HighA[Bar] - LowA[Bar])
		m2 := math.Abs(HighA[Bar] - CloseA[Bar-1])
		m3 := math.Abs(LowA[Bar] - CloseA[Bar-1])
		Result[Bar] = math.Max(math.Max(m1, m2), m3)
	}
	return Result
}

func JDMXplusSeries(SrcA, HighA, LowA TSeries, ALen int) TSeries {
	Result := make(TSeries, len(SrcA))
	upward := make(TSeries, len(SrcA))
	numer := make(TSeries, len(SrcA))
	denom := make(TSeries, len(SrcA))
	for Bar := 1; Bar < len(SrcA); Bar++ {
		v1 := 100 * (HighA[Bar] - HighA[Bar-1])
		v2 := 100 * (LowA[Bar-1] - LowA[Bar])
		if v1 > v2 && v1 > 0 {
			upward[Bar] = v1
		} else {
			upward[Bar] = 0
		}
	}
	numer = JJMASeries(upward, ALen, -100)
	denom = JJMASeries(TrueRangeSeries(SrcA, HighA, LowA), ALen, -100)
	for Bar := 0; Bar < len(SrcA); Bar++ {
		if denom[Bar] > 0.00001 && Bar > 40 {
			Result[Bar] = 100 * numer[Bar] / denom[Bar]
		} else {
			Result[Bar] = 0
		}
	}
	return Result
}

func JDMXminusSeries(SrcA, HighA, LowA TSeries, ALen int) TSeries {
	Result := make(TSeries, len(SrcA))
	downward := make(TSeries, len(SrcA))
	numer := make(TSeries, len(SrcA))
	denom := make(TSeries, len(SrcA))
	for Bar := 1; Bar < len(SrcA); Bar++ {
		v1 := 100 * (HighA[Bar] - HighA[Bar-1])
		v2 := 100 * (LowA[Bar-1] - LowA[Bar])
		if v2 > v1 && v2 > 0 {
			downward[Bar] = v2
		} else {
			downward[Bar] = 0
		}
	}
	numer = JJMASeries(downward, ALen, -100)
	denom = JJMASeries(TrueRangeSeries(SrcA, HighA, LowA), ALen, -100)
	for Bar := 0; Bar < len(SrcA); Bar++ {
		if denom[Bar] > 0.00001 && Bar > 40 {
			Result[Bar] = 100 * numer[Bar] / denom[Bar]
		} else {
			Result[Bar] = 0
		}
	}
	return Result
}

func JDMXSeries(SrcA, HighA, LowA TSeries, ALen int) TSeries {
	Result := make(TSeries, len(SrcA))
	DMXplus := JDMXplusSeries(SrcA, HighA, LowA, ALen)
	DMXminus := JDMXminusSeries(SrcA, HighA, LowA, ALen)
	for Bar := 0; Bar < len(SrcA); Bar++ {
		if DMXplus[Bar]+DMXminus[Bar] > 0.00001 {
			Result[Bar] = 100 * (DMXplus[Bar] - DMXminus[Bar]) / (DMXplus[Bar] + DMXminus[Bar])
		} else {
			Result[Bar] = 0
		}
	}
	return Result
}

func main() {
	// Test code
	SrcA := TSeries{1, 2, 3, 4, 5}
	HighA := TSeries{5, 4, 3, 2, 1}
	LowA := TSeries{0, 1, 2, 3, 4}
	ALen := 3

	JJMASeriesResult := JJMASeries(SrcA, ALen, 0)
	fmt.Println("JJMASeries:", JJMASeriesResult)

	TrueRangeSeriesResult := TrueRangeSeries(SrcA, HighA, LowA)
	fmt.Println("TrueRangeSeries:", TrueRangeSeriesResult)

	JDMXplusSeriesResult := JDMXplusSeries(SrcA, HighA, LowA, ALen)
	fmt.Println("JDMXplusSeries:", JDMXplusSeriesResult)

	JDMXminusSeriesResult := JDMXminusSeries(SrcA, HighA, LowA, ALen)
	fmt.Println("JDMXminusSeries:", JDMXminusSeriesResult)

	JDMXSeriesResult := JDMXSeries(SrcA, HighA, LowA, ALen)
	fmt.Println("JDMXSeries:", JDMXSeriesResult)
}



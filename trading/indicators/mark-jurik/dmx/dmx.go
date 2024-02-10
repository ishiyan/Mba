package main

import (
	"fmt"
	"math"
)

type TSeries []float64

// JDMX

func JJMASeries(SrcA TSeries, ALength, APhase int) TSeries {
	var Result TSeries
	Bar := 0
	k := 0
	Value := 0.0
	v := 0.0
	v1 := 0.0
	v2 := 0.0
	v3 := 0.0
	v4 := 0.0
	s8 := 0.0
	s10 := 0.0
	s18 := 0.0
	s20 := 0.0
	i := 0
	v5 := 0
	v6 := 0
	s28 := 0
	s30 := 0
	s38 := 0
	s40 := 0
	s48 := 0
	s50 := 0
	s58 := 0
	s60 := 0
	s68 := 0
	s70 := 0
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
	f88 := 0.0
	f90 := 0.0
	f98 := 0.0
	fA0 := 0.0
	fA8 := 0.0
	fB0 := 0.0
	fB8 := 0.0
	fC0 := 0.0
	fC8 := 0.0
	fD0 := 0.0
	f0 := 0
	fD8 := 0
	fE0 := 0
	fE8 := 0
	fF0 := 0
	fF8 := 0

	// these slices will be automatically filled with zeroes
	list := make([]float64, 128)
	ring := make([]float64, 128)
	ring2 := make([]float64, 11)
	buffer := make([]float64, 62)

	Result = make([]float64, len(SrcA))

	s28 = 63
	s30 = 64
	for i := 1; i <= s28; i++ {
		list[i] = -1000000.0
	}

	for i := s30; i <= 127; i++ {
		list[i] = 1000000.0
	}

	f0 = 1
	if ALength <= 1 {
		f80 = 1.0e-10
	} else {
		f80 = (float64(ALength) - 1) / 2
	}

	if APhase < -100 {
		f10 = 0.5
	} else if APhase > 100 {
		f10 = 2.5
	} else {
		f10 = float64(APhase)/100 + 1.5
	}

	v1 = math.Log(math.Sqrt(f80))
	v2 = v1
	if v1/math.Log(2.0)+2 < 0 {
		v3 = 0.0
	} else {
		v3 = v2/math.Log(2.0) + 2
	}

	f98 = v3
	if 0.5 <= f98-2 {
		f88 = f98 - 2
	} else {
		f88 = 0.5
	}

	f78 = math.Sqrt(f80) * f98
	f90 = f78 / (f78 + 1)
	f80 = f80 * 0.9
	f50 = f80 / (f80 + 2)
	for Bar = 0; Bar < len(SrcA); Bar++ {
		if fF0 < 61 {
			fF0 = fF0 + 1
			buffer[fF0] = SrcA[Bar]
		}

		if fF0 > 30 {
			if f0 != 0 {
				f0 = 0
				v5 = 0
				for i = 1; i <= 29; i++ {
					if buffer[i+1] != buffer[i] {
						v5 = 1
					}
				}

				fD8 = v5 * 30
				if fD8 == 0 {
					f38 = SrcA[Bar]
				} else {
					f38 = buffer[1]
				}

				f18 = f38
				if fD8 > 29 {
					fD8 = 29
				}

			} else {
				fD8 = 0
			}

			for i = fD8; i >= 0; i-- {
				if i == 0 {
					f8 = SrcA[Bar]
				} else {
					f8 = buffer[31-i]
				}

				f28 = f8 - f18
				f48 = f8 - f38
				if math.Abs(f28) > math.Abs(f48) {
					v2 = math.Abs(f28)
				} else {
					v2 = math.Abs(f48)
				}

				fA0 = v2
				v = fA0 + 1.0e-10
				if s48 <= 1 {
					s48 = 127
				} else {
					s48 = s48 - 1
				}

				if s50 <= 1 {
					s50 = 10
				} else {
					s50 = s50 - 1
				}

				if s70 < 128 {
					s70 = s70 + 1
				}

				s8 = s8 + v - ring2[s50]
				ring2[s50] = v
				if s70 > 10 {
					s20 = s8 / 10
				} else {
					s20 = s8 / float64(s70)
				}

				if s70 > 127 {
					s10 = ring[s48]
					ring[s48] = s20
					s68 = 64
					s58 = s68
					for s68 > 1 {
						if list[s58] < s10 {
							s68 = s68 / 2
							s58 = s58 + s68
						} else if list[s58] <= s10 {
							s68 = 1
						} else {
							s68 = s68 / 2
							s58 = s58 - s68
						}
					}
				} else {
					ring[s48] = s20
					if s28+s30 > 127 {
						s30 = s30 - 1
						s58 = s30
					} else {
						s28 = s28 + 1
						s58 = s28
					}
					if s28 > 96 {
						s38 = 96
					} else {
						s38 = s28
					}

					if s30 < 32 {
						s40 = 32
					} else {
						s40 = s30
					}
				}

				s68 = 64
				s60 = s68
				for s68 > 1 {
					if list[s60] >= s20 {
						if list[s60-1] <= s20 {
							s68 = 1
						} else {
							s68 = s68 / 2
							s60 = s60 - s68
						}
					} else {
						s68 = s68 / 2
						s60 = s60 + s68
					}

					if s60 == 127 && s20 > list[127] {
						s60 = 128
					}
				}

				if s70 > 127 {
					if s58 >= s60 {
						if s38+1 > s60 && s40-1 < s60 {
							s18 = s18 + s20
						} else if s40 > s60 && s40-1 < s58 {
							s18 = s18 + list[s40-1]
						}

					} else if s40 >= s60 {
						if s38+1 < s60 && s38+1 > s58 {
							s18 = s18 + list[s38+1]
						}
					} else if s38+2 > s60 {
						s18 = s18 + s20
					} else if s38+1 < s60 && s38+1 > s58 {
						s18 = s18 + list[s38+1]
					}

					if s58 > s60 {
						if s40-1 < s58 && s38+1 > s58 {
							s18 = s18 - list[s58]
						} else if s38 < s58 && s38+1 > s60 {
							s18 = s18 - list[s38]
						}
					} else {
						if s38+1 > s58 && s40-1 < s58 {
							s18 = s18 - list[s58]
						} else if s40 > s58 && s40 < s60 {
							s18 = s18 - list[s40]
						}
					}
				}

				if s58 <= s60 {
					if s58 >= s60 {
						list[s60] = s20
					} else {
						for k = s58 + 1; k <= s60-1; k++ {
							list[k-1] = list[k]
						}

						list[s60-1] = s20
					}
				} else {
					for k = s58 - 1; k >= s60; k-- {
						list[k+1] = list[k]
					}

					list[s60] = s20
				}

				if s70 <= 127 {
					s18 = 0
					for k = s40; k <= s38; k++ {
						s18 = s18 + list[k]
					}
				}

				f60 = s18 / float64(s38-s40+1)
				if fF8+1 > 31 {
					fF8 = 31
				} else {
					fF8 = fF8 + 1
				}

				if fF8 <= 30 {
					if f28 > 0 {
						f18 = f8
					} else {
						f18 = f8 - f28*f90
					}

					if f48 < 0 {
						f38 = f8
					} else {
						f38 = f8 - f48*f90
					}

					fB8 = SrcA[Bar]
					if fF8 != 30 {
						continue
					}

					fC0 = SrcA[Bar]
					if math.Ceil(f78) >= 1 {
						v4 = math.Ceil(f78)
					} else {
						v4 = 1
					}

					fE8 = int(v4)
					if math.Floor(f78) >= 1 {
						v2 = math.Floor(f78)
					} else {
						v2 = 1
					}

					fE0 = int(v2)
					if fE8 == fE0 {
						f68 = 1
					} else {
						v4 = float64(fE8 - fE0)
						f68 = (f78 - float64(fE0)) / v4
					}

					if fE0 <= 29 {
						v5 = fE0
					} else {
						v5 = 29
					}

					if fE8 <= 29 {
						v6 = fE8
					} else {
						v6 = 29
					}

					fA8 = (SrcA[Bar]-buffer[fF0-v5])*(1-f68)/float64(fE0) +
						(SrcA[Bar]-buffer[fF0-v6])*f68/float64(fE8)
				} else {
					if f98 >= math.Pow(fA0/f60, f88) {
						v1 = math.Pow(fA0/f60, f88)
					} else {
						v1 = f98
					}

					if v1 < 1 {
						v2 = 1.0
					} else {
						if f98 >= math.Pow(fA0/f60, f88) {
							v3 = math.Pow(fA0/f60, f88)
						} else {
							v3 = f98
						}

						v2 = v3
					}

					f58 = v2
					f70 = math.Pow(f90, math.Sqrt(f58))
					if f28 > 0 {
						f18 = f8
					} else {
						f18 = f8 - f28*f70
					}

					if f48 < 0 {
						f38 = f8
					} else {
						f38 = f8 - f48*f70
					}
				}
			}

			if fF8 > 30 {
				f30 = math.Pow(f50, f58)
				fC0 = (1-f30)*SrcA[Bar] + f30*fC0
				fC8 = (SrcA[Bar]-fC0)*(1-f50) + f50*fC8
				fD0 = f10*fC8 + fC0
				f20 = f30 * -2
				f40 = f30 * f30
				fB0 = f20 + f40 + 1
				fA8 = (fD0-fB8)*fB0 + f40*fA8
				fB8 = fB8 + fA8
			}
		}

		Value = fB8
		Result[Bar] = Value
	}

	return Result
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
			Result[Bar] = /* 100 * */ numer[Bar] / denom[Bar]
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
			Result[Bar] = /*100 * */ numer[Bar] / denom[Bar]
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
	SrcC := testInputC()
	SrcL := testInputL()
	SrcH := testInputH()

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=2) Bipolar")
	Result := JDMXSeries(SrcC, SrcH, SrcL, 2) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=2) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 2) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=2) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 2) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=3) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 3) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=3) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 3) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=3) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 3) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=4) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 4) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=4) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 4) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=4) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 4) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=5) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 5) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=5) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 5) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=5) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 5) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=6) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 6) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=6) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 6) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=6) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 6) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=7) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 7) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=7) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 7) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=7) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 7) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=8) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 8) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=8) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 8) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=8) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 8) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=9) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 9) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=9) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 9) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=9) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 9) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=10) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 10) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=10) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 10) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=10) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 10) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=11) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 11) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=11) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 11) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=11) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 11) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=12) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 12) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=12) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 12) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=12) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 12) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=13) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 13) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=13) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 13) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=13) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 13) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=14) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 14) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=14) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 14) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=14) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 1) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=15) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 15) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=15) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 15) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=15) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 15) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=16) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 16) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=16) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 16) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=16) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 16) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=17) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 17) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=17) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 17) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=17) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 17) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=18) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 18) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=18) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 18) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=18) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 18) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=19) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 19) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=19) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 19) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=19) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 19) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JDMXSeries(ALength=20) Bipolar")
	Result = JDMXSeries(SrcC, SrcH, SrcL, 20) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXplusSeries(ALength=20) Plus")
	Result = JDMXplusSeries(SrcC, SrcH, SrcL, 20) // SrcA, HighA, LowA, ALen
	testOutput(Result)
	fmt.Println("//------------------------------------------------")
	fmt.Println("// JDMXminusSeries(ALength=20) Minus")
	Result = JDMXminusSeries(SrcC, SrcH, SrcL, 20) // SrcA, HighA, LowA, ALen
	testOutput(Result)
}

func testInputC() TSeries {
	return TSeries{
		91.500000, 94.815000, 94.375000, 95.095000, 93.780000, 94.625000, 92.530000, 92.750000, 90.315000, 92.470000,
		96.125000, 97.250000, 98.500000, 89.875000, 91.000000, 92.815000, 89.155000, 89.345000, 91.625000, 89.875000,
		88.375000, 87.625000, 84.780000, 83.000000, 83.500000, 81.375000, 84.440000, 89.250000, 86.375000, 86.250000,
		85.250000, 87.125000, 85.815000, 88.970000, 88.470000, 86.875000, 86.815000, 84.875000, 84.190000, 83.875000,
		83.375000, 85.500000, 89.190000, 89.440000, 91.095000, 90.750000, 91.440000, 89.000000, 91.000000, 90.500000,
		89.030000, 88.815000, 84.280000, 83.500000, 82.690000, 84.750000, 85.655000, 86.190000, 88.940000, 89.280000,
		88.625000, 88.500000, 91.970000, 91.500000, 93.250000, 93.500000, 93.155000, 91.720000, 90.000000, 89.690000,
		88.875000, 85.190000, 83.375000, 84.875000, 85.940000, 97.250000, 99.875000, 104.940000, 106.000000, 102.500000,
		102.405000, 104.595000, 106.125000, 106.000000, 106.065000, 104.625000, 108.625000, 109.315000, 110.500000,
		112.750000, 123.000000, 119.625000, 118.750000, 119.250000, 117.940000, 116.440000, 115.190000, 111.875000,
		110.595000, 118.125000, 116.000000, 116.000000, 112.000000, 113.750000, 112.940000, 116.000000, 120.500000,
		116.620000, 117.000000, 115.250000, 114.310000, 115.500000, 115.870000, 120.690000, 120.190000, 120.750000,
		124.750000, 123.370000, 122.940000, 122.560000, 123.120000, 122.560000, 124.620000, 129.250000, 131.000000,
		132.250000, 131.000000, 132.810000, 134.000000, 137.380000, 137.810000, 137.880000, 137.250000, 136.310000,
		136.250000, 134.630000, 128.250000, 129.000000, 123.870000, 124.810000, 123.000000, 126.250000, 128.380000,
		125.370000, 125.690000, 122.250000, 119.370000, 118.500000, 123.190000, 123.500000, 122.190000, 119.310000,
		123.310000, 121.120000, 123.370000, 127.370000, 128.500000, 123.870000, 122.940000, 121.750000, 124.440000,
		122.000000, 122.370000, 122.940000, 124.000000, 123.190000, 124.560000, 127.250000, 125.870000, 128.860000,
		132.000000, 130.750000, 134.750000, 135.000000, 132.380000, 133.310000, 131.940000, 130.000000, 125.370000,
		130.130000, 127.120000, 125.190000, 122.000000, 125.000000, 123.000000, 123.500000, 120.060000, 121.000000,
		117.750000, 119.870000, 122.000000, 119.190000, 116.370000, 113.500000, 114.250000, 110.000000, 105.060000,
		107.000000, 107.870000, 107.000000, 107.120000, 107.000000, 91.000000, 93.940000, 93.870000, 95.500000, 93.000000,
		94.940000, 98.250000, 96.750000, 94.810000, 94.370000, 91.560000, 90.250000, 93.940000, 93.620000, 97.000000,
		95.000000, 95.870000, 94.060000, 94.620000, 93.750000, 98.000000, 103.940000, 107.870000, 106.060000, 104.500000,
		105.000000, 104.190000, 103.060000, 103.420000, 105.270000, 111.870000, 116.000000, 116.620000, 118.280000,
		113.370000, 109.000000, 109.700000, 109.250000, 107.000000, 109.190000, 110.000000, 109.200000, 110.120000,
		108.000000, 108.620000, 109.750000, 109.810000, 109.000000, 108.750000, 107.870000,
	}
}

func testInputL() TSeries {
	return TSeries{
		90.75,
		91.405,
		94.25,
		93.5,
		92.815,
		93.5,
		92,
		89.75,
		89.44,
		90.625,
		92.75,
		96.315,
		96.03,
		88.815,
		86.75,
		90.94,
		88.905,
		88.78,
		89.25,
		89.75,
		87.5,
		86.53,
		84.625,
		82.28,
		81.565,
		80.875,
		81.25,
		84.065,
		85.595,
		85.97,
		84.405,
		85.095,
		85.5,
		85.53,
		87.875,
		86.565,
		84.655,
		83.25,
		82.565,
		83.44,
		82.53,
		85.065,
		86.875,
		88.53,
		89.28,
		90.125,
		90.75,
		89,
		88.565,
		90.095,
		89,
		86.47,
		84,
		83.315,
		82,
		83.25,
		84.75,
		85.28,
		87.19,
		88.44,
		88.25,
		87.345,
		89.28,
		91.095,
		89.53,
		91.155,
		92,
		90.53,
		89.97,
		88.815,
		86.75,
		85.065,
		82.03,
		81.5,
		82.565,
		96.345,
		96.47,
		101.155,
		104.25,
		101.75,
		101.72,
		101.72,
		103.155,
		105.69,
		103.655,
		104,
		105.53,
		108.53,
		108.75,
		107.75,
		117,
		118,
		116,
		118.5,
		116.53,
		116.25,
		114.595,
		110.875,
		110.5,
		110.72,
		112.62,
		114.19,
		111.19,
		109.44,
		111.56,
		112.44,
		117.5,
		116.06,
		116.56,
		113.31,
		112.56,
		114,
		114.75,
		118.87,
		119,
		119.75,
		122.62,
		123,
		121.75,
		121.56,
		123.12,
		122.19,
		122.75,
		124.37,
		128,
		129.5,
		130.81,
		130.63,
		132.13,
		133.88,
		135.38,
		135.75,
		136.19,
		134.5,
		135.38,
		133.69,
		126.06,
		126.87,
		123.5,
		122.62,
		122.75,
		123.56,
		125.81,
		124.62,
		124.37,
		121.81,
		118.19,
		118.06,
		117.56,
		121,
		121.12,
		118.94,
		119.81,
		121,
		122,
		124.5,
		126.56,
		123.5,
		121.25,
		121.06,
		122.31,
		121,
		120.87,
		122.06,
		122.75,
		122.69,
		122.87,
		125.5,
		124.25,
		128,
		128.38,
		130.69,
		131.63,
		134.38,
		132,
		131.94,
		131.94,
		129.56,
		123.75,
		126,
		126.25,
		124.37,
		121.44,
		120.44,
		121.37,
		121.69,
		120,
		119.62,
		115.5,
		116.75,
		119.06,
		119.06,
		115.06,
		111.06,
		113.12,
		110,
		105,
		104.69,
		103.87,
		104.69,
		105.44,
		107,
		89,
		92.5,
		92.12,
		94.62,
		92.81,
		94.25,
		96.25,
		96.37,
		93.69,
		93.5,
		90,
		90.19,
		90.5,
		92.12,
		94.12,
		94.87,
		93,
		93.87,
		93,
		92.62,
		93.56,
		98.37,
		104.44,
		106,
		101.81,
		104.12,
		103.37,
		102.12,
		102.25,
		103.37,
		107.94,
		112.5,
		115.44,
		115.5,
		112.25,
		107.56,
		106.56,
		106.87,
		104.5,
		105.75,
		108.62,
		107.75,
		108.06,
		108,
		108.19,
		108.12,
		109.06,
		108.75,
		108.56,
		106.62,
	}
}

func testInputH() TSeries {
	return TSeries{
		93.25,
		94.94,
		96.375,
		96.19,
		96,
		94.72,
		95,
		93.72,
		92.47,
		92.75,
		96.25,
		99.625,
		99.125,
		92.75,
		91.315,
		93.25,
		93.405,
		90.655,
		91.97,
		92.25,
		90.345,
		88.5,
		88.25,
		85.5,
		84.44,
		84.75,
		84.44,
		89.405,
		88.125,
		89.125,
		87.155,
		87.25,
		87.375,
		88.97,
		90,
		89.845,
		86.97,
		85.94,
		84.75,
		85.47,
		84.47,
		88.5,
		89.47,
		90,
		92.44,
		91.44,
		92.97,
		91.72,
		91.155,
		91.75,
		90,
		88.875,
		89,
		85.25,
		83.815,
		85.25,
		86.625,
		87.94,
		89.375,
		90.625,
		90.75,
		88.845,
		91.97,
		93.375,
		93.815,
		94.03,
		94.03,
		91.815,
		92,
		91.94,
		89.75,
		88.75,
		86.155,
		84.875,
		85.94,
		99.375,
		103.28,
		105.375,
		107.625,
		105.25,
		104.5,
		105.5,
		106.125,
		107.94,
		106.25,
		107,
		108.75,
		110.94,
		110.94,
		114.22,
		123,
		121.75,
		119.815,
		120.315,
		119.375,
		118.19,
		116.69,
		115.345,
		113,
		118.315,
		116.87,
		116.75,
		113.87,
		114.62,
		115.31,
		116,
		121.69,
		119.87,
		120.87,
		116.75,
		116.5,
		116,
		118.31,
		121.5,
		122,
		121.44,
		125.75,
		127.75,
		124.19,
		124.44,
		125.75,
		124.69,
		125.31,
		132,
		131.31,
		132.25,
		133.88,
		133.5,
		135.5,
		137.44,
		138.69,
		139.19,
		138.5,
		138.13,
		137.5,
		138.88,
		132.13,
		129.75,
		128.5,
		125.44,
		125.12,
		126.5,
		128.69,
		126.62,
		126.69,
		126,
		123.12,
		121.87,
		124,
		127,
		124.44,
		122.5,
		123.75,
		123.81,
		124.5,
		127.87,
		128.56,
		129.63,
		124.87,
		124.37,
		124.87,
		123.62,
		124.06,
		125.87,
		125.19,
		125.62,
		126,
		128.5,
		126.75,
		129.75,
		132.69,
		133.94,
		136.5,
		137.69,
		135.56,
		133.56,
		135,
		132.38,
		131.44,
		130.88,
		129.63,
		127.25,
		127.81,
		125,
		126.81,
		124.75,
		122.81,
		122.25,
		121.06,
		120,
		123.25,
		122.75,
		119.19,
		115.06,
		116.69,
		114.87,
		110.87,
		107.25,
		108.87,
		109,
		108.5,
		113.06,
		93,
		94.62,
		95.12,
		96,
		95.56,
		95.31,
		99,
		98.81,
		96.81,
		95.94,
		94.44,
		92.94,
		93.94,
		95.5,
		97.06,
		97.5,
		96.25,
		96.37,
		95,
		94.87,
		98.25,
		105.12,
		108.44,
		109.87,
		105,
		106,
		104.94,
		104.5,
		104.44,
		106.31,
		112.87,
		116.5,
		119.19,
		121,
		122.12,
		111.94,
		112.75,
		110.19,
		107.94,
		109.69,
		111.06,
		110.44,
		110.12,
		110.31,
		110.44,
		110,
		110.75,
		110.5,
		110.5,
		109.5,
	}
}

func testOutput(arr TSeries) {
	i0 := 0
	fmt.Print("[]float64 {")
	for i := 0; i < 42; i++ {
		for j := 0; j < 6; j++ {
			fmt.Printf(" %.15f,", arr[i0+j])
		}

		i0 += 6
		fmt.Println("")
	}

	fmt.Println("}")
}

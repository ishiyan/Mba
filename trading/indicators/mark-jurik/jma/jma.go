package main

import (
	"fmt"
	"math"
)

type TSeries []float64

// JMA

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

func main() {
	SrcA := testInput()

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=20, APhase=-100)")
	Result := JJMASeries(SrcA, 20, -100) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=20, APhase=-30)")
	Result = JJMASeries(SrcA, 20, -30) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=20, APhase=0)")
	Result = JJMASeries(SrcA, 20, 0) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=20, APhase=30)")
	Result = JJMASeries(SrcA, 20, 30) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=20, APhase=100)")
	Result = JJMASeries(SrcA, 20, 100) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=2, APhase=1)")
	Result = JJMASeries(SrcA, 2, 1) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=5, APhase=1)")
	Result = JJMASeries(SrcA, 5, 1) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=10, APhase=1)")
	Result = JJMASeries(SrcA, 10, 1) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=25, APhase=1)")
	Result = JJMASeries(SrcA, 25, 1) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=50, APhase=1)")
	Result = JJMASeries(SrcA, 50, 1) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=75, APhase=1)")
	Result = JJMASeries(SrcA, 75, 1) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JJMASeries(test_input, ALength=100, APhase=1)")
	Result = JJMASeries(SrcA, 100, 1) // SrcA, ALength, APhase
	testOutput(Result)
}

func testInput() TSeries {
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

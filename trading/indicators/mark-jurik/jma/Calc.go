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

// FCB

func JCFBaux(SrcA TSeries, Depth int) TSeries {
	var Result TSeries
	Bar := 0
	Value := 0.0
	jrc04, jrc05, jrc06, jrc08 := 0.0, 0.0, 0.0, 0.0
	jrc07 := 0
	IntA := make(TSeries, len(SrcA))

	Result = make(TSeries, len(SrcA))
	jrc04 = 0
	jrc05 = 0
	jrc06 = 0
	jrc08 = 0
	jrc07 = 0
	IntA = make(TSeries, len(SrcA))

	for Bar = 1; Bar < len(SrcA); Bar++ {
		IntA[Bar] = math.Abs(SrcA[Bar] - SrcA[Bar-1])
	}

	for Bar = Depth; Bar < len(SrcA)-1; Bar++ {
		if Bar <= Depth*2 {
			jrc04 = 0
			jrc05 = 0
			jrc06 = 0
			for jrc07 = 0; jrc07 < Depth; jrc07++ {
				jrc04 = jrc04 + math.Abs(SrcA[Bar-jrc07]-SrcA[Bar-jrc07-1])
				jrc05 = jrc05 + float64(Depth-jrc07)*math.Abs(SrcA[Bar-jrc07]-SrcA[Bar-jrc07-1])
				jrc06 = jrc06 + SrcA[Bar-jrc07-1]
			}
		} else {
			jrc05 = jrc05 - jrc04 + IntA[Bar]*float64(Depth)
			jrc04 = jrc04 - IntA[Bar-Depth] + IntA[Bar]
			jrc06 = jrc06 - SrcA[Bar-Depth-1] + SrcA[Bar-1]
		}
		jrc08 = math.Abs(float64(Depth)*SrcA[Bar] - jrc06)
		if jrc05 == 0 {
			Value = 0
		} else {
			Value = jrc08 / jrc05
		}
		Result[Bar] = Value
	}
	return Result
}

func JCFB24(SrcA TSeries, Smooth int) TSeries {
	var Result TSeries
	Bar := 0

	// Value := 0.0
	er1, er2, er3, er4, er5, er6, er7, er8 := make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA))
	er20, er21, er29 := 0, 0, 0
	er15, er16, er17, er18, er19 := 0.0, 0.0, 0.0, 0.0, 0.0
	er22, er23 := [8]float64{}, [8]float64{}

	Result = make(TSeries, len(SrcA))
	er20 = 0
	er21 = 0
	er29 = 0
	er15 = 0
	er16 = 0
	er17 = 0
	er18 = 0
	er19 = 0
	er15 = 1
	er16 = 1
	er19 = 20
	er29 = Smooth
	er1 = JCFBaux(SrcA, 2)
	er2 = JCFBaux(SrcA, 3)
	er3 = JCFBaux(SrcA, 4)
	er4 = JCFBaux(SrcA, 6)
	er5 = JCFBaux(SrcA, 8)
	er6 = JCFBaux(SrcA, 12)
	er7 = JCFBaux(SrcA, 16)
	er8 = JCFBaux(SrcA, 24)

	for Bar = 1; Bar < len(SrcA); Bar++ {
		if Bar <= er29 {
			for er21 = 0; er21 < 8; er21++ {
				er23[er21] = 0
			}

			for er20 = 0; er20 < Bar; er20++ {
				er23[0] = er23[0] + er1[Bar-er20]
				er23[1] = er23[1] + er2[Bar-er20]
				er23[2] = er23[2] + er3[Bar-er20]
				er23[3] = er23[3] + er4[Bar-er20]
				er23[4] = er23[4] + er5[Bar-er20]
				er23[5] = er23[5] + er6[Bar-er20]
				er23[6] = er23[6] + er7[Bar-er20]
				er23[7] = er23[7] + er8[Bar-er20]
			}

			for er21 = 0; er21 < 8; er21++ {
				er23[er21] = er23[er21] / float64(Bar)
			}
		} else {
			er23[0] = er23[0] + (er1[Bar]-er1[Bar-er29])/float64(er29)
			er23[1] = er23[1] + (er2[Bar]-er2[Bar-er29])/float64(er29)
			er23[2] = er23[2] + (er3[Bar]-er3[Bar-er29])/float64(er29)
			er23[3] = er23[3] + (er4[Bar]-er4[Bar-er29])/float64(er29)
			er23[4] = er23[4] + (er5[Bar]-er5[Bar-er29])/float64(er29)
			er23[5] = er23[5] + (er6[Bar]-er6[Bar-er29])/float64(er29)
			er23[6] = er23[6] + (er7[Bar]-er7[Bar-er29])/float64(er29)
			er23[7] = er23[7] + (er8[Bar]-er8[Bar-er29])/float64(er29)
		}

		if Bar > 5 {
			er15 = 1
			er22[7] = er15 * er23[7]
			er15 = er15 * (1 - er22[7])
			er22[5] = er15 * er23[5]
			er15 = er15 * (1 - er22[5])
			er22[3] = er15 * er23[3]
			er15 = er15 * (1 - er22[3])
			er22[1] = er15 * er23[1]
			er16 = 1
			er22[6] = er16 * er23[6]
			er16 = er16 * (1 - er22[6])
			er22[4] = er16 * er23[4]
			er16 = er16 * (1 - er22[4])
			er22[2] = er16 * er23[2]
			er16 = er16 * (1 - er22[2])
			er22[0] = er16 * er23[0]
			er17 = er22[0]*er22[0]*2 + er22[2]*er22[2]*3 + er22[4]*er22[4]*6 + er22[6]*er22[6]*12 + er22[1]*er22[1]*4 + er22[3]*er22[3]*8 + er22[5]*er22[5]*16 + er22[7]*er22[7]*32
			er18 = er22[0]*er22[0] + er22[2]*er22[2] + er22[4]*er22[4] + er22[6]*er22[6] + er22[1]*er22[1] + er22[3]*er22[3] + er22[5]*er22[5] + er22[7]*er22[7]

			if er18 == 0 {
				er19 = 0
			} else {
				er19 = er17 / er18
			}
		}

		Result[Bar] = er19
	}

	return Result
}

func JCFB48(SrcA TSeries, Smooth int) TSeries {
	var Result TSeries
	Bar := 0

	// Value := 0.0
	er1, er2, er3, er4, er5, er6, er7, er8, er9, er10 := make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA))
	er20, er21, er29 := 0, 0, 0
	er15, er16, er17, er18, er19 := 0.0, 0.0, 0.0, 0.0, 0.0
	er22, er23 := [10]float64{}, [10]float64{}

	Result = make(TSeries, len(SrcA))
	er20 = 0
	er21 = 0
	er29 = 0
	er15 = 0
	er16 = 0
	er17 = 0
	er18 = 0
	er19 = 0
	er15 = 1
	er16 = 1
	er19 = 20
	er29 = Smooth
	er1 = JCFBaux(SrcA, 2)
	er2 = JCFBaux(SrcA, 3)
	er3 = JCFBaux(SrcA, 4)
	er4 = JCFBaux(SrcA, 6)
	er5 = JCFBaux(SrcA, 8)
	er6 = JCFBaux(SrcA, 12)
	er7 = JCFBaux(SrcA, 16)
	er8 = JCFBaux(SrcA, 24)
	er9 = JCFBaux(SrcA, 32)
	er10 = JCFBaux(SrcA, 48)

	for Bar = 1; Bar < len(SrcA); Bar++ {
		if Bar <= er29 {
			for er21 = 0; er21 < 10; er21++ {
				er23[er21] = 0
			}

			for er20 = 0; er20 < Bar; er20++ {
				er23[0] = er23[0] + er1[Bar-er20]
				er23[1] = er23[1] + er2[Bar-er20]
				er23[2] = er23[2] + er3[Bar-er20]
				er23[3] = er23[3] + er4[Bar-er20]
				er23[4] = er23[4] + er5[Bar-er20]
				er23[5] = er23[5] + er6[Bar-er20]
				er23[6] = er23[6] + er7[Bar-er20]
				er23[7] = er23[7] + er8[Bar-er20]
				er23[8] = er23[8] + er9[Bar-er20]
				er23[9] = er23[9] + er10[Bar-er20]
			}

			for er21 = 0; er21 < 10; er21++ {
				er23[er21] = er23[er21] / float64(Bar)
			}
		} else {
			er23[0] = er23[0] + (er1[Bar]-er1[Bar-er29])/float64(er29)
			er23[1] = er23[1] + (er2[Bar]-er2[Bar-er29])/float64(er29)
			er23[2] = er23[2] + (er3[Bar]-er3[Bar-er29])/float64(er29)
			er23[3] = er23[3] + (er4[Bar]-er4[Bar-er29])/float64(er29)
			er23[4] = er23[4] + (er5[Bar]-er5[Bar-er29])/float64(er29)
			er23[5] = er23[5] + (er6[Bar]-er6[Bar-er29])/float64(er29)
			er23[6] = er23[6] + (er7[Bar]-er7[Bar-er29])/float64(er29)
			er23[7] = er23[7] + (er8[Bar]-er8[Bar-er29])/float64(er29)
			er23[8] = er23[8] + (er9[Bar]-er9[Bar-er29])/float64(er29)
			er23[9] = er23[9] + (er10[Bar]-er10[Bar-er29])/float64(er29)
		}
		if Bar > 5 {
			er15 = 1
			er22[9] = er15 * er23[9]
			er15 = er15 * (1 - er22[9])
			er22[7] = er15 * er23[7]
			er15 = er15 * (1 - er22[7])
			er22[5] = er15 * er23[5]
			er15 = er15 * (1 - er22[5])
			er22[3] = er15 * er23[3]
			er15 = er15 * (1 - er22[3])
			er22[1] = er15 * er23[1]
			er16 = 1
			er22[8] = er16 * er23[8]
			er16 = er16 * (1 - er22[8])
			er22[6] = er16 * er23[6]
			er16 = er16 * (1 - er22[6])
			er22[4] = er16 * er23[4]
			er16 = er16 * (1 - er22[4])
			er22[2] = er16 * er23[2]
			er16 = er16 * (1 - er22[2])
			er22[0] = er16 * er23[0]
			er17 = er22[0]*er22[0]*2 + er22[2]*er22[2]*3 + er22[4]*er22[4]*6 + er22[6]*er22[6]*12 + er22[8]*er22[8]*24 + er22[1]*er22[1]*4 + er22[3]*er22[3]*8 + er22[5]*er22[5]*16 + er22[7]*er22[7]*32 + er22[9]*er22[9]*64
			er18 = er22[0]*er22[0] + er22[2]*er22[2] + er22[4]*er22[4] + er22[6]*er22[6] + er22[8]*er22[8] + er22[1]*er22[1] + er22[3]*er22[3] + er22[5]*er22[5] + er22[7]*er22[7] + er22[9]*er22[9]

			if er18 == 0 {
				er19 = 0
			} else {
				er19 = er17 / er18
			}
		}

		Result[Bar] = er19
	}

	return Result
}

func JCFB96(SrcA TSeries, Smooth int) TSeries {
	var Result TSeries
	Bar := 0

	// Value := 0.0
	er1, er2, er3, er4, er5, er6, er7, er8, er9, er10, er11, er12 := make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA))
	er20, er21, er29 := 0, 0, 0
	er15, er16, er17, er18, er19 := 0.0, 0.0, 0.0, 0.0, 0.0
	er22, er23 := [12]float64{}, [12]float64{}

	Result = make(TSeries, len(SrcA))
	er20 = 0
	er21 = 0
	er29 = 0
	er15 = 0
	er16 = 0
	er17 = 0
	er18 = 0
	er19 = 0
	er15 = 1
	er16 = 1
	er19 = 20
	er29 = Smooth
	er1 = JCFBaux(SrcA, 2)
	er2 = JCFBaux(SrcA, 3)
	er3 = JCFBaux(SrcA, 4)
	er4 = JCFBaux(SrcA, 6)
	er5 = JCFBaux(SrcA, 8)
	er6 = JCFBaux(SrcA, 12)
	er7 = JCFBaux(SrcA, 16)
	er8 = JCFBaux(SrcA, 24)
	er9 = JCFBaux(SrcA, 32)
	er10 = JCFBaux(SrcA, 48)
	er11 = JCFBaux(SrcA, 64)
	er12 = JCFBaux(SrcA, 96)

	for Bar = 1; Bar < len(SrcA); Bar++ {
		if Bar <= er29 {
			for er21 = 0; er21 < 12; er21++ {
				er23[er21] = 0
			}

			for er20 = 0; er20 < Bar; er20++ {
				er23[0] = er23[0] + er1[Bar-er20]
				er23[1] = er23[1] + er2[Bar-er20]
				er23[2] = er23[2] + er3[Bar-er20]
				er23[3] = er23[3] + er4[Bar-er20]
				er23[4] = er23[4] + er5[Bar-er20]
				er23[5] = er23[5] + er6[Bar-er20]
				er23[6] = er23[6] + er7[Bar-er20]
				er23[7] = er23[7] + er8[Bar-er20]
				er23[8] = er23[8] + er9[Bar-er20]
				er23[9] = er23[9] + er10[Bar-er20]
				er23[10] = er23[10] + er11[Bar-er20]
				er23[11] = er23[11] + er12[Bar-er20]
			}

			for er21 = 0; er21 < 12; er21++ {
				er23[er21] = er23[er21] / float64(Bar)
			}
		} else {
			er23[0] = er23[0] + (er1[Bar]-er1[Bar-er29])/float64(er29)
			er23[1] = er23[1] + (er2[Bar]-er2[Bar-er29])/float64(er29)
			er23[2] = er23[2] + (er3[Bar]-er3[Bar-er29])/float64(er29)
			er23[3] = er23[3] + (er4[Bar]-er4[Bar-er29])/float64(er29)
			er23[4] = er23[4] + (er5[Bar]-er5[Bar-er29])/float64(er29)
			er23[5] = er23[5] + (er6[Bar]-er6[Bar-er29])/float64(er29)
			er23[6] = er23[6] + (er7[Bar]-er7[Bar-er29])/float64(er29)
			er23[7] = er23[7] + (er8[Bar]-er8[Bar-er29])/float64(er29)
			er23[8] = er23[8] + (er9[Bar]-er9[Bar-er29])/float64(er29)
			er23[9] = er23[9] + (er10[Bar]-er10[Bar-er29])/float64(er29)
			er23[10] = er23[10] + (er11[Bar]-er11[Bar-er29])/float64(er29)
			er23[11] = er23[11] + (er12[Bar]-er12[Bar-er29])/float64(er29)
		}

		if Bar > 5 {
			er15 = 1
			er22[11] = er15 * er23[11]
			er15 = er15 * (1 - er22[11])
			er22[9] = er15 * er23[9]
			er15 = er15 * (1 - er22[9])
			er22[7] = er15 * er23[7]
			er15 = er15 * (1 - er22[7])
			er22[5] = er15 * er23[5]
			er15 = er15 * (1 - er22[5])
			er22[3] = er15 * er23[3]
			er15 = er15 * (1 - er22[3])
			er22[1] = er15 * er23[1]
			er16 = 1
			er22[10] = er16 * er23[10]
			er16 = er16 * (1 - er22[10])
			er22[8] = er16 * er23[8]
			er16 = er16 * (1 - er22[8])
			er22[6] = er16 * er23[6]
			er16 = er16 * (1 - er22[6])
			er22[4] = er16 * er23[4]
			er16 = er16 * (1 - er22[4])
			er22[2] = er16 * er23[2]
			er16 = er16 * (1 - er22[2])
			er22[0] = er16 * er23[0]
			er17 = er22[0]*er22[0]*2 + er22[2]*er22[2]*3 + er22[4]*er22[4]*6 + er22[6]*er22[6]*12 + er22[8]*er22[8]*24 + er22[10]*er22[10]*48 + er22[1]*er22[1]*4 + er22[3]*er22[3]*8 + er22[5]*er22[5]*16 + er22[7]*er22[7]*32 + er22[9]*er22[9]*64 + er22[11]*er22[11]*128
			er18 = er22[0]*er22[0] + er22[2]*er22[2] + er22[4]*er22[4] + er22[6]*er22[6] + er22[8]*er22[8] + er22[10]*er22[10] + er22[1]*er22[1] + er22[3]*er22[3] + er22[5]*er22[5] + er22[7]*er22[7] + er22[9]*er22[9] + er22[11]*er22[11]

			if er18 == 0 {
				er19 = 0
			} else {
				er19 = er17 / er18
			}
		}

		Result[Bar] = er19
	}

	return Result
}

func JCFB192(SrcA TSeries, Smooth int) TSeries {
	var Result TSeries
	Bar := 0

	// Value := 0.0
	er1, er2, er3, er4, er5, er6, er7, er8, er9, er10, er11, er12, er13, er14 := make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA)), make(TSeries, len(SrcA))
	er20, er21, er29 := 0, 0, 0
	er15, er16, er17, er18, er19 := 0.0, 0.0, 0.0, 0.0, 0.0
	er22, er23 := [14]float64{}, [14]float64{}

	Result = make(TSeries, len(SrcA))
	er20 = 0
	er21 = 0
	er29 = 0
	er15 = 0
	er16 = 0
	er17 = 0
	er18 = 0
	er19 = 0
	er15 = 1
	er16 = 1
	er19 = 20
	er29 = Smooth
	er1 = JCFBaux(SrcA, 2)
	er2 = JCFBaux(SrcA, 3)
	er3 = JCFBaux(SrcA, 4)
	er4 = JCFBaux(SrcA, 6)
	er5 = JCFBaux(SrcA, 8)
	er6 = JCFBaux(SrcA, 12)
	er7 = JCFBaux(SrcA, 16)
	er8 = JCFBaux(SrcA, 24)
	er9 = JCFBaux(SrcA, 32)
	er10 = JCFBaux(SrcA, 48)
	er11 = JCFBaux(SrcA, 64)
	er12 = JCFBaux(SrcA, 96)
	er13 = JCFBaux(SrcA, 128)
	er14 = JCFBaux(SrcA, 192)

	for Bar = 1; Bar < len(SrcA); Bar++ {
		if Bar <= er29 {
			for er21 = 0; er21 < 14; er21++ {
				er23[er21] = 0
			}

			for er20 = 0; er20 < Bar; er20++ {
				er23[0] = er23[0] + er1[Bar-er20]
				er23[1] = er23[1] + er2[Bar-er20]
				er23[2] = er23[2] + er3[Bar-er20]
				er23[3] = er23[3] + er4[Bar-er20]
				er23[4] = er23[4] + er5[Bar-er20]
				er23[5] = er23[5] + er6[Bar-er20]
				er23[6] = er23[6] + er7[Bar-er20]
				er23[7] = er23[7] + er8[Bar-er20]
				er23[8] = er23[8] + er9[Bar-er20]
				er23[9] = er23[9] + er10[Bar-er20]
				er23[10] = er23[10] + er11[Bar-er20]
				er23[11] = er23[11] + er12[Bar-er20]
				er23[12] = er23[12] + er13[Bar-er20]
				er23[13] = er23[13] + er14[Bar-er20]
			}

			for er21 = 0; er21 < 14; er21++ {
				er23[er21] = er23[er21] / float64(Bar)
			}
		} else {
			er23[0] = er23[0] + (er1[Bar]-er1[Bar-er29])/float64(er29)
			er23[1] = er23[1] + (er2[Bar]-er2[Bar-er29])/float64(er29)
			er23[2] = er23[2] + (er3[Bar]-er3[Bar-er29])/float64(er29)
			er23[3] = er23[3] + (er4[Bar]-er4[Bar-er29])/float64(er29)
			er23[4] = er23[4] + (er5[Bar]-er5[Bar-er29])/float64(er29)
			er23[5] = er23[5] + (er6[Bar]-er6[Bar-er29])/float64(er29)
			er23[6] = er23[6] + (er7[Bar]-er7[Bar-er29])/float64(er29)
			er23[7] = er23[7] + (er8[Bar]-er8[Bar-er29])/float64(er29)
			er23[8] = er23[8] + (er9[Bar]-er9[Bar-er29])/float64(er29)
			er23[9] = er23[9] + (er10[Bar]-er10[Bar-er29])/float64(er29)
			er23[10] = er23[10] + (er11[Bar]-er11[Bar-er29])/float64(er29)
			er23[11] = er23[11] + (er12[Bar]-er12[Bar-er29])/float64(er29)
			er23[12] = er23[12] + (er13[Bar]-er13[Bar-er29])/float64(er29)
			er23[13] = er23[13] + (er14[Bar]-er14[Bar-er29])/float64(er29)
		}

		if Bar > 5 {
			er15 = 1
			er22[13] = er15 * er23[13]
			er15 = er15 * (1 - er22[13])
			er22[11] = er15 * er23[11]
			er15 = er15 * (1 - er22[11])
			er22[9] = er15 * er23[9]
			er15 = er15 * (1 - er22[9])
			er22[7] = er15 * er23[7]
			er15 = er15 * (1 - er22[7])
			er22[5] = er15 * er23[5]
			er15 = er15 * (1 - er22[5])
			er22[3] = er15 * er23[3]
			er15 = er15 * (1 - er22[3])
			er22[1] = er15 * er23[1]
			er16 = 1
			er22[12] = er16 * er23[12]
			er16 = er16 * (1 - er22[12])
			er22[10] = er16 * er23[10]
			er16 = er16 * (1 - er22[10])
			er22[8] = er16 * er23[8]
			er16 = er16 * (1 - er22[8])
			er22[6] = er16 * er23[6]
			er16 = er16 * (1 - er22[6])
			er22[4] = er16 * er23[4]
			er16 = er16 * (1 - er22[4])
			er22[2] = er16 * er23[2]
			er16 = er16 * (1 - er22[2])
			er22[0] = er16 * er23[0]
			er17 = er22[0]*er22[0]*2 + er22[2]*er22[2]*3 + er22[4]*er22[4]*6 + er22[6]*er22[6]*12 + er22[8]*er22[8]*24 + er22[10]*er22[10]*48 + er22[12]*er22[12]*96 + er22[1]*er22[1]*4 + er22[3]*er22[3]*8 + er22[5]*er22[5]*16 + er22[7]*er22[7]*32 + er22[9]*er22[9]*64 + er22[11]*er22[11]*128 + er22[13]*er22[13]*256
			er18 = er22[0]*er22[0] + er22[2]*er22[2] + er22[4]*er22[4] + er22[6]*er22[6] + er22[8]*er22[8] + er22[10]*er22[10] + er22[12]*er22[12] + er22[1]*er22[1] + er22[3]*er22[3] + er22[5]*er22[5] + er22[7]*er22[7] + er22[9]*er22[9] + er22[11]*er22[11] + er22[13]*er22[13]

			if er18 == 0 {
				er19 = 0
			} else {
				er19 = er17 / er18
			}
		}

		Result[Bar] = er19
	}

	return Result
}

func JCFBSeries(SrcA TSeries, AFractalType int, ASmooth int) TSeries {
	var Result TSeries

	// Bar := 0

	Result = make(TSeries, len(SrcA))
	switch AFractalType {
	case 1:
		Result = JCFB24(SrcA, ASmooth)
	case 2:
		Result = JCFB48(SrcA, ASmooth)
	case 3:
		Result = JCFB96(SrcA, ASmooth)
	case 4:
		Result = JCFB192(SrcA, ASmooth)
	}

	return Result
}

// DMX

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

// RSX

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
			f58 = f20*f58 + f18*math.Abs(v8)
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

// XVEL

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

		jrc05 = float64(jrc04 * (jrc04 + 1) / 2)
		jrc06 = float64(jrc05 * float64(2*jrc04+1) / 3)
		jrc07 = jrc05*jrc05*jrc05 - jrc06*jrc06
		jrc08 = 0.0
		jrc09 = 0.0

		for jrc10 = 0; jrc10 <= jrc02; jrc10++ {
			jrc08 += SrcA[Bar-jrc10] * float64(jrc04-jrc10)
			jrc09 += SrcA[Bar-jrc10] * float64(jrc04-jrc10) * float64(jrc04-jrc10)
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
	jrc10 := 0.0
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

		if jrc27 < jrc26+jrc01 {
			jrc20 = input1
		} else {
			jrc03 = math.Min(500, math.Max(float64(jrc02), Period))
			jrc07 = int(math.Min(float64(jrc01), math.Ceil(jrc03)))
			jrc04 = 0.86 - 0.55/math.Sqrt(jrc03)
			jrc05 = 1 - math.Exp(-math.Log(4)/jrc03/2)
			jrc06 = int(math.Trunc(math.Max(float64(jrc01+1), math.Ceil(2*jrc03))))
			jrc11 = int(math.Trunc(math.Min(float64(jrc27-jrc26+1), float64(jrc06))))
			jrc12 = float64(jrc11*(jrc11+1)*(jrc11-1)) / 12
			jrc13 = float64(jrc11+1) / 2
			jrc14 = float64(jrc11-1) / 2
			jrc09 = 0.0
			jrc10 = 0.0

			for jrc15 = jrc11 - 1; jrc15 >= 0; jrc15-- {
				jrc23 = (jrc24 + jrc15) % 1001
				jrc09 += jrc30[jrc23]
				jrc10 += jrc30[jrc23] * (jrc14 - float64(jrc15))
			}

			jrc16 = jrc10 / jrc12
			jrc17 = jrc09/float64(jrc11) - jrc16*jrc13
			jrc18 = 0.0

			for jrc15 = jrc11 - 1; jrc15 >= 0; jrc15-- {
				jrc17 += jrc16
				jrc23 = (jrc24 + jrc15) % 1001
				jrc18 += math.Abs(jrc30[jrc23] - jrc17)
			}

			jrc25 = 1.2 * jrc18 / float64(jrc11)
			if jrc11 < jrc06 {
				jrc25 *= math.Pow(float64(jrc06)/float64(jrc11), 0.25)
			}

			if jrc28 == 1 {
				jrc28 = 0
				jrc19 = jrc25
			} else {
				jrc19 += (jrc25 - jrc19) * jrc05
			}

			jrc19 = math.Max(float64(jrc02), jrc19)
			if jrc29 == 1 {
				jrc29 = 0
				jrc08 = (jrc30[jrc24] - jrc30[(jrc24+jrc07)%1001]) / float64(jrc07)
			}

			jrc21 = input1 - (jrc20 + jrc08*jrc04)
			jrc22 = 1 - math.Exp(-math.Abs(jrc21)/jrc19/jrc03)
			jrc08 = jrc22*jrc21 + jrc08*jrc04
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
	jrc05 = jrc04 * (jrc04 + 1) / 2
	jrc06 = jrc05 * (2*jrc04 + 1) / 3
	jrc07 = jrc05*jrc05*jrc05 - jrc06*jrc06
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
				JR26 = JR27 - JR01
			} else {
				JR26 = JR27
			}
			JR18 = 0
			JR25 = 0
			JR21 = SrcA[Bar-1]
			JR03 = 3
			JR04 = 0.86 - 0.55/math.Sqrt(float64(JR03))
			JR05 = 1 - math.Exp(-math.Log(4)/float64(JR03)/2)
			JR06 = float64(JR01 + 1)
			JR07 = 3
			JR08 = (SrcA[Bar] - SrcA[Bar-JR07]) / float64(JR07)
			JR11 = int(math.Trunc(math.Min(1+float64(JR27-JR26), float64(JR06))))
			for JR15 := JR11 - 1; JR15 >= 1; JR15-- {
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
				JR08 = (JR21 - JR21b) / 2
			} else {
				JR08 = 0
			}
			JR11 += 1
		} else {
			if JR11 <= JR06 {
				JR12 = JR11 * (JR11 + 1) * (JR11 - 1) / 12
				JR13 = (JR11 + 1) / 2
				JR14 = (JR11 - 1) / 2
				JR09 = 0.0
				JR10 = 0
				for JR15 := JR11 - 1; JR15 >= 0; JR15-- {
					JR24 = (JR25 + JR15) % 100
					JR09 += JR41[JR24]
					JR10 += JR41[JR24] * (JR14 - JR15)
				}
				JR16 = JR10 / JR12
				JR17 = (JR09 / float64(JR11)) - (JR16 * JR13)
				JR19 = 0.0
				for JR15 := JR11 - 1; JR15 >= 0; JR15-- {
					JR17 += JR16
					JR24 = (JR25 + JR15) % 100
					JR19 += math.Abs(JR41[JR24] - JR17)
				}
				JR20 = (JR19 / float64(JR11)) * math.Pow(JR06/float64(JR11), 0.25)
				JR11 += 1
			} else {
				if (Bar % 1000) == 0 {
					JR09 = 0.0
					JR10 = 0
					for JR15 := JR06 - 1; JR15 >= 0; JR15-- {
						JR24 = (JR25 + JR15) % 100
						JR09 += JR41[JR24]
						JR10 += JR41[JR24] * (JR14 - JR15)
					}
				} else {
					JR24 = (JR25 + JR06) % 100
					JR10 = JR10 - JR09 + JR41[JR24]*JR13 + SrcA[Bar]*JR14
					JR09 = JR09 - JR41[JR24] + SrcA[Bar]
				}
				if JR18 <= 0 {
					JR18 = JR06
				}
				JR18 -= 1
				JR19 -= JR40[JR18]
				JR16 = JR10 / JR12
				JR17 = (JR09 / float64(JR06)) + (JR16 * JR14)
				JR40[JR18] = math.Abs(SrcA[Bar] - JR17)
				JR19 = math.Max(JR02, (JR19 + JR40[JR18]))
				JR20 += ((JR19 / float64(JR06)) - JR20) * JR05
			}
			JR20 = math.Max(JR02, JR20)
			JR22 = SrcA[Bar] - (JR21 + JR08*JR04)
			JR23 = 1 - math.Exp(-math.Abs(JR22)/JR20/JR03)
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
	jrc05 = jrc04 * (jrc04 + 1) / 2
	jrc06 = jrc05 * (2*jrc04 + 1) / 3
	jrc07 = jrc05*jrc05*jrc05 - jrc06*jrc06
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

// XXX
// XXX
// XXX

func main() {
	SrcA := testInput()

	fmt.Println("// JJMASeries(SrcA, ALength=5, APhase=50)")
	Result := JJMASeries(SrcA, 5, 50) // SrcA, ALength, APhase
	testOutput(Result)

	fmt.Println("// JCFBSeries(SrcA, AFractalType=1, ASmooth=2)")
	Result = JCFBSeries(SrcA, 1, 2) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("// TrueRangeSeries(SrcA, HighA, LowA)")
	Result = TrueRangeSeries(SrcA, testHigh(), testLow()) // SrcA, HighA, LowA
	testOutput(Result)

	fmt.Println("// JDMXplusSeries(SrcA, HighA, LowA, ALen=5)")
	Result = JDMXplusSeries(SrcA, testHigh(), testLow(), 5) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("// JDMXminusSeries(SrcA, HighA, LowA, ALen=5)")
	Result = JDMXminusSeries(SrcA, testHigh(), testLow(), 5) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	fmt.Println("// JDMXSeries(SrcA, HighA, LowA, ALen=5)")
	Result = JDMXSeries(SrcA, testHigh(), testLow(), 5) // SrcA, HighA, LowA, ALen
	testOutput(Result)

	lenA := make(TSeries, len(SrcA))

	for i := 0; i < len(SrcA); i++ {
		lenA[i] = 5
	}

	fmt.Println("// JXRSXSeries(SrcA, LenA={5...})")
	Result = JXRSXSeries(SrcA, lenA) // SrcA, LenA
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

func testLow() TSeries {
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

func testHigh() TSeries {
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
	fmt.Print("[]float64 {")
	for _, el := range arr {
		fmt.Print(" ", el, ", ")
	}

	fmt.Println("}")
}

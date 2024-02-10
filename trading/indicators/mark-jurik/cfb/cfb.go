package main

import (
	"fmt"
	"math"
)

type TSeries []float64

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

func main() {
	SrcA := testInput()

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=1(24), ASmooth=10)")
	Result := JCFBSeries(SrcA, 1, 10) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=2(48), ASmooth=10)")
	Result = JCFBSeries(SrcA, 2, 10) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=3(96), ASmooth=10)")
	Result = JCFBSeries(SrcA, 3, 10) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=4(192), ASmooth=10)")
	Result = JCFBSeries(SrcA, 4, 10) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=1(24), ASmooth=2)")
	Result = JCFBSeries(SrcA, 1, 2) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=2(48), ASmooth=2)")
	Result = JCFBSeries(SrcA, 2, 2) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=3(96), ASmooth=2)")
	Result = JCFBSeries(SrcA, 3, 2) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=4(192), ASmooth=2)")
	Result = JCFBSeries(SrcA, 4, 2) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=1(24), ASmooth=50)")
	Result = JCFBSeries(SrcA, 1, 50) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=2(48), ASmooth=50)")
	Result = JCFBSeries(SrcA, 2, 50) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=3(96), ASmooth=50)")
	Result = JCFBSeries(SrcA, 3, 50) // SrcA, AFractalType, ASmooth
	testOutput(Result)

	fmt.Println("//////////////////////////////////////////////////")
	fmt.Println("// JCFBSeries(test_input, AFractalType=4(192), ASmooth=50)")
	Result = JCFBSeries(SrcA, 4, 50) // SrcA, AFractalType, ASmooth
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

package main

import (
	"fmt"
	"math"
)

type TSeries []float64

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
				jrc05 = jrc05 + (Depth-jrc07)*math.Abs(SrcA[Bar-jrc07]-SrcA[Bar-jrc07-1])
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
	Value := 0.0
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
	Value := 0.0
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
	Value := 0.0
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
	Value := 0.0
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
	Bar := 0

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
	SrcA := TSeries{1, 2, 3, 4, 5}
	AFractalType := 1
	ASmooth := 2

	Result := JCFBSeries(SrcA, AFractalType, ASmooth)
	fmt.Println(Result)
}



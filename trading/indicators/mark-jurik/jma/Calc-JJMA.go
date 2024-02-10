package main

import (
                "fmt"
                "math"
)

type TSeries []float64

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
                list := make([]float64, 128)
                ring := make([]float64, 128)
                ring2 := make([]float64, 11)
                buffer := make([]float64, 62)

                // SetLength (Result, High (SrcA) + 1);
                // ????????? ???? ?????????? ??????????
  // v := 0; v1 := 0; v2 := 0; v3 := 0; v4 := 0; s8 := 0; s10 := 0; s18 := 0;
  // s20 := 0; i := 0; v5 := 0; v6 := 0; s28 := 0; s30 := 0; s38 := 0; s40 := 0;
  // s48 := 0; s50 := 0; s58 := 0; s60 := 0; s68 := 0; s70 := 0; f8 := 0;
  // f10 := 0; f18 := 0; f20 := 0; f28 := 0; f30 := 0; f38 := 0; f40 := 0;
  // f48 := 0; f50 := 0; f58 := 0; f60 := 0; f68 := 0; f70 := 0; f78 := 0;
  // f80 := 0; f88 := 0; f90 := 0; f98 := 0; fA0 := 0; fA8 := 0; fB0 := 0;
  // fB8 := 0; fC0 := 0; fC8 := 0; fD0 := 0; f0 := 0; fD8 := 0; fE0 := 0;
  // fE8 := 0; fF0 := 0; fF8 := 0; 
  // FillChar (list,SizeOf(list), 0);
  // FillChar (ring,SizeOf(ring), 0);
  // FillChar (ring2,SizeOf(ring2), 0);
  // FillChar (buffer,SizeOf(buffer), 0);

                Result = make([]float64, len(SrcA))
 
                s28 = 63
                s30 = 64
                for i := 1; i <= s28; i++ {
                                list[i] = -1000000
                }

                for i := s30; i <= 127; i++ {
                                list[i] = 1000000
                }

                f0 = 1
                if ALength <= 1 {
                                f80 = 1.0E-10
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
                                v3 = 0
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
                                                                v = fA0 + 1.0E-10
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

                                                                f60 = s18 / (s38 - s40 + 1)
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
                                                                                                v4 = fE8 - fE0
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

                                                                                fA8 = (SrcA[Bar] - buffer[fF0-v5])*(1-f68)/float64(fE0) +
                                                                                                (SrcA[Bar] - buffer[fF0-v6])*f68/float64(fE8)
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
                                                                fC8 = (SrcA[Bar] - fC0)*(1-f50) + f50*fC8
                                                                fD0 = f10*fC8 + fC0
                                                                f20 = f30 * -2
                                                                f40 = f30 * f30
                                                                fB0 = f20 + f40 + 1
                                                                fA8 = (fD0 - fB8)*fB0 + f40*fA8
                                                                fB8 = fB8 + fA8
                                                }
                                }

                                Value = fB8
                                Result[Bar] = Value
                }

                return Result
}

func main() {
                SrcA := TSeries{1, 2, 3, 4, 5}
                ALength := 5
                APhase := 50
                Result := JJMASeries(SrcA, ALength, APhase)
                fmt.Println(Result)
}
 
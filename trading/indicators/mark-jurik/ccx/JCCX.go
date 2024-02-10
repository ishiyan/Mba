package main

import (
    "fmt"
    "math"
)

// JCCXSeries calculates the JCCX series for a given input series and length
func JCCXSeries(series int, length int) []float64 {
    var result []float64
    var sName string
    var value float64

    sName = fmt.Sprintf("JCCX(%s,%d)", GetDescription(series), length)
    result = FindNamedSeries(sName)
    if len(result) > 0 {
        return result
    }
    result = CreateNamedSeries(sName)

    diff := SubtractSeries(JJMASeries(series, 4, 0), JJMASeries(series, length, 0))

    barCount := BarCount()
    for bar := 1; bar < barCount-1; bar++ {
        var abars int
        if bar < 3*length {
            abars = bar
        } else {
            abars = 3 * length
        }
        md := 0.0
        for k := 0; k < abars; k++ {
            md += math.Abs(diff[bar-k])
        }
        md = md * 1.5 / float64(abars)
        if md > 0.00001 {
            value = diff[bar] / md
        } else {
            value = 0
        }
        result = append(result, value)
    }
    return result
}

// JCCX calculates the JCCX value for a given bar, series, and length
func JCCX(bar int, series int, length int) float64 {
    seriesValue := JCCXSeries(series, length)
    return GetSeriesValue(bar, seriesValue)
}

package main

import (
	"fmt"
)

// Below is an example implementation of the Chande Momentum Oscillator (CMO) indicator in Go.
// In this code:
//
// The calculateCMO function calculates the Chande Momentum Oscillator (CMO) values for
// a given set of price data and a specified period.
//
// The main function demonstrates an example usage of the calculateCMO function with
// sample price data and a period of 5.
//
// This implementation follows the logic of the CMO indicator, where gains and losses areaccumulated
// over the specified period, and then the CMO value is calculated based on these cumulative sums.

// calculateCMO calculates the Chande Momentum Oscillator (CMO) for a given set of price data.
func calculateCMO(prices []float64, period int) []float64 {
	if len(prices) <= period {
		return nil
	}

	var (
		cmoValues []float64
		sumGain   float64
		sumLoss   float64
	)

	// Calculate initial sum of gains and losses
	for i := 1; i <= period; i++ {
		priceDiff := prices[i] - prices[i-1]
		if priceDiff >= 0 {
			sumGain += priceDiff
		} else {
			sumLoss += -priceDiff
		}
	}

	// Calculate first CMO value
	cmoValues = append(cmoValues, ((sumGain - sumLoss) / (sumGain + sumLoss)) * 100)

	// Calculate subsequent CMO values
	for i := period + 1; i < len(prices); i++ {
		priceDiff := prices[i] - prices[i-1]
		if priceDiff >= 0 {
			sumGain += priceDiff
		} else {
			sumLoss += -priceDiff
		}

		// Adjust sums by subtracting the price change from period "period" days ago
		priceDiffPast := prices[i-period] - prices[i-period-1]
		if priceDiffPast >= 0 {
			sumGain -= priceDiffPast
		} else {
			sumLoss -= -priceDiffPast
		}

		// Calculate CMO
		cmo := ((sumGain - sumLoss) / (sumGain + sumLoss)) * 100
		cmoValues = append(cmoValues, cmo)
	}

	return cmoValues
}

func main() {
	// Example usage
	prices := []float64{50, 55, 52, 48, 45, 47, 49, 51, 50, 53, 55}
	period := 5
	cmoValues := calculateCMO(prices, period)
	fmt.Println("CMO values:", cmoValues)
}


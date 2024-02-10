package main

import (
    "fmt"
    "math"
)

// Below is an example of how you could implement a simple function in Go to calculate
// the Relative Strength Index (RSI) indicator for a given set of price data:

// This code defines a calculateRSI function that takes a slice of float64 prices and
// a period as input and returns a slice of RSI values calculated based on the provided price data.
// The average function is used internally to calculate the average gain and loss. Finally,
// in the main function, an example usage is demonstrated with sample price data and a period of 5.

// calculateRSI calculates the Relative Strength Index (RSI) for a given set of price data.
func calculateRSI(prices []float64, period int) []float64 {
    if len(prices) <= period {
        return nil
    }

    // Initialize variables
    var (
        gains []float64
        losses []float64
        rsis []float64
    )

    // Calculate initial gain and loss
    prevPrice := prices[0]
    for i := 1; i <= period; i++ {
        priceDiff := prices[i] - prevPrice
        if priceDiff >= 0 {
            gains = append(gains, priceDiff)
            losses = append(losses, 0)
        } else {
            gains = append(gains, 0)
            losses = append(losses, -priceDiff)
        }
        prevPrice = prices[i]
    }

    // Calculate average gain and loss
    avgGain := average(gains)
    avgLoss := average(losses)

    // Calculate RSI for the first period
    if avgLoss == 0 {
        rsis = append(rsis, 100)
    } else {
        rs := avgGain / avgLoss
        rsis = append(rsis, 100 - (100 / (1 + rs)))
    }

    // Calculate RSI for subsequent periods
    for i := period + 1; i < len(prices); i++ {
        priceDiff := prices[i] - prices[i-1]
        var gain, loss float64
        if priceDiff >= 0 {
            gain = priceDiff
            loss = 0
        } else {
            gain = 0
            loss = -priceDiff
        }

        avgGain = ((avgGain * float64(period-1)) + gain) / float64(period)
        avgLoss = ((avgLoss * float64(period-1)) + loss) / float64(period)

        var rsi float64
        if avgLoss == 0 {
            rsi = 100
        } else {
            rs := avgGain / avgLoss
            rsi = 100 - (100 / (1 + rs))
        }
        rsis = append(rsis, rsi)
    }

    return rsis
}

// average calculates the average of a slice of float64 numbers.
func average(numbers []float64) float64 {
    sum := 0.0
    for _, num := range numbers {
        sum += num
    }
    return sum / float64(len(numbers))
}

func main() {
    // Example usage
    prices := []float64{50, 55, 52, 48, 45, 47, 49, 51, 50, 53, 55}
    period := 5
    rsis := calculateRSI(prices, period)
    fmt.Println("RSI values:", rsis)
}

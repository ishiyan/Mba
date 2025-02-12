using System;
using System.Globalization;

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// Enumerates types of techniques used to estimate an instantaneous period.
    /// </summary>
    internal static class HilbertTransformerCycleEstimatorFactory
    {
        /// <summary>
        /// Creates an instance of a cycle estimator with default parameters.
        /// </summary>
        /// <param name="estimator">The type of an estimator.</param>
        public static IHilbertTransformerCycleEstimator Create(this HilbertTransformerCycleEstimator estimator)
        {
            switch (estimator)
            {
                case HilbertTransformerCycleEstimator.HomodyneDiscriminator:
                    return new HilbertTransformerHomodyneDiscriminator();
                case HilbertTransformerCycleEstimator.HomodyneDiscriminatorTl:
                    return new HilbertTransformerHomodyneDiscriminatorTl();
                case HilbertTransformerCycleEstimator.PhaseAccumulation:
                    return new HilbertTransformerPhaseAccumulation();
                case HilbertTransformerCycleEstimator.DualDifferentiator:
                    return new HilbertTransformerDualDifferentiator();
                default:
                    throw new ArgumentException(nameof(estimator));
            }
        }

        /// <summary>
        /// Creates an instance of a cycle estimator with specific parameters.
        /// </summary>
        /// <param name="estimator">The type of an estimator.</param>
        /// <param name="smoothingLength">The WMA smoothing length. The valid values are 2, 3, 4. The default value is 4.</param>
        /// <param name="warmUpPeriod">The number of updates before the indicator is primed. If less than the real primed period, then will be reset to the real primed period. The default value is 100 (MaxPeriod * 2).</param>
        /// <param name="alphaEmaQuadratureInPhase">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the in-phase and quadrature components. The default value is 0.2 for Homodyne Discriminator, 0.15 for others.</param>
        /// <param name="alphaEmaPeriod">The value of α (0 &lt; α ≤ 1) used in EMA to smooth the instantaneous period. The default value is 0.2 for Homodyne Discriminator, 0.15 for Dual Differentiator,.0.25 for Phase Accumulation.</param>
        public static IHilbertTransformerCycleEstimator Create(this HilbertTransformerCycleEstimator estimator,
            int smoothingLength, int warmUpPeriod, double alphaEmaQuadratureInPhase, double alphaEmaPeriod)
        {
            switch (estimator)
            {
                case HilbertTransformerCycleEstimator.HomodyneDiscriminator:
                    return new HilbertTransformerHomodyneDiscriminator(smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase, alphaEmaPeriod);
                case HilbertTransformerCycleEstimator.HomodyneDiscriminatorTl:
                    return new HilbertTransformerHomodyneDiscriminatorTl(smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase, alphaEmaPeriod);
                case HilbertTransformerCycleEstimator.PhaseAccumulation:
                    return new HilbertTransformerPhaseAccumulation(smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase, alphaEmaPeriod);
                case HilbertTransformerCycleEstimator.DualDifferentiator:
                    return new HilbertTransformerDualDifferentiator(smoothingLength, warmUpPeriod, alphaEmaQuadratureInPhase, alphaEmaPeriod);
                default:
                    throw new ArgumentException(nameof(estimator));
            }
        }

        /// <summary>
        /// A short name of a given cycle estimator.
        /// </summary>
        /// <param name="estimator">The type of an estimator.</param>
        public static string ShortName(this HilbertTransformerCycleEstimator estimator)
        {
            switch (estimator)
            {
                case HilbertTransformerCycleEstimator.HomodyneDiscriminator:
                    return "HtHd";
                case HilbertTransformerCycleEstimator.HomodyneDiscriminatorTl:
                    return "HtHdTl";
                case HilbertTransformerCycleEstimator.PhaseAccumulation:
                    return "HtPa";
                case HilbertTransformerCycleEstimator.DualDifferentiator:
                    return "HtDd";
                default:
                    throw new ArgumentException(nameof(estimator));
            }
        }

        /// <summary>
        /// A full name (in brackets) of a given cycle estimator.
        /// </summary>
        /// <param name="estimator">The type of an estimator.</param>
        public static string FullNameInBrackets(this HilbertTransformerCycleEstimator estimator)
        {
            switch (estimator)
            {
                case HilbertTransformerCycleEstimator.HomodyneDiscriminator:
                    return "(Hilbert transformer Homodyne Discriminator)";
                case HilbertTransformerCycleEstimator.HomodyneDiscriminatorTl:
                    return "(Hilbert transformer Homodyne Discriminator, TA-Lib implementation)";
                case HilbertTransformerCycleEstimator.PhaseAccumulation:
                    return "(Hilbert transformer Phase Accumulation)";
                case HilbertTransformerCycleEstimator.DualDifferentiator:
                    return "(Hilbert transformer Dual Differentiator)";
                default:
                    throw new ArgumentException(nameof(estimator));
            }
        }

        /// <summary>
        /// Parameter values of a given cycle estimator.
        /// </summary>
        /// <param name="estimator">The type of an estimator.</param>
        public static string Parameters(this IHilbertTransformerCycleEstimator estimator)
        {
            return string.Format(CultureInfo.InvariantCulture, "smLen={0},wUp={1},αHt={2:0.####},αPe={3:0.####}",
                estimator.SmoothingLength, estimator.WarmUpPeriod, estimator.AlphaEmaQuadratureInPhase, estimator.AlphaEmaPeriod);
        }
    }
}

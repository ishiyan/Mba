using System.ComponentModel;

namespace Mbst.Trading.Indicators.JohnEhlers
{
    /// <summary>
    /// Enumerates types of techniques to estimate an instantaneous period using a Hilbert transformer.
    /// </summary>
    public enum HilbertTransformerCycleEstimator
    {
        /// <summary>Homodyne discriminator.</summary>
        [Description("Homodyne discriminator")]
        HomodyneDiscriminator,

        /// <summary>Homodyne discriminator (TA-Lib implementation with unrolled loops).</summary>
        [Description("Homodyne discriminator (TA-Lib implementation)")]
        HomodyneDiscriminatorTl,

        /// <summary>Phase accumulation.</summary>
        [Description("Phase accumulation")]
        PhaseAccumulation,

        /// <summary>Dual differentiator.</summary>
        [Description("Dual differentiator")]
        DualDifferentiator
    }
}

//
// Copyright (C) 2006, NinjaTrader LLC <ninjatrader@ninjatrader.com>.
// NinjaTrader reserves the right to modify or overwrite this NinjaScript component with each release.
//

#region Using declarations
using System;
using System.ComponentModel;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Xml.Serialization;
using NinjaTrader.Data;
using NinjaTrader.Gui.Chart;
#endregion

#region NinjaScript generated code. Neither change nor remove.
// This namespace holds all indicators and is required. Do not change it.
namespace NinjaTrader.Indicator
{
    public partial class Indicator : IndicatorBase
    {
        private _SwamiAroon[] cache_SwamiAroon = null;
        private _SwamiCCI[] cache_SwamiCCI = null;
        private _SwamiRSI[] cache_SwamiRSI = null;
        private _SwamiStochastics[] cache_SwamiStochastics = null;

        private static _SwamiAroon check_SwamiAroon = new _SwamiAroon();
        private static _SwamiCCI check_SwamiCCI = new _SwamiCCI();
        private static _SwamiRSI check_SwamiRSI = new _SwamiRSI();
        private static _SwamiStochastics check_SwamiStochastics = new _SwamiStochastics();

        /// <summary>
        /// SwamiAroon - A SwamiChart based on the classic Aroon indicator
        /// </summary>
        /// <returns></returns>
        public _SwamiAroon _SwamiAroon(int maxLookback, int minLookback)
        {
            return _SwamiAroon(Input, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiAroon - A SwamiChart based on the classic Aroon indicator
        /// </summary>
        /// <returns></returns>
        public _SwamiAroon _SwamiAroon(Data.IDataSeries input, int maxLookback, int minLookback)
        {
            if (cache_SwamiAroon != null)
                for (int idx = 0; idx < cache_SwamiAroon.Length; idx++)
                    if (cache_SwamiAroon[idx].MaxLookback == maxLookback && cache_SwamiAroon[idx].MinLookback == minLookback && cache_SwamiAroon[idx].EqualsInput(input))
                        return cache_SwamiAroon[idx];

            lock (check_SwamiAroon)
            {
                check_SwamiAroon.MaxLookback = maxLookback;
                maxLookback = check_SwamiAroon.MaxLookback;
                check_SwamiAroon.MinLookback = minLookback;
                minLookback = check_SwamiAroon.MinLookback;

                if (cache_SwamiAroon != null)
                    for (int idx = 0; idx < cache_SwamiAroon.Length; idx++)
                        if (cache_SwamiAroon[idx].MaxLookback == maxLookback && cache_SwamiAroon[idx].MinLookback == minLookback && cache_SwamiAroon[idx].EqualsInput(input))
                            return cache_SwamiAroon[idx];

                _SwamiAroon indicator = new _SwamiAroon();
                indicator.BarsRequired = BarsRequired;
                indicator.CalculateOnBarClose = CalculateOnBarClose;
#if NT7
                indicator.ForceMaximumBarsLookBack256 = ForceMaximumBarsLookBack256;
                indicator.MaximumBarsLookBack = MaximumBarsLookBack;
#endif
                indicator.Input = input;
                indicator.MaxLookback = maxLookback;
                indicator.MinLookback = minLookback;
                Indicators.Add(indicator);
                indicator.SetUp();

                _SwamiAroon[] tmp = new _SwamiAroon[cache_SwamiAroon == null ? 1 : cache_SwamiAroon.Length + 1];
                if (cache_SwamiAroon != null)
                    cache_SwamiAroon.CopyTo(tmp, 0);
                tmp[tmp.Length - 1] = indicator;
                cache_SwamiAroon = tmp;
                return indicator;
            }
        }

        /// <summary>
        /// SwamiCCI - A SwamiChart based on the classic CCI indicator
        /// </summary>
        /// <returns></returns>
        public _SwamiCCI _SwamiCCI(double alpha, int maxLookback, int minLookback)
        {
            return _SwamiCCI(Input, alpha, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiCCI - A SwamiChart based on the classic CCI indicator
        /// </summary>
        /// <returns></returns>
        public _SwamiCCI _SwamiCCI(Data.IDataSeries input, double alpha, int maxLookback, int minLookback)
        {
            if (cache_SwamiCCI != null)
                for (int idx = 0; idx < cache_SwamiCCI.Length; idx++)
                    if (Math.Abs(cache_SwamiCCI[idx].Alpha - alpha) <= double.Epsilon && cache_SwamiCCI[idx].MaxLookback == maxLookback && cache_SwamiCCI[idx].MinLookback == minLookback && cache_SwamiCCI[idx].EqualsInput(input))
                        return cache_SwamiCCI[idx];

            lock (check_SwamiCCI)
            {
                check_SwamiCCI.Alpha = alpha;
                alpha = check_SwamiCCI.Alpha;
                check_SwamiCCI.MaxLookback = maxLookback;
                maxLookback = check_SwamiCCI.MaxLookback;
                check_SwamiCCI.MinLookback = minLookback;
                minLookback = check_SwamiCCI.MinLookback;

                if (cache_SwamiCCI != null)
                    for (int idx = 0; idx < cache_SwamiCCI.Length; idx++)
                        if (Math.Abs(cache_SwamiCCI[idx].Alpha - alpha) <= double.Epsilon && cache_SwamiCCI[idx].MaxLookback == maxLookback && cache_SwamiCCI[idx].MinLookback == minLookback && cache_SwamiCCI[idx].EqualsInput(input))
                            return cache_SwamiCCI[idx];

                _SwamiCCI indicator = new _SwamiCCI();
                indicator.BarsRequired = BarsRequired;
                indicator.CalculateOnBarClose = CalculateOnBarClose;
#if NT7
                indicator.ForceMaximumBarsLookBack256 = ForceMaximumBarsLookBack256;
                indicator.MaximumBarsLookBack = MaximumBarsLookBack;
#endif
                indicator.Input = input;
                indicator.Alpha = alpha;
                indicator.MaxLookback = maxLookback;
                indicator.MinLookback = minLookback;
                Indicators.Add(indicator);
                indicator.SetUp();

                _SwamiCCI[] tmp = new _SwamiCCI[cache_SwamiCCI == null ? 1 : cache_SwamiCCI.Length + 1];
                if (cache_SwamiCCI != null)
                    cache_SwamiCCI.CopyTo(tmp, 0);
                tmp[tmp.Length - 1] = indicator;
                cache_SwamiCCI = tmp;
                return indicator;
            }
        }

        /// <summary>
        /// SwamiRSI - A SwamiChart based on the classic RSI indicator
        /// </summary>
        /// <returns></returns>
        public _SwamiRSI _SwamiRSI(double alpha, int maxLookback, int minLookback)
        {
            return _SwamiRSI(Input, alpha, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiRSI - A SwamiChart based on the classic RSI indicator
        /// </summary>
        /// <returns></returns>
        public _SwamiRSI _SwamiRSI(Data.IDataSeries input, double alpha, int maxLookback, int minLookback)
        {
            if (cache_SwamiRSI != null)
                for (int idx = 0; idx < cache_SwamiRSI.Length; idx++)
                    if (Math.Abs(cache_SwamiRSI[idx].Alpha - alpha) <= double.Epsilon && cache_SwamiRSI[idx].MaxLookback == maxLookback && cache_SwamiRSI[idx].MinLookback == minLookback && cache_SwamiRSI[idx].EqualsInput(input))
                        return cache_SwamiRSI[idx];

            lock (check_SwamiRSI)
            {
                check_SwamiRSI.Alpha = alpha;
                alpha = check_SwamiRSI.Alpha;
                check_SwamiRSI.MaxLookback = maxLookback;
                maxLookback = check_SwamiRSI.MaxLookback;
                check_SwamiRSI.MinLookback = minLookback;
                minLookback = check_SwamiRSI.MinLookback;

                if (cache_SwamiRSI != null)
                    for (int idx = 0; idx < cache_SwamiRSI.Length; idx++)
                        if (Math.Abs(cache_SwamiRSI[idx].Alpha - alpha) <= double.Epsilon && cache_SwamiRSI[idx].MaxLookback == maxLookback && cache_SwamiRSI[idx].MinLookback == minLookback && cache_SwamiRSI[idx].EqualsInput(input))
                            return cache_SwamiRSI[idx];

                _SwamiRSI indicator = new _SwamiRSI();
                indicator.BarsRequired = BarsRequired;
                indicator.CalculateOnBarClose = CalculateOnBarClose;
#if NT7
                indicator.ForceMaximumBarsLookBack256 = ForceMaximumBarsLookBack256;
                indicator.MaximumBarsLookBack = MaximumBarsLookBack;
#endif
                indicator.Input = input;
                indicator.Alpha = alpha;
                indicator.MaxLookback = maxLookback;
                indicator.MinLookback = minLookback;
                Indicators.Add(indicator);
                indicator.SetUp();

                _SwamiRSI[] tmp = new _SwamiRSI[cache_SwamiRSI == null ? 1 : cache_SwamiRSI.Length + 1];
                if (cache_SwamiRSI != null)
                    cache_SwamiRSI.CopyTo(tmp, 0);
                tmp[tmp.Length - 1] = indicator;
                cache_SwamiRSI = tmp;
                return indicator;
            }
        }

        /// <summary>
        /// SwamiStochastics - A SwamiChart based on the classic stochastics indicator
        /// </summary>
        /// <returns></returns>
        public _SwamiStochastics _SwamiStochastics(int maxLookback, int minLookback)
        {
            return _SwamiStochastics(Input, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiStochastics - A SwamiChart based on the classic stochastics indicator
        /// </summary>
        /// <returns></returns>
        public _SwamiStochastics _SwamiStochastics(Data.IDataSeries input, int maxLookback, int minLookback)
        {
            if (cache_SwamiStochastics != null)
                for (int idx = 0; idx < cache_SwamiStochastics.Length; idx++)
                    if (cache_SwamiStochastics[idx].MaxLookback == maxLookback && cache_SwamiStochastics[idx].MinLookback == minLookback && cache_SwamiStochastics[idx].EqualsInput(input))
                        return cache_SwamiStochastics[idx];

            lock (check_SwamiStochastics)
            {
                check_SwamiStochastics.MaxLookback = maxLookback;
                maxLookback = check_SwamiStochastics.MaxLookback;
                check_SwamiStochastics.MinLookback = minLookback;
                minLookback = check_SwamiStochastics.MinLookback;

                if (cache_SwamiStochastics != null)
                    for (int idx = 0; idx < cache_SwamiStochastics.Length; idx++)
                        if (cache_SwamiStochastics[idx].MaxLookback == maxLookback && cache_SwamiStochastics[idx].MinLookback == minLookback && cache_SwamiStochastics[idx].EqualsInput(input))
                            return cache_SwamiStochastics[idx];

                _SwamiStochastics indicator = new _SwamiStochastics();
                indicator.BarsRequired = BarsRequired;
                indicator.CalculateOnBarClose = CalculateOnBarClose;
#if NT7
                indicator.ForceMaximumBarsLookBack256 = ForceMaximumBarsLookBack256;
                indicator.MaximumBarsLookBack = MaximumBarsLookBack;
#endif
                indicator.Input = input;
                indicator.MaxLookback = maxLookback;
                indicator.MinLookback = minLookback;
                Indicators.Add(indicator);
                indicator.SetUp();

                _SwamiStochastics[] tmp = new _SwamiStochastics[cache_SwamiStochastics == null ? 1 : cache_SwamiStochastics.Length + 1];
                if (cache_SwamiStochastics != null)
                    cache_SwamiStochastics.CopyTo(tmp, 0);
                tmp[tmp.Length - 1] = indicator;
                cache_SwamiStochastics = tmp;
                return indicator;
            }
        }
    }
}

// This namespace holds all market analyzer column definitions and is required. Do not change it.
namespace NinjaTrader.MarketAnalyzer
{
    public partial class Column : ColumnBase
    {
        /// <summary>
        /// SwamiAroon - A SwamiChart based on the classic Aroon indicator
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator._SwamiAroon _SwamiAroon(int maxLookback, int minLookback)
        {
            return _indicator._SwamiAroon(Input, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiAroon - A SwamiChart based on the classic Aroon indicator
        /// </summary>
        /// <returns></returns>
        public Indicator._SwamiAroon _SwamiAroon(Data.IDataSeries input, int maxLookback, int minLookback)
        {
            return _indicator._SwamiAroon(input, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiCCI - A SwamiChart based on the classic CCI indicator
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator._SwamiCCI _SwamiCCI(double alpha, int maxLookback, int minLookback)
        {
            return _indicator._SwamiCCI(Input, alpha, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiCCI - A SwamiChart based on the classic CCI indicator
        /// </summary>
        /// <returns></returns>
        public Indicator._SwamiCCI _SwamiCCI(Data.IDataSeries input, double alpha, int maxLookback, int minLookback)
        {
            return _indicator._SwamiCCI(input, alpha, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiRSI - A SwamiChart based on the classic RSI indicator
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator._SwamiRSI _SwamiRSI(double alpha, int maxLookback, int minLookback)
        {
            return _indicator._SwamiRSI(Input, alpha, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiRSI - A SwamiChart based on the classic RSI indicator
        /// </summary>
        /// <returns></returns>
        public Indicator._SwamiRSI _SwamiRSI(Data.IDataSeries input, double alpha, int maxLookback, int minLookback)
        {
            return _indicator._SwamiRSI(input, alpha, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiStochastics - A SwamiChart based on the classic stochastics indicator
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator._SwamiStochastics _SwamiStochastics(int maxLookback, int minLookback)
        {
            return _indicator._SwamiStochastics(Input, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiStochastics - A SwamiChart based on the classic stochastics indicator
        /// </summary>
        /// <returns></returns>
        public Indicator._SwamiStochastics _SwamiStochastics(Data.IDataSeries input, int maxLookback, int minLookback)
        {
            return _indicator._SwamiStochastics(input, maxLookback, minLookback);
        }
    }
}

// This namespace holds all strategies and is required. Do not change it.
namespace NinjaTrader.Strategy
{
    public partial class Strategy : StrategyBase
    {
        /// <summary>
        /// SwamiAroon - A SwamiChart based on the classic Aroon indicator
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator._SwamiAroon _SwamiAroon(int maxLookback, int minLookback)
        {
            return _indicator._SwamiAroon(Input, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiAroon - A SwamiChart based on the classic Aroon indicator
        /// </summary>
        /// <returns></returns>
        public Indicator._SwamiAroon _SwamiAroon(Data.IDataSeries input, int maxLookback, int minLookback)
        {
            if (InInitialize && input == null)
                throw new ArgumentException("You only can access an indicator with the default input/bar series from within the 'Initialize()' method");

            return _indicator._SwamiAroon(input, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiCCI - A SwamiChart based on the classic CCI indicator
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator._SwamiCCI _SwamiCCI(double alpha, int maxLookback, int minLookback)
        {
            return _indicator._SwamiCCI(Input, alpha, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiCCI - A SwamiChart based on the classic CCI indicator
        /// </summary>
        /// <returns></returns>
        public Indicator._SwamiCCI _SwamiCCI(Data.IDataSeries input, double alpha, int maxLookback, int minLookback)
        {
            if (InInitialize && input == null)
                throw new ArgumentException("You only can access an indicator with the default input/bar series from within the 'Initialize()' method");

            return _indicator._SwamiCCI(input, alpha, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiRSI - A SwamiChart based on the classic RSI indicator
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator._SwamiRSI _SwamiRSI(double alpha, int maxLookback, int minLookback)
        {
            return _indicator._SwamiRSI(Input, alpha, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiRSI - A SwamiChart based on the classic RSI indicator
        /// </summary>
        /// <returns></returns>
        public Indicator._SwamiRSI _SwamiRSI(Data.IDataSeries input, double alpha, int maxLookback, int minLookback)
        {
            if (InInitialize && input == null)
                throw new ArgumentException("You only can access an indicator with the default input/bar series from within the 'Initialize()' method");

            return _indicator._SwamiRSI(input, alpha, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiStochastics - A SwamiChart based on the classic stochastics indicator
        /// </summary>
        /// <returns></returns>
        [Gui.Design.WizardCondition("Indicator")]
        public Indicator._SwamiStochastics _SwamiStochastics(int maxLookback, int minLookback)
        {
            return _indicator._SwamiStochastics(Input, maxLookback, minLookback);
        }

        /// <summary>
        /// SwamiStochastics - A SwamiChart based on the classic stochastics indicator
        /// </summary>
        /// <returns></returns>
        public Indicator._SwamiStochastics _SwamiStochastics(Data.IDataSeries input, int maxLookback, int minLookback)
        {
            if (InInitialize && input == null)
                throw new ArgumentException("You only can access an indicator with the default input/bar series from within the 'Initialize()' method");

            return _indicator._SwamiStochastics(input, maxLookback, minLookback);
        }
    }
}
#endregion

using Mbst.Trading;
using Mbst.Trading.Indicators.JohnEhlers;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.Xml;

namespace Tests.Indicators.JohnEhlers
{
    [TestClass]
    public class MesaAdaptiveMovingAverageTlTest
    {
        #region Test data
        /// <summary>
        /// Taken from TA-Lib (http://ta-lib.org/) tests, test_MAMA.xsl, price, D5…D256, 252 entries.
        /// </summary>
        private readonly List<double> rawInput = new List<double>
        {
             92.0000,  93.1725,  95.3125,  94.8450,  94.4075,  94.1100,  93.5000,  91.7350,  90.9550,  91.6875,
             94.5000,  97.9700,  97.5775,  90.7825,  89.0325,  92.0950,  91.1550,  89.7175,  90.6100,  91.0000,
             88.9225,  87.5150,  86.4375,  83.8900,  83.0025,  82.8125,  82.8450,  86.7350,  86.8600,  87.5475,
             85.7800,  86.1725,  86.4375,  87.2500,  88.9375,  88.2050,  85.8125,  84.5950,  83.6575,  84.4550,
             83.5000,  86.7825,  88.1725,  89.2650,  90.8600,  90.7825,  91.8600,  90.3600,  89.8600,  90.9225,
             89.5000,  87.6725,  86.5000,  84.2825,  82.9075,  84.2500,  85.6875,  86.6100,  88.2825,  89.5325,
             89.5000,  88.0950,  90.6250,  92.2350,  91.6725,  92.5925,  93.0150,  91.1725,  90.9850,  90.3775,
             88.2500,  86.9075,  84.0925,  83.1875,  84.2525,  97.8600,  99.8750, 103.2650, 105.9375, 103.5000,
            103.1100, 103.6100, 104.6400, 106.8150, 104.9525, 105.5000, 107.1400, 109.7350, 109.8450, 110.9850,
            120.0000, 119.8750, 117.9075, 119.4075, 117.9525, 117.2200, 115.6425, 113.1100, 111.7500, 114.5175,
            114.7450, 115.4700, 112.5300, 112.0300, 113.4350, 114.2200, 119.5950, 117.9650, 118.7150, 115.0300,
            114.5300, 115.0000, 116.5300, 120.1850, 120.5000, 120.5950, 124.1850, 125.3750, 122.9700, 123.0000,
            124.4350, 123.4400, 124.0300, 128.1850, 129.6550, 130.8750, 132.3450, 132.0650, 133.8150, 135.6600,
            137.0350, 137.4700, 137.3450, 136.3150, 136.4400, 136.2850, 129.0950, 128.3100, 126.0000, 124.0300,
            123.9350, 125.0300, 127.2500, 125.6200, 125.5300, 123.9050, 120.6550, 119.9650, 120.7800, 124.0000,
            122.7800, 120.7200, 121.7800, 122.4050, 123.2500, 126.1850, 127.5600, 126.5650, 123.0600, 122.7150,
            123.5900, 122.3100, 122.4650, 123.9650, 123.9700, 124.1550, 124.4350, 127.0000, 125.5000, 128.8750,
            130.5350, 132.3150, 134.0650, 136.0350, 133.7800, 132.7500, 133.4700, 130.9700, 127.5950, 128.4400,
            127.9400, 125.8100, 124.6250, 122.7200, 124.0900, 123.2200, 121.4050, 120.9350, 118.2800, 118.3750,
            121.1550, 120.9050, 117.1250, 113.0600, 114.9050, 112.4350, 107.9350, 105.9700, 106.3700, 106.8450,
            106.9700, 110.0300,  91.0000,  93.5600,  93.6200,  95.3100,  94.1850,  94.7800,  97.6250,  97.5900,
             95.2500,  94.7200,  92.2200,  91.5650,  92.2200,  93.8100,  95.5900,  96.1850,  94.6250,  95.1200,
             94.0000,  93.7450,  95.9050, 101.7450, 106.4400, 107.9350, 103.4050, 105.0600, 104.1550, 103.3100,
            103.3450, 104.8400, 110.4050, 114.5000, 117.3150, 118.2500, 117.1850, 109.7500, 109.6550, 108.5300,
            106.2200, 107.7200, 109.8400, 109.0950, 109.0900, 109.1550, 109.3150, 109.0600, 109.9050, 109.6250,
            109.5300, 108.0600
        };

        /// <summary>
        /// Taken from TA-Lib (http://ta-lib.org/) tests, test_MAMA.xsl, MAMA, AB5…AB256, 252 entries.
        /// </summary>
        private readonly List<double> mama = new List<double>
        {
             0.0000000000000,  0.0000000000000,  0.0000000000000,  0.0000000000000,  0.0000000000000,  0.0000000000000,  0.0000000000000,  0.0000000000000,  0.0000000000000,  0.0000000000000,
             0.0000000000000,  0.0000000000000, 48.7887500000000, 69.7856250000000, 79.4090625000000, 85.7520312500000, 88.4535156250000, 88.5167148437500, 88.6213791015625, 88.7403101464843,
            88.8314050732422, 88.1732025366211, 88.0864174097900, 85.9882087048950, 84.4953543524475, 83.6539271762238, 83.6134808174126, 83.7730538921178, 83.9274011975119, 84.1084061376363,
            84.1919858307545, 84.2910115392168, 85.3642557696084, 85.4585429811280, 85.6324908320716, 85.7611162904680, 85.7636854759446, 85.1793427379723, 85.1032506010737, 85.0708380710200,
            84.9922961674690, 85.8873980837345, 86.0016531795478, 86.1648205205704, 86.3995794945419, 86.6187255198148, 89.2393627599074, 89.2953946219120, 89.3236248908164, 89.4035686462756,
            89.4083902139618, 89.3215957032637, 89.1805159181005, 86.7315079590502, 86.5403075610977, 85.3951537805489, 85.4097710915214, 85.4697825369453, 85.6104184100981, 85.8065224895932,
            85.9911963651135, 86.0963865468578, 88.3606932734289, 88.5544086097575, 88.7103131792696, 88.9044225203061, 89.1099513942908, 90.1412256971454, 90.1834144122881, 90.1931186916737,
            90.0959627570900, 89.9365396192355, 89.6443376382737, 86.4159188191369, 86.2465746609527, 86.8272459279051, 87.4796336315098, 88.2689019499343, 89.1523318524376, 89.8697152598157,
            96.4898576299079, 96.8458647484125, 97.2355715109918, 97.7145429354422, 98.0764407886701, 98.4476187492366,101.7564076993930,105.7457038496970,107.7953519248480,107.9548343286060,
           113.9774171643030,116.9262085821510,117.0440129385960,117.1621872916660,117.5573436458330,117.5388516286560,117.4440340472230,117.2273323448620,116.9534657276190,116.8316674412380,
           115.7883337206190,115.7724170345880,115.6102961828590,115.4312813737160,115.3314673050300,115.2758939397780,117.4354469698890,117.4619246213950,118.0884623106970,117.9355391951630,
           116.2327695975810,116.1711311177020,116.1890745618170,116.3888708337260,116.5944272920400,118.5947136460200,118.8742279637190,119.1992665655330,121.0846332827670,121.1804016186280,
           121.3431315376970,122.3915657688480,122.4734874804060,122.7590631063860,123.1038599510660,126.9894299755330,129.6672149877670,130.8661074938830,131.0135521191890,131.2458745132300,
           131.5353307875680,131.8320642481900,132.1077110357800,134.2113555178900,135.3256777589450,135.3736438709980,135.0597116774480,134.7222260935760,134.2861147888970,129.1580573944480,
           127.6080756167500,127.4791718359120,127.4677132441170,127.3753275819110,127.2830612028150,127.1141581426750,126.7912002355410,123.3781001177700,123.2481951118820,123.6240975559410,
           123.5818926781440,123.4387980442370,123.3558581420250,123.3083152349240,123.3053994731770,124.7451997365890,124.8859397497590,125.7254698748800,124.3927349374400,124.2939549097530,
           124.2587571642660,124.1613193060520,124.0765033407500,124.0207516703750,124.0182140868560,124.0250533825130,124.0455507133880,124.1932731777180,124.8466365888590,125.0480547594160,
           125.3224020214450,128.8187010107230,129.0810159601870,129.4287151621770,131.6043575810890,131.6616397020340,131.7520577169320,131.7129548310860,131.5070570895320,131.3537042350550,
           131.1830190233020,128.4965095116510,128.3029340360690,128.0237873342650,127.8270979675520,126.8972763663560,124.1511381831780,123.0563896101160,122.6898008861760,122.4740608418670,
           121.8145304209340,121.3597652104670,120.9105195346410,119.9913157340130,119.7369999473130,119.3718999499470,118.4965352202910,112.2332676101460,111.9401042296380,111.6853490181560,
           109.3276745090780,109.3627907836240,108.4446512444430,107.7004186822210,106.7428123045010,101.0264061522510, 97.6057030761253, 97.4644179223190, 97.4724470262030, 97.4783246748929,
            97.3669084411482, 97.2345630190908, 94.7272815095454, 94.5691674340681, 94.4517090623647, 94.4196236092465, 95.0048118046232, 95.0638212143921, 95.0418801536725, 95.0457861459889,
            94.9934968386894, 94.3692484193447, 94.4460359983775, 94.8109841984586, 95.3924349885356,101.6637174942680,101.7507816195540,103.4053908097770,103.4428712692880,103.4362277058240,
           103.4316663205330,103.5020830045060,103.8472288542810,109.1736144271400,109.5806837057830,110.0141495204940,113.5995747602470,113.4070960222350,113.2194912211230,112.9850166600670,
           112.6467658270630,112.4004275357100,111.1202137678550,111.0189530794620,110.9225054254890,110.8341301542150,110.7581736465040,110.6732649641790,110.2891324820890,110.2559258579850,
           110.2196295650860,110.1116480868310
        };
        #endregion

        #region NameTest
        /// <summary>
        /// A test for Name.
        /// </summary>
        [TestMethod]
        public void NameTest()
        {
            var target = new MesaAdaptiveMovingAverageTl();
            Assert.AreEqual("MAMA", target.Name);
        }
        #endregion

        #region MonikerTest
        /// <summary>
        /// A test for Moniker.
        /// </summary>
        [TestMethod]
        public void MonikerTest()
        {
            var target = new MesaAdaptiveMovingAverageTl();
            Assert.AreEqual("MAMA4(3,39)", target.Moniker);
            target = new MesaAdaptiveMovingAverageTl(20, 5);
            Assert.AreEqual("MAMA4(5,20)", target.Moniker);
            target = new MesaAdaptiveMovingAverageTl(0.01, 0.8);
            Assert.AreEqual("MAMA4(1,199)", target.Moniker);
        }
        #endregion

        #region DescriptionTest
        /// <summary>
        /// A test for Description.
        /// </summary>
        [TestMethod]
        public void DescriptionTest()
        {
            var target = new MesaAdaptiveMovingAverageTl();
            Assert.AreEqual("Mesa Adaptive Moving Average", target.Description);
        }
        #endregion

        #region SlowLimitTest
        /// <summary>
        /// A test for SlowLimit.
        /// </summary>
        [TestMethod]
        public void SlowLimitTest()
        {
            var target = new MesaAdaptiveMovingAverageTl();
            Assert.AreEqual(0.05, target.SlowLimit);
            target = new MesaAdaptiveMovingAverageTl(19, 7);
            Assert.AreEqual(0.1, target.SlowLimit);
            target = new MesaAdaptiveMovingAverageTl(0.01, 0.8);
            Assert.AreEqual(0.01, target.SlowLimit);
        }
        #endregion

        #region SlowLimitLengthTest
        /// <summary>
        /// A test for SlowLimitLength.
        /// </summary>
        [TestMethod]
        public void SlowLimitLengthTest()
        {
            var target = new MesaAdaptiveMovingAverageTl();
            Assert.AreEqual(39, target.SlowLimitLength);
            target = new MesaAdaptiveMovingAverageTl(19, 7);
            Assert.AreEqual(19, target.SlowLimitLength);
            target = new MesaAdaptiveMovingAverageTl(0.01, 0.8);
            Assert.AreEqual(199, target.SlowLimitLength);
        }
        #endregion

        #region FastLimitTest
        /// <summary>
        /// A test for FastLimit.
        /// </summary>
        [TestMethod]
        public void FastLimitTest()
        {
            var target = new MesaAdaptiveMovingAverageTl();
            Assert.AreEqual(0.5, target.FastLimit);
            target = new MesaAdaptiveMovingAverageTl(19, 7);
            Assert.AreEqual(0.25, target.FastLimit);
            target = new MesaAdaptiveMovingAverageTl(0.01, 0.8);
            Assert.AreEqual(0.8, target.FastLimit);
        }
        #endregion

        #region FastLimitLengthTest
        /// <summary>
        /// A test for FastLimitLength.
        /// </summary>
        [TestMethod]
        public void FastLimitLengthTest()
        {
            var target = new MesaAdaptiveMovingAverageTl();
            Assert.AreEqual(3, target.FastLimitLength);
            target = new MesaAdaptiveMovingAverageTl(20, 5);
            Assert.AreEqual(5, target.FastLimitLength);
            target = new MesaAdaptiveMovingAverageTl(0.01, 0.8);
            Assert.AreEqual(1, target.FastLimitLength);
        }
        #endregion

        #region SmoothingLengthTest
        /// <summary>
        /// A test for SmoothingLength.
        /// </summary>
        [TestMethod]
        public void SmoothingLengthTest()
        {
            var target = new MesaAdaptiveMovingAverageTl();
            Assert.AreEqual(4, target.SmoothingLength);
            target = new MesaAdaptiveMovingAverageTl(4);
            Assert.AreEqual(4, target.SmoothingLength);
            target = new MesaAdaptiveMovingAverageTl(3);
            Assert.AreEqual(3, target.SmoothingLength);
            target = new MesaAdaptiveMovingAverageTl(2);
            Assert.AreEqual(2, target.SmoothingLength);
        }
        #endregion

        #region IsPrimedTest
        /// <summary>
        /// A test for IsPrimed.
        /// </summary>
        [TestMethod]
        public void IsPrimedTest()
        {
            var target = new MesaAdaptiveMovingAverageTl();
            Assert.IsFalse(target.IsPrimed);
            for (int i = 1; i <= 23; ++i)
            {
                var scalar = new Scalar(DateTime.Now, i);
                scalar = target.Update(scalar);
                Assert.IsTrue(double.IsNaN(scalar.Value));
                Assert.IsFalse(target.IsPrimed);
            }
            for (int i = 24; i <= 48; ++i)
            {
                var scalar = new Scalar(DateTime.Now, i);
                scalar = target.Update(scalar);
                Assert.IsFalse(double.IsNaN(scalar.Value));
                Assert.IsTrue(target.IsPrimed);
            }
        }
        #endregion

        #region UpdateTest
        /// <summary>
        /// A test for Update.
        /// </summary>
        [TestMethod]
        public void UpdateTest()
        {
            const int digits = 9;
            var target = new MesaAdaptiveMovingAverageTl();
            // Tradestation implementation skips first 9 bars.
            for (int i = 9; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                double d = Math.Round(target.Value, digits);
                double u = Math.Round(mama[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
        }
        #endregion

        #region CalculateTest
        /// <summary>
        /// A test for Calculate.
        /// </summary>
        [TestMethod]
        public void CalculateTest()
        {
            var priceList = new List<double>(rawInput);
            List<double> calculatedList = MesaAdaptiveMovingAverageTl.Calculate(priceList);
            var target = new MesaAdaptiveMovingAverageTl();
            var updatedList = rawInput.Select(target.Update).ToList();
            for (int i = 0; i < rawInput.Count; ++i)
                Assert.AreEqual(calculatedList[i], updatedList[i]);
        }
        #endregion

        #region ResetTest
        /// <summary>
        /// A test for Reset.
        /// </summary>
        [TestMethod]
        public void ResetTest()
        {
            double d, u; const int digits = 9;
            var target = new MesaAdaptiveMovingAverageTl();
            // Tradestation implementation skips first 9 bars.
            for (int i = 9; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                d = Math.Round(target.Value, digits);
                u = Math.Round(mama[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
            target.Reset();
            for (int i = 9; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                d = Math.Round(target.Value, digits);
                u = Math.Round(mama[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
        }
        #endregion

        #region ConstructorTest
        /// <summary>
        /// A test for Constructor.
        /// </summary>
        [TestMethod]
        public void MesaAdaptiveMovingAverageTlConstructorTest()
        {
            var target = new MesaAdaptiveMovingAverageTl();
            Assert.AreEqual(4, target.SmoothingLength);
            Assert.AreEqual(3, target.FastLimitLength);
            Assert.AreEqual(39, target.SlowLimitLength);
            Assert.AreEqual(0.5, target.FastLimit);
            Assert.AreEqual(0.05, target.SlowLimit);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new MesaAdaptiveMovingAverageTl(OhlcvComponent.TypicalPrice);
            Assert.AreEqual(4, target.SmoothingLength);
            Assert.AreEqual(3, target.FastLimitLength);
            Assert.AreEqual(39, target.SlowLimitLength);
            Assert.AreEqual(0.5, target.FastLimit);
            Assert.AreEqual(0.05, target.SlowLimit);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.TypicalPrice);

            target = new MesaAdaptiveMovingAverageTl(2);
            Assert.AreEqual(2, target.SmoothingLength);
            Assert.AreEqual(3, target.FastLimitLength);
            Assert.AreEqual(39, target.SlowLimitLength);
            Assert.AreEqual(0.5, target.FastLimit);
            Assert.AreEqual(0.05, target.SlowLimit);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new MesaAdaptiveMovingAverageTl(2, OhlcvComponent.OpeningPrice);
            Assert.AreEqual(2, target.SmoothingLength);
            Assert.AreEqual(3, target.FastLimitLength);
            Assert.AreEqual(39, target.SlowLimitLength);
            Assert.AreEqual(0.5, target.FastLimit);
            Assert.AreEqual(0.05, target.SlowLimit);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.OpeningPrice);

            target = new MesaAdaptiveMovingAverageTl(199, 7);
            Assert.AreEqual(4, target.SmoothingLength);
            Assert.AreEqual(7, target.FastLimitLength);
            Assert.AreEqual(199, target.SlowLimitLength);
            Assert.AreEqual(0.25, target.FastLimit);
            Assert.AreEqual(0.01, target.SlowLimit);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new MesaAdaptiveMovingAverageTl(199, 7, 2);
            Assert.AreEqual(2, target.SmoothingLength);
            Assert.AreEqual(7, target.FastLimitLength);
            Assert.AreEqual(199, target.SlowLimitLength);
            Assert.AreEqual(0.25, target.FastLimit);
            Assert.AreEqual(0.01, target.SlowLimit);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new MesaAdaptiveMovingAverageTl(199, 7, 2, OhlcvComponent.LowPrice);
            Assert.AreEqual(2, target.SmoothingLength);
            Assert.AreEqual(7, target.FastLimitLength);
            Assert.AreEqual(199, target.SlowLimitLength);
            Assert.AreEqual(0.25, target.FastLimit);
            Assert.AreEqual(0.01, target.SlowLimit);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.LowPrice);

            target = new MesaAdaptiveMovingAverageTl(0.01, 0.25);
            Assert.AreEqual(4, target.SmoothingLength);
            Assert.AreEqual(7, target.FastLimitLength);
            Assert.AreEqual(199, target.SlowLimitLength);
            Assert.AreEqual(0.25, target.FastLimit);
            Assert.AreEqual(0.01, target.SlowLimit);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new MesaAdaptiveMovingAverageTl(0.01, 0.25, 2);
            Assert.AreEqual(2, target.SmoothingLength);
            Assert.AreEqual(7, target.FastLimitLength);
            Assert.AreEqual(199, target.SlowLimitLength);
            Assert.AreEqual(0.25, target.FastLimit);
            Assert.AreEqual(0.01, target.SlowLimit);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new MesaAdaptiveMovingAverageTl(0.01, 0.25, 2, OhlcvComponent.HighPrice);
            Assert.AreEqual(2, target.SmoothingLength);
            Assert.AreEqual(7, target.FastLimitLength);
            Assert.AreEqual(199, target.SlowLimitLength);
            Assert.AreEqual(0.25, target.FastLimit);
            Assert.AreEqual(0.01, target.SlowLimit);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.HighPrice);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest2()
        {
            var target = new MesaAdaptiveMovingAverageTl(5);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest3()
        {
            var target = new MesaAdaptiveMovingAverageTl(1);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest4()
        {
            var target = new MesaAdaptiveMovingAverageTl(0);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest5()
        {
            var target = new MesaAdaptiveMovingAverageTl(-8);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest6()
        {
            var target = new MesaAdaptiveMovingAverageTl(0, 2);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest7()
        {
            var target = new MesaAdaptiveMovingAverageTl(-7, 2);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest8()
        {
            var target = new MesaAdaptiveMovingAverageTl(199, 0);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest9()
        {
            var target = new MesaAdaptiveMovingAverageTl(199, -7);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest10()
        {
            var target = new MesaAdaptiveMovingAverageTl(1.01, 0.3);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest11()
        {
            var target = new MesaAdaptiveMovingAverageTl(0, 0.3);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest12()
        {
            var target = new MesaAdaptiveMovingAverageTl(-0.01, 0.3);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest13()
        {
            var target = new MesaAdaptiveMovingAverageTl(0.3, 1.01);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest14()
        {
            var target = new MesaAdaptiveMovingAverageTl(0.3, 0);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void MesaAdaptiveMovingAverageTlConstructorTest15()
        {
            var target = new MesaAdaptiveMovingAverageTl(0.3, -0.01);
            Assert.IsFalse(target.IsPrimed);
        }
        #endregion

        #region SerializationTest
        private static void SerializeTo(MesaAdaptiveMovingAverageTl instance, string fileName)
        {
            var dcs = new DataContractSerializer(typeof(MesaAdaptiveMovingAverageTl), null, 65536, false, true, null);
            using (var fs = new FileStream(fileName, FileMode.Create))
            {
                dcs.WriteObject(fs, instance);
                fs.Close();
            }
        }

        private static MesaAdaptiveMovingAverageTl DeserializeFrom(string fileName)
        {
            var fs = new FileStream(fileName, FileMode.Open);
            XmlDictionaryReader reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());
            var ser = new DataContractSerializer(typeof(MesaAdaptiveMovingAverageTl), null, 65536, false, true, null);
            var instance = (MesaAdaptiveMovingAverageTl)ser.ReadObject(reader, true);
            reader.Close();
            fs.Close();
            return instance;
        }

        /// <summary>
        ///A test for the serialization
        ///</summary>
        [TestMethod]
        public void SerializationTest()
        {
            double d, u; const int digits = 9;
            var source = new MesaAdaptiveMovingAverageTl();
            // Tradestation-implementation skips first 9 bars.
            for (int i = 9; i < 111; i++)
            {
                source.Update(rawInput[i]);
                d = Math.Round(source.Value, digits);
                u = Math.Round(mama[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
            const string fileName = "MesaAdaptiveMovingAverageTl_1.xml";
            SerializeTo(source, fileName);
            MesaAdaptiveMovingAverageTl target = DeserializeFrom(fileName);
            Assert.AreEqual(4, target.SmoothingLength);
            Assert.IsTrue(target.IsPrimed);
            Assert.AreEqual("MAMA", target.Name);
            Assert.AreEqual("Mesa Adaptive Moving Average", target.Description);
            Assert.AreEqual(source.Value, target.Value);
            for (int i = 111; i < rawInput.Count; i++)
            {
                target.Update(rawInput[i]);
                d = Math.Round(target.Value, digits);
                u = Math.Round(mama[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
            //FileInfo fi = new FileInfo(fileName);
            //fi.Delete();
        }
        #endregion
    }
}

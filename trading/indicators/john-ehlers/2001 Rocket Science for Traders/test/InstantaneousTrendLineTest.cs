﻿using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Xml;
using Mbst.Trading;
using Mbst.Trading.Indicators.JohnEhlers;

namespace Tests.Indicators.JohnEhlers
{
    [TestClass]
    public class InstantaneousTrendLineTest
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
        /// Taken from TA-Lib (http://ta-lib.org/) tests, test_MAMA.xsl, Period Adjustment, X5…X256, 252 entries, smoothed as AI18=0.33*X18+0.67*AI17.
        /// </summary>
        private readonly List<double> dcPeriod = new List<double>
        {
             0.00000000000000,  0.00000000000000,  0.00000000000000,  0.00000000000000,  0.00000000000000,  0.00000000000000,  0.00000000000000,  0.00000000000000,  0.00000000000000,  0.00000000000000,
             0.00000000000000,  0.00000000000000,  0.39600000000000,  0.97812000000000,  1.62158040000000,  2.25545086800000,  2.84234568156000,  3.36868456664520,  3.86776291565229,  4.36321983508703,
             4.87235783926831,  5.40838035704577,  5.98190550443027,  6.60199641969884,  7.27686930610184,  8.01438731048222,  8.82241286095647,  9.70906731606755, 10.68293087091460, 11.75320502957710,
            12.92985285048740, 14.22372743856440, 15.55272286275450, 16.77503611571540, 17.85814025111630, 18.72970387649220, 19.30387978646140, 19.63314544969620, 19.86256979430250, 20.09030968609300,
            20.24817834009410, 20.31132870798190, 20.52152604110820, 21.27119054536480, 22.10966835167300, 22.28715460952700, 21.91280773257140, 21.23923470724180, 20.70813161651310, 20.20449150221090,
            19.52863321263000, 18.73709250583170, 17.96311275281150, 17.33367762545960, 16.91743352044750, 16.64300564862120, 16.41952162419500, 16.27464914327850, 16.26425245094380, 16.33321577028600,
            16.39265551523990, 16.39976990202790, 16.38221107536320, 16.37405059271910, 16.35102942468120, 16.26839438425590, 16.12432207371240, 15.99529098667630, 15.96458956780100, 16.07977539207760,
            16.38360881255670, 16.79746341307210, 17.18753188776420, 17.58524022168910, 18.05888760471740, 18.46077773999830, 18.78691120238400, 19.07789869381110, 19.11803073417110, 18.72675385299730,
            18.07403190737810, 17.72999456892580, 18.00699920187680, 18.06680349806270, 17.73551482016550, 17.28467833183610, 16.97456900115070, 16.89386283663200, 17.00556420464730, 17.21986959021550,
            17.48251598471900, 17.79647268844360, 18.15809655229470, 18.56044162987590, 19.03705300462320, 19.61779465906120, 20.13838368155990, 20.58144279802850, 20.93554178712450, 21.09578565733870,
            21.19426268582890, 21.35270550953270, 21.46806615214910, 21.43420235778580, 21.27320458618770, 20.98617884905010, 20.62345107800030, 20.32165030848570, 20.09921951571820, 19.88214300840560,
            19.67081622699810, 19.55217428481160, 19.60485773311710, 19.77836095343260, 19.77886122563300, 19.59009982815140, 19.54609435364200, 19.77945658439880, 20.20526697824140, 20.80572859375930,
            21.45882440191380, 21.50916115262280, 21.07219135457730, 20.33979206665380, 19.60807769029340, 19.15831017112920, 19.03006205140340, 19.23359250887840, 19.84206353515510, 20.83692898803630,
            22.25776348341490, 23.50933063567320, 24.02857349775940, 24.28548086650010, 24.74576845262060, 25.45685387492870, 26.31998583396390, 27.14553013410700, 27.80677101851790, 28.50146147525040,
            29.16835938704370, 29.38723525724370, 29.55886298198770, 30.43981360336700, 30.70779370313880, 30.20667454311960, 29.23518282361370, 28.00037502954910, 26.95505291681000, 26.22399862702800,
            25.67716809996900, 25.19893752937060, 24.76924271120940, 24.40654607774420, 24.12997738279210, 24.02648590415090, 24.17912316847620, 24.26552607123530, 24.07565548132200, 23.81050493977940,
            23.75771490624360, 24.01627030476950, 24.42884190933990, 24.55867905189440, 24.41978729840000, 24.33536819272640, 24.11887925396970, 23.53741527509780, 22.66734716257270, 21.70419061052260,
            20.78848949032480, 19.92593130809770, 19.09528115584620, 18.35405205698280, 17.81539769318840, 17.53491540732180, 17.59552736216070, 18.09376127214910, 18.69300796204700, 19.10361709066390,
            19.40368660687600, 19.79324964337850, 20.14261316711870, 20.30292592814370, 20.37642955508450, 20.42856373321320, 20.36417897031590, 20.26870923265670, 20.31691792510900, 20.52593924664440,
            20.95797078839970, 21.70315565998060, 22.68588957914270, 23.95566588814480, 25.30036991408680, 26.49222048853470, 28.24485763802440, 30.46863151925310, 31.19661794415910, 30.97271495031300,
            30.15801520320610, 29.52193986806340, 28.48090879451130, 27.20913817575940, 25.84740758865390, 24.75875079095690, 24.57820671512040, 25.25622655282780, 26.58938264946150, 28.44936832011270,
            30.75900691394640, 31.63120735338530, 31.95156902113430, 32.19329221743080, 32.18129930292270, 31.78927079951340, 30.94427836437330, 29.74153261553520, 28.44319750131350, 27.27756983469050,
            26.30928991862760, 25.59706087830910, 25.19354035279110, 24.98183319418390, 24.66611779383150, 24.13629363553260, 23.59372342374540, 23.45943359521940, 24.13462330023790, 25.42868068174450,
            27.22154743441240, 28.85990121754770, 29.25658159944000, 28.86760790158470, 28.27077502042400, 27.83957963686970, 27.56292753489200, 27.31665028261770, 27.11537844471070, 27.05619511102920,
            26.72669604084850, 25.93839467294110, 24.88015320695530, 23.98089561843900, 23.51115215671300, 23.02173482203020, 22.29674643126940, 21.42162141795630, 20.54863761751100, 19.78167187971360,
            19.14387361712880, 18.61396641752300
        };

        /// <summary>
        /// Generated using Excel implementation from TA-Lib (http://ta-lib.org/) tests, test_HT.xsl.
        /// </summary>
        private readonly List<double> itl = new List<double>
        {
            double.NaN,  double.NaN,  double.NaN,  double.NaN,  double.NaN,  double.NaN,  double.NaN,  double.NaN,  double.NaN,
            double.NaN, double.NaN,  double.NaN,
              0.0000000000000,  36.3130000000000,  63.1977500000000,  81.3542500000000,  90.5332083333333,  90.7274166666667,  90.8630416666667,  90.7904791666667,  90.5763791666666,  90.1190625000000,
             89.5976625000000,  88.9683964285714,  88.1875857142857,  87.4745535714286,  86.8648353174603,  86.5406809523809,  86.4262830808081,  86.4413116161616,  86.4596270104895,  86.4576728687979,
             86.5316151556777,  86.5976538663542,  86.6975181489262,  86.7923007288442,  86.7608821809425,  86.6849764619883,  86.4810361842105,  86.2045236842105,  85.9179875000000,  85.7217875000000,
             85.6731214285714,  85.7294946428571,  85.8820685064935,  86.1150389610390,  86.4291412337662,  86.8542435064935,  87.1897624458874,  87.4640642857143,  87.6829172619047,  87.8553064223057,
             87.9218177631579,  87.9011081656347,  87.8265154798762,  87.7802132352941,  87.8975367647059,  87.9932665441176,  88.0649329044118,  88.1058593750000,  88.0771718750000,  87.9885156250000,
             87.8919218750000,  87.8735468750000,  87.9217812500000,  88.0132343750000,  88.1667968750000,  88.3524062500000,  88.5845312500000,  88.8867187500000,  89.2125000000000,  89.3545928308824,
             89.4090386029412,  89.2706643178105,  89.1179705882353,  89.2742091503268,  89.6278143274854,  90.2226447368421,  90.9753333333333,  91.7409342105263,  92.5893245614035,  93.3576615497076,
             94.0969948830409,  94.8495138888889,  95.5591111111111,  96.4495179738562,  97.4016168300654,  98.4999640522876,  99.7313676470588, 101.1202794117650, 102.8572647058820, 104.2939607843140,
            105.8849452614380, 107.0814910990710, 108.1507799707600, 108.9417928362570, 109.6523348684210, 110.1277241228070, 110.5267148809520, 110.9164619047620, 111.3471666666670, 111.8653571428570,
            112.3597857142860, 112.7992380952380, 113.1747142857140, 113.5586666666670, 114.0577738095240, 114.6932047619050, 115.2846898809520, 115.7229029761900, 115.8414500000000, 115.7467000000000,
            115.6115500000000, 115.5303375000000, 115.5548000000000, 115.6614000000000, 115.9122375000000, 116.3321625000000, 116.8428375000000, 117.2830500000000, 117.7253922619050, 118.0727228896100,
            118.4984101731600, 119.2198956709960, 120.0234311688310, 120.9289954887220, 121.7905789473680, 122.5689105263160, 123.2356894736840, 123.8346386591480, 124.4085501367050, 124.8498862554110,
            125.4094954004330, 126.1065170454550, 126.7064925000000, 127.4240825000000, 127.8647176923080, 128.0896789173790, 128.1540621001220, 128.0788455784320, 128.1446725050170, 128.3183694581280,
            128.4362103448280, 128.5848821839080, 128.6186973303670, 128.7719790322580, 128.8848929180570, 128.9942553260240, 129.0945314906040, 129.1530999536860, 129.0838581603580, 128.8024011680910,
            128.4259584615380, 127.8496453846150, 127.2448900000000, 126.6843541666670, 126.1858333333330, 125.7495416666670, 125.2761041666670, 124.7606666666670, 124.3471666666670, 124.0095208333330,
            123.7731875000000, 123.6621125000000, 123.6056416666670, 123.5744416666670, 123.5148250000000, 123.4937083333330, 123.4761041666670, 123.6832443181820, 124.0308714826840, 124.5405766233770,
            125.2020811061750, 125.8966645363410, 126.4680156432750, 126.9272675438600, 127.4003611111110, 127.8605833333330, 128.1324342105260, 128.3722748538010, 128.6053611111110, 128.6804526315790,
            128.7627552631580, 128.7694289473680, 128.7595250000000, 128.7409750000000, 128.6613250000000, 128.4858250000000, 128.2154750000000, 127.8500845238100, 127.4645440476190, 127.1153875541130,
            126.7443323451910, 126.3035666290230, 125.8504999604740, 125.3674468450390, 124.8902561172160, 124.3766410622710, 123.8351980503370, 123.2633556835640, 122.5153494623660, 121.7438575268820,
            120.2481227342550, 118.4358502645500, 116.5046713064710, 114.5443467073670, 112.9054354415950, 111.4893484615380, 110.7192281481480, 110.1931396825400, 110.2034782445810, 110.1120396292030,
            109.5987628888250, 108.8005075604840, 107.8019843750000, 106.8111562500000, 105.6388140120970, 104.3560227486560, 102.7347166042630, 101.0735459592080,  99.5273900488400,  98.3256981583231,
             97.3580796011396,  96.7594046153846,  96.4602600000000,  96.1232166666667,  96.1488191666667,  96.4425624637681,  96.7984085144927,  97.1613937318841,  97.3868053381643,  97.5343687643678,
             97.8406773180077,  98.3334693486590,  99.0595665024631,  99.8837727832512, 100.6778885467980, 101.4226269841270, 102.0713564814810, 102.6847440476190, 103.2616851851850, 103.9931695156700,
            104.8224465811970, 105.7652606837610, 106.6112275641030, 107.5680471014490, 108.3253364624510, 108.8823498494260, 109.2757501411630, 109.6873409090910, 110.1830037593980, 110.4551917293230
        };
        #endregion

        #region NameTest
        /// <summary>
        /// A test for Name.
        /// </summary>
        [TestMethod]
        public void NameTest()
        {
            var target = new InstantaneousTrendLine();
            Assert.AreEqual("ITL", target.Name);
        }
        #endregion

        #region MonikerTest
        /// <summary>
        /// A test for Moniker.
        /// </summary>
        [TestMethod]
        public void MonikerTest()
        {
            var target = new InstantaneousTrendLine();
            Assert.AreEqual("ITL4", target.Moniker);
            //target = new InstantaneousTrendLine(4);
            //Assert.AreEqual("ITL4", target.Moniker);
            target = new InstantaneousTrendLine(/*3*/);
            Assert.AreEqual("ITL3", target.Moniker);
            target = new InstantaneousTrendLine(/*2*/);
            Assert.AreEqual("ITL2", target.Moniker);
        }
        #endregion

        #region DescriptionTest
        /// <summary>
        /// A test for Description.
        /// </summary>
        [TestMethod]
        public void DescriptionTest()
        {
            var target = new InstantaneousTrendLine();
            Assert.AreEqual("Instantaneous Trend Line", target.Description);
        }
        #endregion

        #region SmoothingLengthTest
        /// <summary>
        /// A test for SmoothingLength.
        /// </summary>
        [TestMethod]
        public void SmoothingLengthTest()
        {
            var target = new InstantaneousTrendLine();
            Assert.AreEqual(4, target.SmoothingLength);
            //target = new InstantaneousTrendLine(4);
            //Assert.AreEqual(4, target.SmoothingLength);
            target = new InstantaneousTrendLine(/*3*/);
            Assert.AreEqual(3, target.SmoothingLength);
            target = new InstantaneousTrendLine(/*2*/);
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
            var target = new InstantaneousTrendLine();
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

        #region DominantCyclePeriodTest
        /// <summary>
        /// A test for DominantCyclePeriod.
        /// </summary>
        [TestMethod]
        public void DominantCyclePeriodTest()
        {
            const int digits = 9;
            var target = new InstantaneousTrendLine();
            // Tradestation implementation skips first 9 bars.
            for (int i = 9; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                double d = Math.Round(target.DominantCyclePeriod, digits);
                double u = Math.Round(dcPeriod[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
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
            var target = new InstantaneousTrendLine();
            // Tradestation implementation skips first 9 bars.
            for (int i = 9; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                double d = Math.Round(target.Value, digits);
                double u = Math.Round(itl[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
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
            var target = new InstantaneousTrendLine();
            // Tradestation implementation skips first 9 bars.
            for (int i = 9; i < rawInput.Count; i++)
            {
                target.Update(rawInput[i]);
                d = Math.Round(target.Value, digits);
                u = Math.Round(itl[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
            target.Reset();
            for (int i = 9; i < rawInput.Count; i++)
            {
                target.Update(rawInput[i]);
                d = Math.Round(target.Value, digits);
                u = Math.Round(itl[i], digits);
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
        public void InstantaneousTrendLineConstructorTest()
        {
            var target = new InstantaneousTrendLine();
            Assert.AreEqual(4, target.SmoothingLength);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new InstantaneousTrendLine(ohlcvComponent:OhlcvComponent.TypicalPrice);
            Assert.AreEqual(4, target.SmoothingLength);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.TypicalPrice);

            target = new InstantaneousTrendLine(/*3*/);
            Assert.AreEqual(3, target.SmoothingLength);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new InstantaneousTrendLine(/*3,*/ ohlcvComponent:OhlcvComponent.OpeningPrice);
            Assert.AreEqual(3, target.SmoothingLength);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.OpeningPrice);

            target = new InstantaneousTrendLine(/*2*/);
            Assert.AreEqual(2, target.SmoothingLength);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new InstantaneousTrendLine(/*2,*/ ohlcvComponent: OhlcvComponent.OpeningPrice);
            Assert.AreEqual(2, target.SmoothingLength);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.OpeningPrice);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void InstantaneousTrendLineConstructorTest2()
        {
            var target = new InstantaneousTrendLine(/*5*/);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void InstantaneousTrendLineConstructorTest3()
        {
            var target = new InstantaneousTrendLine(/*1*/);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void InstantaneousTrendLineConstructorTest4()
        {
            var target = new InstantaneousTrendLine(/*0*/);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void InstantaneousTrendLineConstructorTest5()
        {
            var target = new InstantaneousTrendLine(/*-8*/);
            Assert.IsFalse(target.IsPrimed);
        }
        #endregion

        #region SerializationTest
        private static void SerializeTo(InstantaneousTrendLine instance, string fileName)
        {
            var dcs = new DataContractSerializer(typeof(InstantaneousTrendLine), null, 65536, false, true, null);
            using (var fs = new FileStream(fileName, FileMode.Create))
            {
                dcs.WriteObject(fs, instance);
                fs.Close();
            }
        }

        private static InstantaneousTrendLine DeserializeFrom(string fileName)
        {
            var fs = new FileStream(fileName, FileMode.Open);
            XmlDictionaryReader reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());
            var ser = new DataContractSerializer(typeof(InstantaneousTrendLine), null, 65536, false, true, null);
            var instance = (InstantaneousTrendLine)ser.ReadObject(reader, true);
            reader.Close();
            fs.Close();
            return instance;
        }

        /// <summary>
        /// A test for the serialization.
        /// </summary>
        [TestMethod]
        public void SerializationTest()
        {
            double d, u; const int digits = 9;
            var source = new InstantaneousTrendLine();
            // Tradestation-implementation skips first 9 bars.
            for (int i = 9; i < 111; ++i)
            {
                source.Update(rawInput[i]);
                d = Math.Round(source.Value, digits);
                u = Math.Round(itl[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
            const string fileName = "InstantaneousTrendLine_1.xml";
            SerializeTo(source, fileName);
            InstantaneousTrendLine target = DeserializeFrom(fileName);
            Assert.AreEqual(source.Value, target.Value);
            Assert.AreEqual(source.DominantCyclePeriod, target.DominantCyclePeriod);
            // Tradestation-implementation skips first 9 bars.
            for (int i = 111; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                d = Math.Round(target.Value, digits);
                u = Math.Round(itl[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
            //FileInfo fi = new FileInfo(fileName);
            //fi.Delete();
        }
        #endregion
    }
}

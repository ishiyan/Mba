﻿using Mbst.Trading;
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
    public class DominantCyclePhaseTest
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
        private readonly List<double> dcPhase = new List<double>
        {
            double.NaN,  double.NaN,  double.NaN,  double.NaN,  double.NaN,  double.NaN,  double.NaN,  double.NaN,  double.NaN,
            double.NaN, double.NaN,  double.NaN,
            639.09090909090900,  98.05299963194700, 132.00564338345400,  69.61331949528320,  72.53929158292410,  49.31988383698000,  70.57064052204580,  95.44397344939550,  15.53098102018940,  -7.59977335936253,
             -0.43908926482948,   0.75159304711349,   6.81682854281200,  10.38041464097730,  14.60138862232650,  23.61952231391600,  34.25173964222910,  45.61939612889610,  54.93203281582900,  62.34730431858280,
             59.09332873285360,  64.74787861710400,  71.38960942346380,  78.26591034671290,  95.01873223899610, 100.81260420916600, 122.15965196914300, 155.92351856084900, 203.60327223472200, 237.36293513970900,
            244.38539212971100, 260.58654095568100, 254.66267427143100, 253.71116813655900, 126.51252837026600, 108.91084071926300, 120.62704116849900, 135.00432720483700, 148.37778407551400, 166.73764548652900,
            192.70016208445300, 227.19271648131900, 250.93069421530800, 272.91238631233800, 306.14557952390500, -30.56440912946640,  -7.29779366562593,  15.79435681229920,  37.27143784018100,  57.28482204365770,
             77.89434659794900, 100.26640790428300, 122.46792347519500, 143.34860922315100, 161.97099218663000, 179.04173949124300, 194.28337763382200, 207.12978658551400, 219.12056620855700, 228.99420937560000,
            246.39888033834300, 259.83330071373300, 279.43099672242300, 300.38982045382800, -42.95237520761510,  10.71059944380160,  67.91671263897760,  95.69661875079390, 116.17343846855600, 131.69663648791300,
            145.22435488266800, 157.96979483912800, 170.90824231177600, 190.12565895164300, 201.99948636973700, 211.84934448916700, 219.50941069822200, 223.55536694633000, 217.70267385839600, 208.61154857738600,
            187.20930268786500, 183.53325881754400, 173.77461459542900, 177.09324308654900, 177.36771678646600, 183.46254384786600, 190.38499136923400, 200.15247884572800, 210.26397611554500, 219.92876325408700,
            230.19440003342700, 241.78128922383700, 255.09398089013500, 269.90233026686000, 287.31443195349700, -22.67219169276530,  21.31042453594620,  55.99561073880190,  76.28592721136950,  93.25596317796150,
            111.58409337397600, 131.21106018529500, 148.25324978238800, 161.34668836868300, 167.25425018604100, 166.56119294454900, 164.79606018404900, 165.59339091940400, 167.71720854219100, 171.16337795073400,
            177.90397416349400, 180.76168462321900, 181.18022018527700, 182.90279528585400, 185.03420448405800, 187.45543006582800, 185.33720976352800, 183.30316508274000, 181.31467258646500, 177.91862390253700,
            179.98928550766400, 182.00429308763000, 183.62347330064100, 185.57299458485300, 189.35191538410900, 194.23220405450000, 200.11245439803000, 206.61598766532100, 214.60761785986900, 223.17826798412900,
            229.59983294953500, 238.43424165042300, 244.29554481830400, 259.55186325451500, 277.88404982202100, 297.46674550039700, -42.41381860502280, -22.05561416691630, -10.76874195668260,   4.55423903808060,
             13.05706378617280,  25.49753552893060,  31.99805128632640,  38.60334291217220,  45.70890152749460,  53.48688015996070,  60.82873486408750,  67.21350248296350,  74.98104788942620,  84.48479832948730,
             97.41668808537870, 101.86825371917200, 131.27099687518600, 148.43969963128300, 169.23915874881900, 186.79876808562800, 222.27683786450500, 226.80174114624100, 148.12023947867300, 119.78684089821000,
            123.91411010078200, 136.35086145099600, 148.39281918279000, 160.94079449625800, 171.89311802023800, 182.21130213571000, 189.94824024493000, 202.58335256387900, 215.72849327557900, 224.87477584909900,
            239.93794152235800, 257.07736337068300, 274.90021437724400, 292.81710751479900, 310.18755119542100, -34.09748283129430, -20.55209191423000, -17.48926436788570,  -6.64084597196063,  -3.41661969757843,
             -1.11706604110969,  -0.61559202318233,  -0.58343503934742,  -0.97020892968976,  -7.33789387098142, -13.71942088996000, -14.16303590443250,  -9.85074940762922,  -2.93111556519989,   0.35846302482548,
             -0.27797938543370,  -4.11254536082527,  -7.19786584394603,  -8.12930435521150,  -7.23274284499956,  -5.60008181003320,  -3.98246383052538,  -1.93459828828531,  -0.91376116945821,   1.11347590999549,
              3.48574296192987,   5.87739974191743,   8.51611669495514,  11.77045158406290,  16.98321519660290,  23.12127015453780,  32.37560208179040,  38.09489298723020,  44.37798569415560,  48.60625731428030,
             57.00174598372450,  65.55585833338270,  77.53688240972470,  96.95830008657520, 111.55989345666400, 124.32277400743800, 131.41492641407500, 137.73657404096000, 141.46543104438800, 142.80498887855200,
            149.73966957805500, 153.53899811794900, 157.79183782289500, 159.94501203849600, 162.96541156987000, 170.96418133015300, 176.71998519472000, 182.65581927371500, 189.05283471879000, 197.04766728263800,
            206.92813680000000, 217.32451174036000, 224.38800791349600, 232.20526011220900, 246.06238925337200, 271.09605242709400, 289.11924018406000,  -31.18231981512890, 23.26913353342980,  47.27652706672060
        };
        #endregion

        #region NameTest
        /// <summary>
        /// A test for Name.
        /// </summary>
        [TestMethod]
        public void NameTest()
        {
            var target = new DominantCyclePhase();
            Assert.AreEqual("DCPh", target.Name);
        }
        #endregion

        #region MonikerTest
        /// <summary>
        /// A test for Moniker.
        /// </summary>
        [TestMethod]
        public void MonikerTest()
        {
            var target = new DominantCyclePhase();
            Assert.AreEqual("DCPh4", target.Moniker);
            //target = new DominantCyclePhase(4);
            //Assert.AreEqual("DCPh4", target.Moniker);
            target = new DominantCyclePhase(/*3*/);
            Assert.AreEqual("DCPh3", target.Moniker);
            target = new DominantCyclePhase(/*2*/);
            Assert.AreEqual("DCPh2", target.Moniker);
        }
        #endregion

        #region DescriptionTest
        /// <summary>
        /// A test for Description.
        /// </summary>
        [TestMethod]
        public void DescriptionTest()
        {
            var target = new DominantCyclePhase();
            Assert.AreEqual("Dominant Cycle Phase", target.Description);
        }
        #endregion

        #region SmoothingLengthTest
        /// <summary>
        /// A test for SmoothingLength.
        /// </summary>
        [TestMethod]
        public void SmoothingLengthTest()
        {
            var target = new DominantCyclePhase();
            Assert.AreEqual(4, target.SmoothingLength);
            //target = new DominantCyclePhase(4);
            //Assert.AreEqual(4, target.SmoothingLength);
            target = new DominantCyclePhase(/*3*/);
            Assert.AreEqual(3, target.SmoothingLength);
            target = new DominantCyclePhase(/*2*/);
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
            var target = new DominantCyclePhase();
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
            var target = new DominantCyclePhase();
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
            const int digits = 8;
            var target = new DominantCyclePhase();
            // Tradestation implementation skips first 9 bars.
            for (int i = 9; i < dcPhase.Count; ++i)
            {
                target.Update(rawInput[i]);
                double d = Math.Round(target.Value, digits);
                double u = Math.Round(dcPhase[i], digits);
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
            var target = new DominantCyclePhase();
            var updatedList1 = rawInput.Select(target.Update).ToList();
            target.Reset();
            var updatedList2 = rawInput.Select(target.Update).ToList();
            for (int i = 0; i < rawInput.Count; ++i)
                Assert.AreEqual(updatedList1[i], updatedList2[i]);
        }
        #endregion

        #region ConstructorTest
        /// <summary>
        /// A test for Constructor.
        /// </summary>
        [TestMethod]
        public void DominantCyclePhaseConstructorTest()
        {
            var target = new DominantCyclePhase();
            Assert.AreEqual(4, target.SmoothingLength);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new DominantCyclePhase(/*OhlcvComponent.TypicalPrice*/);
            Assert.AreEqual(4, target.SmoothingLength);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.TypicalPrice);

            target = new DominantCyclePhase(/*3*/);
            Assert.AreEqual(3, target.SmoothingLength);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new DominantCyclePhase(/*3, OhlcvComponent.OpeningPrice*/);
            Assert.AreEqual(3, target.SmoothingLength);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.OpeningPrice);

            target = new DominantCyclePhase(/*2*/);
            Assert.AreEqual(2, target.SmoothingLength);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new DominantCyclePhase(/*2, OhlcvComponent.OpeningPrice*/);
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
        public void DominantCyclePhaseConstructorTest2()
        {
            var target = new DominantCyclePhase(/*5*/);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void DominantCyclePhaseConstructorTest3()
        {
            var target = new DominantCyclePhase(/*1*/);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void DominantCyclePhaseConstructorTest4()
        {
            var target = new DominantCyclePhase(/*0*/);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void DominantCyclePhaseConstructorTest5()
        {
            var target = new DominantCyclePhase(/*-8*/);
            Assert.IsFalse(target.IsPrimed);
        }
        #endregion

        #region SerializationTest
        private static void SerializeTo(DominantCyclePhase instance, string fileName)
        {
            var dcs = new DataContractSerializer(typeof(DominantCyclePhase), null, 65536, false, true, null);
            using (var fs = new FileStream(fileName, FileMode.Create))
            {
                dcs.WriteObject(fs, instance);
                fs.Close();
            }
        }

        private static DominantCyclePhase DeserializeFrom(string fileName)
        {
            var fs = new FileStream(fileName, FileMode.Open);
            XmlDictionaryReader reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());
            var ser = new DataContractSerializer(typeof(DominantCyclePhase), null, 65536, false, true, null);
            var instance = (DominantCyclePhase)ser.ReadObject(reader, true);
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
            const int digits = 8;
            var source = new DominantCyclePhase();
            // Tradestation-implementation skips first 9 bars.
            for (int i = 9; i < 111; ++i)
            {
                source.Update(rawInput[i]);
                double d = Math.Round(source.Value, digits);
                double u = Math.Round(dcPhase[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
            const string fileName = "DominantCyclePhase_1.xml";
            SerializeTo(source, fileName);
            DominantCyclePhase target = DeserializeFrom(fileName);
            Assert.AreEqual(source.Value, target.Value);
            for (int i = 111; i < dcPhase.Count; ++i)
            {
                target.Update(rawInput[i]);
                double d = Math.Round(target.Value, digits);
                double u = Math.Round(dcPhase[i], digits);
                Assert.AreEqual(u, d);
            }
            //FileInfo fi = new FileInfo(fileName);
            //fi.Delete();
        }
        #endregion
    }
}

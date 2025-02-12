﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Xml;
using Mbst.Trading;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using Mbst.Trading.Indicators;

namespace Tests.Indicators
{
    [TestClass]
    public class InstantaneousTrendLineNewTest
    {
        #region Test data
        /// <summary>
        /// Taken from Excel simulation, test_iTrend.xsl, price, D3…D254, 252 entries.
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
        /// Taken from Excel simulation, test_iTrend.xsl, F3…F254, 252 entries.
        /// </summary>
        private readonly List<double> iTrend = new List<double>
        {
            double.NaN, double.NaN,
            93.4143750000000,  94.6606250000000,  95.6783140625000,  96.5028085937501,  97.1425047142188,  97.5160834907126,  97.6401563403976,  97.7133538695222,  97.9891484785014,  98.6357747207628,
            99.3949330240631,  99.5492649312695,  99.0687548246491,  98.6985386722923,  98.4844531951247,  98.1021667827664,  97.6964818974821,  97.3968985914021,  96.9894308743756,  96.3628930846349,
            95.6101883741735,  94.6675583970620,  93.5694669437127,  92.4960188201866,  91.5097777334300,  90.8840107191004,  90.5890558008832,  90.3712503561927,  90.0930726753346,  89.7411074930513,
            89.4634645676785,  89.2819597876420,  89.2849665754289,  89.3474103099662,  89.1826928354487,  88.7812986218447,  88.2683926532516,  87.7948552820145,  87.3561415812497,  87.1202165702100,
            87.2278192794679,  87.4928422357355,  87.9129003511563,  88.3911077159631,  88.8853919629762,  89.2957766750993,  89.5220581069066,  89.7593357700528,  89.9428946006348,  89.8794508246620,
            89.6119166187823,  89.1350032676849,  88.4571023318091,  87.8447263234442,  87.4853735298246,  87.3245468433268,  87.3581575626426,  87.5886540642218,  87.8782063960230,  88.0378025589573,
            88.2569316727403,  88.7365899780548,  89.2366859679288,  89.7071196658280,  90.2182125722784,  90.5752654604632,  90.7519078276980,  90.8516112127636,  90.7489102755643,  90.4144026996304,
            89.8252603364769,  89.0386743309368,  88.3429065905235,  88.7275860170466,  90.1461431440628,  91.7875167268132,  93.6720233440727,  95.3716484529544,  96.6929936947067,  97.8757892751943,
            99.0308875553095, 100.2753170837600, 101.3998320667070, 102.3039571483300, 103.2506994789000, 104.3758386181630, 105.5549099754820, 106.6814094835480, 108.3724236266050, 110.4812798831640,
           112.2076534505350, 113.7013912595460, 115.0207048983880, 116.0292644981210, 116.7503266748880, 117.0897446258680, 117.1023044005030, 117.1870738705230, 117.4465108231770, 117.7226112529950,
           117.7962598446040, 117.6047708382480, 117.4753019945440, 117.4907019118500, 117.9097256109610, 118.5247906778280, 118.9974889798400, 119.2012494202490, 119.0782475779990, 118.9487386215050,
           118.9537760057880, 119.2991062120260, 119.8662051869630, 120.3872206849690, 121.0920682328380, 122.0367952426500, 122.7837697117460, 123.2732920834810, 123.7960227265840, 124.2780086984450,
           124.6653559978840, 125.3221513077800, 126.2809211549000, 127.3080974320160, 128.3959957666760, 129.4345099070680, 130.4473954385470, 131.5829000220750, 132.8019109762600, 133.9980896867510,
           135.0699315139900, 135.9289864709500, 136.6141566945170, 137.2035375530770, 137.2040195986350, 136.6338371988050, 135.8889642639190, 134.9075702376420, 133.8682685751500, 132.9897113012430,
           132.4161509046650, 131.9299026282320, 131.3641284710660, 130.7284745480260, 129.8139655697020, 128.7151168230590, 127.7321343446540, 127.1233977157930, 126.7112577566840, 126.1129417430420,
           125.5053048083030, 125.0747945048860, 124.7889321503870, 124.7920482824440, 125.0907983884760, 125.3840521930790, 125.3364243029350, 125.0278799616640, 124.7869828490870, 124.5427680954590,
           124.2463703163780, 124.0947300377010, 124.0627720584880, 124.0477320191810, 124.0667766272890, 124.2800314783690, 124.5447645698240, 124.9110409992310, 125.5852702571280, 126.4251838180240,
           127.4188999061350, 128.5624863412020, 129.5637621908190, 130.2300241134180, 130.7998251821180, 131.1815464830450, 131.1127325334490, 130.8702464590300, 130.6702691706150, 130.3042772449290,
           129.7429382449040, 129.0227467463810, 128.3368422852520, 127.7538249896240, 127.0448282131860, 126.2512776180000, 125.3251155728950, 124.3199977037770, 123.6190361450280, 123.1678904657560,
           122.4900556544710, 121.3472286784840, 120.1754689564280, 119.0886840499350, 117.6428104824650, 115.9111007875960, 114.2618150536440, 112.8558760535870, 111.6505273697750, 110.8038288340330,
           108.9618937591840, 106.1946900835270, 103.9133441430420, 102.0099799028150, 100.3656476449200,  98.8794850016057,  97.8091437048954,  97.0687907132167,  96.2677584612191,  95.3783074000063,
            94.3987057209034,  93.3299124456148,  92.3984698208342,  91.7447857175393,  91.4174101365837,  91.3136883119459,  91.1800231080881,  91.0118730850419,  90.8423728269925,  90.6194228019534,
            90.5735497785674,  91.1049063067259,  92.3268496520272,  93.8670773880834,  95.0557583027968,  95.9381300852486,  96.7935171024736,  97.4512735998693,  97.9952374538275,  98.5970656275922,
            99.6300659435061, 101.2270373436170, 103.1384979245890, 105.1121945412410, 106.8723884917320, 107.8633337859010, 108.2299870352780, 108.4704152441910, 108.4451676923830, 108.3623795131320,
            108.5329188572830, 108.7761946586380, 108.9384100454040, 109.0835916741940, 109.2248242907320, 109.3404926167510, 109.4803617381020, 109.6402028936430, 109.7532703898900, 109.7425683174850
        };

        /// <summary>
        /// Taken from Excel simulation, test_iTrend.xsl, H3…H254, 252 entries.
        /// </summary>
        private readonly List<double> trigger = new List<double>
        {
            double.NaN, double.NaN, double.NaN, double.NaN,
            97.9422531250001,  98.3449921875001,  98.6066953659376,  98.5293583876752,  98.1378079665764,  97.9106242483318,  98.3381406166052,  99.5581955720035, 100.8007175696250, 100.4627551417760,
            98.7425766252352,  97.8478124133152,  97.9001515656004,  97.5057948932404,  96.9085105998395,  96.6916304000378,  96.2823798512691,  95.3288875778678,  94.2309458739715,  92.9722237094891,
            91.5287455132518,  90.3244792433112,  89.4500885231473,  89.2720026180142,  89.6683338683363,  89.8584899932850,  89.5970895497861,  89.1109646299099,  88.8338564600224,  88.8228120822326,
            89.1064685831792,  89.4128608322904,  89.0804190954684,  88.2151869337233,  87.3540924710546,  86.8084119421843,  86.4438905092477,  86.4455778584056,  87.0994969776860,  87.8654679012610,
            88.5979814228448,  89.2893731961907,  89.8578835747961,  90.2004456342355,  90.1587242508369,  90.2228948650064,  90.3637310943630,  89.9995658792711,  89.2809386369298,  88.3905557107078,
            87.3022880448359,  86.5544493792035,  86.5136447278401,  86.8043673632094,  87.2309415954606,  87.8527612851168,  88.3982552294034,  88.4869510536929,  88.6356569494577,  89.4353773971523,
            90.2164402631173,  90.6776493536011,  91.1997391766280,  91.4434112550984,  91.2856030831175,  91.1279569650640,  90.7459127234306,  89.9771941864972,  88.9016103973896,  87.6629459622432,
            86.8605528445702,  88.4164977031563,  91.9493796976020,  94.8474474365799,  97.1979035440825,  98.9557801790956,  99.7139640453408, 100.3799300974340, 101.3687814159120, 102.6748448923260,
           103.7687765781040, 104.3325972129000, 105.1015668910930, 106.4477200879950, 107.8591204720650, 108.9869803489330, 111.1899372777270, 114.2811502827800, 116.0428832744650, 116.9215026359280,
           117.8337563462420, 118.3571377366950, 118.4799484513890, 118.1502247536150, 117.4542821261180, 117.2844031151780, 117.7907172458520, 118.2581486354660, 118.1460088660310, 117.4869304235020,
           117.1543441444840, 117.3766329854530, 118.3441492273780, 119.5588794438050, 120.0852523487190, 119.8777081626690, 119.1590061761580, 118.6962278227620, 118.8293044335770, 119.6494738025470,
           120.7786343681370, 121.4753351579120, 122.3179312787140, 123.6863698003300, 124.4754711906540, 124.5097889243120, 124.8082757414230, 125.2827253134090, 125.5346892691840, 126.3662939171150,
           127.8964863119170, 129.2940435562520, 130.5110703784520, 131.5609223821190, 132.4987951104180, 133.7312901370820, 135.1564265139730, 136.4132793514270, 137.3379520517190, 137.8598832551480,
           138.1583818750440, 138.4780886352040, 137.7938825027540, 136.0641368445340, 134.5739089292020, 133.1813032764780, 131.8475728863820, 131.0718523648450, 130.9640332341800, 130.8700939552200,
           130.3121060374670, 129.5270464678190, 128.2638026683390, 126.7017590980930, 125.6503031196060, 125.5316786085270, 125.6903811687130, 125.1024857702920, 124.2993518599220, 124.0366472667300,
           124.0725594924710, 124.5093020600020, 125.3926646265650, 125.9760561037150, 125.5820502173940, 124.6717077302490, 124.2375413952400, 124.0576562292540, 123.7057577836690, 123.6466919799430,
           123.8791738005980, 124.0007340006600, 124.0707811960900, 124.5123309375570, 125.0227525123580, 125.5420505200920, 126.6257759444330, 127.9393266368180, 129.2525295551420, 130.6997888643790,
           131.7086244755030, 131.8975618856340, 132.0358881734170, 132.1330688526710, 131.4256398847790, 130.5589464350150, 130.2278058077810, 129.7383080308290, 128.8156073191920, 127.7412162478330,
           126.9307463256010, 126.4849032328660, 125.7528141411190, 124.7487302463760, 123.6054029326050, 122.3887177895550, 121.9129567171620, 122.0157832277350, 121.3610751639140, 119.5265668912120,
           117.8608822583850, 116.8301394213860, 115.1101520085020, 112.7335175252570, 110.8808196248240, 109.8006513195780, 109.0392396859050, 108.7517816144800, 106.2732601485940, 101.5855513330210,
            98.8647945268997,  97.8252697221038,  96.8179511467976,  95.7489901003959,  95.2526397648711,  95.2580964248278,  94.7263732175427,  93.6878240867959,  92.5296529805876,  91.2815174912233,
            90.3982339207650,  90.1596589894639,  90.4363504523332,  90.8825909063525,  90.9426360795926,  90.7100578581379,  90.5047225458969,  90.2269725188648,  90.3047267301423,  91.5903898114985,
            94.0801495254871,  96.6292484694409,  97.7846669535663,  98.0091827824139,  98.5312759021504,  98.9644171144899,  99.1969578051814,  99.7428576553150, 101.2648944331850, 103.8570090596410,
           106.6469299056720, 108.9973517388660, 110.6062790588740, 110.6144730305620, 109.5875855788240, 109.0774967024800, 108.6603483494880, 108.2543437820720, 108.6206700221830, 109.1900098041450,
           109.3439012335250, 109.3909886897500, 109.5112385360600, 109.5973935593070, 109.7358991854730, 109.9399131705340, 110.0261790416790, 109.8449337413270
        };
        #endregion

        #region NameTest
        /// <summary>
        /// A test for Name.
        /// </summary>
        [TestMethod]
        public void NameTest()
        {
            var target = new InstantaneousTrendLineNew();
            Assert.AreEqual("iTrend", target.Name);
        }
        #endregion

        #region MonikerTest
        /// <summary>
        /// A test for Moniker.
        /// </summary>
        [TestMethod]
        public void MonikerTest()
        {
            var target = new InstantaneousTrendLineNew();
            Assert.AreEqual("iTrend(28)", target.Moniker);
            target = new InstantaneousTrendLineNew(3);
            Assert.AreEqual("iTrend(3)", target.Moniker);
            target = new InstantaneousTrendLineNew(2);
            Assert.AreEqual("iTrend(2)", target.Moniker);
        }
        #endregion

        #region DescriptionTest
        /// <summary>
        /// A test for Description.
        /// </summary>
        [TestMethod]
        public void DescriptionTest()
        {
            var target = new InstantaneousTrendLineNew();
            Assert.AreEqual("Instantaneous Trend Line", target.Description);
        }
        #endregion

        #region SmoothingFactorTest
        /// <summary>
        /// A test for SmoothingFactor.
        /// </summary>
        [TestMethod]
        public void SmoothingFactorTest()
        {
            var target = new InstantaneousTrendLineNew();
            Assert.AreEqual(0.07, target.SmoothingFactor);
            target = new InstantaneousTrendLineNew(0.3);
            Assert.AreEqual(0.3, target.SmoothingFactor);
            target = new InstantaneousTrendLineNew(0.2);
            Assert.AreEqual(0.2, target.SmoothingFactor);
            target = new InstantaneousTrendLineNew(0.000000001);
            Assert.AreEqual(0.000000001, target.SmoothingFactor);
            Assert.AreEqual(int.MaxValue, target.Length);
        }
        #endregion

        #region LengthTest
        /// <summary>
        /// A test for Length.
        /// </summary>
        [TestMethod]
        public void LengthTest()
        {
            var target = new InstantaneousTrendLineNew();
            Assert.AreEqual(28, target.Length);
            target = new InstantaneousTrendLineNew(3);
            Assert.AreEqual(3, target.Length);
            target = new InstantaneousTrendLineNew(2);
            Assert.AreEqual(2, target.Length);
        }
        #endregion

        #region TrendLineFacadeTest
        /// <summary>
        /// A test for TrendLineFacade.
        /// </summary>
        [TestMethod]
        public void TrendLineFacadeTest()
        {
            var target = new InstantaneousTrendLineNew();
            var facade = target.TrendLineFacade;
            Assert.AreEqual("iTrend", facade.Name);
            Assert.AreEqual("iTrend(28)", facade.Moniker);
            Assert.AreEqual("Instantaneous Trend Line", facade.Description);
            for (int i = 0; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                if (i < 4)
                    continue;
                Assert.AreEqual(target.TrendLine, facade.Update(rawInput[i]));
                Assert.IsTrue(facade.IsPrimed);
            }
        }
        #endregion

        #region TriggerLineFacadeTest
        /// <summary>
        /// A test for TriggerLineFacade.
        /// </summary>
        [TestMethod]
        public void TriggerLineFacadeTest()
        {
            var target = new InstantaneousTrendLineNew();
            var facade = target.TriggerLineFacade;
            Assert.AreEqual("iTrendTrigger", facade.Name);
            Assert.AreEqual("iTrend(28)Trigger", facade.Moniker);
            Assert.AreEqual("Instantaneous Trend Line (trigger line)", facade.Description);
            for (int i = 0; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                if (i < 4)
                    continue;
                Assert.AreEqual(target.TriggerLine, facade.Update(rawInput[i]));
                Assert.IsTrue(facade.IsPrimed);
            }
        }
        #endregion

        #region IsPrimedTest
        /// <summary>
        /// A test for IsPrimed.
        /// </summary>
        [TestMethod]
        public void IsPrimedTest()
        {
            var target = new InstantaneousTrendLineNew();
            Assert.IsFalse(target.IsPrimed);
            for (int i = 1; i <= 4; ++i)
            {
                var scalar = new Scalar(DateTime.Now, i);
                scalar = target.Update(scalar);
                Assert.IsTrue(double.IsNaN(scalar.Value));
                Assert.IsFalse(target.IsPrimed);
            }
            for (int i = 5; i <= 48; ++i)
            {
                var scalar = new Scalar(DateTime.Now, i);
                scalar = target.Update(scalar);
                Assert.IsFalse(double.IsNaN(scalar.Value));
                Assert.IsTrue(target.IsPrimed);
            }
        }
        #endregion

        #region TrendLineTest
        /// <summary>
        /// A test for TrendLine.
        /// </summary>
        [TestMethod]
        public void TrendLineTest()
        {
            const int digits = 8;
            var target = new InstantaneousTrendLineNew();
            for (int i = 0; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                if (i < 4)
                    continue;
                double d = Math.Round(target.TrendLine, digits);
                double u = Math.Round(iTrend[i], digits);
                Assert.AreEqual(u, d);
            }
        }
        #endregion

        #region TriggerLineTest
        /// <summary>
        /// A test for TriggerLine.
        /// </summary>
        [TestMethod]
        public void TriggerLineTest()
        {
            const int digits = 8;
            var target = new InstantaneousTrendLineNew();
            for (int i = 0; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                if (i < 4)
                    continue;
                double d = Math.Round(target.TriggerLine, digits);
                double u = Math.Round(trigger[i], digits);
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
            var target = new InstantaneousTrendLineNew();
            for (int i = 0; i < 50; ++i)
            {
                double w = Math.Round(target.Update(rawInput[i]), digits);
                if (i < 4)
                    continue;
                double d = Math.Round(target.TrendLine, digits);
                Assert.AreEqual(w, d);
                double u = Math.Round(iTrend[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.TriggerLine, digits);
                u = Math.Round(trigger[i], digits);
                Assert.AreEqual(u, d);
            }
            for (int i = 50; i < 100; ++i)
            {
                DateTime dateTime = DateTime.Now;
                var ohlcv = new Ohlcv(dateTime, double.NaN, rawInput[i], rawInput[i], rawInput[i], double.NaN);
                Scalar scalar = target.Update(ohlcv);
                Assert.IsTrue(target.IsPrimed);
                Assert.IsFalse(double.IsNaN(scalar.Value));
                Assert.IsFalse(double.IsNaN(target.TrendLine));
                Assert.AreEqual(scalar.Value, target.TrendLine);
                double d = Math.Round(target.TrendLine, digits);
                double u = Math.Round(iTrend[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.TriggerLine, digits);
                u = Math.Round(trigger[i], digits);
                Assert.AreEqual(u, d);
                Assert.AreEqual(dateTime, scalar.Time);
            }
            for (int i = 100; i < 150; ++i)
            {
                DateTime dateTime = DateTime.Now;
                Scalar scalar = target.Update(new Scalar(dateTime, rawInput[i]));
                Assert.IsTrue(target.IsPrimed);
                Assert.IsFalse(double.IsNaN(scalar.Value));
                Assert.IsFalse(double.IsNaN(target.TrendLine));
                Assert.AreEqual(scalar.Value, target.TrendLine);
                double d = Math.Round(target.TrendLine, digits);
                double u = Math.Round(iTrend[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.TriggerLine, digits);
                u = Math.Round(trigger[i], digits);
                Assert.AreEqual(u, d);
                Assert.AreEqual(dateTime, scalar.Time);
            }
            for (int i = 150; i < rawInput.Count; ++i)
            {
                DateTime dateTime = DateTime.Now;
                Scalar scalar = target.Update(rawInput[i], dateTime);
                Assert.IsTrue(target.IsPrimed);
                Assert.IsFalse(double.IsNaN(scalar.Value));
                Assert.IsFalse(double.IsNaN(target.TrendLine));
                Assert.AreEqual(scalar.Value, target.TrendLine);
                double d = Math.Round(target.TrendLine, digits);
                double u = Math.Round(iTrend[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.TriggerLine, digits);
                u = Math.Round(trigger[i], digits);
                Assert.AreEqual(u, d);
                Assert.AreEqual(dateTime, scalar.Time);
            }
            double z = target.Update(double.NaN);
            Assert.IsTrue(double.IsNaN(z));
        }
        #endregion

        #region ResetTest
        /// <summary>
        /// A test for Reset.
        /// </summary>
        [TestMethod]
        public void ResetTest()
        {
            double d, u; const int digits = 8;
            var target = new InstantaneousTrendLineNew();
            for (int i = 0; i < rawInput.Count; i++)
            {
                target.Update(rawInput[i]);
                if (i < 4)
                    continue;
                d = Math.Round(target.TrendLine, digits);
                u = Math.Round(iTrend[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
            target.Reset();
            for (int i = 0; i < rawInput.Count; i++)
            {
                target.Update(rawInput[i]);
                if (i < 4)
                    continue;
                d = Math.Round(target.TrendLine, digits);
                u = Math.Round(iTrend[i], digits);
                if (!double.IsNaN(d))
                    Assert.AreEqual(u, d);
            }
        }
        #endregion

        #region ToStringTest
        /// <summary>
        /// A test for ToString.
        /// </summary>
        [TestMethod]
        public void ToStringTest()
        {
            var target = new InstantaneousTrendLineNew(5);
            Assert.AreEqual("[M:iTrend(5) P:False TL:NaN TR:NaN]", target.ToString());
            target = new InstantaneousTrendLineNew(13);
            Assert.AreEqual("[M:iTrend(13) P:False TL:NaN TR:NaN]", target.ToString());
        }
        #endregion

        #region ConstructorTest
        /// <summary>
        /// A test for Constructor.
        /// </summary>
        [TestMethod]
        public void InstantaneousTrendLineNewConstructorTest()
        {
            var target = new InstantaneousTrendLineNew();
            Assert.AreEqual(28, target.Length);
            Assert.AreEqual(0.07, target.SmoothingFactor);
            Assert.IsTrue(double.IsNaN(target.TrendLine));
            Assert.IsTrue(double.IsNaN(target.TriggerLine));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new InstantaneousTrendLineNew(0.06, OhlcvComponent.TypicalPrice);
            Assert.AreEqual(32, target.Length);
            Assert.AreEqual(0.06, target.SmoothingFactor);
            Assert.IsTrue(double.IsNaN(target.TrendLine));
            Assert.IsTrue(double.IsNaN(target.TriggerLine));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.TypicalPrice);

            target = new InstantaneousTrendLineNew(28);
            Assert.AreEqual(28, target.Length);
            Assert.IsTrue(double.IsNaN(target.TrendLine));
            Assert.IsTrue(double.IsNaN(target.TriggerLine));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new InstantaneousTrendLineNew(28, OhlcvComponent.OpeningPrice);
            Assert.AreEqual(28, target.Length);
            Assert.IsTrue(double.IsNaN(target.TrendLine));
            Assert.IsTrue(double.IsNaN(target.TriggerLine));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.OpeningPrice);

            target = new InstantaneousTrendLineNew(1);
            Assert.AreEqual(1, target.Length);
            Assert.IsTrue(double.IsNaN(target.TrendLine));
            Assert.IsTrue(double.IsNaN(target.TriggerLine));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new InstantaneousTrendLineNew(2, OhlcvComponent.OpeningPrice);
            Assert.AreEqual(2, target.Length);
            Assert.IsTrue(double.IsNaN(target.TrendLine));
            Assert.IsTrue(double.IsNaN(target.TriggerLine));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.OpeningPrice);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void InstantaneousTrendLineNewConstructorTest2()
        {
            var target = new InstantaneousTrendLineNew(0);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void InstantaneousTrendLineNewConstructorTest3()
        {
            var target = new InstantaneousTrendLineNew(-8);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void InstantaneousTrendLineNewConstructorTest4()
        {
            var target = new InstantaneousTrendLineNew(-0.000000001);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void InstantaneousTrendLineNewConstructorTest5()
        {
            var target = new InstantaneousTrendLineNew(1.000000001);
            Assert.IsFalse(target.IsPrimed);
        }
        #endregion

        #region SerializationTest
        private static void SerializeTo(InstantaneousTrendLineNew instance, string fileName)
        {
            var dcs = new DataContractSerializer(typeof(InstantaneousTrendLineNew), null, 65536, false, true, null);
            using (var fs = new FileStream(fileName, FileMode.Create))
            {
                dcs.WriteObject(fs, instance);
                fs.Close();
            }
        }

        private static InstantaneousTrendLineNew DeserializeFrom(string fileName)
        {
            var fs = new FileStream(fileName, FileMode.Open);
            XmlDictionaryReader reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());
            var ser = new DataContractSerializer(typeof(InstantaneousTrendLineNew), null, 65536, false, true, null);
            var instance = (InstantaneousTrendLineNew)ser.ReadObject(reader, true);
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
            double d, u; const int digits = 8;
            var source = new InstantaneousTrendLineNew();
            for (int i = 0; i < 111; ++i)
            {
                source.Update(rawInput[i]);
                if (i < 4)
                    continue;
                d = Math.Round(source.TrendLine, digits);
                u = Math.Round(iTrend[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(source.TriggerLine, digits);
                u = Math.Round(trigger[i], digits);
                Assert.AreEqual(u, d);
            }
            const string fileName = "InstantaneousTrendLineNew_1.xml";
            SerializeTo(source, fileName);
            InstantaneousTrendLineNew target = DeserializeFrom(fileName);
            Assert.AreEqual(source.TrendLine, target.TrendLine);
            Assert.AreEqual(source.TriggerLine, target.TriggerLine);
            for (int i = 111; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                d = Math.Round(target.TrendLine, digits);
                u = Math.Round(iTrend[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.TriggerLine, digits);
                u = Math.Round(trigger[i], digits);
                Assert.AreEqual(u, d);
            }
            //FileInfo fi = new FileInfo(fileName);
            //fi.Delete();
        }
        #endregion
    }
}

using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Xml;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using Mbst.Core;
using Mbst.Indicators;

namespace Tests
{
    [TestClass]
    public class MaximumEntropySpectrumEstimatorTest
    {
        #region Test data
        /// <summary>
        /// Input price test data.
        /// </summary>
        private readonly List<double> price = new List<double>
        {
            1d, 2d, 8d, 4d, 9d, 6d, 7d, 13d, 9d, 10d, 3d, 12d
        };

        /// <summary>
        /// Output data.
        /// </summary>
        private readonly List<double> expected = new List<double>
        {
            100d, 190d, 390d, 240d, 740d, 640d, 940d, 1090d, 990d, 1290d, 1090d, 1190d
        };
        #endregion

        #region NameTest
        /// <summary>
        /// A test for Name.
        /// </summary>
        [TestMethod]
        public void NameTest()
        {
            var target = new OnBalanceVolume();
            Assert.AreEqual("OBV", target.Name);
        }
        #endregion

        #region MonikerTest
        /// <summary>
        /// A test for Moniker.
        /// </summary>
        [TestMethod]
        public void MonikerTest()
        {
            var target = new OnBalanceVolume();
            Assert.AreEqual("OBV", target.Moniker);
        }
        #endregion

        #region DescriptionTest
        /// <summary>
        /// A test for Description.
        /// </summary>
        [TestMethod]
        public void DescriptionTest()
        {
            var target = new OnBalanceVolume();
            Assert.AreEqual("On-Balance Volume", target.Description);
        }
        #endregion

        #region IsPrimedTest
        /// <summary>
        /// A test for IsPrimed.
        /// </summary>
        [TestMethod]
        public void IsPrimedTest()
        {
            var target = new OnBalanceVolume();
            Assert.IsFalse(target.IsPrimed);
            target.Update(1, 1);
            Assert.IsTrue(target.IsPrimed);
            target.Update(2, 2);
            Assert.IsTrue(target.IsPrimed);
        }
        #endregion

        #region ValueTest
        /// <summary>
        /// A test for Value.
        /// </summary>
        [TestMethod]
        public void ValueTest()
        {
            const int dec = 1;
            var target = new OnBalanceVolume();
            for (int i = 0; i < price.Count; ++i)
            {
                double d = price[i];
                var ohlcv = new Ohlcv(DateTime.Now, d, d, d, d, volume[i]);
                d = target.Update(ohlcv).Value;
                Assert.AreEqual(Math.Round(expected[i], dec), Math.Round(d, dec));
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
            var target = new OnBalanceVolume();
            const int dec = 1;
            for (int i = 0; i < price.Count; ++i)
            {
                double d = target.Update(price[i], volume[i]);
                Assert.AreEqual(Math.Round(expected[i], dec), Math.Round(d, dec));
            }
            target = new OnBalanceVolume();
            for (int i = 0; i < price.Count; ++i)
            {
                DateTime dateTime = DateTime.Now;
                Scalar scalar = target.Update(price[i], volume[i], dateTime);
                Assert.AreEqual(dateTime, scalar.Time);
                double d = scalar.Value;
                Assert.AreEqual(Math.Round(expected[i], dec), Math.Round(d, dec));
            }
            target = new OnBalanceVolume();
            foreach (double sample in price)
            {
                DateTime dateTime = DateTime.Now;
                Scalar scalar = target.Update(new Scalar(dateTime, sample));
                Assert.AreEqual(dateTime, scalar.Time);
                Assert.IsTrue(double.IsNaN(scalar.Value));
            }
            target = new OnBalanceVolume();
            foreach (double sample in price)
            {
                DateTime dateTime = DateTime.Now;
                Scalar scalar = target.Update(sample, dateTime);
                Assert.AreEqual(dateTime, scalar.Time);
                Assert.IsTrue(double.IsNaN(scalar.Value));
            }
            target = new OnBalanceVolume();
            foreach (double sample in price)
            {
                double d = target.Update(sample);
                Assert.IsTrue(double.IsNaN(d));
            }
        }
        #endregion

        #region MaximumEntropySpectrumEstimatorConstructorTest
        /// <summary>
        /// A test for MaximumEntropySpectrumEstimator constructor.
        /// </summary>
        [TestMethod]
        public void MaximumEntropySpectrumEstimatorConstructorTest()
        {
            var target = new MaximumEntropySpectrumEstimator();
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
        }
        #endregion

        #region SerializationTest
        private static void SerializeTo(OnBalanceVolume instance, string fileName)
        {
            var dcs = new DataContractSerializer(typeof(OnBalanceVolume), null, 65536, false, true, null);
            using (var fs = new FileStream(fileName, FileMode.Create))
            {
                dcs.WriteObject(fs, instance);
                fs.Close();
            }
        }

        private static OnBalanceVolume DeserializeFrom(string fileName)
        {
            var fs = new FileStream(fileName, FileMode.Open);
            XmlDictionaryReader reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());
            var ser = new DataContractSerializer(typeof(OnBalanceVolume), null, 65536, false, true, null);
            var instance = (OnBalanceVolume)ser.ReadObject(reader, true);
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
            double d;
            const int dec = 1;
            Ohlcv ohlcv;
            var source = new OnBalanceVolume();
            for (int i = 0; i < 6; ++i)
            {
                d = price[i];
                ohlcv = new Ohlcv(DateTime.Now, d, d, d, d, volume[i]);
                d = source.Update(ohlcv).Value;
                Assert.AreEqual(Math.Round(expected[i], dec), Math.Round(d, dec));
            }
            const string fileName = "OnBalanceVolumeTest_1.xml";
            SerializeTo(source, fileName);
            OnBalanceVolume target = DeserializeFrom(fileName);
            Assert.IsTrue(target.IsPrimed);
            Assert.AreEqual(Math.Round(source.Value, dec), Math.Round(target.Value, dec));
            Assert.AreEqual("OBV", target.Name);
            Assert.AreEqual("On-Balance Volume", target.Description);
            for (int i = 6; i < price.Count; ++i)
            {
                d = price[i];
                ohlcv = new Ohlcv(DateTime.Now, d, d, d, d, volume[i]);
                d = target.Update(ohlcv).Value;
                Assert.AreEqual(Math.Round(expected[i], dec), Math.Round(d, dec));
            }
            //FileInfo fi = new FileInfo(fileName);
            //fi.Delete();
        }
        #endregion
    }
}

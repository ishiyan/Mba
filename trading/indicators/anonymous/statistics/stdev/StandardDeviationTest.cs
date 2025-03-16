using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Xml;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using Mbst.Trading;
using Mbst.Trading.Indicators;

namespace Tests.Indicators
{
    /// <summary>
    /// This is a test class for StandardDeviationTest and is intended to contain all StandardDeviationTest Unit Tests.
    /// </summary>
    [TestClass]
    public class StandardDeviationTest
    {
        #region Test data
        /// <summary>
        /// Input test data, length = 5, unbiased = false (popiulation variance).
        /// Taken from TA-Lib (http://ta-lib.org/) tests, test_data.c, TA_SREF_close_daily_ref_0_PRIV[252].
        /// </summary>
        private readonly List<double> input = new List<double>
        {
            91.500000,94.815000,94.375000,95.095000,93.780000,94.625000,92.530000,92.750000,90.315000,92.470000,96.125000,
            97.250000,98.500000,89.875000,91.000000,92.815000,89.155000,89.345000,91.625000,89.875000,88.375000,87.625000,
            84.780000,83.000000,83.500000,81.375000,84.440000,89.250000,86.375000,86.250000,85.250000,87.125000,85.815000,
            88.970000,88.470000,86.875000,86.815000,84.875000,84.190000,83.875000,83.375000,85.500000,89.190000,89.440000,
            91.095000,90.750000,91.440000,89.000000,91.000000,90.500000,89.030000,88.815000,84.280000,83.500000,82.690000,
            84.750000,85.655000,86.190000,88.940000,89.280000,88.625000,88.500000,91.970000,91.500000,93.250000,93.500000,
            93.155000,91.720000,90.000000,89.690000,88.875000,85.190000,83.375000,84.875000,85.940000,97.250000,99.875000,
            104.940000,106.000000,102.500000,102.405000,104.595000,106.125000,106.000000,106.065000,104.625000,108.625000,
            109.315000,110.500000,112.750000,123.000000,119.625000,118.750000,119.250000,117.940000,116.440000,115.190000,
            111.875000,110.595000,118.125000,116.000000,116.000000,112.000000,113.750000,112.940000,116.000000,120.500000,
            116.620000,117.000000,115.250000,114.310000,115.500000,115.870000,120.690000,120.190000,120.750000,124.750000,
            123.370000,122.940000,122.560000,123.120000,122.560000,124.620000,129.250000,131.000000,132.250000,131.000000,
            132.810000,134.000000,137.380000,137.810000,137.880000,137.250000,136.310000,136.250000,134.630000,128.250000,
            129.000000,123.870000,124.810000,123.000000,126.250000,128.380000,125.370000,125.690000,122.250000,119.370000,
            118.500000,123.190000,123.500000,122.190000,119.310000,123.310000,121.120000,123.370000,127.370000,128.500000,
            123.870000,122.940000,121.750000,124.440000,122.000000,122.370000,122.940000,124.000000,123.190000,124.560000,
            127.250000,125.870000,128.860000,132.000000,130.750000,134.750000,135.000000,132.380000,133.310000,131.940000,
            130.000000,125.370000,130.130000,127.120000,125.190000,122.000000,125.000000,123.000000,123.500000,120.060000,
            121.000000,117.750000,119.870000,122.000000,119.190000,116.370000,113.500000,114.250000,110.000000,105.060000,
            107.000000,107.870000,107.000000,107.120000,107.000000,91.000000,93.940000,93.870000,95.500000,93.000000,
            94.940000,98.250000,96.750000,94.810000,94.370000,91.560000,90.250000,93.940000,93.620000,97.000000,95.000000,
            95.870000,94.060000,94.620000,93.750000,98.000000,103.940000,107.870000,106.060000,104.500000,105.000000,
            104.190000,103.060000,103.420000,105.270000,111.870000,116.000000,116.620000,118.280000,113.370000,109.000000,
            109.700000,109.250000,107.000000,109.190000,110.000000,109.200000,110.120000,108.000000,108.620000,109.750000,
            109.810000,109.000000,108.750000,107.870000
        };

        /// <summary>
        /// Length 5 output data.
        /// Taken from TA-Lib (http://ta-lib.org/) tests, test_stddev.c, TA_SREF_close_daily_ref_0_PRIV[252].
        /// /*************************/
        /// /*      STDDEV TEST      */
        /// /*************************/
        /// { 1, 0, 251, 5, 1.0, TA_SUCCESS,     0, 1.2856,  4,  252-4 }, /* First Value */
        /// { 0, 0, 251, 5, 1.0, TA_SUCCESS,     1, 0.4462,  4,  252-4 }, 
        /// { 0, 0, 251, 5, 1.0, TA_SUCCESS, 252-5, 0.7144,  4,  252-4 }, /* Last Value */
        /// </summary>
        private readonly List<double> expected = new List<double>
        {
            // Values from index=0 to indeex=3 are double.NaN.
            1.2856, // Index=4 value.
            0.4462, // Index=5 value.
            0.7144  // Index=251 (last) value.
        };
        #endregion

        #region NameTest
        /// <summary>
        /// A test for Name.
        /// </summary>
        [TestMethod]
        public void NameTest()
        {
            var target = new StandardDeviation(5);
            Assert.AreEqual("STDEV", target.Name);
        }
        #endregion

        #region MonikerTest
        /// <summary>
        /// A test for Moniker.
        /// </summary>
        [TestMethod]
        public void MonikerTest()
        {
            var target = new StandardDeviation(4);
            Assert.AreEqual("STDEV4", target.Moniker);
        }
        #endregion

        #region DescriptionTest
        /// <summary>
        /// A test for Description.
        /// </summary>
        [TestMethod]
        public void DescriptionTest()
        {
            var target = new StandardDeviation(3);
            Assert.AreEqual("Standard Deviation", target.Description);
        }
        #endregion

        #region IsPrimedTest
        /// <summary>
        /// A test for IsPrimed.
        /// </summary>
        [TestMethod]
        public void IsPrimedTest()
        {
            var target = new StandardDeviation(5);
            Assert.IsFalse(target.IsPrimed);
            var scalar = new Scalar(DateTime.Now, 1d);
            for (int i = 1; i < 5; i++)
            {
                scalar.Value = i;
                target.Update(scalar);
                Assert.IsFalse(target.IsPrimed);
            }
            for (int i = 5; i < 10; i++)
            {
                scalar.Value = i;
                target.Update(scalar);
                Assert.IsTrue(target.IsPrimed);
            }
        }
        #endregion

        #region TaLibTest
        /// <summary>
        /// A TA-Lib data test.
        /// </summary>
        [TestMethod]
        public void TaLibTest()
        {
            int count = input.Count;
            const int dec = 4;
            double d;
            var target = new StandardDeviation(5, false);
            for (int i = 0; i < 4; i++)
            {
                d = target.Update(input[i]);
                Assert.IsTrue(double.IsNaN(d));
            }
            d = target.Update(input[4]);
            Assert.AreEqual(expected[0], Math.Round(d, dec));
            d = target.Update(input[5]);
            Assert.AreEqual(expected[1], Math.Round(d, dec));
            for (int i = 6; i < count; i++)
                d = target.Update(input[i]);
            Assert.AreEqual(expected[2], Math.Round(d, dec));
        }
        #endregion

        #region WolframValueTest
        /// <summary>
        /// Taken from http://reference.wolfram.com/mathematica/ref/StandardDeviation.html,
        /// Basic Examples
        /// Standard deviation of a list of numbers (unbiased):
        /// In[1]:=StandardDeviation[{1.21, 3.4, 2, 4.66, 1.5, 5.61, 7.22}]
        /// Out[1]=2.27183
        /// </summary>
        [TestMethod]
        public void WolframValueTest()
        {
            var target = new StandardDeviation(7);
            double d = target.Update(1.21);
            Assert.IsTrue(double.IsNaN(d));
            d = target.Update(3.4);
            Assert.IsTrue(double.IsNaN(d));
            d = target.Update(2d);
            Assert.IsTrue(double.IsNaN(d));
            d = target.Update(4.66);
            Assert.IsTrue(double.IsNaN(d));
            d = target.Update(1.5);
            Assert.IsTrue(double.IsNaN(d));
            d = target.Update(5.61);
            Assert.IsTrue(double.IsNaN(d));
            d = target.Update(7.22);
            Assert.IsFalse(double.IsNaN(d));
            Assert.AreEqual(2.27183, Math.Round(d, 5));
        }
        #endregion

        #region LengthTest
        /// <summary>
        /// A test for Length.
        /// </summary>
        [TestMethod]
        public void LengthTest()
        {
            var target = new StandardDeviation(11);
            Assert.AreEqual(11, target.Length);
            target = new StandardDeviation(22);
            Assert.AreEqual(22, target.Length);
        }
        #endregion

        #region UpdateTest
        /// <summary>
        /// A test for Update.
        /// </summary>
        [TestMethod]
        public void UpdateTest()
        {
            int count = input.Count;
            const int dec = 4;
            double d;
            var scalar = new Scalar(DateTime.Now, 1d);
            var target = new StandardDeviation(5, false);
            for (int i = 0; i < 4; i++)
            {
                scalar.Value = input[i];
                d = target.Update(scalar).Value;
                Assert.IsTrue(double.IsNaN(d));
            }
            scalar.Value = input[4];
            d = target.Update(scalar).Value;
            Assert.AreEqual(expected[0], Math.Round(d, dec));
            scalar.Value = input[5];
            d = target.Update(scalar).Value;
            Assert.AreEqual(expected[1], Math.Round(d, dec));
            for (int i = 6; i < count; i++)
            {
                scalar.Value = input[i];
                d = target.Update(scalar).Value;
            }
            Assert.AreEqual(expected[2], Math.Round(d, dec));
        }
        #endregion

        #region CalculateTest
        /// <summary>
        /// A test for Calculate.
        /// </summary>
        [TestMethod]
        public void CalculateTest()
        {
            const int dec = 4;
            List<double> actual = StandardDeviation.Calculate(input, 5, false);
            for (int i = 0; i < 4; i++)
                Assert.IsTrue(double.IsNaN(actual[i]));
            Assert.AreEqual(expected[0], Math.Round(actual[4], dec));
            Assert.AreEqual(expected[1], Math.Round(actual[5], dec));
            Assert.AreEqual(expected[2], Math.Round(actual[251], dec));
        }
        #endregion

        #region ResetTest
        /// <summary>
        /// A test for Reset.
        /// </summary>
        [TestMethod]
        public void ResetTest()
        {
            int count = input.Count;
            const int dec = 4;
            double d;
            var target = new StandardDeviation(5, false);
            for (int i = 0; i < 4; i++)
            {
                d = target.Update(input[i]);
                Assert.IsTrue(double.IsNaN(d));
            }
            d = target.Update(input[4]);
            Assert.AreEqual(expected[0], Math.Round(d, dec));
            d = target.Update(input[5]);
            Assert.AreEqual(expected[1], Math.Round(d, dec));
            for (int i = 6; i < count; i++)
                d = target.Update(input[i]);
            Assert.AreEqual(expected[2], Math.Round(d, dec));
            target.Reset();
            for (int i = 0; i < 4; i++)
            {
                d = target.Update(input[i]);
                Assert.IsTrue(double.IsNaN(d));
            }
            d = target.Update(input[4]);
            Assert.AreEqual(expected[0], Math.Round(d, dec));
            d = target.Update(input[5]);
            Assert.AreEqual(expected[1], Math.Round(d, dec));
            for (int i = 6; i < count; i++)
                d = target.Update(input[i]);
            Assert.AreEqual(expected[2], Math.Round(d, dec));
        }
        #endregion

        #region StandardDeviationConstructorTest
        /// <summary>
        /// A test for StandardDeviation Constructor.
        /// </summary>
        [TestMethod]
        public void StandardDeviationConstructorTest()
        {
            var target = new StandardDeviation(5);
            Assert.AreEqual(5, target.Length);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
        }
        #endregion

        #region StandardDeviationConstructorTest2
        /// <summary>
        /// A test for StandardDeviation Constructor.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void StandardDeviationConstructorTest2()
        {
            var target = new StandardDeviation(1);
            Assert.IsNotNull(target);
        }
        #endregion

        #region StandardDeviationConstructorTest3
        /// <summary>
        /// A test for StandardDeviation Constructor.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void StandardDeviationConstructorTest3()
        {
            var target = new StandardDeviation(-8);
            Assert.IsNotNull(target);
        }
        #endregion

        #region SerializationTest
        private static void SerializeTo(StandardDeviation instance, string fileName)
        {
            var dcs = new DataContractSerializer(typeof(StandardDeviation), null, 65536, false, true, null);
            using (var fs = new FileStream(fileName, FileMode.Create))
            {
                dcs.WriteObject(fs, instance);
                fs.Close();
            }
        }

        private static StandardDeviation DeserializeFrom(string fileName)
        {
            var fs = new FileStream(fileName, FileMode.Open);
            XmlDictionaryReader reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());
            var ser = new DataContractSerializer(typeof(StandardDeviation), null, 65536, false, true, null);
            var instance = (StandardDeviation)ser.ReadObject(reader, true);
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
            int count = input.Count;
            const int dec = 4;
            double d;
            var source = new StandardDeviation(5, false);
            for (int i = 0; i < 4; i++)
            {
                d = source.Update(input[i]);
                Assert.IsTrue(double.IsNaN(d));
            }
            d = source.Update(input[4]);
            Assert.AreEqual(expected[0], Math.Round(d, dec));
            const string fileName = "StandardDeviationTest_1.xml";
            SerializeTo(source, fileName);
            StandardDeviation target = DeserializeFrom(fileName);
            Assert.AreEqual(5, target.Length);
            Assert.IsTrue(target.IsPrimed);
            Assert.AreEqual(expected[0], Math.Round(target.Value, dec));
            Assert.AreEqual("STDEV", target.Name);
            Assert.AreEqual("Standard Deviation", target.Description);
            Assert.AreEqual(false, target.IsUnbiased);
            d = target.Update(input[5]);
            Assert.AreEqual(expected[1], Math.Round(d, dec));
            for (int i = 6; i < count; i++)
                d = target.Update(input[i]);
            Assert.AreEqual(expected[2], Math.Round(d, dec));
            //FileInfo fi = new FileInfo(fileName);
            //fi.Delete();
        }
        #endregion
    }
}

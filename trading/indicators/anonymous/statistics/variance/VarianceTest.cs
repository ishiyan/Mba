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
    [TestClass]
    public class VarianceTest
    {
        #region Test data
        /// <summary>
        /// Input test data (population variance).
        /// </summary>
        private readonly List<double> input = new List<double>
        {
            1d, 2d, 8d, 4d, 9d, 6d, 7d, 13.0, 9d, 10d, 3d, 12
        };

        /// <summary>
        /// Length 3 output data.
        /// </summary>
        private readonly List<double> expected3 = new List<double>
        {
            double.NaN/*0.2222222222222220*/, double.NaN/*0.6666666666666670*/,
            9.5555555555555600, 6.2222222222222200, 4.6666666666666600, 4.2222222222222300, 1.5555555555555600,
            9.5555555555555700, 6.2222222222222400, 2.8888888888889000, 9.5555555555555600, 14.8888888888889000
        };

        /// <summary>
        /// Length 5 output data.
        /// </summary>
        private readonly List<double> expected5 = new List<double>
        {
            double.NaN/*0.160*/, double.NaN/*0.640*/, double.NaN/*8.960*/, double.NaN/*8.000*/,
            10.160, 6.560, 2.960, 9.360, 5.760, 6.000, 11.040, 12.240
        };
        #endregion

        #region NameTest
        /// <summary>
        /// A test for Name.
        /// </summary>
        [TestMethod]
        public void NameTest()
        {
            var target = new Variance(5);
            Assert.AreEqual("VAR", target.Name);
        }
        #endregion

        #region MonikerTest
        /// <summary>
        /// A test for Moniker.
        /// </summary>
        [TestMethod]
        public void MonikerTest()
        {
            var target = new Variance(4);
            Assert.AreEqual("VAR4", target.Moniker);
        }
        #endregion

        #region DescriptionTest
        /// <summary>
        /// A test for Description.
        /// </summary>
        [TestMethod]
        public void DescriptionTest()
        {
            var target = new Variance(3);
            Assert.AreEqual("Variance", target.Description);
        }
        #endregion

        #region IsPrimedTest
        /// <summary>
        /// A test for IsPrimed.
        /// </summary>
        [TestMethod]
        public void IsPrimedTest()
        {
            var target = new Variance(5);
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

        #region ValueTest
        /// <summary>
        /// A test for Value.
        /// </summary>
        [TestMethod]
        public void ValueTest()
        {
            const int dec = 9;
            var target = new Variance(5, false);
            Assert.IsTrue(double.IsNaN(target.Value));
            var scalar = new Scalar(DateTime.Now, 1d);
            Assert.IsTrue(double.IsNaN(target.Update(scalar).Value));
            scalar.Value = 2d;
            Assert.IsTrue(double.IsNaN(target.Update(scalar).Value));
            scalar.Value = 8d;
            Assert.IsTrue(double.IsNaN(target.Update(scalar).Value));
            scalar.Value = 4d;
            Assert.IsTrue(double.IsNaN(target.Update(scalar).Value));
            scalar.Value = 9d;
            Assert.AreEqual(Math.Round(10.160, dec), Math.Round(target.Update(scalar).Value, dec));
            scalar.Value = 6d;
            Assert.AreEqual(Math.Round(6.560, dec), Math.Round(target.Update(scalar).Value, dec));
            scalar.Value = 7d;
            Assert.AreEqual(Math.Round(2.960, dec), Math.Round(target.Update(scalar).Value, dec));
        }
        #endregion

        #region LengthTest
        /// <summary>
        /// A test for Length.
        /// </summary>
        [TestMethod]
        public void LengthTest()
        {
            var target = new Variance(11);
            Assert.AreEqual(11, target.Length);
            target = new Variance(22);
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
            const int dec = 9;
            double d;
            var scalar = new Scalar(DateTime.Now, 1d);
            int count = input.Count;
            var target = new Variance(3, false);
            for (int i = 0; i < 2; i++)
            {
                scalar.Value = input[i];
                d = target.Update(scalar).Value;
                Assert.IsTrue(double.IsNaN(d));
            }
            for (int i = 2; i < count; i++)
            {
                scalar.Value = input[i];
                d = target.Update(scalar).Value;
                Assert.AreEqual(Math.Round(expected3[i], dec), Math.Round(d, dec));
            }

            target = new Variance(5, false);
            for (int i = 0; i < 4; i++)
            {
                scalar.Value = input[i];
                d = target.Update(scalar).Value;
                Assert.IsTrue(double.IsNaN(d));
            }
            for (int i = 4; i < count; i++)
            {
                scalar.Value = input[i];
                d = target.Update(scalar).Value;
                Assert.AreEqual(Math.Round(expected5[i], dec), Math.Round(d, dec));
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
            const int dec = 9;
            List<double> actual = Variance.Calculate(input, 3, false);
            for (int i = 0; i < 2; i++)
                Assert.IsTrue(double.IsNaN(actual[i]));
            for (int i = 2; i < input.Count; i++)
                Assert.AreEqual(Math.Round(expected3[i], dec), Math.Round(actual[i], dec));

            actual = Variance.Calculate(input, 5, false);
            for (int i = 0; i < 4; i++)
                Assert.IsTrue(double.IsNaN(actual[i]));
            for (int i = 4; i < input.Count; i++)
                Assert.AreEqual(Math.Round(expected5[i], dec), Math.Round(actual[i], dec));
        }
        #endregion

        #region ResetTest
        /// <summary>
        /// A test for Reset.
        /// </summary>
        [TestMethod]
        public void ResetTest()
        {
            const int dec = 9;
            var target = new Variance(3, false);
            Assert.IsTrue(double.IsNaN(target.Update(1d)));
            Assert.IsTrue(double.IsNaN(target.Update(2d)));
            Assert.AreEqual(Math.Round(9.5555555555555600, dec), Math.Round(target.Update(8d), dec));
            target.Reset();
            Assert.IsTrue(double.IsNaN(target.Update(1d)));
            Assert.IsTrue(double.IsNaN(target.Update(2d)));
            Assert.AreEqual(Math.Round(9.5555555555555600, dec), Math.Round(target.Update(8d), dec));
        }
        #endregion

        #region VarianceConstructorTest
        /// <summary>
        /// A test for Variance Constructor.
        /// </summary>
        [TestMethod]
        public void VarianceConstructorTest()
        {
            var target = new Variance(5);
            Assert.AreEqual(5, target.Length);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsFalse(target.IsPrimed);
        }
        #endregion

        #region VarianceConstructorTest2
        /// <summary>
        /// A test for Variance Constructor.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void VarianceConstructorTest2()
        {
            var target = new Variance(1);
            Assert.IsNotNull(target);
        }
        #endregion

        #region VarianceConstructorTest3
        /// <summary>
        /// A test for Variance Constructor.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void VarianceConstructorTest3()
        {
            var target = new Variance(-8);
            Assert.IsNotNull(target);
        }
        #endregion

        #region SerializationTest
        private static void SerializeTo(Variance instance, string fileName)
        {
            var dcs = new DataContractSerializer(typeof(Variance), null, 65536, false, true, null);
            using (var fs = new FileStream(fileName, FileMode.Create))
            {
                dcs.WriteObject(fs, instance);
                fs.Close();
            }
        }

        private static Variance DeserializeFrom(string fileName)
        {
            var fs = new FileStream(fileName, FileMode.Open);
            XmlDictionaryReader reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());
            var ser = new DataContractSerializer(typeof(Variance), null, 65536, false, true, null);
            var instance = (Variance)ser.ReadObject(reader, true);
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
            const int dec = 9;
            var source = new Variance(3, false);
            source.Update(1d);
            source.Update(2d);
            source.Update(8d);
            const string fileName = "VarianceTest_1.xml";
            SerializeTo(source, fileName);
            Variance target = DeserializeFrom(fileName);
            Assert.AreEqual(3, target.Length);
            Assert.IsTrue(target.IsPrimed);
            Assert.AreEqual(false, target.IsUnbiased);
            Assert.AreEqual(Math.Round(9.5555555555555600, dec), Math.Round(target.Value, dec));
            Assert.AreEqual(Math.Round(6.2222222222222200, dec), Math.Round(target.Update(4d), dec));
            Assert.AreEqual("VAR", target.Name);
            Assert.AreEqual("Variance", target.Description);
            //FileInfo fi = new FileInfo(fileName);
            //fi.Delete();
        }
        #endregion
    }
}

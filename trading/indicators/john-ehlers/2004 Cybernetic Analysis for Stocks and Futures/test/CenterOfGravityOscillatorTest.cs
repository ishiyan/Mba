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
    public class CenterOfGravityOscillatorTest
    {
        #region Test data
        /// <summary>
        /// Taken from TA-Lib Excel simulation (TALib data), test_Cog.xsl, high price, B3…B254, 252 entries.
        /// </summary>
        private readonly List<double> talibHigh = new List<double>
        {
            93.250000,94.940000,96.375000,96.190000,96.000000,94.720000,95.000000,93.720000,92.470000,92.750000,96.250000,
            99.625000,99.125000,92.750000,91.315000,93.250000,93.405000,90.655000,91.970000,92.250000,90.345000,88.500000,
            88.250000,85.500000,84.440000,84.750000,84.440000,89.405000,88.125000,89.125000,87.155000,87.250000,87.375000,
            88.970000,90.000000,89.845000,86.970000,85.940000,84.750000,85.470000,84.470000,88.500000,89.470000,90.000000,
            92.440000,91.440000,92.970000,91.720000,91.155000,91.750000,90.000000,88.875000,89.000000,85.250000,83.815000,
            85.250000,86.625000,87.940000,89.375000,90.625000,90.750000,88.845000,91.970000,93.375000,93.815000,94.030000,
            94.030000,91.815000,92.000000,91.940000,89.750000,88.750000,86.155000,84.875000,85.940000,99.375000,103.280000,
            105.375000,107.625000,105.250000,104.500000,105.500000,106.125000,107.940000,106.250000,107.000000,108.750000,
            110.940000,110.940000,114.220000,123.000000,121.750000,119.815000,120.315000,119.375000,118.190000,116.690000,
            115.345000,113.000000,118.315000,116.870000,116.750000,113.870000,114.620000,115.310000,116.000000,121.690000,
            119.870000,120.870000,116.750000,116.500000,116.000000,118.310000,121.500000,122.000000,121.440000,125.750000,
            127.750000,124.190000,124.440000,125.750000,124.690000,125.310000,132.000000,131.310000,132.250000,133.880000,
            133.500000,135.500000,137.440000,138.690000,139.190000,138.500000,138.130000,137.500000,138.880000,132.130000,
            129.750000,128.500000,125.440000,125.120000,126.500000,128.690000,126.620000,126.690000,126.000000,123.120000,
            121.870000,124.000000,127.000000,124.440000,122.500000,123.750000,123.810000,124.500000,127.870000,128.560000,
            129.630000,124.870000,124.370000,124.870000,123.620000,124.060000,125.870000,125.190000,125.620000,126.000000,
            128.500000,126.750000,129.750000,132.690000,133.940000,136.500000,137.690000,135.560000,133.560000,135.000000,
            132.380000,131.440000,130.880000,129.630000,127.250000,127.810000,125.000000,126.810000,124.750000,122.810000,
            122.250000,121.060000,120.000000,123.250000,122.750000,119.190000,115.060000,116.690000,114.870000,110.870000,
            107.250000,108.870000,109.000000,108.500000,113.060000,93.000000,94.620000,95.120000,96.000000,95.560000,
            95.310000,99.000000,98.810000,96.810000,95.940000,94.440000,92.940000,93.940000,95.500000,97.060000,97.500000,
            96.250000,96.370000,95.000000,94.870000,98.250000,105.120000,108.440000,109.870000,105.000000,106.000000,
            104.940000,104.500000,104.440000,106.310000,112.870000,116.500000,119.190000,121.000000,122.120000,111.940000,
            112.750000,110.190000,107.940000,109.690000,111.060000,110.440000,110.120000,110.310000,110.440000,110.000000,
            110.750000,110.500000,110.500000,109.500000
        };

        /// <summary>
        /// Taken from TA-Lib Excel simulation (TALib data), test_Cog.xsl, low price, C3…C254, 252 entries.
        /// </summary>
        private readonly List<double> talibLow = new List<double>
        {
            90.750000,91.405000,94.250000,93.500000,92.815000,93.500000,92.000000,89.750000,89.440000,90.625000,92.750000,
            96.315000,96.030000,88.815000,86.750000,90.940000,88.905000,88.780000,89.250000,89.750000,87.500000,86.530000,
            84.625000,82.280000,81.565000,80.875000,81.250000,84.065000,85.595000,85.970000,84.405000,85.095000,85.500000,
            85.530000,87.875000,86.565000,84.655000,83.250000,82.565000,83.440000,82.530000,85.065000,86.875000,88.530000,
            89.280000,90.125000,90.750000,89.000000,88.565000,90.095000,89.000000,86.470000,84.000000,83.315000,82.000000,
            83.250000,84.750000,85.280000,87.190000,88.440000,88.250000,87.345000,89.280000,91.095000,89.530000,91.155000,
            92.000000,90.530000,89.970000,88.815000,86.750000,85.065000,82.030000,81.500000,82.565000,96.345000,96.470000,
            101.155000,104.250000,101.750000,101.720000,101.720000,103.155000,105.690000,103.655000,104.000000,105.530000,
            108.530000,108.750000,107.750000,117.000000,118.000000,116.000000,118.500000,116.530000,116.250000,114.595000,
            110.875000,110.500000,110.720000,112.620000,114.190000,111.190000,109.440000,111.560000,112.440000,117.500000,
            116.060000,116.560000,113.310000,112.560000,114.000000,114.750000,118.870000,119.000000,119.750000,122.620000,
            123.000000,121.750000,121.560000,123.120000,122.190000,122.750000,124.370000,128.000000,129.500000,130.810000,
            130.630000,132.130000,133.880000,135.380000,135.750000,136.190000,134.500000,135.380000,133.690000,126.060000,
            126.870000,123.500000,122.620000,122.750000,123.560000,125.810000,124.620000,124.370000,121.810000,118.190000,
            118.060000,117.560000,121.000000,121.120000,118.940000,119.810000,121.000000,122.000000,124.500000,126.560000,
            123.500000,121.250000,121.060000,122.310000,121.000000,120.870000,122.060000,122.750000,122.690000,122.870000,
            125.500000,124.250000,128.000000,128.380000,130.690000,131.630000,134.380000,132.000000,131.940000,131.940000,
            129.560000,123.750000,126.000000,126.250000,124.370000,121.440000,120.440000,121.370000,121.690000,120.000000,
            119.620000,115.500000,116.750000,119.060000,119.060000,115.060000,111.060000,113.120000,110.000000,105.000000,
            104.690000,103.870000,104.690000,105.440000,107.000000,89.000000,92.500000,92.120000,94.620000,92.810000,
            94.250000,96.250000,96.370000,93.690000,93.500000,90.000000,90.190000,90.500000,92.120000,94.120000,94.870000,
            93.000000,93.870000,93.000000,92.620000,93.560000,98.370000,104.440000,106.000000,101.810000,104.120000,
            103.370000,102.120000,102.250000,103.370000,107.940000,112.500000,115.440000,115.500000,112.250000,107.560000,
            106.560000,106.870000,104.500000,105.750000,108.620000,107.750000,108.060000,108.000000,108.190000,108.120000,
            109.060000,108.750000,108.560000,106.620000
        };

        /// <summary>
        /// Taken from Excel simulation, test_Cog.xsl, (high + low)/2 median price, D3…D254, 252 entries.
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
        /// Taken from Excel simulation, test_Cog.xsl, F3…F254, 252 entries.
        /// </summary>
        private readonly List<double> cog = new List<double>
        {
            double.NaN, double.NaN, double.NaN, double.NaN, double.NaN, double.NaN, double.NaN, double.NaN, double.NaN, double.NaN,
            5.477786400492390, 5.498228210719120, 5.524042866818050, 5.512283603190270, 5.493748993936790, 5.493931719068440, 5.488107688492600, 5.467315344324120, 5.448413867277750, 5.436101856258920,
            5.430774462990930, 5.445158147637490, 5.463688364952480, 5.440429594272080, 5.409283141760290, 5.402416970216410, 5.400434380056590, 5.419773203514820, 5.449021534382920, 5.489027426326590,
            5.510683422679200, 5.529106629933130, 5.543533049910070, 5.545626970836730, 5.546810196458580, 5.536151458864520, 5.507322611707560, 5.493489204383370, 5.477952787787990, 5.474580649655610,
            5.458492065108890, 5.464858529662380, 5.479499168473390, 5.502943365194450, 5.542973286875730, 5.575504172511830, 5.594956117766870, 5.592017687948660, 5.574205819522010, 5.559947443030600,
            5.525746773304840, 5.496213532312860, 5.468291215570710, 5.437469191127040, 5.414540819931100, 5.406823138199440, 5.420738752842070, 5.437423152123520, 5.464205558408290, 5.506166026178160,
            5.540579040134070, 5.556040420610000, 5.576371982328710, 5.585750092568860, 5.574515786980110, 5.566614422252210, 5.560549126540750, 5.543118208713250, 5.530084943783160, 5.518744438463310,
            5.495783921145850, 5.458972332451190, 5.424303783423940, 5.401497894374070, 5.390593699937560, 5.464037748567580, 5.543379860863360, 5.618905398753100, 5.690664552680990, 5.729420489741260,
            5.738699300148370, 5.726581775387380, 5.686190121179190, 5.631456314513780, 5.554140281453030, 5.533972656681440, 5.524426068461660, 5.536878874627940, 5.557537794630480, 5.566357116565420,
            5.602962456928290, 5.625150354142270, 5.629604000880700, 5.638871548566110, 5.622068392999500, 5.594210774584970, 5.558643413863640, 5.518856314197320, 5.471635090432620, 5.439080592693480,
            5.446523724806440, 5.460831503231560, 5.458178757229820, 5.465360370490870, 5.477699592266210, 5.493685436722490, 5.525914390410040, 5.535876537340000, 5.537901402374650, 5.532908336836450,
            5.526627193286640, 5.525827154069640, 5.517311265718850, 5.517145051729100, 5.517841452907610, 5.516571995808750, 5.548589248965760, 5.573281708653710, 5.586120177420700, 5.578287761769770,
            5.566931211477810, 5.546165089685270, 5.527844129842970, 5.535050516893550, 5.542404103156830, 5.547104247104250, 5.564533223655590, 5.579571203776550, 5.584750886417620, 5.587881081957970,
            5.592041190263980, 5.583819972977780, 5.567308629023190, 5.554972515604280, 5.543211065945830, 5.531029137679690, 5.497105121991820, 5.461651468722410, 5.428003179211240, 5.400504394632340,
            5.386644870649510, 5.388245182436090, 5.406895698117880, 5.423539093366200, 5.449088770617230, 5.477232552504360, 5.472491831731670, 5.468508438546770, 5.464000970324250, 5.466801976275000,
            5.464733329826020, 5.460865574782430, 5.474299094012980, 5.487317180905020, 5.505748869074940, 5.529516899519030, 5.541635317323140, 5.541352318925590, 5.526768445576820, 5.523491940308160,
            5.518972718386210, 5.500008068290010, 5.485059732845200, 5.477801983626820, 5.473045794983040, 5.481329941831170, 5.498403692118680, 5.522948455357470, 5.526060293281620, 5.537778883303310,
            5.554236720102780, 5.565612346275180, 5.575710985515550, 5.589881768767220, 5.586857356587320, 5.573669452765280, 5.557731154775270, 5.537485919312450, 5.496629783624540, 5.471175153698420,
            5.451167486488130, 5.433011278898120, 5.422778283637420, 5.421217296793730, 5.425387786390910, 5.429717546182460, 5.438214852623500, 5.443915526396000, 5.433192049876160, 5.433982401825000,
            5.451202877238110, 5.463683773268300, 5.460801516292700, 5.440060906929210, 5.440453519314930, 5.435074411580040, 5.412742144518540, 5.391520199627000, 5.371988209816070, 5.365024562773750,
            5.382190881961670, 5.424229220847010, 5.377798646236240, 5.344605215810310, 5.338748568474050, 5.348370200764540, 5.346158826928060, 5.349950134485780, 5.380811545595450, 5.423671601670310,
            5.466659743496550, 5.538358448355910, 5.504426364268700, 5.480950293864490, 5.462978534371970, 5.463857240469720, 5.468361593873300, 5.477653085474370, 5.494508754734970, 5.516814422530420,
            5.522761966055180, 5.525721983217620, 5.525305882165760, 5.544653678858700, 5.578370805395150, 5.612397965942790, 5.621395099610250, 5.633023707889940, 5.622986372343700, 5.602840405631590,
            5.569077455136120, 5.531984094813440, 5.520273357191810, 5.542794540128550, 5.588851033725230, 5.635487306204680, 5.644234839966680, 5.619452339185260, 5.585703911849210, 5.538645597180760,
            5.478198182062420, 5.428867471170940, 5.412725152261240, 5.413839397966880, 5.433624195379680, 5.466129679632200, 5.502816137894280, 5.508357237422770, 5.517542488946900, 5.519634535478980,
            5.508653480846080, 5.496199693412960
        };

        /// <summary>
        /// Taken from Excel simulation, test_Cog.xsl, H3…H254, 252 entries.
        /// </summary>
        private readonly List<double> trigger = new List<double>
        {
            double.NaN, double.NaN, double.NaN, double.NaN, double.NaN, double.NaN, double.NaN, double.NaN, double.NaN, double.NaN,
            5.478236604148220,
            5.477786400492390, 5.498228210719120, 5.524042866818050, 5.512283603190270, 5.493748993936790, 5.493931719068440, 5.488107688492600, 5.467315344324120, 5.448413867277750, 5.436101856258920,
            5.430774462990930, 5.445158147637490, 5.463688364952480, 5.440429594272080, 5.409283141760290, 5.402416970216410, 5.400434380056590, 5.419773203514820, 5.449021534382920, 5.489027426326590,
            5.510683422679200, 5.529106629933130, 5.543533049910070, 5.545626970836730, 5.546810196458580, 5.536151458864520, 5.507322611707560, 5.493489204383370, 5.477952787787990, 5.474580649655610,
            5.458492065108890, 5.464858529662380, 5.479499168473390, 5.502943365194450, 5.542973286875730, 5.575504172511830, 5.594956117766870, 5.592017687948660, 5.574205819522010, 5.559947443030600,
            5.525746773304840, 5.496213532312860, 5.468291215570710, 5.437469191127040, 5.414540819931100, 5.406823138199440, 5.420738752842070, 5.437423152123520, 5.464205558408290, 5.506166026178160,
            5.540579040134070, 5.556040420610000, 5.576371982328710, 5.585750092568860, 5.574515786980110, 5.566614422252210, 5.560549126540750, 5.543118208713250, 5.530084943783160, 5.518744438463310,
            5.495783921145850, 5.458972332451190, 5.424303783423940, 5.401497894374070, 5.390593699937560, 5.464037748567580, 5.543379860863360, 5.618905398753100, 5.690664552680990, 5.729420489741260,
            5.738699300148370, 5.726581775387380, 5.686190121179190, 5.631456314513780, 5.554140281453030, 5.533972656681440, 5.524426068461660, 5.536878874627940, 5.557537794630480, 5.566357116565420,
            5.602962456928290, 5.625150354142270, 5.629604000880700, 5.638871548566110, 5.622068392999500, 5.594210774584970, 5.558643413863640, 5.518856314197320, 5.471635090432620, 5.439080592693480,
            5.446523724806440, 5.460831503231560, 5.458178757229820, 5.465360370490870, 5.477699592266210, 5.493685436722490, 5.525914390410040, 5.535876537340000, 5.537901402374650, 5.532908336836450,
            5.526627193286640, 5.525827154069640, 5.517311265718850, 5.517145051729100, 5.517841452907610, 5.516571995808750, 5.548589248965760, 5.573281708653710, 5.586120177420700, 5.578287761769770,
            5.566931211477810, 5.546165089685270, 5.527844129842970, 5.535050516893550, 5.542404103156830, 5.547104247104250, 5.564533223655590, 5.579571203776550, 5.584750886417620, 5.587881081957970,
            5.592041190263980, 5.583819972977780, 5.567308629023190, 5.554972515604280, 5.543211065945830, 5.531029137679690, 5.497105121991820, 5.461651468722410, 5.428003179211240, 5.400504394632340,
            5.386644870649510, 5.388245182436090, 5.406895698117880, 5.423539093366200, 5.449088770617230, 5.477232552504360, 5.472491831731670, 5.468508438546770, 5.464000970324250, 5.466801976275000,
            5.464733329826020, 5.460865574782430, 5.474299094012980, 5.487317180905020, 5.505748869074940, 5.529516899519030, 5.541635317323140, 5.541352318925590, 5.526768445576820, 5.523491940308160,
            5.518972718386210, 5.500008068290010, 5.485059732845200, 5.477801983626820, 5.473045794983040, 5.481329941831170, 5.498403692118680, 5.522948455357470, 5.526060293281620, 5.537778883303310,
            5.554236720102780, 5.565612346275180, 5.575710985515550, 5.589881768767220, 5.586857356587320, 5.573669452765280, 5.557731154775270, 5.537485919312450, 5.496629783624540, 5.471175153698420,
            5.451167486488130, 5.433011278898120, 5.422778283637420, 5.421217296793730, 5.425387786390910, 5.429717546182460, 5.438214852623500, 5.443915526396000, 5.433192049876160, 5.433982401825000,
            5.451202877238110, 5.463683773268300, 5.460801516292700, 5.440060906929210, 5.440453519314930, 5.435074411580040, 5.412742144518540, 5.391520199627000, 5.371988209816070, 5.365024562773750,
            5.382190881961670, 5.424229220847010, 5.377798646236240, 5.344605215810310, 5.338748568474050, 5.348370200764540, 5.346158826928060, 5.349950134485780, 5.380811545595450, 5.423671601670310,
            5.466659743496550, 5.538358448355910, 5.504426364268700, 5.480950293864490, 5.462978534371970, 5.463857240469720, 5.468361593873300, 5.477653085474370, 5.494508754734970, 5.516814422530420,
            5.522761966055180, 5.525721983217620, 5.525305882165760, 5.544653678858700, 5.578370805395150, 5.612397965942790, 5.621395099610250, 5.633023707889940, 5.622986372343700, 5.602840405631590,
            5.569077455136120, 5.531984094813440, 5.520273357191810, 5.542794540128550, 5.588851033725230, 5.635487306204680, 5.644234839966680, 5.619452339185260, 5.585703911849210, 5.538645597180760,
            5.478198182062420, 5.428867471170940, 5.412725152261240, 5.413839397966880, 5.433624195379680, 5.466129679632200, 5.502816137894280, 5.508357237422770, 5.517542488946900, 5.519634535478980,
            5.508653480846080
        };
        #endregion

        #region NameTest
        /// <summary>
        /// A test for Name.
        /// </summary>
        [TestMethod]
        public void NameTest()
        {
            var target = new CenterOfGravityOscillator();
            Assert.AreEqual("cog", target.Name);
        }
        #endregion

        #region MonikerTest
        /// <summary>
        /// A test for Moniker.
        /// </summary>
        [TestMethod]
        public void MonikerTest()
        {
            var target = new CenterOfGravityOscillator();
            Assert.AreEqual("cog(10)", target.Moniker);
            target = new CenterOfGravityOscillator(3);
            Assert.AreEqual("cog(3)", target.Moniker);
            target = new CenterOfGravityOscillator(2);
            Assert.AreEqual("cog(2)", target.Moniker);
        }
        #endregion

        #region DescriptionTest
        /// <summary>
        /// A test for Description.
        /// </summary>
        [TestMethod]
        public void DescriptionTest()
        {
            var target = new CenterOfGravityOscillator();
            Assert.AreEqual("Center of Gravity oscillator", target.Description);
        }
        #endregion

        #region LengthTest
        /// <summary>
        /// A test for Length.
        /// </summary>
        [TestMethod]
        public void LengthTest()
        {
            var target = new CenterOfGravityOscillator();
            Assert.AreEqual(10, target.Length);
            target = new CenterOfGravityOscillator(3);
            Assert.AreEqual(3, target.Length);
            target = new CenterOfGravityOscillator(2);
            Assert.AreEqual(2, target.Length);
        }
        #endregion

        #region ValueFacadeTest
        /// <summary>
        /// A test for ValueFacade.
        /// </summary>
        [TestMethod]
        public void ValueFacadeTest()
        {
            var target = new CenterOfGravityOscillator();
            var facade = target.ValueFacade;
            Assert.AreEqual("cog", facade.Name);
            Assert.AreEqual("cog(10)", facade.Moniker);
            Assert.AreEqual("Center of Gravity oscillator", facade.Description);
            for (int i = 0; i < 10; ++i)
            {
                target.Update(rawInput[i]);
                Assert.IsTrue(double.IsNaN(facade.Update(rawInput[i])));
                Assert.IsFalse(facade.IsPrimed);
            }
            for (int i = 10; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                Assert.AreEqual(target.Value, facade.Update(rawInput[i]));
                Assert.IsTrue(facade.IsPrimed);
            }
        }
        #endregion

        #region TriggerFacadeTest
        /// <summary>
        /// A test for TriggerFacade.
        /// </summary>
        [TestMethod]
        public void TriggerFacadeTest()
        {
            var target = new CenterOfGravityOscillator();
            var facade = target.TriggerFacade;
            Assert.AreEqual("cogTrig", facade.Name);
            Assert.AreEqual("cogTrig(10)", facade.Moniker);
            Assert.AreEqual("Center of Gravity trigger", facade.Description);
            for (int i = 0; i < 10; ++i)
            {
                target.Update(rawInput[i]);
                Assert.IsTrue(double.IsNaN(facade.Update(rawInput[i])));
                Assert.IsFalse(facade.IsPrimed);
            }
            for (int i = 10; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                Assert.AreEqual(target.Trigger, facade.Update(rawInput[i]));
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
            var target = new CenterOfGravityOscillator();
            Assert.IsFalse(target.IsPrimed);
            for (int i = 1; i <= 10; ++i)
            {
                var scalar = new Scalar(DateTime.Now, i);
                scalar = target.Update(scalar);
                Assert.IsTrue(double.IsNaN(scalar.Value));
                Assert.IsFalse(target.IsPrimed);
            }
            for (int i = 11; i <= 48; ++i)
            {
                var scalar = new Scalar(DateTime.Now, i);
                scalar = target.Update(scalar);
                Assert.IsFalse(double.IsNaN(scalar.Value));
                Assert.IsTrue(target.IsPrimed);
            }
        }
        #endregion

        #region TriggerTest
        /// <summary>
        /// A test for Trigger.
        /// </summary>
        [TestMethod]
        public void TriggerTest()
        {
            const int digits = 8;
            var target = new CenterOfGravityOscillator();
            for (int i = 0; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                if (double.IsNaN(trigger[i]))
                {
                    Assert.IsTrue(double.IsNaN(target.Trigger));
                    Assert.IsFalse(target.IsPrimed);
                    continue;
                }
                double d = Math.Round(target.Trigger, digits);
                double u = Math.Round(trigger[i], digits);
                Assert.AreEqual(u, d);
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
            const int digits = 8;
            var target = new CenterOfGravityOscillator();
            for (int i = 0; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                if (double.IsNaN(cog[i]))
                {
                    Assert.IsTrue(double.IsNaN(target.Value));
                    Assert.IsFalse(target.IsPrimed);
                    continue;
                }
                double d = Math.Round(target.Value, digits);
                double u = Math.Round(cog[i], digits);
                Assert.AreEqual(u, d);
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
            const int digits = 8;
            var target = new CenterOfGravityOscillator();
            for (int i = 0; i < 50; ++i)
            {
                double w = Math.Round(target.Update(rawInput[i]), digits);
                if (double.IsNaN(cog[i]))
                {
                    Assert.IsTrue(double.IsNaN(w));
                    Assert.IsTrue(double.IsNaN(target.Value));
                    Assert.IsFalse(target.IsPrimed);
                    continue;
                }
                double d = Math.Round(target.Value, digits);
                Assert.AreEqual(w, d);
                double u = Math.Round(cog[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.Trigger, digits);
                u = Math.Round(trigger[i], digits);
                Assert.AreEqual(u, d);
            }
            for (int i = 50; i < 100; ++i)
            {
                DateTime dateTime = DateTime.Now;
                var ohlcv = new Ohlcv(dateTime, double.NaN, talibHigh[i], talibLow[i], double.NaN, double.NaN);
                Scalar scalar = target.Update(ohlcv);
                Assert.IsTrue(target.IsPrimed);
                Assert.IsFalse(double.IsNaN(scalar.Value));
                Assert.IsFalse(double.IsNaN(target.Value));
                Assert.AreEqual(scalar.Value, target.Value);
                double d = Math.Round(target.Value, digits);
                double u = Math.Round(cog[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.Trigger, digits);
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
                Assert.IsFalse(double.IsNaN(target.Value));
                Assert.AreEqual(scalar.Value, target.Value);
                double d = Math.Round(target.Value, digits);
                double u = Math.Round(cog[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.Trigger, digits);
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
                Assert.IsFalse(double.IsNaN(target.Value));
                Assert.AreEqual(scalar.Value, target.Value);
                double d = Math.Round(target.Value, digits);
                double u = Math.Round(cog[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.Trigger, digits);
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
            const int digits = 8;
            var target = new CenterOfGravityOscillator();
            for (int i = 0; i < rawInput.Count; i++)
            {
                double w = Math.Round(target.Update(rawInput[i]), digits);
                if (double.IsNaN(cog[i]))
                {
                    Assert.IsTrue(double.IsNaN(w));
                    Assert.IsTrue(double.IsNaN(target.Value));
                    Assert.IsFalse(target.IsPrimed);
                    continue;
                }
                double d = Math.Round(target.Value, digits);
                Assert.AreEqual(w, d);
                double u = Math.Round(cog[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.Trigger, digits);
                u = Math.Round(trigger[i], digits);
                Assert.AreEqual(u, d);
            }
            target.Reset();
            for (int i = 0; i < rawInput.Count; i++)
            {
                double w = Math.Round(target.Update(rawInput[i]), digits);
                if (double.IsNaN(cog[i]))
                {
                    Assert.IsTrue(double.IsNaN(w));
                    Assert.IsTrue(double.IsNaN(target.Value));
                    Assert.IsFalse(target.IsPrimed);
                    continue;
                }
                double d = Math.Round(target.Value, digits);
                Assert.AreEqual(w, d);
                double u = Math.Round(cog[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.Trigger, digits);
                u = Math.Round(trigger[i], digits);
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
            var target = new CenterOfGravityOscillator(5);
            Assert.AreEqual("[M:cog(5) P:False V:NaN]", target.ToString());
            target = new CenterOfGravityOscillator(13);
            Assert.AreEqual("[M:cog(13) P:False V:NaN]", target.ToString());
        }
        #endregion

        #region ConstructorTest
        /// <summary>
        /// A test for Constructor.
        /// </summary>
        [TestMethod]
        public void CenterOfGravityOscillatorConstructorTest()
        {
            var target = new CenterOfGravityOscillator();
            Assert.AreEqual(10, target.Length);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsTrue(double.IsNaN(target.Trigger));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new CenterOfGravityOscillator(28);
            Assert.AreEqual(28, target.Length);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsTrue(double.IsNaN(target.Trigger));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new CenterOfGravityOscillator(28, OhlcvComponent.OpeningPrice);
            Assert.AreEqual(28, target.Length);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsTrue(double.IsNaN(target.Trigger));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.OpeningPrice);

            target = new CenterOfGravityOscillator(1);
            Assert.AreEqual(1, target.Length);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsTrue(double.IsNaN(target.Trigger));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.MedianPrice);

            target = new CenterOfGravityOscillator(2, OhlcvComponent.OpeningPrice);
            Assert.AreEqual(2, target.Length);
            Assert.IsTrue(double.IsNaN(target.Value));
            Assert.IsTrue(double.IsNaN(target.Trigger));
            Assert.IsFalse(target.IsPrimed);
            Assert.IsTrue(target.OhlcvComponent == OhlcvComponent.OpeningPrice);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void CenterOfGravityOscillatorConstructorTest2()
        {
            var target = new CenterOfGravityOscillator(0);
            Assert.IsFalse(target.IsPrimed);
        }

        /// <summary>
        /// A test for constructor exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentOutOfRangeException))]
        public void CenterOfGravityOscillatorConstructorTest3()
        {
            var target = new CenterOfGravityOscillator(-8);
            Assert.IsFalse(target.IsPrimed);
        }
        #endregion

        #region SerializationTest
        private static void SerializeTo(CenterOfGravityOscillator instance, string fileName)
        {
            var dcs = new DataContractSerializer(typeof(CenterOfGravityOscillator), null, 65536, false, true, null);
            using (var fs = new FileStream(fileName, FileMode.Create))
            {
                dcs.WriteObject(fs, instance);
                fs.Close();
            }
        }

        private static CenterOfGravityOscillator DeserializeFrom(string fileName)
        {
            var fs = new FileStream(fileName, FileMode.Open);
            XmlDictionaryReader reader = XmlDictionaryReader.CreateTextReader(fs, new XmlDictionaryReaderQuotas());
            var ser = new DataContractSerializer(typeof(CenterOfGravityOscillator), null, 65536, false, true, null);
            var instance = (CenterOfGravityOscillator)ser.ReadObject(reader, true);
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
            var source = new CenterOfGravityOscillator();
            for (int i = 0; i < 111; ++i)
            {
                double w = Math.Round(source.Update(rawInput[i]), digits);
                if (double.IsNaN(cog[i]))
                {
                    Assert.IsTrue(double.IsNaN(w));
                    Assert.IsTrue(double.IsNaN(source.Value));
                    Assert.IsFalse(source.IsPrimed);
                    continue;
                }
                d = Math.Round(source.Value, digits);
                u = Math.Round(cog[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(source.Trigger, digits);
                u = Math.Round(trigger[i], digits);
                Assert.AreEqual(u, d);
            }
            const string fileName = "CenterOfGravityOscillator_1.xml";
            SerializeTo(source, fileName);
            CenterOfGravityOscillator target = DeserializeFrom(fileName);
            Assert.AreEqual(source.Value, target.Value);
            Assert.AreEqual(source.Trigger, target.Trigger);
            Assert.AreEqual(source.Name, target.Name);
            Assert.AreEqual(source.Moniker, target.Moniker);
            Assert.AreEqual(source.Description, target.Description);
            for (int i = 111; i < rawInput.Count; ++i)
            {
                target.Update(rawInput[i]);
                d = Math.Round(target.Value, digits);
                u = Math.Round(cog[i], digits);
                Assert.AreEqual(u, d);
                d = Math.Round(target.Trigger, digits);
                u = Math.Round(trigger[i], digits);
                Assert.AreEqual(u, d);
            }
            //FileInfo fi = new FileInfo(fileName);
            //fi.Delete();
        }
        #endregion
    }
}

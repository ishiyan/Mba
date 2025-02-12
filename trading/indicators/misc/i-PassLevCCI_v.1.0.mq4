//+------------------------------------------------------------------+
//|                                           i-PassLevCCI_v.1.0.mq4 |
//|                              ���� Gentor, ���������� � ��4 KimIV |
//|                                              http://www.kimiv.ru |
//|   23.08.2005 v.1.0                                               |
//| ���������������� ������ ��� ����� ������ -100, 0 � 100           |
//+------------------------------------------------------------------+
#property copyright "Gentor, KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 PaleTurquoise
#property indicator_color2 LightSalmon
#property indicator_color3 Red

//------- ������� ��������� ------------------------------------------
extern int CCI_Period   = 14;   // ������ CCI
extern int BarsForCheck = 9;    // ���������� ����� ��� ��������
extern int MaxLevel     = 100;  // ������������ �������� ������
extern int MinLevel     = -100; // ����������� �������� ������
extern int NumberOfBars = 0;    // ���������� ����� ������� (0-���)

//------- ������ ���������� ------------------------------------------
double SigBuy[];
double SigSell[];
double SigExit[];

//------- ���������� ���������� --------------------------------------
bool firstTime = True;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  SetIndexBuffer(0, SigBuy);
  SetIndexStyle (0, DRAW_ARROW);
  SetIndexArrow (0, 233);
  SetIndexBuffer(1, SigSell);
  SetIndexStyle (1, DRAW_ARROW);
  SetIndexArrow (1, 234);
  SetIndexBuffer(2, SigExit);
  SetIndexStyle (2, DRAW_ARROW);
  SetIndexArrow (2, 251);
  Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
  bool     fsb=False, fss=False;
  double   cci1, cci2, cci3;
  int      loopbegin, shift, sh, i;

  if (firstTime) {
  	if (NumberOfBars==0) loopbegin = Bars - 1 - CCI_Period;
	  else loopbegin = NumberOfBars - 1;
  }
  if (BarsForCheck<2) BarsForCheck = 2;

  for (shift=loopbegin; shift>=0; shift--) {
    SigBuy[shift] = EMPTY_VALUE;
    SigSell[shift] = EMPTY_VALUE;
    SigExit[shift] = EMPTY_VALUE;
    cci1 = iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+1);
    // ������ �� �������
    if (cci1>MaxLevel) {
      for (sh=2; sh<=BarsForCheck; sh++) {
        if (fsb) break;
        cci2 = iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+sh);
        if (cci2<=0) {
          for (i=sh+1; i<=BarsForCheck; i++) {
            cci3 = iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+i);
            if (cci3<MinLevel) {
              SigBuy[shift] = Low[shift] - 10 * Point;
              fsb = True;
              break;
            }
          }
        }
      }
    }
    // ������ �� �������
    if (cci1<MinLevel) {
      for (sh=2; sh<=BarsForCheck; sh++) {
        if (fss) break;
        cci2 = iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+sh);
        if (cci2>=0) {
          for (i=sh+1; i<=BarsForCheck; i++) {
            cci3 = iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+i);
            if (cci3>MaxLevel) {
              SigSell[shift] = High[shift] + 10 * Point;
              fss = True;
              break;
            }
          }
        }
      }
    }

    // ������� �� �����
    cci3 = iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, shift+2);
    if (cci1*cci3<0 && (fsb || fss)) {
      SigExit[shift] = Close[shift];
      fsb = False;
      fss = False;
    }
  }
}
//+------------------------------------------------------------------+


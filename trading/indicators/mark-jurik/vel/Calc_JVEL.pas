unit Calc;
{  Декомпиляция индикаторов от M.Jurik          }
{  Created by Starlight (extesy@yandex.ru)      }

interface
uses
  Math;

type
  TSeries = array of Double;            // Серия данных

function JAVELSeries (const SrcA: TSeries; ALoLen, AHiLen: Integer; ASensitivity, APeriod: Double): TSeries;
function JXVELSeries (const SrcA: TSeries; DepthSrcA: TSeries; APeriod: Double): TSeries;
function JVELSeries (const SrcA: TSeries; ADepth: integer): TSeries;

implementation

function JXVELaux1(const SrcA: TSeries; DepthSeries: TSeries): TSeries;
var
  Bar: integer;
  jrc05, jrc06, jrc07, jrc08, jrc09: Double;
  jrc02, jrc04, jrc10: integer;
begin
  SetLength (Result, High(SrcA)+1);
  jrc05 := 0; jrc06 := 0; jrc07 := 0; jrc08 := 0; jrc09 := 0;
  jrc02 := 0; jrc04 := 0; jrc10 := 0;

  for Bar := 0 to High (SrcA) do
  begin
    jrc02 := ceil(DepthSeries[Bar]);
    jrc04 := jrc02 + 1;
    if (Bar < jrc04) then continue;
    jrc05 := jrc04 * (jrc04+1) / 2;
    jrc06 := jrc05 * (2*jrc04+1) / 3;
    jrc07 := jrc05 * jrc05 * jrc05 - jrc06 * jrc06;
    jrc08 := 0;
    jrc09 := 0;
    for jrc10 := 0 to jrc02 do begin
      jrc08 := jrc08 + SrcA[Bar-jrc10] * (jrc04 - jrc10);
      jrc09 := jrc09 + SrcA[Bar-jrc10] * (jrc04 - jrc10) * (jrc04 - jrc10);
    end;
    Result[Bar] := (jrc09*jrc05 - jrc08*jrc06) / jrc07;
  end;
end;

function JXVELaux3(const SrcA: TSeries; Period: Double): TSeries;
var
  Bar: integer;
  input1, jrc02, jrc03, jrc04, jrc05, jrc08, jrc09, jrc10, jrc12, jrc13: Double;
  jrc14, jrc16, jrc17, jrc18, jrc19, jrc20, jrc21, jrc22, jrc25: Double;
  jrc01, jrc06, jrc07, jrc11, jrc15, jrc23, jrc24, jrc26, jrc27, jrc28, jrc29: integer;
  jrc30: array[0..1000] of Double;
begin
  SetLength (Result, High(SrcA)+1);

  input1 := 0; jrc02 := 0; jrc03 := 0; jrc04 := 0; jrc05 := 0; jrc07 := 0; jrc08 := 0;
  jrc09 := 0; jrc10 := 0; jrc12 := 0; jrc13 := 0; jrc14 := 0; jrc16 := 0; jrc17 := 0;
  jrc18 := 0; jrc19 := 0; jrc20 := 0; jrc21 := 0; jrc22 := 0; jrc23 := 0; jrc24 := 0;
  jrc25 := 0; jrc01 := 0; jrc06 := 0; jrc11 := 0; jrc15 := 0; jrc26 := 0; jrc27 := 0;
  jrc28 := 0; jrc29 := 0;
  FillChar (jrc30, SizeOf(jrc30), 0);

  jrc01 := 30;
  jrc02 := 0.0001;
  jrc28 := 1;
  jrc29 := 1;

  for Bar := 0 to High (SrcA) do begin
    input1 := SrcA[Bar];
    jrc27 := Bar;
    if (Bar = 0) then jrc26 := jrc27;
    if (Bar > 0) then begin
      if (jrc24 <= 0) then jrc24 := 1001;
      jrc24 := jrc24 - 1;
      jrc30[jrc24] := input1;
    end;
    if (jrc27 < jrc26 + jrc01) then jrc20 := input1 else begin
    	jrc03 := min(500, max(jrc02, Period));
    	jrc07 := min(jrc01, ceil(jrc03));
    	jrc04 := 0.86 - 0.55 / sqrt(jrc03);
    	jrc05 := 1 - exp(-ln(4) / jrc03 / 2);
    	jrc06 := Trunc(max(jrc01 + 1, ceil(2*jrc03)));
    	jrc11 := Trunc(min(jrc27 - jrc26 + 1, jrc06));
    	jrc12 := jrc11 * (jrc11+1) * (jrc11-1) / 12;
    	jrc13 := (jrc11+1) / 2;
    	jrc14 := (jrc11-1) / 2;
    	jrc09 := 0;
    	jrc10 := 0;
    	for jrc15 := jrc11 - 1 downto 0 do begin
    		jrc23 := (jrc24 + jrc15) mod 1001;
    		jrc09 := jrc09 + jrc30[jrc23];
		    jrc10 := jrc10 + jrc30[jrc23] * (jrc14 - jrc15);
    	end;
    	jrc16 := jrc10 / jrc12;
      jrc17 := jrc09 / jrc11 - jrc16 * jrc13;
      jrc18 := 0;
    	for jrc15 := jrc11 - 1 downto 0 do begin
    		jrc17 := jrc17 + jrc16;
        jrc23 := (jrc24+jrc15) mod 1001;
  		  jrc18 := jrc18 + abs(jrc30[jrc23] - jrc17);
    	end;
      jrc25 := 1.2 * jrc18 / jrc11;
      if (jrc11 < jrc06) then jrc25 := jrc25 * power(jrc06 / jrc11, 0.25);
      if (jrc28 = 1) then begin
        jrc28 := 0;
        jrc19 := jrc25;
      end else jrc19 := jrc19 + (jrc25 - jrc19) * jrc05;
      jrc19 := max(jrc02, jrc19);
      if (jrc29 = 1) then begin
        jrc29 := 0;
    		jrc08 := (jrc30[jrc24] - jrc30[(jrc24+jrc07) mod 1001]) / jrc07;
    	end;
      jrc21 := input1 - (jrc20 + jrc08 * jrc04);
    	jrc22 := 1 - exp(-abs(jrc21) / jrc19 / jrc03);
      jrc08 := jrc22 * jrc21 + jrc08 * jrc04;
    	jrc20 := jrc20 + jrc08;
    end;
    Result[Bar] := jrc20;
  end;
end;

function JXVELSeries(const SrcA: TSeries; DepthSrcA: TSeries; APeriod: Double): TSeries;
begin
  //  for Bar := 0 to High (SrcA) do
  //    @Result[Bar] := GetSeriesValue(Bar, JXVELaux3(JXVELaux1(Series, DepthSeries), Period));
  Result := JXVELaux3(JXVELaux1(SrcA, DepthSrcA), APeriod);
end;

function JVELaux1(const SrcA: TSeries; Depth: integer): TSeries;
var
  Bar: integer;
  jrc04, jrc05, jrc06, jrc07, jrc08, jrc09: Double;
  jrc01: TSeries;
  jrc02, jrc10: integer;
begin
  SetLength (Result, High(SrcA)+1);
  jrc04 := 0; jrc05 := 0; jrc06 := 0; jrc07 := 0; jrc08 := 0; jrc09 := 0;

  jrc01 := SrcA;
  jrc02 := Depth;
  jrc04 := jrc02 + 1;
  jrc05 := jrc04 * (jrc04+1) / 2;
  jrc06 := jrc05 * (2*jrc04+1) / 3;
  jrc07 := jrc05 * jrc05 * jrc05 - jrc06 * jrc06;
  for Bar := jrc02 to High (SrcA) do
  begin
    jrc08 := 0;
    jrc09 := 0;
    for jrc10 := 0 to jrc02 do
    begin
      jrc08 := jrc08 + jrc01[Bar-jrc10] * (jrc04 - jrc10);
      jrc09 := jrc09 + jrc01[Bar-jrc10] * (jrc04 - jrc10) * (jrc04 - jrc10);
    end;
    Result[Bar] := (jrc09*jrc05 - jrc08*jrc06) / jrc07;
  end;
end;

function JVELaux3(const SrcA: TSeries): TSeries;
var
  Bar: integer;
  JR02, JR04, JR05, JR08, JR09, JR10, JR12, JR13, JR14, JR16, JR17, JR19, JR20, JR22, JR23, JR28: Double;
  JR01, JR03, JR06, JR07, JR11, JR15, JR18, JR24, JR25, JR26, JR27, JR29: integer;
  JR21, JR21a, JR21b: Double;
  JR40, JR41 : array[0..99] of Double;
begin
  SetLength (Result, High(SrcA)+1);
  JR02 := 0; JR04 := 0; JR05 := 0; JR08 := 0; JR09 := 0; JR10 := 0; JR12 := 0; JR13 := 0;
  JR14 := 0; JR16 := 0; JR17 := 0; JR19 := 0; JR20 := 0; JR22 := 0; JR23 := 0; JR28 := 0;
  JR01 := 0; JR03 := 0; JR06 := 0; JR07 := 0; JR11 := 0; JR15 := 0; JR18 := 0;
  JR24 := 0; JR25 := 0; JR26 := 0; JR27 := 0; JR29 := 0;

  JR21 := 0; JR21a := 0; JR21b := 0;

  FillChar (JR40, SizeOf(JR40), 0);
  FillChar (JR41, SizeOf(JR41), 0);

  JR01 := 30;
  JR02 := 0.0001;

  for Bar := JR01 to High (SrcA) do
  begin
    JR27 := Bar;
    If Bar = JR01 then begin
	    JR28 := 0;
    	for JR29 := 1 to JR01-1 do
      	if SrcA[Bar-JR29] = SrcA[Bar-JR29-1] then JR28 := JR28 + 1;
      if JR28 < (JR01-1) then JR26 := JR27-JR01 else JR26 := JR27;
    	JR18 := 0;
    	JR25 := 0;
    	JR21 := SrcA[Bar-1];
    	JR03 := 3;
    	JR04 := 0.86 - 0.55 / sqrt(JR03);
    	JR05 := 1 - exp(-ln(4) / JR03);
    	JR06 := JR01+1;
    	JR07 := 3;
    	JR08 := (SrcA[Bar] - SrcA[Bar-JR07]) / JR07;
    	JR11 := Trunc(min(1+JR27-JR26, JR06));
    	for JR15 := JR11-1 downto 1 do begin
    		if JR25 <= 0 then JR25 := 100;
    		JR25 := JR25-1;
    		JR41[JR25] := SrcA[Bar-JR15];
    	end;
    end;
    If JR25 <= 0 then JR25 := 100;
    JR25 := JR25-1;
    JR41[JR25] := SrcA[Bar];
    if JR11 <= JR01 then begin
    	if Bar = JR01 then JR21 := SrcA[Bar] else JR21 := sqrt(JR05)*SrcA[Bar] + (1-sqrt(JR05))*JR21a;
    	if Bar > JR01+1 then JR08 := (JR21 - JR21b)/2 else JR08 := 0;
      JR11 := JR11 + 1;
    end else begin
    	If JR11 <= JR06 then begin
    		JR12 := JR11 * (JR11+1) * (JR11-1) / 12;
    		JR13 := (JR11+1)/2;
                JR14 := (JR11-1)/2;
    		JR09 := 0;
                JR10 := 0;
    		for JR15 := JR11-1 downto 0 do begin
		    	JR24 := (JR25+JR15) mod 100;
    			JR09 := JR09 + JR41[JR24];
		    	JR10 := JR10 + JR41[JR24]*(JR14 - JR15);
    		end;
    		JR16 := JR10/JR12;
		JR17 := (JR09/JR11) - (JR16*JR13);
    		JR19 := 0;
		for JR15 := JR11-1 downto 0 do begin
    			JR17 := JR17+JR16;
		    	JR24 := (JR25+JR15) mod 100;
    			JR40[JR15] := abs(JR41[JR24]-JR17);
		    	JR19 := JR19 + JR40[JR15];
    		end;
    		JR20 := (JR19/JR11) * power(JR06/JR11, 0.25);
		    JR11 := JR11+1;
    	end else begin
    		if (Bar mod 1000)=0 then begin
		    	JR09 := 0;
    			JR10 := 0;
		    	for JR15 := JR06-1 downto 0 do begin
				    JR24 := (JR25+JR15) mod 100;
    				JR09 := JR09 + JR41[JR24];
		    		JR10 := JR10 + JR41[JR24]*(JR14 - JR15);
    			end;
		    end else begin
    			JR24 := (JR25+JR06) mod 100;
		    	JR10 := JR10 - JR09 + JR41[JR24]*JR13 + SrcA[Bar]*JR14;
    			JR09 := JR09 - JR41[JR24] + SrcA[Bar];
		    end;
    		if JR18 <= 0 then JR18 := JR06;
    		JR18 := JR18 - 1;
		    JR19 := JR19 - JR40[JR18];
    		JR16 := JR10/JR12;
		    JR17 := (JR09/JR06) + (JR16*JR14);
    		JR40[JR18] := abs(SrcA[Bar]-JR17);
		    JR19 := max(JR02, (JR19 + JR40[JR18]));
    		JR20 := JR20 + ((JR19/JR06) - JR20) * JR05;
    	end;
    	JR20 := max(JR02, JR20);
    	JR22 := SrcA[Bar] - (JR21 + JR08*JR04);
    	JR23 := 1-exp(-abs(JR22)/JR20/JR03);
    	JR08 := JR23*JR22 + JR08*JR04;
    	JR21 := JR21 + JR08;
    end;
    JR21b := JR21a; JR21a := JR21;
    Result[Bar] := JR21;
  end;
end;

function JVELSeries(const SrcA: TSeries; ADepth: integer): TSeries;
var
  Bar: integer;
  Value: Double;
begin
   //  for Bar := 0 to High (SrcA) do
   //    @Result[Bar] := GetSeriesValue(Bar, JVELaux3(JVELaux1(Series, Depth)));
  Result := JVELaux3(JVELaux1(SrcA, ADepth));
end;

function JAVELSeries(const SrcA: TSeries; ALoLen, AHiLen: Integer; ASensitivity, APeriod: Double): TSeries;
var
  Bar, j, k: integer;
  avg1, avg2, value2, value3: Double;
  eps: Double;
  value1, value4: TSeries;
begin
  SetLength (Result, High(SrcA)+1);
  SetLength (value1, High(SrcA)+1);
  SetLength (value4, High(SrcA)+1);

  eps := 0.001;
  for Bar := 1 to High(SrcA) do
     value1[Bar] := abs(SrcA[Bar] - SrcA[Bar-1]);

  for Bar := 0 to High(SrcA) do begin
    avg1 := 0;
    if (Bar < 99) then k := Bar else k := 99;
    for j := 0 to k do
       avg1 := avg1 + value1[Bar-j];
    avg1 := avg1 / (k+1);

    avg2 := 0;
    if (Bar < 9) then k := Bar else k := 9;
    for j := 0 to k do
       avg2 := avg2 + value1[Bar-j];
    avg2 := avg2 / (k+1);

    value2 := ASensitivity * ln((eps+avg1) / (eps+avg2));
    value3 := value2 / (1 + abs(value2));
    value4[Bar] := ALoLen + (AHiLen-ALoLen) * (1+value3) / 2;
  end;

  //  for Bar := 0 to High(SrcA) do
  //    Result[Bar] := GetSeriesValue(Bar, JXVELaux3(JXVELaux1(Series, value4), Period));
  Result := JXVELaux3(JXVELaux1(SrcA, value4), APeriod);
end;

end.


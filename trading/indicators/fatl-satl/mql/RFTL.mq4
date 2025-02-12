//+------------------------------------------------------------------+ 
//| RFTL.mq4 
//| 
//+------------------------------------------------------------------+ 
#property copyright "Copyright 2002, Finware.ru Ltd." 
#property link "http://www.finware.ru/" 

#property indicator_chart_window 
#property indicator_buffers 1 
#property indicator_color1 Red 


//---- buffers 
double RFTLBuffer[]; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function | 
//+------------------------------------------------------------------+ 
int init() 
{ 
string short_name; 
//---- indicator line 
SetIndexStyle(0,DRAW_LINE); 
SetIndexBuffer(0,RFTLBuffer); 
SetIndexDrawBegin(0,44); 
//---- 
return(0); 
} 
//+------------------------------------------------------------------+ 
//| RFTL | 
//+------------------------------------------------------------------+ 
int start() 
{ 
int i,counted_bars=IndicatorCounted(); 
//---- 
if(Bars<=44) return(0); 
//---- initial zero 
if(counted_bars<44) 
for(i=1;i<=0;i++) RFTLBuffer[Bars-i]=0.0; 
//---- 
i=Bars-44-1; 
if(counted_bars>=44) i=Bars-counted_bars-1; 
while(i>=0) 
{ 
RFTLBuffer[i]= 
-0.02232324*Close[i+0] 
+0.02268676*Close[i+1] 
+0.08389067*Close[i+2] 
+0.14630380*Close[i+3] 
+0.19282649*Close[i+4] 
+0.21002638*Close[i+5] 
+0.19282649*Close[i+6] 
+0.14630380*Close[i+7] 
+0.08389067*Close[i+8] 
+0.02268676*Close[i+9] 
-0.02232324*Close[i+10] 
-0.04296564*Close[i+11] 
-0.03980614*Close[i+12] 
-0.02082171*Close[i+13] 
+0.00243636*Close[i+14] 
+0.01950580*Close[i+15] 
+0.02460929*Close[i+16] 
+0.01799295*Close[i+17] 
+0.00470540*Close[i+18] 
-0.00831985*Close[i+19] 
-0.01544722*Close[i+20] 
-0.01456262*Close[i+21] 
-0.00733980*Close[i+22] 
+0.00201852*Close[i+23] 
+0.00902504*Close[i+24] 
+0.01093067*Close[i+25] 
+0.00766099*Close[i+26] 
+0.00145478*Close[i+27] 
-0.00447175*Close[i+28] 
-0.00750446*Close[i+29] 
-0.00671646*Close[i+30] 
-0.00304016*Close[i+31] 
+0.00143433*Close[i+32] 
+0.00457475*Close[i+33] 
+0.00517589*Close[i+34] 
+0.00336708*Close[i+35] 
+0.00034406*Close[i+36] 
-0.00233637*Close[i+37] 
-0.00352280*Close[i+38] 
-0.00293522*Close[i+39] 
-0.00114249*Close[i+40] 
+0.00083536*Close[i+41] 
+0.00215524*Close[i+42] 
+0.00604133*Close[i+43] 
-0.00013046*Close[i+44]; 

i--; 
} 
return(0); 
} 
//+------------------------------------------------------------------+ 
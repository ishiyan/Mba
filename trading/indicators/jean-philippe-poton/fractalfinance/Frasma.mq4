//+------------------------------------------------------------------+
//| FRAMA2.mq4 |
//| Copyright © 2008, MetaQuotes Software Corp. |
//| http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link "http://www.metaquotes.net"

#property indicator_chart_window

#property indicator_color1 Red
#property indicator_width1 2
//************************************************************
// Input parameters
//************************************************************
extern int e_period =10;
extern int normal_speed =10;
extern int e_type_data =PRICE_CLOSE;
//************************************************************
// Constant
//************************************************************
string INDICATOR_NAME="FRAMA2";
string FILENAME ="FRAMA2.mq4";
double LOG_2;
//************************************************************
// Private vars
//************************************************************
double ExtOutputBuffer[];
int g_period_minus_1;
//+-----------------------------------------------------------------------+
//| FUNCTION : init | 
//| Initialization function | 
//| Check the user input parameters and convert them in appropriate types.| 
//+-----------------------------------------------------------------------+
int init()
{
// Check e_period input parameter
if(e_period < 2 )
{
Alert( "[ 10-ERROR " + FILENAME + " ] input parameter \"e_period\" must be >= 1 (" + e_period + ")" );
return( -1 );
}
if(e_type_data < PRICE_CLOSE || e_type_data > PRICE_WEIGHTED )
{
Alert( "[ 20-ERROR " + FILENAME + " ] input parameter \"e_type_data\" unknown (" + e_type_data + ")" );
return( -1 );
}
IndicatorBuffers( 1 );
SetIndexBuffer( 0, ExtOutputBuffer );
SetIndexStyle( 0, DRAW_LINE, STYLE_SOLID, 2 );
SetIndexDrawBegin( 0, 2 * e_period );
g_period_minus_1=e_period - 1;
LOG_2=MathLog( 2.0 );
//----
return( 0 );
}
//+------------------------------------------------------------------+
//| FUNCTION : deinit |
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
return(0);
}
//+------------------------------------------------------------------+
//| FUNCTION : start |
//| This callback is fired by metatrader for each tick |
//+------------------------------------------------------------------+
int start()
{
int countedBars=IndicatorCounted();
//---- check for possible errors
if(countedBars < 0)
{
return(-1);
}
_computeLastNbBars( Bars - countedBars - 1 );
//----
return( 0 );
}
//+================================================================================================================+
//+=== FUNCTION : _computeLastNbBars ===+
//+=== ===+
//+=== ===+
//+=== This callback is fired by metatrader for each tick ===+
//+=== ===+
//+=== In : ===+
//+=== - lastBars : these "n" last bars must be repainted ===+
//+=== ===+
//+================================================================================================================+
//+------------------------------------------------------------------+
//| FUNCTION : _computeLastNbBars |
//| This callback is fired by metatrader for each tick |
//| In : - lastBars : these "n" last bars must be repainted | 
//+------------------------------------------------------------------+
void _computeLastNbBars( int lastBars )
{
int pos;
switch( e_type_data )
{
case PRICE_CLOSE : _computeFRAMA( lastBars, Close ); break;
case PRICE_OPEN : _computeFRAMA( lastBars, Open ); break;
case PRICE_HIGH : _computeFRAMA( lastBars, High ); break;
case PRICE_LOW : _computeFRAMA( lastBars, Low ); break;

default :
Alert( "[ 20-ERROR " + FILENAME + " ] the imput parameter e_type_data <" + e_type_data + "> is unknown" );
}
}
//+------------------------------------------------------------------+
//| FUNCTION : _computeFRASMA |
//| Compute the fractally modified SMA from input data. |
//| In : |
//| - lastBars : these "n" last bars must be repainted |
//| - inputData : data array on which the will be applied | 
//| For technical explanations, see my blog: | 
//| http://fractalfinance.blogspot.com/ |
//+------------------------------------------------------------------+
void _computeFRAMA( int lastBars, double inputData[] )
{
int pos, iteration;
double diff, priorDiff;
double length;
double priceMax, priceMin;
double fdi,alpha;
int speed;
//----
for( pos=lastBars; pos>=0; pos-- )
{
priceMax=_highest( e_period, pos, inputData );
priceMin=_lowest( e_period, pos, inputData );
length =0.0;
priorDiff=0.0;
//----
for( iteration=0; iteration <= g_period_minus_1; iteration++ )
{
if(( priceMax - priceMin)> 0.0 )
{
diff =(inputData[pos + iteration] - priceMin )/( priceMax - priceMin );
if(iteration > 0 )
{
length+=MathSqrt( MathPow( diff - priorDiff, 2.0)+(1.0/MathPow( e_period, 2.0)) );
}
priorDiff=diff;
}
}
if(length > 0.0 )
{
fdi=1.0 +(MathLog( length)+ LOG_2 )/MathLog( 2 * g_period_minus_1 );
}
else
{
/*
** The FDI algorithm suggests in this case a zero value.
** I prefer to use the previous FDI value.
*/
fdi=0.0;
}

alpha=MathExp(-4.6*(fdi-1)); // This is the recommendation from Elhers, but using fdi as the fractal dimension 
ExtOutputBuffer[pos]=alpha*Close[pos]+(1-alpha)*ExtOutputBuffer[pos+1];
}
}
//+------------------------------------------------------------------+
//| FUNCTION : _highest |
//| Search for the highest value in an array data |
//| In : |
//| - n : find the highest on these n data |
//| - pos : begin to search for from this index |
//| - inputData : data array on which the searching for is done |
//| |
//| Return : the highest value | |
//+------------------------------------------------------------------+
double _highest( int n, int pos, double inputData[] )
{
int length=pos + n;
double highest=0.0;
//----
for( int i=pos; i < length; i++ )
{
if(inputData[i] > highest)highest=inputData[i];
}
return( highest );
}
//+------------------------------------------------------------------+
//| FUNCTION : _lowest | ===+
//| Search for the lowest value in an array data |
//| In : |
//| - n : find the hihest on these n data |
//| - pos : begin to search for from this index |
//| - inputData : data array on which the searching for is done |
//| |
//| Return : the highest value |
//+------------------------------------------------------------------+
double _lowest( int n, int pos, double inputData[] )
{
int length=pos + n;
double lowest=9999999999.0;
//----
for( int i=pos; i < length; i++ )
{
if(inputData[i] < lowest)lowest=inputData[i];
}
return( lowest );
}
//+------------------------------------------------------------------+
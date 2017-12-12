//+------------------------------------------------------------------+
//|                                                     MA_Cross.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "..\ExpertSignal.mqh"   // The CExpertSignal class is in the file ExpertSignal
//#property tester_indicator "Custom Moving Average.ex5"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals at the intersection of two MAs                     |
//| Type=SignalAdvanced                                              |
//| Name=My_MA_Cross                                                 |
//| ShortName=MaCross                                                |
//| Class=MA_Cross                                                   |
//| Page=Not needed                                                  |
//| Parameter=FastPeriod,int,1,Period of fast MA                    |
//| Parameter=FastMethod,ENUM_MA_METHOD,MODE_SMA,Method of fast MA   |
//| Parameter=SlowPeriod,int,20,Period of slow MA                    |
//| Parameter=SlowMethod,ENUM_MA_METHOD,MODE_SMA,Method of slow MA   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MA_Cross : public CExpertSignal
  {
private:
   CiCustom          m_fast_ma;        // The indicator as an object
   CiCustom          m_slow_ma;        // The indicator as an object
   //--- Configurable module parameters
   int               m_period_fast;    // Period of the fast MA
   ENUM_MA_METHOD    m_method_fast;    // Type of smoothing of the fast MA
   int               m_period_slow;    // Period of the slow MA
   ENUM_MA_METHOD    m_method_slow;    // Type of smoothing of the slow MA

public:
   //--- Constructor of class
                     MA_Cross(void);
   //--- Destructor of class
                    ~MA_Cross(void);
   //--- Methods for placing
   void              FastPeriod(const int value)               { m_period_fast=value;                }
   void              FastMethod(const ENUM_MA_METHOD value)    { m_method_fast=value;                }
   void              SlowPeriod(const int value)               { m_period_slow=value;                }
   void              SlowMethod(const ENUM_MA_METHOD value)    { m_method_slow=value;                }
   //--- Checking correctness of input data
   bool              ValidationSettings(void);
   //--- Creating indicators and timeseries for the module of signals
   bool              InitIndicators(CIndicators *indicators);
   //--- Access to indicator data
   double            FastMA(const int index)             const { return(m_fast_ma.GetData(0,index)); }
   double            SlowMA(const int index)             const { return(m_slow_ma.GetData(0,index)); }
   //--- Checking Buy and Sell conditions
   virtual int       LongCondition();
   virtual int       ShortCondition();

protected:
   //--- Creating MA indicators
   bool              CreateFastMA(CIndicators *indicators);
   bool              CreateSlowMA(CIndicators *indicators);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
MA_Cross::MA_Cross(void) : m_period_fast(1),
                           m_method_fast(MODE_SMA),
                           m_period_slow(20),
                           m_method_slow(MODE_SMA)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
MA_Cross::~MA_Cross(void)
  {
  }
//+------------------------------------------------------------------+
//| Checks input parameters and returns true if everything is OK     |
//+------------------------------------------------------------------+
bool MA_Cross::ValidationSettings(void)
  {
//--- Call the base class method
   if(!CExpertSignal::ValidationSettings()) return(false);
//--- Check periods, number of bars for the calculation of the MA >=1
   if(m_period_fast<1 || m_period_slow<1)
     {
      PrintFormat("Incorrect value set for one of the periods! FastPeriod=%d, SlowPeriod=%d",
                  m_period_fast,m_period_slow);
      return false;
     }
//--- Slow MA period must be greater that the fast MA period
   if(m_period_fast>m_period_slow)
     {
      PrintFormat("SlowPeriod=%d must be greater than FastPeriod=%d!",
                  m_period_slow,m_period_fast);
      return false;
     }
//--- Fast MA smoothing type must be one of the four values of the enumeration
   if(m_method_fast!=MODE_SMA && m_method_fast!=MODE_EMA && m_method_fast!=MODE_SMMA && m_method_fast!=MODE_LWMA)
     {
      PrintFormat("Invalid type of smoothing of the fast MA!");
      return false;
     }
//--- Show MA smoothing type must be one of the four values of the enumeration
   if(m_method_slow!=MODE_SMA && m_method_slow!=MODE_EMA && m_method_slow!=MODE_SMMA && m_method_slow!=MODE_LWMA)
     {
      PrintFormat("Invalid type of smoothing of the slow MA!");
      return false;
     }
//--- All checks are completed, everything is ok
   return true;
  }
//+------------------------------------------------------------------+
//| Creates indicators                                               |
//| Input:  a pointer to a collection of indicators                  |
//| Output: true if successful, otherwise false                      |
//+------------------------------------------------------------------+
bool MA_Cross::InitIndicators(CIndicators *indicators)
  {
//--- Standard check of the collection of indicators for NULL
   if(indicators==NULL) return(false);
//--- Initializing indicators and timeseries in additional filters
   if(!CExpertSignal::InitIndicators(indicators)) return(false);
//--- Creating our MA indicators
   if(!CreateFastMA(indicators))                  return(false);
   if(!CreateSlowMA(indicators))                  return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the "Fast MA" indicator                                  |
//+------------------------------------------------------------------+
bool MA_Cross::CreateFastMA(CIndicators *indicators)
  {
//--- Checking the pointer
   if(indicators==NULL) return(false);
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(m_fast_ma)))
     {
      printf(__FUNCTION__+": Error adding an object of the fast MA");
      return(false);
     }
//--- Setting parameters of the fast MA
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Custom Moving Average-Blue.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_period_fast;      // Period
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=0;                  // Shift
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_method_fast;      // Method of averaging
//--- Object initialization
   if(!m_fast_ma.Create(m_symbol.Name(),m_period,IND_CUSTOM,4,parameters))
     {
      printf(__FUNCTION__+": Error initializing the object of the fast MA");
      return(false);
     }
     
//--- Number of buffers
   if(!m_fast_ma.NumBuffers(1)) return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the "Slow MA" indicator                                  |
//+------------------------------------------------------------------+
bool MA_Cross::CreateSlowMA(CIndicators *indicators)
  {
//--- Checking the pointer
   if(indicators==NULL) return(false);
//--- Adding an object to the collection
   if(!indicators.Add(GetPointer(m_slow_ma)))
     {
      printf(__FUNCTION__+": Error adding an object of the slow MA");
      return(false);
     }
//--- Setting parameters of the slow MA
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Custom Moving Average-Green.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_period_slow;      // Period
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=0;                  // Shift
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_method_slow;      // Method of averaging
//--- Object initialization  
   if(!m_slow_ma.Create(m_symbol.Name(),m_period,IND_CUSTOM,4,parameters))
     {
      printf(__FUNCTION__+": Error initializing the object of the slow MA");
      return(false);
     }
//--- Number of buffers
   if(!m_slow_ma.NumBuffers(1)) return(false);
//--- Reached this part, so the function was successful, return true
   return(true);
  }
//+------------------------------------------------------------------+
//| Returns the strength of the buy signal                           |
//+------------------------------------------------------------------+
int MA_Cross::LongCondition()
  {
   int signal=0;
//--- For operation with ticks idx=0, for operation with formed bars idx=1
   int idx=StartIndex();
//--- Values of MAs at the last formed bar
   double last_fast_value=FastMA(idx);
   double last_slow_value=SlowMA(idx);
//--- Values of MAs at the last but one formed bar
   double prev_fast_value=FastMA(idx+1);
   double prev_slow_value=SlowMA(idx+1);
//--- If the fast MA crossed the slow MA from bottom upwards on the last two closed bars
   if((last_fast_value>last_slow_value) && (prev_fast_value<prev_slow_value))
     {
      signal=100; // There is a signal to buy
     }
//--- Return the signal value
   return(signal);
  }
//+------------------------------------------------------------------+
//| Returns the strength of the sell signal                          |
//+------------------------------------------------------------------+
int MA_Cross::ShortCondition()
  {
   int signal=0;
//--- For operation with ticks idx=0, for operation with formed bars idx=1
   int idx=StartIndex();
//--- Values of MAs at the last formed bar
   double last_fast_value=FastMA(idx);
   double last_slow_value=SlowMA(idx);
//--- Values of MAs at the last but one formed bar
   double prev_fast_value=FastMA(idx+1);
   double prev_slow_value=SlowMA(idx+1);
//--- If the fast MA crossed the slow MA from up downwards on the last two closed bars
   if((last_fast_value<last_slow_value) && (prev_fast_value>prev_slow_value))
     {
      signal=100; // There is a signal to sell
     }
//--- Return the signal value
   return(signal);
  }
//+------------------------------------------------------------------+

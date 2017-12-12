//+------------------------------------------------------------------+
//|                                            Tigers-MediaMovel.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot A
#property indicator_label1  "A"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot B
#property indicator_label2  "B"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Venda
#property indicator_label3  "Venda"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  3
//--- plot Compra
#property indicator_label4  "Compra"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrDodgerBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  3
//--- indicator buffers
double         ABuffer[];
double         BBuffer[];
double         VendaBuffer[];
double         CompraBuffer[];
int            Status;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ABuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,CompraBuffer,INDICATOR_DATA);
   
   PlotIndexSetInteger(2,PLOT_ARROW,230);
   PlotIndexSetInteger(3,PLOT_ARROW,228);
   
   Status = 0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   for(int i = 3 ; i<rates_total;i++)
   {
      
      
       // create an Array for several prices
      double myMovingAverageArray1[],myMovingAverageArray2[];
      
      // define the properties of the Moving Average1
      int movingAverageDefinition1 = iMA (_Symbol,_Period,1,0,MODE_SMA,PRICE_CLOSE);
      
            // define the properties of the Moving Average2
      int movingAverageDefinition2 = iMA (_Symbol,_Period,20,0,MODE_SMA,PRICE_CLOSE);
      
      // sort the price array1 from the current candle downwards
      ArraySetAsSeries(myMovingAverageArray1,true);
      
      // sort the price array2 from the current candle downwards
      ArraySetAsSeries(myMovingAverageArray2,true);
      
      // Defined MA1, one line,current candle,3 candles, store result 
      CopyBuffer(movingAverageDefinition1,0,0,3,myMovingAverageArray1);
      
      // Defined MA2, one line,current candle,3 candles, store result 
      CopyBuffer(movingAverageDefinition2,0,0,3,myMovingAverageArray2);
      
      // calculate MA1 for the current candle
      double myMovingAverageValue1=myMovingAverageArray1[0];
      
      // calculate MA2 for the current candle
      double myMovingAverageValue2=myMovingAverageArray2[0];
      
      
      
      ABuffer[i]=close[i];
      //BBuffer[i]=close[i];
      
      if (   // Check if the 1 candle EA is above the 20 candle EA  
            (myMovingAverageValue1>myMovingAverageValue2)
         )
            {
            //CompraBuffer[i]=myMovingAverageValue1;
            }
      if (   // Check if the 20 candle EA is above the 1 candle EA          
            (myMovingAverageValue1<myMovingAverageValue2)
         )
            {
            //VendaBuffer[i]=myMovingAverageValue2;
            }     
      
      
      
      
      
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

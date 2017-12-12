void OnTick()
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
      
      if (   // Check if the 1 candle EA is above the 20 candle EA  
            (myMovingAverageValue1>myMovingAverageValue2)
         )
            {
            Comment ("BUY");
            }
      if (   // Check if the 20 candle EA is above the 1 candle EA          
            (myMovingAverageValue1<myMovingAverageValue2)
         )
            {
            Comment ("SELL");
            }     
  }
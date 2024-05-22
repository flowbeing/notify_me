import "dart:async";
import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";

import "../data/data.dart";
import "all_instruments_with_fetching_notification.dart";

/// This class retrieves and forwards much needed data to the app..
class DataProvider with ChangeNotifier{

  /// Data object
  Data? _data;
  /// A map of all forex and crypto prices
  Map<dynamic, dynamic> allForexAndCryptoPrices =
      allInstrumentsWithFetchingNotification;
  
  /// tracking whether an initial "fetching" notification has previously been
  /// set for allForexCryptoPrices
  bool isSetAllForexAndCryptoPricesFetching = false;

  /// Number of times prices have been retrieved from the relevant data provider
  int _countPricesRetrieval = 0;

  Future _initialDataAndDotEnv() async{

    /// loading configuration file
    await dotenv.load(fileName: "config.env");

    /// initializing Data class
    _data = Data();
    await _data!.createAppFilesAndFolders();
    await _data!.updateAndSaveAllSymbolsData();

  }

  Future allSymbolsWithFetchingNotification() async{

    /// setting an interim value for allForexAndCryptoPrices (Map)
    allForexAndCryptoPrices = await _data!.getMapOfAllPairsWithFetchingNotification();

    return allForexAndCryptoPrices;

  }

  /// This method retrieves the prices of forex and crypto pairs periodically
  Future updatePrices() async{

    /// initialzing dotenv, creating necessary files and folders, and
    /// updating instruments / symbols..
    await _initialDataAndDotEnv();

    print("");
    print("fetching all instruments' prices every 1 minute (approx)...");
    print("");

    _countPricesRetrieval += 1;
    print("Retrieved Forex & Crypto Prices: $_countPricesRetrieval");

    /// retrieving all prices..
    /// if successful, a map of all prices will be returned. Otherwise, an empty
    /// map will be returned..
    DateTime startTime = DateTime.now();
    Map<dynamic, dynamic> mapOfAllPrices = await _data!.getRealTimePriceAll();
    DateTime finishTime = DateTime.now();

    print("");
    print("updatePricesCompletionTime: ${finishTime.difference(startTime)}");
    print("");

    /// setting all prices to string value - "fetching"..
    /// useful when initializing the app for the first time..
    // if (allForexAndCryptoPrices.isEmpty && mapOfAllPrices.isEmpty){
    //   print("");
    //   print("allForexAndCryptoPrices & mapOfAllPrices are both empty");
    //   allForexAndCryptoPrices = _data!.mapOfSymbolsPreInitialPriceFetch;
    // }
    if (mapOfAllPrices.isNotEmpty){
      print("");
      allForexAndCryptoPrices = mapOfAllPrices;
    }

    /// note: if allForexAndCryptoPrices.isNotEmpty &&
    /// mapOfAllPrices.isNotEmpty, the previous value of
    /// allForexAndCryptoPrices will be used in the homepage..

    // print("timer: ${timer}");
    // print("timer tick: ${timer.tick}");

  }
}
import "dart:async";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";

import "../data/data.dart";

/// This class retrieves and forwards much needed data to the app..
class DataProvider with ChangeNotifier{

  /// Data object
  Data? _data;
  /// A map of all forex and crypto prices
  Map<dynamic, dynamic> allForexAndCryptoPrices = {};

  /// Number of times prices have been retrieved from the relevant data provider
  int countPricesRetrieval = 0;

  Future _initialDataAndDotEnv() async{

    /// loading configuration file
    await dotenv.load(fileName: "config.env");

    /// initializing Data class
    _data = Data();
    _data!.createAppFilesAndFolders();
  }

  /// This method retrieves the prices of forex and crypto pairs
  Future updatePrices() async{

    await _initialDataAndDotEnv();

    Timer.periodic(const Duration(minutes: 1), (timer) {
      countPricesRetrieval += 1;
      print("Retrieved Forex & Crypto Prices: $countPricesRetrieval");
    });

    allForexAndCryptoPrices = await _data!.getRealTimePriceAll();

    notifyListeners();

  }
}
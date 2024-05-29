import "dart:async";
import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";

import "../data/data.dart";
import '../data/enums.dart';

import "all_instruments_with_fetching_notification.dart";

enum UpdatePricesState { isIdle, isUpdating, isDoneUpdating }

/// This class retrieves and forwards much needed data to the app..
class DataProvider with ChangeNotifier {
  /// Data object
  Data? _data;

  /// A map of all forex and crypto prices
  Map<dynamic, dynamic> _allForexAndCryptoPrices =
      allInstrumentsWithFetchingNotification;

  /// filter to apply to _allForexAndCryptoPrices
  Filter _instrumentFilter = Filter.all;

  /// tracking whether prices are being updated
  bool isUpdatingPrices = false;

  // UpdatePricesState isUpdatingPrices = UpdatePricesState.isIdle;

  /// Number of times prices have been retrieved from the relevant data provider
  int _countPricesRetrieval = 0;

  Future _initialDataAndDotEnv() async {
    /// loading configuration file
    await dotenv.load(fileName: "config.env");

    /// initializing Data class
    _data = Data();
    await _data!.createAppFilesAndFolders();
    await _data!.updateAndSaveAllSymbolsData();
    _data!.getUriAppDirectory();
  }

  Future allSymbolsWithFetchingNotification() async {
    /// setting an interim value for _allForexAndCryptoPrices (Map)
    _allForexAndCryptoPrices =
        await _data!.getMapOfAllPairsWithFetchingNotification();

    return _allForexAndCryptoPrices;
  }

  /// This method retrieves the prices of forex and crypto pairs periodically
  Future updatePrices() async {
    /// signalling that updatePrices method in data provider
    /// is currently running
    isUpdatingPrices = true;
    // isUpdatingPrices = UpdatePricesState.isUpdating;

    print(
        "--------------------------------------------------------------------------------");
    print("");
    print("UPDATEPRICES METHOD - START");

    /// initializing dotenv, creating necessary files and folders, and
    /// updating instruments / symbols..
    await _initialDataAndDotEnv();

    print("");
    print("Fetching all instruments' prices every 1 minute (approx)...");

    _countPricesRetrieval += 1;
    print("Called UpdatePrices Method (Provider) $_countPricesRetrieval times");

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
    // if (_allForexAndCryptoPrices.isEmpty && mapOfAllPrices.isEmpty){
    //   print("");
    //   print("_allForexAndCryptoPrices & mapOfAllPrices are both empty");
    //   _allForexAndCryptoPrices = _data!.mapOfSymbolsPreInitialPriceFetch;
    // }

    if (mapOfAllPrices.isNotEmpty) {
      print("");
      _allForexAndCryptoPrices = mapOfAllPrices;
    }

    /// signalling that updatePrices method in data provider
    /// is currently running

    isUpdatingPrices = false;
    // isUpdatingPrices = UpdatePricesState.isDoneUpdating;

    print("UPDATEPRICES METHOD - END");
    print("");
    print(
        "--------------------------------------------------------------------------------");
    print("");

    /// note: if _allForexAndCryptoPrices.isNotEmpty &&
    /// mapOfAllPrices.isNotEmpty, the previous value of
    /// _allForexAndCryptoPrices will be used in the homepage..

    // print("timer: ${timer}");
    // print("timer tick: ${timer.tick}");
  }

  /// a (bypass) method for when a grid tile is clicked..
  ///
  /// prevents updatePrices from being called each time a grid tile is clicked
  Future nothingToSeeHere() async {}

  /// get instruments - can be all, forex, or crypto
  Map<dynamic, dynamic> getInstruments() {

    Map<dynamic, dynamic> mapToReturn = {};
    print("_allForexAndCryptoPrices.values.toList()[0]: ${_allForexAndCryptoPrices.values.toList()[0]}");


    if (_allForexAndCryptoPrices.values.toList()[0].runtimeType == String ||
        _instrumentFilter == Filter.all) {
      /// adding null value to match maps that would be created by the
      /// conditions below
      mapToReturn[null] = null;
      mapToReturn = _allForexAndCryptoPrices;
    } else {
      if (_instrumentFilter == Filter.forex) {
        mapToReturn = _allForexAndCryptoPrices.map((key, value) {
          if (value['type'] == "forex") {
            return MapEntry(key, value);
          }

          return const MapEntry(null, null);
        });
      } else if (_instrumentFilter == Filter.crypto) {
        mapToReturn = _allForexAndCryptoPrices.map((key, value) {
          if (value['type'] == "crypto") {
            return MapEntry(key, value);
          }

          return const MapEntry(null, null);
        });
      }
    }

    mapToReturn.remove(null);

    return mapToReturn;
  }

  void updateFilter(Filter filter) {
    _instrumentFilter = filter;
  }
}

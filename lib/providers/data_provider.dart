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

  /// list of all forex instruments
  List<dynamic> _listOfAllInstruments = [];

  /// filter to apply to _allForexAndCryptoPrices
  Filter _instrumentFilter = Filter.all;

  /// tracking whether prices are being updated
  bool _isUpdatingPrices = false;

  // UpdatePricesState _isUpdatingPrices = UpdatePricesState.isIdle;

  /// Number of times prices have been retrieved from the relevant data provider
  int _countPricesRetrieval = 0;

  /// loads this app's configuration file and creates all relevant File objects
  Future _initialDataAndDotEnv() async {
    /// loading configuration file
    await dotenv.load(fileName: "config.env");

    /// initializing Data class
    _data = Data();
    await _data!.createAppFilesAndFolders();
    await _data!.updateAndSaveAllSymbolsData();
    _data!.getUriAppDirectory();
  }

  /// returns a map of all instrument with all values set to "fetching"
  Future allSymbolsWithFetchingNotification() async {
    /// setting an interim value for _allForexAndCryptoPrices (Map)
    _allForexAndCryptoPrices =
        await _data!.getMapOfAllPairsWithFetchingNotification();

    return _allForexAndCryptoPrices;
  }

  /// returns the number of times updatePrices has been called
  int countPriceRetrieval() {
    return _countPricesRetrieval;
  }

  /// This method retrieves the prices of forex and crypto pairs periodically
  Future updatePrices() async {
    /// signalling that updatePrices method in data provider
    /// is currently running
    _isUpdatingPrices = true;
    // _isUpdatingPrices = UpdatePricesState.isUpdating;

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
      _listOfAllInstruments = mapOfAllPrices.keys.toList();
    }

    /// signalling that updatePrices method in data provider
    /// is currently running

    _isUpdatingPrices = false;
    // _isUpdatingPrices = UpdatePricesState.isDoneUpdating;

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

  /// a method to retrieve the value of _isUpdatingPrices
  ///
  /// helps determine whether prices are currently being updated
  bool getIsUpdatingPrices() {
    return _isUpdatingPrices;
  }

  /// a (bypass) method for when a grid tile is clicked..
  ///
  /// prevents updatePrices from being called each time a grid tile is clicked
  ///
  /// helps rebuild the homepage widget without triggering updatePrices method
  Future nothingToSeeHere() async {
    print("Nothing to see here");
  }

  /// get instruments - can be all, forex, or crypto
  Map<dynamic, dynamic> getInstruments() {
    // print(_allForexAndCryptoPrices);

    Map<dynamic, dynamic> mapToReturn = {};
    // print(
    // "_allForexAndCryptoPrices.values.toList()[0]: ${_allForexAndCryptoPrices.values.toList()[0]}");

    /// if no prices have not been fetched, return the default map which has the
    /// "fetching" notification set for all instruments. However, if prices have
    /// been fetched but "all" filter is active, show all instruments...
    if (_allForexAndCryptoPrices.values.toList()[0].runtimeType == String ||
        _instrumentFilter == Filter.all) {
      /// adding null value to match maps that would be created by the
      /// conditions below..
      mapToReturn = _allForexAndCryptoPrices;

      /// setting _listOfAllInstruments variable
      _listOfAllInstruments = _allForexAndCryptoPrices.keys.toList();
    }

    /// if prices have been fetched and the forex or crypto filter is active,
    /// return forex instrument or crypto instruments
    else {

      /// if the forex filter has been selected, show only forex data
      if (_instrumentFilter == Filter.forex) {

        _allForexAndCryptoPrices.forEach((key, value) {
          // print("value['type']: ${value['type']}");
          if (value['type'] == "forex") {
            mapToReturn[key] = value;
          }
        });

        /// setting _listOfAllInstruments variable
        _listOfAllInstruments = mapToReturn.keys.toList();

      } else if (_instrumentFilter == Filter.crypto) {

        _allForexAndCryptoPrices.forEach((key, value) {
          if (value['type'] == "crypto") {
            mapToReturn[key] = value;
          }
        });

        /// setting _listOfAllInstruments variable
        _listOfAllInstruments = mapToReturn.keys.toList();
      }
    }

    // print("mapToReturn: $mapToReturn");

    return mapToReturn;
  }

  /// this method returns a list of all instruments (strings) - List<String>
  List<dynamic> getListOfAllInstruments(){

    return _listOfAllInstruments;

  }

  /// this method help retrieve the value of the first item in the map of
  /// all instruments i.e _allForexAndCryptoPrices
  dynamic getTypeFirstValueInMapOfAllInstruments() {

    String firstKeyPriceAllInstruments =
        _allForexAndCryptoPrices.keys.toList()[0];

    dynamic typeFirstValueInMapOfAllInstruments =
        _allForexAndCryptoPrices[firstKeyPriceAllInstruments].runtimeType;

    return typeFirstValueInMapOfAllInstruments;

  }

  /// this method helps update the instrument type that should be displayed
  /// i.e forex, crypto, or both...
  void updateFilter({required Filter filter}) {
    if (_instrumentFilter != filter) {
      _instrumentFilter = filter;
      // notifyListeners();
      print("current filter: $_instrumentFilter");
    }
  }

  /// this method calculates the row number of a currency pair within this app's
  /// GridView builder..
  int getInstrumentGridViewRowNumber({required String instrument}) {
    Map filteredAllInstruments = getInstruments();

    List<dynamic> listOfAllKeys = filteredAllInstruments.keys.toList();
    int indexOfInstrumentInMapOfAllInstruments =
        listOfAllKeys.indexOf(instrument);

    print("indexOfInstrumentInMapOfAllInstruments: ${indexOfInstrumentInMapOfAllInstruments}");

    /// checking whether the index is an odd number
    // bool isOddNumber = indexOfInstrumentInMapOfAllInstruments % 2 != 0;

    // int numberToCalcRowOn = isOddNumber
    //     ? indexOfInstrumentInMapOfAllInstruments - 1
    //     : indexOfInstrumentInMapOfAllInstruments;

    /// instrument's row number within app's gridview
    int instrumentRowNum =  (indexOfInstrumentInMapOfAllInstruments / 2).round() - 1;

    print("instrumentRowNum: ${instrumentRowNum}");

    return instrumentRowNum;

  }


}

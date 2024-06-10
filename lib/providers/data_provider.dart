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

  /// a map of all alerts
  Map<String, Map> mapOfAllAlerts = {};

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

  /// determine whether the prices data have not been fetched
  bool _isFirstValueInMapOfAllInstrumentsContainsFetching = true;

  /// timer - updatePrices method..
  Timer _relevantTimer =
      Timer.periodic(const Duration(microseconds: 1), (timer) {
    timer.cancel();
  });

  /// timer - check if prices have finished updating
  Timer _isPricesUpdatedCheckingTimer =
      Timer.periodic(const Duration(microseconds: 1), (timer) {
    timer.cancel();
  });

  /// timer to set manually entered currency pair, if any
  Timer _updateCurrencyPairManually =
      Timer.periodic(const Duration(microseconds: 1), (timer) {
    timer.cancel();
  });

  /// text that's been entered into the currency pair text form field -
  /// CurrencyPairTextFieldOrCreateAlertButton
  String? _enteredCurrencyPair;
  bool? _isErrorEnteredText;

  /// CurrencyPairTextFieldOrCreateAlertButton's focus if any
  bool _hasFocusCurrencyPairTextField = false;

  /// bool that signals whether the keyboard is visible as a result of clicking
  /// the currency price text form field widget
  bool _hasFocusAlertPriceTextField = false;

  bool _hasFocusCurrencyPairAndAlertPriceTextFields = false;

  /// registers the price of the alert that will be added
  String _alertPriceCurrencyPriceTextField = "";

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

  /// WIDGET VARIABLES
  int _indexSelectedGridTile = 3;

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

    if (_isFirstValueInMapOfAllInstrumentsContainsFetching == true) {
      /// setting a dummy alert price for the initially selected currency pair
      /// (4th pair) in the map of all prices when prices are being fetched for
      /// the first time..
      setAlertPriceCurrencyPriceTextField();
    }

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

    /// if the values of mapOfAllPrices are Strings, which
    /// will only happen when the prices are being displayed for the
    /// first time or have not been fetched, create future timers and
    /// notify listeners..
    defineIsFirstValueInMapOfAllInstrumentsContainsFetching();

    if (_isFirstValueInMapOfAllInstrumentsContainsFetching) {
      print('priceAllInstruments contains "fetching"');
      print("");
      print("HOMEPAGE - END - 5s");
      print(
          "--------------------------------------------------------------------------------");
      print("");

      /// updating timers
      updateTimers(isOneMin: false);
      notifyListeners();
    }

    /// ... otherwise, wait for 1 minute (approx) future timers and notify
    /// listeners
    else {
      /// setting the alert price for the currently selected currency pair
      /// after prices have been fetched at least once
      setAlertPriceCurrencyPriceTextField();

      /// updating timers
      updateTimers(isOneMin: true);
      notifyListeners();
    }
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
  List<dynamic> getListOfAllInstruments() {
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

  /// this method helps determine whether prices have been fetched
  void defineIsFirstValueInMapOfAllInstrumentsContainsFetching() {
    if (getTypeFirstValueInMapOfAllInstruments() != String) {
      _isFirstValueInMapOfAllInstrumentsContainsFetching = false;
    }
  }

  /// this method helps get the value of
  /// defineIsFirstValueInMapOfAllInstrumentsContainsFetching
  bool getIsFirstValueInMapOfAllInstrumentsContainsFetching() {
    return _isFirstValueInMapOfAllInstrumentsContainsFetching;
  }

  /// updates the selected grid tile's index as well the alert price..
  void updateIndexSelectedGridTile({required int newIndexSelectedGridTile}) {
    _indexSelectedGridTile = newIndexSelectedGridTile;

    /// update the alert price to reflect the newly selected grid tile's
    /// price..
    setAlertPriceCurrencyPriceTextField();

    /// remove hasFocus to false for the alert price text form field since
    /// a new grid tile has been clicked and will be reflected
    // updateHasFocusATextField(hasFocus: false); // -->

    /// notifyListeners
    notifyListeners();

    /// affect didChangeDependencies of listening widgets
  }

  /// retrieves the index of the selected grid tile
  int getIndexSelectedGridTile() {
    return _indexSelectedGridTile;
  }

  /// retrieves the currently selected pair
  String getCurrentlySelectedInstrument() {
    return _listOfAllInstruments[_indexSelectedGridTile];
  }

  /// signals that the currency pair text field has just been tapped
  void updateHasFocusCurrencyPairTextField({required bool hasFocus}) {
    _hasFocusCurrencyPairTextField = hasFocus;
    notifyListeners();
  }

  /// retrieves the signal that stipulates whether the currency pair text field
  /// has focus
  bool getHasFocusCurrencyPairTextField() {
    return _hasFocusCurrencyPairTextField;
  }

  /// signals that the alert price text field has just been tapped
  void updateHasFocusAlertPriceTextField({required bool hasFocus}) {
    _hasFocusAlertPriceTextField = hasFocus;
    notifyListeners();
  }

  /// retrieves the signal that stipulates whether the alert price text field
  /// has focus
  bool getHasFocusAlertPriceTextField() {
    return _hasFocusAlertPriceTextField;
  }

  /// retrieves the signal that stipulates whether or not currency
  /// pair or alert price text form field is being edited
  bool getHasFocusCurrencyPairOrAlertPriceTextField(){

    if (_hasFocusCurrencyPairTextField==true || _hasFocusAlertPriceTextField==true){
      _hasFocusCurrencyPairAndAlertPriceTextFields=true;
    }
    else if (_hasFocusCurrencyPairTextField==false && _hasFocusAlertPriceTextField==false) {
      _hasFocusCurrencyPairAndAlertPriceTextFields=false;
      // notifyListeners();
    }

    return _hasFocusCurrencyPairAndAlertPriceTextFields;


  }

  /// retrieves the currently selected pair's price if any (i.e if prices have
  /// been fetched..
  ///
  /// a helper function for setAlertPriceCurrencyPriceTextField
  String getCurrentlySelectedInstrumentPrice() {
    bool isFetchingPrices =
        getIsFirstValueInMapOfAllInstrumentsContainsFetching();

    /// ensuring that the list of all instruments fits the current filter
    getInstruments();

    String currentlySelectCurrencyPair =
        _listOfAllInstruments[_indexSelectedGridTile];

    return isFetchingPrices
        ? "0.00000"
        : _allForexAndCryptoPrices[currentlySelectCurrencyPair]
            ['current_price'];
  }

  /// sets the alert price of the currently selected currency pair when
  void setAlertPriceCurrencyPriceTextField() {
    /// bool to signal that prices are being fetched for the first time..
    bool isFetchingPrices =
        getIsFirstValueInMapOfAllInstrumentsContainsFetching();

    if (isFetchingPrices) {
      _alertPriceCurrencyPriceTextField = "0.00000";
    } else {
      String currentlySelectedInstrumentPrice =
          getCurrentlySelectedInstrumentPrice();

      if (currentlySelectedInstrumentPrice == "demo") {
        _alertPriceCurrencyPriceTextField = "0.00000";
      } else {
        _alertPriceCurrencyPriceTextField = currentlySelectedInstrumentPrice;
      }
    }
  }

  /// updates the alert price of the currently selected currency pair
  void updateAlertPriceCurrencyPriceTextField({required String alertPrice}) {
    _alertPriceCurrencyPriceTextField = alertPrice;
  }

  /// gets the price of the currency pair that should be added to the currency
  /// pair..
  String getAlertPriceCurrencyPriceTextField() {
    return _alertPriceCurrencyPriceTextField;
  }

  /// update entered currency pair text ->
  /// CurrencyPairTextFieldOrCreateAlertButton
  ///
  /// When the entered text is a valid currency pair, this method will help to
  /// update the grid view widget with the currently selected (entered) pair
  void updateEnteredTextCurrencyPair({
    required String? enteredText,
    bool? isErrorEnteredText,
    FocusNode? focusNode,
    /// used with FocusScope to determine whether the keyboard is still visible
    BuildContext? context
  }) {
    /// when grid tile gets tapped, reset the manually entered tell by setting
    /// it to null. enteredText will be null
    if (focusNode == null) {
      _enteredCurrencyPair = enteredText;
      _isErrorEnteredText = null;
    }

    /// reset _updateCurrencyPairManually timer, if any, when an invalid
    /// currency pair text gets entered
    if (enteredText == null &&
        isErrorEnteredText == null &&
        focusNode != null &&
        _updateCurrencyPairManually.isActive) {
      _updateCurrencyPairManually.cancel();
      _enteredCurrencyPair = null;
      _isErrorEnteredText = null;
    }

    // _enteredCurrencyPair = enteredText;
    // _isErrorEnteredText = isErrorEnteredText;

    /// if the entered currency pair is valid, update the index of the selected
    /// grid tile..
    // if (_isErrorEnteredText == null) {
    //   int indexOfEnteredValidCurrencyPair =
    //   _listOfAllInstruments.indexOf(_enteredCurrencyPair);
    //
    //   _indexSelectedGridTile = indexOfEnteredValidCurrencyPair;
    //   // notifyListeners();
    //
    // }

    // /// signalling that the keyboard is visible
    // ///
    // /// may not be necessary
    // if (focusNode != null){
    //   if (focusNode.hasFocus){
    //     _hasFocusCurrencyPairTextField=true;
    //   }
    // }

    /// if the "done" button gets clicked by the user or the  currency pair
    /// text form field isn't being focused on any longer, reload all listening
    /// widgets including the ContainerGridViewBuilder custom widget
    /// to reflect the currently selected currency pair..
    if (enteredText != null && focusNode != null) {
      print("focusNode updateEnteredTextCurrencyPair: ${focusNode.hasFocus}");

      _updateCurrencyPairManually.cancel();

      _updateCurrencyPairManually =
          Timer.periodic(const Duration(milliseconds: 0), (timer) {
        print("timer: $timer");

        // if (focusNode.hasFocus == false) {

          _enteredCurrencyPair = enteredText;
          _isErrorEnteredText = isErrorEnteredText;

          /// if the entered currency pair is valid, update the index of the
          /// selected grid tile..
          if (_isErrorEnteredText == null) {
            int indexOfEnteredValidCurrencyPair =
                _listOfAllInstruments.indexOf(_enteredCurrencyPair);

            _indexSelectedGridTile = indexOfEnteredValidCurrencyPair;

            /// setting the alert price of the entered currency pair
            setAlertPriceCurrencyPriceTextField();
          }

          /// if the alert price text field gains focus immediately after the
          /// currency pair text form field loses focus, ensure that the blur
          /// effect remains
          // bool isKeyboardStillVisible = FocusScope.of(context!).hasFocus;
          //
          // if (isKeyboardStillVisible){
          //   _hasFocusCurrencyPairTextField=true;
          // }else{
          //   _hasFocusCurrencyPairTextField=false;
          // }

          // _hasFocusCurrencyPairTextField=false;

          timer.cancel();

          notifyListeners();
        // }
      });
    }
  }

  /// retrieves manually entered currency pair text and its error if any
  Map<String, dynamic> getEnteredTextCurrencyPair() {
    return {
      "enteredCurrencyPair": _enteredCurrencyPair,
      "isErrorEnteredText": _isErrorEnteredText
    };
  }

  /// this method helps update the instrument type that should be displayed
  /// i.e forex, crypto, or both...
  void updateFilter({required Filter filter}) {
    if (_instrumentFilter != filter) {
      _instrumentFilter = filter;

      /// update the list of all instruments to include only currency pairs that
      /// fit into the selected filter
      setAlertPriceCurrencyPriceTextField();

      notifyListeners();
      print("current filter: $_instrumentFilter");
    }
  }

  /// this method calculates the row number of the selected currency pair within
  /// this app's GridView builder..
  int getCurrentlySelectedInstrumentRowNumber() {
    Map filteredAllInstruments = getInstruments();

    String currentlySelectedInstrument = getCurrentlySelectedInstrument();

    List<dynamic> listOfAllKeys = filteredAllInstruments.keys.toList();
    int indexOfInstrumentInMapOfAllInstruments =
        listOfAllKeys.indexOf(currentlySelectedInstrument);

    print(
        "indexOfInstrumentInMapOfAllInstruments: ${indexOfInstrumentInMapOfAllInstruments}");

    /// checking whether the index is an odd number
    // bool isOddNumber = indexOfInstrumentInMapOfAllInstruments % 2 != 0;

    // int numberToCalcRowOn = isOddNumber
    //     ? indexOfInstrumentInMapOfAllInstruments - 1
    //     : indexOfInstrumentInMapOfAllInstruments;

    /// instrument's row number within app's gridview
    int instrumentRowNum =
        ((indexOfInstrumentInMapOfAllInstruments + 1) / 2).round();

    print("instrumentRowNum: ${instrumentRowNum}");

    return instrumentRowNum;
  }

  /// this method updates timers when prices have been fetched
  void updateTimers({required bool isOneMin}) {
    /// is price currently being updated
    ///
    /// dataProvider!.getIsUpdatingPrices() is used below instead of
    /// "updatingPrices" variable to ensure that the latest state prices
    /// update state is obtained directly from dataProvider...
    // bool isPriceUpdating = dataProvider!.getIsUpdatingPrices();

    if (isOneMin == false) {
      /// if a previous 5 seconds timer is no longer active and it's
      /// corresponding dataProvider!.updatePrices (Future) is has
      /// finished running set _relevantTimer to a timer that should
      /// execute  dataProvider!.updatePrices 5 seconds in the
      /// future

      if (_relevantTimer.isActive == false && _isUpdatingPrices == true) {
        _relevantTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
          timer.cancel();

          // setState(() {
          //   print("Timer.periodic - 1 min: ${DateTime.now()}");
          //   isNonTextFormFieldTriggeredBuild = true;
          // });

          updatePrices();
        });
      }
    } else if (isOneMin == true) {
      print('priceAllInstruments contains "prices"');
      print("");
      print("HOMEPAGE - END - 1min");
      print(
          "--------------------------------------------------------------------------------");
      print("");

      print("_relevantTimer outside: $_relevantTimer");
      print(
          "_relevantTimer.isActive == false && isPriceUpdating == false in: ${_relevantTimer.isActive == false && _isUpdatingPrices == false}");

      /// If prices are currently being updated, replace current
      /// _relevantTimer with another when prices have fully been
      /// updated..
      ///
      /// useful when a grid tile has been clicked but prices
      /// are still being updated, which would normally prevent
      /// the rebuilt version of this page that has been triggered
      /// by the grid tile selection from reflecting the updated
      /// prices when the prices have finished updating..
      if (_isUpdatingPrices == true) {
        /// cancel any previously set (active) price update
        /// operation status checking timer to prevent the creation
        /// of multiple memory hogging timers..
        if (_isPricesUpdatedCheckingTimer.isActive) {
          _isPricesUpdatedCheckingTimer.cancel();
        }

        print("isPriceUpdating == true");

        /// create and store the new value of price update
        /// operation status checking timer..
        _isPricesUpdatedCheckingTimer =
            Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          // 1000
          print("Duration(milliseconds: 1000)");
          print(
              "2. _relevantTimer.isActive == false && isPriceUpdating == false: ${_relevantTimer.isActive == false && _isUpdatingPrices == false}");
          print(
              "2. _relevantTimer.isActive == false: ${_relevantTimer.isActive == false}");
          print("2. isPriceUpdating == false: ${_isUpdatingPrices == false}");
          print("");

          /// dataProvider!.getIsUpdatingPrices() is used below instead of
          /// "updatingPrices" variable to ensure that the latest state prices
          /// update state is obtained directly from dataProvider...

          if (_relevantTimer.isActive == false && _isUpdatingPrices == false) {
            print("gridTile _relevantTimer in: $_relevantTimer");
            print("gridTile selected: _relevantTimer.isActive == false "
                "&& isPriceUpdating == false in: ${_relevantTimer.isActive == false && _isUpdatingPrices == false}");

            // /// updating all instruments' price data
            // priceAllInstruments = dataProvider!.getInstruments();

            _relevantTimer =
                Timer.periodic(const Duration(milliseconds: 60001), (timer) {
              timer.cancel();

              // setState(() {
              //   isNonTextFormFieldTriggeredBuild = true;
              // });

              updatePrices();
            });

            timer.cancel();

            /// arbitrarily rebuild this FutureBuilder widget..
            ///
            /// Note that isGridTileOrFilterOptionClickedOrKeyboardVisible will be set back to
            /// false once this FutureBuilder widget has been
            /// rebuilt..
            // setState(() {
            //   isGridTileOrFilterOptionClickedOrKeyboardVisible = true;
            // });
          }
        });
      }

      /// if a previous 1 minute timer is no longer active and it's
      /// corresponding dataProvider!.updatePrices (Future) has
      /// finished running i.e prices have finished updating,
      /// set _relevantTimer to a timer that should
      /// execute dataProvider!.updatePrices one minute in the
      /// future..
      ///
      /// the conditions below mean "wait until the previously set
      /// relevant timer has done it's job.."
      else if (_relevantTimer.isActive == false && _isUpdatingPrices == false) {
        print("3. _relevantTimer in: $_relevantTimer");
        print("3. _relevantTimer.isActive == false "
            "&& isPriceUpdating == false in: "
            "${_relevantTimer.isActive == false && _isUpdatingPrices == false}");

        _relevantTimer =
            Timer.periodic(const Duration(milliseconds: 60001), (timer) {
          timer.cancel();

          // setState(() {
          //   isNonTextFormFieldTriggeredBuild = true;
          // });

          updatePrices();
        });
      }
    }
  }

  /// subtracts or adds a unit or five units to the current instrument's
  /// alert price
  String subtractOrAddOneOrFiveUnitsFromAlertPrice({
    /// to determine the actual unit price of the entered alert price
    required String currentPairPriceStructure,
    /// the entered alert price, regardless of whether the price structure
    /// of the user has changed the currently selected pair's price by editing
    /// it..
    required String alertPrice,
    required isSubtract
  }){

    /// obtaining the original count of numbers that exist after the "." symbol
    /// - currentPairPriceStructure
    List<String> alertPriceOriginalStructureSplit = currentPairPriceStructure.split("");
    int lengthOfCurrentPairPriceStructure = currentPairPriceStructure.length;
    int countOfNumAfterDot = 0;

    if (alertPriceOriginalStructureSplit.contains(".")){
      int indexOfDot = alertPriceOriginalStructureSplit.indexOf(".");
      int positionOfDot=indexOfDot+1;
      countOfNumAfterDot=lengthOfCurrentPairPriceStructure-(positionOfDot);
    }

    /// determining one unit of the current alert price
    String aUnitOfTheAlertPrice = "1";

    if (countOfNumAfterDot!=0){
      aUnitOfTheAlertPrice="0.${"0"*countOfNumAfterDot}";
      List<String> incrementValueOneUnitSplit= aUnitOfTheAlertPrice.split('');
      int indexOfLastItemInIncrementValueOneUnitSplit = aUnitOfTheAlertPrice.length - 1;
      incrementValueOneUnitSplit[indexOfLastItemInIncrementValueOneUnitSplit] = "1";
      aUnitOfTheAlertPrice=incrementValueOneUnitSplit.join("");
    }

    print("aUnitOfTheAlertPrice: ${aUnitOfTheAlertPrice}");

    /// subtracting or adding a unit to the alert price depending on the
    /// specified operation type..
    String finalValue = "0";

    if (isSubtract){
      /// subtracting a unit of the selected currency pair's original price
      /// (structure) from the visible alert price ..
      finalValue = (double.parse(alertPrice) - double.parse(aUnitOfTheAlertPrice)).toStringAsFixed(countOfNumAfterDot);
    } else {
      /// adding a unit of the selected currency pair's original price
      /// (structure) from the visible alert price..
      finalValue = (double.parse(alertPrice) + double.parse(aUnitOfTheAlertPrice)).toStringAsFixed(countOfNumAfterDot);
    }

    return finalValue;
  }

  /// add alert to map of all alerts
  void addAlertToMapOfAllAlerts({
    required String currencyPair,
    required String alertPrice
  }){

    List<String> alreadyAddedAlertCurrencyPair = mapOfAllAlerts.keys.toList();
    bool isCurrencyInMapOfAlerts = alreadyAddedAlertCurrencyPair.contains(currencyPair);
    int keyCurrentAlert=0;

    bool isAlertAlreadyExist = false;


    if (isCurrencyInMapOfAlerts==false){
      // int numberOfExistingAlertsForTheSpecifiedPair = mapOfAllAlerts[currencyPair].keys.toList();
      mapOfAllAlerts[currencyPair]={};
    }

    /// obtaining the list of already created alerts (prices) for the specified
    /// currency pair
    List<dynamic> listOfAlertsPricesCurrentCurrencyPair=mapOfAllAlerts[currencyPair]!.values.toList();

    /// setting the map key of the alert that should be created
    ///
    /// only used if the alert does not already exist
    keyCurrentAlert=listOfAlertsPricesCurrentCurrencyPair.length;

    /// checking whether the alert already exists
    if (isCurrencyInMapOfAlerts==true){
      isAlertAlreadyExist = listOfAlertsPricesCurrentCurrencyPair.contains(alertPrice);
    }

    /// including the alert into the map of all alerts if it does not already
    /// exist
    if (isAlertAlreadyExist==false){
      mapOfAllAlerts[currencyPair]![keyCurrentAlert]=alertPrice;
    }

  }

}

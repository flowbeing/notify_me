import "dart:async";
import 'dart:convert';
import "dart:math";

import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "package:audioplayers/audioplayers.dart";

import "../data/data.dart";
import '../data/enums.dart';
import "../helper_functions/helper_functions.dart";

import "all_instruments_with_fetching_notification.dart";

enum UpdatePricesState { isIdle, isUpdating, isDoneUpdating }

/// This class retrieves and forwards much needed data to the app..
class DataProvider with ChangeNotifier {
  /// this boolean signals whether the application is active or has been
  /// minimized
  // bool _isAppMinimized=false;

  /// Data object
  Data? _data;

  /// a map of all alerts
  Map<dynamic, dynamic> _mapOfAllAlerts = {}; // <Map<String, List<dynamic>>>

  /// bool that signals whether all price alerts have been muted
  bool _isAllPriceAlertsMuted = false;

  /// true if:
  /// 1. a price alert has been fulfilled &&
  /// 2. the price alert has not been set to mute
  // bool _isSoundAlertAlarm=false;

  /// number of fulfilled alerts
  ///
  /// i.e alerts that have been met
  int _countFulfilledUnMutedAlerts = 0;

  /// an instance of audio player
  ///
  /// used to play a sound when a price alert has been fulfilled
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// bool that tracks whether the alert is currently playing
  bool _isPlayingAlertSound = false;

  /// timer -plays an audio at regular intervals when a price alert has been
  /// fulfilled
  Timer _timerAudioPlayer =
      Timer.periodic(const Duration(microseconds: 1), (timer) {
    timer.cancel();
  });

  /// A map of all forex and crypto prices
  Map<dynamic, dynamic> _allForexAndCryptoPrices =
      allInstrumentsWithFetchingNotification;

  /// map of all instruments for the currently selected filter
  Map<dynamic, dynamic> _mapOfAllInstrumentCurrentFilter = {};

  /// list of all forex instruments
  List<dynamic> _listOfAllInstruments = [];

  /// CURRENTLY SELECTED GRID TILE INDEX
  ///
  /// initially selected grid tile is set to 3 for Filter.all since Filter.all
  /// will be the first selection filter option
  int _indexSelectedGridTile = 3;

  /// a unit of the currently selected pair's price
  // String _selectedCurrencyPairOneUnitOfPrice = "";

  /// SELECTED GRID TILE INDEXES FOR EACH FILTER
  // Map<Filter, dynamic> _indexSelectedGridTileMap = {
  //   Filter.all: 3,
  //   Filter.forex: null,
  //   Filter.crypto: null
  // };

  /// filter to apply to _allForexAndCryptoPrices
  Filter _instrumentFilter = Filter.all;

  /// tracking whether prices are being updated
  bool _isUpdatingPrices = false;

  // UpdatePricesState _isUpdatingPrices = UpdatePricesState.isIdle;

  /// Number of times the updatePrices method has been called
  int _countUpdatePricesCall = 0;

  /// determine whether the prices data have not been fetched
  bool _isFirstValueInMapOfAllInstrumentsContainsFetching = true;

  /// timer - updatePrices method..
  Timer _relevantTimer =
      Timer.periodic(const Duration(microseconds: 0), (timer) {
    timer.cancel();
  });

  /// timer - check if prices have finished updating
  Timer _isPricesUpdatedCheckingTimer =
      Timer.periodic(const Duration(microseconds: 0), (timer) {
    timer.cancel();
  });

  /// timer to set manually entered currency pair, if any
  Timer _updateCurrencyPairManually =
      Timer.periodic(const Duration(microseconds: 0), (timer) {
    timer.cancel();
  });

  /// timer to check if a user's device that's actively running updatePrices
  /// method is done
  Timer _isGlobalUserRunningUpdatePricesDoneTimer =
      Timer.periodic(const Duration(microseconds: 0), (timer) {
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

  /// holds an original alert price for the currently selected currency
  String _alertPriceCurrencyPriceTextField = "";

  /// hold an original or edited alert price for the currently selected
  /// currency
  String _originalOrEditedAlertPriceCurrencyPriceTextField = "";

  /// a unique id that helps locate a device's isAllowedTimeExpired value
  /// in firebase
  String deviceUniqueId = "";

  /// updates the boolean that signals whether the app has been minimized
  // updateIsAppMinimised({required bool isAppMinimized}){
  //   _isAppMinimized=isAppMinimized;
  // }

  /// loads this app's configuration file and creates all relevant File objects
  Future _initialDataAndDotEnv({required bool isUseLocalStorage}) async {
    /// loading configuration file
    await dotenv.load(fileName: "config.env");

    /// initializing Data class
    _data = Data(isUseLocalStorage: isUseLocalStorage);

    /// creating files, folders or firebase realtime database references
    /// based on whether local or online storage should be used
    await _data!.createFilesAndFoldersOrFirebaseRefs();
    await _data!.updateAndSaveAllSymbolsData();

    /// used to obtain the app directory's URI when local storage is used
    if (isUseLocalStorage) {
      _data!.getUriAppDirectory();
    }
  }

  /// returns a map of all instrument with all values set to "fetching"
  Future allSymbolsWithFetchingNotification() async {
    /// setting an interim value for _allForexAndCryptoPrices (Map)
    // _allForexAndCryptoPrices =
    //     await _data!.getMapOfAllPairsWithFetchingNotification();

    return _allForexAndCryptoPrices;
  }

  /// returns the number of times updatePrices has been called
  int countPriceRetrieval() {
    return _countUpdatePricesCall;
  }

  Future<Map<dynamic, dynamic>> _getIsCallUpdatePricesFully() async {
    /// map to return
    Map<dynamic, dynamic> mapIsCallUpdatePricesFully = {};

    /// IMPORTANT VARIABLES
    /// devices that made it into getRealtimePricesAll method in
    /// data.dart (including the ones that slipped in due to the fact that
    /// two or more devices called updatePrices method at the same time and
    /// received all the requirements needed to call getRealtimePricesAll to
    /// update price data)..
    // List<dynamic> listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll = [];
    Map mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll = {};

    /// time since last price data update
    int secondsSinceLastPricesDataUpdate = 0;

    /// map of the updated prices from the last update session
    Map<dynamic, dynamic> lastUpdateSessionMap = {};

    /// REFERENCES
    /// Firebase Database Reference:
    ///
    // /// list of devices currently updating prices data within
    // /// getRealTimePriceAll method in data.dart
    // DatabaseReference
    //     listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef =
    //     FirebaseDatabase.instance
    //         .ref("listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef");

    /// map of devices currently updating prices data within
    /// getRealTimePriceAll method in data.dart
    DatabaseReference
        mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef =
        FirebaseDatabase.instance
            .ref("mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef");

    /// last prices update session's data; includes:
    /// 1. last update session time
    /// 2. currency and their prices from the last update session
    DatabaseReference lastUpdateSessionRef =
        FirebaseDatabase.instance.ref("dataUpdateSessionsRef");

    /// isAllowedTimeExpired - devicesThatExceededAllowedUpdateTimeMapRef
    /// Database Reference:
    DatabaseReference devicesThatExceededAllowedUpdateTimeMapRef =
        FirebaseDatabase.instance
            .ref("devicesThatExceededAllowedUpdateTimeMapMapRef");

    /// SNAPSHOTS
    /// Firebase Database Snapshot:
    // /// list of devices currently updating prices data within
    // /// getRealTimePriceAll method in data.dart
    // DataSnapshot listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllSnap =
    //     await listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef.get();

    /// map of devices currently updating prices data within
    /// getRealTimePriceAll method in data.dart
    DataSnapshot? mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllSnap;

    /// dataUpdateSessions Snapshot:
    DataSnapshot? lastUpdateSessionSnap;

    /// devicesThatExceededAllowedUpdateTimeMap
    DataSnapshot? devicesThatExceededAllowedUpdateTimeMapSnap;

    try {
      mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllSnap =
          await mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef
              .get();
      lastUpdateSessionSnap = await lastUpdateSessionRef.get();
      devicesThatExceededAllowedUpdateTimeMapSnap =
          await devicesThatExceededAllowedUpdateTimeMapRef.get();
    } catch (error) {
      print("an error occured while fetching snapshots");
    }

    /// RETRIEVING AND DEFINING THE ABOVE "IMPORTANT VARIABLES"
    /// checking whether the reference that holds the map of devices that are
    /// currently updating prices data within getRealTimePriceAll method in
    /// data.dart exists
    ///
    /// if it doesn't, create it
    // if (!listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllSnap.exists) {
    if (!mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllSnap!.exists) {
      // listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef.set(jsonEncode([]));
      try {
        print(
            "tried creating mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef");
        // String now=cleanDateTimeAndReturnString(dateTime: DateTime.now());
        await mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef.set({
          'dummyActiveUpdateDevice': jsonEncode({}),
          "leadingDeviceId": "none"
        });
      } catch (error) {
        print(
            'an error occured: mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef.set({});');
      }
    } else {
      /// --->
      // /// a list of devices that are currently updating prices data within
      // /// getRealTimePriceAll method
      // listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll = jsonDecode(jsonDecode(
      //     jsonEncode(
      //         listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllSnap
      //             .value!
      //     )
      // ));
      /// a map of devices that are currently updating prices data within
      /// getRealTimePriceAll method
      mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll = jsonDecode(
          jsonEncode(mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllSnap
              .value!));

      /// removing dummy and unnecessary data from mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll
      if (mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll
          .containsKey("dummyActiveUpdateDevice")) {
        mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll
            .remove("dummyActiveUpdateDevice");
        mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll
            .remove("leadingDeviceId");
      }
    }

    /// if dataUpdateSessionsRef does not exist, create it
    if (!lastUpdateSessionSnap!.exists) {
      try {
        await lastUpdateSessionRef.set(jsonEncode({}));
      } catch (error) {
        print('an error occured: lastUpdateSessionRef.set(jsonEncode({}));');
      }
    } else {
      /// setting the prices map using the last price data update session
      lastUpdateSessionMap = await jsonDecode(
          jsonDecode(jsonEncode(lastUpdateSessionSnap.value!)));

      List listOfKeysInLastUpdateSessionMap =
          lastUpdateSessionMap.keys.toList();
      DateTime? lastUpdateSessionTime;

      /// setting the last prices' update session time if lastUpdateSessionMap
      /// isn't empty and contains either one of the following keys:
      /// 1. last_prices_data_update_time
      /// 2. last_prices_data_update_time_INITIAL
      if (listOfKeysInLastUpdateSessionMap
          .contains("last_prices_data_update_time")) {
        /// setting lastUpdateSessionTime
        String lastUpdateSessionTimeString =
            lastUpdateSessionMap["last_prices_data_update_time"]
                .keys
                .toList()[0];
        String properLastUpdateSessionTimeString =
            retrieveDatetimeStringFromCleanedDateTimeString(
                cleanedDateTimeString: lastUpdateSessionTimeString);
        lastUpdateSessionTime =
            DateTime.parse(properLastUpdateSessionTimeString);
      } else if (listOfKeysInLastUpdateSessionMap
          .contains("last_prices_data_update_time_initial")) {
        /// setting lastUpdateSessionTime
        String lastUpdateSessionTimeString =
            lastUpdateSessionMap["last_prices_data_update_time_initial"]
                .keys
                .toList()[0];
        String properLastUpdateSessionTimeString =
            retrieveDatetimeStringFromCleanedDateTimeString(
                cleanedDateTimeString: lastUpdateSessionTimeString);
        lastUpdateSessionTime =
            DateTime.parse(properLastUpdateSessionTimeString);
      }

      /// if lastUpdateSessionTime exists, calculate how long it's been since
      /// the last price update session
      if (lastUpdateSessionTime != null) {
        DateTime now = DateTime.now();
        secondsSinceLastPricesDataUpdate =
            now.difference(lastUpdateSessionTime).inMilliseconds;
      }
    }

    /// if devicesThatExceededAllowedUpdateTimeMapRef does not exist, create it
    if (!devicesThatExceededAllowedUpdateTimeMapSnap!.exists) {
      try {
        await devicesThatExceededAllowedUpdateTimeMapRef.set(jsonEncode({}));
      } catch (error) {
        print(
            "an error occured: devicesThatExceededAllowedUpdateTimeMapRef.set(jsonEncode({}));");
      }
    }

    // print("listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll data_provider: ${listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll}");
    print(
        "mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll data_provider: ${mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll}");
    print(
        "secondsSinceLastPricesDataUpdate data_provider: ${secondsSinceLastPricesDataUpdate}");
    // print("lastUpdateSessionMap data_provider: ${lastUpdateSessionMap}");

    /// DEFINING WHETHER THIS DEVICE SHOULD PROCEED TO GETREALTIMEPRICEALL
    /// WITH THE ABILITY TO FETCH PRICE DATA FROM THE RELEVANT FINANCIAL
    /// MARKETS DATA PROVIDER..
    /// determining whether the current device should proceed to calling
    /// updateRealtimePriceAll method within data.dart with the ability to
    /// update prices
    ///
    /// if no price data exists i.e if the app's running for the first time
    /// for all devices, allow this device to proceed to fully calling
    /// getRealtimePriceAll i.e with the ability to fetch new price data from
    /// the relevant financial markets data provider..
    ///
    /// Note: if lastUpdateSessionMap is empty, secondsSinceLastPricesDataUpdate
    /// will also be zero. Hence, it's unnecessary to include it in the condition
    /// below
    ///
    /// parent condition 1
    if (lastUpdateSessionMap.isEmpty) {
      mapIsCallUpdatePricesFully = {
        "parentConditionNumber": 1,

        /// remove later cos all devices will proceed to getRealtimePriceAll anyway
        "allowDeviceToProceedWithinUpdatePricesMethod": true,
        "allowDeviceToTryAndFetchDataFromFinancialMarketsDataProviderWithinGetRealTimePriceAll":
            true
      };
    }

    /// if a full minute has not been registered since the last price data update
    /// session, allow this device to proceed to calling getRealtimePriceAll, but
    /// do not allow it to fetch new price data from the relevant financial
    /// markets data provider..
    ///
    /// parent condition 2
    else if (secondsSinceLastPricesDataUpdate <= 60000 &&
        lastUpdateSessionMap.isNotEmpty) {
      mapIsCallUpdatePricesFully = {
        "parentConditionNumber": 2,

        /// remove later cos all devices will proceed to getRealtimePriceAll anyway
        "allowDeviceToProceedWithinUpdatePricesMethod": true,
        "allowDeviceToTryAndFetchDataFromFinancialMarketsDataProviderWithinGetRealTimePriceAll":
            false
      };
    }

    /// if it's been more than a minute since the last price data update and no
    /// device has retrieved the latest price data from the relevant financial
    /// market provider, allow this device to do just that..
    ///
    /// Note: The conditions below may be true for two or more devices. That
    /// issue will be handled within getRealtimePriceAll method in data.dart
    ///
    /// parent condition 3
    else if (secondsSinceLastPricesDataUpdate > 60000
        // &&listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.isEmpty
        &&
        mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.isEmpty) {
      mapIsCallUpdatePricesFully = {
        "parentConditionNumber": 3,

        /// remove later cos all devices will proceed to getRealtimePriceAll anyway
        "allowDeviceToProceedWithinUpdatePricesMethod": true,
        "allowDeviceToTryAndFetchDataFromFinancialMarketsDataProviderWithinGetRealTimePriceAll":
            true
      };
    }

    /// determining what should happen if active update devices already exist
    /// within the map of devices that are updating prices data within
    /// getRealTimePriceAll..
    else if (secondsSinceLastPricesDataUpdate > 60000
        // &&listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.isNotEmpty
        &&
        mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.isNotEmpty) {
      /// the number of devices that slipped into getRealtimePriceAll method
      /// in data.dart to retrieve the latest price data from the relevant
      /// financial market data provider
      // int numberOfDevicesThatSlippedToUpdatePricesDataWithinGetRealTimePriceAll=listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.length;
      int numberOfDevicesThatSlippedToUpdatePricesDataWithinGetRealTimePriceAll =
          mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.length;

      /// checking if any of the above described devices is still actively
      /// retrieving the latest price data from the relevant financial market
      /// data provider after calling updatePrices, and within an acceptable time
      int indexActiveUpdateDevice = 0;
      // for (var activeUpdateDevice in listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll){
      // }
      mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.forEach(
          (activeUpdateDeviceKeyOrNumber, activeUpdateDeviceJsonString) async {
        Map<dynamic, dynamic> activeUpdateDevice =
            jsonDecode(jsonDecode(jsonEncode(activeUpdateDeviceJsonString)));

        print("activeUpdateDevice decoded: ${activeUpdateDevice}");

        /// checking if the current active update device is leading i.e if it's
        /// the one currently fetching the latest price data from the relevant
        /// financial market data provider
        /// ---> set in getRealtimePriceAll
        bool isCurrentDeviceLeading = activeUpdateDevice['isLeading'];

        /// if the current active update device is leading, check whether it has
        /// exceeded the maximum time allowed for fetching the latest price data
        /// from the relevant financial market data provider - 10 seconds.
        ///
        /// if it has,
        /// 1. and if it's the only one in the map of devices updating prices
        /// data within getRealTimePriceAll, perform the relevant specified
        /// actions below for when there's only one active update device in the
        /// map of devices updating prices data within getRealTimePriceAll
        ///
        /// 2. delete all active devices from the map if it's the last device in
        /// the map of devices updating prices data within getRealTimePriceAll,
        /// and allow this device to call updatePrices fully (i.e with permission
        /// to fetch the latest price data from the relevant financial market
        /// data provider..
        /// Note:  1 and 2 above will leave a little room for other devices
        ///        running this method at the same time, and that find that no
        ///        active update device exists when its been more than a minute
        ///        since the last update to slip to getRealtimePriceAll
        ///        method with the ability to fetch the latest price data from
        ///        the relevant financial market data provider.. --->
        ///
        /// 3. only allow this device to call updatePrices partially (i.e
        /// without the permission to fetch the latest price data from the
        /// relevant financial market data provider, if the active device:
        ///   a. is leading
        ///   b. has exceeded the maximum allowed update time
        ///   c. it's not the last active device in the map of devices updating
        ///      prices data within getRealTimePriceAll.
        if (isCurrentDeviceLeading) {
          /// ---> active update device's id. set in getRealtimePriceAll
          String activeDeviceUniqueId = activeUpdateDevice['deviceUniqueId'];

          /// ---> check again if this device is the only one trying to update
          ///      prices within getRealtimePriceAll
          /// ---> Time device started updating prices within getRealtimePriceAll
          /// ---> update in getRealtimePriceAll to the time a new device starts
          ///      leading
          ///
          DateTime
              timeDeviceCalledUpdatePricesOrStartedLeadingInGetRealtimePriceAll =
              DateTime.parse(retrieveDatetimeStringFromCleanedDateTimeString(
                  cleanedDateTimeString: activeUpdateDevice[
                      "timeDeviceCalledUpdatePricesOrStartedLeadingInGetRealtimePriceAll"]));

          /// obtaining how long it's been since the active device called
          /// updatePrices method in this module and moved to retrieve the latest
          /// price data from the relevant financial market provider..
          ///
          /// this time difference should not exceed 10 seconds as most devices
          /// with fast internet connection will complete the task within 6 seconds
          DateTime now = DateTime.now();
          int diffNowAndTimeDeviceCalledUpdatingPricesOrStartedLeadingInGetRealtimePriceAll = now
              .difference(
                  timeDeviceCalledUpdatePricesOrStartedLeadingInGetRealtimePriceAll)
              .inSeconds;

          /// ---> set in getRealtimePriceAll
          bool isFinishedUpdatingPrices =
              activeUpdateDevice['isFinishedUpdatingPrices'];

          /// DETERMINING WHAT HAPPENS..
          /// 1a. if only one active update device exists and it's finished updating
          /// prices:
          ///   - reset the map of devices that are updating prices data within
          ///     GetRealTimePriceAll
          ///   - allow this device to call updatePrices fully (i.e with the
          ///     permission to try and fetch price data from the relevant
          ///     financial markets data provider in the event that it's been
          ///     more than another 60 seconds since the last price data update)
          ///
          ///     parent condition 4
          if (numberOfDevicesThatSlippedToUpdatePricesDataWithinGetRealTimePriceAll ==
                  1 &&
              isFinishedUpdatingPrices == true) {
            // /// resetting listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll
            // /// in firebase
            // listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef.set(jsonEncode([]));
            /// resetting mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll
            /// in firebase
            try {
              await mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef
                  .set({
                'dummyActiveUpdateDevice': jsonEncode({}),
                "leadingDeviceId": "none"
              });
            } catch (error) {
              print(
                  "an error occured: mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef.set({});}");
            }

            /// setting mapIsCallUpdatePricesFully
            mapIsCallUpdatePricesFully = {
              "parentConditionNumber": 4,

              /// remove later cos all devices will proceed to getRealtimePriceAll anyway
              "allowDeviceToProceedWithinUpdatePricesMethod": true,

              /// this will allow this device to check whether it's been more
              /// than one minute since the last price data update again..
              "allowDeviceToTryAndFetchDataFromFinancialMarketsDataProviderWithinGetRealTimePriceAll":
                  true
            };
          }

          /// 1.b if only one active update device exists, has not finished
          /// updating prices, and has exceeded the maximum allowed update time,
          /// delete it from the map of devices currently updating prices data
          /// within getRealTimePriceAll and allow this device to call
          /// updatePrices fully (i.e with the permission to fetch price
          /// data from the relevant financial markets data provider)
          ///
          /// parent condition 5
          else if (numberOfDevicesThatSlippedToUpdatePricesDataWithinGetRealTimePriceAll ==
                  1 &&
              isFinishedUpdatingPrices == false &&
              diffNowAndTimeDeviceCalledUpdatingPricesOrStartedLeadingInGetRealtimePriceAll >
                  10) {
            // /// emptying the list of devices currently updating prices data
            // /// within getRealTimePriceAll
            // /// ---> async check 'isAllowedTimeExpired' periodically, and stop the
            // ///      active update device from continuing running
            // ///      getRealtimeUpdatePrices if it comes back online
            // listOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef.set(jsonEncode([]));
            /// emptying the map of devices currently updating prices data
            /// within getRealTimePriceAll
            /// ---> async check 'isAllowedTimeExpired' periodically, and stop the
            ///      active update device from continuing running
            ///      getRealtimeUpdatePrices if it comes back online
            try {
              await mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef
                  .set({
                'dummyActiveUpdateDevice': jsonEncode({}),
                "leadingDeviceId": "none"
              });
            } catch (error) {
              print(
                  "an error occured: mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef.set({})");
            }

            /// signalling to the active update device through firebase that
            /// it's exceeded the max allowed update time so that it can self-stop it's
            /// price update operation
            updateIsAllowedTimeExpiredMapInFirebase(
              devicesThatExceededAllowedUpdateTimeMapRef:
                  devicesThatExceededAllowedUpdateTimeMapRef,
              deviceUniqueId: activeDeviceUniqueId,
            );

            /// ---> an extra cost center, since the last device failed to update
            ///      prices data fully but has used some or most of the minutely
            ///      API credit. Howbeit, better than having multiple devices
            ///      trying to fetch prices data directly from the relevant
            ///      financial markets data provider
            mapIsCallUpdatePricesFully = {
              "parentConditionNumber": 5,

              /// remove later cos all devices will proceed to getRealtimePriceAll anyway
              "allowDeviceToProceedWithinUpdatePricesMethod": true,

              /// this will allow this device to check whether it's been more
              /// than one minute since the last price data update..
              "allowDeviceToTryAndFetchDataFromFinancialMarketsDataProviderWithinGetRealTimePriceAll":
                  true
            };
          }

          /// if only one active update device exists but it's not finished
          /// updating prices and has not exceeded the maximum allowed update
          /// time, all the current device to call updatePrices partially
          /// (i.e without the permission to fetch price data from the relevant
          /// financial markets data provider)
          ///
          /// parent condition 6
          else if (numberOfDevicesThatSlippedToUpdatePricesDataWithinGetRealTimePriceAll ==
                  1 &&
              isFinishedUpdatingPrices == false &&
              diffNowAndTimeDeviceCalledUpdatingPricesOrStartedLeadingInGetRealtimePriceAll <=
                  10) {
            mapIsCallUpdatePricesFully = {
              "parentConditionNumber": 6,

              /// remove later cos all devices will proceed to getRealtimePriceAll anyway
              "allowDeviceToProceedWithinUpdatePricesMethod": true,

              /// this will allow this device to check whether it's been more
              /// than one minute since the last price data update again..
              /// ---> those without the ability to fetch prices data from the
              ///      relevant financial markets data provider should be served
              ///      the previously saved prices data
              "allowDeviceToTryAndFetchDataFromFinancialMarketsDataProviderWithinGetRealTimePriceAll":
                  false
            };
          }

          /// if more than one active update device exists and the current active
          /// device, and prices prices data have finished updating,
          ///
          /// clear the map of active
          /// update devices in firebase, and allow this device to call
          /// updatePrices fully
          ///
          /// parent condition 7
          else if (numberOfDevicesThatSlippedToUpdatePricesDataWithinGetRealTimePriceAll >
                  1 &&
              isFinishedUpdatingPrices == true) {
            /// if the active update device is the last in the map of active
            /// update devices, clear the map of active update devices in
            /// firebase
            if (indexActiveUpdateDevice ==
                mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.length -
                    1) {
              /// clearing the map of active update devices in firebase..
              try {
                await mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef
                    .set({
                  'dummyActiveUpdateDevice': jsonEncode({}),
                  "leadingDeviceId": "none"
                });
              } catch (error) {
                print(
                    "an error occured: mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef.set({})");
              }
            } else if (indexActiveUpdateDevice !=
                mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.length -
                    1) {
              /// clearing the map of active update devices in firebase..
              try {
                await mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef
                    .set({
                  'dummyActiveUpdateDevice': jsonEncode({}),
                  "leadingDeviceId": "none"
                });
              } catch (error) {
                print(
                    "an error occured: mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef.set({});");
              }

              /// ---> Unserviced devices (devices that were behind the leading
              ///      device that finished updating prices will stop and skip
              ///      their current getRealtimePriceAll process and re-run
              ///      getRealtimePriceAll with the ability to fetch the latest
              ///      price data either from firebase or the relevant financial
              ///      market data provider..
            }

            mapIsCallUpdatePricesFully = {
              "parentConditionNumber": 7,

              /// remove later cos all devices will proceed to getRealtimePriceAll anyway
              "allowDeviceToProceedWithinUpdatePricesMethod": true,

              /// this will allow this device to check whether it's been more
              /// than one minute since the last price data update..
              ///
              /// 'true" here might not really be necessary though
              "allowDeviceToTryAndFetchDataFromFinancialMarketsDataProviderWithinGetRealTimePriceAll":
                  true
            };
          }

          /// if more than one active update device exists and the current active
          /// device, is the last in the map of active update devices,
          /// and has not finished fetching prices data after the maximum allowed
          /// update time, clear the map of active update devices in firebase,
          /// signal to th active update device that it has exceeded the max
          /// allowed update time, and allow this device to call updatePrices
          /// fully
          ///
          /// parent condition 8
          else if (numberOfDevicesThatSlippedToUpdatePricesDataWithinGetRealTimePriceAll >
                  1 &&
              indexActiveUpdateDevice ==
                  mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll
                          .length -
                      1 &&
              isFinishedUpdatingPrices == false &&
              diffNowAndTimeDeviceCalledUpdatingPricesOrStartedLeadingInGetRealtimePriceAll >
                  10) {
            /// clearing the map of active update devices in firebase..
            try {
              await mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef
                  .set({
                'dummyActiveUpdateDevice': jsonEncode({}),
                "leadingDeviceId": "none"
              });
            } catch (error) {
              print(
                  "an error occured: mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAllRef.set({});");
            }

            /// signalling to the active update device through firebase that
            /// it's exceeded the max allowed update time so that it can
            /// self-stop it's price update operation
            updateIsAllowedTimeExpiredMapInFirebase(
              devicesThatExceededAllowedUpdateTimeMapRef:
                  devicesThatExceededAllowedUpdateTimeMapRef,
              deviceUniqueId: activeDeviceUniqueId,
            );

            /// setting mapIsCallUpdatePricesFully
            mapIsCallUpdatePricesFully = {
              "parentConditionNumber": 8,

              /// remove later cos all devices will proceed to getRealtimePriceAll anyway
              "allowDeviceToProceedWithinUpdatePricesMethod": true,

              /// this will allow this device to check it's been more
              /// than one minute since the last price data update..
              "allowDeviceToTryAndFetchDataFromFinancialMarketsDataProviderWithinGetRealTimePriceAll":
                  true
            };
          }

          /// if:
          /// 1. the map of active update devices has up to 2 active update
          /// devices
          /// 2. the current leading active update device is not positioned last
          /// and didn't fetch new price data within the max allowed update time
          /// - 10 seconds,
          /// ...allow this device to call getRealtimePriceAll, but without the
          /// ability to fetch new price data from the relevant financial market
          /// data provider, since at least one extra active update device exists
          ///
          /// parent condition 9
          ///
          /// ????????????↓↓↓ --->  implement in getRealtimePriceAll with -
          /// &&indexActiveUpdateDevice!=mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.length-1
          else if (numberOfDevicesThatSlippedToUpdatePricesDataWithinGetRealTimePriceAll >
                  1 &&
              indexActiveUpdateDevice !=
                  mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll
                          .length -
                      1 &&
              isFinishedUpdatingPrices == false &&
              diffNowAndTimeDeviceCalledUpdatingPricesOrStartedLeadingInGetRealtimePriceAll >
                  10) {
            /// setting mapIsCallUpdatePricesFully
            mapIsCallUpdatePricesFully = {
              "parentConditionNumber": 9,

              /// remove later cos all devices will proceed to getRealtimePriceAll anyway
              "allowDeviceToProceedWithinUpdatePricesMethod": true,
              "allowDeviceToTryAndFetchDataFromFinancialMarketsDataProviderWithinGetRealTimePriceAll":
                  false
            };
          }

          /// if more than one active update device exists and the current active
          /// device is or is not the last active update device in the map of
          /// active update devices, and has not finished fetching prices data
          /// but is still running within the maximum allowed update time,
          /// allow this device to call updatePrices partially
          ///
          /// &&indexActiveUpdateDevice==mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.length-1
          /// || indexActiveUpdateDevice!=mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll.length-1
          /// not necessary to include in the conditions below.
          ///
          /// parent condition 10
          else if (numberOfDevicesThatSlippedToUpdatePricesDataWithinGetRealTimePriceAll >
                  1 &&
              isFinishedUpdatingPrices == false &&
              diffNowAndTimeDeviceCalledUpdatingPricesOrStartedLeadingInGetRealtimePriceAll <=
                  10) {
            /// setting mapIsCallUpdatePricesFully
            mapIsCallUpdatePricesFully = {
              "parentConditionNumber": 10,

              /// remove later cos all devices will proceed to getRealtimePriceAll anyway
              "allowDeviceToProceedWithinUpdatePricesMethod": true,
              "allowDeviceToTryAndFetchDataFromFinancialMarketsDataProviderWithinGetRealTimePriceAll":
                  false
            };
          }

          /// if the active device has taken too much time to update price data,
          /// signal to it to stop even if it had a connectivity issue and got
          /// connected again to ensure that other devices won't have to wait too
          /// long to start getting the latest prices
          /// ---> async check 'isAllowedTimeExpired' periodically, and stop the
          ///      active update device from continuing running
          ///      getRealtimeUpdatePrices if it comes back online
          // if (diffNowAndTimeDeviceCalledUpdatingPricesOrStartedLeadingInGetRealtimePriceAll>10 && isFinishedUpdatingPrices==false){
          //   mapOfDevicesUpdatingPricesDataWithinGetRealTimePriceAll[indexActiveUpdateDevice]['isAllowedTimeExpired']=true;
          // }

          indexActiveUpdateDevice += 1;
        }
      });
    }

    return mapIsCallUpdatePricesFully;
  }

  /// This method retrieves the prices of forex and crypto pairs periodically
  Future updatePrices() async {
    print('called update prices');

    /// start time - this method
    DateTime startTimeUpdatePrices = DateTime.now();

    /// creating device's unique id if it does not already exist
    if (deviceUniqueId == "") {
      Random rand = Random();
      String aRandomNumberString = rand.nextInt(1000000000).toString();
      String nowToString =
          cleanDateTimeAndReturnString(dateTime: DateTime.now());
      deviceUniqueId = "$nowToString,$aRandomNumberString";
    }

    // DateTime startTimeUpdatePrices = DateTime.now();

    // // /// if any device that's currently running this app is executing this
    // // /// method fully, keep other devices from executing it until that
    // // /// device is done..
    // // /// IS ANY DEVICE FULLY RUNNING THE UPDATE PRICES METHOD  'DatabaseReference'
    // // ///
    // // /// kind of like a global "_isUpdatingPrices" variable for all devices
    // // DatabaseReference isAnyDeviceFullyRunningUpdatePricesMethodRef =
    // // FirebaseDatabase.instance.ref("isAnyDeviceFullyRunningUpdatePricesMethod");
    // //
    // // /// IS ANY DEVICE FULLY RUNNING THE UPDATE PRICES METHOD  'DataSnapshot'
    // // DataSnapshot lastUpdatePricesFunctionCallTimeSnap = await isAnyDeviceFullyRunningUpdatePricesMethodRef.get();
    // //
    // // /// if the ref that signals whether a user's device is currently running
    // // /// this method has not been created, create it.
    // // if (lastUpdatePricesFunctionCallTimeSnap.exists == false) {
    // //   print('setting isAnyDeviceFullyRunningUpdatePricesMethod');
    // //
    // //   /// creating isAnyDeviceFullyRunningUpdatePricesMethodRef to relect that
    // //   /// a user is currently running updatePrices method
    // //   await isAnyDeviceFullyRunningUpdatePricesMethodRef.set({
    // //     "isUpdatePricesMethodRunning": jsonEncode(true),
    // //     "lastAccessTime": cleanDateTimeAndReturnString(dateTime: DateTime.now())
    // //   });
    // // } else if (lastUpdatePricesFunctionCallTimeSnap.exists == true) {
    // //   /// obtaining bool that signals whether this method has been called by
    // //   /// a user's device
    // //   Map isAnyDeviceFullyRunningUpdatePricesMethodMap=jsonDecode(jsonEncode((lastUpdatePricesFunctionCallTimeSnap.value!)));
    // //   bool isAnyDeviceFullyRunningUpdatePricesMethod=jsonDecode(isAnyDeviceFullyRunningUpdatePricesMethodMap["isUpdatePricesMethodRunning"]);
    // //
    // //   /// last time updatePrices method was called globally
    // //   String lastGlobalAccessTimeUpdatePriceString=jsonDecode(isAnyDeviceFullyRunningUpdatePricesMethodMap["lastAccessTime"]);
    // //   DateTime lastGlobalAccessTimeUpdatePricesMethod=DateTime.parse(
    // //       retrieveDatetimeStringFromCleanedDateTimeString(cleanedDateTimeString: lastGlobalAccessTimeUpdatePriceString)
    // //   );
    // //   /// difference between now and the last time updatePrices was called
    // //   /// globally
    // //   int diffNowAndLastGlobalAccessTimeUpdatePricesMethod=DateTime.now().difference(lastGlobalAccessTimeUpdatePricesMethod).inSeconds;
    // //   /// if a user's device is currently running this method, create a timer
    // //   /// that tracks whether that user's device is done. When the user's device
    // //   /// is done, run this method again.
    // //   ///
    // //   /// helps prevent multiple devices from calling the financial markets API
    // //   /// all at once. Hence conserving API credits
    //
    //
    //   if (isAnyDeviceFullyRunningUpdatePricesMethod==true || diffNowAndLastGlobalAccessTimeUpdatePricesMethod<=2){
    //     _isGlobalUserRunningUpdatePricesDoneTimer.cancel();
    //     _isGlobalUserRunningUpdatePricesDoneTimer=Timer.periodic(const Duration(seconds: 5), (timer){
    //       updatePrices();
    //     });
    //     return;
    //   } else{
    //     _isGlobalUserRunningUpdatePricesDoneTimer.cancel();
    //   }
    // }
    //
    // /// if no user is currently executing this method globally, set that this
    // /// device's user is currently executing it..
    // isAnyDeviceFullyRunningUpdatePricesMethodRef.set(jsonEncode(true));

    /// obtaining whether this device should proceed to getRealtimePriceAll
    Map<dynamic, dynamic> isCallUpdatePricesFullyMap =
        await _getIsCallUpdatePricesFully();
    bool isAllowDeviceFetchDataDataProvider = isCallUpdatePricesFullyMap[
        "allowDeviceToTryAndFetchDataFromFinancialMarketsDataProviderWithinGetRealTimePriceAll"];

    /// adding this device to the map of active update device so that the number
    ///

    print("IsCallUpdatePricesFullyMap: ${isCallUpdatePricesFullyMap}");
    print("deviceUniqueId: ${deviceUniqueId}");

    /// if...:
    /// 1. the updatePrices timer (relevantTimer) has finished counting down the
    ///    time and this method is not already running OR
    /// 2. this app is running for the first time,
    /// ... update prices' data..
    ///
    /// Also, the conditions below prevent this method from being called each
    /// time the user selects a new device..
    print(
        "(!_relevantTimer.isActive && _isUpdatingPrices == false) || _countUpdatePricesCall == 0: ${(!_relevantTimer.isActive && _isUpdatingPrices == false) || _countUpdatePricesCall == 0}");
    print("!_relevantTimer.isActive: ${!_relevantTimer.isActive}");
    print("_isUpdatingPrices == false: ${_isUpdatingPrices == false}");
    print("_countUpdatePricesCall == 0: ${_countUpdatePricesCall == 0}");
    if ((!_relevantTimer.isActive && _isUpdatingPrices == false) ||
        _countUpdatePricesCall == 0) {
      print("called updatePrices");

      /// signalling that updatePrices method in data provider
      /// is currently running
      _isUpdatingPrices = true;
      // _isUpdatingPrices = UpdatePricesState.isUpdating;

      if (_isFirstValueInMapOfAllInstrumentsContainsFetching == true) {
        /// setting a dummy alert price for the initially selected currency pair
        /// (4th pair) in the map of all prices when prices are being fetched for
        /// the first time..
        setAlertPriceCurrencyPriceTextField();

        /// retrieve locally saved price alerts data if any
        _mapOfAllAlerts = await retrievePriceAlertsFromUserDeviceStorage();

        /// calculate whether all price alerts (in _mapOfAllAlerts) are currently
        /// muted
        ///
        /// updates _isAllPriceAlertsMuted when the app gets started or updated
        muteUnMuteAllOrCalcIsAllMutedOrIsPriceAlertFulfilled(
            alertOperationType: AlertOperationType.calcIsAllAlertsMuted);
      }

      print(
          "--------------------------------------------------------------------------------");
      print("");
      print("UPDATEPRICES METHOD - START");

      /// initializing dotenv, creating necessary files and folders, and
      /// updating instruments / symbols..
      await _initialDataAndDotEnv(isUseLocalStorage: false);

      print("");
      print("Fetching all instruments' prices every 1 minute (approx)...");

      _countUpdatePricesCall += 1;
      print(
          "Called UpdatePrices Method (Provider) $_countUpdatePricesCall times");

      /// retrieving all prices..
      /// if successful, a map of all prices will be returned. Otherwise, an empty
      /// map will be returned..
      DateTime startTime = DateTime.now();
      Map<dynamic, dynamic> mapOfAllPrices = await _data!.getRealTimePriceAll(
          timeDeviceCalledUpdatePricesOrStartedLeadingInGetRealtimePriceAll:
              startTimeUpdatePrices,
          deviceUniqueId: deviceUniqueId,
          isAllowDeviceFetchDataDataProvider:
              isAllowDeviceFetchDataDataProvider);
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

      /// ... otherwise,
      /// 1. wait for 1 minute (approx) future timers and notify
      ///    listeners
      /// 2. determine the number of fulfilled alerts that have not been muted.
      ///    if any, play an alert sound..
      else {
        /// setting the alert price for the currently selected currency pair
        /// after prices have been fetched at least once
        setAlertPriceCurrencyPriceTextField();

        /// updating timers
        updateTimers(isOneMin: true);

        /// reset the number of fulfilled alerts that have not been muted
        /// to avoid repetitive addition when
        /// muteUnMuteAllOrCalcIsAllMutedOrIsPriceAlertFulfilled gets called
        _countFulfilledUnMutedAlerts = 0;

        /// determine the number of fulfilled alerts that have not been muted
        await muteUnMuteAllOrCalcIsAllMutedOrIsPriceAlertFulfilled(
            alertOperationType: AlertOperationType.setIsAlertFulfilled);

        notifyListeners();
      }
    }

    // DateTime finishTimeUpdatePrices = DateTime.now();

    // Duration durationUpdatePrice =
    //     finishTimeUpdatePrices.difference(startTimeUpdatePrices);
    // print("durationUpdatePrice: $durationUpdatePrice");
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
  Map<dynamic, dynamic> getInstruments(
      {
      /// allows for retrieving all instrument's prices' data
      ///
      /// especially useful when listing existing price alerts
      bool isRetrieveAll = false}) {
    // print(_allForexAndCryptoPrices);

    Map<dynamic, dynamic> mapToReturn = {};
    // print(
    // "_allForexAndCryptoPrices.values.toList()[0]: ${_allForexAndCryptoPrices.values.toList()[0]}");

    /// if no prices have not been fetched, return the default map which has the
    /// "fetching" notification set for all instruments. However, if prices have
    /// been fetched but "all" filter is active, show all instruments...
    if (_allForexAndCryptoPrices.values.toList()[0].runtimeType == String ||
        _instrumentFilter == Filter.all ||
        isRetrieveAll == true) {
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
  bool getHasFocusCurrencyPairOrAlertPriceTextField() {
    if (_hasFocusCurrencyPairTextField == true ||
        _hasFocusAlertPriceTextField == true) {
      _hasFocusCurrencyPairAndAlertPriceTextFields = true;
    } else if (_hasFocusCurrencyPairTextField == false &&
        _hasFocusAlertPriceTextField == false) {
      _hasFocusCurrencyPairAndAlertPriceTextFields = false;
      // notifyListeners();
    }

    return _hasFocusCurrencyPairAndAlertPriceTextFields;
  }

  /// retrieves the currently selected pair's price if any (i.e if prices have
  /// been fetched..
  ///
  /// a helper function for setAlertPriceCurrencyPriceTextField
  String getCurrentlySelectedInstrumentPrice() {
    bool isFirstTimeFetchingPrices =
        getIsFirstValueInMapOfAllInstrumentsContainsFetching();

    /// ensuring that the list of all instruments fits the current filter
    getInstruments();

    String currentlySelectCurrencyPair =
        _listOfAllInstruments[_indexSelectedGridTile];

    String currentlySelectedCurrencyPairPrice = "";

    if (isFirstTimeFetchingPrices) {
      currentlySelectedCurrencyPairPrice = "0.00000";
    } else {
      currentlySelectedCurrencyPairPrice =
          _allForexAndCryptoPrices[currentlySelectCurrencyPair]
              ['current_price'];

      /// if price equals "demo" after prices have been fetched at least once,
      /// set currentlySelectedCurrencyPairPrice to "0.00000"
      if (currentlySelectedCurrencyPairPrice == "demo") {
        currentlySelectedCurrencyPairPrice = "0.00000";
      }
    }

    return currentlySelectedCurrencyPairPrice;
  }

  /// sets the alert price of the currently selected currency pair
  void setAlertPriceCurrencyPriceTextField() {
    // /// bool to signal that prices are being fetched for the first time..
    // bool isFetchingPrices =
    //     getIsFirstValueInMapOfAllInstrumentsContainsFetching();
    //
    // if (isFetchingPrices) {
    //   _alertPriceCurrencyPriceTextField = "0.00000";
    // } else {
    //   _alertPriceCurrencyPriceTextField = getCurrentlySelectedInstrumentPrice();
    //
    // }

    _alertPriceCurrencyPriceTextField = getCurrentlySelectedInstrumentPrice();
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

  /// sets the currently selected currency pair's alert price, original or
  /// user edited version..
  void setOriginalOrEditedAlertPriceCurrencyPriceTextField(
      {required String originalOrUserEditedAlertPrice}) {
    _originalOrEditedAlertPriceCurrencyPriceTextField =
        originalOrUserEditedAlertPrice;
  }

  /// gets the currently selected currency pair's alert price, original or
  /// user edited version..
  String getOriginalOrEditedAlertPriceCurrencyPriceTextField() {
    return _originalOrEditedAlertPriceCurrencyPriceTextField;
  }

  /// update entered currency pair text ->
  /// CurrencyPairTextFieldOrCreateAlertButton
  ///
  /// When the entered text is a valid currency pair, this method will help to
  /// update the grid view widget with the currently selected (entered) pair
  void updateEnteredTextCurrencyPair(
      {required String? enteredText,
      bool? isErrorEnteredText,
      FocusNode? focusNode,

      /// used with FocusScope to determine whether the keyboard is still visible
      BuildContext? context}) {
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

          /// setting the alert price for the entered currency pair
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

      /// are prices being fetched for the first time?
      bool isFirstTimeFetchingPrices =
          _isFirstValueInMapOfAllInstrumentsContainsFetching;

      /// map of all instruments according to the currently selected filter
      _mapOfAllInstrumentCurrentFilter = getInstruments();
      List<dynamic> _listOfAllInstrumentCurrentFilter =
          _mapOfAllInstrumentCurrentFilter.keys.toList();

      /// currently selected instrument per the selected filter option
      String selectedInstrumentPerSelectedFilter =
          _listOfAllInstrumentCurrentFilter[_indexSelectedGridTile];

      /// is the price of the selected instrument per the selected filter option
      /// equal to "demo"
      ///
      /// note: prices will not contain "fetching" here because filter options
      /// won't be selectable when prices get fetched for the first time..
      bool isSelectedInstrumentPriceEqualToDemo =
          _mapOfAllInstrumentCurrentFilter[selectedInstrumentPerSelectedFilter]
                  ["current_price"] ==
              "demo";

      /// determining the last selectable grid tile for "forex" &
      /// "crypto" filter options' instruments' data
      int indexLastSelectableGridTileForexOrCryptoFilter = 0;
      for (var instrument in _listOfAllInstrumentCurrentFilter) {
        String price =
            _mapOfAllInstrumentCurrentFilter[instrument]["current_price"];

        if (price == "demo") {
          break;
        }

        indexLastSelectableGridTileForexOrCryptoFilter += 1;
      }

      /// if forex or crypto filter option gets clicked after prices have been
      /// fetched at least once and the translated selected instrument's doesn't
      /// have a price that can be displayed, update the index selected grid
      /// tile's index to the index of the last selectable instrument of the
      /// selected filter (i.e the last instrument a user can select)
      if ((filter == Filter.forex || filter == Filter.crypto) &&
          isFirstTimeFetchingPrices == false &&
          isSelectedInstrumentPriceEqualToDemo &&
          indexLastSelectableGridTileForexOrCryptoFilter != 0) {
        indexLastSelectableGridTileForexOrCryptoFilter -= 1;
        _indexSelectedGridTile = indexLastSelectableGridTileForexOrCryptoFilter;
      }

      /// update the alert price to reflect the currently select pair per
      /// the current filter (_instrumentFilter)
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
  /// alert price, or simply calculate and set the unit value of the currently
  /// selected currency pair...
  dynamic subtractOrAddOneOrFiveUnitsFromAlertPrice(
      {
      /// to determine the actual unit price of the entered alert price
      required String currentPairPriceStructure,

      /// the entered alert price, regardless of whether the price structure
      /// of the user has changed the currently selected pair's price by editing
      /// it..
      String alertPrice = "",

      /// should the method be used to subtract or add a unit price of the
      /// current currency's alert price
      isSubtract = false,

      /// useful when only using this method to determine a unit of the alert
      /// price..
      ///
      /// the above arguments are not necessary when this method will only be
      /// used to determine a unit of the alert price..
      AlertOperationType alertOperationType = AlertOperationType.none}) {
    /// obtaining the original count of numbers that exist after the "." symbol
    /// - currentPairPriceStructure
    List<String> alertPriceOriginalStructureSplit =
        currentPairPriceStructure.split("");
    int lengthOfCurrentPairPriceStructure = currentPairPriceStructure.length;
    int countOfNumAfterDot = 0;

    if (alertPriceOriginalStructureSplit.contains(".")) {
      int indexOfDot = alertPriceOriginalStructureSplit.indexOf(".");
      int positionOfDot = indexOfDot + 1;
      countOfNumAfterDot = lengthOfCurrentPairPriceStructure - (positionOfDot);
    }

    /// determining a unit of the current alert price
    String aUnitOfTheAlertPrice = "1";

    if (countOfNumAfterDot != 0) {
      aUnitOfTheAlertPrice = "0.${"0" * countOfNumAfterDot}";
      List<String> incrementValueOneUnitSplit = aUnitOfTheAlertPrice.split('');
      int indexOfLastItemInIncrementValueOneUnitSplit =
          aUnitOfTheAlertPrice.length - 1;
      incrementValueOneUnitSplit[indexOfLastItemInIncrementValueOneUnitSplit] =
          "1";
      aUnitOfTheAlertPrice = incrementValueOneUnitSplit.join("");

      /// if this method has been called only to retrieve a unit of the
      /// currently selected pair's price, return:
      /// 1. aUnitOfTheAlertPrice
      /// 2. countOfNumAfterDot...
      /// and exit this method
      if (alertOperationType == AlertOperationType.calcUnitPrice) {
        // _selectedCurrencyPairOneUnitOfPrice = aUnitOfTheAlertPrice;
        return {
          "aUnitOfTheAlertPrice": aUnitOfTheAlertPrice,
          "countOfNumAfterDot": countOfNumAfterDot
        };
      }
    }

    print("aUnitOfTheAlertPrice: ${aUnitOfTheAlertPrice}");

    /// subtracting or adding a unit to the alert price depending on the
    /// specified operation type..
    String finalValue = "0";

    if (isSubtract) {
      /// subtracting a unit of the selected currency pair's original price
      /// (structure) from the visible alert price ..
      finalValue =
          (double.parse(alertPrice) - double.parse(aUnitOfTheAlertPrice))
              .toStringAsFixed(countOfNumAfterDot);
    } else {
      /// adding a unit of the selected currency pair's original price
      /// (structure) from the visible alert price..
      finalValue =
          (double.parse(alertPrice) + double.parse(aUnitOfTheAlertPrice))
              .toStringAsFixed(countOfNumAfterDot);
    }

    return finalValue;
  }

  /// this helps save all existing price alerts locally
  Future savePriceAlertsToLocalStorage() async {
    /// saving map of all alerts to the user's local storage
    SharedPreferences sharedPref = await SharedPreferences.getInstance();

    /// if a map of all alerts has already be saved locally, delete it. Then
    /// save a new copy..
    await sharedPref.remove("mapOfAllAlerts");

    /// save a latest copy of the map of all alerts.
    await sharedPref.setString('mapOfAllAlerts', jsonEncode(_mapOfAllAlerts));

    print("_mapOfAllAlerts to be saved locally: $_mapOfAllAlerts");
  }

  /// this helps retrieve all locally saved price alerts
  Future<Map<dynamic, dynamic>>
      retrievePriceAlertsFromUserDeviceStorage() async {
    // <Map<String, List<dynamic>>>

    /// retrieving the map of all alerts from the user's local storage
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? mapOfAllAlertsString = sharedPref.getString('mapOfAllAlerts');
    Map mapOfAllAlerts = {}; // List<Map<String, dynamic>>

    if (mapOfAllAlertsString != null) {
      mapOfAllAlerts = jsonDecode(mapOfAllAlertsString);
    }

    /// return the obtained map of all strings whether empty map or not
    print("mapOfAllAlerts savePriceAlertsToLocalStorage: ${mapOfAllAlerts}");
    return mapOfAllAlerts;
  }

  /// helps present notification to the user visually
  ScaffoldFeatureController showNotification({
    required BuildContext context,
    required String message,
  }) {
    /// media query data
    MediaQueryData mediaQuery = MediaQuery.of(context);

    /// device's height
    double deviceHeight = mediaQuery.size.height;

    /// SafeArea's height
    double paddingTop = mediaQuery.padding.top;
    double paddingBottom = mediaQuery.padding.bottom;
    double safeAreaHeight = deviceHeight - paddingTop - paddingBottom;

    /// device's width
    double deviceWidth = mediaQuery.size.width;

    /// snackbar's height
    ///
    /// same as the height of the CreateNewAlert widget
    double heightSnackBar = 0.05833333333 * safeAreaHeight;

    /// snack bar's margin left and right
    double snackBarPaddingLeftAndRight = 0.02325581395 * deviceWidth;

    /// snack bar's font size
    double fontSizeMessage = 0.01716738197 * deviceHeight;

    /// snack bar's padding bottom
    double paddingBottomSnackBar = 0.847639485 * deviceHeight;

    /// hiding all visible snack bars
    ScaffoldMessenger.of(context).clearSnackBars();

    /// snackbar
    SnackBar snackBar = SnackBar(
        // backgroundColor: Colors.black,
        margin: EdgeInsets.only(
          left: snackBarPaddingLeftAndRight,
          right: snackBarPaddingLeftAndRight,
          bottom: safeAreaHeight - heightSnackBar,
          // top: 0
        ),
        padding: EdgeInsets.zero,
        dismissDirection: DismissDirection.none,
        duration: const Duration(milliseconds: 3000),
        behavior: SnackBarBehavior.floating,
        content: Container(
          alignment: Alignment.center,
          // color: Colors.yellow,
          /// height of the createNewAlert widget
          height: heightSnackBar,
          // width: double.infinity,
          child: Text(
            message,
            style: TextStyle(
                fontFamily: "PT-Mono",
                fontSize: fontSizeMessage,
                color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ));

    /// displaying a snack bar with a custom message
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// adds the currently displayed alert price to the map of all alerts, if
  /// it has not already been added..
  void addAlertToMapOfAllAlerts(
      {
      /// used with scaffold messenger to notify the user whenever an alert
      /// cannot be added to the list / map of all alerts..
      required BuildContext context}) {
    /// currently selected currency pair
    String currentlySelectedCurrencyPair = getCurrentlySelectedInstrument();
    String currentlyDisplayedAlertPrice =
        _originalOrEditedAlertPriceCurrencyPriceTextField;
    String currentlySelectedCurrencyPairPrice =
        getCurrentlySelectedInstrumentPrice();

    print("currentlySelectedCurrencyPair:${currentlySelectedCurrencyPair}");
    print("currentlyDisplayedAlertPrice: ${currentlyDisplayedAlertPrice}");

    List<dynamic> alreadyAddedAlertCurrencyPair = _mapOfAllAlerts.keys.toList();
    bool isCurrencyInMapOfAlerts =
        alreadyAddedAlertCurrencyPair.contains(currentlySelectedCurrencyPair);
    int keyCurrentAlert = 0;

    bool isAlertAlreadyExist = false;

    /// if no alerts have previously been created for the currently selected
    /// currency pair, create a list of alerts for it within _mapOfAllAlerts
    if (isCurrencyInMapOfAlerts == false) {
      // int numberOfExistingAlertsForTheSpecifiedPair = mapOfAllAlerts[currencyPair].keys.toList();
      _mapOfAllAlerts[currentlySelectedCurrencyPair] = [];
    }

    /// Map<String, List<Map<String, dynamic>>

    /// obtaining the list of already created alerts (prices and isMuted data)
    /// for the specified currency pair
    List<dynamic>? listOfAlertsDataCurrentCurrencyPair = _mapOfAllAlerts[
        currentlySelectedCurrencyPair]; // Map<String, Map<String, dynamic>>

    /// creating the map key for the alert that should be created
    ///
    /// only used if the alert does not already exist
    keyCurrentAlert = listOfAlertsDataCurrentCurrencyPair!.length;

    // /// checking whether the alert already exists
    // if (isCurrencyInMapOfAlerts == true) {
    // }

    /// iterating through the specified currency pair's existing alerts
    /// (if any) to determine whether the price alert that should be added
    /// already exists
    for (var alertData in listOfAlertsDataCurrentCurrencyPair) {
      String price = alertData['price'];

      if (price == currentlyDisplayedAlertPrice) {
        isAlertAlreadyExist = true;
        break;
      }
    }

    /// including the new alert into the map of all alerts if:
    /// 1. the current price of the alert instrument is not the same as the alert
    /// price to be saved..
    /// 2. it does not already exist
    if (currentlySelectedCurrencyPairPrice != currentlyDisplayedAlertPrice &&
        isAlertAlreadyExist == false) {
      /// determining the alert price position..
      String initialAlertPricePosition = "none";

      /// currentlySelectedCurrencyPairPrice as double
      double doubleCurrentlySelectedCurrencyPairPrice =
          double.parse(currentlySelectedCurrencyPairPrice);
      double doubleCurrentlyDisplayedAlertPrice =
          double.parse(currentlyDisplayedAlertPrice);

      /// if the alert instrument's (currently selected currency pair) price
      /// is greater than the alert price and vice versa, register it
      if (doubleCurrentlySelectedCurrencyPairPrice >
          doubleCurrentlyDisplayedAlertPrice) {
        initialAlertPricePosition = "down";
      } else if (doubleCurrentlySelectedCurrencyPairPrice <
          doubleCurrentlyDisplayedAlertPrice) {
        initialAlertPricePosition = "up";
      }

      _mapOfAllAlerts[currentlySelectedCurrencyPair]!.insert(keyCurrentAlert, {
        "price": currentlyDisplayedAlertPrice,
        "isMuted": false,

        /// signals whether the current price of the instrument is equal to
        /// its alert price
        "isFulfilledAlertPrice": false,
        "hasFulfilledAlertPriceOnce": false,
        "initialAlertPricePosition": initialAlertPricePosition
      });
    }

    /// ... else if:
    /// 1. the current price of the alert instrument is the same as the alert
    /// price &&
    /// 2. no previous price alert exists for the currently selected
    /// currency pair,
    /// ... remove the currency pair from the map of all alerts and notify the
    /// user that the current price of the alert instrument cannot be added to
    /// the list
    else if (currentlySelectedCurrencyPairPrice ==
            currentlyDisplayedAlertPrice &&
        listOfAlertsDataCurrentCurrencyPair.isEmpty) {
      /// removing the currency pair from the map of all alerts
      _mapOfAllAlerts.remove(currentlySelectedCurrencyPair);

      /// notifying user visually that the current price of the alert instrument
      /// cannot be added to the list (or map) of all alerts, which helps avoid
      /// alert sound chaos
      showNotification(
          context: context, message: "Can't add pair's current price!");
    }

    /// ... if:
    /// 1. the current price of the alert instrument is the same as the alert
    ///    price &&
    /// 2. at least one price alert exists for the currently selected pair
    /// ... only notify the user that the
    else if (currentlySelectedCurrencyPairPrice ==
        currentlyDisplayedAlertPrice) {
      /// notifying user visually that the current price of the alert instrument
      /// cannot be added to the list (or map) of all alerts, which helps avoid
      /// alert sound chaos
      showNotification(
          context: context, message: "Can't add pair's current price!");
    }

    /// if the alert already exists, notify the user
    else if (isAlertAlreadyExist) {
      /// notifying the user that the alert already exists
      showNotification(context: context, message: "The alert already exists!");
    }

    /// save all price alerts locally asynchronously
    savePriceAlertsToLocalStorage();

    print("mapOfAllAlerts: ${_mapOfAllAlerts}");

    notifyListeners();
  }

  /// this method plays an alert sound every three seconds or stops the audio
  /// player depending on whether:
  /// 1. a price alert has been fulfilled and is not muted
  /// 2. no alert has been fulfilled
  /// 3. all fulfilled price alerts have been muted
  Future _playOrStopAudio() async {
    print(
        "_countFulfilledUnMutedAlerts within _playOrStopAudio: ${_countFulfilledUnMutedAlerts}");

    /// play alert sound at regular intervals (every 3 seconds) if the specified \
    /// price alert has been fulfilled and is currently not muted.  Otherwise,
    /// stop any alert sound that's playing, if any..
    if (_countFulfilledUnMutedAlerts > 0
        // && alertOperationType==AlertOperationType.setIsAlertFulfilled
        ) {
      /// creating audio playing timer
      if (_isPlayingAlertSound == false) {
        _timerAudioPlayer =
            Timer.periodic(const Duration(milliseconds: 3000), (timer) async {
          await _audioPlayer
              .play(AssetSource("/sounds/notification_sound.mp3"));
        });
      }

      /// vibrate the device
      // HapticFeedback.vibrate();
      // HapticFeedback.heavyImpact();
      /// signalling that the price alert sound is currently being played
      _isPlayingAlertSound = true;
      // return _isAllPriceAlertsMuted;
    } else if (_countFulfilledUnMutedAlerts == 0
        // && alertOperationType==AlertOperationType.setIsAlertFulfilled
        ) {
      /// cancelling audio playing timer
      _timerAudioPlayer.cancel();

      /// stopping the audio player
      await _audioPlayer.stop();

      /// resetting _isPlayingAlertSound
      _isPlayingAlertSound = false;
      // _isSoundAlertAlarm=false;
      // return _isSoundAlertAlarm;
    } else if (_isAllPriceAlertsMuted == true) {
      /// cancelling audio playing timer
      _timerAudioPlayer.cancel();

      /// stopping the audio player
      await _audioPlayer.stop();

      /// resetting _isPlayingAlertSound
      _isPlayingAlertSound = false;
      // _isSoundAlertAlarm=false;
    }
  }

  /// mutes, un-mutes or removes an individual alert
  ///
  /// used with alert prices list view builder..
  void muteUnMuteOrRemoveAlert(
      {required String currencyPair,
      required String alertPrice,
      required AlertOperationType alertOperationType}) async {
    bool isCurrencyPairInMapOfAllAlerts =
        _mapOfAllAlerts.keys.toList().contains(currencyPair);
    bool isAlertExists = false;

    print("here1");

    /// if at least one alert exists for the specified...
    if (isCurrencyPairInMapOfAllAlerts) {
      List<dynamic>? listOfAlertsSpecifiedPair = [
        ..._mapOfAllAlerts[currencyPair]
      ];

      print("here2");

      /// iterate through the specified currency pair's existing alerts, if
      /// any, to mute, un-mute or delete the specified alert, if it exists..
      int indexOfAlertIfAlreadyExists = 0;
      for (var alertsData in listOfAlertsSpecifiedPair!) {
        print("here3");
        String price = alertsData['price'];
        print("here4");
        print("alertsData keys: ${alertsData.keys.toList()}");
        bool isMuted = alertsData['isMuted'];

        print("price: $price");
        print("alertsData: $alertsData");
        print("isMuted: $isMuted");

        /// the specified alert...
        if (price == alertPrice) {
          print("here5");

          /// bool that signals whether the specified alert is currently muted
          bool isMutedCurrentPriceAlert =
              _mapOfAllAlerts[currencyPair]![indexOfAlertIfAlreadyExists]
                  ['isMuted'];

          /// bool that signals whether the specified alert has been fulfilled
          bool isFulfilledCurrentPriceAlert =
              _mapOfAllAlerts[currencyPair]![indexOfAlertIfAlreadyExists]
                  ['isFulfilledAlertPrice'];

          /// mute the current price alert if the alert operation type has been
          /// set to AlertOperationType.mute..
          if (alertOperationType == AlertOperationType.mute) {
            /// if the specified price alert to be muted has been fulfilled
            /// and is currently un-muted...
            if (isFulfilledCurrentPriceAlert &&
                isMutedCurrentPriceAlert == false) {
              /// decrease the number of fulfilled & un-muted price alerts
              _countFulfilledUnMutedAlerts -= 1;
            }

            _mapOfAllAlerts[currencyPair]![indexOfAlertIfAlreadyExists]
                ['isMuted'] = true;
          }

          /// un-mute the current price alert if the alert operation type has
          /// been set to AlertOperationType.unMute..
          else if (alertOperationType == AlertOperationType.unMute) {
            /// if the specified price alert to be un-muted has been fulfilled
            /// and is currently muted...
            if (isFulfilledCurrentPriceAlert && isMutedCurrentPriceAlert) {
              /// increase the number of fulfilled & un-muted price alerts
              _countFulfilledUnMutedAlerts += 1;
            }

            _mapOfAllAlerts[currencyPair]![indexOfAlertIfAlreadyExists]
                ['isMuted'] = false;
          }

          /// remove the current price alert if the alert operation type has
          /// been set to AlertOperationType.remove..
          else if (alertOperationType == AlertOperationType.remove) {
            /// if the specified price alert to be removed has been fulfilled
            /// and is currently un-muted...
            if (isFulfilledCurrentPriceAlert &&
                isMutedCurrentPriceAlert == false) {
              /// decrease the number of fulfilled & un-muted price alerts
              _countFulfilledUnMutedAlerts -= 1;
            }

            /// remove the alert from the map of all alerts
            _mapOfAllAlerts[currencyPair]!
                .removeAt(indexOfAlertIfAlreadyExists);

            /// if no alerts exist for the current pair after deletion of the
            /// above alert, remove the currency pair from the map of alerts..
            if (_mapOfAllAlerts[currencyPair]!.isEmpty) {
              _mapOfAllAlerts.remove(currencyPair);
            }

            print("here6");
            print("_mapOfAllAlerts: $_mapOfAllAlerts");
          }
        }

        indexOfAlertIfAlreadyExists += 1;
      }
    }

    print("_countFulfilledUnMutedAlerts_: ${_countFulfilledUnMutedAlerts}");

    /// play or stop playing alert sound depending on on whether:
    /// 1. a price alert has been fulfilled and is not muted
    /// 2. no alert has been fulfilled
    /// 3. all fulfilled price alerts have been muted
    await _playOrStopAudio();

    print("_mapOfAllAlerts: ${_mapOfAllAlerts}");

    /// update all listening widgets
    notifyListeners();
  }

  /// this method is used to:
  /// 1. mute all alerts
  /// 2. un-mutes all alerts
  /// 3. determine whether all alerts have been muted
  /// 4. determine whether an alert price has been met, hit, or fulfilled..
  /// If option 4 is true, this method will return a bool
  Future muteUnMuteAllOrCalcIsAllMutedOrIsPriceAlertFulfilled(
      {
      /// must be either mute or un-mute
      required AlertOperationType alertOperationType}) async {
    /// bool that signals whether all price alert have been muted
    // bool isMutedAll=false;

    /// number of alerts
    int countAllAlerts = 0;

    /// number of muted alerts
    int countMutedAlerts = 0;

    /// is this the first time prices are being fetched?
    bool isFirstTimeFetchingPrices = false;

    /// muting all price alerts
    _mapOfAllAlerts.forEach((currencyPair, listOfPriceAlertsCurrentPair) {
      /// index of the current currency pair's price alert
      int indexAlertCurrentPair = 0;

      /// muting or un-muting the current currency pair's price alerts
      for (Map alertData in listOfPriceAlertsCurrentPair) {
        print('alertData: ${alertData}');

        /// increment the number of alerts - tracks the total number of alerts
        countAllAlerts += 1;

        /// bool that signals whether the current price alert's muted
        bool isMutedCurrentPriceAlert = _mapOfAllAlerts[currencyPair]
                [indexAlertCurrentPair]['isMuted'] ==
            true;

        /// bool that signals whether the current price alert has been fulfilled
        bool isFulfilledCurrentPriceAlert = _mapOfAllAlerts[currencyPair]
            [indexAlertCurrentPair]['isFulfilledAlertPrice'];

        /// current alert price
        String currentAlertPrice = alertData['price'];

        if (alertOperationType == AlertOperationType.mute) {
          /// if the current price alert to be muted was been fulfilled and
          /// is currently un-muted...
          if (isFulfilledCurrentPriceAlert &&
              isMutedCurrentPriceAlert == false) {
            /// decrease the number of fulfilled & un-muted price alerts
            _countFulfilledUnMutedAlerts -= 1;
          }

          /// set isMuted to true for the current price alert
          _mapOfAllAlerts[currencyPair][indexAlertCurrentPair]['isMuted'] =
              true;
        } else if (alertOperationType == AlertOperationType.unMute) {
          /// if the current price alert to be un-muted has been fulfilled and
          /// is currently muted...
          if (isFulfilledCurrentPriceAlert && isMutedCurrentPriceAlert) {
            /// increase the number of fulfilled & un-muted price alerts
            _countFulfilledUnMutedAlerts += 1;
          }

          /// set isMuted to false for the current price alert
          _mapOfAllAlerts[currencyPair][indexAlertCurrentPair]['isMuted'] =
              false;
        }

        /// increase the number of muted alerts if this alert has been muted..
        else if (alertOperationType ==
            AlertOperationType.calcIsAllAlertsMuted) {
          if (isMutedCurrentPriceAlert == true) {
            /// increment the number of muted alert's counter
            countMutedAlerts += 1;
          }
        }

        /// determine if the current alert has been triggered, fulfilled
        /// and update isFulfilledAlertPrice accordingly
        else if (alertOperationType == AlertOperationType.setIsAlertFulfilled &&
            isFirstTimeFetchingPrices == false) {
          /// the latest price of the alert currency pair
          String currentPairPrice =
              _allForexAndCryptoPrices[currencyPair]['current_price'];

          /// if the current alert's price has been fulfilled, register that it
          /// has been fulfilled. Otherwise, register that it has not been
          /// fulfilled..
          if (currentPairPrice == currentAlertPrice) {
            _mapOfAllAlerts[currencyPair][indexAlertCurrentPair]
                ['isFulfilledAlertPrice'] = true;

            /// registering that the current alert has been fulfilled at least once
            _mapOfAllAlerts[currencyPair][indexAlertCurrentPair]
                ['hasFulfilledAlertPriceOnce'] = true;
          } else {
            _mapOfAllAlerts[currencyPair][indexAlertCurrentPair]
                ['isFulfilledAlertPrice'] = false;
          }

          /// if the current alert's price has been fulfilled and is not muted,
          /// increase the number of fulfilled alerts that have not been muted
          /// by 1 unit
          if (currentPairPrice == currentAlertPrice &&
              isMutedCurrentPriceAlert == false) {
            _countFulfilledUnMutedAlerts += 1;
          }
          // else if (currentPairPrice==currentAlertPrice && isMutedCurrentPriceAlert==false){
          //
          // }

          /// if the current alert's price has not been fulfilled, set
          /// isFulfilledAlertPrice to false
          // else if (currencyPair!=currentAlertPrice){
          //   _mapOfAllAlerts[currencyPair][indexAlertCurrentPair]['isFulfilledAlertPrice']=false;
          // }
        }

        /// increment the currency pair's price alert index
        indexAlertCurrentPair += 1;
      }
    });

    /// updating the value of the boolean that tracks whether or not all alerts
    /// have been muted..
    print(
        'countAllAlerts==countMutedAlerts: ${countAllAlerts == countMutedAlerts}');
    print("_mapOfAllAlerts.isNotEmpty: ${_mapOfAllAlerts.isNotEmpty}");
    if ((countAllAlerts == countMutedAlerts && _mapOfAllAlerts.isNotEmpty) &&
        alertOperationType == AlertOperationType.calcIsAllAlertsMuted) {
      _isAllPriceAlertsMuted = true;

      print("_isAllPriceAlertsMuted: $_isAllPriceAlertsMuted");
    }

    /// no alert is muted when this condition is true since no alert exists
    else if (countAllAlerts == countMutedAlerts &&
        _mapOfAllAlerts.isEmpty &&
        alertOperationType == AlertOperationType.calcIsAllAlertsMuted) {
      _isAllPriceAlertsMuted = false;
    } else if (countAllAlerts != countMutedAlerts &&
        alertOperationType == AlertOperationType.calcIsAllAlertsMuted) {
      // print('Got')
      _isAllPriceAlertsMuted = false;
    }

    // /// reload all listening widgets if this method isn't being used to
    // /// set, determine whether price alerts have been fulfilled..
    // if (alertOperationType!=AlertOperationType.setIsAlertFulfilled){
    //   notifyListeners();
    // }

    print("_countFulfilledUnMutedAlerts_: ${_countFulfilledUnMutedAlerts}");

    /// play or stop playing alert sound depending on on whether:
    /// 1. a price alert has been fulfilled and is not muted
    /// 2. no alert has been fulfilled
    /// 3. all fulfilled price alerts have been muted
    await _playOrStopAudio();

    print('_isPlayingAlertSound: ${_isPlayingAlertSound}');
    print('_mapOfAllAlerts.length: ${_mapOfAllAlerts.length}');
    print("_isAllPriceAlertsMuted: ${_isAllPriceAlertsMuted}");
    notifyListeners();
  }

  /// returns the bool whether that signals whether all alert have been muted
  getIsMutedAll() {
    return _isAllPriceAlertsMuted;
  }

  /// retrieves a map of all alerts
  Map<dynamic, dynamic> getMapOfAllAlerts() {
    // List<Map<String, dynamic>>
    return _mapOfAllAlerts;
  }

  /// returns a bool that signals whether the map of all alerts is empty
  bool isMapOfAllAlertsEmpty() {
    return _mapOfAllAlerts.isEmpty;
  }

// /// get whether an alert price has been fulfilled
// ///
// /// i.e if the latest price of at least one price alert's currency pair
// /// equals its alert price..
// getisFulfilledAlertPrice(){
//
//   bool isFulfilledAlertPrice=false;
//
//   if (_mapOfAllAlerts.isNotEmpty){
//     _mapOfAllAlerts.forEach((currencyPair, listOfAllAlertsCurrentPair) {
//
//     });
//   }
// }
}

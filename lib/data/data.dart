import 'dart:convert';
import 'dart:io';

// import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;
// import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";

import "enums.dart";


enum PriceDataType{
  realtime,
  quote
}

class Data {

  /// a map of symbols or instruments before any price is fetched..
  Map<String, String> mapOfSymbolsPreInitialPriceFetch = {};

  /// a list of all symbols or instrument's (data) map...
  final List<Map<dynamic, dynamic>> _listOfAllSymbolsDataMaps = [];
  final List<String> _listOfImportantForexPairs = [
    "AUD/USD", "EUR/USD", "GBP/USD", "NZD/USD", "USD/CAD", "USD/CHF", "USD/JPY",
    "AUD/CAD", "AUD/CHF", "AUD/JPY", "AUD/NZD", "CAD/CHF", "CAD/JPY", "CHF/JPY",
  ]; // "EUR/AUD", "EUR/CAD", "EUR/CHF", "EUR/GBP", "EUR/JPY", "EUR/NZD", "GBP/AUD", "GBP/CAD", "GBP/CHF", "GBP/JPY", "GBP/NZD", "NZD/CAD", "NZD/CHF", "NZD/JPY"

  final List<String> _listOfImportantCryptoPairs = [
    "BTC/USD",  "ETH/USD",  "USDT/USD",  "BNB/USD",  "SOL/USD",  "USDC/USD",
    "XRP/USD",  "TON/USD",  "DOGE/USD",  "ADA/USD",  "SHIB/USD",  "AVAX/USD",
    "TRX/USD"
  ]; // "DOT/USD", "LINK/USD", "BCH/USD",  "NEAR/USD",  "MATIC/USD", "LTC/USD",  "ICP/USD",  "LEOu/USD",  "DAI/USD",  "UNI/USD",  "PEPE/USD", "ETC/USD",  "HBAR/USD",  "RNDR/USD"

  final List<String> fullListOfImportantPairs = [
    "AUD/USD", "EUR/USD", "GBP/USD", "NZD/USD", "USD/CAD", "USD/CHF", "USD/JPY",
    "AUD/CAD", "AUD/CHF", "AUD/JPY", "AUD/NZD", "CAD/CHF", "CAD/JPY", "CHF/JPY",
    "EUR/AUD", "EUR/CAD", "EUR/CHF", "EUR/GBP", "EUR/JPY", "EUR/NZD", "GBP/AUD",
    "GBP/CAD", "GBP/CHF", "GBP/JPY", "GBP/NZD", "NZD/CAD", "NZD/CHF", "NZD/JPY",
    "BTC/USD",  "ETH/USD",  "USDT/USD",  "BNB/USD",  "SOL/USD",  "USDC/USD",
    "XRP/USD",  "TON/USD",  "DOGE/USD",  "ADA/USD",  "SHIB/USD",  "AVAX/USD",
    "TRX/USD", "DOT/USD", "LINK/USD", "BCH/USD",  "NEAR/USD",  "MATIC/USD",
    "LTC/USD",  "ICP/USD",  "LEOu/USD",  "DAI/USD",  "UNI/USD",  "PEPE/USD",
    "ETC/USD",  "HBAR/USD",  "RNDR/USD"
  ];

  /// "BTC", "ETH", "USDT", "BNB", "SOL", "USDC", "XRP", "TON", "DOGE", "ADA",
  /// "SHIB", "AVAX", "TRX", "DOT", "LINK", "BCH", "NEAR", "MATIC", "LTC", "ICP",
  /// "LEO", "DAI", "UNI", "PEPE", "ETC", "HBAR", "RNDR"

  final String _apiKey =  dotenv.env["API_KEY"]!;

  Directory? _appDir;
  String? _appDirPath;
  final String _dataFolderName = dotenv.env["DATA_FOLDER_NAME"]!;
  final String _allSymbolsDataFileName = dotenv.env["DATA_FILE_NAME"]!;
  final String _logFolderName = dotenv.env["LOG_FOLDER_NAME"]!;
  final String _dataFetchingErrorLogFileName = dotenv.env["DATA_FETCHING_ERROR_LOG_FILE_NAME"]!;
  final String _dataUpdateSessionsFileName = dotenv.env["DATA_UPDATE_SESSIONS_FILE_NAME"]!;
  final String _otherErrorsLogFileName = dotenv.env["OTHER_ERRORS_LOG_FILE_NAME"]!;
  final String _urlRealTimePrice = dotenv.env["URL_REAL_TIME_PRICE"]!;
  final String _urlQuote = dotenv.env["URL_LATEST_ONE_MIN_QUOTE"]!;

  File? _dataFetchingErrorLogFile;
  File? _allSymbolsDataFile;
  File? _dataUpdateSessionsFile;
  File? _otherErrorsLogFile;

  /// This method creates the app's files and folders
  Future createAppFilesAndFolders() async{

    print("Creating files");

    _appDir = await getApplicationDocumentsDirectory();
    _appDirPath = "${_appDir!.path}/";
    // print("appDirUri: ${_appDir!.uri}");

    /// creating all relevant files & folders in this app's document directory
    /// i.e appDir

    // path to all symbols data file
    File allSymbolsDataFile = File(
        _appDirPath! +
        _dataFolderName +
        _allSymbolsDataFileName
    );

    File dataFetchingErrorLogfile = File(
        _appDirPath! +
            _dataFolderName +
            _logFolderName +
            _dataFetchingErrorLogFileName
    );
    
    File dataUpdateSessionsFile = File(
      _appDirPath! +
          _dataFolderName +
          _logFolderName +
          _dataUpdateSessionsFileName
    );

    File otherErrorsLogFile = File(
        _appDirPath! +
            _dataFolderName +
            _logFolderName +
            _otherErrorsLogFileName
    );

    bool isAllSymbolsDataFile = await allSymbolsDataFile.exists();
    bool isDataFetchingErrorLogfile = await dataFetchingErrorLogfile.exists();
    bool isdataUpdateSessionsFile = await dataUpdateSessionsFile.exists();
    bool isOtherErrorsLogFile = await otherErrorsLogFile.exists();

    /// if data file and log files do not exist, create them.
    // all symbols data file
    if (isAllSymbolsDataFile == false){
      await allSymbolsDataFile.create(recursive: true);
      allSymbolsDataFile.writeAsString(
        json.encode([{}]),
      );
    }

    // data fetching error log file
    if (isDataFetchingErrorLogfile == false){
      await dataFetchingErrorLogfile.create(recursive: true);
    }

    // data update sessions file
    if ( isdataUpdateSessionsFile == false){

      DateTime now = DateTime.now();

      await dataUpdateSessionsFile.create(recursive: true);
      await dataUpdateSessionsFile.writeAsString(json.encode({}));

    }

    // other error log file
    if (isOtherErrorsLogFile == false){

      await otherErrorsLogFile.create(recursive: true);

    }



    /// setting the symbols data and data fetching error (File) objects
    _allSymbolsDataFile = allSymbolsDataFile;
    _dataFetchingErrorLogFile = dataFetchingErrorLogfile;
    _dataUpdateSessionsFile = dataUpdateSessionsFile;
    _otherErrorsLogFile = otherErrorsLogFile;

    print("Done with creating files!");

  }

  /// This method updates all forex symbols data
  Future _updateAllForexSymbolsData() async{

    // try{

      /// formatting url & obtaining all forex symbols' data
      List<String> urlAllForexPairs = dotenv.env['URL_ALL_FOREX_PAIRS']!.split("/");

      // print("getAllForexPairsUrl: ${getAllForexPairsUrl}, type: ${getAllForexPairsUrl.runtimeType}");

      Uri uri = Uri.https(urlAllForexPairs[0], urlAllForexPairs[1]);
      var response = await http.get(uri);
      List<dynamic> resolvedResponse = json.decode(response.body)['data'];

      /// adding the data type, "forex", to each currency detail (map)
      for (var i in resolvedResponse) {
        i["type"] = "forex";
        _listOfAllSymbolsDataMaps.add(i);
        print(i);
      }

    // } catch(error){
    //
    //   DateTime dateTime = DateTime.now();
    //
    //   print("_dataFetchingErrorLogFile: $_dataFetchingErrorLogFile");
    //   await _dataFetchingErrorLogFile!.writeAsString(""
    //       "$dateTime: \n"
    //       "_updateAllForexSymbolsData\n"
    //       "AN ERROR OCCURRED WHILE FETCHING FOREX SYMBOLS!\n"
    //       "${error.toString()}\n\n",
    //       mode: FileMode.append
    //   );
    //
    // }

  }

  /// This method updates all stock symbols' data
  Future _updateAllStockSymbolsData() async{

    try{

      /// formatting url & obtaining all stock symbols' data
      List<String> urlAllStockSymbols = dotenv.env['URL_ALL_STOCKS_SYMBOLS']!.split("/");

      // print("getAllForexPairsUrl: ${getAllForexPairsUrl}, type: ${getAllForexPairsUrl.runtimeType}");

      Uri uri = Uri.https(urlAllStockSymbols[0], urlAllStockSymbols[1]);
      var response = await http.get(uri);
      List<dynamic> resolvedResponse = json.decode(response.body)['data'];

      /// adding the data type, "stock", to each stock symbol's detail (map)
      for (var i in resolvedResponse) {
        i["type"] = "stock";
        _listOfAllSymbolsDataMaps.add(i);
        print(i);
      }

    }catch(error){

      DateTime dateTime = DateTime.now();

      print("_dataFetchingErrorLogFile: $_dataFetchingErrorLogFile");
      _dataFetchingErrorLogFile!.writeAsString(""
          "$dateTime: \n"
          "_updateAllStockSymbolsData\n"
          "AN ERROR OCCURRED WHILE FETCHING STOCK SYMBOLS' DATA!\n"
          "${error.toString()}\n\n",
          mode: FileMode.append
      );

    }



  }

  /// This method updates all crypto symbols' data
  Future _updateAllCryptoSymbolsData() async{

    // try{

      /// formatting url & obtaining all crypto symbols' data
      List<String> urlAllCryptoSymbols = dotenv.env['URL_ALL_CRYPTO_SYMBOLS']!.split("/");

      // print("getAllForexPairsUrl: ${getAllForexPairsUrl}, type: ${getAllForexPairsUrl.runtimeType}");

      Uri uri = Uri.https(urlAllCryptoSymbols[0], urlAllCryptoSymbols[1]);
      var response = await http.get(uri);
      List<dynamic> resolvedResponse = json.decode(response.body)['data'];

      /// adding the data type, "crypto", to each crypto symbol's detail (map)
      for (var i in resolvedResponse) {
        i["type"] = "crypto";
        _listOfAllSymbolsDataMaps.add(i);
        print(i);
      }


    // }catch(error){
    //
    //   DateTime dateTime = DateTime.now();
    //
    //   print("_dataFetchingErrorLogFile: $_dataFetchingErrorLogFile");
    //   await _dataFetchingErrorLogFile!.writeAsString(""
    //       "$dateTime: \n"
    //       "_updateAllCryptoSymbolsData\n"
    //       "AN ERROR OCCURRED WHILE FETCHING CRYPTO SYMBOLS' DATA!\n"
    //       "${error.toString()}\n\n",
    //       mode: FileMode.append
    //   );
    //
    // }


  }

  /// This method updates all etf symbols' data
  Future _updateAllETFSymbolsData() async{

    try{

      /// formatting url & obtaining all ETF symbols' data
      List<String> urlAllETFSymbols = dotenv.env['URL_ALL_ETF_SYMBOLS']!.split("/");

      // print("getAllForexPairsUrl: ${getAllForexPairsUrl}, type: ${getAllForexPairsUrl.runtimeType}");

      Uri uri = Uri.https(urlAllETFSymbols[0], urlAllETFSymbols[1]);
      var response = await http.get(uri);
      List<dynamic> resolvedResponse = json.decode(response.body)['data'];

      /// adding the data type, "etf", to each etf symbol's detail (map)
      for (var i in resolvedResponse) {
        i["type"] = "etf";
        _listOfAllSymbolsDataMaps.add(i);
        print(i);
      }

    }catch(error){

      DateTime dateTime = DateTime.now();

      print("_dataFetchingErrorLogFile: $_dataFetchingErrorLogFile");
      _dataFetchingErrorLogFile!.writeAsString(""
          "$dateTime: \n"
          "_updateAllETFSymbolsData\n"
          "AN ERROR OCCURRED WHILE FETCHING ETF SYMBOL's DATA!\n"
          "${error.toString()}\n\n",
          mode: FileMode.append
      );

    }

  }

  /// This method updates all indices symbols' data
  Future _updateAllIndexSymbolsData() async{

    try{

      /// formatting url & obtaining all Index symbols' data
      List<String> urlAllIndexSymbols = dotenv.env['URL_ALL_INDEX_SYMBOLS']!.split("/");

      // print("getAllForexPairsUrl: ${getAllForexPairsUrl}, type: ${getAllForexPairsUrl.runtimeType}");

      Uri uri = Uri.https(urlAllIndexSymbols[0], urlAllIndexSymbols[1]);
      var response = await http.get(uri);
      List<dynamic> resolvedResponse = json.decode(response.body)['data'];

      /// adding the data type, "indices", to each index symbol's detail (map)
      for (var i in resolvedResponse) {
        i["type"] = "indices";
        _listOfAllSymbolsDataMaps.add(i);
        print(i);
      }

    }catch(error){

      DateTime dateTime = DateTime.now();

      print("_dataFetchingErrorLogFile: $_dataFetchingErrorLogFile");
      _dataFetchingErrorLogFile!.writeAsString(""
          "$dateTime: \n"
          "_updateAllIndexSymbolsData\n"
          "AN ERROR OCCURRED WHILE FETCHING INDEX SYMBOLS' DATA!\n"
          "${error.toString()}\n\n",
          mode: FileMode.append
      );

    }

  }

  /// This method updates all fund symbols' data
  Future _updateAllFundSymbolsData() async{

    try{

      /// formatting url & obtaining all fund symbols' data
      List<String> urlAllFundSymbols = dotenv.env['URL_ALL_FUNDS_SYMBOLS']!.split("/");

      // print("getAllForexPairsUrl: ${getAllForexPairsUrl}, type: ${getAllForexPairsUrl.runtimeType}");

      Uri uri = Uri.https(urlAllFundSymbols[0], urlAllFundSymbols[1]);
      var response = await http.get(uri);
      List<dynamic> resolvedResponse = json.decode(response.body)['data'];

      /// adding the data type, "fund", to each fund symbol's detail (map)
      for (var i in resolvedResponse) {
        i["type"] = "fund";
        _listOfAllSymbolsDataMaps.add(i);
        print(i);
      }

    } catch(error){

      DateTime dateTime = DateTime.now();

      print("_dataFetchingErrorLogFile: $_dataFetchingErrorLogFile");
      _dataFetchingErrorLogFile!.writeAsString(""
          "$dateTime: \n"
          "AN ERROR OCCURRED WHILE FETCHING FUND SYMBOL'S DATA!\n"
          "${error.toString()}\n\n",
          mode: FileMode.append
      );

    }

  }

  /// This method updates all bonds' data
  Future _updateAllBondSymbolsData() async{

    // print("running updateAllBondsData");

    try{

      /// formatting url & obtaining bond symbols' data
      List<String> urlAllBondSymbols = dotenv.env['URL_ALL_BONDS_SYMBOLS']!.split("/");

      // print("getAllForexPairsUrl: ${getAllForexPairsUrl}, type: ${getAllForexPairsUrl.runtimeType}");

      Uri uri = Uri.https(urlAllBondSymbols[0], urlAllBondSymbols[1]);
      var response = await http.get(uri);
      List<dynamic> resolvedResponse = json.decode(response.body)['data'];

      /// adding the data type, "bond", to each bond's detail (map)
      for (var i in resolvedResponse) {
        i["type"] = "bond";

        _listOfAllSymbolsDataMaps.add(i);
        print(i);
      }

      // print("finished running updateAllBondsData");

    }catch(error){

      DateTime dateTime = DateTime.now();

      print("_dataFetchingErrorLogFile: $_dataFetchingErrorLogFile");
      _dataFetchingErrorLogFile!.writeAsString(""
          "$dateTime: \n"
          "_updateAllFundSymbolsData\n"
          "AN ERROR OCCURRED WHILE FETCHING BOND SYMBOLS' DATA!\n"
          "${error.toString()}\n\n",
        mode: FileMode.append
      );

    }

  }

  /// This method updates and saves all financial data to this app's directory
  /// Cost: 6 API credits per day -> 180 API credits per month
  Future updateAndSaveAllSymbolsData({
      /// a bool to break free from the 24 hrs limit set for this function
      bool unconditionally = false
  }) async {

    print("///");
    /// saving the update session's time to 'data update sessions' log file
    String lastUpdateTime = DateTime.now().toString();

    /// update sessions file
    Map<dynamic, dynamic> updateSessions = json.decode(await _dataUpdateSessionsFile!.readAsString());


    print("////");
    dynamic lastSymbolsDataUpdateTime = updateSessions["last_symbols_data_update_time"];
    // print("/////");
    dynamic lastSymbolsDataUpdateErrorTime = updateSessions["last_symbols_data_update_error_time"];
    print("//////");

    /// checking whether the last symbols' data updated over 24 hrs ago.
    /// 1. If not, task will be cancelled..
    /// 2. If no previous symbols' data update session exists, this task will
    /// continue..
    if (lastSymbolsDataUpdateTime != null){

      print("//////");
      lastSymbolsDataUpdateTime = DateTime.parse(lastSymbolsDataUpdateTime);

      DateTime now = DateTime.now();

      /// time difference between the last symbols data update and the current
      /// session in hours
      int diffLastSymbolsDataUpdateTimeInHours = now.difference(lastSymbolsDataUpdateTime).inHours;
      // print("lastSymbolsDataUpdateTime: $lastSymbolsDataUpdateTime");
      // print("now - lastSymbolsDataUpdateTime: ${now.difference(lastSymbolsDataUpdateTime).inHours}");

      /// Was there an error while fetching all symbols data previously?
      bool isLastSymbolsDataUpdateTimeEqualToLastSymbolsDataUpdateErrorTime =
          lastSymbolsDataUpdateTime.toString() == lastSymbolsDataUpdateErrorTime.toString();

      print("///////");
      print("lastSymbolsDataUpdateTime: $lastSymbolsDataUpdateTime, "
          "lastSymbolsDataUpdateErrorTime: $lastSymbolsDataUpdateErrorTime");

      print("isLastSymbolsDataUpdateTimeEqualToLastSymbolsDataUpdateErrorTime: $isLastSymbolsDataUpdateTimeEqualToLastSymbolsDataUpdateErrorTime");

      /// determining whether to proceed with the symbols' data update..
      /// if all symbols were updated within the last 24 hours and there was
      /// no update error, cancel the current session
      print("////////");
      if (
        diffLastSymbolsDataUpdateTimeInHours < 24
            && isLastSymbolsDataUpdateTimeEqualToLastSymbolsDataUpdateErrorTime == false
            && unconditionally == false
      ){
        print("Can't update symbols data now! Last update session was under 24hrs ago..");
        return {};
      }

    }

    // print("aDay - lastSymbolsDataUpdateTime: ${aDay.}")
    // if (lastSymbolsDataUpdateTime )
    print("/////////");
    /// updating symbols' data
    try{

      print("Updating All Data..");

      /// updating all financial data
      await _updateAllForexSymbolsData();
      // await _updateAllStockSymbolsData();  // skipped - v1
      await _updateAllCryptoSymbolsData();
      // await _updateAllETFSymbolsData();    // skipped - v1
      // await _updateAllIndexSymbolsData();  // skipped - v1
      // await _updateAllFundSymbolsData();   // skipped - v1
      // await _updateAllBondSymbolsData();   // skipped - v1

      /// saving the financial data to all symbols' data file
      String allSymbolsData = jsonEncode(_listOfAllSymbolsDataMaps);
      /// CHECKED HERE!!
      _allSymbolsDataFile!.writeAsString(
          allSymbolsData,
          mode: FileMode.write
      );

      var updateSessions = json.decode(await _dataUpdateSessionsFile!.readAsString());
      updateSessions["last_symbols_data_update_time"] = lastUpdateTime.toString();


      print("updateSessions: $updateSessions");

      _dataUpdateSessionsFile!.writeAsString(json.encode(updateSessions));

      print("Data Update Complete!");
      print("");

    } catch(error){

      print("AN ERROR OCCURRED WHILE UPDATING AND SAVING ALL SYMBOLS' DATA!");

      /// logging symbols' data update and update error time for current session
      var updateSessions = json.decode(await _dataUpdateSessionsFile!.readAsString());
      updateSessions["last_symbols_data_update_time"] = lastUpdateTime.toString();
      updateSessions["last_symbols_data_update_error_time"] = lastUpdateTime.toString();

      _dataUpdateSessionsFile!.writeAsString(json.encode(updateSessions));
      print("");

      /// logging symbols' data update error
      _otherErrorsLogFile!.writeAsString(
          "$lastUpdateTime: \n"
              "updateAndSaveAllSymbolsData\n"
              "AN ERROR OCCURRED WHILE UPDATING AND SAVING ALL SYMBOLS' DATA!\n"
              "${error.toString()}\n\n",
          mode: FileMode.append
      );
    }



  }

  /// This method retrieves all locally saved symbols' data
  Future<List<dynamic>> getAllSymbolsLocalData() async{

    print("");
    print("List of all Symbols / Instruments - getAllSymbolsLocalData");
    print("__________________________________________________________");
    print("");

    int count = 0;

    dynamic savedListOfAllSymbolsDataMaps = await _allSymbolsDataFile!.readAsString();
    savedListOfAllSymbolsDataMaps = json.decode(savedListOfAllSymbolsDataMaps);

    // for (var symbolMap in savedListOfAllSymbolsDataMaps){
    //
    //   String symbolDenominator = symbolMap["symbol"].split("/")[1];
    //
    //   if (
    //     symbolDenominator.endsWith("USD")
    //         // ||
    //         // symbolDenominator.endsWith("ETH") ||
    //         // symbolDenominator.endsWith("BTC")
    //   ){
    //
    //     print(symbolMap);
    //     count += 1;
    //
    //   }
    //
    // }

    count = savedListOfAllSymbolsDataMaps.length; // 5846
    print("Total number of instruments - getAllSymbolsLocalData: $count");
    print("");

    print("__________________________________________________________");

    return savedListOfAllSymbolsDataMaps;

  }

  /// This method prints the app's directory uri
  void getUriAppDirectory(){
    
    print("This app's directory: ${_appDir!.uri}");
    
  }

  /// This method retrieves a symbol(s)'s realtime price
  Future<Map<String, dynamic>> getRealTimePriceSingle({
    required String symbol,
    required String country,
    required PriceDataType priceDataType,
  }) async{

    var aMapPriceOfcurrentPair = {};

    // try{

      /// determining price fetching url based on the requested data type i.e
      /// realtime price or quote, which contains last minute's open, close,
      /// high, low
      /// Types: urlRealTimePriceOrQuote - String -> List<Strings>
      /// api.twelvedata.com/quote?symbol={abc}&interval=1min&apikey=
      dynamic urlRealTimePriceOrQuote = priceDataType ==
          PriceDataType.realtime ? _urlRealTimePrice: _urlQuote;

      urlRealTimePriceOrQuote = urlRealTimePriceOrQuote.replaceFirst("/", " ");

      /// replacing unnecessary symbols
      urlRealTimePriceOrQuote = urlRealTimePriceOrQuote.replaceFirst("{abc}", symbol);

      if (urlRealTimePriceOrQuote.contains("{xyz}")){
        urlRealTimePriceOrQuote = urlRealTimePriceOrQuote.replaceFirst("{xyz}", country);
      }

      /// including a common symbol - "&", and api key
      urlRealTimePriceOrQuote = urlRealTimePriceOrQuote.replaceFirst("?", "&");
      urlRealTimePriceOrQuote = urlRealTimePriceOrQuote + _apiKey;

      /// separating the URL Authority from the URL Path and Parameters
      urlRealTimePriceOrQuote = urlRealTimePriceOrQuote.split(" ");

      List<String> urlPathAndParameters = urlRealTimePriceOrQuote[1].split("&");

      /// defining urlAuthority, urlPath, & urlParameters - for http.get() module
      String urlAuthority = urlRealTimePriceOrQuote[0];
      String urlPath = urlPathAndParameters[0];
      Map<String, String> urlParameters = {};

      /// urlParameters
      for (String parameter in urlPathAndParameters.sublist(1)){
        List<String> paramAndParamValue = parameter.split("=");
        String paramKey = paramAndParamValue[0];
        String paramValue = paramAndParamValue[1];
        urlParameters[paramKey] = paramValue;
      }

      // print("urlRealTimePrice: $urlRealTimePrice");
      // print("urlAuthority: $urlAuthority");
      // print("urlParameters: $urlParameters");

      /// sending a request
      Uri uriUrlRealTimePrice = Uri.https(urlAuthority, urlPath, urlParameters);

      http.Response response = await http.get(uriUrlRealTimePrice);
      Map<String, dynamic> resolvedResponse = json.decode(response.body);

      // print("");
      // print("response: ${resolvedResponse}}");
      // print("");

      if (priceDataType == PriceDataType.realtime){
        aMapPriceOfcurrentPair = resolvedResponse;
      }
      else if (priceDataType == PriceDataType.quote){
        aMapPriceOfcurrentPair = resolvedResponse;
      }

      // List<dynamic> resolvedResponse = json.decode(response.body);
      //
      // for (var i in resolvedResponse){
      //   print("i: $i");
      // }

    // } catch(error){
    //
    //   /// logging symbols' data update error
    //   DateTime now = DateTime.now();
    //
    //   _otherErrorsLogFile!.writeAsString(
    //       "$now: \n"
    //           "getRealTimePriceSingle\n"
    //           "AN ERROR OCCURRED WHILE FETCHING THIS INSTRUMENT'S PRICE: ${symbol}!\n"
    //           "${error.toString()}\n\n",
    //       mode: FileMode.append
    //   );

    // }

    return {...aMapPriceOfcurrentPair};

  }

  /// This method logs all important pairs that have been saved locally i.e
  /// recognised by data provider
  void checkIfImportantPairsInSavedPairs({
    required List<String> listOfImportantPairs,
    required List<dynamic> listOfSavedPairs
  }){

    int count = 0;
    for (var symbolData in listOfSavedPairs){

      String currentSavedPair = symbolData["symbol"];

      /// QUICK CHECK

      for (var importantPair in listOfImportantPairs){
        if (currentSavedPair == importantPair){

          print("currentSavedPair: $currentSavedPair, importantPair: $importantPair");

          count += 1;
        }
      }

    }
    print("Total number of important pairs: ${count}");

  }

  Future<Map<dynamic, dynamic>> getMapOfAllPairsWithFetchingNotification() async{

    Map<dynamic, dynamic> mapOfSymbolsPreInitialPriceFetch = {};

    /// all instruments / symbols' data -> forex & crypto inclusive
    List<dynamic> savedListOfAllSymbolsDataMaps =  await getAllSymbolsLocalData();

    for (var symbolData in savedListOfAllSymbolsDataMaps){

      String symbol = symbolData['symbol'];

      /// creating a map of all symbols before any price is fetched...
      mapOfSymbolsPreInitialPriceFetch[symbol] = "fetching";

    }

    await _dataFetchingErrorLogFile!.writeAsString(json.encode(mapOfSymbolsPreInitialPriceFetch));

    return mapOfSymbolsPreInitialPriceFetch;

  }


  /// This method obtains the prices of all saved instruments (symbols)
  /// {} as the return value means:
  /// a. A session took place less than 1 minute ago, OR
  /// b. A session took place but didn't complete due to network or other errors
  /// It is bes to wait for one minute before calling this function again in
  /// the event any of the above two happen..
  Future<Map<dynamic,dynamic>> getRealTimePriceAll() async{

    print('PRE FOR! 1');

    DateTime nowGetRealTimePriceAll = DateTime.now();

    print("");
    print("--------------------------------------------------------------------------------");
    print("GETREALTIMEPRICEALL METHOD - START");
    print("");

    /// last update session's data -> both time and prices
    Map<String, dynamic> lastUpdateSessionsMap =
    json.decode(await _dataUpdateSessionsFile!.readAsString());

    /// last prices data update session's key (found in lastUpdateSession Map)..
    /// Value is either "last_prices_data_update_time" or
    /// "last_prices_data_update_time_initial"
    String? lastUpdateSessionsMapPricesDataKey;

    /// last prices data update session's time..
    String? lastPricesDataUpdateTimeString;
    String? latestPricesDataUpdateTimeString;

    /// instruments' prices (map)
    Map<String, dynamic> mapOfAllPrices = {};

    /// current symbol / pair
    String? currentPair;

    /// list of important pairs to be applied in this method..
    List<String> listOfAppliedImportantPairs = [];

    /// list of all 27 important pairs - ensures that the API credit limit
    /// (55 per minute) does not get exceeded when fetching both quotes and
    /// realtime prices of each instrument for the first time..
    List<String> listOfAllTwentySevenImportantPairs =
        _listOfImportantForexPairs + _listOfImportantCryptoPairs;

    /// setting the default value of listOfAppliedImportantPairs, to ensure that
    /// it doesn't exceed the above 27 pairs on this method's first execution..
    listOfAppliedImportantPairs = listOfAllTwentySevenImportantPairs;

    /// all instruments / symbols' data -> forex & crypto inclusive
    List<dynamic> savedListOfAllSymbolsDataMaps = [{}];
    Map<String, String> mapInstrumentsType = {};

    /// mapping out instruments and their prices
    savedListOfAllSymbolsDataMaps = await getAllSymbolsLocalData();

    /// Set of the above to remove duplicate symbols
    Set<String> setSavedListOfAllSymbols = {};

    /// boolean that tracks whether or not there's been a connection error
    bool connectionError = false;

    /// number of saved important pairs
    int countSavedImportantPairs = 0;

    /// number of saved unimportant pairs
    int countSavedUnimportantPairs = 0;

    for (var symbolData in savedListOfAllSymbolsDataMaps){
      String symbol = symbolData['symbol'];

      /// creating a map of all symbols before any price is fetched...
      mapOfSymbolsPreInitialPriceFetch[symbol] = "fetching";
      mapInstrumentsType[symbol] = symbolData['type'];

      setSavedListOfAllSymbols.add(symbol);
    }

    /// A map of previously retrieved prices... if any
    Map<String, dynamic> mapLastSavedPricesOneMinInterval = {};


    print("lengthMapOfAllPrices 1: ${mapOfAllPrices.length}");

    print('PRE FOR! 2');
    try{

      /// checking whether the last prices' data session was updated over 1 min
      /// ago.
      /// 1. If not, task will be cancelled..
      /// 2. If no previous prices' data update session exists, this task will
      /// continue..
      /// 3. Also, if prices data have previously been retrieved and saved, the
      ///    value of lastSavedPricesOneMinInterval will be set to the map of
      ///    the previouly retrieved prices data map
      if (
      lastUpdateSessionsMap.containsKey("last_prices_data_update_time") ||
          lastUpdateSessionsMap.containsKey(
              "last_prices_data_update_time_initial"
          )
      ){

        /// if there's been more than one forex and crypto prices updates and
        /// local storage, set lastPricesDataUpdateTimeString to
        /// last_prices_data_update_time's map key..
        if (lastUpdateSessionsMap.containsKey("last_prices_data_update_time")){

          /// saving the last prices data update session's key
          lastUpdateSessionsMapPricesDataKey = "last_prices_data_update_time";

          /// last prices data update time
          lastPricesDataUpdateTimeString =
          lastUpdateSessionsMap["last_prices_data_update_time"]!.keys.toList()[0];

          print("lastPricesDataUpdateTimeString: $lastPricesDataUpdateTimeString");

          /// latest prices of all forex and crypto pairs...
          mapLastSavedPricesOneMinInterval =
          lastUpdateSessionsMap
          ["last_prices_data_update_time"][lastPricesDataUpdateTimeString];

        }
        /// else set lastPricesDataUpdateTimeString to
        /// last_prices_data_update_time_initial's map key..
        else if (
          lastUpdateSessionsMap.containsKey(
              "last_prices_data_update_time_initial"
          )
        ){



          // STOPPED HERE!
          // print("here 1");

          // print("lastPricesDataUpdateTimeString: ${lastUpdateSessionsMap["last_prices_data_update_time_initial"]!.}");

          /// saving the last prices data update session's key
          lastUpdateSessionsMapPricesDataKey = "last_prices_data_update_time";

          /// last prices data update time
          lastPricesDataUpdateTimeString =
          lastUpdateSessionsMap["last_prices_data_update_time_initial"]!.keys.toList()[0];


          /// latest prices of all forex and crypto pairs...
          mapLastSavedPricesOneMinInterval =
          lastUpdateSessionsMap
          ["last_prices_data_update_time_initial"][lastPricesDataUpdateTimeString];

          // print("here 2");

        }

        DateTime lastPricesDataUpdateTime =
        DateTime.parse(lastPricesDataUpdateTimeString!);



        int diffLastPricesDataUpdateTimeInMilliSeconds =
            nowGetRealTimePriceAll.difference(lastPricesDataUpdateTime).inMilliseconds;
        // print("lastPricesDataUpdateTime: $lastSymbolsDataUpdateTime");
        // print("now - lastSymbolsDataUpdateTime: ${now.difference(lastSymbolsDataUpdateTime).inHours}");

        /// determining whether to proceed with the prices' data update..
        if (diffLastPricesDataUpdateTimeInMilliSeconds <= 60000){
          print("Timer.periodic - data - start: ${DateTime.now()}");
          print("nowGetRealTimePriceAll: $nowGetRealTimePriceAll");
          print("diffLastPricesDataUpdateTimeInMilliSeconds: $diffLastPricesDataUpdateTimeInMilliSeconds");
          print("Can't update symbols data now! Last update session was under 1 minute (approx) ago..");

          /// return the last saved prices' data
          return mapLastSavedPricesOneMinInterval;
        }

      }

      // checkIfImportantPairsInSavedPairs(
      //   listOfImportantPairs: listOfAppliedImportantPairs,
      //   listOfSavedPairs: savedListOfAllSymbolsDataMaps
      // );

      /// obtaining each pair's price, especially the most important ones
      /// i.e the most traded ones..

      print('PRE FOR!');
      for (var symbol in setSavedListOfAllSymbols){

        currentPair = symbol;

        // print(symbolData);

        /// retrieving price from data provider if pair is important or
        /// popularly traded
        if (listOfAppliedImportantPairs.contains(currentPair)){

          var mapPriceOfCurrentPairResponseQuote;
          var mapPriceOfCurrentPairResponseRealTime;

          /// if prices data:
          /// 1. has not previously been retrieved or
          ///
          /// 2. by inference, the current (important) pair's price (old and
          ///    current) has not previously been documented in
          ///    mapLastSavedPricesOneMinInterval,
          ///
          /// ...request for the current pair's
          ///    "quote", which contains the previous minute's opening price..
          ///
          /// Helps with documenting and noting whether the current realtime
          /// price of each pair is an upward or downward price movement,
          /// when compared with the previous minute's closing price provided
          /// by mapPriceOfCurrentPairResponseQuote..

          print("");
          // print("Getting quote - 1");
          if (mapLastSavedPricesOneMinInterval.isEmpty){

            // print("");
            // print("obtaining quote");

            // print("Getting quote - 2");
            mapPriceOfCurrentPairResponseQuote = await getRealTimePriceSingle(
                symbol: currentPair,
                country: "US",
                priceDataType: PriceDataType.quote
            );
            // print("mapPriceOfCurrentPairResponseQuote: $mapPriceOfCurrentPairResponseQuote");
            // print("Getting quote - 3");
            // print("");

            // print("mapPriceOfCurrentPairResponseQuote: $mapPriceOfCurrentPairResponseQuote");

          }

          /// Retrieve the current pair's price regardless of whether or not
          /// prices data has previously been retrieved.
          /// Helps with documenting each symbols current (realtime) price
          ///
          // print("");
          // print("obtaining realtime price");


          print("");
          // print("Getting realtime price - 4");
          mapPriceOfCurrentPairResponseRealTime =
            await getRealTimePriceSingle(
                symbol: currentPair,
                country: "US",
                priceDataType: PriceDataType.realtime
            );
          // print("Getting realtime price - 5");

          // print("mapPriceOfCurrentPairResponseRealTime: $mapPriceOfCurrentPairResponseRealTime");


          /// if the current pair's quote has been retrieved, which will only
          /// happen if 'mapLastSavedPricesOneMinInterval' is empty, which in
          /// turn will only happen when all prices data have never been
          /// retrieved, set its current price using
          /// mapPriceOfCurrentPairResponseRealTime and it's old price using
          /// mapPriceOfCurrentPairResponseQuote
          if (mapPriceOfCurrentPairResponseQuote != null){

            Map currentSymbolsPriceDataToSave = {
              "old_price": mapPriceOfCurrentPairResponseQuote['close'],
              "current_price": mapPriceOfCurrentPairResponseRealTime['price'],
              "type": mapInstrumentsType[currentPair]
            };

            mapOfAllPrices[currentPair] = currentSymbolsPriceDataToSave;

            /// including the result in a (previously saved) prices' data map
            /// (mapLastSavedPricesOneMinInterval) if it is not empty i.e if
            /// prices' data have previously been retrieved
            if (mapLastSavedPricesOneMinInterval.isNotEmpty){
              mapLastSavedPricesOneMinInterval[currentPair] =
                  currentSymbolsPriceDataToSave;
            }

            countSavedImportantPairs += 1;

          }
          /// ... else if current pair's quote has not been retrieved, which
          /// will only happen when prices data have previously been retrieved
          /// and saved as reflected in mapLastSavedPricesOneMinInterval,
          /// set the current pair's old price using
          /// mapLastSavedPricesOneMinInterval's 'current_price' value for the
          /// current pair and its current price using
          /// mapPriceOfCurrentPairResponseRealTime's "price" value
          ///
          else if (mapPriceOfCurrentPairResponseQuote == null){

            Map currentSymbolsPriceDataToSave = {
              "old_price": mapLastSavedPricesOneMinInterval[currentPair]!['current_price'],
              "current_price": mapPriceOfCurrentPairResponseRealTime['price'],
              "type": mapInstrumentsType[currentPair]
            };

            mapOfAllPrices[currentPair] = currentSymbolsPriceDataToSave;

            /// including the result in a (previously saved) prices' data map
            /// (mapLastSavedPricesOneMinInterval) if it is not empty i.e if
            /// prices' data have previously been retrieved
            if (mapLastSavedPricesOneMinInterval.isNotEmpty){
              mapLastSavedPricesOneMinInterval[currentPair] =
                  currentSymbolsPriceDataToSave;
            }

            countSavedImportantPairs += 1;

          }

          /// printing the current pair's old and current price map
          // print("${mapOfAllPrices[currentPair]}");

          // mapOfAllPrices[currentPair] = priceOfCurrentPairResponse!["price"];
          // print("${mapOfAllPrices[currentPair]}:${priceOfCurrentPairResponse["price"]}");

          /// saving an updated copy of a previous prices data
          /// (mapLastSavedPricesOneMinInterval), if any
          ///
          /// ensure that this method will not rerun immediately after an
          /// abnormal setState streak. Helps conserve API credits..
          // if (mapLastSavedPricesOneMinInterval.isNotEmpty
          //     && lastUpdateSessionsMapPricesDataKey != null
          //     && lastPricesDataUpdateTimeString != null
          // ){
          //
          //   DateTime now = DateTime.now();
          //
          //   print("error one");
          //   print("now.toString one: ${now.toString()}");
          //   Map<dynamic, dynamic> copyLastUpdateSessionsMap =
          //     {...lastUpdateSessionsMap};
          //
          //   copyLastUpdateSessionsMap[lastUpdateSessionsMapPricesDataKey] = {
          //     now.toString() : mapLastSavedPricesOneMinInterval
          //   };
          //   print("error two");
          //   copyLastUpdateSessionsMap[lastUpdateSessionsMapPricesDataKey].remove(lastPricesDataUpdateTimeString);
          //   copyLastUpdateSessionsMap[lastUpdateSessionsMapPricesDataKey].remove(latestPricesDataUpdateTimeString);
          //   print("error three");
          //
          //   /// updating the last prices' data update time string to its new
          //   /// value..
          //
          //   _dataUpdateSessionsFile!.writeAsString(
          //       json.encode(copyLastUpdateSessionsMap),
          //       mode: FileMode.write
          //   );
          //
          // }

        }
        /// ...otherwise, setting the price to "demo"
        else if (listOfAppliedImportantPairs.contains(currentPair) == false){

          mapOfAllPrices[currentPair] = {
            "old_price": "demo",
            "current_price": "demo",
            "type": mapInstrumentsType[currentPair]
          };

          /// printing the current pair's old and current price map
          // print("${mapOfAllPrices[currentPair]}");

          countSavedUnimportantPairs += 1;

        }


        // if (count == 2) break;

      }

      // print("");
      // print("Total number of saved pairs: $countSavedImportantPairs");
      // print("length of mapOfAllPrices: ${mapOfAllPrices.length}");
      // print("length of savedListOfAllSymbolsDataMaps: ${savedListOfAllSymbolsDataMaps.length}");
      // print("length of setSavedListOfAllSymbols: ${setSavedListOfAllSymbols.length}");
      // print("");


    } catch(error){

      print("ERROR OCCURRED WHILE GETTING PRICE QUOTES AND REAL TIME PRICES");

      /// logging instrument's price fetching error
      DateTime now = DateTime.now();

      _otherErrorsLogFile!.writeAsString(
          "$now: \n"
              "getRealTimePriceAll\n"
              "AN ERROR OCCURRED WHILE FETCHING THIS INSTRUMENT'S PRICE: ${currentPair}!\n"
              "${error.toString()}\n\n",
          mode: FileMode.append
      );

      /// if the error is a connection error (connection cut before or during
      /// data fetching) replace the last data fetching time with the current
      /// time to prevent this method from running again immediately, i.e to
      /// ensure that there's a minute (approx) wait period
      ///
      /// Caveat: if the connection error occurs when this methods is being
      /// executed for the first time, there's no provision to how many times
      /// this method can be fully re-executed. Hence, creating a precedence
      /// for exceeding the API limits
      ///
      /// checking whether prices data has previously been fetched..
      String errorString = error.toString();
      if (
        errorString.contains("Connection reset")
            || errorString.contains("Connection closed")
            || errorString.contains("Failed host lookup")
      ){

        connectionError = true;

        if (lastUpdateSessionsMapPricesDataKey != null){

          /// checking whether a previous prices data update session's time string
          /// exists. It should normally exist if the above key is not null
          if (lastPricesDataUpdateTimeString != null){

            /// replacing the last prices data update session time with the
            /// current time to enforce a 1 minute waiting period for this method
            /// can run again, and reflect the partially fetched prices data -
            /// helps API credits wastage..
            lastUpdateSessionsMap[lastUpdateSessionsMapPricesDataKey][now.toString()] = mapLastSavedPricesOneMinInterval;
            lastUpdateSessionsMap[lastUpdateSessionsMapPricesDataKey].remove(lastPricesDataUpdateTimeString);

            _dataUpdateSessionsFile!.writeAsString(
                json.encode(lastUpdateSessionsMap),
                mode: FileMode.write
            );

          }

        }

      }
      /// if the error is not a connection error, the only reasonable cause
      /// would be the presence of an inaccurate symbols / instruments' map..
      /// Hence, update and save the symbols / instruments' data unconditionally
      /// Note:
      else {

        print("Updating and Saving All Symbols Locally & Unconditionally");

        await updateAndSaveAllSymbolsData(
          unconditionally: true
        );
      }


    }

    // print("Out here!");
    // print("mapLastSavedPricesOneMinInterval: $mapLastSavedPricesOneMinInterval}");
    // print("mapOfAllPrices: $mapOfAllPrices");

    // print("mapOfAllPrices: $mapOfAllPrices");
    // print("mapLastSavedPricesOneMinInterval: $mapLastSavedPricesOneMinInterval");

    print("");
    // print("lengthMapOfAllPrices 2: ${mapOfAllPrices.length}");

    /// re-ordering mapOfAllPrice to ensure that instruments or symbols that
    /// have actual prices will get displayed first when possible..
    ///
    /// This sorting operation will run regardless of whether all instrument
    /// have been included in the map or not
    ///
    /// This code block is placed outside the if-else statement below to ensure
    /// that a sorted prices data map will be returned when all important
    /// prices have been fetched successfully..
    List<MapEntry> listOfMapEntryAllRetrievedPrices = [];
    int countRetrievedImportantPairs = 0;

    mapOfAllPrices.forEach((symbol, priceData) {

      dynamic oldPrice = priceData['old_price'];
      dynamic currentPrice = priceData['current_price'];

      try {

        /// if the current price convert to a double, i.e the price of the
        /// current symbol has been retrieved, which should be all the current
        /// contents of mapOfAllPrices, place it in front of all other symbols
        /// in listOfMapEntryAllRetrievedPrices..
        /// ...ensures that symbols with prices get displayed first
        oldPrice = double.parse(oldPrice);
        currentPrice = double.parse(currentPrice);

        MapEntry mapEntryCurrentInstrument = MapEntry(symbol, {
          "old_price": oldPrice.toString(),
          "current_price": currentPrice.toString(),
          "type": mapInstrumentsType[currentPair]
        });

        listOfMapEntryAllRetrievedPrices.insert(0, mapEntryCurrentInstrument);

        /// Counting the number of important pairs whose prices have been
        /// retrieved..
        countRetrievedImportantPairs += 1;

      } catch(error){

        /// ... otherwise place it at the end of the listOfMapEntryAllRetrievedPrices to
        /// ensure that symbols with "demo" get displayed last
        MapEntry mapEntryCurrentInstrument = MapEntry(symbol, {
          "old_price": oldPrice,
          "current_price": currentPrice,
          "type": mapInstrumentsType[currentPair]
        });

        listOfMapEntryAllRetrievedPrices.add(mapEntryCurrentInstrument);

      }

    });

    // print("");
    // print("lengthMapOfAllPrices 3: ${mapOfAllPrices.length}");
    // print("");
    // print("countSavedImportantPairs: $countSavedImportantPairs");
    // print('countSavedUnimportantPairs: $countSavedUnimportantPairs');


    /// if there's been an incomplete price data mapping, print a notification
    /// message, otherwise save the map locally
    ///
    /// Note: The if-statement below will run if the above try-catch block
    /// returns an error, since it does so always before the try block gets to
    /// to fill up mapOfAllPrices with all symbols in
    /// setSavedListOfAllSymbols
    if (mapOfAllPrices.length < setSavedListOfAllSymbols.length){

      /// if up to 6 important symbols' or instruments' prices have been
      /// retrieved, map out all instruments and display the important symbols
      /// or instruments whose prices have been retrieved first followed by
      /// other important instruments whose prices have not been retrieved
      int lengthOfMapOfAllPrices = mapOfAllPrices.length;

      int countRefreshInOneMin = 0;

      /// manually constructed map of instruments' prices to be returned when
      /// relevant..
      Map<dynamic, dynamic> mapEntryAllRetrievedPrices = {};


      if (countSavedImportantPairs >= 6){

        /// list of retrieved (prices) and mapped instruments ..
        List allRetrievedSymbolsOrInstrumentsKey =  mapOfAllPrices.keys.toList();

        // print("lengthListOfAppliedImportantPairs: $listOfAppliedImportantPairs");

        for (var symbol in setSavedListOfAllSymbols){

          MapEntry? mapEntryCurrentInstrument;

          // List<MapEntry> listOfMapEntryAllRetrievedPricesCopy =
          //   [...listOfMapEntryAllRetrievedPrices];

          /// if the instrument is an important one i.e it should be displayed
          /// but it's price was not retrieved, notify the user that it's price
          /// will be available after the next retrieval process if it
          /// does not already exist within mapLastSavedPricesOneMinInterval -
          /// a map of previously retrieved prices' data..
          print("");
          // print("listOfAppliedImportantPairs: $listOfAppliedImportantPairs");
          // print("allRetrievedSymbolsOrInstrumentsKey: $allRetrievedSymbolsOrInstrumentsKey");
          // print("lengthMapofAllPrices: ${mapOfAllPrices.length}");

          // print("isSymbolImportant: ${listOfAppliedImportantPairs.contains(symbol)}, isSymbolInMapOfAllPrices: ${allRetrievedSymbolsOrInstrumentsKey.contains(symbol)}");
          if (
            listOfAppliedImportantPairs.contains(symbol)
            && !allRetrievedSymbolsOrInstrumentsKey.contains(symbol)
          ){

            countRefreshInOneMin += 1;



            // if (mapLastSavedPricesOneMinInterval.containsKey(symbol)){

              // /// ensuring that the previous price data of the current symbol
              // /// is included where the current session fails to fetch only
              // /// 6 (prices' data) of all the important pairs'..
              // mapEntryCurrentInstrument = MapEntry(symbol, {
              //   "old_price": mapLastSavedPricesOneMinInterval[symbol]["old_price"],
              //   "current_price": mapLastSavedPricesOneMinInterval[symbol]["current_price"],
              //               "type": mapInstrumentsType[currentPair]
              // });
              //
              // listOfMapEntryAllRetrievedPrices.insert(
              //     countRetrievedImportantPairs - 1, mapEntryCurrentInstrument
              // );

            // }
            // else{

              // print("");
              // print('here! Refresh - 1 min');

              mapEntryCurrentInstrument = MapEntry(symbol, {
                "old_price": "Refresh - 1 min",
                "current_price": "Refresh - 1 min",
                "type": mapInstrumentsType[currentPair]
              });

              /// placing all non retrieved important pairs just after the
              /// retrieved important pairs
              listOfMapEntryAllRetrievedPrices.insert(
                  countRetrievedImportantPairs, mapEntryCurrentInstrument
              );

              // print("map entry: refresh 1 min: $mapEntryCurrentInstrument");


            // }

          }

          /// if the current symbol or instrument is not an important one i.e
          /// should not be displayed first, add it the the end of the list of
          /// all instruments-prices map entry list (listOfMapEntryAllRetrievedPrices)
          else if (!listOfAppliedImportantPairs.contains(symbol)
              && !allRetrievedSymbolsOrInstrumentsKey.contains(symbol)){

            // print("Unimportant Pair - Unsaved - Start");

            mapEntryCurrentInstrument = MapEntry(symbol, {
              "old_price": "demo",
              "current_price": "demo",
              "type": mapInstrumentsType[currentPair]
            });
            
            listOfMapEntryAllRetrievedPrices.add(mapEntryCurrentInstrument);

            // print("Unimportant Pair - Unsaved - End");
            
          }

        }

        // print("Out here - isMapLastSavedPricesOneMinIntervalEmpty");
        // print("isMapLastSavedPricesOneMinIntervalEmpty: ${mapLastSavedPricesOneMinInterval.isEmpty}");

        /// saving an updated copy of a previous prices data
        /// (mapLastSavedPricesOneMinInterval), if any
        if (mapLastSavedPricesOneMinInterval.isNotEmpty
            && lastUpdateSessionsMapPricesDataKey != null
            && lastPricesDataUpdateTimeString != null
        ){

          DateTime now = DateTime.now();

          lastUpdateSessionsMap[lastUpdateSessionsMapPricesDataKey][now.toString()] = mapLastSavedPricesOneMinInterval;
          lastUpdateSessionsMap[lastUpdateSessionsMapPricesDataKey].remove(lastPricesDataUpdateTimeString);

          _dataUpdateSessionsFile!.writeAsString(
              json.encode(lastUpdateSessionsMap),
              mode: FileMode.write
          );

        }

        /// if a previous prices' data map exists, return its updated version
        if (mapLastSavedPricesOneMinInterval.isNotEmpty){
          mapEntryAllRetrievedPrices = mapLastSavedPricesOneMinInterval;
        }
        /// ... otherwise return a map of prices' data that lets the user
        /// know that some important pairs' prices were not retrieved but
        /// will be retrieved when this method run again..
        else{

          /// converting listOfMapEntryAllRetrievedPrices from a List<MapEntry> to
          /// Iterable<MapEntry>
          ///
          /// At this point, all instruments' data (prices preferred) should
          /// have been included in listOfMapEntryAllRetrievedPrices

          // print("IN ITERABLE CONVERSION");
          Iterable<MapEntry<dynamic, dynamic>> listOfMapEntryAllRetrievedPricesIterable = Iterable.castFrom(
              listOfMapEntryAllRetrievedPrices
          );

          // print("listOfMapEntryAllRetrievedPricesIterableIn: $listOfMapEntryAllRetrievedPricesIterable");
          // print("next");
          // print("Map.fromIterableIn: ${Map.fromIterable(
          //     listOfMapEntryAllRetrievedPricesIterable
          // )}");

          try{

            /// converting the entries (iterable) to a map
            mapEntryAllRetrievedPrices = Map.fromEntries(
                listOfMapEntryAllRetrievedPricesIterable
            );

            // print("mapEntryAllRetrievedPricesIn: $mapEntryAllRetrievedPrices");

          } catch(error){

            DateTime now = DateTime.now();

            _otherErrorsLogFile!.writeAsString(
              "$now\n"
              "AN ERROR OCCURED WHILE CONVERTING ITERABLE<MAPENTRY> TO MAP:\n"
                  "$error\n",
              mode: FileMode.append
            );
          }


        }

      }

      // print("mapOfAllPrices is lesser than savedListOfAllSymbolsDataMaps");
      print("✔");
      // print("listOfMapEntryAllRetrievedPrices: $listOfMapEntryAllRetrievedPrices");
      // print("countRefreshInOneMin: $countRefreshInOneMin");


      print("mapEntryAllRetrievedPrices: $mapEntryAllRetrievedPrices");

      /// updateAndSaveAllSymbolsData();
      return mapEntryAllRetrievedPrices;

    }
    /// will be executed when:
    /// a. all prices' data have been retrieved
    /// b. no price data has been retrieved and no previous prices' data exists,
    ///    since length zero cannot be lesser than length of zero. i.e the
    ///    length of mapOfAllPrices cannot be lesser than the length of
    ///    setSavedListOfAllSymbols when both objects have a size of zero
    else {

      print("");
      print("It's a match. Prices update completed!");
      print("");

      /// converting listOfMapEntryAllRetrievedPrices from a List<MapEntry> to
      /// Iterable<MapEntry>
      ///
      /// At this point, all instruments' data (prices preferred) should
      /// have been included in listOfMapEntryAllRetrievedPrices
      Iterable<MapEntry> listOfMapEntryAllRetrievedPricesIterable = Iterable.castFrom(
          listOfMapEntryAllRetrievedPrices
      );

      // print("listOfMapEntryAllRetrievedPricesIterable: $listOfMapEntryAllRetrievedPricesIterable");

      /// converting the entries (iterable) to a map
      Map<dynamic,dynamic> finalMapAllInstrumentsPrices = Map.fromEntries(
          listOfMapEntryAllRetrievedPricesIterable
      );

      // print("finalMapAllInstrumentsPrices: ${finalMapAllInstrumentsPrices}");


      /// LOGGING THIS PRICES UPDATE SESSION TIME
      DateTime now =  DateTime.now();
      print("currentPricesDataUpdateTimeString: $now");

      /// if no prices data have previously been retrieved or saved, save the
      /// latest prices data as the initial..
      if (
        !lastUpdateSessionsMap.containsKey('last_prices_data_update_time_initial')
          && !lastUpdateSessionsMap.containsKey('last_prices_data_update_time')
          && finalMapAllInstrumentsPrices.isNotEmpty
      ){

        lastUpdateSessionsMap["last_prices_data_update_time_initial"] = {
          now.toString() : finalMapAllInstrumentsPrices
        };

      }
      /// ... else if prices data have previously been retrieved or saved once,
      /// initially or more than once, save the latest prices data as post initial
      /// prices data, and remove the initial prices data, if any,
      /// to free up file space..
      else if (
        (
            lastUpdateSessionsMap.containsKey('last_prices_data_update_time_initial')
            || lastUpdateSessionsMap.containsKey('last_prices_data_update_time')
        ) 
            && finalMapAllInstrumentsPrices.isNotEmpty
      ){

        lastUpdateSessionsMap["last_prices_data_update_time"] = {
          now.toString() : finalMapAllInstrumentsPrices
        };

        /// removing the initial prices data, if any, to free up file space..
        /// This code is best placed here to ensure that an initial prices data
        /// map will only be removed if all instruments' prices have been
        /// fetched and mapped successfully...
        if (
          lastUpdateSessionsMap.containsKey("last_prices_data_update_time_initial") 
              && finalMapAllInstrumentsPrices.isNotEmpty
        ) {

          lastUpdateSessionsMap.remove("last_prices_data_update_time_initial");

        }

      }

      _dataUpdateSessionsFile!.writeAsString(
          json.encode(lastUpdateSessionsMap),
          mode: FileMode.write
      );

      print("GETREALTIMEPRICEALL METHOD - END");
      print("");
      print("--------------------------------------------------------------------------------");
      print("");

      /// 1. if there's been a connection error and no prices data have been
      ///    retrieved, if there's a previous prices' data map, serve it..
      ///
      /// 2. if there's been a connection error and no prices data have been
      ///    retrieved, if there's no previous prices' data map, return an empty
      ///    map
      ///
      /// 3. if all symbols' price data have been fetched, serve it i.e if:
      ///    a. finalMapAllInstrumentsPrices is not empty at this point
      ///       which is the same as:
      ///       mapOfAllPrices.length == setSavedListOfAllSymbols.length
      ///
      /// 4. if there's any other kind of error, return an empty list
      if (
          connectionError == true
          && mapOfAllPrices.isEmpty
          && mapLastSavedPricesOneMinInterval.isNotEmpty
      ){

        return mapLastSavedPricesOneMinInterval;

      }
      else if (
          connectionError == true
          && mapOfAllPrices.isEmpty
          && mapLastSavedPricesOneMinInterval.isEmpty
      ){

        return {};

      } else if (mapOfAllPrices.length == setSavedListOfAllSymbols.length){

        print("Timer.periodic - data - complete: ${DateTime.now()}");
        return finalMapAllInstrumentsPrices;

      } else{

        return finalMapAllInstrumentsPrices;

      }

    }

  }

}
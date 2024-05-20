import 'dart:convert';
import 'dart:io';

// import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;
// import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";

import "data_type.dart";


enum PriceDataType{
  realtime,
  quote
}

class Data {

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
  Future updateAndSaveAllSymbolsData() async {

    /// saving the update session's time to 'data update sessions' log file
    String lastUpdateTime = DateTime.now().toString();

    /// update sessions file
    var updateSessions = json.decode(await _dataUpdateSessionsFile!.readAsString());
    dynamic lastSymbolsDataUpdateTime = updateSessions["last_symbols_data_update_time"];
    dynamic lastSymbolsDataUpdateErrorTime = updateSessions["last_symbols_data_update_error_time"];


    /// checking whether the last symbols' data updated over 24 hrs ago.
    /// 1. If not, task will be cancelled..
    /// 2. If no previous symbols' data update session exists, this task will
    /// continue..
    if (lastSymbolsDataUpdateTime != null){

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

      print("lastSymbolsDataUpdateTime: $lastSymbolsDataUpdateTime, "
          "lastSymbolsDataUpdateErrorTime: $lastSymbolsDataUpdateErrorTime");

      print("isLastSymbolsDataUpdateTimeEqualToLastSymbolsDataUpdateErrorTime: $isLastSymbolsDataUpdateTimeEqualToLastSymbolsDataUpdateErrorTime");

      /// determining whether to proceed with the symbols' data update..
      /// if all symbols were updated within the last 24 hours and there was
      /// no update error, cancel the current session
      if (
        diffLastSymbolsDataUpdateTimeInHours < 24
            && isLastSymbolsDataUpdateTimeEqualToLastSymbolsDataUpdateErrorTime == false
      ){
        print("Can't update symbols data now! Last update session is lesser than 24hrs ago..");
        return {};
      }

    }

    // print("aDay - lastSymbolsDataUpdateTime: ${aDay.}")
    // if (lastSymbolsDataUpdateTime )

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
    print("List of all Data");
    print("________________");
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
    print("Total number of symbols: $count");
    print("");

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

      print("");
      print("response: ${resolvedResponse}}");
      print("");

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


  /// This method obtains the prices of all saved instruments (symbols)
  Future<Map<dynamic,dynamic>> getRealTimePriceAll() async{

    /// last update sessions data -> both time and prices
    Map<String, dynamic> lastUpdateSessionsMap =
    json.decode(await _dataUpdateSessionsFile!.readAsString());

    /// instruments' prices (map)
    Map<String, dynamic> mapOfAllPrices = {};

    /// current symbol / pair
    String? currentPair;

    /// list of all important pairs
    List<String> listOfAllTwentySevenImportantPairs =
        _listOfImportantForexPairs + _listOfImportantCryptoPairs;

    /// all instruments / symbols' data -> forex & crypto inclusive
    List<dynamic> savedListOfAllSymbolsDataMaps = [{}];

    /// mapping out instruments and their prices
    savedListOfAllSymbolsDataMaps = await getAllSymbolsLocalData();
    /// Set of the above to remove duplicate symbols
    Set<String> savedListOfAllSymbolsDataMapsSet = {};

    for (var symbolData in savedListOfAllSymbolsDataMaps){
      String symbol = symbolData['symbol'];

      savedListOfAllSymbolsDataMapsSet.add(symbol);
    }

    /// A map of previously retrieved prices... if any
    Map<String, Map<String, String>> mapLastSavedPricesOneMinInterval = {};

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

        String? lastPricesDataUpdateTimeString;

        /// if there's been more than one forex and crypto prices updates and
        /// local storage, set lastPricesDataUpdateTimeString to
        /// last_prices_data_update_time's map key..
        if (lastUpdateSessionsMap.containsKey("last_prices_data_update_time")){

          /// last prices data update time
          lastPricesDataUpdateTimeString =
          lastUpdateSessionsMap["last_prices_data_update_time"]!.keys[0];

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

          /// last prices data update time
          lastPricesDataUpdateTimeString =
          lastUpdateSessionsMap["last_prices_data_update_time_initial"]!.keys[0];

          /// latest prices of all forex and crypto pairs...
          mapLastSavedPricesOneMinInterval =
          lastUpdateSessionsMap
          ["last_prices_data_update_time_initial"][lastPricesDataUpdateTimeString];

        }

        DateTime lastPricesDataUpdateTime =
        DateTime.parse(lastPricesDataUpdateTimeString!);

        DateTime now = DateTime.now();

        int diffLastPricesDataUpdateTimeInMinutes =
            now.difference(lastPricesDataUpdateTime).inMinutes;
        // print("lastPricesDataUpdateTime: $lastSymbolsDataUpdateTime");
        // print("now - lastSymbolsDataUpdateTime: ${now.difference(lastSymbolsDataUpdateTime).inHours}");

        /// determining whether to proceed with the prices' data update..
        if (diffLastPricesDataUpdateTimeInMinutes < 1){
          print("Can't update symbols data now! Last update session is lesser than 1 minute ago..");
          return {};
        }

      }

      // checkIfImportantPairsInSavedPairs(
      //   listOfImportantPairs: listOfAllTwentySevenImportantPairs,
      //   listOfSavedPairs: savedListOfAllSymbolsDataMaps
      // );

      /// obtaining each pair's price, especially the most important ones
      /// i.e the most traded ones..
      int countSavedPairs = 0;

      for (var symbol in savedListOfAllSymbolsDataMapsSet){

        currentPair = symbol;

        // print(symbolData);

        /// retrieving price from data provider if pair is important or
        /// popularly traded
        if (listOfAllTwentySevenImportantPairs.contains(currentPair)){

          var mapPriceOfCurrentPairResponseQuote;
          var mapPriceOfCurrentPairResponseRealTime;

          /// if prices data has not previously been retrieved or by inference,
          /// the current (important) pair's price (old and current) has not
          /// previously been documented, request for the current pair's
          /// "quote", which contains the previous minute's opening price..
          ///
          /// Helps with documenting and noting whether the current realtime
          /// price of each pair is an upward or downward price movement,
          /// when compared with the previous minute's closing price provided
          /// by mapPriceOfCurrentPairResponseQuote..
          if (mapLastSavedPricesOneMinInterval.isEmpty){

            print("");
            print("obtaining quote");

            mapPriceOfCurrentPairResponseQuote = await getRealTimePriceSingle(
                symbol: currentPair!,
                country: "US",
                priceDataType: PriceDataType.quote
            );

            print("mapPriceOfCurrentPairResponseQuote: $mapPriceOfCurrentPairResponseQuote");



          }

          /// Retrieve the current pair's price regardless of whether or not
          /// prices data has previously been retrieved.
          /// Helps with documenting each symbols current (realtime) price
          ///
          print("");
          print("obtaining realtime price");

          mapPriceOfCurrentPairResponseRealTime =
            await getRealTimePriceSingle(
                symbol: currentPair!,
                country: "US",
                priceDataType: PriceDataType.realtime
            );

          print("mapPriceOfCurrentPairResponseRealTime: $mapPriceOfCurrentPairResponseRealTime");


          /// if the current pair's quote has been retrieved, which will only
          /// happen if 'mapLastSavedPricesOneMinInterval' is empty, which in
          /// turn will only happen when all prices data have never been
          /// retrieved, set its current price using
          /// mapPriceOfCurrentPairResponseRealTime and it's old price using
          /// mapPriceOfCurrentPairResponseQuote
          if (mapPriceOfCurrentPairResponseQuote != null){

            mapOfAllPrices[currentPair] = {
              "old_price": mapPriceOfCurrentPairResponseQuote['close'],
              "current_price": mapPriceOfCurrentPairResponseRealTime['price']
            };

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

            mapOfAllPrices[currentPair] = {
              "old_price": mapLastSavedPricesOneMinInterval[currentPair]!['current_price'],
              "current_price": mapPriceOfCurrentPairResponseRealTime['price']
            };

          }

          countSavedPairs += 1;
          /// printing the current pair's old and current price map
          print("${mapOfAllPrices[currentPair]}");

          // mapOfAllPrices[currentPair] = priceOfCurrentPairResponse!["price"];
          // print("${mapOfAllPrices[currentPair]}:${priceOfCurrentPairResponse["price"]}");

        }
        /// ...otherwise, setting the price to "No (Demo) Price"
        else if (!listOfAllTwentySevenImportantPairs.contains(currentPair)){

          mapOfAllPrices[currentPair!] = {
            "old_price": "No (Demo) Price",
            "current_price": "No (Demo) Price"
          };

          countSavedPairs += 1;
          /// printing the current pair's old and current price map
          print("${mapOfAllPrices[currentPair]}");

        }


        // if (count == 2) break;
      }

      print("");
      print("Total number of saved pairs: $countSavedPairs");
      print("length of mapOfAllPrices: ${mapOfAllPrices.length}");
      print("length of savedListOfAllSymbolsDataMaps: ${savedListOfAllSymbolsDataMaps.length}");
      print("");
      // print(mapOfAllPrices);


    } catch(error){

      print("ERROR OCCURED WHILE GETTING PRICE QUOTES AND REAL TIME PRICES");

      /// logging instrument's price fetching error
      DateTime now = DateTime.now();

      _otherErrorsLogFile!.writeAsString(
          "$now: \n"
              "getRealTimePriceAll\n"
              "AN ERROR OCCURRED WHILE FETCHING THIS INSTRUMENT'S PRICE: ${currentPair}!\n"
              "${error.toString()}\n\n",
          mode: FileMode.append
      );

    }

    print("Out here!");
    print("mapLastSavedPricesOneMinInterval: $mapLastSavedPricesOneMinInterval}");
    // print("mapOfAllPrices: $mapOfAllPrices");


    /// if there's been an incomplete price data mapping, print a notification
    /// message, otherwise save the map locally

    if (mapOfAllPrices.length < savedListOfAllSymbolsDataMapsSet.length){
      print("mapOfAllPrices is lesser than savedListOfAllSymbolsDataMaps");
      /// updateAndSaveAllSymbolsData();

      print("");
      // print(mapOfAllPrices.keys.toList().join(", "));
      // print("savedListOfAllSymbolsDataMaps[0]: ${savedListOfAllSymbolsDataMaps[0]}");
      //
      // int count = 0;
      // String symbols = "";
      // for (var symbol in savedListOfAllSymbolsDataMapsSet){
      //
      //   String currentSymbol = symbol;
      //
      //   if (!listOfAllTwentySevenImportantPairs.contains(currentSymbol)){
      //
      //     List mKeys = mapOfAllPrices.keys.toList();
      //     String mCurrentKey = mKeys[count];
      //
      //     // print("${currentSymbol.runtimeType} == ${mCurrentKey.runtimeType}");
      //     print("${currentSymbol.runtimeType} == ${mCurrentKey.runtimeType}, $currentSymbol == $mCurrentKey: ${currentSymbol == mCurrentKey}");
      //
      //     if (currentSymbol != mCurrentKey){
      //       break;
      //     }
      //
      //     count += 1;
      //
      //   }
      //
      // }
      //
      // print(symbols);

    }
    else {

      print("It's a match");

      /// LOGGING THIS PRICES UPDATE SESSION TIME
      DateTime now =  DateTime.now();

      /// if no prices data have previously been retrieved or saved, save the
      /// latest prices data as the initial..
      if (
      !lastUpdateSessionsMap.containsKey('last_prices_data_update_time_initial')
          && !lastUpdateSessionsMap.containsKey('last_prices_data_update_time')
      ){

        lastUpdateSessionsMap["last_prices_data_update_time_initial"] = {
          now.toString() : mapOfAllPrices
        };

      }
      /// ... else if prices data have previously been retrieved or saved once,
      /// initially or more than once, save the latest prices data as post initial
      /// prices data, and remove the initial prices data, if any,
      /// to free up file space..
      else if (
      lastUpdateSessionsMap.containsKey('last_prices_data_update_time_initial')
          || lastUpdateSessionsMap.containsKey('last_prices_data_update_time')
      ){

        lastUpdateSessionsMap["last_prices_data_update_time"] = {
          now.toString() : mapOfAllPrices
        };

        /// removing the initial prices data, if any, to free up file space..
        if (
        lastUpdateSessionsMap.containsKey("last_prices_data_update_time_initial")
        ) {

          lastUpdateSessionsMap.remove("last_prices_data_update_time_initial");

        }

      }

      _dataUpdateSessionsFile!.writeAsString(
          json.encode(lastUpdateSessionsMap),
          mode: FileMode.write
      );

    }

    return mapOfAllPrices;

  }

}
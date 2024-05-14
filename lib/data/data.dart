import 'dart:convert';
import 'dart:io';

// import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;
// import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";

import "data_type.dart";


class Data {

  final List<Map<dynamic, dynamic>> _listOfAllSymbolsDataMaps = [];

  final String apiKey =  dotenv.env["API_KEY"]!;

  Directory? _appDir;
  String? _appDirPath;
  final String _dataFolderName = dotenv.env["DATA_FOLDER_NAME"]!;
  final String _allSymbolsDataFileName = dotenv.env["DATA_FILE_NAME"]!;
  final String _logFolderName = dotenv.env["LOG_FOLDER_NAME"]!;
  final String _dataFetchingErrorLogFileName = dotenv.env["DATA_FETCHING_ERROR_LOG_FILE_NAME"]!;
  final String _dataUpdateSessionsFileName = dotenv.env["DATA_UPDATE_SESSIONS_FILE_NAME"]!;
  final String _otherErrorsLogFileName = dotenv.env["OTHER_ERRORS_LOG_FILE_NAME"]!;
  final String _urlRealTimePrice = dotenv.env["URL_REAL_TIME_PRICE"]!;

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

    try{

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

    } catch(error){

      DateTime dateTime = DateTime.now();

      print("_dataFetchingErrorLogFile: $_dataFetchingErrorLogFile");
      _dataFetchingErrorLogFile!.writeAsString(""
          "$dateTime: \n"
          "_updateAllForexSymbolsData\n"
          "AN ERROR OCCURRED WHILE FETCHING FOREX SYMBOLS!\n"
          "${error.toString()}\n\n",
          mode: FileMode.append
      );

    }

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

    try{

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


    }catch(error){

      DateTime dateTime = DateTime.now();

      print("_dataFetchingErrorLogFile: $_dataFetchingErrorLogFile");
      _dataFetchingErrorLogFile!.writeAsString(""
          "$dateTime: \n"
          "_updateAllCryptoSymbolsData\n"
          "AN ERROR OCCURRED WHILE FETCHING CRYPTO SYMBOLS' DATA!\n"
          "${error.toString()}\n\n",
          mode: FileMode.append
      );

    }


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

    /// update sessions file
    var updateSessions = json.decode(await _dataUpdateSessionsFile!.readAsString());
    dynamic lastSymbolsDataUpdateTime = updateSessions["last_symbols_data_update_time"];

    /// checking whether the last symbols' data update session is greater than
    /// 24 hrs.
    /// 1. If not, task will be cancelled..
    /// 2. If no previous symbols' data update session exists, this task will
    /// continue..
    if (lastSymbolsDataUpdateTime != null){

      lastSymbolsDataUpdateTime = DateTime.parse(lastSymbolsDataUpdateTime);

      DateTime now = DateTime.now();

      int diffLastSymbolsDataUpdateTimeInHours = now.difference(lastSymbolsDataUpdateTime).inHours;
      // print("lastSymbolsDataUpdateTime: $lastSymbolsDataUpdateTime");
      // print("now - lastSymbolsDataUpdateTime: ${now.difference(lastSymbolsDataUpdateTime).inHours}");

      /// determining whether to proceed with the symbols' data update..
      if (diffLastSymbolsDataUpdateTimeInHours < 24){
        print("Can't update symbols data now! Last update session was less than 24hrs ago..");
        return;
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

      /// saving the update session's time to 'data update sessions' log file
      DateTime now = DateTime.now();

      var updateSessions = json.decode(await _dataUpdateSessionsFile!.readAsString());
      updateSessions["last_symbols_data_update_time"] = now.toString();

      print("updateSessions: $updateSessions");

      _dataUpdateSessionsFile!.writeAsString(json.encode(updateSessions));

      print("Data Update Complete!");

    } catch(error){

      /// logging symbols' data update error
      DateTime now = DateTime.now();

      _otherErrorsLogFile!.writeAsString(
          "$now: \n"
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

    dynamic savedlistOfAllSymbolsDataMaps = await _allSymbolsDataFile!.readAsString();
    savedlistOfAllSymbolsDataMaps = json.decode(savedlistOfAllSymbolsDataMaps);

    // for (var symbol in savedlistOfAllSymbolsDataMaps){
    //   print(symbol);
    // }
    count = savedlistOfAllSymbolsDataMaps.length; // 5846


    return savedlistOfAllSymbolsDataMaps;

  }

  /// This method prints the app's directory uri
  void getUriAppDirectory(){
    
    print("This app's directory: ${_appDir!.uri}");
    
  }

  /// This method retrieves a symbol(s)'s realtime price
  Future<Map<String, String>> getRealTimePriceSingle({
    required String symbol,
    required String country
  }) async{

    Map<String, String> aMapPriceOfCurrentSymbol = {};

    try{

      dynamic urlRealTimePrice = _urlRealTimePrice;
      urlRealTimePrice = urlRealTimePrice.replaceFirst("/", " ");

      /// replacing unnecessary symbols
      urlRealTimePrice = urlRealTimePrice.replaceFirst("{abc}", symbol);
      urlRealTimePrice = urlRealTimePrice.replaceFirst("{xyz}", country);
      urlRealTimePrice = urlRealTimePrice.replaceFirst("?", "&");
      urlRealTimePrice = urlRealTimePrice + apiKey;

      urlRealTimePrice = urlRealTimePrice.split(" ");

      List<String> urlPathAndParameters = urlRealTimePrice[1].split("&");

      /// defining urlAuthority, urlPath, & urlParameters - for http.get() module
      String urlAuthority = urlRealTimePrice[0];
      String urlPath = urlPathAndParameters[0];
      Map<String, String> urlParameters = {};

      /// urlParameters
      for (String parameter in urlPathAndParameters.sublist(1)){
        List<String> paramAndParamValue = parameter.split("=");
        String paramKey = paramAndParamValue[0];
        String paramValue = paramAndParamValue[1];
        urlParameters[paramKey] = paramValue;
      }

      print("urlRealTimePrice: $urlRealTimePrice");
      print("urlAuthority: $urlAuthority");
      print("urlParameters: $urlParameters");

      /// sending a request
      Uri uriUrlRealTimePrice = Uri.https(urlAuthority, urlPath, urlParameters);

      http.Response response = await http.get(uriUrlRealTimePrice);
      Map<String, String> resolvedResponse = json.decode(response.body);
      print("response: $response}");

      aMapPriceOfCurrentSymbol = {symbol: resolvedResponse["price"]!};

      // List<dynamic> resolvedResponse = json.decode(response.body);
      //
      // for (var i in resolvedResponse){
      //   print("i: $i");
      // }

    } catch(error){

      /// logging symbols' data update error
      DateTime now = DateTime.now();

      _otherErrorsLogFile!.writeAsString(
          "$now: \n"
              "getRealTimePriceSingle\n"
              "AN ERROR OCCURRED WHILE FETCHING THIS INSTRUMENT'S PRICE: ${symbol}!\n"
              "${error.toString()}\n\n",
          mode: FileMode.append
      );

    }

    return aMapPriceOfCurrentSymbol;

  }

  /// This method obtains the prices of all saved instruments (symbols)
  Future<Map<dynamic,dynamic>> getRealTimePriceAll() async{

    /// current symbol
    String? currentSymbol;

    /// instruments' prices (map)
    var mapOfAllRealtimePrices = {};

    try{

      /// all instruments / symbols' data -> forex & crypto inclusive
      List<dynamic> savedlistOfAllSymbolsDataMaps = [{}];

      /// mapping out instruments and their prices
      savedlistOfAllSymbolsDataMaps = await getAllSymbolsLocalData();

      int count = 0;
      for (var symbolData in savedlistOfAllSymbolsDataMaps){

        currentSymbol = symbolData["symbol"];

        print(symbolData);

        var priceOfCurrentSymbol = await getRealTimePriceSingle(
            symbol: currentSymbol!,
            country: "US"
        );
        //
        // mapOfAllRealtimePrices[currentSymbol] = priceOfCurrentSymbol["price"]!;
        //
        count += 1;
        if (count == 2) break;
      }

      print(mapOfAllRealtimePrices);

    } catch(error){

      /// logging instrument's price fetching error
      DateTime now = DateTime.now();

      _otherErrorsLogFile!.writeAsString(
          "$now: \n"
              "getRealTimePriceAll\n"
              "AN ERROR OCCURRED WHILE FETCHING THIS INSTRUMENT'S PRICE: ${currentSymbol!}!\n"
              "${error.toString()}\n\n",
          mode: FileMode.append
      );

    }

    return mapOfAllRealtimePrices;

  }

}
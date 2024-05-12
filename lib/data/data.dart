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

  Data({
    required this.apiKey
  });

  final String apiKey;
  final List<Map<dynamic, dynamic>> _listOfAllSymbolsDataMaps = [];

  Directory? _appDir;
  String? _appDirPath;
  final String _dataFolderName = dotenv.env["DATA_FOLDER_NAME"]!;
  final String _allSymbolsDataFileName = dotenv.env["DATA_FILE_NAME"]!;
  final String _logFolderName = dotenv.env["LOG_FOLDER_NAME"]!;
  final String _dataFetchingErrorLogFileName = dotenv.env["DATA_FETCHING_ERROR_LOG_FILE_NAME"]!;
  final String _dataUpdateSessionsFileName = dotenv.env["DATA_UPDATE_SESSIONS_FILE_NAME"]!;
  final String _otherErrorsLogFileName = dotenv.env["OTHER_ERRORS_LOG_FILE_NAME"]!;

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
    
    File dataUpdateSessionsFileName = File(
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

    /// if data file and error log file do not exist, create them.
    if (isAllSymbolsDataFile == false){
      await allSymbolsDataFile.create(recursive: true);
    }

    if (isDataFetchingErrorLogfile == false){
      await dataFetchingErrorLogfile.create(recursive: true);
    }

    /// setting the symbols data and data fetching error (File) objects
    _allSymbolsDataFile = allSymbolsDataFile;
    _dataFetchingErrorLogFile = dataFetchingErrorLogfile;
    _dataUpdateSessionsFile = dataUpdateSessionsFileName;
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
          "AN ERROR OCCURRED WHILE FETCHING BOND SYMBOLS' DATA!\n"
          "${error.toString()}\n\n",
        mode: FileMode.append
      );

    }

  }

  /// This method updates and saves all financial data to this app's directory
  /// Cost: 6 API credits per day -> 180 API credits per month
  Future updateAndSaveAllSymbolsData() async {

    try{

      print("Updating All Data..");

      /// updating all financial data
      await _updateAllForexSymbolsData();
      await _updateAllStockSymbolsData();
      await _updateAllCryptoSymbolsData();
      await _updateAllETFSymbolsData();
      await _updateAllIndexSymbolsData();
      await _updateAllFundSymbolsData();
      await _updateAllBondSymbolsData();

      /// saving the financial data to all data
      String allSymbolsData = jsonEncode(_listOfAllSymbolsDataMaps);
      _allSymbolsDataFile!.writeAsString(
          allSymbolsData,
          mode: FileMode.write
      );

      DateTime now = DateTime.now();
      Map dataUpdatesInfoMap = {
        "last_symbols_update_time": now.toString()
      };
      _dataUpdateSessionsFile!.writeAsString(json.encode(dataUpdatesInfoMap));

      print("Data Update Complete!");

    } catch(error){

      DateTime now = DateTime.now();

      _otherErrorsLogFile!.writeAsString(
          "$now: \n"
              "AN ERROR OCCURRED WHILE UPDATING AND SAVING ALL SYMBOLS' DATA!\n"
              "${error.toString()}\n\n",
          mode: FileMode.append
      );

    }



  }

  Future<List<dynamic>> getAllSymbolsData() async{

    print("");
    print("List of all Data");
    print("________________");
    print("");

    int notIsCountry = 0;
    
    dynamic savedlistOfAllSymbolsDataMaps = await _allSymbolsDataFile!.readAsString();
    savedlistOfAllSymbolsDataMaps = json.decode(savedlistOfAllSymbolsDataMaps);

    // for (Map data in savedlistOfAllSymbolsDataMaps){
    //   print(data);
    //
    //   // if (!data.keys.contains("country")){
    //   //   notIsCountry += 1;
    //   //
    //   //   print("");
    //   //   print('notIsCountry: $notIsCountry}');
    //   //
    //   //   break;
    //   // }
    //
    // }


    return savedlistOfAllSymbolsDataMaps;

  }

  /// This method returns the app's directory uri
  void getAppDirectory(){
    
    print("This app's directory: ${_appDir!.uri}");
    
  }

}
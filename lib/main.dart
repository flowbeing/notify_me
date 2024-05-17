import "dart:io";

import 'package:flutter/material.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";

import "data/data.dart";

Future main() async{

  // Directory.current = Platform.pathSeparator;

  print('pre loading');
  await dotenv.load(fileName: 'config.env');
  print('post loading');

  String apiKey = dotenv.env['API_KEY']!;

  Data dataObject = Data();

  /// needed to set data symbols and data fetching error files
  await dataObject.createAppFilesAndFolders();

  // dataObject.updateAllForexData();
  // dataObject.updateAllStocksData();
  // dataObject.updateAllCryptoData();
  // dataObject.updateAllETFData();
  // dataObject.updateAllIndicesData();
  // dataObject.updateAllFundsData();
  // dataObject.updateAllBondsData();

  // await dataObject.updateAndSaveAllSymbolsData();
  // await dataObject.getAllSymbolsLocalData();
  await dataObject.getRealTimePriceAll();

  // dataObject.getRealTimePriceSingle(
  //   symbol: "INO/USD",
  //   country: "US"
  // );

  // dataObject.getUriAppDirectory();

  runApp(App());

}

class App extends StatelessWidget{

  Widget build(BuildContext context){

    return MaterialApp(
      title: "App",
      home: Container(
        color: Colors.teal
      )
    );
  }
}
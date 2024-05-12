import "dart:io";

import "package:flutter_dotenv/flutter_dotenv.dart";


import "data/data.dart";

Future main() async{

  // Directory.current = Platform.pathSeparator;

  print('pre loading');
  await dotenv.load(fileName: 'config.env');
  print('post loading');

  String apiKey = dotenv.env['API_KEY']!;

  Data dataObject = Data(
      apiKey: apiKey
  );

  /// needed to set data symbols and data fetching error files
  await dataObject.createAppFilesAndFolders();

  // dataObject.updateAllForexData();
  // dataObject.updateAllStocksData();
  // dataObject.updateAllCryptoData();
  // dataObject.updateAllETFData();
  // dataObject.updateAllIndicesData();
  // dataObject.updateAllFundsData();
  // dataObject.updateAllBondsData();

  await dataObject.updateAndSaveAllSymbolsData();
  // await dataObject.getAllSymbolsData();
  // dataObject.getAppDirectory();

}
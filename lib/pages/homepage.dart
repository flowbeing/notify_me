import 'dart:async';
import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:lottie/lottie.dart";

import "../providers/data_provider.dart";

import "../widgets/primary/grid_tile_currency_pair.dart";

class Homepage extends StatefulWidget {
  State<Homepage> createState() {
    return HomepageState();
  }
}

class HomepageState extends State<Homepage> {
  /// Screen Width & Height
  double deviceWidth = 0;
  double deviceHeight = 0;

  /// Screen / Main Container's Padding
  double paddingTop = 0;
  double paddingBottom = 0;
  double paddingTopScreen = 0;
  double paddingLeftAndRightScreen = 0;

  /// Grid Tile's Dimensions
  double widthGridTile = 0;
  double heightGridTile = 0;
  double paddingTopGridTile = 0;
  double crossAxisSpacing = 0;
  double mainAxisSpacing = 0;
  double radiusGridTile = 0;
  double heightFirstSixGridTiles = 0;

  /// price direction icon's height
  double heightPriceDirectionIcon = 0;

  /// font size - instruments / symbols
  double fontSizeSymbols = 0;

  /// font size - prices
  double fontSizePrices = 0;

  /// height - symbol and price sized boxes
  double heightSymbolSizedBox = 0;
  double heightPriceSizedBox = 0;

  /// margins:
  /// 1. price direction icon & currency pair
  /// 2. currency pair & currency price
  double marginPriceDirectionAndCurrencyPair = 0;
  double marginCurrencyPairAndCurrencyPrice = 0;

  /// Provider
  DataProvider? dataProvider;

  /// Index of first selected grid tile
  int indexSelectedGridTile = 3;

  @override
  void didChangeDependencies() async {
    print("");
    print("within didChangeDependencies");

    paddingTop = MediaQuery.of(context).padding.top;
    paddingBottom = MediaQuery.of(context).padding.bottom;
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    paddingTopScreen = paddingTop + (0.00321888412 * deviceHeight);
    paddingLeftAndRightScreen = 0.02325581395 * deviceWidth;

    /// Grid Tile's Dimensions
    widthGridTile = 0.4651162791 * deviceWidth;
    heightGridTile = 0.2145922747 * deviceHeight;
    paddingTopGridTile = 0.04721030043 * deviceHeight;
    crossAxisSpacing = 0.02325581395 * deviceWidth;
    mainAxisSpacing = 0.01072961373 * deviceHeight;
    radiusGridTile = 0.01162790698 * deviceWidth;
    heightFirstSixGridTiles = 0.6652360515 * deviceHeight;

    /// price direction icon's height
    heightPriceDirectionIcon = 0.02575107296 * deviceHeight;

    /// font sizes - symbols & prices
    fontSizeSymbols = 0.02360515021 * deviceHeight;
    fontSizePrices = 0.02145922747 * deviceHeight;

    /// symbol & price boxes' dimensions
    heightSymbolSizedBox = fontSizeSymbols;
    heightPriceSizedBox = 0.0321888412 * deviceHeight;

    /// 1. price direction icon & currency pair
    /// 2. currency pair & currency price
    marginPriceDirectionAndCurrencyPair = 0.01716738197 * deviceHeight;
    marginCurrencyPairAndCurrencyPrice = 0.01287553648 * deviceHeight;

    print("widthGridTile: ${widthGridTile}");
    print("heightGridTile: $heightGridTile");
    print("crossAxisSpacing: $crossAxisSpacing");
    print("mainAxisSpacing: $mainAxisSpacing");
    print("radiusGridTile: $radiusGridTile");
    print("heightFirstSixGridTiles: $heightFirstSixGridTiles");

    /// Data Provider
    dataProvider = Provider.of<DataProvider>(context, listen: true);

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {
    print("");
    print("");
    print(
        "--------------------------------------------------------------------------------");
    print("");
    print("HOMEPAGE - BEGINNING (BUILT HOMEPAGE!)");

    return Scaffold(
        appBar: null,

        /// The background
        body: FutureBuilder(
            future: dataProvider!.updatePrices(),
            builder: (ctx, snapshot) {
              /// Prices - all instruments / symbols
              Map<dynamic, dynamic> priceAllInstruments =
                  dataProvider!.allForexAndCryptoPrices;
              dynamic firstKeypriceAllInstruments;

              print(
                  "dataProvider!.allForexAndCryptoPrices: ${dataProvider!.allForexAndCryptoPrices}");

              firstKeypriceAllInstruments =
                  priceAllInstruments.keys.toList()[0];

              if (snapshot.connectionState == ConnectionState.done) {
                /// if the values of priceAllInstruments are Strings, which
                /// will only happen when the prices are being displayed for the
                /// first time, rebuild the page..
                if (priceAllInstruments[firstKeypriceAllInstruments]
                        .runtimeType ==
                    String) {
                  print('priceAllInstruments contains "fetching"');
                  print("");
                  print("HOMEPAGE - END");
                  print(
                      "--------------------------------------------------------------------------------");
                  print("");
                  Timer.periodic(const Duration(seconds: 5), (timer) {
                    setState(() {
                      print("Timer.periodic - 1 min: ${DateTime.now()}");
                      // priceAllInstruments = dataProvider!.allForexAndCryptoPrices;
                    });

                    timer.cancel();
                  });
                }

                /// ... otherwise, wait for 1 minute (approx) before rebuilding
                /// this page i.e before providing new price data..
                else {
                  print('priceAllInstruments contains "prices"');
                  print("");
                  print("HOMEPAGE - END");
                  print(
                      "--------------------------------------------------------------------------------");
                  print("");
                  Timer.periodic(const Duration(milliseconds: 60001), (timer) {
                    setState(() {
                      // priceAllInstruments = dataProvider!.allForexAndCryptoPrices;
                    });

                    timer.cancel();
                  });
                }
              }

              List<dynamic> listOfAllInstruments =
                  priceAllInstruments.keys.toList();
              List<dynamic> listOfAllInstrumentsValues =
                  priceAllInstruments.values.toList();

              /// main background
              return Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(
                      top: paddingTopScreen,
                      left: paddingLeftAndRightScreen,
                      right: paddingLeftAndRightScreen),

                  /// a column - holds all elements on the screen
                  child: Column(
                    children: [
                      /// Currency Pairs Container
                      /// - holds a gridview builder..
                      Container(
                        // color: Colors.yellow,
                        width: double.infinity,
                        height: heightFirstSixGridTiles,
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),

                        /// A GridView Builder - contains all currency pairs
                        child: GridView.builder(
                          padding: const EdgeInsets.all(0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: crossAxisSpacing,
                                  mainAxisSpacing: mainAxisSpacing),
                          itemCount: priceAllInstruments.isEmpty
                              ? 6

                              /// a minimum of six instruments will be
                              /// displayed post fetch operation
                              : priceAllInstruments.length,
                          itemBuilder: (context, index) {
                            String currentSymbolOrInstrument =
                                listOfAllInstruments[index];

                            /// Current instrument's data - could contain both
                            /// the old and current prices of the instrument
                            /// (actual prices or "demo") or
                            /// "fetching"
                            dynamic currentInstrumentsData =
                                priceAllInstruments[currentSymbolOrInstrument];

                            /// checking whether the current instrument's price
                            /// is being fetched..
                            bool isFetchingPrices =
                                currentInstrumentsData == "fetching";

                            String? current_price;
                            String? old_price;

                            String priceDifferenceIfAny = "";

                            if (currentInstrumentsData.runtimeType != String) {
                              current_price =
                                  currentInstrumentsData["current_price"];

                              old_price = currentInstrumentsData["old_price"];

                              /// if both the prices of the current instrument
                              /// are actual prices, calculate the price
                              /// movement. Otherwise, set
                              /// priceDifferenceIfAny to "demo"
                              try {
                                priceDifferenceIfAny =
                                    (double.parse(current_price!) -
                                            double.parse(old_price!))
                                        .toString();
                              } catch (error) {
                                priceDifferenceIfAny = current_price!;
                              }
                            }

                            /// determining whether there was an upward price
                            /// movement
                            bool isUpwardPriceMovement =
                                currentInstrumentsData.runtimeType != String &&
                                    !priceDifferenceIfAny.startsWith("-") &&
                                    priceDifferenceIfAny != "0" &&
                                    priceDifferenceIfAny != "demo";

                            /// determining whether there was a downward price
                            /// movement
                            bool isDownwardPriceMovement =
                                currentInstrumentsData.runtimeType != String &&
                                    priceDifferenceIfAny.startsWith("-");

                            /// determining whether the current instrument's
                            /// price should not be displayed or whether there
                            /// was no price movement..
                            bool isNotDisplayedPriceOrNoPriceMovement =
                                currentInstrumentsData.runtimeType != String &&
                                    !priceDifferenceIfAny.startsWith("-") &&
                                    (priceDifferenceIfAny == "0" ||
                                        priceDifferenceIfAny == "demo");

                            /// determining whether the current tile has been or
                            /// should be selected
                            bool isSelectedTile =
                                index == indexSelectedGridTile &&
                                    isFetchingPrices == false;

                            /// defining each grid tile's colors
                            Color pureColorGridTile = const Color(0xFF0066FF);
                            Color? gridTileColor;
                            Color? gridBorderColor;

                            if (isFetchingPrices == true) {
                              gridTileColor = Colors.white;
                              gridBorderColor = gridTileColor;
                            } else if (isNotDisplayedPriceOrNoPriceMovement) {
                              gridTileColor = Colors.black.withOpacity(.01);
                              gridBorderColor = gridTileColor;
                            } else if (isUpwardPriceMovement) {
                              pureColorGridTile = const Color(0xFF0066FF);
                              gridTileColor =
                                  pureColorGridTile.withOpacity(.05);
                              gridBorderColor =
                                  const Color(0xFF0066FF).withOpacity(.1);
                            } else if (isDownwardPriceMovement) {
                              pureColorGridTile = const Color(0xFFFC8955);

                              // Random random = Random();

                              // int randomIndex = random.nextInt(11);
                              // print("randomIndex: $randomIndex");

                              // List<double> opacity = [0.07, 0.1, 0.07, 0.1,
                              //   0.07, 0.1, 0.07, 0.1, 0.07, 0.1, 0.07, 0.1];

                              gridTileColor =
                                  pureColorGridTile.withOpacity(0.07);
                              gridBorderColor =
                                  pureColorGridTile.withOpacity(0.1);
                            }

                            /// Grid Tile - custom template
                            return GridTileCurrencyPair(
                                isSelected: isSelectedTile,
                                widthGridTile: widthGridTile,
                                heightGridTile: heightGridTile,
                                paddingTopGridTile: paddingTopGridTile,
                                gridTileColor: isSelectedTile
                                    ? pureColorGridTile.withOpacity(.58)
                                    : gridTileColor!,
                                gridBorderColor: gridBorderColor!,
                                radiusGridTile: radiusGridTile,
                                isFetchingPrices: isFetchingPrices,
                                heightPriceDirectionIcon:
                                    heightPriceDirectionIcon,
                                isDownwardPriceMovement:
                                    isDownwardPriceMovement,
                                isUpwardPriceMovement: isUpwardPriceMovement,
                                isNotDisplayedPriceOrNoPriceMovement:
                                    isNotDisplayedPriceOrNoPriceMovement,
                                marginPriceDirectionAndCurrencyPair:
                                    marginPriceDirectionAndCurrencyPair,
                                heightSymbolSizedBox: heightSymbolSizedBox,
                                currencyPairLazyLoading:
                                    currencyPairLazyLoading,
                                currencyPairOrPrice: currencyPairOrPrice,
                                currentSymbolOrInstrument:
                                    currentSymbolOrInstrument,
                                fontSizeSymbols: fontSizeSymbols,
                                marginCurrencyPairAndCurrencyPrice:
                                    marginCurrencyPairAndCurrencyPrice,
                                heightPriceSizedBox: heightPriceSizedBox,
                                priceAllInstruments: priceAllInstruments,
                                fontSizePrices: fontSizePrices
                            );
                          },
                        ),
                      )
                    ],
                  ));
            }));
  }
}

/// Text Widget - Currency Symbol/Instrument/Pair or Price
Text currencyPairOrPrice({
    required String currentSymbolOrInstrumentOrPrice,
    required FontWeight fontWeight,
    required double fontSize,
    bool isFetching = false,
    required Color fontColor
  }) {
  return Text(
    isFetching == true ? "fetching" : currentSymbolOrInstrumentOrPrice,
    style: TextStyle(
        fontFamily: "PT-Mono",
        fontWeight: fontWeight,
        fontSize: fontSize, // isFetching == true ? 16 : fontSize
        color: fontColor
        ),
  );
}

/// Lottie animation widget - for lazy loading currency pair/instrument/symbol
LottieBuilder currencyPairLazyLoading() {
  return Lottie.asset("assets/lottie_animations/"
      "loading_symbol.json");
}

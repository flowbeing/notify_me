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

  /// bool to track whether a grid tile has been clicked
  bool isGridTileClicked = false;

  /// timer - updatePrices method..
  Timer relevantTimer =
      Timer.periodic(const Duration(microseconds: 1), (timer) {
    timer.cancel();
  });

  /// timer - check if prices have finished updating
  Timer isPricesUpdatedCheckingTimer =
      Timer.periodic(const Duration(microseconds: 1), (timer) {
    timer.cancel();
  });

  /// Index of selected grid tile
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
            future: isGridTileClicked == true
                ? dataProvider!.nothingToSeeHere()
                : dataProvider!.updatePrices(),
            builder: (ctx, snapshot) {
              /// Prices - all instruments / symbols
              Map<dynamic, dynamic> priceAllInstruments =
                  dataProvider!.allForexAndCryptoPrices;
              dynamic firstKeypriceAllInstruments;

              print(
                  "dataProvider!.allForexAndCryptoPrices: ${dataProvider!.allForexAndCryptoPrices}");

              firstKeypriceAllInstruments =
                  priceAllInstruments.keys.toList()[0];

              /// resetting isGridTileClicked
              isGridTileClicked = false;

              /// if dataProvider!.updatePrices() (Future) has finished running,
              /// replace the current timer to reflect a price update that
              /// will take place within 5 seconds and 1 minute
              if (snapshot.connectionState == ConnectionState.done) {
                /// bool that signal whether prices are currently being fetched.
                /// true when:
                /// a. the relevant timer has been cancelled &&
                /// b. updatePrices is running
                // bool isUpdatingPrices = relevantTimer.isActive == false &&
                //     dataProvider!.isUpdatingPrices == true;

                /// if the values of priceAllInstruments are Strings, which
                /// will only happen when the prices are being displayed for the
                /// first time, rebuild the page..

                if (priceAllInstruments[firstKeypriceAllInstruments]
                        .runtimeType ==
                    String) {
                  print('priceAllInstruments contains "fetching"');
                  print("");
                  print("HOMEPAGE - END - 5s");
                  print(
                      "--------------------------------------------------------------------------------");
                  print("");

                  /// if a previous 5 seconds timer is no longer active and it's
                  /// corresponding dataProvider!.updatePrices (Future) is has
                  /// finished running set relevantTimer to a timer that should
                  /// execute  dataProvider!.updatePrices one minute in the
                  /// future

                  if (relevantTimer.isActive == false &&
                      dataProvider!.isUpdatingPrices == true) {
                    relevantTimer =
                        Timer.periodic(const Duration(seconds: 5), (timer) {
                      timer.cancel();

                      setState(() {
                        print("Timer.periodic - 1 min: ${DateTime.now()}");
                      });
                    });
                  }
                }

                /// ... otherwise, wait for 1 minute (approx) before rebuilding
                /// this page i.e before providing new price data..
                else {
                  print('priceAllInstruments contains "prices"');
                  print("");
                  print("HOMEPAGE - END - 1min");
                  print(
                      "--------------------------------------------------------------------------------");
                  print("");

                  print("relevantTimer outside: $relevantTimer");
                  print(
                      "relevantTimer.isActive == false && dataProvider!.isUpdatingPrices == false in: ${relevantTimer.isActive == false && dataProvider!.isUpdatingPrices == false}");

                  /// If prices are currently being updated, replace current
                  /// relevantTimer with another when prices have fully been
                  /// updated..
                  ///
                  /// useful when a grid tile has been clicked but prices
                  /// are still being updated, which would normally prevent
                  /// the rebuilt version of this page that has been triggered
                  /// by the grid tile selection from reflecting the updated
                  /// prices when the prices update has ended..
                  if (dataProvider!.isUpdatingPrices == true) {
                    /// cancel any previously set (active) price update
                    /// operation status checking timer to prevent the creation
                    /// of multiple memory hogging timers..
                    if (isPricesUpdatedCheckingTimer.isActive) {
                      isPricesUpdatedCheckingTimer.cancel();
                    }

                    /// create and store a new the value of price update
                    /// operation status checking timer..
                    isPricesUpdatedCheckingTimer = Timer.periodic(
                        const Duration(milliseconds: 1000), (timer) {
                      if (relevantTimer.isActive == false &&
                          dataProvider!.isUpdatingPrices == false) {
                        print("gridTile relevantTimer in: $relevantTimer");
                        print(
                            "gridTile selected: relevantTimer.isActive == false && dataProvider!.isUpdatingPrices == false in: ${relevantTimer.isActive == false && dataProvider!.isUpdatingPrices == false}");

                        // /// updating all instruments' price data
                        // priceAllInstruments = dataProvider!.allForexAndCryptoPrices;

                        relevantTimer = Timer.periodic(
                            const Duration(milliseconds: 60001), (timer) {
                          timer.cancel();

                          setState(() {});
                        });

                        timer.cancel();

                        /// arbitrarily rebuild this FutureBuilder widget..
                        ///
                        /// Note that isGridTileClicked will be set back to
                        /// false once this FutureBuilder widget has been
                        /// rebuilt..
                        setState(() {
                          isGridTileClicked = true;
                        });
                      }
                    });
                  }

                  /// if a previous 1 minute timer is no longer active and it's
                  /// corresponding dataProvider!.updatePrices (Future) has
                  /// finished running i.e prices have finished updating,
                  /// set relevantTimer to a timer that should
                  /// execute dataProvider!.updatePrices one minute in the
                  /// future..
                  ///
                  /// the conditions below mean "wait until the previously set
                  /// relevant timer has done it's job.."
                  else if (relevantTimer.isActive == false &&
                      dataProvider!.isUpdatingPrices == false) {
                    print("relevantTimer in: $relevantTimer");
                    print("relevantTimer.isActive == false "
                        "&& dataProvider!.isUpdatingPrices == false in: "
                        "${relevantTimer.isActive == false
                        && dataProvider!.isUpdatingPrices == false}");

                    relevantTimer = Timer.periodic(
                        const Duration(milliseconds: 60001), (timer) {
                      timer.cancel();

                      setState(() {});
                    });
                  }
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
                                    isFetchingPrices == false &&
                                    priceDifferenceIfAny != "demo";

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
                              pureColorGridTile =
                                  const Color(0xFF0066FF).withOpacity(.67);
                              gridTileColor =
                                  const Color(0xFF0066FF).withOpacity(.05);
                              gridBorderColor =
                                  const Color(0xFF0066FF).withOpacity(.1);
                            } else if (isDownwardPriceMovement) {
                              pureColorGridTile = const Color(0xFFFC8955);
                              gridTileColor =
                                  const Color(0xFFFC8955).withOpacity(0.07);
                              gridBorderColor =
                                  const Color(0xFFFC8955).withOpacity(0.1);
                            }

                            /// Grid Tile - custom template
                            return GestureDetector(
                              /// select the current grid tile when it's tapped
                              onTap: () => {
                                if (currentInstrumentsData.runtimeType !=
                                        String &&
                                    priceDifferenceIfAny != "demo")
                                  {
                                    setState(() {
                                      print("Gesture Detector Setting State");
                                      indexSelectedGridTile = index;

                                      /// signalling that a grid tile has been
                                      /// clicked
                                      ///
                                      /// This will change the value of the
                                      /// FutureBuilder widget's "future"
                                      /// parameter to
                                      /// "dataProvider!.nothingToSeeHere" -
                                      /// a filler Future method that helps
                                      /// ensure that a selected grid tile is
                                      /// colored and a timer is set ...
                                      isGridTileClicked = true;
                                    })
                                  }
                              },
                              child: GridTileCurrencyPair(
                                  isSelected: isSelectedTile,
                                  widthGridTile: widthGridTile,
                                  heightGridTile: heightGridTile,
                                  paddingTopGridTile: paddingTopGridTile,
                                  gridTileColor: isSelectedTile
                                      ? pureColorGridTile
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
                                  fontSizePrices: fontSizePrices),
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
Text currencyPairOrPrice(
    {required String currentSymbolOrInstrumentOrPrice,
    required FontWeight fontWeight,
    required double fontSize,
    bool isFetching = false,
    required Color fontColor}) {
  return Text(
    isFetching == true ? "fetching" : currentSymbolOrInstrumentOrPrice,
    style: TextStyle(
        fontFamily: "PT-Mono",
        fontWeight: fontWeight,
        fontSize: fontSize, // isFetching == true ? 16 : fontSize
        color: fontColor),
  );
}

/// Lottie animation widget - for lazy loading currency pair/instrument/symbol
LottieBuilder currencyPairLazyLoading() {
  return Lottie.asset("assets/lottie_animations/"
      "loading_symbol.json");
}

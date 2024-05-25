import 'dart:async';

import "package:flutter/material.dart";

import "package:provider/provider.dart";

import "../providers/data_provider.dart";

class Homepage extends StatefulWidget{

  State<Homepage> createState(){
    return HomepageState();
  }

}

class HomepageState extends State<Homepage>{

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

  /// Provider
  DataProvider? dataProvider;

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

    print("widthGridTile: ${widthGridTile}");
    print("heightGridTile: $heightGridTile");
    print("crossAxisSpacing: $crossAxisSpacing");
    print("mainAxisSpacing: $mainAxisSpacing");
    print("radiusGridTile: $radiusGridTile");
    print("heightFirstSixGridTiles: $heightFirstSixGridTiles");

    /// Data Provider
    dataProvider = Provider.of<DataProvider>(context, listen:true);

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

  }

  Widget build(BuildContext context){

    print("");
    print("");
    print("--------------------------------------------------------------------------------");
    print("");
    print("HOMEPAGE - BEGINNING (BUILT HOMEPAGE!)");

    return Scaffold(
        appBar: null,
        /// The background
        body: FutureBuilder(
          future: dataProvider!.updatePrices(),
          builder: (ctx, snapshot) {

            /// Prices - all instruments / symbols
            Map<dynamic, dynamic> priceAllInstruments = dataProvider!.allForexAndCryptoPrices;
            dynamic firstKeypriceAllInstruments;

            print("dataProvider!.allForexAndCryptoPrices: ${dataProvider!.allForexAndCryptoPrices}");

            firstKeypriceAllInstruments = priceAllInstruments.keys.toList()[0];

            if (snapshot.connectionState == ConnectionState.done){

              /// if the values of priceAllInstruments are Strings, which
              /// will only happen when the prices are being displayed for the
              /// first time, rebuild the page..
              if (priceAllInstruments[firstKeypriceAllInstruments].runtimeType == String){

                print('priceAllInstruments contains "fetching"');
                print("");
                print("HOMEPAGE - END");
                print("--------------------------------------------------------------------------------");
                print("");
                Timer.periodic(const Duration(seconds: 59), (timer) {

                  setState((){
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
                print("--------------------------------------------------------------------------------");
                print("");
                Timer.periodic(const Duration(minutes: 1, seconds: 6), (timer) {

                  setState((){
                    // priceAllInstruments = dataProvider!.allForexAndCryptoPrices;
                  });

                  timer.cancel();
                });

              }

            }

            List<dynamic> listOfAllInstruments = priceAllInstruments.keys.toList();
            List<dynamic> listOfAllInstrumentsValues = priceAllInstruments.values.toList();

            /// main background
            return Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                    top: paddingTopScreen,
                    left: paddingLeftAndRightScreen,
                    right: paddingLeftAndRightScreen
                ),
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

                      /// A GridView builder - contains all currency pairs
                      child: GridView.builder(
                        padding: const EdgeInsets.all(0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: crossAxisSpacing,
                            mainAxisSpacing: mainAxisSpacing
                        ),
                        itemCount: priceAllInstruments.isEmpty ?
                          6 : priceAllInstruments.length,
                        itemBuilder: (context, index) {

                          String currentSymbolOrInstrument =
                            listOfAllInstruments[index];

                          dynamic currentInstrumentsData =
                            priceAllInstruments[currentSymbolOrInstrument];

                          String? current_price;
                          String? old_price;

                          double? price_difference;

                          if (currentInstrumentsData.runtimeType != String){
                            current_price =
                              currentInstrumentsData["current_price"];

                            old_price =
                            currentInstrumentsData["old_price"];

                            price_difference =
                                double.parse(current_price!)
                                    - double.parse(old_price!);
                          }


                          /// Grid Tile - custom template
                          return Container(
                              alignment: Alignment.center,
                              width: widthGridTile,
                              height: heightGridTile,
                              padding: EdgeInsets.only(
                                top: paddingTopGridTile
                              ),
                              decoration: BoxDecoration(
                                // const Color(0xFFF3F7FF), // Color(0xFFFEF7F2) -> light orange, Color(0xFFFC8955) -> Orange
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFF0066FF).withOpacity(0.1), // Color(0xFFFC8955).withOpacity(0.1)
                                  ),
                                  borderRadius: BorderRadius.circular(radiusGridTile)
                              ),
                              child: Container(
                                // color: Colors.yellow,
                                child: Column(
                                  children: <Widget>[

                                    /// icon - fetching prices
                                    if (currentInstrumentsData == "fetching")
                                      Image.asset(
                                        "assets/images/price_fetching.png",
                                        height: heightPriceDirectionIcon,
                                      ),

                                    /// price increase or decrease image
                                    ///
                                    /// if app isn't fetching the current
                                    /// instrument's price, and the current
                                    /// price does not reflect a decrease in the
                                    /// instrument's value, show a blue upward
                                    /// price movement (image) icon..
                                    if (currentInstrumentsData.runtimeType != String
                                        && price_difference != null &&
                                        price_difference.toString()
                                            .startsWith("-")) Image.asset(
                                      "assets/images/price_increase.png"
                                    ),

                                    /// if app isn't fetching the current
                                    /// instrument's price, and the current
                                    /// price does reflects a decrease in the
                                    /// instrument's value, show a blue downward
                                    /// price movement (image) icon..
                                    if (currentInstrumentsData.runtimeType != String
                                        && price_difference != null &&
                                        !price_difference.toString()
                                            .startsWith("-")) Image.asset(
                                        "assets/images/price_decrease.png"
                                    ),



                                    /// currency name / currency name holder
                                    Text(
                                      currentSymbolOrInstrument.toString(),
                                        style: TextStyle(
                                          fontFamily: "PT-Mono",
                                          fontWeight: FontWeight.bold,
                                          fontSize: fontSizeSymbols
                                        ),
                                    ),

                                    /// currency price / currency price holder
                                    Text(
                                        currentInstrumentsData == "fetching" ?
                                            "fetching" :
                                        priceAllInstruments[
                                          currentSymbolOrInstrument][
                                            "current_price"
                                        ].toString(),
                                      style: TextStyle(
                                        fontFamily: "PT-Mono",
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16
                                      ),
                                    ),

                                    
                                  ]
                                )
                              )
                          );
                        },
                      ),
                    )

                  ],
                )
            );
          }
        )
    );
  }

}
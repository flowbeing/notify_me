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
  double crossAxisSpacing = 0;
  double mainAxisSpacing = 0;
  double radiusGridTile = 0;
  double heightFirstSixGridTiles = 0;

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
    crossAxisSpacing = 0.02325581395 * deviceWidth;
    mainAxisSpacing = 0.01072961373 * deviceHeight;
    radiusGridTile = 0.01162790698 * deviceWidth;
    heightFirstSixGridTiles = 0.6652360515 * deviceHeight;

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
    print("BUILT HOMEPAGE!");

    return Scaffold(
        appBar: null,
        /// The background
        body: FutureBuilder(
          future: dataProvider!.updatePrices(),
          builder: (ctx, snapshot) {

            print("initialData: ${snapshot.data}");

            /// Prices - all instruments / symbols
            Map<dynamic, dynamic> pricesAllInstruments = dataProvider!.allForexAndCryptoPrices;
            dynamic firstKeyPricesAllInstruments;

            print("dataProvider!.allForexAndCryptoPrices: ${dataProvider!.allForexAndCryptoPrices}");

            firstKeyPricesAllInstruments = pricesAllInstruments.keys.toList()[0];

            if (snapshot.connectionState == ConnectionState.done){

              /// if the values of pricesAllInstruments are Strings, which
              /// will only happen when the prices are being displayed for the
              /// first time, rebuild the page..
              if (pricesAllInstruments[firstKeyPricesAllInstruments].runtimeType == String){

                print('pricesAllInstruments contains "fetching"');
                Timer.periodic(const Duration(seconds: 5), (timer) {

                  setState((){
                    // pricesAllInstruments = dataProvider!.allForexAndCryptoPrices;
                  });

                  timer.cancel();
                });

              }
              /// ... otherwise, wait for 1 minute (approx) before rebuilding
              /// this page i.e before providing new price data..
              else {

                print('pricesAllInstruments contains prices data');
                Timer.periodic(const Duration(minutes: 1, seconds: 6), (timer) {

                  setState((){
                    // pricesAllInstruments = dataProvider!.allForexAndCryptoPrices;
                  });

                  timer.cancel();
                });

              }

            }

            List<dynamic> listOfAllInstruments = pricesAllInstruments.keys.toList();
            List<dynamic> listOfAllInstrumentsValues = pricesAllInstruments.values.toList();

            return Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                    top: paddingTopScreen,
                    left: paddingLeftAndRightScreen,
                    right: paddingLeftAndRightScreen
                ),
                child: Column(
                  children: [

                    /// Currency Pairs - GridView Tiles
                    Container(
                      width: double.infinity,
                      height: heightFirstSixGridTiles,
                      margin: const EdgeInsets.all(0),
                      padding: const EdgeInsets.all(0),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: crossAxisSpacing,
                            mainAxisSpacing: mainAxisSpacing
                        ),
                        itemCount: pricesAllInstruments.isEmpty ?
                          6 : pricesAllInstruments.length,
                        itemBuilder: (context, index) {
                          return Container(
                              alignment: Alignment.center,
                              width: widthGridTile,
                              height: heightGridTile,
                              decoration: BoxDecoration(
                                // const Color(0xFFF3F7FF), // Color(0xFFFEF7F2) -> light orange, Color(0xFFFC8955) -> Orange
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: const Color(0xFF0066FF).withOpacity(0.1), // Color(0xFFFC8955).withOpacity(0.1)
                                  ),
                                  borderRadius: BorderRadius.circular(radiusGridTile)
                              ),
                              child: Text(
                                  listOfAllInstruments[index].toString()
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
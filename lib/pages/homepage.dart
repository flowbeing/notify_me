import 'dart:async';
import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:lottie/lottie.dart";
import "package:keyboard_detection/keyboard_detection.dart";

import '../data/enums.dart';
import "../providers/data_provider.dart";

import "../widgets/primary/container_gridview_builder.dart";
import "../widgets/secondary/custom_text_button.dart";
import "../widgets/secondary/dot_divider.dart";
import "../widgets/secondary/instrument_filters.dart";

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
  double borderWidthGridTile = 0;

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

  /// bool to track whether a grid tile or filter option has been clicked
  bool isGridTileOrFilterOptionClickedOrKeyboardVisible = false;

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

  /// Dimensions and other measurements - alerts & other menu items sized box
  double heightAlertsAndOtherMenuItemsSizedBox = 0;
  double marginTopAlertsAndOtherMenuItemsSizedBox = 0;
  double marginBottomAlertsAndOtherMenuItemsSizedBox = 0;

  double fontSizeAlertsAndOtherMenuItemsSizedBox = 0;
  double widthDotDivider = 0;
  double iconSizeDotDivider = 0;
  double widthSpaceInBetweenAlertsMenu = 0;

  /// dimensions - alerts ListView Builder
  double heightAlertsListViewBuilder = 0;
  double radiusListViewBuilder = 0;
  double fontSizeNoAlerts = 0; //
  double fontSizeAlertsListTile = 0; //
  double borderWidthListViewBuilder = 0;

  /// measurements - swipe notification
  double heightSwipeNotification = 0;
  double fontSizeSwipeNotification = 0; //

  /// measurements - create new alert container
  double heightCreateNewAlertContainer = 0;
  double widthCreateNewAlertContainer = 0;

  double widthCurrencyPairTextField = 0;
  double widthPriceTextField = 0;
  double widthAddAlertButton = 0;
  double borderTopLeftOrRightRadiusCreateAlert = 0;
  double borderBottomLeftOrRightRadiusCreateAlert = 0;

  // /// keyboard visibility signalling bool
  // bool isKeyboardVisible = false;

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
    borderWidthGridTile = 0.0008583690987 * deviceHeight;

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

    /// dimensions and other measurements - alerts and other menu items SizedBox
    heightAlertsAndOtherMenuItemsSizedBox = 0.04291845494 * deviceHeight;
    marginTopAlertsAndOtherMenuItemsSizedBox = 0.01394849785 * deviceHeight;
    marginBottomAlertsAndOtherMenuItemsSizedBox = 0.01072961373 * deviceHeight;

    fontSizeAlertsAndOtherMenuItemsSizedBox = 0.0160944206 * deviceHeight;
    widthDotDivider = 0.04418604651 * deviceWidth;
    iconSizeDotDivider = 0.003755364807 * deviceHeight;

    widthSpaceInBetweenAlertsMenu = 0.2348837209 * deviceWidth;

    /// dimensions - alerts ListView Builder
    heightAlertsListViewBuilder = 0.1201716738 * deviceHeight;
    radiusListViewBuilder = 0.00643776824 * deviceHeight;
    fontSizeNoAlerts = fontSizeSymbols; //
    fontSizeAlertsListTile = 0.01716738197 * deviceHeight;
    borderWidthListViewBuilder = 0.0002682403433 * deviceHeight;

    /// height - swipe notification
    heightSwipeNotification = 0.03004291845 * deviceHeight;
    fontSizeSwipeNotification = 0.01072961373 * deviceHeight;

    /// measurements - create new alert container
    heightCreateNewAlertContainer = 0.05364806867 * deviceHeight;
    widthCreateNewAlertContainer = 0.4093023256 * deviceWidth;

    widthCurrencyPairTextField = 0.2488372093 * deviceWidth;
    widthPriceTextField = 0.4093023256 * deviceWidth;
    widthAddAlertButton = widthCurrencyPairTextField;
    borderTopLeftOrRightRadiusCreateAlert = 0.004291845494 * deviceHeight;
    borderBottomLeftOrRightRadiusCreateAlert = 0.02145922747 * deviceHeight;

    /// Data Provider
    dataProvider = Provider.of<DataProvider>(context, listen: true);

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  /// this method updates timers when prices have been fetched
  void updateTimers({required bool isOneMin}) {
    /// is price currently being updated
    bool isPriceUpdating = dataProvider!.getIsUpdatingPrices();

    if (isOneMin == false) {
      /// if a previous 5 seconds timer is no longer active and it's
      /// corresponding dataProvider!.updatePrices (Future) is has
      /// finished running set relevantTimer to a timer that should
      /// execute  dataProvider!.updatePrices 5 seconds in the
      /// future

      if (relevantTimer.isActive == false && isPriceUpdating == true) {
        relevantTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
          timer.cancel();

          setState(() {
            print("Timer.periodic - 1 min: ${DateTime.now()}");
          });
        });
      }
    } else if (isOneMin == true) {
      print('priceAllInstruments contains "prices"');
      print("");
      print("HOMEPAGE - END - 1min");
      print(
          "--------------------------------------------------------------------------------");
      print("");

      print("relevantTimer outside: $relevantTimer");
      print(
          "relevantTimer.isActive == false && isPriceUpdating == false in: ${relevantTimer.isActive == false && isPriceUpdating == false}");

      /// If prices are currently being updated, replace current
      /// relevantTimer with another when prices have fully been
      /// updated..
      ///
      /// useful when a grid tile has been clicked but prices
      /// are still being updated, which would normally prevent
      /// the rebuilt version of this page that has been triggered
      /// by the grid tile selection from reflecting the updated
      /// prices when the prices have finished updating..
      if (isPriceUpdating == true) {
        /// cancel any previously set (active) price update
        /// operation status checking timer to prevent the creation
        /// of multiple memory hogging timers..
        if (isPricesUpdatedCheckingTimer.isActive) {
          isPricesUpdatedCheckingTimer.cancel();
        }

        print("isPriceUpdating == true");

        /// create and store the new value of price update
        /// operation status checking timer..
        isPricesUpdatedCheckingTimer =
            Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          // 1000
          print("Duration(milliseconds: 1000)");
          print(
              "2. relevantTimer.isActive == false && isPriceUpdating == false: ${relevantTimer.isActive == false && isPriceUpdating == false}");

          /// dataProvider!.getIsUpdatingPrices() is used below instead of
          /// "updatingPrices" variable to ensure that the latest state prices
          /// update state is obtained directly from dataProvider...

          if (relevantTimer.isActive == false &&
              dataProvider!.getIsUpdatingPrices() == false) {
            print("gridTile relevantTimer in: $relevantTimer");
            print("gridTile selected: relevantTimer.isActive == false "
                "&& isPriceUpdating == false in: ${relevantTimer.isActive == false && isPriceUpdating == false}");

            // /// updating all instruments' price data
            // priceAllInstruments = dataProvider!.getInstruments();

            relevantTimer =
                Timer.periodic(const Duration(milliseconds: 60001), (timer) {
              timer.cancel();

              setState(() {});
            });

            timer.cancel();

            /// arbitrarily rebuild this FutureBuilder widget..
            ///
            /// Note that isGridTileOrFilterOptionClickedOrKeyboardVisible will be set back to
            /// false once this FutureBuilder widget has been
            /// rebuilt..
            setState(() {
              isGridTileOrFilterOptionClickedOrKeyboardVisible = true;
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
      else if (relevantTimer.isActive == false && isPriceUpdating == false) {
        print("3. relevantTimer in: $relevantTimer");
        print("3. relevantTimer.isActive == false "
            "&& isPriceUpdating == false in: "
            "${relevantTimer.isActive == false && isPriceUpdating == false}");

        relevantTimer =
            Timer.periodic(const Duration(milliseconds: 60001), (timer) {
          timer.cancel();

          setState(() {});
        });
      }
    }
  }

  /// this method triggers a rebuild of this homepage widget when a grid tile
  /// is clicked..
  void updateAppGridTileClicked(
      {required bool isGridTileClicked,
      required int indexNewSelectedGridTile}) {
    setState(() {
      isGridTileOrFilterOptionClickedOrKeyboardVisible = isGridTileClicked;
      indexSelectedGridTile = indexNewSelectedGridTile;
    });
  }

  /// this method rebuilds the homepage state when a filter option is clicked
  void updateAppFilterOptionClicked({required Filter selectedFilterOption}) {
    dataProvider!.updateFilter(filter: selectedFilterOption);

    setState(() {
      isGridTileOrFilterOptionClickedOrKeyboardVisible = true;
    });
  }

  Widget build(BuildContext context) {
    print("");
    print("");
    print(
        "--------------------------------------------------------------------------------");
    print("");
    print("HOMEPAGE - BEGINNING (BUILT HOMEPAGE!)");

    KeyboardDetectionController keyboardDetectionController;
    bool? isKeyboardVisible;

    return KeyboardDetection(
      controller:
          KeyboardDetectionController(onChanged: (isKeyBoardVisibleVal) {
        print('isKeyBoardVisibleVal: $isKeyBoardVisibleVal');

        if (isKeyBoardVisibleVal == KeyboardState.visibling ||
            isKeyBoardVisibleVal == KeyboardState.visible ||
            isKeyBoardVisibleVal == KeyboardState.hiding ||
            isKeyBoardVisibleVal == KeyboardState.hidden) {
          /// this will help prevent a price update loop -
          /// dataProvider!.updatePrices()
          print("isKeyBoardVisibleVal in");
          isGridTileOrFilterOptionClickedOrKeyboardVisible = true;
        }
      }),
      child: Scaffold(
          appBar: null,
          resizeToAvoidBottomInset: false,

          /// The background
          body: FutureBuilder(
              future:
                  isGridTileOrFilterOptionClickedOrKeyboardVisible == true ||
                          dataProvider!.getIsUpdatingPrices() == true
                      ? dataProvider!.nothingToSeeHere()
                      : dataProvider!.updatePrices(),
              builder: (ctx, snapshot) {
                /// Prices - all instruments / symbols
                Map<dynamic, dynamic> priceAllInstruments =
                    dataProvider!.getInstruments();
                dynamic firstKeypriceAllInstruments;

                print(
                    "dataProvider!.getInstruments(): ${dataProvider!.getInstruments()}");

                /// determining whether instruments prices is being fetched for
                /// the first time..
                ///
                /// bool isFirstValueInMapOfAllInstrumentsContainsFetching will
                /// be true if so..
                dynamic typeFirstValueInMapOfAllInstruments =
                    dataProvider!.getTypeFirstValueInMapOfAllInstruments();

                bool isFirstValueInMapOfAllInstrumentsContainsFetching =
                    typeFirstValueInMapOfAllInstruments == String;

                print(
                    "typeFirstValueInMapOfAllInstruments: $typeFirstValueInMapOfAllInstruments");

                // firstKeypriceAllInstruments =
                //     priceAllInstruments.keys.toList()[0];

                /// resetting isGridTileOrFilterOptionClickedOrKeyboardVisible
                isGridTileOrFilterOptionClickedOrKeyboardVisible = false;

                /// if dataProvider!.updatePrices() (Future) has finished running,
                /// replace the current timer to reflect a price update that
                /// will take place within 5 seconds and 1 minute
                if (snapshot.connectionState == ConnectionState.done) {
                  // /// bool that signal whether prices are currently being fetched.
                  // /// true when:
                  // /// a. the relevant timer has been cancelled &&
                  // /// b. updatePrices is running
                  // bool isUpdatingPrices = relevantTimer.isActive == false &&
                  //     isPriceUpdating == true;

                  /// if the values of priceAllInstruments are Strings, which
                  /// will only happen when the prices are being displayed for the
                  /// first time, rebuild the page..

                  if (isFirstValueInMapOfAllInstrumentsContainsFetching) {
                    print('priceAllInstruments contains "fetching"');
                    print("");
                    print("HOMEPAGE - END - 5s");
                    print(
                        "--------------------------------------------------------------------------------");
                    print("");

                    updateTimers(isOneMin: false);
                  }

                  /// ... otherwise, wait for 1 minute (approx) before rebuilding
                  /// this page i.e before providing new price data..
                  else {
                    updateTimers(isOneMin: true);
                  }
                }

                List<dynamic> listOfAllInstruments =
                    priceAllInstruments.keys.toList();
                List<dynamic> listOfAllInstrumentsValues =
                    priceAllInstruments.values.toList();

                String currentlySelectedInstrument =
                    listOfAllInstruments[indexSelectedGridTile];

                print("");
                print(
                    "currentlySelectedInstrument: ${currentlySelectedInstrument}");

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
                        ContainerGridViewBuilder(
                            heightFirstSixGridTiles: heightFirstSixGridTiles,
                            crossAxisSpacing: crossAxisSpacing,
                            mainAxisSpacing: mainAxisSpacing,
                            listOfAllInstruments: listOfAllInstruments,
                            priceAllInstruments: priceAllInstruments,
                            indexSelectedGridTile: indexSelectedGridTile,
                            widthGridTile: widthGridTile,
                            heightGridTile: heightGridTile,
                            paddingTopGridTile: paddingTopGridTile,
                            borderWidthGridTile: borderWidthGridTile,
                            radiusGridTile: radiusGridTile,
                            heightPriceDirectionIcon: heightPriceDirectionIcon,
                            marginPriceDirectionAndCurrencyPair:
                                marginPriceDirectionAndCurrencyPair,
                            heightSymbolSizedBox: heightSymbolSizedBox,
                            currencyPairLazyLoading: currencyPairLazyLoading,
                            currencyPairOrPrice: currencyPairOrPrice,
                            fontSizeSymbols: fontSizeSymbols,
                            marginCurrencyPairAndCurrencyPrice:
                                marginCurrencyPairAndCurrencyPrice,
                            heightPriceSizedBox: heightPriceSizedBox,
                            fontSizePrices: fontSizePrices,
                            updateAppGridTileClicked: updateAppGridTileClicked),

                        /// Alerts & Other menu items - SizedBox
                        SizedBox(
                            height: heightAlertsAndOtherMenuItemsSizedBox,
                            width: double.infinity,
                            // color: Colors.green,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: marginTopAlertsAndOtherMenuItemsSizedBox,
                                  bottom:
                                      marginBottomAlertsAndOtherMenuItemsSizedBox),
                              child: Row(children: <Widget>[
                                /// title - "Alert"
                                Text("Alerts",
                                    style: TextStyle(
                                      fontFamily: "PT-Mono",
                                      fontSize:
                                          fontSizeAlertsAndOtherMenuItemsSizedBox,
                                    )),

                                /// dot divider
                                DotDivider(
                                    widthDotDivider: widthDotDivider,
                                    iconSizeDotDivider: iconSizeDotDivider),

                                /// "Mute All" button
                                CustomTextButton(
                                    currentFilter: Filter.none,
                                    selectedFilter: Filter.none,
                                    fontSize:
                                        fontSizeAlertsAndOtherMenuItemsSizedBox,
                                    isFirstValueInMapOfAllInstrumentsContainsFetching:
                                        isFirstValueInMapOfAllInstrumentsContainsFetching),

                                /// Space in between - "Alerts -> Mute All" &
                                /// Instruments Filter ("All", "Forex", "Crypto")
                                SizedBox(
                                  width: widthSpaceInBetweenAlertsMenu,
                                ),

                                /// Instrument Filter Options
                                InstrumentFilters(
                                    fontSizeAlertsAndOtherMenuItemsSizedBox:
                                        fontSizeAlertsAndOtherMenuItemsSizedBox,
                                    widthDotDivider: widthDotDivider,
                                    iconSizeDotDivider: iconSizeDotDivider,
                                    updateAppFilterClicked:
                                        updateAppFilterOptionClicked,
                                    isFirstValueInMapOfAllInstrumentsContainsFetching:
                                        isFirstValueInMapOfAllInstrumentsContainsFetching)
                              ]),
                            )),

                        /// Alerts' Sized Box - contains a ListView builder
                        Container(
                          height: heightAlertsListViewBuilder,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            // color: Colors.yellow,
                            border: Border.all(
                                color: Colors.grey, // const Color(0xFFFC8955)
                                width: borderWidthGridTile / 6.1538461538),
                            borderRadius: BorderRadius.circular(radiusGridTile),
                          ),
                          child: Image.asset(
                            "assets/images/no_alerts.png",
                            width: 10,
                            height: 10,
                            // fit: BoxFit.fitHeight,
                          ),
                        ),

                        /// Swipe notification's Sized Box
                        SizedBox(
                            height: heightSwipeNotification,
                            width: double.infinity,
                            // color: Colors.blueAccent
                            child: Center(
                              child: Text("Swipe",
                                  style: TextStyle(
                                      fontFamily: "PT-Mono",
                                      fontSize: fontSizeSwipeNotification,
                                      color: Colors.black)),
                            )),

                        /// Create New Alert's Sized Box
                        SizedBox(
                            height: heightCreateNewAlertContainer,
                            width: double.infinity,
                            // color: Colors.tealAccent
                            child: Row(
                              children: [
                                /// currency pair text-field..
                                CurrencyPairTextFieldOrCreateAlertButton(
                                  isCurrencyPairTextField: true,
                                  heightCreateNewAlertContainer:
                                      heightCreateNewAlertContainer,
                                  widthCurrencyPairTextField:
                                      widthCurrencyPairTextField,
                                  borderTopLeftOrRightRadiusCreateAlert:
                                      borderTopLeftOrRightRadiusCreateAlert,
                                  borderBottomLeftOrRightRadiusCreateAlert:
                                      borderBottomLeftOrRightRadiusCreateAlert,
                                  borderWidthGridTile: borderWidthGridTile,
                                  fontSizeCurrencyPairAndPrice:
                                      fontSizeAlertsListTile,
                                  selectedInstrument:
                                      currentlySelectedInstrument,
                                ),

                                /// spacing - currency pair text-field & currency
                                /// price adjustment container..
                                SizedBox(
                                    width:
                                        marginBottomAlertsAndOtherMenuItemsSizedBox // 10 px -> iPhone 14 Pro Max
                                    ),

                                /// currency price adjustment container
                                Container(
                                  height: heightCreateNewAlertContainer,
                                  width: widthCreateNewAlertContainer,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: borderWidthGridTile / 4)),
                                ),

                                /// spacing - currency price adjustment container
                                /// and "Add Alert" button..
                                SizedBox(
                                    width:
                                        marginBottomAlertsAndOtherMenuItemsSizedBox // 10 px -> iPhone 14 Pro Max
                                    ),

                                /// add alert button..
                                // CurrencyPairTextFieldOrCreateAlertButton(
                                //   isCurrencyPairTextField: false,
                                //   heightCreateNewAlertContainer:
                                //       heightCreateNewAlertContainer,
                                //   widthCurrencyPairTextField:
                                //       widthCurrencyPairTextField,
                                //   borderTopLeftOrRightRadiusCreateAlert:
                                //       borderTopLeftOrRightRadiusCreateAlert,
                                //   borderBottomLeftOrRightRadiusCreateAlert:
                                //       borderBottomLeftOrRightRadiusCreateAlert,
                                //   borderWidthGridTile: borderWidthGridTile,
                                //   fontSizeAlertButton:
                                //       fontSizeAlertsAndOtherMenuItemsSizedBox,
                                // )
                              ],
                            ))
                      ],
                    ));
              })),
    );
  }
}

/// Currency Pair TextField or Create Alert Button..
class CurrencyPairTextFieldOrCreateAlertButton extends StatelessWidget {
  const CurrencyPairTextFieldOrCreateAlertButton(
      {Key? key,
      required this.isCurrencyPairTextField,
      required this.heightCreateNewAlertContainer,
      required this.widthCurrencyPairTextField,
      required this.borderTopLeftOrRightRadiusCreateAlert,
      required this.borderBottomLeftOrRightRadiusCreateAlert,
      required this.borderWidthGridTile,
      this.fontSizeAlertButton = 0,
      this.fontSizeCurrencyPairAndPrice = 0,
      this.selectedInstrument = "None"})
      : super(key: key);

  final bool isCurrencyPairTextField;
  final double heightCreateNewAlertContainer;
  final double widthCurrencyPairTextField;
  final double borderTopLeftOrRightRadiusCreateAlert;
  final double borderBottomLeftOrRightRadiusCreateAlert;
  final double borderWidthGridTile;
  final double fontSizeCurrencyPairAndPrice;
  final double fontSizeAlertButton;
  final String selectedInstrument;

  @override
  Widget build(BuildContext context) {
    Widget? currencyPairOrTextButtonWidget;

    /// Selected Currency Pair Or Currency Pair To Select
    Widget currencyPairTextField = Container(
      // color: Colors.blue,
      child: TextFormField(
        key: ValueKey(selectedInstrument),
        initialValue: selectedInstrument,
        keyboardType: TextInputType.text,
        style: TextStyle(
            fontFamily: "PT-Mono",
            fontSize: fontSizeCurrencyPairAndPrice,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
            // contentPadding: EdgeInsets.only(left: 5),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: borderWidthGridTile / 4),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                        borderBottomLeftOrRightRadiusCreateAlert),
                    topLeft: Radius.circular(
                        borderTopLeftOrRightRadiusCreateAlert))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: borderWidthGridTile / 4),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                        borderBottomLeftOrRightRadiusCreateAlert),
                    topLeft: Radius.circular(
                        borderTopLeftOrRightRadiusCreateAlert)))),
      ),
    );

    /// "Add Alert" Button Text
    Widget addAlertButtonText = Text(
      'Add Alert',
      style: TextStyle(
          fontFamily: "PT-Mono",
          fontSize: fontSizeAlertButton,
          fontWeight: FontWeight.bold,
          color: Colors.white),
    );

    if (isCurrencyPairTextField) {
      currencyPairOrTextButtonWidget = currencyPairTextField;
    } else {
      currencyPairOrTextButtonWidget = addAlertButtonText;
    }

    print("selectedInstrument: $selectedInstrument");

    return Container(
        alignment: Alignment.center,
        height: heightCreateNewAlertContainer,
        width: widthCurrencyPairTextField,
        decoration: BoxDecoration(
            color: isCurrencyPairTextField ? Colors.transparent : Colors.black,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isCurrencyPairTextField
                    ? borderTopLeftOrRightRadiusCreateAlert
                    : 0),
                bottomLeft: Radius.circular(isCurrencyPairTextField
                    ? borderBottomLeftOrRightRadiusCreateAlert
                    : 0),
                topRight: Radius.circular(isCurrencyPairTextField == false
                    ? borderTopLeftOrRightRadiusCreateAlert
                    : 0),
                bottomRight: Radius.circular(isCurrencyPairTextField == false
                    ? borderBottomLeftOrRightRadiusCreateAlert
                    : 0)),
            border: Border.all(
                width: borderWidthGridTile / 4,
                color: isCurrencyPairTextField
                    ? Colors.transparent
                    : Colors.black)),
        child: currencyPairOrTextButtonWidget);
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

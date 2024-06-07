import 'dart:async';
import "dart:math";
import 'dart:ui';

import "package:flutter/material.dart";
import 'package:notify_me/data/data.dart';
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
  // bool isGridTileOrFilterOptionClickedOrKeyboardVisible = false;

  /// timer - relevantTimerTickTracker
  // Timer relevantTimerTickTracker =
  // Timer.periodic(const Duration(microseconds: 1), (timer) {
  //   timer.cancel();
  // });

  /// MAPS, LISTS & OTHER VALUES
  ///
  /// Prices - all instruments / symbols
  // Map<dynamic, dynamic> priceAllInstruments = {};

  /// list of all instruments
  List<dynamic> listOfAllInstruments = [];

  /// the currently selected instrument
  // String currentlySelectedInstrument = "";

  /// Index of selected grid tile
  // int indexSelectedGridTile = 3;

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

  /// keyboard visibility signalling bool
  double previousKeyboardValue = -1;
  bool isKeyboardVisible = true;

  /// entered text and whether it's valid - currency pair text form widget
  String? enteredTextCurrencyPairTextFormFieldWidget;
  bool isErrorEnteredTextCurrencyPairTextFormFieldWidget = false;

  /// a boolean that tracks whether a build has been triggered but not after
  /// a text has been entered into a textformfield
  bool isNonTextFormFieldTriggeredBuild = false;

  bool hasFocus = false;

  /// bool to track whether updatePrices provider method has be called
  bool hasInitializedUpdatePrices = false;

  /// create new alert - price adjustment button
  double fontSizeMinus = 0;

  @override
  void didChangeDependencies() async {
    print("");
    print("within didChangeDependencies");

    /// media query
    MediaQueryData mediaQuery = MediaQuery.of(context);

    paddingTop = mediaQuery.padding.top;
    paddingBottom = mediaQuery.padding.bottom;
    deviceWidth = mediaQuery.size.width;
    deviceHeight = mediaQuery.size.height;

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

    /// create new alert - font price adjustment button
    fontSizeMinus = 0.02682403433 * deviceHeight;

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
    dataProvider = Provider.of<DataProvider>(context, listen: false);

    /// initializing updatePrices
    if (hasInitializedUpdatePrices == false) {
      dataProvider!.updatePrices();
      hasInitializedUpdatePrices = true;
    }

    /// REGISTERING WHETHER THE KEYBOARD IS VISIBLE
    print("");
    print("Registering Keyboard's visibility");
    double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    /// if a bottom inset becomes visible i.e a keyboard is being displayed,
    /// signal that the keyboard has been toggled...
    if (bottomInset > 0) {
      // isGridTileOrFilterOptionClickedOrKeyboardVisible = true;
      isKeyboardVisible = true;
      print("Keyboard is visible");

      /// ...otherwise if the keyboard is being hidden, signal that the keyboard
      /// is still visible..
    } else if (bottomInset == 0 && previousKeyboardValue > 0) {
      // isGridTileOrFilterOptionClickedOrKeyboardVisible = true;
      isKeyboardVisible = true;
      print("Keyboard is visible");
    }

    /// updating previousKeyboardValue
    previousKeyboardValue = bottomInset;

    /// if keyboard has been hidden, log that it is no longer visible
    if (bottomInset == 0 && previousKeyboardValue == 0) {
      isKeyboardVisible = false;
    }

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant Homepage oldWidget) {
    // relevantTimerTickTracker.cancel();

    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  /// this method triggers a rebuild of this homepage widget when a grid tile
  /// is clicked..
  // void updateHomepageGridTileClicked(
  //     {required bool isGridTileClicked,
  //     required int indexNewSelectedGridTile}) {
  //   setState(() {
  //     isGridTileOrFilterOptionClickedOrKeyboardVisible = isGridTileClicked;
  //     indexSelectedGridTile = indexNewSelectedGridTile;
  //   });
  // }

  /// this method rebuilds the homepage state when a filter option is clicked
  // void updateHomepageFilterOptionClicked(
  //     {required Filter selectedFilterOption}) {
  //   dataProvider!.updateFilter(filter: selectedFilterOption);
  //
  //   setState(() {
  //     isGridTileOrFilterOptionClickedOrKeyboardVisible = true;
  //   });
  // }

  /// this method rebuilds the app when the user enters a valid instrument
  /// string within the add instrument's alert text field (bottom left)
  void updateHomepageNewInstrumentTextEntered({
    required String? enteredText,
    bool isErrorEnteredText = false,
    int? indexEnteredInstrument,
  }) {
    ///
    enteredTextCurrencyPairTextFormFieldWidget = enteredText;
    isErrorEnteredTextCurrencyPairTextFormFieldWidget = isErrorEnteredText;

    /// if the currency pair that's been entered into the
    /// CurrencyPairTextFormFieldWidget is valid, update the selected tile's
    /// index
    // if (indexEnteredInstrument != null){
    //   indexSelectedGridTile = indexEnteredInstrument;
    // }

    // /// bypass updatePrices
    // isGridTileOrFilterOptionClickedOrKeyboardVisible = true;
    //
    // /// set state...
    // if (!isKeyboardVisible) {
    //   setState(() {
    //     indexSelectedGridTile = indexEnteredInstrument;
    //   });
    // }
  }

  Widget build(BuildContext context) {
    print("");
    print("");
    print(
        "--------------------------------------------------------------------------------");
    print("");
    print("HOMEPAGE - BEGINNING (BUILT HOMEPAGE!)");
    print("");

    return Scaffold(
        // key: ValueKey("$indexSelectedGridTile$indexSelectedGridTile$indexSelectedGridTile"),
        appBar: null,
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
              // color: Colors.white,
              padding: EdgeInsets.only(
                  top: paddingTopScreen,
                  left: paddingLeftAndRightScreen,
                  right: paddingLeftAndRightScreen),

              /// a column - holds all elements on the screen
              child: Column(
                children: [
                  /// every widget above CreateAlertWidget
                  BlurrableWidgetsAboveCreateAlertWidget(
                      heightFirstSixGridTiles: heightFirstSixGridTiles,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      widthGridTile: widthGridTile,
                      heightGridTile: heightGridTile,
                      paddingTopGridTile: paddingTopGridTile,
                      borderWidthGridTile: borderWidthGridTile,
                      radiusGridTile: radiusGridTile,
                      heightPriceDirectionIcon: heightPriceDirectionIcon,
                      marginPriceDirectionAndCurrencyPair:
                          marginPriceDirectionAndCurrencyPair,
                      heightSymbolSizedBox: heightSymbolSizedBox,
                      fontSizeSymbols: fontSizeSymbols,
                      marginCurrencyPairAndCurrencyPrice:
                          marginCurrencyPairAndCurrencyPrice,
                      heightPriceSizedBox: heightPriceSizedBox,
                      fontSizePrices: fontSizePrices,
                      heightAlertsAndOtherMenuItemsSizedBox:
                          heightAlertsAndOtherMenuItemsSizedBox,
                      marginTopAlertsAndOtherMenuItemsSizedBox:
                          marginTopAlertsAndOtherMenuItemsSizedBox,
                      marginBottomAlertsAndOtherMenuItemsSizedBox:
                          marginBottomAlertsAndOtherMenuItemsSizedBox,
                      dataProvider: dataProvider,
                      fontSizeAlertsAndOtherMenuItemsSizedBox:
                          fontSizeAlertsAndOtherMenuItemsSizedBox,
                      widthDotDivider: widthDotDivider,
                      iconSizeDotDivider: iconSizeDotDivider,
                      widthSpaceInBetweenAlertsMenu:
                          widthSpaceInBetweenAlertsMenu,
                      heightAlertsListViewBuilder: heightAlertsListViewBuilder,
                      heightSwipeNotification: heightSwipeNotification,
                      fontSizeSwipeNotification: fontSizeSwipeNotification),

                  /// Create New Alert's Sized Box
                  CreateNewAlert(
                    heightCreateNewAlertContainer:
                        heightCreateNewAlertContainer,
                    widthCurrencyPairTextField: widthCurrencyPairTextField,
                    borderTopLeftOrRightRadiusCreateAlert:
                        borderTopLeftOrRightRadiusCreateAlert,
                    borderBottomLeftOrRightRadiusCreateAlert:
                        borderBottomLeftOrRightRadiusCreateAlert,
                    borderWidthGridTile: borderWidthGridTile,
                    fontSizeAlertsListTile: fontSizeAlertsListTile,
                    marginBottomAlertsAndOtherMenuItemsSizedBox:
                        marginBottomAlertsAndOtherMenuItemsSizedBox,
                    widthCreateNewAlertContainer: widthCreateNewAlertContainer,
                    fontSizeAlertsAndOtherMenuItemsSizedBox:
                        fontSizeAlertsAndOtherMenuItemsSizedBox,
                    fontSizePlus: fontSizePrices,
                    fontSizeMinus: fontSizeMinus,
                  )
                ],
              )),
        ));
  }
}

class CreateNewAlert extends StatelessWidget {
  const CreateNewAlert(
      {Key? key,
      required this.heightCreateNewAlertContainer,
      required this.widthCurrencyPairTextField,
      required this.borderTopLeftOrRightRadiusCreateAlert,
      required this.borderBottomLeftOrRightRadiusCreateAlert,
      required this.borderWidthGridTile,
      required this.fontSizeAlertsListTile,
      required this.marginBottomAlertsAndOtherMenuItemsSizedBox,
      required this.widthCreateNewAlertContainer,
      required this.fontSizeAlertsAndOtherMenuItemsSizedBox,
      required this.fontSizePlus,
      required this.fontSizeMinus})
      : super(key: key);

  final double heightCreateNewAlertContainer;
  final double widthCurrencyPairTextField;
  final double borderTopLeftOrRightRadiusCreateAlert;
  final double borderBottomLeftOrRightRadiusCreateAlert;
  final double borderWidthGridTile;
  final double fontSizeAlertsListTile;
  final double marginBottomAlertsAndOtherMenuItemsSizedBox;
  final double widthCreateNewAlertContainer;
  final double fontSizeAlertsAndOtherMenuItemsSizedBox;
  final double fontSizePlus;
  final double fontSizeMinus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: heightCreateNewAlertContainer,
        width: double.infinity,
        // color: Colors.tealAccent
        child: Row(
          children: <Widget>[
            /// currency pair text-field..
            CurrencyPairTextFieldOrCreateAlertButton(
              isCurrencyPairTextField: true,
              heightCreateNewAlertContainer: heightCreateNewAlertContainer,
              widthCurrencyPairTextField: widthCurrencyPairTextField,
              borderTopLeftOrRightRadiusCreateAlert:
                  borderTopLeftOrRightRadiusCreateAlert,
              borderBottomLeftOrRightRadiusCreateAlert:
                  borderBottomLeftOrRightRadiusCreateAlert,
              borderWidthGridTile: borderWidthGridTile,
              fontSizeCurrencyPairAndPrice: fontSizeAlertsListTile,
            ),

            /// spacing - currency pair text-field & currency
            /// price adjustment container..
            SizedBox(
                width:
                    marginBottomAlertsAndOtherMenuItemsSizedBox // 10 px -> iPhone 14 Pro Max
                ),

            /// currency price adjustment container
            CurrencyPriceAdjustmentContainer(
              heightCreateNewAlertContainer: heightCreateNewAlertContainer,
              widthCreateNewAlertContainer: widthCreateNewAlertContainer,
              borderWidthGridTile: borderWidthGridTile,
              fontSizePlus: fontSizePlus,
              fontSizeMinus: fontSizeMinus,
              fontSizePrice: fontSizeAlertsListTile,
            ),

            /// spacing - currency price adjustment container
            /// and "Add Alert" button..
            SizedBox(
                width:
                    marginBottomAlertsAndOtherMenuItemsSizedBox // 10 px -> iPhone 14 Pro Max
                ),

            /// add alert button..
            CurrencyPairTextFieldOrCreateAlertButton(
              isCurrencyPairTextField: false,
              heightCreateNewAlertContainer: heightCreateNewAlertContainer,
              widthCurrencyPairTextField: widthCurrencyPairTextField,
              borderTopLeftOrRightRadiusCreateAlert:
                  borderTopLeftOrRightRadiusCreateAlert,
              borderBottomLeftOrRightRadiusCreateAlert:
                  borderBottomLeftOrRightRadiusCreateAlert,
              borderWidthGridTile: borderWidthGridTile,
              fontSizeAlertButton: fontSizeAlertsAndOtherMenuItemsSizedBox,
            )
          ],
        ));
  }
}

/// Currency Price Adjustment Container
class CurrencyPriceAdjustmentContainer extends StatefulWidget {
  const CurrencyPriceAdjustmentContainer(
      {Key? key,
      required this.heightCreateNewAlertContainer,
      required this.widthCreateNewAlertContainer,
      required this.borderWidthGridTile,
      required this.fontSizeMinus,
      required this.fontSizePlus,
      required this.fontSizePrice})
      : super(key: key);

  final double heightCreateNewAlertContainer;
  final double widthCreateNewAlertContainer;
  final double borderWidthGridTile;
  final double fontSizeMinus;
  final double fontSizePlus;
  final double fontSizePrice;

  @override
  State<CurrencyPriceAdjustmentContainer> createState() =>
      _CurrencyPriceAdjustmentContainerState();
}

class _CurrencyPriceAdjustmentContainerState
    extends State<CurrencyPriceAdjustmentContainer> {
  DataProvider? dataProvider;

  int flexPlusAndMinusButtons = 0;
  int flexPriceContainer = 0;

  @override
  didChangeDependencies() {
    dataProvider = Provider.of<DataProvider>(context, listen: true);

    flexPlusAndMinusButtons = (0.1761363636 * 100).round();
    flexPriceContainer = 100 - (flexPlusAndMinusButtons * 2);

    print("flexPlusAndMinusButtons: $flexPlusAndMinusButtons");
    print("flexPriceContainer: $flexPriceContainer");

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    /// Price reduction icon flexible - sizedbox
    return Container(
        height: widget.heightCreateNewAlertContainer,
        width: widget.widthCreateNewAlertContainer,
        decoration: BoxDecoration(
            border: Border.all(width: widget.borderWidthGridTile / 4)),
        child: Row(
          children: [
            /// minus button
            Flexible(
                fit: FlexFit.tight,
                flex: flexPlusAndMinusButtons,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text("-",
                      style: TextStyle(
                          fontFamily: "PT-Mono",
                          fontWeight: FontWeight.normal,
                          fontSize: widget.fontSizeMinus)),
                )),

            /// price container
            Flexible(
                fit: FlexFit.tight,
                flex: flexPriceContainer,
                child: Container(
                    alignment: Alignment.center,
                    // color: Colors.yellow,

                    child: TextFormField(
                        initialValue: "0.6",
                        onChanged: (string){

                        },
                        style: TextStyle(
                            fontFamily: "PT-Mono",
                            fontWeight: FontWeight.bold,
                            fontSize: widget.fontSizePrice,
                        ),
                        textAlign: TextAlign.center,
                        // textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                            // contentPadding: EdgeInsets.only(left: 5),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent
                              ),
                            ),
                        )
                    )
                )
            ),

            /// plus button
            Flexible(
                fit: FlexFit.tight,
                flex: flexPlusAndMinusButtons,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text("+",
                      style: TextStyle(
                          fontFamily: "PT-Mono",
                          fontWeight: FontWeight.normal,
                          fontSize: widget.fontSizePlus)),
                ))
          ],
        ));
  }
}

/// Blurrable Widgets That Are Above CreateAlertWidget
/// blurred when text is being entered into the currency pair text form field
class BlurrableWidgetsAboveCreateAlertWidget extends StatefulWidget {
  const BlurrableWidgetsAboveCreateAlertWidget({
    Key? key,
    required this.heightFirstSixGridTiles,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.widthGridTile,
    required this.heightGridTile,
    required this.paddingTopGridTile,
    required this.borderWidthGridTile,
    required this.radiusGridTile,
    required this.heightPriceDirectionIcon,
    required this.marginPriceDirectionAndCurrencyPair,
    required this.heightSymbolSizedBox,
    required this.fontSizeSymbols,
    required this.marginCurrencyPairAndCurrencyPrice,
    required this.heightPriceSizedBox,
    required this.fontSizePrices,
    required this.heightAlertsAndOtherMenuItemsSizedBox,
    required this.marginTopAlertsAndOtherMenuItemsSizedBox,
    required this.marginBottomAlertsAndOtherMenuItemsSizedBox,
    required this.dataProvider,
    required this.fontSizeAlertsAndOtherMenuItemsSizedBox,
    required this.widthDotDivider,
    required this.iconSizeDotDivider,
    required this.widthSpaceInBetweenAlertsMenu,
    required this.heightAlertsListViewBuilder,
    required this.heightSwipeNotification,
    required this.fontSizeSwipeNotification,
  }) : super(key: key);

  final double heightFirstSixGridTiles;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double widthGridTile;
  final double heightGridTile;
  final double paddingTopGridTile;
  final double borderWidthGridTile;
  final double radiusGridTile;
  final double heightPriceDirectionIcon;
  final double marginPriceDirectionAndCurrencyPair;
  final double heightSymbolSizedBox;
  final double fontSizeSymbols;
  final double marginCurrencyPairAndCurrencyPrice;
  final double heightPriceSizedBox;
  final double fontSizePrices;
  final double heightAlertsAndOtherMenuItemsSizedBox;
  final double marginTopAlertsAndOtherMenuItemsSizedBox;
  final double marginBottomAlertsAndOtherMenuItemsSizedBox;
  final DataProvider? dataProvider;
  final double fontSizeAlertsAndOtherMenuItemsSizedBox;
  final double widthDotDivider;
  final double iconSizeDotDivider;
  final double widthSpaceInBetweenAlertsMenu;
  final double heightAlertsListViewBuilder;
  final double heightSwipeNotification;
  final double fontSizeSwipeNotification;

  @override
  State<BlurrableWidgetsAboveCreateAlertWidget> createState() =>
      _BlurrableWidgetsAboveCreateAlertWidgetState();
}

/// _BlurrableWidgetsAboveCreateAlertWidget's state
class _BlurrableWidgetsAboveCreateAlertWidgetState
    extends State<BlurrableWidgetsAboveCreateAlertWidget> {
  DataProvider? dataProvider;

  bool isFocusedCurrencyPairTextField = false;

  @override
  void didChangeDependencies() {
    dataProvider = Provider.of<DataProvider>(context, listen: true);
    isFocusedCurrencyPairTextField =
        dataProvider!.getHasFocusCurrencyPairTextField();

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // fit: StackFit.loose,
      children: [
        /// GridView + Alerts Menu + Alerts List View
        Container(
          child: Column(
            children: [
              /// Currency Pairs Container
              /// - holds a gridview builder..
              ContainerGridViewBuilder(
                heightFirstSixGridTiles: widget.heightFirstSixGridTiles,
                crossAxisSpacing: widget.crossAxisSpacing,
                mainAxisSpacing: widget.mainAxisSpacing,
                widthGridTile: widget.widthGridTile,
                heightGridTile: widget.heightGridTile,
                paddingTopGridTile: widget.paddingTopGridTile,
                borderWidthGridTile: widget.borderWidthGridTile,
                radiusGridTile: widget.radiusGridTile,
                heightPriceDirectionIcon: widget.heightPriceDirectionIcon,
                marginPriceDirectionAndCurrencyPair:
                    widget.marginPriceDirectionAndCurrencyPair,
                heightSymbolSizedBox: widget.heightSymbolSizedBox,
                currencyPairLazyLoading: currencyPairLazyLoading,
                currencyPairOrPrice: currencyPairOrPrice,
                fontSizeSymbols: widget.fontSizeSymbols,
                marginCurrencyPairAndCurrencyPrice:
                    widget.marginCurrencyPairAndCurrencyPrice,
                heightPriceSizedBox: widget.heightPriceSizedBox,
                fontSizePrices: widget.fontSizePrices,
              ),

              /// Alerts & Other menu items - SizedBox
              AlertsAndOtherMenuItems(
                  heightAlertsAndOtherMenuItemsSizedBox:
                      widget.heightAlertsAndOtherMenuItemsSizedBox,
                  mainAxisSpacing: widget.mainAxisSpacing,
                  marginTopAlertsAndOtherMenuItemsSizedBox:
                      widget.marginTopAlertsAndOtherMenuItemsSizedBox,
                  marginBottomAlertsAndOtherMenuItemsSizedBox:
                      widget.marginBottomAlertsAndOtherMenuItemsSizedBox,
                  dataProvider: widget.dataProvider,
                  fontSizeAlertsAndOtherMenuItemsSizedBox:
                      widget.fontSizeAlertsAndOtherMenuItemsSizedBox,
                  widthDotDivider: widget.widthDotDivider,
                  iconSizeDotDivider: widget.iconSizeDotDivider,
                  widthSpaceInBetweenAlertsMenu:
                      widget.widthSpaceInBetweenAlertsMenu),

              /// Alerts' Sized Box - contains a ListView builder
              Container(
                height: widget.heightAlertsListViewBuilder,
                width: double.infinity,
                decoration: BoxDecoration(
                  // color: Colors.yellow,
                  border: Border.all(
                      color: Colors.grey,
                      // const Color(0xFFFC8955)
                      width: widget.borderWidthGridTile / 6.1538461538),
                  borderRadius: BorderRadius.circular(widget.radiusGridTile),
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
                  height: widget.heightSwipeNotification,
                  width: double.infinity,
                  // color: Colors.blueAccent
                  child: Center(
                    child: Text("Swipe",
                        style: TextStyle(
                            fontFamily: "PT-Mono",
                            fontSize: widget.fontSizeSwipeNotification,
                            color: Colors.black)),
                  )),
            ],
          ),
        ),

        /// Positioned Widget to blur the homepage widget's content when
        /// text is being entered into the currency pair text form field..
        isFocusedCurrencyPairTextField == false
            ? Container(
                height: 0,
              )
            : Positioned(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaY: isFocusedCurrencyPairTextField == true ? 10 : 0,
                      sigmaX: isFocusedCurrencyPairTextField == true ? 10 : 0),
                  child: Container(
                      width: double.infinity,
                      height: widget.heightFirstSixGridTiles +
                          widget.heightAlertsAndOtherMenuItemsSizedBox +
                          widget.heightAlertsListViewBuilder +
                          widget.heightSwipeNotification,
                      color: Colors.yellow.withOpacity(0)),
                ),
              ),
      ],
    );
  }
}

/// Alerts and Other Menu Items
class AlertsAndOtherMenuItems extends StatefulWidget {
  const AlertsAndOtherMenuItems({
    Key? key,
    required this.heightAlertsAndOtherMenuItemsSizedBox,
    required this.mainAxisSpacing,
    required this.marginTopAlertsAndOtherMenuItemsSizedBox,
    required this.marginBottomAlertsAndOtherMenuItemsSizedBox,
    required this.dataProvider,
    required this.fontSizeAlertsAndOtherMenuItemsSizedBox,
    required this.widthDotDivider,
    required this.iconSizeDotDivider,
    required this.widthSpaceInBetweenAlertsMenu,
  }) : super(key: key);

  final double heightAlertsAndOtherMenuItemsSizedBox;
  final double mainAxisSpacing;
  final double marginTopAlertsAndOtherMenuItemsSizedBox;
  final double marginBottomAlertsAndOtherMenuItemsSizedBox;
  final DataProvider? dataProvider;
  final double fontSizeAlertsAndOtherMenuItemsSizedBox;
  final double widthDotDivider;
  final double iconSizeDotDivider;
  final double widthSpaceInBetweenAlertsMenu;

  @override
  State<AlertsAndOtherMenuItems> createState() =>
      _AlertsAndOtherMenuItemsState();
}

class _AlertsAndOtherMenuItemsState extends State<AlertsAndOtherMenuItems> {
  DataProvider? dataProvider;

  @override
  void didChangeDependencies() {
    dataProvider = Provider.of<DataProvider>(context, listen: true);

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print(
        "dataProvider!.getHasFocusCurrencyPairTextField() == true a: ${dataProvider!.getHasFocusCurrencyPairTextField() == true}");

    return SizedBox(

        /// an extra main axis spacing was added to the
        /// height of the grid view builder. Hence, an
        /// adjustments have to the made to the height of
        /// this widget as well as the padding top of it's
        /// child widget to ensure that no visible widget
        /// will cross the bottom iphone bar
        height: widget.heightAlertsAndOtherMenuItemsSizedBox -
            widget.mainAxisSpacing,
        width: double.infinity,
        // color: Colors.green,
        child: Padding(
          padding: EdgeInsets.only(
              top: widget.marginTopAlertsAndOtherMenuItemsSizedBox -
                  widget.mainAxisSpacing,
              bottom: widget.marginBottomAlertsAndOtherMenuItemsSizedBox),
          child: Row(children: <Widget>[
            /// title - "Alert"
            Text("Alerts",
                style: TextStyle(
                  fontFamily: "PT-Mono",
                  fontSize: widget.fontSizeAlertsAndOtherMenuItemsSizedBox,
                )),

            /// dot divider
            DotDivider(
                widthDotDivider: widget.widthDotDivider,
                iconSizeDotDivider: widget.iconSizeDotDivider),

            /// "Mute All" button
            CustomTextButton(
                currentFilter: Filter.none,
                selectedFilter: Filter.none,
                fontSize: widget.fontSizeAlertsAndOtherMenuItemsSizedBox),

            /// Space in between - "Alerts -> Mute All" &
            /// Instruments Filter ("All", "Forex", "Crypto")
            SizedBox(
              width: widget.widthSpaceInBetweenAlertsMenu,
            ),

            /// Instrument Filter Options
            InstrumentFilters(
              fontSizeAlertsAndOtherMenuItemsSizedBox:
                  widget.fontSizeAlertsAndOtherMenuItemsSizedBox,
              widthDotDivider: widget.widthDotDivider,
              iconSizeDotDivider: widget.iconSizeDotDivider,
            ),
          ]),
        ));
  }
}

/// Currency Pair TextField or Create Alert Button..
class CurrencyPairTextFieldOrCreateAlertButton extends StatefulWidget {
  const CurrencyPairTextFieldOrCreateAlertButton({
    Key? key,
    required this.isCurrencyPairTextField,
    required this.heightCreateNewAlertContainer,
    required this.widthCurrencyPairTextField,
    required this.borderTopLeftOrRightRadiusCreateAlert,
    required this.borderBottomLeftOrRightRadiusCreateAlert,
    required this.borderWidthGridTile,
    this.fontSizeAlertButton = 0,
    this.fontSizeCurrencyPairAndPrice = 0,
    this.dataProvider,
    this.updateHomepageNewInstrumentTextEntered,
  }) : super(key: key);

  final bool isCurrencyPairTextField;
  final double heightCreateNewAlertContainer;
  final double widthCurrencyPairTextField;
  final double borderTopLeftOrRightRadiusCreateAlert;
  final double borderBottomLeftOrRightRadiusCreateAlert;
  final double borderWidthGridTile;
  final Function({
    required String? enteredText,
    bool isErrorEnteredText,
    int indexEnteredInstrument,
  })? updateHomepageNewInstrumentTextEntered; //
  final double fontSizeCurrencyPairAndPrice;
  final double fontSizeAlertButton;
  final DataProvider? dataProvider;

  // final bool isKeyBoardStillVisible;

  @override
  State<CurrencyPairTextFieldOrCreateAlertButton> createState() =>
      _CurrencyPairTextFieldOrCreateAlertButtonState();
}

/// CurrencyPairTextFieldOrCreateAlertButton's state
class _CurrencyPairTextFieldOrCreateAlertButtonState
    extends State<CurrencyPairTextFieldOrCreateAlertButton> {
  /// data provider
  DataProvider? dataProvider;

  /// initial text form field's value
  String? initialValue;

  /// previously entered error text
  String? previouslyEnteredErrorText;

  /// timer to correct entered error text to the currently selected currency
  /// pair
  Timer correctEnteredErrorTextTimer =
      Timer(const Duration(microseconds: 1), () {});

  /// bool to signal whether instruments' prices are still being fetched?
  bool isFirstValueInMapOfAllInstrumentsContainsFetching = true;

  /// text color
  Color? textColor;

  /// color red int value
  int colorRedInt = 4294198070;

  /// Currency Pair Text Form Field Widget or "Add Alert" Button Widget
  Widget? currencyPairOrTextButtonWidget;

  /// Number of times the keyboard has been registered to have been hidden
  /// after entry of an invalid currency pair text into the currency pair
  /// text form field..
  int countNumberOfTimesKeyBoardHidden = 0;

  String? selectedInstrument;

  /// bool that tracks whether setState within the text form field's
  /// 'onChanged' function below is running..
  bool isRunningErrorOnChangedSetState = false;

  String? previouslyEnteredErrorTextFieldValue;

  /// focus node
  FocusNode focusNode = FocusNode();

  /// timer that checks whether prices have been fetched
  Timer hasFetchedPricesTimer =
      Timer.periodic(Duration(microseconds: 1), (timer) {
    timer.cancel();
  });

  void updateInitialValue(String newInitialValue) {
    initialValue = newInitialValue;
  }

  @override
  void initState() {
    print("Ran init State");

    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    print("");

    if (dataProvider == null) {
      dataProvider = Provider.of<DataProvider>(context, listen: true);

      // textColor = widget.isFetching == true ? Colors.grey : Colors.black;
      /// the initial color of the text form field's initialValue
      textColor ??= Colors.grey;

      /// created to serve as a stable value key that can be changed at the
      /// when the user has finished entering a text, especially an error
      /// text..
      ///
      /// It will also change when a new tile (valid pair) gets tapped on the
      /// grid..
      selectedInstrument = dataProvider!.getCurrentlySelectedInstrument();

      /// the first value of the text form field's
      /// Note: keyboard toggle will make it null due to multiple rebuilds
      initialValue ??= selectedInstrument;
      print("initialValue: $initialValue");

      print("textColorDidChangeDependencies: $textColor");
      print("textColor!.value: ${textColor!.value}");
    }

    // /// setting this widget's focus note in data provider
    // dataProvider!.hasFocusCurrencyPairTextField = focusNode;

    /// are instruments' prices still being fetched?
    isFirstValueInMapOfAllInstrumentsContainsFetching =
        dataProvider!.getIsFirstValueInMapOfAllInstrumentsContainsFetching();

    print(
        "textColor: didChangeDependencies: $textColor, int: ${textColor!.value}");
    int colorGreyInt = 4288585374;

    /// if instruments' prices have been fetched for the first time,
    /// color the text black
    if (isFirstValueInMapOfAllInstrumentsContainsFetching == false &&
        textColor!.value == colorGreyInt) {
      print("color changed to black");
      textColor = Colors.black;
    }

    /// Change the text form field's text to the selected grid tile's currency
    /// pair and its color to black when a user selects a valid currency
    /// pair or when the app is running for the first time
    // since previouslyEnteredErrorTextFieldValue will be valid in such a situation:
    ///
    ///    a. !isRunningErrorOnChangedSetState - true for the first of many
    ///       setState functions that'd be triggered when the software
    ///       keyboard is disappearing or when the user clicks "done"
    //    b. previouslyEnteredErrorTextFieldValue - not null when an invalid
    //       currency pair is entered into the text form field..
    ///
    /// This helps to ensure that when a grid tile is clicked even after an
    /// invalid currency pair has been entered into the text form field,
    /// the selected grid tile's currency pair will still get displayed and
    /// with the right color (Colors.black)..

    // print("isRunningErrorOnChangedSetState == false d : ${isRunningErrorOnChangedSetState == false}");
    print(
        "textColor!.value != colorRedInt d: ${textColor!.value != colorRedInt}");
    print("focusNode.hasFocus d: ${focusNode.hasFocus == false}");
    print(
        "isFirstValueInMapOfAllInstrumentsContainsFetching  == false d : ${isFirstValueInMapOfAllInstrumentsContainsFetching == false}");

    if ((textColor!.value != colorRedInt ||
            correctEnteredErrorTextTimer.isActive) &&
        focusNode.hasFocus == false &&
        isFirstValueInMapOfAllInstrumentsContainsFetching == false) {
      print("initial value before change: ${initialValue}");
      // setState(() {
      correctEnteredErrorTextTimer.cancel();
      textColor = Colors.black;
      selectedInstrument = dataProvider!.getCurrentlySelectedInstrument();
      initialValue = selectedInstrument;

      // });
    }

    /// updating the text form field after an error currency pair text has been
    /// entered, submitted and displayed..
    if (textColor!.value == colorRedInt && focusNode.hasFocus == false) {
      // setState(() {
      correctEnteredErrorTextTimer = Timer(const Duration(seconds: 5), () {
        setState(() {
          print("colorRedInt is");
          String currentlySelectedPair =
              dataProvider!.getCurrentlySelectedInstrument();

          textColor = Colors.black;

          /// if the value key's 'selectedInstrument' variable does not change,
          /// the text form field widget will not get rebuilt. In this case,
          /// when an invalid currency pair, which would be colored red, is
          /// entered into the text form field at the bottom left corner,
          /// an update will not be made to reflect the currently selected
          /// pair if the value key's "selectedInstrument" isn't switched to
          /// another case (upper case or lower case, whichever is relevant)
          if (selectedInstrument == selectedInstrument!.toUpperCase()) {
            selectedInstrument = currentlySelectedPair.toLowerCase();
            initialValue = currentlySelectedPair.toUpperCase();
          } else if (selectedInstrument == selectedInstrument!.toLowerCase()) {
            selectedInstrument = currentlySelectedPair.toUpperCase();
            initialValue = currentlySelectedPair.toUpperCase();
          }
          print(
              "currentlySelectedPair == previouslyEnteredErrorText: ${currentlySelectedPair == previouslyEnteredErrorText}");
        });
      });
      // });
    }

    print("");

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(
      covariant CurrencyPairTextFieldOrCreateAlertButton oldWidget) {
    print("");

    // if the entered currency pair text is invalid, set the value key to
    // the error text,
    if (textColor!.value == colorRedInt) {
      // selectedInstrument = initialValue;
    } else {
      // selectedInstrument = dataProvider!.getCurrentlySelectedInstrument();
    }

    /// Change the text form field's text to the selected grid tile's currency
    /// pair and its color to black when a user selects a valid currency
    /// pair or when the app is running for the first time
    // since previouslyEnteredErrorTextFieldValue will be valid in such a situation:
    ///
    ///    a. !isRunningErrorOnChangedSetState - true for the first of many
    ///       setState functions that'd be triggered when the software
    ///       keyboard is disappearing or when the user clicks "done"
    //    b. previouslyEnteredErrorTextFieldValue - not null when an invalid
    //       currency pair is entered into the text form field..
    ///
    /// This helps to ensure that when a grid tile is clicked even after an
    /// invalid currency pair has been entered into the text form field,
    /// the selected grid tile's currency pair will still get displayed and
    /// with the right color (Colors.black)..

    // print("isRunningErrorOnChangedSetState == false: ${isRunningErrorOnChangedSetState == false}");
    print(
        "textColor!.value != colorRedInt: ${textColor!.value != colorRedInt}");
    print("focusNode.hasFocus: ${focusNode.hasFocus == false}");
    print(
        "isFirstValueInMapOfAllInstrumentsContainsFetching == false: ${isFirstValueInMapOfAllInstrumentsContainsFetching == false}");

    print("Colors.red.value: ${Colors.red.value}");
    // if (
    //   isRunningErrorOnChangedSetState == false && textColor!.value != colorRedInt && focusNode.hasFocus == false  && isFirstValueInMapOfAllInstrumentsContainsFetching == false
    // ) {
    //   print("initial value before change: ${initialValue}");
    //   textColor = Colors.black;
    //   initialValue = dataProvider!.getCurrentlySelectedInstrument();
    //   //   print("initial value after change: ${initialValue}");
    // }

    print("initialValue didUpdateWidget: ${initialValue}");

    print("focusNode.hasFocus: ${focusNode.hasFocus}");

    // /// setting this widget's focus note in data provider
    // dataProvider!.hasFocusCurrencyPairTextField = focusNode;

    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    // }
  }

  @override
  Widget build(BuildContext context) {
    print("textColor: $textColor");
    print("initialValue build: ${initialValue}");

    print("selectedInstrument: ${selectedInstrument}");
    print("");

    /// Selected Currency Pair Or Currency Pair To Select
    Widget currencyPairTextField = TextFormField(
      key: ValueKey(selectedInstrument),
      enabled: isFirstValueInMapOfAllInstrumentsContainsFetching ? false : true,
      focusNode: focusNode,
      initialValue: initialValue,
      keyboardType: TextInputType.text,
      onTap: () {
        dataProvider!.updateHasFocusCurrencyPairTextField(hasFocus: true);
      },
      onChanged: (enteredText) {
        // /// setting this widget's focus note in data provider
        // dataProvider!.hasFocusCurrencyPairTextField = true;

        print("within onChanged");

        /// entered text if any
        // String enteredTextUpper = string == null ? "" : string.toUpperCase();
        String enteredTextUpper = enteredText.toUpperCase();

        print("enteredTextUpper: ${enteredTextUpper}");

        /// checking whether the entered text is a valid instrument
        List<dynamic> listOfAllInstruments =
            dataProvider!.getListOfAllInstruments();

        /// if the entered instrument is not valid, display the entered text
        /// with an error color - red
        if (!listOfAllInstruments.contains(enteredTextUpper)) {
          print('does not contain: ${enteredTextUpper}');

          // if (widget.isKeyBoardStillVisible == false){

          setState(() {
            /// this variable will allow 'enteredText' and color red to be
            /// set on the first set state execution despite the numerous
            /// set states the keyboard getting toggled will cause to be
            /// executed..
            // isRunningErrorOnChangedSetState = true;
            textColor = Colors.red;
            previouslyEnteredErrorText = enteredText;
            // initialValue = enteredTextUpper;

            /// to cancel any existing _updateCurrencyPairManually timer in
            /// dataProvider
            dataProvider!.updateEnteredTextCurrencyPair(
                enteredText: null,
                isErrorEnteredText: null,
                focusNode: focusNode);
          });

          // }

          /// ... otherwise, display the entered text with the default black
          /// color
          // update the app and scroll to the entered instrument's
          // row within the app's gridview builder
          // show the focusedBorder
        } else {
          print('contains: ${enteredTextUpper}');

          setState(() {
            // initialValue = enteredTextUpper;
            // isRunningErrorOnChangedSetState = false;
            textColor = Colors.black;

            dataProvider!.updateEnteredTextCurrencyPair(
                enteredText: enteredTextUpper,
                isErrorEnteredText: null,
                focusNode: focusNode);
          });
        }
      },
      onEditingComplete: () {
        focusNode.unfocus();

        /// setting this widget's focus note in data provider
        dataProvider!.updateHasFocusCurrencyPairTextField(hasFocus: false);

        print("dataProvider!.hasFocusCurrencyPairTextField");
      },
      style: TextStyle(
          fontFamily: "PT-Mono",
          fontSize: widget.fontSizeCurrencyPairAndPrice,
          fontWeight: FontWeight.bold,
          color: textColor),
      decoration: InputDecoration(
          // contentPadding: EdgeInsets.only(left: 5),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: widget.borderWidthGridTile / 4),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                      widget.borderBottomLeftOrRightRadiusCreateAlert),
                  topLeft: Radius.circular(
                      widget.borderTopLeftOrRightRadiusCreateAlert))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: widget.borderWidthGridTile / 4),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                      widget.borderBottomLeftOrRightRadiusCreateAlert),
                  topLeft: Radius.circular(
                      widget.borderTopLeftOrRightRadiusCreateAlert))),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: widget.borderWidthGridTile / 4),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                      widget.borderBottomLeftOrRightRadiusCreateAlert),
                  topLeft: Radius.circular(
                      widget.borderTopLeftOrRightRadiusCreateAlert))),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: widget.borderWidthGridTile / 4, color: Colors.red),
              borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(widget.borderBottomLeftOrRightRadiusCreateAlert), topLeft: Radius.circular(widget.borderTopLeftOrRightRadiusCreateAlert)))),
    );

    /// "Add Alert" Button Text
    Widget addAlertButtonText = Text(
      'Add Alert',
      style: TextStyle(
          fontFamily: "PT-Mono",
          fontSize: widget.fontSizeAlertButton,
          fontWeight: FontWeight.bold,
          color: Colors.white),
    );

    if (widget.isCurrencyPairTextField) {
      currencyPairOrTextButtonWidget = currencyPairTextField;
    } else {
      currencyPairOrTextButtonWidget = addAlertButtonText;
    }

    return Container(
        alignment: Alignment.center,
        height: widget.heightCreateNewAlertContainer,
        width: widget.widthCurrencyPairTextField,
        decoration: BoxDecoration(
            color: widget.isCurrencyPairTextField
                ? Colors.transparent
                : Colors.black,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(widget.isCurrencyPairTextField
                    ? widget.borderTopLeftOrRightRadiusCreateAlert
                    : 0),
                bottomLeft: Radius.circular(widget.isCurrencyPairTextField
                    ? widget.borderBottomLeftOrRightRadiusCreateAlert
                    : 0),
                topRight: Radius.circular(
                    widget.isCurrencyPairTextField == false
                        ? widget.borderTopLeftOrRightRadiusCreateAlert
                        : 0),
                bottomRight: Radius.circular(
                    widget.isCurrencyPairTextField == false
                        ? widget.borderBottomLeftOrRightRadiusCreateAlert
                        : 0)),
            border: Border.all(
                width: widget.borderWidthGridTile / 4,
                color: widget.isCurrencyPairTextField
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

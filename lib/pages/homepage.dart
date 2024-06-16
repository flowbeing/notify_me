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

  /// dimensions - alerts ListView Builder & List Tile
  double heightAlertsListViewBuilder = 0;
  double radiusListViewBuilder = 0;
  double fontSizeNoAlerts = 0; //
  double fontSizeAlertsListTile = 0; //
  double borderWidthListViewBuilder = 0;

  double heightListTile = 0;
  double widthListTile = 0;

  double widthListTileLeading = 0;
  double widthListTileTitle = 0;
  double widthListTileTrailing = 0;

  double paddingLeftTrailing = 0;
  double paddingRightTrailing = 0;
  double paddingMiddleTrailing = 0;
  double paddingBottomListTile = 0;

  double widthPriceUpOrDownIndicator = 0;
  double widthMutePauseOrUnallowButton = 0;
  double widthUnMutePlayOrAllowButton = 0;
  double widthDeleteButton = 0;

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

    heightListTile = 0.05364806867 * deviceHeight;
    widthListTile = 0.9534883721 * deviceWidth;

    widthListTileLeading = 0.2585365854 * widthListTile;
    widthListTileTitle = 0.4756097561 * widthListTile;
    widthListTileTrailing = 0.2658536585 * widthListTile;

    paddingLeftTrailing = 0.04634146341 * widthListTile; //
    paddingRightTrailing = paddingLeftTrailing; //
    paddingMiddleTrailing = 0.03902439024 * widthListTile; //
    paddingBottomListTile = 0.01287553648 * deviceHeight;

    widthPriceUpOrDownIndicator = paddingLeftTrailing; //

    widthMutePauseOrUnallowButton = 0.02195121951 * widthListTile; //
    widthUnMutePlayOrAllowButton = 0.02926829268 * widthListTile; //
    widthDeleteButton = 0.01951219512 * widthListTile; //

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
                      heightSwipeNotification: heightSwipeNotification,
                      fontSizeSwipeNotification: fontSizeSwipeNotification,
                      heightAlertsListViewBuilder: heightAlertsListViewBuilder,
                      fontSizeAListTile: fontSizeAlertsListTile,
                      heightListTile: heightListTile,
                      widthListTileLeading: widthListTileLeading,
                      widthListTileTitle: widthListTileTitle,
                      widthListTileTrailing: widthListTileTrailing,
                      paddingLeftTrailing: paddingLeftTrailing,
                      paddingRightTrailing: paddingRightTrailing,
                      paddingMiddleTrailing: paddingMiddleTrailing,
                      paddingBottomListTile: paddingBottomListTile,
                      widthPriceUpOrDownIndicator: widthPriceUpOrDownIndicator,
                      widthMutePauseOrUnallowButton:
                          widthMutePauseOrUnallowButton,
                      widthUnMutePlayOrAllowButton:
                          widthUnMutePlayOrAllowButton,
                      widthDeleteButton: widthUnMutePlayOrAllowButton),

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

  int numTimesDidChangeDependenciesRan=0;

  int flexPlusAndMinusButtons = 0;
  int flexPriceContainer = 0;

  /// Have prices been fetched for the first time or not..
  bool isFirstTimeFetching = true;

  /// bool to signal whether the alert price has been edited at least once
  bool hasEditedAlertPriceAtLeastOnce = false;

  /// selected instrument - used as currency price text form field's key
  String selectedInstrument = "";
  String? initialValuePrice;

  /// alert price text form field's focus node
  FocusNode? focusNodeAlertPrice;

  /// alert price (currently selected currency price's) text color
  Color? textColor;

  /// color red int value
  int colorRedInt = 4294198070;

  /// previously entered error text (alert price)
  String previouslyEnteredErrorText = "";

  /// timer that corrects an entered invalid alert price
  Timer correctEnteredErrorTextTimer =
      Timer(const Duration(microseconds: 1), () {});

  /// bool that signals whether the current alert price is valid or not
  bool isValidCurrentAlertPrice = true;

  /// the currently selected pair's latest price
  String currentPairLatestPrice = "";

  /// setting the current entered alert price text, whether valid or not,
  /// selected, updated, or entered
  String enteredAlertPriceText = "";

  /// signalling whether the minus or plus buttons have been long pressed
  // bool isLongPressedButton=false;

  /// addition or subtraction timer - to add or subtract a unit of price at
  /// interval
  Timer additionOrSubtractionTimer =
      Timer.periodic(const Duration(microseconds: 1), (timer) {
    timer.cancel();
  });

  // final _formKey = GlobalKey<FormState>();

  // @override
  // void initState() {
  //
  //   print("initializedState focusNode");
  //   focusNodeAlertPrice = FocusNode(debugLabel: "alertPrice$selectedInstrument");
  //
  //   // TODO: implement initState
  //   super.initState();
  // }

  @override
  didChangeDependencies() {
    print("begin didChangeDependencies CurrencyPriceAdjustmentContainer");


    /// prevents the alert price textform field from rebuilding everytime
    /// notifyListeners gets called, since selectedInstrument (valueKey) will
    /// change with every execution of notifyListeners()
    if (dataProvider == null) {
      dataProvider = Provider.of<DataProvider>(context, listen: true);

      /// setting the currently selected currency pair's price text form
      /// field's valueKey and alert price.. a mouthful
      selectedInstrument = dataProvider!.getCurrentlySelectedInstrument();

      /// setting the initial alert price
      initialValuePrice =
          dataProvider!.getAlertPriceCurrencyPriceTextField();


      print("initializedState focusNode");
      focusNodeAlertPrice = FocusNode(
          debugLabel: "alertPrice$selectedInstrument", skipTraversal: true);

      /// setting the currently selected pair's latest price
      currentPairLatestPrice = initialValuePrice!;

      /// setting the current entered alert price text, whether selected,
      /// updated, or entered
      enteredAlertPriceText = currentPairLatestPrice;

      /// saving the original alert price in the data provider class for use
      /// (addition to map of all alerts when triggered) later..
      dataProvider!.setOriginalOrEditedAlertPriceCurrencyPriceTextField(
          originalOrUserEditedAlertPrice: enteredAlertPriceText);

      flexPlusAndMinusButtons = (0.2 * 100).round(); //0.1761363636
      flexPriceContainer = 100 - (flexPlusAndMinusButtons * 2);

      print("flexPlusAndMinusButtons: $flexPlusAndMinusButtons");
      print("flexPriceContainer: $flexPriceContainer");
    }

    /// setting alert price string's color depending on whether prices have
    /// been fetched for the first time or not..
    isFirstTimeFetching =
        dataProvider!.getIsFirstValueInMapOfAllInstrumentsContainsFetching();

    /// so far the alert price's text form field's initial value has not been
    /// edited or a new grid tile has been selected, update the alert price's
    /// text form field's content
    String currentSelectedInstrument =
        dataProvider!.getCurrentlySelectedInstrument();
    String currentlySelectedInstrumentPrice =
        dataProvider!.getAlertPriceCurrencyPriceTextField();

    /// setting the currently selected pair's latest price:
    ///
    /// used to:
    /// 1. calculate the number of dots the current pair's original price
    ///    has
    /// 2. holds the latest price of the selected currency pair. Hence,
    ///    it's used to signal to the user that the selected currency pair's
    ///    latest price cannot be added as an alert price..
    ///
    ///    Ability to do so will cause the app to play a price alert sound
    ///    whenever an alert gets added to the list of alerts. Now, that
    ///    would be annoying..
    currentPairLatestPrice = dataProvider!.getCurrentlySelectedInstrumentPrice();

    print("currentPairLatestPrice get: ${currentPairLatestPrice}");


    if (currentSelectedInstrument.toLowerCase() ==
            selectedInstrument.toLowerCase() &&
        focusNodeAlertPrice!.hasFocus == false) {
      print(
          "hasEditedAlertPriceAtLeastOnce: ${hasEditedAlertPriceAtLeastOnce}");
      if (hasEditedAlertPriceAtLeastOnce == false) {
        if (isFirstTimeFetching) {
          textColor = Colors.grey;
        } else {
          textColor = Colors.black;
        }

        /// checking whether the current valueKey's case matches the currently
        /// selected currency pair's case (upper case)
        ///
        /// if so switch the case so that the updated price can be reflected
        if (currentSelectedInstrument == selectedInstrument) {
          selectedInstrument =
              currentSelectedInstrument.toLowerCase(); // lowercase
          initialValuePrice = currentlySelectedInstrumentPrice;
        } else {
          selectedInstrument = currentSelectedInstrument; // uppercase
          initialValuePrice = currentlySelectedInstrumentPrice;
        }

        /// if prices have been fetched at least once and the current alert price
        /// does not belong to a "demo" priced currency pair, ie. when the
        /// grid view widget has loaded all currency pairs and their prices
        /// correctly, set the alert price one unit of price higher than the
        /// current or updated price..
        if (isFirstTimeFetching==false && initialValuePrice!="0.00000"){
          /// ensuring that the initial alert price will be one unit more than the
          /// currently selected currency pair's price
          initialValuePrice =
              dataProvider!.getAlertPriceCurrencyPriceTextField();
          /// a map containing information about the current currency pair's
          /// unit price and count of decimal numbers
          Map unitPriceDataCurrentPairMap=dataProvider!.subtractOrAddOneOrFiveUnitsFromAlertPrice(
              currentPairPriceStructure: initialValuePrice!,
              alertOperationType: AlertOperationType.calcUnitPrice
          );
          /// current pair's unit price
          String unitPriceCurrentPair=unitPriceDataCurrentPairMap["aUnitOfTheAlertPrice"];
          /// number of decimal numbers the current pair's price has
          int countOfNumAfterDot=unitPriceDataCurrentPairMap["countOfNumAfterDot"];
          initialValuePrice=(double.parse(initialValuePrice!) + double.parse(unitPriceCurrentPair)).toStringAsFixed(countOfNumAfterDot);
        }

        /// setting the current entered alert price text, whether selected,
        /// updated, or entered
        ///
        /// used below to save the current alert price in data_provider.dart
        /// every time the current currency pair's price gets updated
        /// automatically or after the user adds to or subtracts from it and
        /// then saves it manually..
        enteredAlertPriceText = initialValuePrice!;

        /// saving the original alert price in the data provider class for use
        /// (addition to map of all alerts when triggered) later..
        dataProvider!.setOriginalOrEditedAlertPriceCurrencyPriceTextField(
            originalOrUserEditedAlertPrice: enteredAlertPriceText);
      }
    }

    /// else if a new grid tile has been selected, switch the price
    ///
    /// focusNode.hasFocus signals that no update should be made to the alert
    /// price's text form field when a user is still entering text..
    else if (currentSelectedInstrument.toLowerCase() !=
            selectedInstrument.toLowerCase() &&
        focusNodeAlertPrice!.hasFocus == false) {
      print("updatedFilters?a");

      textColor = Colors.black;

      selectedInstrument = currentSelectedInstrument; // uppercase
      initialValuePrice = currentlySelectedInstrumentPrice;

      print("selectedInstrument: $selectedInstrument");
      print("initialValuePrice: $initialValuePrice");
      print("updatedFilters?b");

      /// if prices have been fetched at least once, ie. when the grid view
      /// widget has loaded all currency pairs and their prices correctly,
      /// set the alert price one unit of price higher than the current or
      /// updated price..
      if (isFirstTimeFetching==false && initialValuePrice!="0.00000"){
        /// ensuring that the initial alert price will be one unit more than the
        /// currently selected currency pair's price
        initialValuePrice =
            dataProvider!.getAlertPriceCurrencyPriceTextField();
        /// a map containing information about the current currency pair's
        /// unit price and count of decimal numbers
        Map unitPriceDataCurrentPairMap=dataProvider!.subtractOrAddOneOrFiveUnitsFromAlertPrice(
            currentPairPriceStructure: initialValuePrice!,
            alertOperationType: AlertOperationType.calcUnitPrice
        );
        /// current pair's unit price
        String unitPriceCurrentPair=unitPriceDataCurrentPairMap["aUnitOfTheAlertPrice"];
        /// number of decimal numbers the current pair's price has
        int countOfNumAfterDot=unitPriceDataCurrentPairMap["countOfNumAfterDot"];
        initialValuePrice=(double.parse(initialValuePrice!) + double.parse(unitPriceCurrentPair)).toStringAsFixed(countOfNumAfterDot);
      }

      /// setting the current entered alert price text, whether selected,
      /// updated, or entered
      ///
      /// used below to save the current alert price in data_provider.dart
      /// every time the current currency pair's price gets updated
      /// automatically or after the user adds to or subtracts from it and
      /// then saves it manually..
      enteredAlertPriceText = initialValuePrice!;

      /// resetting this signal variable to ensure that price updates
      /// will get displayed again at intervals after editing the alert
      /// price of a previously selected currency pair..
      hasEditedAlertPriceAtLeastOnce = false;

      /// saving the original alert price in the data provider class for use
      /// (addition to map of all alerts when triggered) later..
      dataProvider!.setOriginalOrEditedAlertPriceCurrencyPriceTextField(
          originalOrUserEditedAlertPrice: enteredAlertPriceText);
    }

    /// updates the alert price after an error currency pair text has been
    /// entered, submitted and displayed..
    if (textColor!.value == colorRedInt &&
        focusNodeAlertPrice!.hasFocus == false) {
      // setState(() {
      correctEnteredErrorTextTimer =
          Timer(const Duration(milliseconds: 2250), () {
        setState(() {
          print("colorRedInt is");
          String currentlySelectedPairAlertPrice =
              dataProvider!.getAlertPriceCurrencyPriceTextField();

          textColor = Colors.black;

          /// if the value key's 'selectedInstrument' variable does not change,
          /// the text form field widget will not get rebuilt. In this case,
          /// when an invalid currency pair, which would be colored red, is
          /// entered into the text form field at the bottom left corner,
          /// an update will not be made to reflect the currently selected
          /// pair if the value key's "selectedInstrument" isn't switched to
          /// another case (upper case or lower case, whichever is relevant)
          if (selectedInstrument == selectedInstrument.toUpperCase()) {
            selectedInstrument = selectedInstrument.toLowerCase();
            initialValuePrice = currentlySelectedInstrumentPrice.toUpperCase();
          } else if (selectedInstrument == selectedInstrument.toLowerCase()) {
            selectedInstrument = selectedInstrument.toUpperCase();
            initialValuePrice = currentlySelectedInstrumentPrice.toUpperCase();
          }
          print(
              "currentlySelectedInstrumentPrice == previouslyEnteredErrorText: ${currentlySelectedInstrumentPrice == previouslyEnteredErrorText}");

          /// if prices have been fetched at least once, ie. when the grid view
          /// widget has loaded all currency pairs and their prices correctly,
          /// set the alert price one unit of price higher than the current or
          /// updated price..
          if (isFirstTimeFetching==false && initialValuePrice!="0.00000"){
            /// ensuring that the initial alert price will be one unit more than the
            /// currently selected currency pair's price
            initialValuePrice =
                dataProvider!.getAlertPriceCurrencyPriceTextField();
            /// a map containing information about the current currency pair's
            /// unit price and count of decimal numbers
            Map unitPriceDataCurrentPairMap=dataProvider!.subtractOrAddOneOrFiveUnitsFromAlertPrice(
                currentPairPriceStructure: initialValuePrice!,
                alertOperationType: AlertOperationType.calcUnitPrice
            );
            /// current pair's unit price
            String unitPriceCurrentPair=unitPriceDataCurrentPairMap["aUnitOfTheAlertPrice"];
            /// number of decimal numbers the current pair's price has
            int countOfNumAfterDot=unitPriceDataCurrentPairMap["countOfNumAfterDot"];
            initialValuePrice=(double.parse(initialValuePrice!) + double.parse(unitPriceCurrentPair)).toStringAsFixed(countOfNumAfterDot);
          }

          /// setting the current entered alert price text, whether selected,
          /// updated, or entered
          ///
          /// used below to save the current alert price in data_provider.dart
          /// every time the current currency pair's price gets updated
          /// automatically or after the user adds to or subtracts from it and
          /// then saves it manually..
          enteredAlertPriceText = initialValuePrice!;

          /// saving the original alert price in the data provider class for use
          /// (addition to map of all alerts when triggered) later..
          dataProvider!.setOriginalOrEditedAlertPriceCurrencyPriceTextField(
              originalOrUserEditedAlertPrice: enteredAlertPriceText);
        });
      });
      // });
    }

    /// register this didChangeDependencies call
    numTimesDidChangeDependenciesRan+=1;

    print("end didChangeDependencies CurrencyPriceAdjustmentContainer");

    super.didChangeDependencies();
  }

  void subtractOrAddOneUnitToAlertPrice({required bool isSubtract}) {
    if (isValidCurrentAlertPrice) {
      String decreasedOrIncreasedAlertPrice = dataProvider!
          .subtractOrAddOneOrFiveUnitsFromAlertPrice(
              currentPairPriceStructure: currentPairLatestPrice,
              alertPrice: enteredAlertPriceText,
              isSubtract: isSubtract ? true : false);

      print(
          "decreasedOrIncreasedAlertPrice: ${decreasedOrIncreasedAlertPrice}");

      // focusNodeAlertPrice!.requestFocus();

      setState(() {
        /// was the keyboard visible before the button was
        /// clicked
        bool isKeyboardVisibleBeforeButtonClick = focusNodeAlertPrice!.hasFocus;

        /// setting the (user edited version) current alert price, for use in
        /// future subtraction or additions, since initialValuePrice can be both
        /// the price structure and user edited alert price..
        enteredAlertPriceText = decreasedOrIncreasedAlertPrice;

        /// setting the alert price value that should be displayed.
        ///
        /// Can be both the price structure and user edited alert price..
        initialValuePrice = decreasedOrIncreasedAlertPrice;

        /// saving the edited alert price in the data provider class for use
        /// later..
        dataProvider!.setOriginalOrEditedAlertPriceCurrencyPriceTextField(
            originalOrUserEditedAlertPrice: enteredAlertPriceText);

        if (selectedInstrument == selectedInstrument.toUpperCase()) {
          /// disposing the old focus node to provide access
          /// to the new alert price text form field's focus
          /// node
          focusNodeAlertPrice!.dispose();

          /// updating the valueKey to ensure that a new
          /// instance of alert price's text form field will be
          /// created with a new alert price
          selectedInstrument = selectedInstrument.toLowerCase();

          /// creating a new focus node for the new alert price
          /// text form field
          focusNodeAlertPrice = FocusNode(
              // debugLabel: "alertPrice$selectedInstrument",
              // skipTraversal: true
              );

          print("focusNodeAlertPrice: ${focusNodeAlertPrice}");

          /// the new alert price
          // initialValuePrice = decreasedAlertPrice;

        } else if (selectedInstrument == selectedInstrument.toLowerCase()) {
          /// disposing the old focus node to provide access
          /// to the new alert price text form field's focus
          /// node
          focusNodeAlertPrice!.dispose();

          /// updating the valueKey to ensure that a new
          /// instance of alert price's text form field will be
          /// created with a new alert price
          selectedInstrument = selectedInstrument.toUpperCase();

          /// creating a new focus node for the new alert price
          /// text form field
          focusNodeAlertPrice = FocusNode(
              // debugLabel: "alertPrice$selectedInstrument",
              // skipTraversal: true
              );

          print("focusNodeAlertPrice: ${focusNodeAlertPrice}");

          /// the new alert price
          // initialValuePrice = decreasedAlertPrice;
        }

        print("alertPrice hasFocus: ${isKeyboardVisibleBeforeButtonClick}");

        /// ensuring that the keyboard remains visible if it
        /// was visible before this button was clicked
        /// - (after the old focus node has been disposed)..
        if (isKeyboardVisibleBeforeButtonClick) {
          // FocusScope.of(context).nextFocus();
          print("requestingFocus");
          // FocusScope.of(context).requestFocus(focusNodeAlertPrice!);

          focusNodeAlertPrice!.requestFocus();
          print(
              "focusNodeAlertPrice.hasFocus:${focusNodeAlertPrice!.hasFocus}");
          print("requestedFocus");
          // FocusScope.of(context).requestFocus(focusNodeAlertPrice!);

        }

        /// ensuring that the current alert price value will
        /// remain and not be affected by price updates
        hasEditedAlertPriceAtLeastOnce = true;
      });

      // print("alertPrice focusNode hasFocus: ${focusNodeAlertPrice!.hasFocus}");

      // setState(() {

      // FocusScope.of(context).requestFocus(focusNode);
      // FocusScope.of(context).unfocus();
      // });

    }
  }

  @override
  Widget build(BuildContext context) {
    print("Price reduction icon flexible - container");

    /// Price reduction icon flexible - container
    return FocusScope(
      child: Container(
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
                  child: GestureDetector(
                    onTap: () {
                      /// add a unit of price to the current currency pair's
                      /// price
                      subtractOrAddOneUnitToAlertPrice(isSubtract: true);
                    },
                    onLongPress: () {
                      print("");
                      print("onLongPress");

                      /// create and run a subtraction timer that runs and
                      /// updates the screen every 65 millisecond
                      additionOrSubtractionTimer = Timer.periodic(
                          const Duration(milliseconds: 65), (timer) {
                        subtractOrAddOneUnitToAlertPrice(isSubtract: true);
                      });
                    },
                    onLongPressEnd: (longPressEndDetails) {
                      /// cancel the subtraction timer
                      additionOrSubtractionTimer.cancel();
                    },
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text("-",
                          style: TextStyle(
                              fontFamily: "PT-Mono",
                              fontWeight: FontWeight.normal,
                              fontSize: widget.fontSizeMinus
                          )
                      ),
                    ),
                  )),

              /// price container
              Flexible(
                  fit: FlexFit.tight,
                  flex: flexPriceContainer,
                  child: Container(
                      alignment: Alignment.center,
                      // color: Colors.yellow,
                      child: TextFormField(
                          key: ValueKey(selectedInstrument),
                          initialValue: initialValuePrice,
                          enabled: isFirstTimeFetching ? false : true,
                          focusNode: focusNodeAlertPrice,
                          keyboardType: TextInputType.number,
                          maxLength: currentPairLatestPrice.length,
                          // expands: false,
                          // maxLines: 1,
                          onTap: () {
                            /// bool to check if updateCurrencyPairManually timer in dataProvider is
                            /// active
                            ///
                            /// helps to determine

                            dataProvider!.updateHasFocusAlertPriceTextField(
                                hasFocus: true);
                          },
                          onChanged: (enteredText) {
                            dataProvider!.updateHasFocusAlertPriceTextField(
                                hasFocus: true);

                            /// confirming whether the entered text is a string of
                            /// numbers.. despite setting the keyboardType to
                            /// TextInputType.number..
                            int lengthOfEnteredText = enteredText.length;
                            String numberChecker = "";

                            for (String i in enteredText.split("")) {
                              if (i == "." ||
                                  i == "0" ||
                                  i == "1" ||
                                  i == "2" ||
                                  i == "3" ||
                                  i == "4" ||
                                  i == "5" ||
                                  i == "6" ||
                                  i == "7" ||
                                  i == "8" ||
                                  i == "9") {
                                numberChecker += i;
                              }
                            }

                            /// if it entered text is a string of numbers (i.e. a
                            /// valid alert price), display it..
                            if (numberChecker.length == lengthOfEnteredText) {
                              setState(() {
                                /// setting the currently entered alert price text
                                enteredAlertPriceText = enteredText;

                                /// setting the bool that signals whether the
                                /// current alert price is valid or not
                                isValidCurrentAlertPrice = true;

                                /// updating text color to valid alert price
                                /// text color (Colors.black)
                                textColor = Colors.black;

                                /// signalling whether alert price has been
                                /// edited at least one time. If true, the alert
                                /// price will stop updating text to ensure that
                                /// the user's entries are left undisturbed
                                hasEditedAlertPriceAtLeastOnce = true;
                              });

                              /// ? check later: can the two methods below
                              /// be merged ¿
                              dataProvider!
                                  .updateAlertPriceCurrencyPriceTextField(
                                      alertPrice: enteredText);

                              dataProvider!
                                  .setOriginalOrEditedAlertPriceCurrencyPriceTextField(
                                      originalOrUserEditedAlertPrice:
                                          enteredText);
                            }

                            /// .. otherwise, color the text red to signify that
                            /// an invalid text has been entered..
                            else {
                              setState(() {
                                /// setting the currently entered alert price text
                                enteredAlertPriceText = enteredText;

                                /// setting the bool that signals whether the
                                /// current alert price is valid or not
                                isValidCurrentAlertPrice = false;

                                /// updating the error text value
                                previouslyEnteredErrorText = enteredText;

                                /// painting the alert price text red to signal
                                /// that an error text has been entered
                                textColor = Colors.red;
                              });
                            }
                          },
                          onEditingComplete: () {
                            focusNodeAlertPrice!.unfocus();
                            dataProvider!.updateHasFocusAlertPriceTextField(
                                hasFocus: false);
                            dataProvider!.updateHasFocusCurrencyPairTextField(
                                hasFocus: false);
                          },
                          style: TextStyle(
                            fontFamily: "PT-Mono",
                            fontWeight: FontWeight.normal,
                            fontSize: widget.fontSizePrice,
                            /// if the current alert price is the same as the
                            /// current price of the selected (alert) instrument,
                            /// signal to the user that it cannot be added
                            color: currentPairLatestPrice==initialValuePrice ? Colors.grey : textColor,
                            overflow: TextOverflow.fade,
                          ),
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            // contentPadding: EdgeInsets.only(left: 5),
                            counterText: "",
                            // removes the maxLength's counter
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                          )))),

              /// plus button
              Flexible(
                  fit: FlexFit.tight,
                  flex: flexPlusAndMinusButtons,
                  child: GestureDetector(
                    onTap: () {
                      /// subtract a unit of price from the current currency
                      /// pair's price
                      subtractOrAddOneUnitToAlertPrice(isSubtract: false);
                    },
                    onLongPress: () {
                      print("");
                      print("onLongPress");

                      /// create and run an addition timer that runs and
                      /// updates the screen every 65 millisecond
                      additionOrSubtractionTimer = Timer.periodic(
                          const Duration(milliseconds: 65), (timer) {
                        subtractOrAddOneUnitToAlertPrice(isSubtract: false);
                      });
                    },
                    onLongPressEnd: (longPressEndDetails) {
                      /// cancel the addition timer
                      additionOrSubtractionTimer.cancel();
                    },
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text("+",
                          style: TextStyle(
                              fontFamily: "PT-Mono",
                              fontWeight: FontWeight.normal,
                              fontSize: widget.fontSizePlus)),
                    ),
                  ))
            ],
          )),
    );
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

    /// list tile dimensions
    required this.fontSizeAListTile,
    required this.heightListTile,
    required this.widthListTileLeading,
    required this.widthListTileTitle,
    required this.widthListTileTrailing,
    required this.paddingLeftTrailing,
    required this.paddingRightTrailing,
    required this.paddingMiddleTrailing,
    required this.paddingBottomListTile,
    required this.widthPriceUpOrDownIndicator,
    required this.widthMutePauseOrUnallowButton,
    required this.widthUnMutePlayOrAllowButton,
    required this.widthDeleteButton,
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

  /// list tile dimensions
  final double fontSizeAListTile;
  final double heightListTile;
  final double widthListTileLeading;
  final double widthListTileTitle;
  final double widthListTileTrailing;

  final double paddingLeftTrailing;
  final double paddingRightTrailing;
  final double paddingMiddleTrailing;
  final double paddingBottomListTile;

  final double widthPriceUpOrDownIndicator;
  final double widthMutePauseOrUnallowButton;
  final double widthUnMutePlayOrAllowButton;
  final double widthDeleteButton;

  @override
  State<BlurrableWidgetsAboveCreateAlertWidget> createState() =>
      _BlurrableWidgetsAboveCreateAlertWidgetState();
}

/// _BlurrableWidgetsAboveCreateAlertWidget's state
class _BlurrableWidgetsAboveCreateAlertWidgetState
    extends State<BlurrableWidgetsAboveCreateAlertWidget> {
  DataProvider? dataProvider;

  /// signals whether the currency pair or alert price text form field currently
  /// has focus..
  bool isFocusedAnyTextField = false;

  /// a map of existing alerts
  Map<dynamic, dynamic> mapOfExistingAlerts = {};

  /// list of all alerts data from the above map of existing alerts
  List<Map<String, dynamic>> listOfExistingAlerts = [];

  /// signal whether prices have not been fetched at least once
  bool isFirstTimeFetchingPrices = true;

  /// get the latest map of all instruments' prices
  Map<dynamic, dynamic> mapOfAllPrices = {};

  @override
  void didChangeDependencies() {
    print("didChangeDependencies Blurrable");
    dataProvider = Provider.of<DataProvider>(context, listen: true);
    isFocusedAnyTextField =
        dataProvider!.getHasFocusCurrencyPairOrAlertPriceTextField();

    /// a map of existing alerts
    mapOfExistingAlerts = dataProvider!.getMapOfAllAlerts();

    /// obtaining a list of all alerts data from the above map of existing
    /// alerts
    listOfExistingAlerts = getListOfExistingAlerts();

    print("listOfExistingAlerts: $listOfExistingAlerts");

    /// setting bool that signals whether prices have not been fetched at least
    /// once
    isFirstTimeFetchingPrices =
        dataProvider!.getIsFirstValueInMapOfAllInstrumentsContainsFetching();

    /// get the latest map of all instruments' prices
    mapOfAllPrices = dataProvider!.getInstruments(isRetrieveAll: true);



    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  /// determining all existing alerts and alerts
  List<Map<String, dynamic>> getListOfExistingAlerts() {
    // List<Map<String, dynamic>>
    /// all alerts data listed
    List<Map<String, dynamic>> listOfExistingAlertsWithin = [];

    /// iterating through all existing alerts so that they can be added into
    /// the above list of existing alerts
    mapOfExistingAlerts.forEach((currentPair, alertsForCurrentPair) {
      /// adding all existing alert for the current pair to the list of existing
      /// alerts
      for (var alertsData in alertsForCurrentPair) {
        String currentAlertPrice = alertsData['price'];
        bool isMuted = alertsData['isMuted'];
        bool isFulfilledAlertPrice= alertsData['isFulfilledAlertPrice'];
        bool hasFulfilledAlertPriceOnce=alertsData['hasFulfilledAlertPriceOnce'];
        String initialAlertPricePosition=alertsData['initialAlertPricePosition'];

        Map<String, dynamic> alertDataToAdd = {
          "currencyPair": currentPair,
          "price": currentAlertPrice,
          "isMuted": isMuted,
          "isFulfilledAlertPrice": isFulfilledAlertPrice,
          "hasFulfilledAlertPriceOnce": hasFulfilledAlertPriceOnce,
          "initialAlertPricePosition": initialAlertPricePosition
        };

        // print("alertDataToAdd: ${alertDataToAdd.toString()}");
        // print("${listOfExistingAlerts.contains(alertDataToAdd)}");
        //
        // bool isAlreadyAddedCurrentAlertData = false;
        // for (var alertData in listOfExistingAlerts){
        //   String alreadyAddAlertDataString = alertData.toString();
        //
        //   if (alertDataToAdd.toString()==alreadyAddAlertDataString){
        //     isAlreadyAddedCurrentAlertData=true;
        //   }
        // }
        //
        // if (isAlreadyAddedCurrentAlertData==false){
        //   listOfExistingAlerts.add(alertDataToAdd);
        // }

        listOfExistingAlertsWithin.add(alertDataToAdd);
      }
    });

    // listOfExistingAlerts = listOfExistingAlertsWithin.reversed.toList();

    return listOfExistingAlertsWithin.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {

    print("mapOfExistingAlerts.isEmpty: ${mapOfExistingAlerts.isEmpty}");
    print("mapOfExistingAlerts: ${mapOfExistingAlerts}");
    print("isFirstTimeFetchingPrices == true: ${isFirstTimeFetchingPrices == true}");

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

                      /// make the alerts holding container's borders visible
                      /// if no alerts exist. Otherwise, don't display them.
                      color: mapOfExistingAlerts.isEmpty
                          ? Colors.grey
                          : Colors.transparent,
                      // const Color(0xFFFC8955)
                      width: widget.borderWidthGridTile / 6.1538461538),
                  borderRadius: BorderRadius.circular(widget.radiusGridTile),
                ),

                /// display a no alerts image if no price alerts have been
                /// created or prices have not been fetched at least once.
                /// Otherwise, display all existing alerts
                child: mapOfExistingAlerts.isEmpty ||
                        isFirstTimeFetchingPrices == true
                    ? Image.asset(
                        "assets/images/no_alerts.png",
                        width: 10,
                        height: 10,
                        // fit: BoxFit.fitHeight,
                      )

                    /// Alerts list view builder's container
                    : Container(
                        // color: Colors.green,
                        height: widget.heightListTile,
                        width: double.infinity,

                        /// Alerts list view builder
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: listOfExistingAlerts.length,
                          // listOfExistingAlerts.length,
                          itemBuilder: (context, index) {
                            // List<Map<dynamic, dynamic>> listOfExistingAlerts = getListOfExistingAlerts();

                            /// currency pair the current alert belongs to
                            String currentAlertInstrument =
                                listOfExistingAlerts[index]['currencyPair'];

                            /// calculating decimal numbers of the currently
                            /// alert as a string
                            ///
                            /// price structure
                            String currentAlertInstrumentLatestPriceString =
                                mapOfAllPrices[currentAlertInstrument]
                                    ['current_price'];
                            if (currentAlertInstrumentLatestPriceString=="demo"){
                              currentAlertInstrumentLatestPriceString="0.00000";
                            }

                            int dotPositionCurrentAlertInstrumentPrice =
                                currentAlertInstrumentLatestPriceString.indexOf(".") +
                                    1;
                            int numOfDecimalNumbersCurrentInstrumentOriginalPrice =
                                currentAlertInstrumentLatestPriceString.length -
                                    dotPositionCurrentAlertInstrumentPrice;

                            /// alert price of the current alert as a double
                            double currentAlertInstrumentAlertPrice =
                                double.parse(
                                    listOfExistingAlerts[index]['price']);

                            /// alert price of the current alert as a double
                            String currentAlertInstrumentAlertPriceString =
                                listOfExistingAlerts[index]['price'];

                            /// the latest price of the alert currency pair
                            ///
                            /// if the list view builder is visible, the price
                            /// will not contain fetched because of the ternary
                            /// statement I specified above..
                            // print("mapOfAllPrices: $mapOfAllPrices");
                            double doubleCurrentPairLatestPrice = double.parse(
                                currentAlertInstrumentLatestPriceString);


                            /// is the alert price above or below the current
                            /// currency pair's latest price
                            String diffAlertPriceAndLatestPrice =
                                (currentAlertInstrumentAlertPrice -
                                        doubleCurrentPairLatestPrice)
                                    .toString();
                            double diffAlertPriceAndLatestPriceDouble =
                                double.parse(diffAlertPriceAndLatestPrice);

                            /// icon that signals whether the alert price is
                            /// above or below the current currency pair's
                            /// latest price
                            String alertPriceRelativePositionIndicatorImageString="";

                            if (diffAlertPriceAndLatestPriceDouble == 0) {
                              alertPriceRelativePositionIndicatorImageString =
                              "assets/images/alert_price_no_price_diff_three.png";

                            } else if (diffAlertPriceAndLatestPrice.contains("-")){
                              alertPriceRelativePositionIndicatorImageString="assets/images/alert_price_below_current_price.png";
                            }else if (!diffAlertPriceAndLatestPrice.contains("-")){
                              alertPriceRelativePositionIndicatorImageString="assets/images/alert_price_above_current_price.png";
                            }

                            print(
                                "currentAlertInstrument: ${currentAlertInstrument}, currentAlertPrice: ${currentAlertInstrumentAlertPrice}");
                            print(
                                "diffAlertPriceAndLatestPrice: ${diffAlertPriceAndLatestPrice}");

                            /// is the current alert muted?
                            bool isMuted =
                                listOfExistingAlerts[index]["isMuted"];

                            /// boolean that signals whether the current alert
                            /// is the last alert in the list of existing alerts
                            bool isLastAlert =
                                index == listOfExistingAlerts.length - 1;

                            /// DETERMINING A COLOR TO APPLY TO THE PRICE IF
                            /// THE CURRENT ALERT HAS PREVIOUSLY BEEN FULFILLED
                            Color colorAlertPrice=Colors.black;

                            /// a bool that signals if the current price alert
                            /// has been fulfilled at least once
                            bool isPriceAlertFulfilledOnce=
                            listOfExistingAlerts[index]["hasFulfilledAlertPriceOnce"];

                            String alertPricePosition=listOfExistingAlerts[index]['initialAlertPricePosition'];

                            if (isPriceAlertFulfilledOnce && alertPricePosition=="up"){
                              colorAlertPrice=const Color(0xFF069D91);
                            }
                            else if (isPriceAlertFulfilledOnce && alertPricePosition=="down"){
                              colorAlertPrice=const Color(0xFFFC8955);
                            }


                            return Dismissible(
                              key: UniqueKey(),
                              direction: DismissDirection.endToStart,
                              onDismissed: (dismissDirection) async {
                                print("dismissDirection: ${dismissDirection}");
                                print(
                                    "dismissDirection index: ${dismissDirection.index}");
                                print(
                                    "dismissDirection name: ${dismissDirection.name}");

                                /// remove alert from the local list of all
                                /// alerts
                                setState(() {
                                  listOfExistingAlerts.removeAt(index);
                                  print(
                                      "listOfExistingAlerts: $listOfExistingAlerts");
                                });

                                /// removing alert from the map of all alert
                                dataProvider!.muteUnMuteOrRemoveAlert(
                                  alertOperationType: AlertOperationType.remove,
                                  currencyPair: currentAlertInstrument,
                                  alertPrice:
                                      currentAlertInstrumentAlertPriceString,
                                );

                                /// saving the changes locally
                                await dataProvider!
                                    .savePriceAlertsToLocalStorage();

                                /// signalling to "Mute All" button that no
                                /// alert exists if all alerts have been deleted
                                dataProvider!.muteUnMuteAllOrCalcIsAllMutedOrIsPriceAlertFulfilled(
                                    alertOperationType: AlertOperationType
                                        .calcIsAllAlertsMuted);
                              },
                              background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(
                                    right: widget.paddingRightTrailing,
                                  ),
                                  margin: EdgeInsets.only(
                                      bottom: isLastAlert
                                          ? 0
                                          : widget.paddingBottomListTile),
                                  decoration: BoxDecoration(

                                      /// Dismissible widget's background - colored red
                                      color: const Color(0xFFFC8955),
                                      border: Border.all(
                                          color: Colors.grey,
                                          width:
                                              widget.borderWidthGridTile / 5.4),
                                      borderRadius: BorderRadius.circular(
                                          widget.radiusGridTile)),
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(
                                        fontFamily: "PT-Mono",
                                        fontSize: widget.fontSizeAListTile,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )),
                              child: Container(
                                // color: Colors.red,
                                height: widget.heightListTile,
                                width: double.infinity,
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(
                                    top: 0,
                                    left: 0,
                                    right: 0,

                                    /// add a spacing below each alert's list tile
                                    /// so far the alert isn't the last in the
                                    /// list of existing price alerts.
                                    bottom: isLastAlert
                                        ? 0
                                        : widget.paddingBottomListTile),
                                padding: null,
                                decoration: BoxDecoration(
                                    // color:Colors.red,
                                    borderRadius: BorderRadius.circular(
                                        widget.radiusGridTile),
                                    border: Border.all(
                                        color: Colors.grey,
                                        width:
                                            widget.borderWidthGridTile / 5.4)),
                                child: ListTile(
                                  // key: ValueKey(
                                  //     "listTile$currentAlertInstrument$currentPairLatestPrice"
                                  // ),
                                  // dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  minVerticalPadding: 0,
                                  horizontalTitleGap: 0,
                                  // visualDensity: VisualDensity.comfortable,

                                  /// leading - Currency Pair
                                  leading: Container(
                                      width: widget.widthListTileLeading,
                                      height: widget.heightListTile,
                                      // color: Colors.blue,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.zero,
                                      padding: EdgeInsets.zero,
                                      child: Text(
                                        currentAlertInstrument,
                                        style: TextStyle(
                                          fontFamily: "PT-Mono",
                                          fontWeight: isPriceAlertFulfilledOnce ? FontWeight.bold : FontWeight.normal,
                                          fontSize: widget.fontSizeAListTile,
                                        ),
                                        textAlign: TextAlign.left,
                                      )),

                                  /// title - Alert Price
                                  title: Container(
                                      height: widget.heightListTile,
                                      width: widget.widthListTileTitle,
                                      alignment: Alignment.center,
                                      // color: Colors.green,
                                      child: Text(

                                          /// show the alert price of the current
                                          /// price alert instrument and ensure that
                                          /// it has the number of decimal numbers
                                          /// the alert instrument's original price
                                          /// has..
                                          currentAlertInstrumentAlertPrice
                                              .toStringAsFixed(
                                                  numOfDecimalNumbersCurrentInstrumentOriginalPrice),
                                          style: TextStyle(
                                              fontFamily: "PT-Mono",
                                              fontWeight: isPriceAlertFulfilledOnce ? FontWeight.bold : FontWeight.normal,
                                              fontSize:
                                                  widget.fontSizeAListTile,
                                              color: Colors.black

                                          ))),

                                  /// Buttons & Icons
                                  /// a. alert price's relative direction
                                  /// b. Pause or Play button
                                  /// c. delete button
                                  trailing: Container(
                                    alignment: Alignment.center,
                                    width: widget.widthListTileTrailing,
                                    height: widget.heightListTile,
                                    child: Row(children: <Widget>[
                                      /// initial padding left
                                      SizedBox(
                                        width: widget.paddingLeftTrailing,
                                      ),

                                      /// alert price's relative direction:
                                      /// i.e is the alert price above or below
                                      /// the current currency pair's latest
                                      /// price?
                                      SizedBox(
                                          width: widget
                                              .widthPriceUpOrDownIndicator,
                                          child: Image.asset(
                                              alertPriceRelativePositionIndicatorImageString
                                          )
                                      ),

                                      /// spacing between alert price's relative
                                      /// position and the mute / unmute button
                                      SizedBox(
                                        width: widget.paddingMiddleTrailing,
                                      ),

                                      /// mute / unmute button
                                      GestureDetector(
                                        onTap: () async {
                                          /// mute or un-mute the alert
                                          isMuted
                                              ? dataProvider!
                                                  .muteUnMuteOrRemoveAlert(
                                                  alertOperationType:
                                                      AlertOperationType.unMute,
                                                  currencyPair:
                                                      currentAlertInstrument,
                                                  alertPrice:
                                                      currentAlertInstrumentAlertPriceString,
                                                )
                                              : dataProvider!
                                                  .muteUnMuteOrRemoveAlert(
                                                  alertOperationType:
                                                      AlertOperationType.mute,
                                                  currencyPair:
                                                      currentAlertInstrument,
                                                  alertPrice:
                                                      currentAlertInstrumentAlertPriceString,
                                                );

                                          /// saving the changes locally
                                          await dataProvider!
                                              .savePriceAlertsToLocalStorage();

                                          /// calculate whether all price alerts (in _mapOfAllAlerts within data_provider.dart) have been
                                          /// muted
                                          ///
                                          /// updates _isAllPriceAlertsMuted within data_provider.dart when the an alert gets muted or unmuted
                                          dataProvider!
                                              .muteUnMuteAllOrCalcIsAllMutedOrIsPriceAlertFulfilled(
                                                  alertOperationType:
                                                      AlertOperationType
                                                          .calcIsAllAlertsMuted);
                                        },
                                        child: SizedBox(
                                            width: widget
                                                .widthUnMutePlayOrAllowButton,
                                            // width: isMuted == false
                                            //     ? widget
                                            //         .widthMutePauseOrUnallowButton
                                            //     : widget
                                            //         .widthUnMutePlayOrAllowButton,
                                            child: Image.asset(isMuted == false
                                                ? "assets/images/price_mute_button.png"
                                                : "assets/images/price_unmute_button.png")),
                                      ),

                                      /// spacing between the mute / unmute
                                      /// button and the delete button
                                      SizedBox(
                                        width: widget.paddingMiddleTrailing,
                                      ),

                                      /// the delete button
                                      GestureDetector(
                                        onTap: () async {
                                          /// remove alert from the local list of all
                                          /// alerts
                                          setState(() {
                                            listOfExistingAlerts
                                                .removeAt(index);
                                            print(
                                                "listOfExistingAlerts: $listOfExistingAlerts");
                                          });

                                          /// removing alert from the map of all alert
                                          dataProvider!.muteUnMuteOrRemoveAlert(
                                            alertOperationType:
                                                AlertOperationType.remove,
                                            currencyPair:
                                                currentAlertInstrument,
                                            alertPrice:
                                                currentAlertInstrumentAlertPriceString,
                                          );

                                          /// saving the changes locally
                                          await dataProvider!
                                              .savePriceAlertsToLocalStorage();

                                          /// signalling to "Mute All" button that no
                                          /// alert exists if all alerts have been deleted
                                          dataProvider!.muteUnMuteAllOrCalcIsAllMutedOrIsPriceAlertFulfilled(
                                              alertOperationType: AlertOperationType
                                                  .calcIsAllAlertsMuted
                                          );
                                        },
                                        child: SizedBox(
                                            width: widget.widthDeleteButton,
                                            child: Image.asset(
                                              "assets/images/price_delete_button.png",
                                              color: Colors.black,
                                            )),
                                      ),
                                    ]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),

              /// Swipe notification's Sized Box
              SizedBox(
                  height: widget.heightSwipeNotification,
                  width: double.infinity,
                  // color: Colors.blueAccent
                  child: Center(
                    child: Text(listOfExistingAlerts.length <= 2 ? "" : "Swipe",
                        // listOfExistingAlerts.length
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
        isFocusedAnyTextField == false
            ? Container(
                height: 0,
              )
            : Positioned(
                child: GestureDetector(
                  onTap: () {
                    /// hide the software keyboard and unblur the screen when
                    /// the blurred container gets clicked
                    FocusScope.of(context).unfocus();
                    dataProvider!
                        .updateHasFocusCurrencyPairTextField(hasFocus: false);
                    dataProvider!
                        .updateHasFocusAlertPriceTextField(hasFocus: false);

                    print(
                        "dataProvider!.getHasFocusCurrencyPairTextField(): ${dataProvider!.getHasFocusCurrencyPairTextField()}");
                    print(
                        "dataProvider!.getHasFocusAlertPriceTextField();: ${dataProvider!.getHasFocusAlertPriceTextField()}");

                    // dataProvider!.updateHasFocusCurrencyPairTextField(hasFocus: false);
                    // dataP
                  },
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaY: isFocusedAnyTextField == true ? 10 : 0,
                        sigmaX: isFocusedAnyTextField == true ? 10 : 0),
                    child: Container(
                        width: double.infinity,
                        height: widget.heightFirstSixGridTiles +
                            widget.heightAlertsAndOtherMenuItemsSizedBox +
                            widget.heightAlertsListViewBuilder +
                            widget.heightSwipeNotification,
                        color: Colors.yellow.withOpacity(0)),
                  ),
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
    // print(
    // "dataProvider!.getHasFocusATextField() == true a: ${dataProvider!.getHasFocusATextField() == true}");

    return SizedBox(

        // an extra main axis spacing was added to the
        // height of the grid view builder. Hence, an
        // adjustments have to the made to the height of
        // this widget as well as the padding top of it's
        // child widget to ensure that no visible widget
        // will cross the bottom iphone bar
        height: widget.heightAlertsAndOtherMenuItemsSizedBox,
        // - widget.mainAxisSpacing,
        width: double.infinity,
        // color: Colors.green,
        child: Padding(
          padding: EdgeInsets.only(
              top: widget.marginTopAlertsAndOtherMenuItemsSizedBox,
              // - widget.mainAxisSpacing,
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

  /// timer that helps correct entered error text to the currently selected
  /// currency pair
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
  FocusNode? focusNodeCurrencyPair;

  /// timer that checks whether prices have been fetched
  Timer hasFetchedPricesTimer =
      Timer.periodic(const Duration(microseconds: 1), (timer) {
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

      focusNodeCurrencyPair = FocusNode(
        debugLabel: "currencyPair$selectedInstrument",
        skipTraversal: true,
        canRequestFocus: false,
        descendantsAreFocusable: false,
        descendantsAreTraversable: false,
      );

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

    // print("isRunningErrorOnChangedSetState == false d : ${isRunningErrorOnChangedSetState == false}");

    /// if
    /// 1. a valid currency pair has been entered
    /// 2. an invalid text (colored red) correcting timer is active,
    /// 3. user has taken focus away from the currency pair text form field, and
    /// 4. prices have been fetched at least once,
    /// update the currency text form field with the currently selected grid
    /// tile's currency pair
    ///
    /// This helps to ensure that when a grid tile is clicked even after an
    /// invalid currency pair has been entered into the text form field,
    /// the selected grid tile's currency pair will still get displayed
    /// with the right color (Colors.black)..
    ///
    // print(
    //         "textColor!.value != colorRedInt d: ${textColor!.value != colorRedInt}");
    //     print("focusNode.hasFocus d: ${focusNode.hasFocus == false}");
    //     print(
    //         "isFirstValueInMapOfAllInstrumentsContainsFetching  == false d : ${isFirstValueInMapOfAllInstrumentsContainsFetching == false}");

    if ((textColor!.value != colorRedInt ||
            correctEnteredErrorTextTimer.isActive) &&
        focusNodeCurrencyPair!.hasFocus == false &&
        isFirstValueInMapOfAllInstrumentsContainsFetching == false) {
      print("initial value before change: ${initialValue}");

      correctEnteredErrorTextTimer.cancel();
      textColor = Colors.black;
      selectedInstrument = dataProvider!.getCurrentlySelectedInstrument();
      initialValue = selectedInstrument;
    }

    /// updating the text form field after an error currency pair text has been
    /// entered, submitted and displayed..
    if (textColor!.value == colorRedInt &&
        focusNodeCurrencyPair!.hasFocus == false) {
      correctEnteredErrorTextTimer =
          Timer(const Duration(milliseconds: 2250), () {
        print("colorRedInt is");
        String currentlySelectedPair =
            dataProvider!.getCurrentlySelectedInstrument();

        setState(() {
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
        });
        print(
            "currentlySelectedPair == previouslyEnteredErrorText: ${currentlySelectedPair == previouslyEnteredErrorText}");
      });
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
    // if (textColor!.value == colorRedInt) {
    // selectedInstrument = initialValue;
    // } else {
    // selectedInstrument = dataProvider!.getCurrentlySelectedInstrument();
    // }

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
    print("focusNode.hasFocus: ${focusNodeCurrencyPair!.hasFocus == false}");
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

    print("focusNode.hasFocus: ${focusNodeCurrencyPair!.hasFocus}");

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
      focusNode: focusNodeCurrencyPair!,
      initialValue: initialValue,
      keyboardType: TextInputType.text,
      autofocus: false,
      onTap: () {
        // FocusScope.of(context).requestFocus();

        /// cancel any active error-text correcting timer so that it will not
        /// interfere with the user experience when the user clicks on the
        /// currency pair text form field again immediately after entering an
        /// invalid text
        correctEnteredErrorTextTimer.cancel();

        /// register that the currency pair text form field has been tapped and
        /// that the keyboard is currently visible
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
                focusNode: focusNodeCurrencyPair!
                // context: context
                );
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
                focusNode: focusNodeCurrencyPair!,
                context: context);
          });
        }
      },
      onEditingComplete: () {
        focusNodeCurrencyPair!.unfocus();

        /// setting this widget's focus node in data provider
        dataProvider!.updateHasFocusCurrencyPairTextField(hasFocus: false);
        dataProvider!.updateHasFocusAlertPriceTextField(hasFocus: false);

        print("dataProvider!.hasFocusCurrencyPairTextField");
      },
      style: TextStyle(
          fontFamily: "PT-Mono",
          fontSize: widget.fontSizeCurrencyPairAndPrice,
          fontWeight: FontWeight.bold,
          color: textColor,
          overflow: TextOverflow.fade),
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

    return GestureDetector(
      onTap: () {
        /// adding alert if the active child widget is the "add alert" button
        /// and prices have been retrieved at least once
        if (widget.isCurrencyPairTextField == false &&
            isFirstValueInMapOfAllInstrumentsContainsFetching == false) {
          /// adding alert to the map of all alerts
          dataProvider!.addAlertToMapOfAllAlerts(context: context);

          /// un-blurring the screen if it is currently blurred and making the
          /// keyboard invisible if it's currently visible..
          dataProvider!.updateHasFocusCurrencyPairTextField(hasFocus: false);
          dataProvider!.updateHasFocusAlertPriceTextField(hasFocus: false);
          FocusScope.of(context).unfocus();

          /// calculate whether all price alerts (in _mapOfAllAlerts,
          /// data_provider.dart) are currently muted
          ///
          /// updates _isAllPriceAlertsMuted in data_provider.dart when the app
          /// gets started or updated
          dataProvider!.muteUnMuteAllOrCalcIsAllMutedOrIsPriceAlertFulfilled(
              alertOperationType: AlertOperationType.calcIsAllAlertsMuted
          );
        }
      },
      child: Container(
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
                  color: widget.isCurrencyPairTextField ? Colors.transparent : Colors.black)),
          child: currencyPairOrTextButtonWidget),
    );
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

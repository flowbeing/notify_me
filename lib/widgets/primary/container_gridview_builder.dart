import 'dart:math';
import 'dart:ui';

import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../../providers/data_provider.dart';

import "./grid_tile_currency_pair.dart";

class ContainerGridViewBuilder extends StatefulWidget {
  ContainerGridViewBuilder(
      {required this.heightGridView,
      required this.crossAxisSpacing,
      required this.mainAxisSpacing,
      required this.widthGridTile,
      required this.heightGridTile,
      required this.aspectRatioGridTile,
      // required this.paddingTopGridTile,
      required this.borderWidthGridTile,
      required this.radiusGridTile,
      required this.heightPriceDirectionIcon,
      required this.marginPriceDirectionAndCurrencyPair,
      required this.heightSymbolSizedBox,
      required this.currencyPairLazyLoading,
      required this.currencyPairOrPrice,
      required this.fontSizeSymbols,
      required this.marginCurrencyPairAndCurrencyPrice,
      required this.heightPriceSizedBox,
      required this.fontSizePrices,
      // required this.updateHomepageGridTileClicked,
      /// function to reset the lower left corner's text to null if any has
      /// previously been entered, so that
      /// CurrencyPairTextFieldOrCreateAlertButton can update correctly with a
      /// selected grid tile's currency pair..
      // required this.updateHomepageNewInstrumentTextEntered,
      // required this.enteredTextCurrencyPairTextFormFieldWidget,
      // required this.isErrorEnteredTextCurrencyPairTextFormFieldWidget
      });

  final double heightGridView;

  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double widthGridTile;
  final double heightGridTile;
  final double aspectRatioGridTile;
  // final double paddingTopGridTile;
  final double borderWidthGridTile;
  final double radiusGridTile;
  final double heightPriceDirectionIcon;
  final double marginPriceDirectionAndCurrencyPair;
  final double heightSymbolSizedBox;
  final Function currencyPairLazyLoading;
  final Function currencyPairOrPrice;
  final double fontSizeSymbols;
  final double marginCurrencyPairAndCurrencyPrice;
  final double heightPriceSizedBox;
  final double fontSizePrices;
  // final Function({required String? enteredText}) updateHomepageNewInstrumentTextEntered;
  // final String? enteredTextCurrencyPairTextFormFieldWidget;
  // final bool isErrorEnteredTextCurrencyPairTextFormFieldWidget;

  /// updateAppGridTileClicked should contain setState and the explanation below
  // setState(() {
  //   print("Gesture Detector Setting State");
  // })

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
  // isGridTileClicked = true;
  // final Function(
  //     {required bool isGridTileClicked,
  //     required int indexNewSelectedGridTile}) updateHomepageGridTileClicked;

  @override
  State<ContainerGridViewBuilder> createState() =>
      _ContainerGridViewBuilderState();
}

class _ContainerGridViewBuilderState extends State<ContainerGridViewBuilder> {
  DataProvider? dataProvider;

  GridView? gridView;

  /// currently selected instrument and it's row number
  String? currentlySelectedInstrument;
  int? currentlySelectedInstrumentRowNumber;

  /// map of all instruments
  Map<dynamic, dynamic> mapOfAllInstruments = {};

  /// list of all instruments
  List<dynamic> listOfAllInstruments = [];

  /// index of the selected grid tile
  int? indexSelectedGridTile;

  /// map of entered currency pair map
  Map<String,dynamic> enteredCurrencyPairMap = {};
  String? manuallyEnteredCurrencyPair;
  bool? isErrorManuallyEnteredCurrencyPair;

  /// value keys
  Key? currentValueKeyBackup;
  Key? currentValueKey;

  /// have prices been fetched at least once
  bool isFirstTimeFetchingPrices=true;

  @override
  didChangeDependencies() {
    // TODO: implement didChangeDependencies

    /// data provider
    dataProvider = Provider.of<DataProvider>(context, listen: true);

    /// setting the value of the currently selected currency pair
    indexSelectedGridTile = dataProvider!.getIndexSelectedGridTile();

    /// map of all instruments
    mapOfAllInstruments = dataProvider!.getInstruments();

    /// list of all instruments
    listOfAllInstruments = dataProvider!.getListOfAllInstruments();

    /// determining the currently selected currency pair's row
    currentlySelectedInstrumentRowNumber = dataProvider!
        .getCurrentlySelectedInstrumentRowNumber();

    /// map of entered currency pair map
    enteredCurrencyPairMap = dataProvider!.getEnteredTextCurrencyPair();
    manuallyEnteredCurrencyPair = enteredCurrencyPairMap['enteredCurrencyPair'];
    isErrorManuallyEnteredCurrencyPair = enteredCurrencyPairMap['isErrorEnteredText'];

    /// have prices been fetched at least once
    isFirstTimeFetchingPrices=dataProvider!.getIsFirstValueInMapOfAllInstrumentsContainsFetching();

    print(
        "currently selected instrument's row number: ${currentlySelectedInstrumentRowNumber}");

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ContainerGridViewBuilder oldWidget) {

    /// setting the value of the currently selected currency pair
    indexSelectedGridTile = dataProvider!.getIndexSelectedGridTile();

    currentValueKey = ValueKey("$indexSelectedGridTile");

    /// to ensure that the gridview will not be rebuilt when the grid tile gets
    /// clicked post deletion of a previous manually entered currency pair text
    if (
    currentValueKeyBackup != null
        && manuallyEnteredCurrencyPair==null
        && isErrorManuallyEnteredCurrencyPair==null
    ){
      currentValueKey = currentValueKeyBackup;
    }

    /// determining the currently selected currency pair's row
    currentlySelectedInstrumentRowNumber = dataProvider!
        .getCurrentlySelectedInstrumentRowNumber();

    print(
        "currently selected instrument's row number: ${currentlySelectedInstrumentRowNumber}");

    /// obtaining the currently selected instrument's row number..
    ///
    /// 1. if a valid currency pair has been entered into the
    ///    CurrencyPairTextFieldOrCreateAlertButton, set
    ///    currentSelectedInstrument to the content of
    ///    CurrencyPairTextFieldOrCreateAlertButton..
    // if (
    // widget.enteredTextCurrencyPairTextFormFieldWidget != null &&
    //     widget.isErrorEnteredTextCurrencyPairTextFormFieldWidget == false
    // ){
    //   currentlySelectedInstrument =
    //       widget.enteredTextCurrencyPairTextFormFieldWidget;
    // }
    /// if no valid text or any text has been entered into the
    /// CurrencyPairTextFieldOrCreateAlertButton, set currentSelectedInstrument
    /// to the currently or previously selected grid tile's currency pair..
    // if{
    //   currentlySelectedInstrument = dataProvider!.getCurrentlySelectedInstrument();
    // }

    /// map of entered currency pair map
    enteredCurrencyPairMap = dataProvider!.getEnteredTextCurrencyPair();
    manuallyEnteredCurrencyPair = enteredCurrencyPairMap['enteredCurrencyPair'];
    isErrorManuallyEnteredCurrencyPair = enteredCurrencyPairMap['isErrorEnteredText'];

    /// to ensure that the gridview will not be rebuilt when the grid tile gets
    /// clicked post deletion of a previous manually entered currency pair text
    if (
          currentValueKeyBackup != null
          && manuallyEnteredCurrencyPair==null
          && isErrorManuallyEnteredCurrencyPair==null
    ){
      currentValueKey = currentValueKeyBackup;
    }

    print(
        "currently selected instrument's row number: ${currentlySelectedInstrumentRowNumber}");

    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  /// this method gets the initial scroll offset
  double getInitialScrollOffset(){
    
    Map<String,dynamic> enteredCurrencyPairMap = dataProvider!.getEnteredTextCurrencyPair();

    String? manuallyEnteredCurrencyPair = enteredCurrencyPairMap['enteredCurrencyPair'];
    bool? isErrorManuallyEnteredCurrencyPair = enteredCurrencyPairMap['isErrorEnteredText'];

    print("manuallyEnteredCurrencyPair: $manuallyEnteredCurrencyPair");
    print("isErrorManuallyEnteredCurrencyPair: $isErrorManuallyEnteredCurrencyPair");

    /// if a valid currency pair text exists, apply a proper scroll offset
    if (
      manuallyEnteredCurrencyPair != null && isErrorManuallyEnteredCurrencyPair == null) {

      double scaleOffset =
          (dataProvider!.getCurrentlySelectedInstrumentRowNumber() - 1) *
              (widget.heightGridTile); //  + widget.mainAxisSpacing

      print("scaleOffset: $scaleOffset");
      return scaleOffset;

    } else {

      return 0;

    }

  }



  Container build(BuildContext context) {
    // print("GridViewBuilder key: ${gridView!.anchor}");

    // double initialScrollOffset = currentlySelectedInstrumentRowNumber! <= 3 ?
    // 0 : getInitialScrollOffset();

    ScrollController? scrollController;

    print("initialScrollOffset: ${getInitialScrollOffset()}");

    print("manuallyEnteredCurrencyPair: ${manuallyEnteredCurrencyPair}, isErrorManuallyEnteredCurrencyPair: $isErrorManuallyEnteredCurrencyPair");


    return Container(
      // key: ValueKey("gridViewBuilderContainer$indexSelectedGridTile"),
      // color: Colors.yellow,
      width: double.infinity,
      height: widget.heightGridView, //+ widget.mainAxisSpacing + .1,
      // margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(0),

      /// A GridView Builder - contains all currency pairs
      child: GridView.builder(
        // clipBehavior: Clip.none,
        // addRepaintBoundaries: true,
        // addAutomaticKeepAlives: false,
        // addSemanticIndexes: false,
        // cacheExtent: 10,
        // semanticChildCount: 10,
        /// currentValueKey will be equal to the previous key when a previous
        /// manually entered currency pair text gets reset.
        ///
        /// That will ensure that this grid view builder will not get rebuilt..
        /// if it gets rebuilt, this grid view builder will scroll back to the
        /// top which would contribute to a pretty nasty user experience
        key: currentValueKey,
        /// the scroll controller will have a zero value offset when the grid
        /// tile gets tapped or when the index of the selected grid tile does
        /// not exceed 5, and will have a properly calculated offset when
        /// the a manually entered currency pair exists
        controller: manuallyEnteredCurrencyPair == null
            && isErrorManuallyEnteredCurrencyPair == null ?
            ScrollController() :
            ScrollController(
                initialScrollOffset: indexSelectedGridTile! <= 6 ?
                0 : getInitialScrollOffset(),
                keepScrollOffset: true
            ),
        addRepaintBoundaries: true,
        padding: const EdgeInsets.all(0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
            childAspectRatio: widget.aspectRatioGridTile

        ),
        itemCount:
        // listOfAllInstruments.isEmpty ? 6 :
        listOfAllInstruments.length,
        itemBuilder: (context, index) {
          String currentSymbolOrInstrument = listOfAllInstruments[index];

          /// Current instrument's data - could contain both
          /// the old and current prices of the instrument
          /// (actual prices or "demo") or
          /// "fetching"
          dynamic currentInstrumentsData =
              mapOfAllInstruments[currentSymbolOrInstrument];

          /// checking whether the current instrument's price
          /// is being fetched..
          bool isFetchingPrices = currentInstrumentsData == "fetching";

          String? current_price;
          String? old_price;

          String priceDifferenceIfAny = "";

          if (currentInstrumentsData.runtimeType != String) {
            current_price = currentInstrumentsData["current_price"];

            old_price = currentInstrumentsData["old_price"];

            /// if both the prices of the current instrument
            /// are actual prices, calculate the price
            /// movement. Otherwise, set
            /// priceDifferenceIfAny to "demo"
            try {
              /// obtaining the longest string of price (old, new price)
              bool isCurrentPriceLongerThanOldPrice=current_price!.length > old_price!.length;
              /// obtaining the length of the longest string of price (old, new price)
              // int longestStringCurrentAndOldPrice=max(current_price.length, old_price.length);

              /// the index of "."
              /// note that "."'s index cannot be 0
              int indexOfDot=0;
              /// the number of decimal numbers, if any
              int numDecimalNumbersLongestPriceString=0;
              /// longest price string (old, new price)
              String longestStringOldCurrentPrice="";

              /// obtaining the index of "." in the longest price string
              if (isCurrentPriceLongerThanOldPrice && current_price.contains(".")){
                longestStringOldCurrentPrice=current_price;
                indexOfDot=current_price.indexOf(".");
                numDecimalNumbersLongestPriceString=current_price.substring(indexOfDot+1).length;

              } else if (!isCurrentPriceLongerThanOldPrice && old_price.contains(".")){
                longestStringOldCurrentPrice=old_price;
                indexOfDot=old_price.indexOf(".");
                numDecimalNumbersLongestPriceString=old_price.substring(indexOfDot+1).length;
              }

              print("");
              print("longestStringOldCurrentPrice: $longestStringOldCurrentPrice");
              print("indexOfDot: $indexOfDot");
              print("numDecimalNumbersLongestPriceString: $numDecimalNumbersLongestPriceString");
              print("old_price: $old_price, new_price: $current_price");

              priceDifferenceIfAny =
                  (double.parse(current_price) - double.parse(old_price))
                      .toStringAsFixed(numDecimalNumbersLongestPriceString);
                  print("priceDifferenceIfAny: ${priceDifferenceIfAny}");
            } catch (error) {
              priceDifferenceIfAny = current_price!;
              print("priceDifferenceIfAny_error: ${priceDifferenceIfAny}");
            }
          }


          /// determining whether there was an upward price
          /// movement
          bool isUpwardPriceMovement = false;
          if (priceDifferenceIfAny!="demo"){
            isUpwardPriceMovement=currentInstrumentsData.runtimeType != String &&
                !priceDifferenceIfAny.startsWith("-") &&
                double.parse(priceDifferenceIfAny) != 0 &&
                priceDifferenceIfAny != "demo";
          }

          /// determining whether there was a downward price
          /// movement
          bool isDownwardPriceMovement =
              currentInstrumentsData.runtimeType != String &&
                  priceDifferenceIfAny.startsWith("-");

          /// determining whether the current instrument's
          /// price should not be displayed or whether there
          /// was no price movement..
          bool isNotDisplayedPrice =
              currentInstrumentsData.runtimeType != String &&
                  !priceDifferenceIfAny.startsWith("-") &&
                  priceDifferenceIfAny == "demo";

          /// determining whether the current instrument's
          /// price had no price movement..
          bool isNoPriceMovement = false;
          if (priceDifferenceIfAny!="demo"){
            isNoPriceMovement=currentInstrumentsData.runtimeType != String &&
                !priceDifferenceIfAny.startsWith("-") &&
                double.parse(priceDifferenceIfAny) == 0;
          }


          print("isUpwardPriceMovement: ${isUpwardPriceMovement}");
          print("isDownwardPriceMovement: ${isDownwardPriceMovement}");
          print("isNotDisplayedPrice: ${isNotDisplayedPrice}");
          print("isNoPriceMovement: ${isNoPriceMovement}");

          /// determining whether the current tile has been or
          /// should be selected
          bool isSelectedTile = false;

          if (index == indexSelectedGridTile &&
              isFetchingPrices == false &&
              priceDifferenceIfAny != "demo"){

            isSelectedTile = true;

          }

          /// defining each grid tile's colors
          Color pureColorGridTile = Colors.transparent;
          Color? gridTileColor;
          Color? gridBorderColor;

          /// grid tile color configuration for when prices get fetched for
          /// the first time
          if (isFetchingPrices == true) {
            gridTileColor = Colors.black.withOpacity(.02); //  Colors.white
            // gridTileColor = Colors.white;
            gridBorderColor = Colors.black.withOpacity(0.1); //gridTileColor
          }
          /// grid tile color configuration for 'demo' priced currency pairs
          else if (isNotDisplayedPrice){
            gridTileColor = Colors.black.withOpacity(.01);
            gridBorderColor = gridTileColor;
          }
          /// grid tile color configuration for when current and previous price
          /// are the same
          else if (isNoPriceMovement){
            pureColorGridTile=Color(0xFFF5F4FB).withRed(80).withBlue(80).withGreen(80); //Colors.black.withOpacity(1);
            gridTileColor = Color(0xFFF5F4FB); // Colors.black.withOpacity(.05);
            gridBorderColor = Colors.black.withOpacity(.01);
          }
          /// grid tile color configuration for when there's an upward price
          /// movement
          else if (isUpwardPriceMovement) {
            pureColorGridTile =
                const Color(0xFF069D91).withOpacity(1); // 0xFF0066FF // .67
            gridTileColor = const Color(0xFF069D91).withOpacity(.05);
            gridBorderColor = const Color(0xFF069D91).withOpacity(.1);
          }
          /// grid tile color configuration for when there's an downward price
          /// movement
          else if (isDownwardPriceMovement) {
            pureColorGridTile = const Color(0xFFFC8955);
            gridTileColor = const Color(0xFFFC8955).withOpacity(0.07);
            gridBorderColor = const Color(0xFFFC8955).withOpacity(0.1);
          }

          /// Grid Tile - custom template
          return GestureDetector(
            /// select the current grid tile when it's tapped if
            ///
            /// a. prices' data is being fetched
            /// b. the clicked grid tile is not the currently selected grid
            ///    tile..
            onTap: () {
              if (currentInstrumentsData.runtimeType != String
                  && priceDifferenceIfAny != "demo"
                  && indexSelectedGridTile != index
                  && dataProvider!.getHasFocusCurrencyPairOrAlertPriceTextField()==false
              ){

                  // widget.updateHomepageNewInstrumentTextEntered(
                  //     enteredText: null
                  // );

                  /// resetting any previous manually entered currency pair text
                  currentValueKeyBackup = currentValueKey;
                  if (manuallyEnteredCurrencyPair != null){
                    dataProvider!.updateEnteredTextCurrencyPair(
                        enteredText: null
                    );
                  }

                  /// updating the selected grid tile's index and calling
                  /// notifyListeners
                  dataProvider!.updateIndexSelectedGridTile(
                      newIndexSelectedGridTile: index
                  );

                }
            },
              child: GridTileCurrencyPair(
                    isSelected: isSelectedTile,
                    widthGridTile: widget.widthGridTile,
                    heightGridTile: widget.heightGridTile,
                    // paddingTopGridTile: widget.paddingTopGridTile,
                    gridTileColor:
                        isSelectedTile ? pureColorGridTile : gridTileColor!,
                    gridBorderColor: gridBorderColor!,
                    borderWidthGridTile: widget.borderWidthGridTile,
                    radiusGridTile: widget.radiusGridTile,
                    isFetchingPrices: isFetchingPrices,
                    heightPriceDirectionIcon: widget.heightPriceDirectionIcon,
                    isDownwardPriceMovement: isDownwardPriceMovement,
                    isUpwardPriceMovement: isUpwardPriceMovement,
                    isNotDisplayedPrice:
                        isNotDisplayedPrice,
                    isNoPriceMovement: isNoPriceMovement,
                    marginPriceDirectionAndCurrencyPair:
                        widget.marginPriceDirectionAndCurrencyPair,
                    heightSymbolSizedBox: widget.heightSymbolSizedBox,
                    currencyPairLazyLoading: widget.currencyPairLazyLoading,
                    currencyPairOrPrice: widget.currencyPairOrPrice,
                    currentSymbolOrInstrument: currentSymbolOrInstrument,
                    fontSizeSymbols: widget.fontSizeSymbols,
                    marginCurrencyPairAndCurrencyPrice:
                        widget.marginCurrencyPairAndCurrencyPrice,
                    heightPriceSizedBox: widget.heightPriceSizedBox,
                    mapOfAllInstruments: mapOfAllInstruments,
                    fontSizePrices: widget.fontSizePrices
                ),
          );
        },
      ),
    );
  }
}

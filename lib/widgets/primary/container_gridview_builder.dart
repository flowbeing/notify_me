import "package:flutter/material.dart";

import "./grid_tile_currency_pair.dart";

class ContainerGridViewBuilder extends StatefulWidget {

  ContainerGridViewBuilder({
    required this.heightFirstSixGridTiles,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.listOfAllInstruments,
    required this.priceAllInstruments,
    required this.indexSelectedGridTile,
    required this.widthGridTile,
    required this.heightGridTile,
    required this.paddingTopGridTile,
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
    required this.updateGridTileClicked

  });

  final double heightFirstSixGridTiles;

  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final List listOfAllInstruments;
  final Map priceAllInstruments;
  final int indexSelectedGridTile;
  final double widthGridTile;
  final double heightGridTile;
  final double paddingTopGridTile;
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


  /// updateGridTileClicked should contain setState and the explanation below
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
  final Function({
    required bool isGridTileClicked,
    required int indexNewSelectedGridTile
  })
      updateGridTileClicked;

  @override
  State<ContainerGridViewBuilder> createState() =>
      _ContainerGridViewBuilderState();
}

class _ContainerGridViewBuilderState extends State<ContainerGridViewBuilder> {
  Container build(BuildContext context) {
    return Container(
      // color: Colors.yellow,
      width: double.infinity,
      height: widget.heightFirstSixGridTiles,
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(0),

      /// A GridView Builder - contains all currency pairs
      child: GridView.builder(
        padding: const EdgeInsets.all(0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing),
        itemCount: widget.listOfAllInstruments.isEmpty
            ? 6
            :

            /// a minimum of six instruments will be
            /// displayed post fetch operation
            widget.listOfAllInstruments.length,
        itemBuilder: (context, index) {
          String currentSymbolOrInstrument = widget.listOfAllInstruments[index];

          /// Current instrument's data - could contain both
          /// the old and current prices of the instrument
          /// (actual prices or "demo") or
          /// "fetching"
          dynamic currentInstrumentsData =
              widget.priceAllInstruments[currentSymbolOrInstrument];

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
              priceDifferenceIfAny =
                  (double.parse(current_price!) - double.parse(old_price!))
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
          bool isSelectedTile = index == widget.indexSelectedGridTile &&
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
            pureColorGridTile = const Color(0xFF0066FF).withOpacity(.67);
            gridTileColor = const Color(0xFF0066FF).withOpacity(.05);
            gridBorderColor = const Color(0xFF0066FF).withOpacity(.1);
          } else if (isDownwardPriceMovement) {
            pureColorGridTile = const Color(0xFFFC8955);
            gridTileColor = const Color(0xFFFC8955).withOpacity(0.07);
            gridBorderColor = const Color(0xFFFC8955).withOpacity(0.1);
          }

          /// Grid Tile - custom template
          return GestureDetector(
            /// select the current grid tile when it's tapped
            onTap: () => {
              if (currentInstrumentsData.runtimeType != String &&
                  priceDifferenceIfAny != "demo")
                {
                  widget.updateGridTileClicked(
                      indexNewSelectedGridTile: index,
                      isGridTileClicked: true
                  )
                }
            },
            child: GridTileCurrencyPair(
                isSelected: isSelectedTile,
                widthGridTile: widget.widthGridTile,
                heightGridTile: widget.heightGridTile,
                paddingTopGridTile: widget.paddingTopGridTile,
                gridTileColor:
                    isSelectedTile ? pureColorGridTile : gridTileColor!,
                gridBorderColor: gridBorderColor!,
                radiusGridTile: widget.radiusGridTile,
                isFetchingPrices: isFetchingPrices,
                heightPriceDirectionIcon: widget.heightPriceDirectionIcon,
                isDownwardPriceMovement: isDownwardPriceMovement,
                isUpwardPriceMovement: isUpwardPriceMovement,
                isNotDisplayedPriceOrNoPriceMovement:
                    isNotDisplayedPriceOrNoPriceMovement,
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
                priceAllInstruments: widget.priceAllInstruments,
                fontSizePrices: widget.fontSizePrices
            ),
          );
        },
      ),
    );
  }
}

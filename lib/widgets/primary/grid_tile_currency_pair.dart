import "package:flutter/material.dart";

class GridTileCurrencyPair extends StatefulWidget {
  GridTileCurrencyPair(
      {required this.isSelected,
      required this.widthGridTile,
      required this.heightGridTile,
      // required this.paddingTopGridTile,
      required this.gridTileColor,
      required this.gridBorderColor,
      required this.borderWidthGridTile,
      required this.radiusGridTile,
      required this.isFetchingPrices,
      required this.heightPriceDirectionIcon,
      required this.isDownwardPriceMovement,
      required this.isUpwardPriceMovement,
      required this.isNotDisplayedPrice,
      required this.isNoPriceMovement,
      required this.marginPriceDirectionAndCurrencyPair,
      required this.heightSymbolSizedBox,
      required this.currencyPairLazyLoading,
      required this.currencyPairOrPrice,
      required this.currentSymbolOrInstrument,
      required this.fontSizeSymbols,
      required this.marginCurrencyPairAndCurrencyPrice,
      required this.heightPriceSizedBox,
      required this.mapOfAllInstruments,
      required this.fontSizePrices});

  final bool isSelected;
  final double widthGridTile;
  final double heightGridTile;
  // final double paddingTopGridTile;
  final Color gridTileColor;
  final Color gridBorderColor;
  final double borderWidthGridTile;
  final double radiusGridTile;
  final bool isFetchingPrices;
  final double heightPriceDirectionIcon;
  final bool isDownwardPriceMovement;
  final bool isUpwardPriceMovement;
  final bool isNotDisplayedPrice;
  final bool isNoPriceMovement;
  final double marginPriceDirectionAndCurrencyPair;
  final double heightSymbolSizedBox;
  final Function currencyPairLazyLoading;
  final Function currencyPairOrPrice;
  final String currentSymbolOrInstrument;
  final double fontSizeSymbols;
  final double marginCurrencyPairAndCurrencyPrice;
  final double heightPriceSizedBox;
  final Map mapOfAllInstruments;
  final double fontSizePrices;

  @override
  State<GridTileCurrencyPair> createState() => _GridTileCurrencyPairState();
}

class _GridTileCurrencyPairState extends State<GridTileCurrencyPair> {
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: widget.widthGridTile,
        height: widget.heightGridTile,
        padding: null,
        margin: null,
        // padding: EdgeInsets.only(
        //     top: widget.paddingTopGridTile * .97
        // ),
        decoration: BoxDecoration(
            color: widget.gridTileColor,
            border: Border.all(
              color: widget.gridBorderColor,
              width: widget.isFetchingPrices ? 0.2 : widget.borderWidthGridTile
            ),
            borderRadius: BorderRadius.circular(widget.radiusGridTile)),

        /// A column containing:
        /// 1. A price direction icon
        /// 2. The currency pair
        /// 3. The currency's price
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          /// Icon - fetching prices
          if (widget.isFetchingPrices)
            Image.asset(
              "assets/images/price_fetching.png",
              height: widget.heightPriceDirectionIcon,
            ),

          /// PRICE INCREASE OR DECREASE ICONS

          /// 1. if the app isn't fetching the current
          /// instrument's price, and the current
          /// price reflects a decrease in the
          /// instrument's value, show an orange
          /// downward price movement (image) icon..
          if (widget.isDownwardPriceMovement)
            Image.asset(
              widget.isSelected
                  ? "assets/images/price_decrease_white.png"
                  : "assets/images/price_decrease.png",
              height: widget.heightPriceDirectionIcon,
            ),

          /// 2. if the app isn't fetching the current
          /// instrument's price, and the current
          /// price reflects an increase in the
          /// instrument's value, show a blue upward
          /// price movement (image) icon..
          if (widget.isUpwardPriceMovement)
            Image.asset(
              widget.isSelected
                  ? "assets/images/price_increase_white.png"
                  : "assets/images/price_increase_darker_turquoise.png",
              height: widget.heightPriceDirectionIcon,
            ),

          /// PRICE NOT DISPLAYED ICON
          ///
          /// if the app isn't fetching the current
          /// instrument's price, and the current
          /// instrument's price should and will not be
          /// displayed, show a black downward price
          /// movement (image) icon..
          if (widget.isNotDisplayedPrice)
            Image.asset(
              "assets/images/price_fetching.png",
              height: widget.heightPriceDirectionIcon,
            ),

          /// PRICE NO PRICE CHANGE
          /// if the app isn't fetching the current
          /// instrument's price, and the current reflects
          /// no change in price, display a white downward
          /// price movement (image) icon
          if (widget.isNoPriceMovement)
            Image.asset(
              widget.isSelected
                  ? "assets/images/price_decrease_white.png"
                  : "assets/images/price_fetching.png",
              height: widget.heightPriceDirectionIcon,
            ),

          /// margin - price direction and currency
          /// pair
          SizedBox(
            height: widget.marginPriceDirectionAndCurrencyPair,
          ),

          /// currency name / currency name holder
          Container(
            alignment: Alignment.center,
            // color: Colors.yellow,
            height: widget.heightSymbolSizedBox, //
            child: widget.isFetchingPrices
                ?

                /// currency pair lazy loading
                widget.currencyPairLazyLoading()
                :

                /// currency price
                widget.currencyPairOrPrice(
                    currentSymbolOrInstrumentOrPrice: widget.currentSymbolOrInstrument,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.fontSizeSymbols,
                    fontColor: widget.isSelected ? Colors.white : Colors.black
                ),
          ),

          /// margin - currency pair and currency
          /// price
          SizedBox(
            height: widget.marginCurrencyPairAndCurrencyPrice * .75,
          ),

          /// currency price / currency price holder
          SizedBox(
            height: widget.heightPriceSizedBox,
            child: widget.currencyPairOrPrice(
                isFetching: widget.isFetchingPrices,
                currentSymbolOrInstrumentOrPrice: widget.isFetchingPrices
                    ? "fetching"
                    : widget.mapOfAllInstruments[widget.currentSymbolOrInstrument]
                            ["current_price"]
                        .toString(),
                fontWeight: FontWeight.w300,
                fontSize: widget.fontSizePrices,
                fontColor: widget.isSelected ? Colors.white : Colors.black),
          ),
        ]));
  }
}

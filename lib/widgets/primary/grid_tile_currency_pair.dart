import "package:flutter/material.dart";

class GridTileCurrencyPair extends StatelessWidget {
  GridTileCurrencyPair(
      {required this.isSelected,
      required this.widthGridTile,
      required this.heightGridTile,
      required this.paddingTopGridTile,
      required this.gridTileColor,
      required this.gridBorderColor,
      required this.radiusGridTile,
      required this.isFetchingPrices,
      required this.heightPriceDirectionIcon,
      required this.isDownwardPriceMovement,
      required this.isUpwardPriceMovement,
      required this.isNotDisplayedPriceOrNoPriceMovement,
      required this.marginPriceDirectionAndCurrencyPair,
      required this.heightSymbolSizedBox,
      required this.currencyPairLazyLoading,
      required this.currencyPairOrPrice,
      required this.currentSymbolOrInstrument,
      required this.fontSizeSymbols,
      required this.marginCurrencyPairAndCurrencyPrice,
      required this.heightPriceSizedBox,
      required this.priceAllInstruments,
      required this.fontSizePrices});

  final bool isSelected;
  final double widthGridTile;
  final double heightGridTile;
  final double paddingTopGridTile;
  final Color gridTileColor;
  final Color gridBorderColor;
  final double radiusGridTile;
  final bool isFetchingPrices;
  final double heightPriceDirectionIcon;
  final bool isDownwardPriceMovement;
  final bool isUpwardPriceMovement;
  final bool isNotDisplayedPriceOrNoPriceMovement;
  final double marginPriceDirectionAndCurrencyPair;
  final double heightSymbolSizedBox;
  final Function currencyPairLazyLoading;
  final Function currencyPairOrPrice;
  final String currentSymbolOrInstrument;
  final double fontSizeSymbols;
  final double marginCurrencyPairAndCurrencyPrice;
  final double heightPriceSizedBox;
  final Map priceAllInstruments;
  final double fontSizePrices;

  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: widthGridTile,
        height: heightGridTile,
        padding: EdgeInsets.only(top: paddingTopGridTile),
        decoration: BoxDecoration(
            color: gridTileColor,
            border: Border.all(color: gridBorderColor, width: 0.8),
            borderRadius: BorderRadius.circular(radiusGridTile)),

        /// A column containing:
        /// 1. A price direction icon
        /// 2. The currency pair
        /// 3. The currency's price
        child: Column(children: <Widget>[
          /// Icon - fetching prices
          if (isFetchingPrices)
            Image.asset(
              "assets/images/price_fetching.png",
              height: heightPriceDirectionIcon,
            ),

          /// PRICE INCREASE OR DECREASE ICONS

          /// 1. if the app isn't fetching the current
          /// instrument's price, and the current
          /// price reflects a decrease in the
          /// instrument's value, show an orange
          /// downward price movement (image) icon..
          if (isDownwardPriceMovement)
            Image.asset(
              isSelected
                  ? "assets/images/price_decrease_white.png"
                  : "assets/images/price_decrease.png",
              height: heightPriceDirectionIcon,
            ),

          /// 2. if the app isn't fetching the current
          /// instrument's price, and the current
          /// price reflects an increase in the
          /// instrument's value, show a blue upward
          /// price movement (image) icon..
          if (isUpwardPriceMovement)
            Image.asset(
              isSelected
                  ? "assets/images/price_increase_white.png"
                  : "assets/images/price_increase.png",
              height: heightPriceDirectionIcon,
            ),

          /// PRICE NOT DISPLAYED ICON
          ///
          /// if the app isn't fetching the current
          /// instrument's price, and the current
          /// price does not reflect any change in the
          /// instrument's value OR the current
          /// instrument's price should and will not be
          /// displayed, show a black downward price
          /// movement (image) icon..
          if (isNotDisplayedPriceOrNoPriceMovement)
            Image.asset(
              "assets/images/price_fetching.png",
              height: heightPriceDirectionIcon,
            ),

          /// margin - price direction and currency
          /// pair
          SizedBox(
            height: marginPriceDirectionAndCurrencyPair,
          ),

          /// currency name / currency name holder
          SizedBox(
            height: heightSymbolSizedBox,
            child: isFetchingPrices
                ?

                /// currency pair lazy loading
                currencyPairLazyLoading()
                :

                /// currency price
                currencyPairOrPrice(
                    currentSymbolOrInstrumentOrPrice: currentSymbolOrInstrument,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeSymbols,
                    fontColor: isSelected ? Colors.white : Colors.black),
          ),

          /// margin - currency pair and currency
          /// price
          SizedBox(
            height: marginCurrencyPairAndCurrencyPrice,
          ),

          /// currency price / currency price holder
          SizedBox(
            height: heightPriceSizedBox,
            child: currencyPairOrPrice(
                isFetching: isFetchingPrices,
                currentSymbolOrInstrumentOrPrice: isFetchingPrices
                    ? "fetching"
                    : priceAllInstruments[currentSymbolOrInstrument]
                            ["current_price"]
                        .toString(),
                fontWeight: FontWeight.w300,
                fontSize: fontSizePrices,
                fontColor: isSelected ? Colors.white : Colors.black),
          ),
        ]));
  }
}

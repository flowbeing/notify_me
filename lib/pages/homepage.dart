import "package:flutter/material.dart";

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

  @override
  void didChangeDependencies() {

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

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

  }

  Widget build(BuildContext context){
    return Scaffold(
        appBar: null,
        /// The background
        body: Container(
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
                  itemCount: 6,
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
                      child: const Text("1")
                    );
                  },
                ),
              )

            ],
          )
        )
    );
  }

}
import "package:flutter/material.dart";

import "./custom_text_button.dart";
import "./dot_divider.dart";

import "../../data/enums.dart";

class InstrumentFilters extends StatelessWidget{

  InstrumentFilters({
    required this.fontSizeAlertsAndOtherMenuItemsSizedBox,
    required this.widthDotDivider,
    required this.iconSizeDotDivider
  });

  final double fontSizeAlertsAndOtherMenuItemsSizedBox;
  final double widthDotDivider;
  final double iconSizeDotDivider;

  void updateInstrumentFilter({
    required filter
  }){


  }

  Widget build(BuildContext context){



    return Row(
      children: <Widget>[

        /// FILTERS
        ///
        /// 1. All
        CustomTextButton(
            text: "All",
            fontSize: fontSizeAlertsAndOtherMenuItemsSizedBox
        ),

        /// dot divider
        DotDivider(
            widthDotDivider: widthDotDivider,
            iconSizeDotDivider: iconSizeDotDivider
        ),

        /// 2. "Forex"
        CustomTextButton(
            text: "Forex",
            fontSize: fontSizeAlertsAndOtherMenuItemsSizedBox
        ),

        /// dot divider
        DotDivider(
            widthDotDivider: widthDotDivider,
            iconSizeDotDivider: iconSizeDotDivider
        ),

        /// 3. "Crypto"
        CustomTextButton(
            text: "Crypto",
            fontSize: fontSizeAlertsAndOtherMenuItemsSizedBox
        )

      ],
    );
  }
}
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import '../../providers/data_provider.dart';

import "./custom_text_button.dart";
import "./dot_divider.dart";

import "../../data/enums.dart";

/// Instrument Filters
class InstrumentFilters extends StatefulWidget {
  InstrumentFilters(
      {required this.fontSizeAlertsAndOtherMenuItemsSizedBox,
      required this.widthDotDivider,
      required this.iconSizeDotDivider,
      });

  final double fontSizeAlertsAndOtherMenuItemsSizedBox;
  final double widthDotDivider;
  final double iconSizeDotDivider;

  @override
  State<InstrumentFilters> createState() => _InstrumentFiltersState();
}

/// Instrument Filters' State
class _InstrumentFiltersState extends State<InstrumentFilters> {

  DataProvider? dataProvider;

  @override
  void didChangeDependencies() {

    dataProvider = Provider.of<DataProvider>(context, listen:true);

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant InstrumentFilters oldWidget) {

    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  Filter selectedFilterOption = Filter.all;

  void updateInstrumentFilter({required Filter selectedFilter}) {

    /// updates the selected filter variable to ensure that the right
    /// filter option is highlighted..
    setState(() {
      selectedFilterOption = selectedFilter;
    });

    /// rebuilds the homepage to reflect prices data that match the selected
    /// filter..
    dataProvider!.updateFilter(filter: selectedFilterOption);


  }

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        /// FILTERS
        ///
        /// 1. All
        CustomTextButton(
          currentFilter: Filter.all,
          selectedFilter: selectedFilterOption,
          fontSize: widget.fontSizeAlertsAndOtherMenuItemsSizedBox,
          functionUpdateSelectedFilter: updateInstrumentFilter,
        ),

        /// dot divider
        DotDivider(
            widthDotDivider: widget.widthDotDivider,
            iconSizeDotDivider: widget.iconSizeDotDivider),

        /// 2. "Forex"
        CustomTextButton(
            currentFilter: Filter.forex,
            selectedFilter: selectedFilterOption,
            fontSize: widget.fontSizeAlertsAndOtherMenuItemsSizedBox,
            functionUpdateSelectedFilter: updateInstrumentFilter
        ),

        /// dot divider
        DotDivider(
            widthDotDivider: widget.widthDotDivider,
            iconSizeDotDivider: widget.iconSizeDotDivider),

        /// 3. "Crypto"
        CustomTextButton(
            currentFilter: Filter.crypto,
            selectedFilter: selectedFilterOption,
            fontSize: widget.fontSizeAlertsAndOtherMenuItemsSizedBox,
            functionUpdateSelectedFilter: updateInstrumentFilter
        )
      ],
    );
  }
}

import "package:flutter/material.dart";

import "./custom_text_button.dart";
import "./dot_divider.dart";

import "../../data/enums.dart";

/// Instrument Filters
class InstrumentFilters extends StatefulWidget {
  InstrumentFilters(
      {required this.fontSizeAlertsAndOtherMenuItemsSizedBox,
      required this.widthDotDivider,
      required this.iconSizeDotDivider,
      required this.updateAppFilterClicked,
      required this.isFirstValueInMapOfAllInstrumentsContainsFetching});

  final double fontSizeAlertsAndOtherMenuItemsSizedBox;
  final double widthDotDivider;
  final double iconSizeDotDivider;
  /// helps reflect the selected filter option and its corresponding data
  /// on the UI..
  final void Function({required Filter selectedFilterOption})
      updateAppFilterClicked;
  /// helps determine whether instruments prices' are still being fetched..
  final bool isFirstValueInMapOfAllInstrumentsContainsFetching;

  @override
  State<InstrumentFilters> createState() => _InstrumentFiltersState();
}

/// Instrument Filters' State
class _InstrumentFiltersState extends State<InstrumentFilters> {
  Filter selectedFilterOption = Filter.all;

  void updateInstrumentFilter({required Filter selectedFilter}) {

    /// updates the selected filter variable to ensure that the right
    /// filter option is highlighted..
    setState(() {
      selectedFilterOption = selectedFilter;
    });

    /// rebuilds the homepage to reflect prices data that match the selected
    /// filter..
    widget.updateAppFilterClicked(selectedFilterOption: selectedFilter);

  }

  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        /// FILTERS
        ///
        /// 1. All
        CustomTextButton(
          currentFilter: Filter.all,
          selectedFilter: selectedFilterOption,
          fontSize: widget.fontSizeAlertsAndOtherMenuItemsSizedBox,
          functionUpdateSelectedFilter: updateInstrumentFilter,
          isFirstValueInMapOfAllInstrumentsContainsFetching:
              widget.isFirstValueInMapOfAllInstrumentsContainsFetching,
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
            functionUpdateSelectedFilter: updateInstrumentFilter,
            isFirstValueInMapOfAllInstrumentsContainsFetching:
                widget.isFirstValueInMapOfAllInstrumentsContainsFetching),

        /// dot divider
        DotDivider(
            widthDotDivider: widget.widthDotDivider,
            iconSizeDotDivider: widget.iconSizeDotDivider),

        /// 3. "Crypto"
        CustomTextButton(
            currentFilter: Filter.crypto,
            selectedFilter: selectedFilterOption,
            fontSize: widget.fontSizeAlertsAndOtherMenuItemsSizedBox,
            functionUpdateSelectedFilter: updateInstrumentFilter,
            isFirstValueInMapOfAllInstrumentsContainsFetching:
                widget.isFirstValueInMapOfAllInstrumentsContainsFetching)
      ],
    );
  }
}

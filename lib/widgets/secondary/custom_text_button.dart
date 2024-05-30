import "package:flutter/material.dart";

import '../../data/enums.dart';

class CustomTextButton extends StatefulWidget {
  CustomTextButton(
      {required this.fontSize,
      required this.currentFilter,
      required this.selectedFilter,

      /// helps determine whether instruments prices' are still being fetched..
      /// if so, this button will be deactivated..
      this.isFirstValueInMapOfAllInstrumentsContainsFetching = false,

      /// helps reflect the selected filter option and its corresponding data
      /// on the UI..
      this.functionUpdateSelectedFilter});

  final double fontSize;
  final Filter currentFilter;
  final Filter selectedFilter;
  final bool isFirstValueInMapOfAllInstrumentsContainsFetching;
  final Function({required Filter selectedFilter})?
      functionUpdateSelectedFilter;

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

/// CustomTextButton's state
class _CustomTextButtonState extends State<CustomTextButton> {
  String text = "";

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (widget.currentFilter == Filter.all) {
      text = "All";
    } else if (widget.currentFilter == Filter.forex) {
      text = "Forex";
    } else if (widget.currentFilter == Filter.crypto) {
      text = "Crypto";
    } else if (widget.currentFilter == Filter.none &&
        widget.selectedFilter == Filter.none &&
        widget.functionUpdateSelectedFilter == null) {
      text = "Mute All";
    }

    super.didChangeDependencies();
  }

  // FontWeight fontWeight = FontWeight.normal;
  bool isCustomTextButtonClicked = false;

  @override
  GestureDetector build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /// if the current Text Button is a filter, update the selected filter
        /// variable...
        ///
        /// the conditions below mean "if the current button isn't currently
        /// selected, a homepage updating function has been specified,
        /// and prices are not currently being fetched, allow this button to
        /// be displayed as the selected filter option on-screen..
        if (widget.selectedFilter != widget.currentFilter &&
            widget.functionUpdateSelectedFilter != null  &&
            widget.isFirstValueInMapOfAllInstrumentsContainsFetching == false) {
          print("reflecting this");
          widget.functionUpdateSelectedFilter!(
              selectedFilter: widget.currentFilter);
        }

        /// else if this is a "Mute All" button, signal that it has been tapped
        /// and reflect it on the UI..
        ///
        /// useful for the "Mute All" button which stands alone..
        else if (widget.currentFilter == Filter.none &&
            widget.selectedFilter == Filter.none) {
          print("reflecting this 2");
          setState(() {
            isCustomTextButtonClicked = !isCustomTextButtonClicked;
          });
        }
      },
      child: Text(text,
          style: TextStyle(
              fontFamily: "PT-Mono",
              fontSize: widget.fontSize,
              fontWeight: (widget.selectedFilter == widget.currentFilter &&

                          /// functionUpdateSelectedFilter will be null for
                          /// "Mute All" button
                          widget.functionUpdateSelectedFilter != null)
                          || isCustomTextButtonClicked == true

                  /// --
                  ? FontWeight.w700
                  : FontWeight.normal,
              color: widget.isFirstValueInMapOfAllInstrumentsContainsFetching
                  ? Colors.grey
                  : Colors.black)),
    );
  }
}

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/data_provider.dart";

import '../../data/enums.dart';

class CustomTextButton extends StatefulWidget {
  CustomTextButton(
      {required this.fontSize,
      required this.currentFilter,
      required this.selectedFilter,
      this.functionUpdateSelectedFilter});

  final double fontSize;

  /// used to identify when the custom text button is for the Mute all button
  final Filter currentFilter;

  /// used to identify when the custom text button is for the Mute all button
  final Filter selectedFilter;

  /// helps reflect the selected filter option and its corresponding data
  /// on the UI..
  final Function({required Filter selectedFilter})?
      functionUpdateSelectedFilter;

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

/// CustomTextButton's state
class _CustomTextButtonState extends State<CustomTextButton> {
  DataProvider? dataProvider;

  String text = "";

  /// should the custom button be highlighted?
  bool isCustomTextButtonActivated = false;

  /// is map of all alerts empty
  // bool isMapOfAllAlertsEmpty = false;

  @override
  void didChangeDependencies() {
    /// defining data provider
    dataProvider = Provider.of(context, listen: true);

    /// updating bool that signals whether all existing alerts, if any, are
    /// currently muted..
    setState(() {
      isCustomTextButtonActivated = dataProvider!.getIsMutedAll();
      // isMapOfAllAlertsEmpty = dataProvider!.isMapOfAllAlertsEmpty();
    });

    print("isCustomTextButtonActivated: ${isCustomTextButtonActivated}");

    /// defining filters
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

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  // FontWeight fontWeight = FontWeight.normal;

  @override
  GestureDetector build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        /// if the current Text Button is a filter, update the selected filter
        /// variable...
        ///
        /// the conditions below mean "if the current button isn't currently
        /// selected, a homepage updating function has been specified,
        /// and prices are not currently being fetched, allow this button to
        /// be displayed as the selected filter option on-screen..
        if (widget.selectedFilter != widget.currentFilter &&
            widget.functionUpdateSelectedFilter != null &&
            dataProvider!
                    .getIsFirstValueInMapOfAllInstrumentsContainsFetching() ==
                false) {
          print("reflecting this");
          widget.functionUpdateSelectedFilter!(
              selectedFilter: widget.currentFilter
          );
        }

        /// else if this is a "Mute All" button, signal that it has been tapped
        /// and reflect it on the UI..
        ///
        /// useful for the "Mute All" button which stands alone..
        else if (widget.currentFilter == Filter.none &&
            widget.selectedFilter == Filter.none) {
          print("reflecting this 2");
          if (dataProvider!
                  .getIsFirstValueInMapOfAllInstrumentsContainsFetching() ==
              false) {
            setState(() {
              isCustomTextButtonActivated = !isCustomTextButtonActivated;

            });

            /// if the "mute all" button has been activated and should be
            /// highlighted, mute all alerts
            if (isCustomTextButtonActivated == true) {
              /// muting all alerts
              dataProvider!.muteUnMuteAllOrCalcIsAllMutedOrIsPriceAlertFulfilled(
                  alertOperationType: AlertOperationType.mute);
            }

            /// ... else if "mute all" button has been deactivated, un-mute
            /// all alerts
            else if (isCustomTextButtonActivated == false) {
              /// un-muting all alerts
              dataProvider!.muteUnMuteAllOrCalcIsAllMutedOrIsPriceAlertFulfilled(
                  alertOperationType: AlertOperationType.unMute);
            }

            /// calculate and update whether all button have been muted
            dataProvider!.muteUnMuteAllOrCalcIsAllMutedOrIsPriceAlertFulfilled(
                alertOperationType: AlertOperationType.calcIsAllAlertsMuted);
            
          }
        }

        /// saving the (mute or un-mute all changes) changes locally
        await dataProvider!.savePriceAlertsToLocalStorage();
      },
      child: Text(text,
          style: TextStyle(
              fontFamily: "PT-Mono",
              fontSize: widget.fontSize,
              fontWeight: (widget.selectedFilter == widget.currentFilter &&

                          /// functionUpdateSelectedFilter will only be null for
                          /// "Mute All" button
                          widget.functionUpdateSelectedFilter != null) ||
                      (widget.functionUpdateSelectedFilter == null &&
                          isCustomTextButtonActivated == true
                          // && isMapOfAllAlertsEmpty == false
                      )

                  /// --
                  ? FontWeight.w700
                  : FontWeight.normal,
              color: dataProvider!
                      .getIsFirstValueInMapOfAllInstrumentsContainsFetching()
                  ? Colors.grey
                  : Colors.black)),
    );
  }
}

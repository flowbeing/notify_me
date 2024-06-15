
// enum DataType {
//   forex,
//   stock,
//   crypto,
//   etf,
//   indices,
//   fund,
//   bond
// }

/// used to filter the displayed financial markets' data
enum Filter {
  all,
  forex,
  crypto,
  none
}

/// 1. used to mute, un-mute, or remove price alerts or
/// 2. determine the number of alerts that have been muted..
///    especially whether all alerts have been muted..
/// 3. calculate the unit price of a currency pair
/// 4. determine whether each currency pair has been fulfilled and registers
///    the result..
enum AlertOperationType {
  mute,
  unMute,
  /// signals that one or more alerts  should be removed
  remove,
  calcIsAllAlertsMuted,
  calcUnitPrice,
  /// used to a bool that signals whether the each alert price has been met
  /// or fulfilled
  setIsAlertFulfilled,
  none
}

/// used to specify the position of an alert price relative to the price of the
/// alert instrument at the time of the price alert's creation
enum AlertPricePosition {
  up,
  down,
  none
}
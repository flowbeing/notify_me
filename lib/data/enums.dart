enum DataType {
  forex,
  stock,
  crypto,
  etf,
  indices,
  fund,
  bond
}

enum Filter {
  all,
  forex,
  crypto,
  none
}

enum AlertOperationType {
  mute,
  unMute,
  /// signals that one or more alerts should be removed
  remove,
  calcIsAllAlertsMuted,
  calcUnitPrice,
  /// used to a bool that signals whether the each alert price has been met
  /// or fulfilled
  setAlertIsFulfilled,
  none
}
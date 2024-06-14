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
  remove,
  calcIsAllAlertsMuted
}
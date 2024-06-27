import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

/// This method clean a DateTime string so that it can be used as a firebase
/// realtime database map key
///
/// '_" represents "." - a dot
/// "__" represents " " - a space
String cleanDateTimeAndReturnString({required DateTime dateTime}) {
  return dateTime
      .toString()
      .replaceAll(" ", "__")
      .replaceAll(".", "_");
  // .replaceAll("#", "_")
  // .replaceAll("\$", "_")
  // .replaceAll("[", "_")
  // .replaceAll("]", "_")

  // .replaceAll("-", "_")
  // .replaceAll(":", "_");
}

/// retrieves the DateTime object (as string) from a cleaned DateTime string..
String retrieveDatetimeStringFromCleanedDateTimeString({required String cleanedDateTimeString}){
  return cleanedDateTimeString
      .replaceAll("__", " ")
      .replaceAll("_", ".");
}

/// this method helps signal to an active update device through firebase that
/// it's exceeded the max allowed update time so that it can self-stop it's
/// price update operation
void updateIsAllowedTimeExpiredMapInFirebase({
  required DatabaseReference allowedTimeActiveUpdateDevicesTrackingRef,
  required String deviceUniqueId,
}) async {

  Map isAllowedTimeExpiredMap= jsonDecode(jsonDecode(jsonEncode((await allowedTimeActiveUpdateDevicesTrackingRef.get()).value!)));

  isAllowedTimeExpiredMap[deviceUniqueId]=true; /// ---> remove in getRealtimePriceAll when the disconnect device comes alive to stop it's getRealtimePriceAll process
  await allowedTimeActiveUpdateDevicesTrackingRef.set(jsonEncode(isAllowedTimeExpiredMap));

}
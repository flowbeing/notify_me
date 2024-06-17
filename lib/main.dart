import "dart:async";
import 'dart:io';

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import 'package:device_frame/device_frame.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/data_provider.dart';

import 'pages/homepage.dart';

Future main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  //
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(NotifyMeApp());
}

class NotifyMeApp extends StatelessWidget {

  Widget homepage = Homepage();

  Widget build(BuildContext context) {



    print("defaultTargetPlatform: ${defaultTargetPlatform}");

    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      homepage =
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              DeviceFrame(device: Devices.ios.iPhone13ProMax, screen: Homepage()),

            ],
          );
    }

    return ChangeNotifierProvider(
      create: (ctx) => DataProvider(),
      child: MaterialApp(title: "Notify Me", home: homepage),
    );
  }
}

import "dart:async";
import 'dart:io';

import "package:flutter/material.dart";
import 'package:notify_me/data/data.dart';
import "package:provider/provider.dart";
import 'package:device_frame/device_frame.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/data_provider.dart';

import 'pages/homepage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await Firebase.initializeApp();

  runApp(NotifyMeApp());
}

class NotifyMeApp extends StatelessWidget {

  /// homepage widget
  Widget homepage = Homepage();

  /// devices
  DeviceInfo iPhone13ProMax= Devices.ios.iPhone13ProMax;
  DeviceInfo iPhone13= Devices.ios.iPhone13;
  DeviceInfo iPad= Devices.ios.iPad;
  DeviceInfo iPad12InchesGen2= Devices.ios.iPad12InchesGen2;
  DeviceInfo iPad12InchesGen4= Devices.ios.iPad12InchesGen4;
  DeviceInfo iPadAir4= Devices.ios.iPadAir4;
  DeviceInfo iPadPro11Inches= Devices.ios.iPadPro11Inches;
  DeviceInfo iPhone12= Devices.ios.iPhone12;
  DeviceInfo iPhone12Mini= Devices.ios.iPhone12Mini;
  DeviceInfo iPhone12ProMax= Devices.ios.iPhone12ProMax;
  DeviceInfo iPhone13Mini= Devices.ios.iPhone13Mini;
  DeviceInfo iPhoneSE= Devices.ios.iPhoneSE;


  Widget build(BuildContext context) {

    print("defaultTargetPlatform: ${defaultTargetPlatform}");

    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      homepage =
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// A column of widget on the left hand side of the device frame
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                verticalDirection: VerticalDirection.up,
                children: [

                  /// Niagara Color meaning
                  ElevatedButton(
                    onPressed: null,
                    onHover: null,
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                        foregroundColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                        overlayColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                        shadowColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ))
                    ),
                    child: const Text(
                      "Price Up ↑",
                      style: TextStyle(
                          fontFamily: "PT-Mono",
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),

                  /// Spacing
                  const SizedBox(
                    height: 10,
                  ),

                  /// Orange color meaning
                  ElevatedButton(
                    onPressed: null,
                    onHover: null,
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(const Color(0xFFFC8955)),
                        foregroundColor: WidgetStateProperty.all(const Color(0xFFFC8955)),
                        overlayColor: WidgetStateProperty.all(const Color(0xFFFC8955)),
                        shadowColor: WidgetStateProperty.all(const Color(0xFFFC8955)),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ))
                    ),
                    child: const Text(
                      "Price down ↓",
                      style: TextStyle(
                          fontFamily: "PT-Mono",
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),

                  /// Spacing
                  const SizedBox(
                    height: 10,
                  ),

                  /// Emperor color
                  ElevatedButton(
                    onPressed: null,
                    onHover: null,
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Color(0xFFF5F4FB)
                                .withRed(80)
                                .withBlue(80)
                                .withGreen(80)
                        ),
                        foregroundColor: WidgetStateProperty.all(
                            Color(0xFFF5F4FB)
                                .withRed(80)
                                .withBlue(80)
                                .withGreen(80)
                        ),
                        overlayColor: WidgetStateProperty.all(
                            Color(0xFFF5F4FB)
                                .withRed(80)
                                .withBlue(80)
                                .withGreen(80)
                        ),
                        shadowColor: WidgetStateProperty.all(
                            Color(0xFFF5F4FB)
                                .withRed(80)
                                .withBlue(80)
                                .withGreen(80)
                        ),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ))
                    ),
                    child: const Text(
                      "No Price Change",
                      style: TextStyle(
                          fontFamily: "PT-Mono",
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),

                  /// Spacing
                  const SizedBox(
                    height: 10,
                  ),

                  /// toggle device left button
                  ElevatedButton(
                    onPressed: (){

                    },
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.black),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ))
                    ),
                    child: const Text(
                      "< TOGGLE DEVICE",
                      style: TextStyle(
                          fontFamily: "PT-Mono",
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),

              /// Spacing
              const SizedBox(
                width: 20,
              ),

              /// APPLICATION WITH A SMART DEVICE'S FRAME
              DeviceFrame(
                  device: Devices.ios.iPhone13ProMax,
                  screen: Homepage()
              ),

              /// Spacing
              const SizedBox(
                width: 20,
              ),

              /// A column of widget on the right hand side of the device frame
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                verticalDirection: VerticalDirection.up,
                children: [

                  /// Niagara Color meaning
                  ElevatedButton(
                    onPressed: null,
                    onHover: null,
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                        foregroundColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                        overlayColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                        shadowColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ))
                    ),
                    child: const Text(
                      "Hire Author",
                      style: TextStyle(
                          fontFamily: "PT-Mono",
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),

                  /// Spacing
                  const SizedBox(
                    height: 10,
                  ),

                  /// Orange color meaning
                  ElevatedButton(
                    onPressed: null,
                    onHover: null,
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(const Color(0xFFFC8955)),
                        foregroundColor: WidgetStateProperty.all(const Color(0xFFFC8955)),
                        overlayColor: WidgetStateProperty.all(const Color(0xFFFC8955)),
                        shadowColor: WidgetStateProperty.all(const Color(0xFFFC8955)),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ))
                    ),
                    child: const Text(
                      "Hide Borders",
                      style: TextStyle(
                          fontFamily: "PT-Mono",
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),

                  /// Spacing
                  const SizedBox(
                    height: 10,
                  ),

                  /// Emperor color
                  ElevatedButton(
                    onPressed: null,
                    onHover: null,
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Color(0xFFF5F4FB)
                                .withRed(80)
                                .withBlue(80)
                                .withGreen(80)
                        ),
                        foregroundColor: WidgetStateProperty.all(
                            Color(0xFFF5F4FB)
                                .withRed(80)
                                .withBlue(80)
                                .withGreen(80)
                        ),
                        overlayColor: WidgetStateProperty.all(
                            Color(0xFFF5F4FB)
                                .withRed(80)
                                .withBlue(80)
                                .withGreen(80)
                        ),
                        shadowColor: WidgetStateProperty.all(
                            Color(0xFFF5F4FB)
                                .withRed(80)
                                .withBlue(80)
                                .withGreen(80)
                        ),
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ))
                    ),
                    child: const Text(
                      "About Project",
                      style: TextStyle(
                          fontFamily: "PT-Mono",
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),

                  /// Spacing
                  const SizedBox(
                    height: 10,
                  ),

                  /// toggle device left button
                  ElevatedButton(
                    onPressed: (){

                    },
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.black),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ))
                    ),
                    child: const Text(
                      "TOGGLE DEVICE >",
                      style: TextStyle(
                          fontFamily: "PT-Mono",
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),

            ],
          );
    }

    return ChangeNotifierProvider<DataProvider>(
      create: (_) => DataProvider(),
      child: MaterialApp(title: "Notify Me", home: homepage),
    );
  }

}

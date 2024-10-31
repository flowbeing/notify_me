import "dart:async";
import 'dart:io';

import "package:flutter/material.dart";
import 'package:notify_me/data/data.dart';
import "package:provider/provider.dart";
import 'package:device_frame/device_frame.dart';
import 'package:flutter/foundation.dart';
// import "package:share_plus/share_plus.dart";
import "package:url_launcher/url_launcher.dart";
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/data_provider.dart';

import 'pages/homepage.dart';

enum OS {
  android,
  iOS
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await Firebase.initializeApp();

  runApp(NotifyMeApp());
}


/// Notify Me App
class NotifyMeApp extends StatefulWidget {

  @override
  State<NotifyMeApp> createState() => _NotifyMeAppState();
}

/// Notify Me App's State
class _NotifyMeAppState extends State<NotifyMeApp> {
  /// homepage widget
  // Widget homepage = Homepage();

  /// devices
  // DeviceInfo iPhone13ProMax= Devices.ios.iPhone13ProMax;
  //
  // DeviceInfo iPhone13= Devices.ios.iPhone13;
  //
  // DeviceInfo iPad= Devices.ios.iPad;
  //
  // DeviceInfo iPad12InchesGen2= Devices.ios.iPad12InchesGen2;
  //
  // DeviceInfo iPad12InchesGen4= Devices.ios.iPad12InchesGen4;
  //
  // DeviceInfo iPadAir4= Devices.ios.iPadAir4;
  //
  // DeviceInfo iPadPro11Inches= Devices.ios.iPadPro11Inches;
  //
  // DeviceInfo iPhone12= Devices.ios.iPhone12;
  //
  // DeviceInfo iPhone12Mini= Devices.ios.iPhone12Mini;
  //
  // DeviceInfo iPhone12ProMax= Devices.ios.iPhone12ProMax;
  //
  // DeviceInfo iPhone13Mini= Devices.ios.iPhone13Mini;
  //
  // DeviceInfo iPhoneSE= Devices.ios.iPhoneSE;

  // /// bool that signals whether the current device type is an iphone or an
  // /// android
  // bool isAndroid=false;

  /// list of all devices
  List<DeviceInfo> allDevices= Devices.ios.all;

  /// index of the current device
  int countCurrentDeviceIndex=5;

  /// current OS
  OS currentDeviceOS=OS.iOS;

  /// bool that signals whether the currently visible device's borders should
  /// be hidden or not
  bool isShowDeviceBorders=true;

  final Uri _uri=Uri.parse('https://facebook.com');

  /// Custom Elevated Button
  customElevationButton({
    required Color color,
    void Function()? onPressed,
    void Function(bool trueOrFalse)? onHover,
    /// defines whether the child element is a text or image
    bool isChildImage=false,
    required String textOrImageString,
  }){

    return ElevatedButton(
      onPressed: onPressed,
      onHover: onHover,
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(color),
          foregroundColor: WidgetStateProperty.all(color),
          overlayColor: WidgetStateProperty.all(color),
          shadowColor: WidgetStateProperty.all(color),
          elevation: WidgetStateProperty.all(0),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
          ))
      ),
      child: isChildImage ? Image.asset(
        textOrImageString
      ) : Text(
        textOrImageString,// isShowDeviceBorders==false ? "Show Borders 📱": "Hide Borders 📱",
        style: const TextStyle(
            fontFamily: "PT-Mono",
            fontWeight: FontWeight.bold,
            color: Colors.white
        ),
      ),
    );
  }

  Widget build(BuildContext context) {

    // print("defaultTargetPlatform: ${defaultTargetPlatform}");

    // defaultTargetPlatform != TargetPlatform.iOS && /// ---<
    //         defaultTargetPlatform != TargetPlatform.android

    return ChangeNotifierProvider<DataProvider>(
      create: (_) => DataProvider(),
      child: MaterialApp(
          title: "Notify Me - Daniel Oyebolu",
          home: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              /// This row contains:
              /// 1. Left side toggle buttons
              /// 2. The device frame and the device's functionalities
              /// 3. Right side toggle buttons
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /// A column of widget on the left hand side of the device frame
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    verticalDirection: VerticalDirection.up,
                    children: [

                      /// change OS button - iOS vs android
                      ElevatedButton(
                        onPressed: (){

                          /// changing the selected OS (Operating System)
                          setState(() {
                            if (currentDeviceOS==OS.iOS){
                              currentDeviceOS=OS.android;
                              allDevices=Devices.android.all;
                              countCurrentDeviceIndex=0;
                            } else if (currentDeviceOS==OS.android){
                              currentDeviceOS=OS.iOS;
                              allDevices=Devices.ios.all;
                              countCurrentDeviceIndex=0;
                            }
                          });

                        },
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.black),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ))
                        ),
                        child: Text(
                          "Change OS to ${currentDeviceOS==OS.iOS ? "Android": "iOS"}",
                          style: const TextStyle(
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

                      /// Niagara Color - meaning
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

                      /// Orange color - meaning
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

                          /// change the device
                          if (countCurrentDeviceIndex>=1){
                            setState(() {
                              countCurrentDeviceIndex-=1;
                            });
                          }

                        },
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(countCurrentDeviceIndex==0 ? Colors.grey : Colors.black),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ))
                        ),
                        child: const Text(
                          "< PREV DEVICE",
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
                    key: ValueKey("${currentDeviceOS==OS.iOS? "iOS": "android"}$countCurrentDeviceIndex"), //allDevices[countCurrentDeviceIndex].name
                    device: allDevices[countCurrentDeviceIndex],
                    screen: Homepage(
                      deviceName: allDevices[countCurrentDeviceIndex].name,
                      safeAreaDimensions: allDevices[countCurrentDeviceIndex].safeAreas,
                    ),
                    // isFrameVisible: isShowDeviceBorders,
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

                      /// Device Name
                      ElevatedButton(
                        onPressed: null,
                        onHover: null,
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.white),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Colors.black
                                )
                            ))
                        ),
                        child: Text(
                          allDevices[countCurrentDeviceIndex].name, // allDevices[countCurrentDeviceIndex].name
                          style: const TextStyle(
                              fontFamily: "PT-Mono",
                              fontWeight: FontWeight.bold,
                              color: Colors.black
                          ),
                        ),
                      ),

                      /// Spacing
                      const SizedBox(
                        height: 10,
                      ),

                      /// "Hire / Contact The Developer" button
                      // ElevatedButton(
                      //   onPressed: (null),
                      //   onHover: null,
                      //   style: ButtonStyle(
                      //       backgroundColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                      //       foregroundColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                      //       overlayColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                      //       shadowColor: WidgetStateProperty.all(const Color(0xFF069D91)),
                      //       shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(5)
                      //       ))
                      //   ),
                      //   child: const Text(
                      //     "Hire Daniel 🤝",
                      //     style: TextStyle(
                      //         fontFamily: "PT-Mono",
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.white
                      //     ),
                      //   ),
                      // ),

                      /// "Hire / Contact Daniel" button
                      customElevationButton(
                          onPressed: () async{
                            // print("launching url"); --

                            // Uri uri=Uri.parse("https://www.linkedin.com/feed/?shareActive=true&text=Check out this cool app demo by @danieloyebolu - ${Uri.base}");
                            Uri uri=Uri.parse("https://linkedin.com/in/daniel-oyebolu");

                            await launchUrl(uri);
                            // await Share.share("A great app: ${Uri.base}");
                          },
                          color: const Color(0xFF069D91),
                          textOrImageString: "Contact Daniel 🤝"
                      ),

                      /// Spacing
                      const SizedBox(
                        height: 10,
                      ),

                      /// a row of share buttons
                      ///     - assets/images/facebook.png
                      //     - assets/images/instagram.png
                      //     - assets/images/linkedin.png
                      //     - assets/images/twitter.png
                      Row(
                        children: [

                          /// Share to LinkedIn Button
                          customElevationButton(
                              onPressed: () async{
                                // print("launching url"); --

                                // Uri uri=Uri.parse("https://www.linkedin.com/feed/?shareActive=true&text=Check out this cool app demo by @danieloyebolu - ${Uri.base}");
                                Uri uri=Uri.parse("https://www.linkedin.com/feed/?shareActive=true&text="
                                    "→ Check out this beautiful app by 👊👊🏾🤓Daniel Oyebolu  😍 - ${Uri.base}\n"
                                    "→ It's financial markets application he coded using Flutter, Firebase and Rest API. 👨🏾‍💻\n"
                                    "→ Sharing for reach! \n\n"

                                    "#innovator #flutter #firebase #RESTAPI"
                                );

                                await launchUrl(uri);
                                // await Share.share("A great app: ${Uri.base}");
                              },
                              color: const Color(0xFFFC8955),
                              textOrImageString: "Share on LinkedIn"
                          ),

                          /// Spacing
                          const SizedBox(
                            width: 5,
                          ),

                          /// Share to FB Button
                          customElevationButton(
                              onPressed: () async{
                                // print("launching url");

                                Uri uri=Uri.parse("https://www.facebook.com/sharer/sharer.php?u=${Uri.base}");

                                await launchUrl(uri);
                                // await Share.share("A great app: ${Uri.base}");
                              },
                              color: const Color(0xFFFC8955),
                              textOrImageString: "FB"
                          ),

                          /// Spacing
                          const SizedBox(
                            width: 5,
                          ),

                          /// Share to Twitter text
                          customElevationButton(
                              onPressed: () async{
                                // print("launching url");

                                Uri uri=Uri.parse("http://twitter.com/share?text=→ Check out this beautiful app by Daniel Oyebolu 😍\n"
                                    "→ It's financial markets application he coded using Flutter, Firebase and Rest API. 👨🏾‍💻\n"
                                    "🥂\n\n&url=${Uri.base}&hashtags=innovator,flutter,firebase,RESTAPI");

                                await launchUrl(uri);
                                // await Share.share("A great app: ${Uri.base}");
                              },
                              color: const Color(0xFFFC8955),
                              textOrImageString: "X"
                          ),

                        ],
                      ),

                      /// Spacing
                      const SizedBox(
                        height: 10,
                      ),

                      /// About (Flutter) Project
                      customElevationButton(
                          onPressed: () async{

                            Uri uri=Uri.parse("https://www.linkedin.com/posts/daniel-oyebolu_strategic-alliances-appearances-expectations-activity-7213893394060750848-gsCq");

                            await launchUrl(uri);

                          },
                          color: Color(0xFFF5F4FB)
                              .withRed(80)
                              .withBlue(80)
                              .withGreen(80),
                          textOrImageString: "About (Flutter) Project 🔖"
                      ),

                      // /// Emperor color
                      // ElevatedButton(
                      //   onPressed: null,
                      //   onHover: null,
                      //   style: ButtonStyle(
                      //       backgroundColor: WidgetStateProperty.all(
                      //           Color(0xFFF5F4FB)
                      //               .withRed(80)
                      //               .withBlue(80)
                      //               .withGreen(80)
                      //       ),
                      //       foregroundColor: WidgetStateProperty.all(
                      //           Color(0xFFF5F4FB)
                      //               .withRed(80)
                      //               .withBlue(80)
                      //               .withGreen(80)
                      //       ),
                      //       overlayColor: WidgetStateProperty.all(
                      //           Color(0xFFF5F4FB)
                      //               .withRed(80)
                      //               .withBlue(80)
                      //               .withGreen(80)
                      //       ),
                      //       shadowColor: WidgetStateProperty.all(
                      //           Color(0xFFF5F4FB)
                      //               .withRed(80)
                      //               .withBlue(80)
                      //               .withGreen(80)
                      //       ),
                      //       elevation: WidgetStateProperty.all(0),
                      //       shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(5)
                      //       ))
                      //   ),
                      //   child: const Text(
                      //     "About Project 🔖",
                      //     style: TextStyle(
                      //         fontFamily: "PT-Mono",
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.white
                      //     ),
                      //   ),
                      // ),

                      /// Spacing
                      const SizedBox(
                        height: 10,
                      ),

                      /// toggle device right button
                      ElevatedButton(
                        onPressed: (){

                          /// change the device when the right toggle button gets
                          /// clicked..
                          if (countCurrentDeviceIndex<=allDevices.length-2){
                            setState(() {
                              countCurrentDeviceIndex+=1;
                            });
                          }

                        },
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(countCurrentDeviceIndex==allDevices.length-1 ? Colors.grey : Colors.black),
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ))
                        ),
                        child: const Text(
                          "NEXT DEVICE >",
                          style: TextStyle(
                              fontFamily: "PT-Mono",
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                      )

                    ],
                  ),

                ],
              ),
            ),
          )
      ),
    );
  }
}

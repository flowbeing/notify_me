import "dart:async";

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import 'providers/data_provider.dart';

import 'pages/homepage.dart';

Future main() async{

  runApp(NotifyMeApp());

}

class NotifyMeApp extends StatelessWidget{



  Widget build(BuildContext context){

    return ChangeNotifierProvider(
      create: (ctx) => DataProvider(),
      child: MaterialApp(
          title: "Notify Me",
          home: Homepage()
      ),
    );
  }

}
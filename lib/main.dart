import 'dart:io';
import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/config/route_names.dart';
import 'package:africanplug/landing.dart';
import 'package:africanplug/models/user.dart';
import 'package:africanplug/screens/login/login.dart';
import 'package:africanplug/screens/login/login_signup.dart';
import 'package:africanplug/screens/upload/upload.dart';
import 'package:africanplug/screens/videos/videos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';

GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
late Box appBox;

void main() async {
  await initHiveForFlutter();
  appBox = await Hive.openBox('appBox');
  runApp(
    GraphQLProvider(
      client: graphQLConfiguration.client,
      child: CacheProvider(child: MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GraphQLConfiguration graphQLConfig = new GraphQLConfiguration();
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    User user = currentUser();
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    //         statusBarColor: kPrimaryLightColor,
    //         /* set Status bar color in Android devices. */

    //         statusBarIconBrightness: Brightness.dark,
    //         /* set Status bar icons color in Android devices.*/

    //         statusBarBrightness:
    //             Brightness.light) /* set Status bar icon color in iOS. */
    //     );
    return GraphQLProvider(
        client: graphQLConfig.client,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: txtAppName,
          theme: ThemeData(
              // This is the theme of your application.
              primaryColor: kPrimaryColor,
              scaffoldBackgroundColor: Colors.white,
              inputDecorationTheme: InputDecorationTheme(
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor)),
              )),
          home: GraphQLConfiguration.sessionToken == ''
              ? LandingScreen()
              : VideosScreen(),
          routes: <String, WidgetBuilder>{
            landingRoute: (BuildContext context) => LandingScreen(),
            loginRegisterRoute: (BuildContext context) => LoginSignupScreen(),
            // homeRoute: (BuildContext context) => VideosScreen(),
            homeRoute: (BuildContext context) => VideosScreen(),
            uploadRoute: (BuildContext context) => UploadVideoPage()
          },
          // WelcomeScreen(
          //   key: key,
          // ),
        ));
  }
}

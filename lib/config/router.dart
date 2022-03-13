import 'package:africanplug/config/route_names.dart';
import 'package:africanplug/landing.dart';
import 'package:africanplug/main.dart';
import 'package:africanplug/screens/login/login_signup.dart';
import 'package:africanplug/screens/profile/user_profile.dart';
import 'package:africanplug/screens/upload/upload.dart';
import 'package:africanplug/screens/videos/videos_screen.dart';
import 'package:flutter/material.dart';

class CustomRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landingRoute:
        return MaterialPageRoute(builder: (_) => LandingScreen());
      case loginRegisterRoute:
        return MaterialPageRoute(builder: (_) => LoginSignupScreen());
      // homeRoute: (BuildContext context) => VideosScreen(),
      case homeRoute:
        return appBox.get("user") == null
            ? MaterialPageRoute(builder: (_) => LandingScreen())
            : MaterialPageRoute(builder: (_) => VideosScreen());
      case uploadRoute:
        return MaterialPageRoute(builder: (_) => UploadVideoPage());
      case profileRoute:
        List<dynamic> args = settings.arguments as List<dynamic>;
        return MaterialPageRoute(
            builder: (_) => UserProfileScreen(user_id: args[0], tab: args[1]));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}

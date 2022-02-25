import 'dart:ffi';

import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/screens/login/login.dart';
import 'package:africanplug/widgets/app/appbar.dart';
import 'package:africanplug/widgets/button/main_upload_button.dart';
import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
import 'package:africanplug/widgets/menu/main_menu.dart';
import 'package:africanplug/widgets/video/thumbnail_display.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:africanplug/widgets/video/video_tile.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MainLayout extends StatefulWidget {
  final Widget body;
  final bool upload;
  const MainLayout({Key? key, required Widget this.body, this.upload = false})
      : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState(body, upload);
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  final Widget body;
  final bool upload;

  bool isCollapsed = true;
  bool collapseFromLeft = true;

  final Duration duration = const Duration(milliseconds: 300);
  late AnimationController _aController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _menuScaleAnimation;
  late Animation<Offset> _slideAnimation;

  _MainLayoutState(this.body, this.upload);

  @override
  void initState() {
    super.initState();

    _aController = AnimationController(duration: duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.85).animate(_aController);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_aController);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_aController);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String? current_page = ModalRoute.of(context)?.settings.name;
    // print(current_page);
    return Scaffold(
      floatingActionButton:
          current_page != "/upload" ? MainUploadButton() : SizedBox(),
      body: SizedBox(
        height: size.height,
        child: Stack(children: [
          MainMenu(context, current_page, _slideAnimation, _menuScaleAnimation,
              size, 1),
          AnimatedPositioned(
            duration: duration,
            top: 0,
            bottom: 0,
            left: collapseFromLeft
                ? (isCollapsed ? 0 : 0.6 * size.width)
                : (isCollapsed ? 0 : -0.4 * size.width),
            right: collapseFromLeft
                ? (isCollapsed ? 0 : -0.4 * size.width)
                : (isCollapsed ? 0 : 0.6 * size.width),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                animationDuration: duration,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                elevation: 8.0,
                color: kPrimaryLightColor,
                child: SafeArea(
                  child: Stack(children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.height / 12,
                          ),
                          body,
                        ],
                      ),
                    ),
                    appBar(size, () {
                      setState(() {
                        // print("collapsing");
                        collapseFromLeft = true;
                        if (isCollapsed)
                          _aController.forward();
                        else
                          _aController.reverse();

                        isCollapsed = !isCollapsed;
                      });
                    }, () {}, () {}, 1)
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _logOutUser(context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      GraphQLConfiguration.removeToken();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
          ModalRoute.withName('/'));
    });
  }
}

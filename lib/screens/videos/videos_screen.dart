import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/screens/login/login.dart';
import 'package:africanplug/widgets/button/main_upload_button.dart';
import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
import 'package:africanplug/widgets/menu/main_menu.dart';
import 'package:africanplug/widgets/video/thumbnail_display.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:africanplug/widgets/video/video_tile.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({Key? key}) : super(key: key);

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool playArea = false;
  bool isPlaying = false;
  bool disposed = false;

  bool isCollapsed = true;
  bool collapseFromLeft = true;

  final Duration duration = const Duration(milliseconds: 300);
  late AnimationController _aController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _menuScaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
      ..initialize().then((_) {
        setState(() {});
        // _controller.play();
      });

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
    return Scaffold(
        floatingActionButton:
            current_page != "/upload" ? MainUploadButton() : SizedBox(),
        body: Stack(children: [
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
                    pageBody(size, context),
                    Container(
                      color: kPrimaryColor.withOpacity(0.979),
                      height: size.height / 14,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(color: kPrimaryLightColor),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  collapseFromLeft = true;
                                  if (isCollapsed)
                                    _aController.forward();
                                  else
                                    _aController.reverse();

                                  isCollapsed = !isCollapsed;
                                });
                              },
                              icon: Icon(Icons.menu),
                              color: kPrimaryColor,
                            ),
                            Text(
                              txtAppName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.search),
                              color: kPrimaryColor,
                            )
                          ],
                        ),
                      ),
                    )
                  ]),
                ),
              ),
            ),
          ),
        ]));
  }

  Container pageBody(Size size, BuildContext context) {
    return Container(
      color: kPrimaryLightColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          playArea
              ? Container(
                  height: size.height * 0.40,
                  child: Column(
                    children: [playView(context), controlView(context)],
                  ),
                )
              : SizedBox(),
          topVideosSection(size)
        ],
      ),
    );
  }

  Expanded topVideosSection(Size size) {
    return Expanded(
        child: Container(
      // decoration: BoxDecoration(color: Colors.white),
      width: size.width,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: size.height * 0.07,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(40))),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.height * 0.015),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TOP VIDEOS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kPrimaryColor),
                  ),
                  Icon(Icons.sync),
                ],
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (_, int index) {
                    return GestureDetector(
                      onTap: () {
                        onVideoTap(index, "assets/videos/ruto.mp4");
                      },
                      child: VideoTile(
                        thumbnail_url: "assets/images/ruto.jpg",
                        title: "The government's scorecard",
                        channel_name: "Visanga Kenya",
                        channel_id: 4,
                        channel_image_url: "assets/images/brian.jpg",
                        lapse: "2 days ago",
                        view_count: "21K",
                      ),
                    );
                  }))
        ],
      ),
    ));
  }

  var onUpdateControllerTime;
  void onControllerUpdate() async {
    if (disposed) {
      return;
    }
    onUpdateControllerTime = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (onUpdateControllerTime < now) {
      onUpdateControllerTime = now + 500;
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      debugPrint("Controller error");
      return;
    } else {
      final playing = controller.value.isPlaying;

      setState(() {
        isPlaying = playing;
      });
    }
  }

  onVideoTap(int index, String url) {
    debugPrint("Trying to play");
    final controller = VideoPlayerController.asset(url);
    final old_controller = _controller;
    _controller = controller;
    old_controller.removeListener(() {
      onControllerUpdate();
    });
    old_controller.pause;
    setState(() {});
    controller
      ..initialize().then((_) {
        old_controller.dispose();
        controller.addListener(() {
          onControllerUpdate;
        });
        _controller.play();

        setState(() {
          playArea = true;
          isPlaying = true;
        });
      });
  }

  Widget playView(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return Container(
        margin: EdgeInsets.only(top: size.height / 12),
        height: size.height * 0.253,
        width: double.infinity,
        child: VideoPlayer(controller),
      );
    } else {
      return Container(
        height: size.height * 0.253,
        margin: EdgeInsets.only(top: size.height / 12),
        color: Colors.white,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.slow_motion_video_rounded, color: kPrimaryLightColor),
            Text(
              "Loading. Please wait..",
              style: TextStyle(
                fontSize: 14,
              ),
            )
          ],
        ),
      );
    }
  }

  Widget controlView(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      // height: size.height * 0.04,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () async {},
            child: Icon(
              Icons.fast_rewind,
              color: kPrimaryColor,
            ),
          ),
          TextButton(
            onPressed: () async {
              if (isPlaying) {
                _controller.pause();
                setState(() {
                  isPlaying = false;
                });
              } else {
                _controller.play();
                setState(() {
                  isPlaying = true;
                });
              }
            },
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: kPrimaryColor,
            ),
          ),
          TextButton(
            onPressed: () async {},
            child: Icon(
              Icons.fast_forward,
              color: kPrimaryColor,
            ),
          ),
        ],
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

  @override
  void dispose() {
    super.dispose();
    _controller.pause();
    disposed = true;
    _controller.dispose();
    _aController.dispose();
  }
}

// import 'package:africanplug/config/config.dart';
// import 'package:africanplug/layouts/main_layout.dart';
// import 'package:africanplug/screens/videos/components/body.dart';
// import 'package:africanplug/widgets/video/video_tile.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class VideosScreen extends StatefulWidget {
//   const VideosScreen({Key? key}) : super(key: key);

//   @override
//   State<VideosScreen> createState() => _VideosScreenState();
// }

// class _VideosScreenState extends State<VideosScreen> {
//   late VideoPlayerController _controller;
//   bool isPlaying = false;
//   bool disposed = false;
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(
//         'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
//       ..initialize().then((_) {
//         setState(() {});
//         // _controller.play();
//       });
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     bool playArea = false;
//     bool disposed = false;
//     var onUpdateControllerTime;
//     return Scaffold(
//       body: MainLayout(
//           body: pageBody(
//               size,
//               context,
//               playArea,
//               _controller,
//               () {
//                 setState(() {});
//               },
//               () {
//                 setState(() {
//                   playArea = true;
//                   isPlaying = true;
//                 });
//               },
//               () async {
//                 if (isPlaying) {
//                   _controller.pause();
//                   setState(() {
//                     isPlaying = false;
//                   });
//                 } else {
//                   _controller.play();
//                   setState(() {
//                     isPlaying = true;
//                   });
//                 }
//               },
//               isPlaying,
//               disposed,
//               () async {
//                 if (disposed) {
//                   return;
//                 }
//                 onUpdateControllerTime = 0;
//                 final now = DateTime.now().millisecondsSinceEpoch;

//                 if (onUpdateControllerTime < now) {
//                   onUpdateControllerTime = now + 500;
//                 }
//                 final controller = _controller;
//                 if (controller == null || !controller.value.isInitialized) {
//                   debugPrint("Controller error");
//                   return;
//                 } else {
//                   final playing = controller.value.isPlaying;

//                   setState(() {
//                     isPlaying = playing;
//                   });
//                 }
//               })),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _controller.pause();
//     disposed = true;
//     _controller.dispose();
//   }
// }

// Container pageBody(
//     Size size,
//     BuildContext context,
//     playArea,
//     _controller,
//     stateFunction,
//     playAreaToggle,
//     pausePlayFunction,
//     isPlaying,
//     disposed,
//     controllerUpdate) {
//   return Container(
//     color: kPrimaryLightColor,
//     child: Expanded(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           playArea
//               ? Container(
//                   height: size.height * 0.40,
//                   child: Column(
//                     children: [
//                       playView(context, _controller),
//                       controlView(context, pausePlayFunction, isPlaying)
//                     ],
//                   ),
//                 )
//               : SizedBox(),
//           topVideosSection(size, _controller, stateFunction, playAreaToggle,
//               disposed, controllerUpdate)
//         ],
//       ),
//     ),
//   );
// }

// Expanded topVideosSection(Size size, _controller, stateFunction, playAreaToggle,
//     disposed, controllerUpdate) {
//   return Expanded(
//       child: Container(
//     // decoration: BoxDecoration(color: Colors.white),
//     width: size.width,
//     child: Column(
//       children: [
//         Container(
//           width: double.infinity,
//           height: size.height * 0.07,
//           decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(topRight: Radius.circular(40))),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: size.height * 0.015),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "TOP VIDEOS",
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: kPrimaryColor),
//                 ),
//                 Icon(Icons.sync),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//             child: ListView.builder(
//                 itemCount: 10,
//                 itemBuilder: (_, int index) {
//                   return GestureDetector(
//                     onTap: () {
//                       onVideoTap(
//                           index,
//                           "assets/videos/ruto.mp4",
//                           _controller,
//                           stateFunction,
//                           playAreaToggle,
//                           disposed,
//                           controllerUpdate);
//                     },
//                     child: VideoTile(
//                       thumbnail_url: "assets/images/ruto.jpg",
//                       title: "The government's scorecard",
//                       channel_name: "Visanga Kenya",
//                       channel_id: 4,
//                       channel_image_url: "assets/images/brian.jpg",
//                       lapse: "2 days ago",
//                       view_count: "21K",
//                     ),
//                   );
//                 }))
//       ],
//     ),
//   ));
// }

// onVideoTap(int index, String url, _controller, Function stateFunction,
//     Function playeAreaToggle, disposed, controllerUpdate) {
//   debugPrint("Trying to play");
//   final controller = VideoPlayerController.asset(url);
//   final old_controller = _controller;
//   _controller = controller;
//   old_controller.removeListener(() {
//     controllerUpdate(disposed);
//   });
//   old_controller.pause;
//   stateFunction();
//   controller
//     ..initialize().then((_) {
//       old_controller.dispose();
//       controller.addListener(() {
//         controllerUpdate;
//       });
//       _controller.play();
//       playeAreaToggle();
//     });
// }

// Widget playView(BuildContext context, _controller) {
//   Size size = MediaQuery.of(context).size;
//   final controller = _controller;
//   if (controller != null && controller.value.isInitialized) {
//     return Container(
//       // margin: EdgeInsets.only(top: size.height / 12),
//       height: size.height * 0.253,
//       width: double.infinity,
//       child: VideoPlayer(controller),
//     );
//   } else {
//     return Container(
//       height: size.height * 0.253,
//       // margin: EdgeInsets.only(top: size.height / 12),
//       color: Colors.white,
//       width: double.infinity,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.slow_motion_video_rounded, color: kPrimaryLightColor),
//           Text(
//             "Loading. Please wait..",
//             style: TextStyle(
//               fontSize: 14,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// Widget controlView(
//     BuildContext context, Function pausePlayFunction, isPlaying) {
//   Size size = MediaQuery.of(context).size;
//   return Container(
//     // height: size.height * 0.04,
//     width: double.infinity,
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         TextButton(
//           onPressed: () async {},
//           child: Icon(
//             Icons.fast_rewind,
//             color: kPrimaryColor,
//           ),
//         ),
//         TextButton(
//           onPressed: pausePlayFunction(),
//           child: Icon(
//             isPlaying ? Icons.pause : Icons.play_arrow,
//             color: kPrimaryColor,
//           ),
//         ),
//         TextButton(
//           onPressed: () async {},
//           child: Icon(
//             Icons.fast_forward,
//             color: kPrimaryColor,
//           ),
//         ),
//       ],
//     ),
//   );
// }

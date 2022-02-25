import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/screens/login/login.dart';
import 'package:africanplug/widgets/app/appbar.dart';
import 'package:africanplug/widgets/button/main_upload_button.dart';
import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
import 'package:africanplug/widgets/chip/image_chip.dart';
import 'package:africanplug/widgets/menu/main_menu.dart';
import 'package:africanplug/widgets/video/thumbnail_display.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:africanplug/widgets/video/video_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
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
    final key = GlobalKey();
    String? current_page = ModalRoute.of(context)?.settings.name;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: kBackgroundColor,
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
                color: kScaffoldColor,
                child: Padding(
                  padding: isCollapsed
                      ? const EdgeInsets.only(bottom: 0.0)
                      : const EdgeInsets.only(bottom: 15.0),
                  child: SafeArea(
                      child: Stack(
                    children: [
                      // Positioned(
                      //   bottom: 0,
                      //   height: size.height,
                      //   child: Image.asset(
                      //     'assets/images/grey.jpg',
                      //     height: size.height,
                      //   ),
                      // ),
                      // Positioned(
                      //   bottom: 0,
                      //   child: Container(
                      //     height: size.height / 2.4,
                      //     width: size.width,
                      //     color: kScaffoldColor,
                      //   ),
                      // ),
                      Scaffold(
                        backgroundColor: kScaffoldColor,
                        // appBar: AppBar(
                        //   elevation: 0,
                        //   backgroundColor: Colors.transparent,
                        //   iconTheme: IconThemeData(color: Colors.white),
                        //   leading: IconButton(
                        //     icon: Icon(Icons.menu),
                        //     onPressed: () {
                        //       setState(() {
                        //         collapseFromLeft = true;
                        //         if (isCollapsed)
                        //           _aController.forward();
                        //         else
                        //           _aController.reverse();

                        //         isCollapsed = !isCollapsed;
                        //       });
                        //     },
                        //   ),
                        //   title: Center(
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.max,
                        //       children: [
                        //         SizedBox(
                        //           width: size.width / 5,
                        //         ),
                        //         Icon(FlutterIcons.plug_faw5s,
                        //             color: kActiveColor),
                        //         Text("27Plug",
                        //             style: TextStyle(color: kActiveColor))
                        //       ],
                        //     ),
                        //   ),
                        //   actions: [
                        //     IconButton(
                        //       icon: CircleAvatar(
                        //         backgroundImage: AssetImage(
                        //           'assets/images/brian.jpg',
                        //         ),
                        //         backgroundColor: Colors.black26,
                        //         foregroundColor: Colors.black26,
                        //       ),
                        //       onPressed: () {},
                        //     )
                        //   ],
                        // ),
                        body: Column(
                          children: [
                            Stack(
                              children: [
                                Column(
                                  children: [
                                    appBar(size, () {
                                      setState(() {
                                        collapseFromLeft = true;
                                        if (isCollapsed)
                                          _aController.forward();
                                        else
                                          _aController.reverse();

                                        isCollapsed = !isCollapsed;
                                      });
                                    }, () {}, () {}, 1),
                                    Container(
                                      height: 290,
                                      // color: Colors.red,
                                      child: Column(
                                        children: [
                                          playView(context),
                                          controlView(context)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                !isPlaying
                                    ? Column(
                                        children: [
                                          SizedBox(height: size.height / 14),
                                          Container(
                                            width: size.width,
                                            height: 240,
                                            color: Colors.black38,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Govt\'s scorecard',
                                                        style: TextStyle(
                                                            color: kWhite,
                                                            fontSize: 17),
                                                      ),
                                                      OutlinedButton(
                                                        child: Icon(
                                                            Icons.more_horiz),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          primary: kWhite,
                                                          side: BorderSide(
                                                              width: 0,
                                                              color: Colors
                                                                  .black12),
                                                          shape: CircleBorder(),
                                                        ),
                                                        onPressed: () {},
                                                      )
                                                    ],
                                                  ),
                                                  Container(
                                                    width: size.width,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          FlutterIcons
                                                              .skip_previous_mdi,
                                                          color: kWhite,
                                                          size: 45.0,
                                                        ),
                                                        SizedBox(
                                                          width: 30.0,
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            if (isPlaying) {
                                                              _controller
                                                                  .pause();
                                                              setState(() {
                                                                isPlaying =
                                                                    false;
                                                              });
                                                            } else {
                                                              _controller
                                                                  .play();
                                                              setState(() {
                                                                isPlaying =
                                                                    true;
                                                              });
                                                            }
                                                          },
                                                          child: Icon(
                                                            isPlaying
                                                                ? FlutterIcons
                                                                    .pause_faw5s
                                                                : FlutterIcons
                                                                    .play_faw5s,
                                                            color: kWhite,
                                                            size: 50.0,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 30.0,
                                                        ),
                                                        Icon(
                                                          FlutterIcons
                                                              .skip_next_mdi,
                                                          color: kWhite,
                                                          size: 45.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '00:23/1:59',
                                                        style: TextStyle(
                                                          color: kWhite,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      OutlinedButton(
                                                        child: Icon(FlutterIcons
                                                            .fullscreen_mco),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          primary: kWhite,
                                                          side: BorderSide(
                                                              width: 0,
                                                              color: Colors
                                                                  .black12),
                                                          shape: CircleBorder(),
                                                        ),
                                                        onPressed: () {},
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: DefaultTextStyle(
                                    style: TextStyle(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: size.height * 0.44,
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    // width: size.width * 0.25,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5.0,
                                                            horizontal: 10.0),
                                                    decoration: BoxDecoration(
                                                      color: kActiveColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          FlutterIcons
                                                              .fire_alt_faw5s,
                                                          color: Colors.black,
                                                          size: size.height *
                                                              0.025,
                                                        ),
                                                        SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          "Trending",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5.0,
                                                            horizontal: 10.0),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: kActiveColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          FlutterIcons
                                                              .list_faw5s,
                                                          color: kActiveColor,
                                                          size: size.height *
                                                              0.025,
                                                        ),
                                                        SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          "Top",
                                                          style: TextStyle(
                                                              color:
                                                                  kActiveColor),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              OutlinedButton(
                                                child: Icon(Icons.more_horiz),
                                                style: OutlinedButton.styleFrom(
                                                  primary: kPrimaryLightColor,
                                                  // side: BorderSide(
                                                  //     width: 1, color: Colors.white),
                                                  shape: CircleBorder(),
                                                ),
                                                onPressed: () {},
                                              )
                                            ]),
                                        Container(
                                          height: 325,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      numCurveRadius + 2)),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                numCurveRadius),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  SizedBox(height: 7),
                                                  for (var location
                                                      in locations)
                                                    // ClipRRect(
                                                    //   borderRadius:
                                                    //       BorderRadius.circular(8.0),
                                                    //   child: Stack(
                                                    //     alignment:
                                                    //         AlignmentDirectional.center,
                                                    //     children: [
                                                    //       ColorFiltered(
                                                    //         colorFilter: ColorFilter.mode(
                                                    //           Colors.black45,
                                                    //           BlendMode.darken,
                                                    //         ),
                                                    //         child: Image.network(
                                                    //           location.imageUrl,
                                                    //           height: size.height * 0.35,
                                                    //         ),
                                                    //       ),
                                                    //       Column(
                                                    //         children: [
                                                    //           Text(
                                                    //             location.text,
                                                    //             style: TextStyle(
                                                    //               color: Colors.white,
                                                    //               fontSize: 19,
                                                    //               fontWeight:
                                                    //                   FontWeight.w600,
                                                    //             ),
                                                    //           ),
                                                    //           Text(location.timing),
                                                    //           SizedBox(height: 40),
                                                    //           Text(
                                                    //             location.temperature
                                                    //                     .toString() +
                                                    //                 '°',
                                                    //             style: TextStyle(
                                                    //               color: Colors.white,
                                                    //               fontSize: 40,
                                                    //               fontWeight:
                                                    //                   FontWeight.w600,
                                                    //             ),
                                                    //           ),
                                                    //           SizedBox(height: 50),
                                                    //           Text(location.weather),
                                                    //         ],
                                                    //       )
                                                    //     ],
                                                    //   ),
                                                    // ),
                                                    Column(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: GestureDetector(
                                                              onTap: () {
                                                                onVideoTap(1,
                                                                    "assets/videos/ruto.mp4");
                                                              },
                                                              child:
                                                                  // VideoTile(
                                                                  //   thumbnail_url:
                                                                  //       "assets/images/ruto.jpg",
                                                                  //   title:
                                                                  //       "The government's scorecard",
                                                                  //   channel_name: "Visanga Kenya",
                                                                  //   channel_id: 4,
                                                                  //   channel_image_url:
                                                                  //       "assets/images/brian.jpg",
                                                                  //   lapse: "2 days ago",
                                                                  //   view_count: "21K",
                                                                  // ),
                                                                  Container(
                                                                width:
                                                                    size.width *
                                                                        0.98,
                                                                child: Material(
                                                                  elevation:
                                                                      8.0,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade900,
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        size.height /
                                                                            6.3,
                                                                    padding: EdgeInsets.only(
                                                                        left: 5,
                                                                        right:
                                                                            5),
                                                                    // width: size.width,
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        ColorFiltered(
                                                                          colorFilter:
                                                                              ColorFilter.mode(
                                                                            Colors.black26,
                                                                            BlendMode.darken,
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Container(
                                                                                width: size.width * 0.45,
                                                                                height: size.height * 0.147,
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(numCurveRadius),
                                                                                    image: DecorationImage(image: AssetImage("assets/images/ruto.jpg"), fit: BoxFit.fill),
                                                                                  ),
                                                                                  alignment: Alignment.center,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                // width: 180,
                                                                                height: 200,
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(
                                                                              width: size.width * 0.45,
                                                                              height: size.height * 0.147,
                                                                              child: Align(
                                                                                alignment: Alignment.bottomCenter,
                                                                                child: Container(
                                                                                  height: size.width * 0.07,
                                                                                  child: Stack(
                                                                                    children: [
                                                                                      Align(
                                                                                        alignment: Alignment.bottomLeft,
                                                                                        child: ThumbNailIconButton(
                                                                                          icon_data: Icons.watch_later,
                                                                                          press: () {},
                                                                                        ),
                                                                                      ),
                                                                                      Align(
                                                                                        alignment: Alignment.bottomRight,
                                                                                        child: ThumbNailIconButton(
                                                                                          icon_data: Icons.favorite,
                                                                                          press: () {},
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              height: size.height * 0.19,
                                                                              width: size.width / 2.2,
                                                                              padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    "The government's scorecard",
                                                                                    style: TextStyle(color: kWhite, fontSize: 18),
                                                                                    textAlign: TextAlign.left,
                                                                                  ),
                                                                                  // SizedBox(
                                                                                  //   height: size.height * 0.01,
                                                                                  // ),
                                                                                  ImageChip(image_url: "assets/images/brian.jpg", text: "Visanga Kenya"),
                                                                                  Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      VideoInfoChip(
                                                                                        icon_data: Icons.remove_red_eye,
                                                                                        text: "21K",
                                                                                      ),
                                                                                      VideoInfoChip(
                                                                                        icon_data: Icons.access_time,
                                                                                        text: "2 days ago",
                                                                                      ),
                                                                                    ],
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              )),
                                                        ),
                                                        SizedBox(
                                                          height: 10.0,
                                                        )
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                      //  Stack(children: [
                      //   pageBody(size, context),
                      //   Container(
                      //     color: kPrimaryColor.withOpacity(0.979),
                      //     height: size.height / 14,
                      //     child: Container(
                      //       alignment: Alignment.bottomCenter,
                      //       decoration: BoxDecoration(color: kPrimaryLightColor),
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           IconButton(
                      //             onPressed: () {
                      //               setState(() {
                      //                 collapseFromLeft = true;
                      //                 if (isCollapsed)
                      //                   _aController.forward();
                      //                 else
                      //                   _aController.reverse();

                      //                 isCollapsed = !isCollapsed;
                      //               });
                      //             },
                      //             icon: Icon(Icons.menu),
                      //             color: kPrimaryColor,
                      //           ),
                      //           Text(
                      //             txtAppName,
                      //             style: TextStyle(
                      //                 fontWeight: FontWeight.bold,
                      //                 color: kPrimaryColor),
                      //           ),
                      //           IconButton(
                      //             onPressed: () {},
                      //             icon: Icon(Icons.search),
                      //             color: kPrimaryColor,
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      //   )
                      // ]),
                      ),
                ),
              ),
            ),
          ),
        ]));
  }

  Container pageBody(Size size, BuildContext context) {
    return Container(
      color: kPrimaryColor.withOpacity(0.9),
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
        // margin: EdgeInsets.only(top: size.height / 12),
        height: 240,
        width: double.infinity,
        child: VideoPlayer(controller),
      );
    } else {
      return Container(
        height: 240,
        // margin: EdgeInsets.only(top: size.height / 12),
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

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//     return Stack(
//       children: [
//         Positioned(
//           bottom: height / 2.4,
//           child: Image.network(
//             'https://i.ibb.co/Y2CNM8V/new-york.jpg',
//             height: height,
//           ),
//         ),
//         Positioned(
//           bottom: 0,
//           child: Container(
//             height: height / 2.4,
//             width: width,
//             color: Color(0xFF2D2C35),
//           ),
//         ),
//         Foreground()
//       ],
//     );
//   }
// }

class Location {
  final String text;
  final String timing;
  final int temperature;
  final String weather;
  final String imageUrl;

  Location({
    required this.text,
    required this.timing,
    required this.temperature,
    required this.weather,
    required this.imageUrl,
  });
}

final locations = [
  Location(
    text: 'New York',
    timing: '10:44 am',
    temperature: 15,
    weather: 'Cloudy',
    imageUrl: 'https://i.ibb.co/df35Y8Q/2.png',
  ),
  Location(
    text: 'San Francisco',
    timing: '7:44 am',
    temperature: 6,
    weather: 'Raining',
    imageUrl: 'https://i.ibb.co/7WyTr6q/3.png',
  ),
  Location(
    text: 'San Francisco',
    timing: '7:44 am',
    temperature: 6,
    weather: 'Raining',
    imageUrl: 'https://i.ibb.co/7WyTr6q/3.png',
  ),
  Location(
    text: 'San Francisco',
    timing: '7:44 am',
    temperature: 6,
    weather: 'Raining',
    imageUrl: 'https://i.ibb.co/7WyTr6q/3.png',
  ),
  Location(
    text: 'San Francisco',
    timing: '7:44 am',
    temperature: 6,
    weather: 'Raining',
    imageUrl: 'https://i.ibb.co/7WyTr6q/3.png',
  ),
];

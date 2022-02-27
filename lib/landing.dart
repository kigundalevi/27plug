import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/models/user.dart';
import 'package:africanplug/models/video.dart';
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
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:video_player/video_player.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool playArea = false;
  bool isPlaying = false;
  bool disposed = false;

  bool isCollapsed = true;
  bool collapseFromLeft = true;
  bool videoSelected = false;

  bool trendingPage = true;
  bool topPage = false;
  bool latestPage = false;

  final Duration duration = const Duration(milliseconds: 300);
  late AnimationController _aController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _menuScaleAnimation;
  late Animation<Offset> _slideAnimation;

  var latest_videos = [];

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
    updateVideos();
  }

  void updateVideos() async {
    latest_videos = await fetchLatestVideos();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final key = GlobalKey();
    String? current_page = ModalRoute.of(context)?.settings.name;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: kBackgroundColor,
        // floatingActionButton:
        //     current_page != "/upload" ? MainUploadButton() : SizedBox(),
        body: Stack(children: [
          MainMenu(context, current_page, _slideAnimation, _menuScaleAnimation,
              size),
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
                borderRadius: !isCollapsed
                    ? BorderRadius.all(Radius.circular(20))
                    : BorderRadius.all(Radius.circular(0)),
                elevation: 8.0,
                color: kScaffoldColor,
                child: Padding(
                  padding: isCollapsed
                      ? const EdgeInsets.only(top: 0.0, bottom: 0.0)
                      : const EdgeInsets.only(top: 15.0, bottom: 15.0),
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
                                    }, () {
                                      Navigator.pushNamed(context, "/landing");
                                    }, () {
                                      Navigator.pushNamed(
                                          context, "/loginRegister");
                                    }),
                                    videoSelected
                                        ? Container(
                                            height: 290,
                                            // color: Colors.red,
                                            child: Column(
                                              children: [
                                                playView(context),
                                                controlView(context)
                                              ],
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                                !isPlaying
                                    ? Column(
                                        children: [
                                          SizedBox(height: size.height / 14),
                                          Container(
                                            width: size.width,
                                            height: videoSelected ? 240 : 0,
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
                                                            fontWeight:
                                                                FontWeight.w700,
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
                                DefaultTextStyle(
                                  style: TextStyle(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      videoSelected
                                          ? SizedBox(
                                              height: size.height * 0.42,
                                            )
                                          : SizedBox(
                                              height: size.height / 15.5,
                                            ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Container(
                                            height: videoSelected
                                                ? size.height / 2.23
                                                : size.height -
                                                    (size.height / 5.5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        numCurveRadius + 2)),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      numCurveRadius),
                                              child: FutureBuilder(
                                                  future: fetchLatestVideos(),
                                                  builder: (context,
                                                      AsyncSnapshot snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return Center(
                                                          child:
                                                              CircularProgressIndicator());
                                                    } else {
                                                      print(snapshot);
                                                      return Container(
                                                        height: 300,
                                                        child:
                                                            SingleChildScrollView(
                                                          child:
                                                              Column(children: [
                                                            videoSelected
                                                                ? SizedBox(
                                                                    height: 7)
                                                                : SizedBox(),
                                                            Container(
                                                              height:
                                                                  size.height -
                                                                      100,
                                                              child: ListView
                                                                  .builder(
                                                                      itemCount: snapshot
                                                                          .data
                                                                          .length,
                                                                      scrollDirection:
                                                                          Axis
                                                                              .vertical,
                                                                      itemBuilder:
                                                                          (BuildContext context,
                                                                              int index) {
                                                                        return Column(
                                                                          children: [
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              child: GestureDetector(
                                                                                  onTap: () {
                                                                                    videoSelected = true;
                                                                                    onVideoTap(1, snapshot.data[index].url);
                                                                                  },
                                                                                  child: Container(
                                                                                    width: !isCollapsed ? size.width * 1 : size.width * 0.98,
                                                                                    child: Material(
                                                                                      elevation: 8.0,
                                                                                      color: Colors.grey.shade900,
                                                                                      child: Container(
                                                                                        height: size.height / 6.3,
                                                                                        padding: EdgeInsets.only(left: 5, right: 5),
                                                                                        // width: size.width,
                                                                                        child: Stack(
                                                                                          children: [
                                                                                            ColorFiltered(
                                                                                              colorFilter: ColorFilter.mode(
                                                                                                Colors.black26,
                                                                                                BlendMode.darken,
                                                                                              ),
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: size.width * 0.45,
                                                                                                    height: size.height * 0.147,
                                                                                                    child: Container(
                                                                                                      decoration: BoxDecoration(
                                                                                                        borderRadius: BorderRadius.circular(numCurveRadius),
                                                                                                        image: DecorationImage(image: NetworkImage(snapshot.data[index].thumbnail_url == null ? "https://redmoonrecord.co.uk/tech/wp-content/uploads/2019/11/YouTube-thumbnail-size-guide-best-practices-top-examples.png" : snapshot.data[index].thumbnail_url), fit: BoxFit.fill),
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
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                                                  // height: size.height * 0.19,
                                                                                                  width: !isCollapsed ? size.width / 4 : size.width / 2.2,
                                                                                                  color: Colors.black26,
                                                                                                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                                                                                                  child: Column(
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        snapshot.data[index].title,
                                                                                                        style: TextStyle(color: kWhite, fontSize: 18, fontWeight: FontWeight.w300),
                                                                                                        textAlign: TextAlign.left,
                                                                                                      ),
                                                                                                      // SizedBox(
                                                                                                      //   height: size.height * 0.01,
                                                                                                      // ),
                                                                                                      ImageChip(image_url: "assets/images/brian.jpg", text: snapshot.data[index].uploaded_by),
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
                                                                              height: 5,
                                                                            )
                                                                          ],
                                                                        );
                                                                      }),
                                                            )
                                                          ]),
                                                        ),
                                                      );
                                                    }
                                                  }),
                                            )),
                                      ),
                                      Container(
                                        height: !isCollapsed
                                            ? size.height / 17
                                            : size.height / 13,
                                        width: size.width,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        videoSelected = false;
                                                        _controller.pause();
                                                        topPage = false;
                                                        latestPage = false;
                                                        trendingPage = true;
                                                      });
                                                    },
                                                    child: Container(
                                                      // width: size.width * 0.25,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.0,
                                                              horizontal: 10.0),
                                                      decoration: BoxDecoration(
                                                        color: trendingPage
                                                            ? kActiveColor
                                                            : kPrimaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            FlutterIcons
                                                                .fire_alt_faw5s,
                                                            color: trendingPage
                                                                ? kBlack
                                                                : kActiveColor,
                                                            size: size.height *
                                                                0.025,
                                                          ),
                                                          SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            "Trending",
                                                            style: TextStyle(
                                                                color: trendingPage
                                                                    ? kBlack
                                                                    : kActiveColor),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        videoSelected = false;
                                                        _controller.pause();
                                                        latestPage = false;
                                                        trendingPage = false;
                                                        topPage = true;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.0,
                                                              horizontal: 10.0),
                                                      decoration: BoxDecoration(
                                                        color: topPage
                                                            ? kActiveColor
                                                            : kPrimaryColor,
                                                        border: Border.all(
                                                            color: topPage
                                                                ? kBlack
                                                                : kActiveColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            FlutterIcons
                                                                .timeline_mco,
                                                            color: topPage
                                                                ? kBlack
                                                                : kActiveColor,
                                                            size: size.height *
                                                                0.025,
                                                          ),
                                                          SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            "Top",
                                                            style: TextStyle(
                                                                color: topPage
                                                                    ? kBlack
                                                                    : kActiveColor),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        videoSelected = false;
                                                        _controller.pause();
                                                        trendingPage = false;
                                                        topPage = false;
                                                        latestPage = true;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.0,
                                                              horizontal: 10.0),
                                                      decoration: BoxDecoration(
                                                        color: latestPage
                                                            ? kActiveColor
                                                            : kPrimaryColor,
                                                        border: Border.all(
                                                            color: latestPage
                                                                ? kBlack
                                                                : kActiveColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            FlutterIcons
                                                                .time_slot_ent,
                                                            color: latestPage
                                                                ? kBlack
                                                                : kActiveColor,
                                                            size: size.height *
                                                                0.025,
                                                          ),
                                                          SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            "Latest",
                                                            style: TextStyle(
                                                                color: latestPage
                                                                    ? kBlack
                                                                    : kActiveColor),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          "/loginRegister");
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.0,
                                                              horizontal: 10.0),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            kPrimaryLightColor,
                                                        // border: Border.all(
                                                        //     color: kActiveColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            FlutterIcons
                                                                .account_edit_mco,
                                                            color:
                                                                kPrimaryColor,
                                                            // size: size.height *
                                                            //     0.025,
                                                          ),
                                                          SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            "SignUp",
                                                            style: TextStyle(
                                                                color:
                                                                    kPrimaryColor),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // OutlinedButton(
                                                  //   child: Icon(Icons.more_horiz),
                                                  //   style: OutlinedButton.styleFrom(
                                                  //     primary: kPrimaryLightColor,
                                                  //     // side: BorderSide(
                                                  //     //     width: 1, color: Colors.white),
                                                  //     shape: CircleBorder(),
                                                  //   ),
                                                  //   onPressed: () {},
                                                  // )
                                                ]),
                                          ],
                                        ),
                                      ),
                                    ],
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

  Future<List<Video>> fetchLatestVideos() async {
    List<Video> _latestVideos = [];

    GraphQLConfiguration graphQLConfig = new GraphQLConfiguration();
    // GraphQLClient _client = GraphQLClient(
    //   cache: GraphQLCache(store: HiveStore()),
    //   link: HttpLink("https://plug27.herokuapp.com/graphq"),
    // );
    // ;
    QueryResult result = await GraphQLClient(
      cache: GraphQLCache(),
      link: HttpLink(REGISTER_URL),
    ).query(QueryOptions(document: gql("""
query{
  listVideo(sortField:"created_at",order:"desc",limit:5){
    id,
    title,
    url,
    description,
    name,
    durationMillisec,
    createdAt,
    thumbnailUrl,
    thumbnailName,
    uploader{
      id,
      dpUrl,
      channelName,
      firstName,
      lastName,
      email,
      emailVerifiedAt,
      userType{
        id,
        name
      }
    },
    views{
      viewer{
        firstName
      }
    },
    comments{
      commenter{
        lastName
      }
    }
  }
}
""")));
    try {
      if (result.hasException) {
        print(result);
        try {
          OperationException? registerexception = result.exception;
          List<GraphQLError>? errors = registerexception?.graphqlErrors;
          String main_error = errors![0].message;
          print(main_error);
          return [];
        } catch (error) {
          return [];
        }
      } else {
        var videos = result.data?['listVideo'];
        videos.forEach((video) {
          _latestVideos.add(Video(
              id: int.parse(video['id']),
              title: video['title'],
              url: video['url'],
              description: video['description'],
              duration_millisec: video['durationMillisec'],
              name: video['name'],
              thumbnail_url: video['thumbnailUrl'],
              thumbnail_name: video['thumbnailName'],
              views: "2",
              upload_lapse: " hours ago",
              uploaded_by: video['uploader']['email']));
        });
        return _latestVideos;
        // return _allTags
        //     .where(
        //         (tag) => tag.name.toLowerCase().contains(query.toLowerCase()))
        //     .toList();
      }
    } catch (e) {
      print(e);
      return [];
    }
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
    final controller = VideoPlayerController.network(url);
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

import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/controller/user_controller.dart';
import 'package:africanplug/models/location.dart';
import 'package:africanplug/models/user.dart';
import 'package:africanplug/models/video.dart';
import 'package:africanplug/player/upload_player.dart';
import 'package:africanplug/screens/login/login.dart';
import 'package:africanplug/screens/videos/tv.dart';
import 'package:africanplug/widgets/app/appbar.dart';
import 'package:africanplug/widgets/button/main_upload_button.dart';
import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
import 'package:africanplug/widgets/chip/image_chip.dart';
import 'package:africanplug/widgets/loader/custom_loader.dart';
import 'package:africanplug/widgets/menu/main_menu.dart';
import 'package:africanplug/widgets/video/thumbnail_display.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:africanplug/widgets/video/video_list_tile.dart';
import 'package:africanplug/widgets/video/video_tile_old.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
  late VoidCallback listener;
  int currentDurationInSecond = 0;

  FadeAnimation imageFadeAnim =
      FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
  Widget controlIcon = SizedBox();
  Widget overLay = SizedBox();

  bool _paused = false;
  bool _overlayed = false;

  late String videoTitle;
  _VideoPlayPauseState() {
    listener = () {
      setState(() {});
    };
  }

  late VideoProgressIndicator progressIndicator;

  late List<Video>? latestVideos;
  late List<Video>? trendingVideos;
  late List<Video>? topVideos;

  TextEditingController searchController = new TextEditingController();
  List<Video> _searchResults = [];
  String searchText = "";
  bool _searching = false;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      print("WidgetsBinding");
      UserController ctrl = UserController();
      ctrl.fetchLatestVideos(currentUser().id).then((latest_videos) {
        if (latest_videos == null) {
        } else {
          setState(() {
            latestVideos = latest_videos.take(7).toList();
          });
        }
        ctrl.fetchTopVideos(currentUser().id).then((top_videos) {
          if (top_videos == null) {
          } else {
            setState(() {
              topVideos = top_videos.take(7).toList();
            });
          }
          ctrl.fetchTrendingVideos(currentUser().id).then((trending_videos) {
            if (trending_videos == null) {
            } else {
              setState(() {
                trendingVideos = trending_videos.take(7).toList();
              });
            }
          });
        });
      });
    });

    super.initState();

    _aController = AnimationController(duration: duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.85).animate(_aController);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_aController);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_aController);
    // updateVideos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final key = GlobalKey();
    String? current_page = ModalRoute.of(context)?.settings.name;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
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
                      Scaffold(
                        resizeToAvoidBottomInset: false,
                        backgroundColor: kScaffoldColor,
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
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, "/landing");
                                    }, () {
                                      // Navigator.pop(context);
                                      Navigator.pushNamed(
                                          context, "/loginRegister");
                                    }, () {
                                      setState(() {
                                        _searching = !_searching;
                                      });
                                    }),
                                  ],
                                ),
                                // Container(
                                //                                                         width: size.width,
                                //                                                         child: TextButton(
                                //                                                             style: ButtonStyle(
                                //                                                                 elevation: MaterialStateProperty.all(3.0),
                                //                                                                 backgroundColor: MaterialStateProperty.all(kActiveColor),
                                //                                                                 shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                //                                                                   borderRadius: BorderRadius.circular(numCurveRadius),
                                //                                                                   // side: BorderSide(color: Colors.red)
                                //                                                                 ))),
                                //                                                             onPressed: () {
                                //                                                               // Navigator.pop(context);
                                //                                                               Navigator.pushNamed(context, "/loginRegister");
                                //                                                             },
                                //                                                             child: Text("Register/Login for more", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold))),
                                //                                                       )
                                DefaultTextStyle(
                                  style: TextStyle(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: size.height / 14.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Container(
                                            height: size.height - 140,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        numCurveRadius + 2)),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      numCurveRadius),
                                              child: FutureBuilder(
                                                  future: latestPage
                                                      ? fetchLatestVideos()
                                                      : trendingPage
                                                          ? fetchTrendingVideos()
                                                          : fetchTopVideos(),
                                                  builder: (context,
                                                      AsyncSnapshot snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return customLoader(
                                                          size: size,
                                                          text:
                                                              "Fetching videos..");
                                                      ;
                                                    } else {
                                                      return SingleChildScrollView(
                                                        child: Column(
                                                            children: [
                                                              _searching
                                                                  ? searchTab(
                                                                      context)
                                                                  : SizedBox(),
                                                              Container(
                                                                height: _searching
                                                                    ? size.height -
                                                                        200
                                                                    : size.height -
                                                                        140,
                                                                child: searchText !=
                                                                        ""
                                                                    ? new ListView
                                                                        .builder(
                                                                        itemCount:
                                                                            _searchResults.length,
                                                                        itemBuilder:
                                                                            (context,
                                                                                i) {
                                                                          if (_searchResults.length ==
                                                                              0) {
                                                                            return Container(
                                                                              width: size.width,
                                                                              child: TextButton(
                                                                                  style: ButtonStyle(
                                                                                      elevation: MaterialStateProperty.all(3.0),
                                                                                      backgroundColor: MaterialStateProperty.all(kActiveColor),
                                                                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(numCurveRadius),
                                                                                        // side: BorderSide(color: Colors.red)
                                                                                      ))),
                                                                                  onPressed: () {
                                                                                    // Navigator.pop(context);
                                                                                    Navigator.pushNamed(context, "/loginRegister");
                                                                                  },
                                                                                  child: Text("Register/Login for wider search", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold))),
                                                                            );
                                                                          } else if (i ==
                                                                              _searchResults.length - 1) {
                                                                            return Column(
                                                                              children: [
                                                                                VideoListTile(video: _searchResults[i], playList: _searchResults, playingIndex: i, isCollapsed: isCollapsed, size: size),
                                                                                Container(
                                                                                  width: size.width,
                                                                                  child: TextButton(
                                                                                      style: ButtonStyle(
                                                                                          elevation: MaterialStateProperty.all(3.0),
                                                                                          backgroundColor: MaterialStateProperty.all(kActiveColor),
                                                                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(numCurveRadius),
                                                                                            // side: BorderSide(color: Colors.red)
                                                                                          ))),
                                                                                      onPressed: () {
                                                                                        // Navigator.pop(context);
                                                                                        Navigator.pushNamed(context, "/loginRegister");
                                                                                      },
                                                                                      child: Text("Register/Login for more", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold))),
                                                                                ),
                                                                              ],
                                                                            );
                                                                          } else {
                                                                            return new VideoListTile(
                                                                                video: _searchResults[i],
                                                                                playList: _searchResults,
                                                                                playingIndex: i,
                                                                                isCollapsed: isCollapsed,
                                                                                size: size);
                                                                          }
                                                                        },
                                                                      )
                                                                    : ListView.builder(
                                                                        itemCount: snapshot.data.length,
                                                                        scrollDirection: Axis.vertical,
                                                                        itemBuilder: (BuildContext context, int index) {
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 3.0),
                                                                            child: index == 6
                                                                                ? Column(
                                                                                    children: [
                                                                                      VideoListTile(
                                                                                          video: snapshot.data[index],
                                                                                          playList: latestPage
                                                                                              ? latestVideos!
                                                                                              : trendingPage
                                                                                                  ? trendingVideos!
                                                                                                  : topVideos!,
                                                                                          playingIndex: index,
                                                                                          isCollapsed: isCollapsed,
                                                                                          size: size),
                                                                                      Container(
                                                                                        width: size.width,
                                                                                        child: TextButton(
                                                                                            style: ButtonStyle(
                                                                                                elevation: MaterialStateProperty.all(3.0),
                                                                                                backgroundColor: MaterialStateProperty.all(kActiveColor),
                                                                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.circular(numCurveRadius),
                                                                                                  // side: BorderSide(color: Colors.red)
                                                                                                ))),
                                                                                            onPressed: () {
                                                                                              // Navigator.pop(context);
                                                                                              Navigator.pushNamed(context, "/loginRegister");
                                                                                            },
                                                                                            child: Text("Register/Login for more", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold))),
                                                                                      ),
                                                                                    ],
                                                                                  )
                                                                                : VideoListTile(
                                                                                    video: snapshot.data[index],
                                                                                    playList: latestPage
                                                                                        ? latestVideos!
                                                                                        : trendingPage
                                                                                            ? trendingVideos!
                                                                                            : topVideos!,
                                                                                    playingIndex: index,
                                                                                    isCollapsed: isCollapsed,
                                                                                    size: size),
                                                                          );
                                                                        }),
                                                              ),
                                                              // videoSelected
                                                              //     ? SizedBox(
                                                              //         height:
                                                              //             200)
                                                              //     : SizedBox(),
                                                            ]),
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
                                                      Navigator.pop(context);
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
                  )),
                ),
              ),
            ),
          ),
        ]));
  }

  Container searchTab(BuildContext context) {
    return new Container(
      color: Theme.of(context).primaryColor.withOpacity(0.4),
      child: new ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
        visualDensity: VisualDensity(horizontal: 0, vertical: 0),
        leading: new Icon(Icons.search, color: kActiveColor.withOpacity(0.8)),
        title: new TextField(
          style: TextStyle(color: kActiveColor),
          cursorColor: kActiveColor,
          controller: searchController,
          decoration: new InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: kActiveColor.withOpacity(0.6)),
              border: InputBorder.none),
          onChanged: (value) {
            onSearchTextChanged(value);
            setState(() {
              searchText = value;
            });
            print(searchText);
          },
        ),
        trailing: new IconButton(
          icon: new Icon(Icons.cancel, color: kActiveColor.withOpacity(0.7)),
          onPressed: () {
            searchController.clear();
            onSearchTextChanged('');
            setState(() {
              _searching = false;
              searchText = "";
            });
          },
        ),
      ),
    );
  }

  Future<List<Video>> fetchLatestVideos() async {
    if (latestVideos == null) {
      return [];
    } else {
      return latestVideos!;
    }
  }

  Future<List<Video>> fetchTopVideos() async {
    if (topVideos == null) {
      return [];
    } else {
      return topVideos!;
    }
  }

  Future<List<Video>> fetchTrendingVideos() async {
    if (trendingVideos == null) {
      return [];
    } else {
      return trendingVideos!;
    }
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

  onVideoTap(int index, String url, int id) {
    final controller = VideoPlayerController.network(url);
    final old_controller = _controller;
    _controller = controller;
    old_controller.removeListener(() {
      onControllerUpdate();
    });
    old_controller.pause;
    old_controller.dispose();
    setState(() {});
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // ignore: avoid_single_cascade_in_expression_statements
      controller
        ..initialize().then((_) {
          // controller.addListener(listener);
          controller.addListener(() {
            // setState(() {
            currentDurationInSecond = _controller.value.position.inSeconds;
            // });
            if (_controller.value.position.inSeconds >=
                _controller.value.duration.inSeconds) {
              print("ended");
            }

            onControllerUpdate;
          });
          _controller.play();

          // _controller.addListener(() => setState(() {}));

          progressIndicator = VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.grey.shade400,
              backgroundColor: Colors.grey,
            ),
          );

          addVideoView(id);

          setState(() {
            playArea = true;
            isPlaying = true;
          });
        });
    });
  }

  // Widget playView(BuildContext context) {
  //   Size size = MediaQuery.of(context).size;
  //   final controller = _controller;
  //   if (controller != null && controller.value.isInitialized) {
  //     return Container(
  //       // margin: EdgeInsets.only(top: size.height / 12),
  //       height: 240,
  //       width: double.infinity,
  //       child: Stack(
  //         children: [
  //           GestureDetector(
  //               child: VideoPlayer(controller),
  //               onTap: () {
  //                 if (!controller.value.isInitialized) {
  //                   return;
  //                 }
  //                 if (controller.value.isPlaying) {
  //                   controller.pause();
  //                   _paused = true;
  //                   setState(() {});
  //                   imageFadeAnim = FadeAnimation(
  //                       child: const Icon(Icons.pause, size: 100.0));

  //                   // controller.pause();
  //                   // controlIcon = ;
  //                   overLay = Container(
  //                     height: 240,
  //                     color: Colors.black38,
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(left: 8.0),
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         crossAxisAlignment: CrossAxisAlignment.stretch,
  //                         mainAxisSize: MainAxisSize.max,
  //                         children: [
  //                           Row(
  //                             mainAxisSize: MainAxisSize.max,
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Text(
  //                                 videoTitle.length > 25
  //                                     ? videoTitle.replaceRange(
  //                                         25, videoTitle.length, '...')
  //                                     : videoTitle,
  //                                 style: TextStyle(color: kWhite, fontSize: 15),
  //                               ),
  //                               OutlinedButton(
  //                                 child: Icon(Icons.more_horiz),
  //                                 style: OutlinedButton.styleFrom(
  //                                   primary: kWhite,
  //                                   side: BorderSide(
  //                                       width: 0, color: Colors.black12),
  //                                   shape: CircleBorder(),
  //                                 ),
  //                                 onPressed: () {},
  //                               )
  //                             ],
  //                           ),
  //                           Container(
  //                             child: Row(
  //                               mainAxisSize: MainAxisSize.max,
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Icon(
  //                                   FlutterIcons.skip_previous_mdi,
  //                                   color: kWhite,
  //                                   size: 45.0,
  //                                 ),
  //                                 SizedBox(
  //                                   width: 30.0,
  //                                 ),
  //                                 _paused
  //                                     ? InkWell(
  //                                         child: Icon(FlutterIcons.play_faw5s,
  //                                             color: kWhite, size: 55.0),
  //                                         onTap: () {
  //                                           controlIcon = SizedBox();
  //                                           overLay = SizedBox();

  //                                           controller.play();
  //                                           _paused = false;
  //                                           setState(() {});
  //                                         },
  //                                       )
  //                                     : InkWell(
  //                                         child: Icon(FlutterIcons.pause_faw5s,
  //                                             size: 80.0),
  //                                         onTap: () {
  //                                           controlIcon = SizedBox();
  //                                           overLay = SizedBox();
  //                                           controller.pause();
  //                                           _paused = true;
  //                                           setState(() {});
  //                                         },
  //                                       ),
  //                                 SizedBox(
  //                                   width: 30.0,
  //                                 ),
  //                                 Icon(
  //                                   FlutterIcons.skip_next_mdi,
  //                                   color: kWhite,
  //                                   size: 45.0,
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           Row(
  //                             // crossAxisAlignment: CrossAxisAlignment.end,
  //                             mainAxisSize: MainAxisSize.max,
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Text(
  //                                 formattedTime(currentDurationInSecond) +
  //                                     ' / ' +
  //                                     formattedTime(
  //                                         controller.value.duration.inSeconds),
  //                                 style: TextStyle(
  //                                   color: kWhite, fontSize: 15,
  //                                   // color: kWhite,
  //                                   // fontSize: 15,
  //                                   // fontWeight: FontWeight.w700,
  //                                 ),
  //                               ),
  //                               OutlinedButton(
  //                                 child: Icon(FlutterIcons.fullscreen_mco),
  //                                 style: OutlinedButton.styleFrom(
  //                                   primary: kWhite,
  //                                   side: BorderSide(
  //                                       width: 0, color: Colors.black12),
  //                                   shape: CircleBorder(),
  //                                 ),
  //                                 onPressed: () {},
  //                               )
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   );
  //                 } else {
  //                   _paused = false;
  //                   overLay = SizedBox();

  //                   controller.play();
  //                   imageFadeAnim = FadeAnimation(
  //                       child:
  //                           const Icon(FlutterIcons.play_faw5s, size: 100.0));
  //                   setState(() {});
  //                 }
  //               }),
  //           Align(
  //             alignment: Alignment.bottomCenter,
  //             child: progressIndicator,
  //           ),
  //           Center(child: imageFadeAnim),
  //           Center(
  //               child: Material(
  //                   elevation: 8.0,
  //                   color: Colors.white38,
  //                   borderRadius: BorderRadius.circular(10.0),
  //                   child: controlIcon)),
  //           Center(
  //               child: controller.value.isBuffering
  //                   ? const CircularProgressIndicator(color: kPrimaryColor)
  //                   : null),
  //           overLay
  //         ],
  //       ),
  //     );
  //   } else {
  //     return Container(
  //       height: 240,
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

  onSearchTextChanged(String text) async {
    _searchResults.clear();

    List<Video> videos_list = latestPage
        ? latestVideos!
        : trendingPage
            ? trendingVideos!
            : topVideos!;
    if (text.isEmpty) {
      //setState(() {});
      return videos_list;
    }

    String _searchText = text.toLowerCase();

    videos_list.forEach((video) {
      if (video.title.toLowerCase().contains(_searchText) ||
          video.name.toLowerCase().contains((_searchText)) ||
          video.description.toLowerCase().contains((_searchText)))
        _searchResults.add(video);
    });

    //setState(() {});
  }
}

void addVideoView(int video_id) async {
  User current_user = currentUser();
  int user_id = current_user.id;
  Loc loc = await currentLocation();
  String lat = loc.lat;
  String lng = loc.lng;
  String ip = loc.ip;
  String locationName = loc.name;
  bool locationLive = loc.live;

//   String query = """
// mutation{
//   addVideoView(videoId:$video_id,userId:$user_id,lat:"$lat",lng:"$lng",ip:"$ip",locationName:"$locationName",locationLive:$locationLive){
//     ok
//   }
// }
// """;

  String query = """
mutation{
  addVideoView(videoId:$video_id,userId:$user_id,ip:"$ip",lat:"$lat",lng:"$lng",locationName:"$locationName",locationLive:$locationLive){
    ok
  }
}
""";

  // print(query);

  GraphQLConfiguration graphQLConfig = new GraphQLConfiguration();
  // GraphQLClient _client = graphQLConfig.clientToQuery();
  QueryResult result = await GraphQLClient(
    cache: GraphQLCache(),
    link: HttpLink("https://plug27.herokuapp.com/graphq"),
  ).mutate(MutationOptions(document: gql(query)));
  // print("VIEW RESULT");
  // print(result);
}

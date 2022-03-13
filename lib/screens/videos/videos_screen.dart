import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/controller/custom_full_player_with_controls.dart';
import 'package:africanplug/controller/custom_player_with_controls.dart';
import 'package:africanplug/controller/data_manager.dart';
import 'package:africanplug/controller/user_controller.dart';
import 'package:africanplug/controller/video_controls.dart';
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
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({Key? key}) : super(key: key);

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late VideoPlayerController main_controller;
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
  late List<Video>? latestVideos;
  late List<Video>? trendingVideos;
  late List<Video>? topVideos;
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
  late FlickManager flickManager;
  late List<String> videoUrls;
  double _playHeight = 250;
  late double _controllerHeight;
  late double _controllerWidth;
  late double _controllerAspectRatio;

  TextEditingController searchController = new TextEditingController();
  List<Video> _searchResults = [];
  String searchText = "";
  bool _searching = false;
  @override
  void initState() {
    UserController ctrl = UserController();
    ctrl.fetchLatestVideos(currentUser().id).then((latest_videos) {
      if (latest_videos == null) {
      } else {
        setState(() {
          latestVideos = latest_videos;
        });
      }
    });
    ctrl.fetchTopVideos(currentUser().id).then((top_videos) {
      if (top_videos == null) {
      } else {
        setState(() {
          topVideos = top_videos;
        });
      }
    });
    ctrl.fetchTrendingVideos(currentUser().id).then((trending_videos) {
      if (trending_videos == null) {
      } else {
        setState(() {
          trendingVideos = trending_videos;
        });
      }
    });
    _aController = AnimationController(duration: duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.85).animate(_aController);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_aController);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_aController);
    // updateVideos();
    super.initState();
  }

  @override
  void dispose() {
    flickManager.dispose();
    _controller.setVolume(0);
    _controller.pause();
    _controller.dispose();
    disposed = true;
    _aController.dispose();
    super.dispose();
  }

  skipToVideo(String url) {
    setState(() {
      main_controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          // _controller.play();
        });
      main_controller.addListener(checkVideo);
    });
    flickManager.handleChangeVideo(main_controller);
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
        floatingActionButton: current_page == "/upload" || isCollapsed
            ? MainUploadButton()
            : SizedBox(),
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
                                      Navigator.pushNamed(context, "/home");
                                    }, () {
                                      // Navigator.pop(context);
                                      Navigator.pushNamed(context, "/profile",
                                          arguments: [
                                            currentUser().id,
                                            'profile'
                                          ]);
                                    }, () {
                                      setState(() {
                                        _searching = !_searching;
                                      });
                                    }),
                                  ],
                                ),
                                DefaultTextStyle(
                                  style: TextStyle(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: size.height / 15.5,
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
                                                                          return new VideoListTile(
                                                                              video: _searchResults[i],
                                                                              playList: _searchResults,
                                                                              playingIndex: i,
                                                                              isCollapsed: isCollapsed,
                                                                              size: size);
                                                                        },
                                                                      )
                                                                    : ListView.builder(
                                                                        itemCount: snapshot.data.length,
                                                                        scrollDirection: Axis.vertical,
                                                                        itemBuilder: (BuildContext context, int index) {
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 3.0),
                                                                            child: VideoListTile(
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
                                                  SizedBox(
                                                      width: size.width / 4)
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

  void _logOutUser(context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      GraphQLConfiguration.removeToken();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
          ModalRoute.withName('/'));
    });
  }

  void checkVideo() {
    // print('______________________________________________');
    // print('CHECKING ' +
    //     main_controller.value.position.toString() +
    //     '/' +
    //     main_controller.value.duration.toString());
    // print('______________________________________________');
    if (main_controller.value.position ==
        Duration(seconds: 0, minutes: 0, hours: 0)) {
      Size size = MediaQuery.of(context).size;
      Size video_size = main_controller.value.size;
      double aspect_ratio = video_size.aspectRatio;
      setState(() {
        // _playHeight = size.width / aspect_ratio;
        // _controllerHeight = video_size.height;
        // _controllerWidth = video_size.width;
        // _controllerAspectRatio = video_size.aspectRatio;
        // if (_playHeight > (size.height / 2)) {
        //   flickManager.flickControlManager!.toggleFullscreen();
        // }
      });
      // print('______________________________________________');
      // print('video Started');
      // print('______________________________________________');
    }

    if (main_controller.value.position == main_controller.value.duration ||
        main_controller.value.position > main_controller.value.duration) {
      // print('______________________________________________');
      // print('video Ended');
      // print('______________________________________________');
    }
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

    videos_list.forEach((video) {
      if (video.title.contains(text) || video.name.contains(text))
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

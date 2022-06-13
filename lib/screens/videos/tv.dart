import 'dart:async';

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
import 'package:africanplug/widgets/app/appbar.dart';
import 'package:africanplug/widgets/button/main_upload_button.dart';
import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
import 'package:africanplug/widgets/chip/image_chip.dart';
import 'package:africanplug/widgets/loader/custom_loader.dart';
import 'package:africanplug/widgets/menu/main_menu.dart';
import 'package:africanplug/widgets/video/thumbnail_display.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:africanplug/widgets/video/video_tile_old.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TvScreen extends StatefulWidget {
  const TvScreen({Key? key, required this.videos, required this.activeIndex})
      : super(key: key);
  final List<Video> videos;
  final int activeIndex;

  @override
  State<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends State<TvScreen> with TickerProviderStateMixin {
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
  Animation<Offset>? _slideAnimation;
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

  late int currentPlaying = widget.activeIndex;
  late VideoProgressIndicator progressIndicator;
  late FlickManager flickManager;
  late CustomDataManager dataManager;
  double _playHeight = 250;
  late double _controllerHeight;
  late double _controllerWidth;
  late double _controllerAspectRatio;
  String? _newLikes;
  String? _newComment;
  String? _newComments;
  String? _newCommentCount;
  late bool _commenting;
  late bool _liked;
  bool _favourite = false;
  bool _later = false;

  List _deletedComments = [];

  late Future _videoComments;
  late bool _subscribed;
  fetchVideoComments() async {
    UserController ctrl = UserController();
    return await ctrl.fetchVideoComments(widget.videos[currentPlaying].id);
  }

  refreshComments() {
    setState(() {
      _videoComments = fetchVideoComments();
    });
  }

  @override
  void initState() {
    //   _liked
    UserController ctrl = UserController();
    ctrl.fetchVideoComments(widget.videos[currentPlaying].id).then((comments) {
      print("-----------COMMENTS----------");
      print(comments!.length);
      if (comments == null) {
        setState(() {
          _newCommentCount = '0';
        });
      } else {
        setState(() {
          _newCommentCount = comments.length.toString();
        });
      }
    });
    //  _personList.forEach((p) {
    // refreshComments();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _commenting = false;
      currentPlaying = widget.activeIndex;
      main_controller =
          VideoPlayerController.network(widget.videos[currentPlaying].url)
            ..initialize();

      print("------SUBSCRIBED CHANNELS-------");
      print(currentUser().subscribed_channels);
      // main_controller.addListener(checkVideo);
      flickManager = FlickManager(
          videoPlayerController: main_controller,
          onVideoEnd: () {
            // skipToNextVideo([Duration? duration]) {
            // if (currentPlaying != widget.videos.length - 1) {
            //   main_controller = VideoPlayerController.network(
            //       widget.videos[currentPlaying + 1].url)
            //     ..initialize().then((_) {
            //       setState(() {});

            //       // _controller.play();
            //     });
            //   main_controller.addListener(checkVideo);
            // flickManager.handleChangeVideo(main_controller,
            //     videoChangeDuration: Duration(seconds: 4));
            // flickManager.handleChangeVideo(main_controller,
            //   videoChangeDuration: duration);

            // currentPlaying++;

            currentPlaying++;
            dataManager.skipToNextVideo(Duration(seconds: 3));
            Timer(Duration(seconds: 3), () {
              setState(() {});
            });

            // }
            // }
          });

      dataManager = CustomDataManager(
          context: context,
          flickManager: flickManager,
          videos: widget.videos,
          currentPlaying: widget.activeIndex);
      print('Title');
      print(dataManager.videos[dataManager.currentPlaying].title);
      dataManager.play();
      _liked = false;
      setState(() {});
      if (currentUser().liked_videos == null) {
        print("NO LIKED VIDEOS");
        _liked = false;
        setState(() {});
      } else {
        print(currentUser().liked_videos);
        currentUser().liked_videos.forEach((i) {
          print("LIKED - " + i.toString());
          if (i == dataManager.videos[dataManager.currentPlaying].id) {
            _liked = true;
            setState(() {});
          }
        });
      }

      _aController = AnimationController(duration: duration, vsync: this);
      _scaleAnimation =
          Tween<double>(begin: 1, end: 0.85).animate(_aController);
      _menuScaleAnimation =
          Tween<double>(begin: 0.5, end: 1).animate(_aController);
      _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
          .animate(_aController);
      // updateVideos();
      setState(() {
        _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
            .animate(_aController);
        _subscribed = false;
        _videoComments = fetchVideoComments();
      });
    });
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
    User user = currentUser();

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
                      Scaffold(
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
                                    },
                                        user.id == 1
                                            ? () {
                                                // Navigator.pop(context);
                                                Navigator.pushNamed(
                                                    context, "/loginRegister");
                                              }
                                            : () {
                                                // Navigator.pop(context);
                                                Navigator.pushNamed(
                                                    context, "/profile",
                                                    arguments: [
                                                      currentUser().id,
                                                      'profile'
                                                    ]);
                                              })
                                  ],
                                ),
                                DefaultTextStyle(
                                  style: TextStyle(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: size.height / 13.5,
                                      ),
                                      Container(
                                          height: size.height - 100,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      numCurveRadius + 2)),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                numCurveRadius),
                                            child: FutureBuilder(
                                                future: fetchVideos(),
                                                builder: (context,
                                                    AsyncSnapshot snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return customLoader(
                                                        size: size,
                                                        text:
                                                            "Loading videos..");
                                                  } else {
                                                    return VisibilityDetector(
                                                      key: ObjectKey(
                                                          flickManager),
                                                      onVisibilityChanged:
                                                          (visibility) {
                                                        if (visibility
                                                                    .visibleFraction ==
                                                                0 &&
                                                            this.mounted) {
                                                          flickManager
                                                              .flickControlManager
                                                              ?.autoPause();
                                                        } else if (visibility
                                                                .visibleFraction ==
                                                            1) {
                                                          flickManager
                                                              .flickControlManager
                                                              ?.autoResume();
                                                        }
                                                      },
                                                      child: Column(children: [
                                                        // _playHeight >
                                                        //         250
                                                        //     ? Container(
                                                        //         height:
                                                        //             250,
                                                        //         width: size.width /
                                                        //             3.5,
                                                        //         color: Colors
                                                        //             .red,
                                                        //         child:
                                                        //             FittedBox(
                                                        //           fit: BoxFit
                                                        //               .cover,
                                                        //           child:
                                                        //               SizedBox(
                                                        //             height:
                                                        //                 250,
                                                        //             child:
                                                        //                 FlickVideoPlayer(
                                                        //               flickManager: flickManager,
                                                        //               preferredDeviceOrientationFullscreen: [
                                                        //                 DeviceOrientation.portraitUp,
                                                        //                 DeviceOrientation.landscapeLeft,
                                                        //                 DeviceOrientation.landscapeRight,
                                                        //               ],
                                                        //               flickVideoWithControls: CustomFlickVideoWithControls(
                                                        //                 controls: CustomOrientationControls(dataManager: dataManager),
                                                        //               ),
                                                        //               flickVideoWithControlsFullscreen: CustomFlickVideoWithControls(
                                                        //                 videoFit: BoxFit.fitWidth,
                                                        //                 controls: CustomOrientationControls(dataManager: dataManager),
                                                        //               ),
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       )
                                                        //     :
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey.shade900,
                                                            // borderRadius:
                                                            //     BorderRadius
                                                            //         .circular(
                                                            //             numCurveRadius)
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                height:
                                                                    _playHeight,
                                                                child:
                                                                    FlickVideoPlayer(
                                                                  flickManager:
                                                                      flickManager,
                                                                  preferredDeviceOrientationFullscreen: [
                                                                    DeviceOrientation
                                                                        .portraitUp,
                                                                    DeviceOrientation
                                                                        .landscapeLeft,
                                                                    DeviceOrientation
                                                                        .landscapeRight,
                                                                  ],
                                                                  flickVideoWithControls:
                                                                      CustomFlickVideoWithControls(
                                                                    controls: CustomOrientationControls(
                                                                        dataManager:
                                                                            dataManager),
                                                                  ),
                                                                  flickVideoWithControlsFullscreen:
                                                                      CustomFullFlickVideoWithControls(
                                                                    videoFit: BoxFit
                                                                        .fitWidth,
                                                                    controls: CustomOrientationControls(
                                                                        dataManager:
                                                                            dataManager),
                                                                  ),
                                                                ),
                                                              ),
                                                              // Text(
                                                              //   dataManager
                                                              //       .videos[dataManager
                                                              //           .currentPlaying]
                                                              //       .title,
                                                              //   style: TextStyle(
                                                              //       color:
                                                              //           kWhite),
                                                              // ),
                                                              // Row(
                                                              //   mainAxisAlignment:
                                                              //       MainAxisAlignment
                                                              //           .spaceBetween,
                                                              //   children: [
                                                              //     Icon(
                                                              //         FlutterIcons
                                                              //             .like1_ant,
                                                              //         color:
                                                              //             kActiveColor),
                                                              //     Icon(FlutterIcons
                                                              //         .ellipsis_h_faw)
                                                              //   ],
                                                              // ),
                                                            ],
                                                          ),
                                                        ),

                                                        SizedBox(
                                                          height: (size.height -
                                                                  _playHeight) -
                                                              100,
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  height:
                                                                      size.height -
                                                                          300,

                                                                  color: kWhite,
                                                                  // videoSelected
                                                                  //     ? size.height -
                                                                  //         450
                                                                  //     : size.height -
                                                                  //         120,
                                                                  child: ListView
                                                                      .builder(
                                                                          itemCount: snapshot
                                                                              .data
                                                                              .length,
                                                                          scrollDirection: Axis
                                                                              .vertical,
                                                                          itemBuilder:
                                                                              (BuildContext context, int index) {
                                                                            return Container(
                                                                              child: index == 0
                                                                                  ? Column(
                                                                                      children: [
                                                                                        Container(
                                                                                          width: size.width,
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Column(
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: size.width,
                                                                                                  child: Text(dataManager.videos[dataManager.currentPlaying].title, style: TextStyle(color: kBlack, fontWeight: FontWeight.w600)),
                                                                                                ),
                                                                                                Container(width: size.width, child: Text(dataManager.videos[dataManager.currentPlaying].views + " . " + dataManager.videos[dataManager.currentPlaying].upload_lapse, style: TextStyle(color: kBlack, fontWeight: FontWeight.w400))),
                                                                                                Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                  children: [
                                                                                                    (dataManager.videos[dataManager.currentPlaying].liked || _liked == true || findIfLiked(dataManager.videos[dataManager.currentPlaying].id))
                                                                                                        ? Row(
                                                                                                            children: [
                                                                                                              IconButton(onPressed: () {}, icon: Icon(Icons.thumb_up, color: kActiveColor)),
                                                                                                              Text(_newLikes == null ? dataManager.videos[dataManager.currentPlaying].like_count : _newLikes!, style: TextStyle(color: kBlack, fontWeight: FontWeight.w400))
                                                                                                            ],
                                                                                                          )
                                                                                                        : InkWell(
                                                                                                            child: Icon(Icons.thumb_up),
                                                                                                            onTap: () {
                                                                                                              UserController ctrl = UserController();
                                                                                                              ctrl.addVideoLike(dataManager.videos[dataManager.currentPlaying].id);

                                                                                                              setState(() {
                                                                                                                _liked = true;
                                                                                                                _newLikes = (int.parse(dataManager.videos[dataManager.currentPlaying].like_count) + 1).toString();
                                                                                                              });
                                                                                                            }),
                                                                                                    // Icon(FlutterIcons.ellipsis_h_faw),
                                                                                                    (dataManager.videos[dataManager.currentPlaying].watch_later || _later == true || currentUser().later_videos.contains(dataManager.videos[dataManager.currentPlaying].id))
                                                                                                        ? Icon(Icons.watch_later, color: kActiveColor)
                                                                                                        : IconButton(
                                                                                                            onPressed: () {
                                                                                                              UserController ctrl = UserController();
                                                                                                              ctrl.addVideoLater(dataManager.videos[dataManager.currentPlaying].id);
                                                                                                              setState(() {
                                                                                                                _later = true;
                                                                                                                print('Later');
                                                                                                              });
                                                                                                            },
                                                                                                            icon: Icon(Icons.watch_later)),
                                                                                                    (dataManager.videos[dataManager.currentPlaying].favourite || _favourite == true || currentUser().favourited_videos.contains(dataManager.videos[dataManager.currentPlaying].id))
                                                                                                        ? IconButton(onPressed: () {}, icon: Icon(Icons.favorite, color: kActiveColor))
                                                                                                        : IconButton(
                                                                                                            onPressed: () {
                                                                                                              UserController ctrl = UserController();
                                                                                                              ctrl.addVideoFavourite(dataManager.videos[dataManager.currentPlaying].id);
                                                                                                              setState(() {
                                                                                                                _favourite = true;
                                                                                                                print("Faved");
                                                                                                              });
                                                                                                            },
                                                                                                            icon: Icon(Icons.favorite)),

                                                                                                    // Align(
                                                                                                    //   alignment: Alignment.bottomLeft,
                                                                                                    //   child: ThumbNailIconButton(
                                                                                                    //     icon_data: Icons.watch_later,
                                                                                                    //     press: () {},
                                                                                                    //   ),
                                                                                                    // ),
                                                                                                    // Align(
                                                                                                    //   alignment: Alignment.bottomRight,
                                                                                                    //   child: ThumbNailIconButton(
                                                                                                    //     icon_data: Icons.favorite,
                                                                                                    //     press: () {},
                                                                                                    //   ),
                                                                                                    // )
                                                                                                    // InkWell(
                                                                                                    //   child: Container(
                                                                                                    //     decoration: BoxDecoration(
                                                                                                    //       border: Border.all(color: Colors.white60),
                                                                                                    //       borderRadius: BorderRadius.circular(5.0),
                                                                                                    //     ),
                                                                                                    //     child: Padding(
                                                                                                    //       padding: const EdgeInsets.all(8.0),
                                                                                                    //       child: Text(
                                                                                                    //         "SUBSCRIBE",
                                                                                                    //         style: TextStyle(color: Colors.white60, fontSize: 17),
                                                                                                    //       ),
                                                                                                    //     ),
                                                                                                    //   ),
                                                                                                    //   onTap: () {
                                                                                                    //     Navigator.pushNamed(context, "/upload");
                                                                                                    //   },
                                                                                                    // ),
                                                                                                  ],
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Divider(height: 2.0),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.all(8.0),
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Row(
                                                                                                children: [
                                                                                                  CircleAvatar(radius: size.width / 18, backgroundImage: NetworkImage((dataManager.videos[dataManager.currentPlaying].uploader_dpurl == '' || dataManager.videos[dataManager.currentPlaying].uploader_dpurl == null) ? 'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png' : dataManager.videos[dataManager.currentPlaying].uploader_dpurl)),
                                                                                                  SizedBox(
                                                                                                    width: 8,
                                                                                                  ),
                                                                                                  Text(dataManager.videos[dataManager.currentPlaying].uploader_channel_name == null ? dataManager.videos[dataManager.currentPlaying].uploaded_by : dataManager.videos[dataManager.currentPlaying].uploader_channel_name, style: TextStyle(color: kBlack, fontWeight: FontWeight.w600))
                                                                                                ],
                                                                                              ),
                                                                                              _subscribed == true || findIfSubscribed(dataManager.videos[dataManager.currentPlaying].uploader_id)
                                                                                                  ? InkWell(
                                                                                                      child: Container(
                                                                                                        decoration: BoxDecoration(
                                                                                                          border: Border.all(color: kPrimaryColor),
                                                                                                          borderRadius: BorderRadius.circular(5.0),
                                                                                                        ),
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets.all(8.0),
                                                                                                          child: Text(
                                                                                                            "SUBSCRIBED",
                                                                                                            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      onTap: () {},
                                                                                                    )
                                                                                                  : InkWell(
                                                                                                      onTap: () async {
                                                                                                        UserController ctrl = UserController();
                                                                                                        bool sub = await ctrl.addSubscription(int.parse(dataManager.videos[dataManager.currentPlaying].uploader_id));
                                                                                                        if (sub) {
                                                                                                          setState(() {
                                                                                                            _subscribed = true;
                                                                                                          });
                                                                                                        }
                                                                                                      },
                                                                                                      child: Container(
                                                                                                        decoration: BoxDecoration(
                                                                                                          border: Border.all(color: Colors.white60),
                                                                                                          borderRadius: BorderRadius.circular(5.0),
                                                                                                          color: kPrimaryColor,
                                                                                                        ),
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets.all(8.0),
                                                                                                          child: Text(
                                                                                                            "SUBSCRIBE",
                                                                                                            style: TextStyle(color: kWhite, fontWeight: FontWeight.w600),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    )
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        Divider(height: 2.0),
                                                                                        Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: InkWell(
                                                                                              child: Container(
                                                                                                  width: size.width,
                                                                                                  child: Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                    children: [
                                                                                                      Row(
                                                                                                        children: [
                                                                                                          Text('Comments', style: TextStyle(color: kBlack, fontWeight: FontWeight.w600)),
                                                                                                          SizedBox(width: 8),
                                                                                                          Text(_newCommentCount == null ? '' : _newCommentCount!, style: TextStyle(color: kBlack, fontWeight: FontWeight.w400))
                                                                                                        ],
                                                                                                      ),
                                                                                                      Icon(Icons.arrow_drop_down_rounded)
                                                                                                    ],
                                                                                                  )),
                                                                                              onTap: () => showModalBottomSheet(
                                                                                                // expand: false,
                                                                                                context: context,
                                                                                                elevation: 0.0,
                                                                                                // backgroundColor: Colors.transparent,
                                                                                                builder: (context) => StatefulBuilder(builder: (BuildContext context, StateSetter setState /*You can rename this!*/) {
                                                                                                  setState(() {
                                                                                                    _videoComments = fetchVideoComments();
                                                                                                  });
                                                                                                  return SingleChildScrollView(
                                                                                                    controller: ModalScrollController.of(context),
                                                                                                    child: Container(
                                                                                                      height: (size.height - _playHeight) - size.height / 14,
                                                                                                      child: Card(
                                                                                                          child: Column(
                                                                                                        children: [
                                                                                                          Row(
                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                            children: [
                                                                                                              Row(
                                                                                                                children: [
                                                                                                                  Text('Comments', style: TextStyle(color: kBlack, fontWeight: FontWeight.w600)),
                                                                                                                  SizedBox(width: 8),
                                                                                                                  Text(_newCommentCount == null ? '' : _newCommentCount!, style: TextStyle(color: kBlack, fontWeight: FontWeight.w400))
                                                                                                                ],
                                                                                                              ),
                                                                                                              IconButton(
                                                                                                                  onPressed: () {
                                                                                                                    Navigator.pop(context);
                                                                                                                  },
                                                                                                                  icon: Icon(Icons.cancel))
                                                                                                            ],
                                                                                                          ),
                                                                                                          Divider(height: 2.0),
                                                                                                          Container(
                                                                                                            width: size.width,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.all(8.0),
                                                                                                              child: Row(
                                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                children: [
                                                                                                                  Container(
                                                                                                                    width: size.width / 1.3,
                                                                                                                    child: TextField(
                                                                                                                      // autofocus: true,
                                                                                                                      onChanged: (value) {
                                                                                                                        _newComment = value;
                                                                                                                      },
                                                                                                                      decoration: InputDecoration(
                                                                                                                        contentPadding: EdgeInsets.all(3.0),
                                                                                                                        icon: CircleAvatar(radius: size.width / 18, backgroundImage: NetworkImage((currentUser().dp_url == '') ? 'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png' : currentUser().dp_url)),
                                                                                                                        hintText: 'Add a comment..',
                                                                                                                        // helperText: 'Helper Text',
                                                                                                                        // counterText: '0 characters',
                                                                                                                        border: OutlineInputBorder(),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  _commenting == true
                                                                                                                      ? Padding(
                                                                                                                          padding: const EdgeInsets.only(right: 3.0),
                                                                                                                          child: Container(
                                                                                                                            width: 20,
                                                                                                                            height: 20,
                                                                                                                            child: CircularProgressIndicator(
                                                                                                                              strokeWidth: 3.0,
                                                                                                                              color: kActiveColor,
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        )
                                                                                                                      : IconButton(
                                                                                                                          onPressed: () async {
                                                                                                                            _commenting = true;
                                                                                                                            setState(() {
                                                                                                                              _commenting = true;
                                                                                                                            });
                                                                                                                            // _changeCommenting();

                                                                                                                            if (_newComment == null || _newComment == "") {
                                                                                                                              setState(() {
                                                                                                                                _commenting = false;
                                                                                                                              });
                                                                                                                            } else {
                                                                                                                              UserController ctrl = UserController();
                                                                                                                              bool commented = await ctrl.addVideoComment(dataManager.videos[dataManager.currentPlaying].id, _newComment!);
                                                                                                                              if (commented) {
                                                                                                                                setState(() {
                                                                                                                                  dataManager.videos[dataManager.currentPlaying].comments.add({
                                                                                                                                    'comment': _newComment,
                                                                                                                                    'commentedAt': '',
                                                                                                                                    'commenter': {
                                                                                                                                      'id': currentUser().id,
                                                                                                                                      'dpUrl': currentUser().dp_url,
                                                                                                                                      'firstName': currentUser().first_name,
                                                                                                                                      'lastName': currentUser().last_name,
                                                                                                                                      'channelName': currentUser().channel_name,
                                                                                                                                      'email': currentUser().email
                                                                                                                                    }
                                                                                                                                  });

                                                                                                                                  setState(() {
                                                                                                                                    refreshComments();
                                                                                                                                    _newCommentCount = (int.parse(_newCommentCount!) + 1).toString();
                                                                                                                                  });
                                                                                                                                });
                                                                                                                                Navigator.pop(context);
                                                                                                                              }
                                                                                                                              setState(() {
                                                                                                                                _commenting = false;
                                                                                                                              });
                                                                                                                            }
                                                                                                                          },
                                                                                                                          icon: Icon(Icons.send))
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                          // Padding(
                                                                                                          //   padding: const EdgeInsets.all(8.0),
                                                                                                          //   child: Row(
                                                                                                          //     children: [
                                                                                                          //       CircleAvatar(radius: size.width / 18, backgroundImage: NetworkImage((currentUser().dp_url == '' || currentUser().dp_url == null) ? 'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png' : currentUser().dp_url)),
                                                                                                          //       SizedBox(
                                                                                                          //         width: 8,
                                                                                                          //       ),
                                                                                                          //       Text('Add a comment..', style: TextStyle(color: kBlack, fontWeight: FontWeight.w400)),
                                                                                                          //     ],
                                                                                                          //   ),
                                                                                                          // ),
                                                                                                          // Divider(height: 2.0),

                                                                                                          Container(
                                                                                                            height: size.height / 2 - 50,
                                                                                                            child: FutureBuilder(
                                                                                                                future: _videoComments,
                                                                                                                builder: (context, AsyncSnapshot snapshot) {
                                                                                                                  if (!snapshot.hasData) {
                                                                                                                    return customLoader(size: size, text: "Fetching comments..");
                                                                                                                  } else {
                                                                                                                    Future.delayed(Duration.zero, () async {
                                                                                                                      setState(() {
                                                                                                                        _newCommentCount = snapshot.data.length.toString();
                                                                                                                      });
                                                                                                                    });

                                                                                                                    return SingleChildScrollView(
                                                                                                                        child: Container(
                                                                                                                      height: size.height / 2 - 70,
                                                                                                                      child: new ListView.builder(
                                                                                                                          itemCount: snapshot.data.length,
                                                                                                                          itemBuilder: (context, int index) {
                                                                                                                            return widget.videos[currentPlaying].uploader_id == currentUser().id.toString() || snapshot.data[index]['commenter']['id'].toString() == currentUser().id.toString()
                                                                                                                                ? Row(
                                                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                                    children: [
                                                                                                                                      Container(
                                                                                                                                        width: size.width / 1.19,
                                                                                                                                        child: Column(
                                                                                                                                          children: [
                                                                                                                                            Padding(
                                                                                                                                              padding: const EdgeInsets.all(8.0),
                                                                                                                                              child: Column(children: [
                                                                                                                                                Row(
                                                                                                                                                  children: [
                                                                                                                                                    CircleAvatar(radius: size.width / 33, backgroundImage: NetworkImage((snapshot.data[index]['commenter']['dpUrl'] == '' || snapshot.data[index]['commenter']['dpUrl'] == null) ? 'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png' : snapshot.data[index]['commenter']['dpUrl'])),
                                                                                                                                                    SizedBox(
                                                                                                                                                      width: 8,
                                                                                                                                                    ),
                                                                                                                                                    Text(snapshot.data[index]['commenter']['channelName'] == null || snapshot.data[index]['commenter']['channelName'] == "" ? snapshot.data[index]['commenter']['firstName'] + " " + snapshot.data[index]['commenter']['lastName'] : snapshot.data[index]['commenter']['channelName'] + " - " + getLapse(snapshot.data[index]['commentedAt'])),
                                                                                                                                                  ],
                                                                                                                                                ),
                                                                                                                                                Padding(
                                                                                                                                                  padding: const EdgeInsets.only(top: 3.0),
                                                                                                                                                  child: Container(width: size.width, child: Text(snapshot.data[index]['comment'])),
                                                                                                                                                )
                                                                                                                                              ]),
                                                                                                                                            ),
                                                                                                                                            Divider(height: 2.0),
                                                                                                                                          ],
                                                                                                                                        ),
                                                                                                                                      ),
                                                                                                                                      IconButton(
                                                                                                                                          onPressed: () {
                                                                                                                                            showDialog(
                                                                                                                                              context: context,
                                                                                                                                              builder: (context) => AlertDialog(
                                                                                                                                                // title: Text('Result'),
                                                                                                                                                content: Text('Delete this comment ?'),
                                                                                                                                                actions: [
                                                                                                                                                  ElevatedButton(
                                                                                                                                                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent[700])),
                                                                                                                                                      onPressed: () async {
                                                                                                                                                        setState(() {
                                                                                                                                                          _videoComments = fetchVideoComments();
                                                                                                                                                        });
                                                                                                                                                        UserController ctrl = UserController();
                                                                                                                                                        bool? deleted = await ctrl.deleteComment(snapshot.data[index]['id']);
                                                                                                                                                        if (deleted == null) {
                                                                                                                                                          Navigator.pop(context);
                                                                                                                                                          Flushbar(
                                                                                                                                                            icon: Icon(
                                                                                                                                                              Icons.info_outline,
                                                                                                                                                              color: Colors.white,
                                                                                                                                                            ),
                                                                                                                                                            backgroundColor: Colors.redAccent,
                                                                                                                                                            title: "Error",
                                                                                                                                                            message: "Could not delete video.Try again later",
                                                                                                                                                            duration: Duration(seconds: 3),
                                                                                                                                                          )..show(context);
                                                                                                                                                        } else {
                                                                                                                                                          _deletedComments.add(snapshot.data[index]['id']);
                                                                                                                                                          setState(() {
                                                                                                                                                            refreshComments();
                                                                                                                                                            _newCommentCount = (int.parse(_newCommentCount!) - 1).toString();
                                                                                                                                                          });
                                                                                                                                                          setState(() {
                                                                                                                                                            _videoComments = fetchVideoComments();
                                                                                                                                                          });
                                                                                                                                                          setState(() {});
                                                                                                                                                          // ctrl.fetchChannelVideos(user_id).then((channel_videos) {
                                                                                                                                                          //   setState(() {
                                                                                                                                                          //     _channelVideos = channel_videos;
                                                                                                                                                          //   });
                                                                                                                                                          // });
                                                                                                                                                          Navigator.pop(context);
                                                                                                                                                          Flushbar(
                                                                                                                                                            icon: Icon(
                                                                                                                                                              Icons.check_circle_rounded,
                                                                                                                                                              color: kPrimaryColor,
                                                                                                                                                            ),
                                                                                                                                                            backgroundColor: kPrimaryLightColor,
                                                                                                                                                            title: "Success",
                                                                                                                                                            message: "Comment deleted",
                                                                                                                                                            duration: Duration(seconds: 3),
                                                                                                                                                          )..show(context);
                                                                                                                                                        }
                                                                                                                                                        fetchVideoComments();
                                                                                                                                                        setState(() {});
                                                                                                                                                      },
                                                                                                                                                      child: Text('Yes')),
                                                                                                                                                  ElevatedButton(
                                                                                                                                                      onPressed: () {
                                                                                                                                                        setState(() {});
                                                                                                                                                        Navigator.pop(context);
                                                                                                                                                      },
                                                                                                                                                      child: Text('No'))
                                                                                                                                                ],
                                                                                                                                              ),
                                                                                                                                            );
                                                                                                                                          },
                                                                                                                                          icon: Icon(FlutterIcons.delete_mco, size: 21))
                                                                                                                                    ],
                                                                                                                                  )
                                                                                                                                : Column(
                                                                                                                                    children: [
                                                                                                                                      Padding(
                                                                                                                                        padding: const EdgeInsets.all(8.0),
                                                                                                                                        child: Column(children: [
                                                                                                                                          Row(
                                                                                                                                            children: [
                                                                                                                                              CircleAvatar(radius: size.width / 33, backgroundImage: NetworkImage((snapshot.data[index]['commenter']['dpUrl'] == '' || snapshot.data[index]['commenter']['dpUrl'] == null) ? 'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png' : snapshot.data[index]['commenter']['dpUrl'])),
                                                                                                                                              SizedBox(
                                                                                                                                                width: 8,
                                                                                                                                              ),
                                                                                                                                              Text(snapshot.data[index]['commenter']['channelName'] == null || snapshot.data[index]['commenter']['channelName'] == "" ? snapshot.data[index]['commenter']['firstName'] + " " + snapshot.data[index]['commenter']['lastName'] : snapshot.data[index]['commenter']['channelName'] + " - " + getLapse(snapshot.data[index]['commentedAt'])),
                                                                                                                                            ],
                                                                                                                                          ),
                                                                                                                                          Padding(
                                                                                                                                            padding: const EdgeInsets.only(top: 3.0),
                                                                                                                                            child: Container(width: size.width, child: Text(snapshot.data[index]['comment'])),
                                                                                                                                          )
                                                                                                                                        ]),
                                                                                                                                      ),
                                                                                                                                      Divider(height: 2.0),
                                                                                                                                    ],
                                                                                                                                  );
                                                                                                                          }),
                                                                                                                    ));
                                                                                                                  }
                                                                                                                }),
                                                                                                          ),

                                                                                                          // Container(
                                                                                                          //   height: size.height / 2 - 50,
                                                                                                          //   child: SingleChildScrollView(
                                                                                                          //     child: Column(
                                                                                                          //         children: _videoComments
                                                                                                          //             .map<Container>((comment) => Container(
                                                                                                          //                   child: _deletedComments.contains(comment['id']) || comment['deletedAt'] == null
                                                                                                          //                       ? SizedBox()
                                                                                                          //                       : comment['commenter']['id'].toString() == currentUser().id.toString()
                                                                                                          //                           ? Row(
                                                                                                          //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                          //                               children: [
                                                                                                          //                                 Container(
                                                                                                          //                                   width: size.width / 1.19,
                                                                                                          //                                   child: Column(
                                                                                                          //                                     children: [
                                                                                                          //                                       Padding(
                                                                                                          //                                         padding: const EdgeInsets.all(8.0),
                                                                                                          //                                         child: Column(children: [
                                                                                                          //                                           Row(
                                                                                                          //                                             children: [
                                                                                                          //                                               CircleAvatar(radius: size.width / 33, backgroundImage: NetworkImage((comment['commenter']['dpUrl'] == '' || comment['commenter']['dpUrl'] == null) ? 'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png' : comment['commenter']['dpUrl'])),
                                                                                                          //                                               SizedBox(
                                                                                                          //                                                 width: 8,
                                                                                                          //                                               ),
                                                                                                          //                                               Text(comment['commenter']['channelName'] == null || comment['commenter']['channelName'] == "" ? comment['commenter']['firstName'] + " " + comment['commenter']['lastName'] : comment['commenter']['channelName'] + " - " + getLapse(comment['commentedAt']) + " - " + comment['deletedAt'].toString()),
                                                                                                          //                                             ],
                                                                                                          //                                           ),
                                                                                                          //                                           Padding(
                                                                                                          //                                             padding: const EdgeInsets.only(top: 3.0),
                                                                                                          //                                             child: Container(width: size.width, child: Text(comment['comment'])),
                                                                                                          //                                           )
                                                                                                          //                                         ]),
                                                                                                          //                                       ),
                                                                                                          //                                       Divider(height: 2.0),
                                                                                                          //                                     ],
                                                                                                          //                                   ),
                                                                                                          //                                 ),
                                                                                                          //                                 IconButton(
                                                                                                          //                                     onPressed: () {
                                                                                                          //                                       showDialog(
                                                                                                          //                                         context: context,
                                                                                                          //                                         builder: (context) => AlertDialog(
                                                                                                          //                                           // title: Text('Result'),
                                                                                                          //                                           content: Text('Delete this comment - ' + comment['id'].toString() + '?'),
                                                                                                          //                                           actions: [
                                                                                                          //                                             ElevatedButton(
                                                                                                          //                                                 style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent[700])),
                                                                                                          //                                                 onPressed: () async {
                                                                                                          //                                                   UserController ctrl = UserController();
                                                                                                          //                                                   bool? deleted = await ctrl.deleteComment(comment['id']);
                                                                                                          //                                                   if (deleted == null) {
                                                                                                          //                                                     Navigator.pop(context);
                                                                                                          //                                                     Flushbar(
                                                                                                          //                                                       icon: Icon(
                                                                                                          //                                                         Icons.info_outline,
                                                                                                          //                                                         color: Colors.white,
                                                                                                          //                                                       ),
                                                                                                          //                                                       backgroundColor: Colors.redAccent,
                                                                                                          //                                                       title: "Error",
                                                                                                          //                                                       message: "Could not delete video.Try again later",
                                                                                                          //                                                       duration: Duration(seconds: 3),
                                                                                                          //                                                     )..show(context);
                                                                                                          //                                                   } else {
                                                                                                          //                                                     _deletedComments.add(comment['id']);
                                                                                                          //                                                     setState(() {});
                                                                                                          //                                                     // ctrl.fetchChannelVideos(user_id).then((channel_videos) {
                                                                                                          //                                                     //   setState(() {
                                                                                                          //                                                     //     _channelVideos = channel_videos;
                                                                                                          //                                                     //   });
                                                                                                          //                                                     // });
                                                                                                          //                                                     Navigator.pop(context);
                                                                                                          //                                                     Flushbar(
                                                                                                          //                                                       icon: Icon(
                                                                                                          //                                                         Icons.check_circle_rounded,
                                                                                                          //                                                         color: kPrimaryColor,
                                                                                                          //                                                       ),
                                                                                                          //                                                       backgroundColor: kPrimaryLightColor,
                                                                                                          //                                                       title: "Success",
                                                                                                          //                                                       message: "Comment deleted",
                                                                                                          //                                                       duration: Duration(seconds: 3),
                                                                                                          //                                                     )..show(context);
                                                                                                          //                                                   }
                                                                                                          //                                                 },
                                                                                                          //                                                 child: Text('Yes')),
                                                                                                          //                                             ElevatedButton(
                                                                                                          //                                                 onPressed: () {
                                                                                                          //                                                   Navigator.pop(context);
                                                                                                          //                                                 },
                                                                                                          //                                                 child: Text('No'))
                                                                                                          //                                           ],
                                                                                                          //                                         ),
                                                                                                          //                                       );
                                                                                                          //                                     },
                                                                                                          //                                     icon: Icon(FlutterIcons.delete_mco, size: 21))
                                                                                                          //                               ],
                                                                                                          //                             )
                                                                                                          //                           : Column(
                                                                                                          //                               children: [
                                                                                                          //                                 Padding(
                                                                                                          //                                   padding: const EdgeInsets.all(8.0),
                                                                                                          //                                   child: Column(children: [
                                                                                                          //                                     Row(
                                                                                                          //                                       children: [
                                                                                                          //                                         CircleAvatar(radius: size.width / 33, backgroundImage: NetworkImage((comment['commenter']['dpUrl'] == '' || comment['commenter']['dpUrl'] == null) ? 'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png' : comment['commenter']['dpUrl'])),
                                                                                                          //                                         SizedBox(
                                                                                                          //                                           width: 8,
                                                                                                          //                                         ),
                                                                                                          //                                         Text(comment['commenter']['channelName'] == null || comment['commenter']['channelName'] == "" ? comment['commenter']['firstName'] + " " + comment['commenter']['lastName'] : comment['commenter']['channelName'] + " - " + getLapse(comment['commentedAt'])),
                                                                                                          //                                       ],
                                                                                                          //                                     ),
                                                                                                          //                                     Padding(
                                                                                                          //                                       padding: const EdgeInsets.only(top: 3.0),
                                                                                                          //                                       child: Container(width: size.width, child: Text(comment['comment'])),
                                                                                                          //                                     )
                                                                                                          //                                   ]),
                                                                                                          //                                 ),
                                                                                                          //                                 Divider(height: 2.0),
                                                                                                          //                               ],
                                                                                                          //                             ),
                                                                                                          //                 ))
                                                                                                          //             .toList()),
                                                                                                          //   ),
                                                                                                          // ),

                                                                                                          //                                                       FutureBuilder(
                                                                                                          // future: dataManager.videos[dataManager.currentPlaying].comments,
                                                                                                          // builder: (context,
                                                                                                          //     AsyncSnapshot snapshot) {
                                                                                                          //   if (!snapshot.hasData) {
                                                                                                          //     return customLoader(
                                                                                                          //         size: size,
                                                                                                          //         text:
                                                                                                          //             "Loading comments..");
                                                                                                          //   } else {
                                                                                                          //     return VisibilityDetector(
                                                                                                          //     )}}),
                                                                                                        ],
                                                                                                      )),
                                                                                                    ),
                                                                                                  );
                                                                                                }),
                                                                                              ),
                                                                                            )),
                                                                                        Divider(height: 2.0),
                                                                                        ClipRRect(
                                                                                          borderRadius: BorderRadius.circular(8.0),
                                                                                          child: GestureDetector(
                                                                                              onTap: () {
                                                                                                dataManager.skipToVideo(index);
                                                                                                // videoSelected = true;
                                                                                                // onVideoTap(1, snapshot.data[index].url, snapshot.data[index].id);

                                                                                                // videoTitle = snapshot.data[index].title;
                                                                                                setState(() {});
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
                                                                                                                      // Align(
                                                                                                                      //   alignment: Alignment.bottomLeft,
                                                                                                                      //   child: ThumbNailIconButton(
                                                                                                                      //     icon_data: Icons.watch_later,
                                                                                                                      //     press: () {},
                                                                                                                      //   ),
                                                                                                                      // ),
                                                                                                                      // Align(
                                                                                                                      //   alignment: Alignment.bottomRight,
                                                                                                                      //   child: ThumbNailIconButton(
                                                                                                                      //     icon_data: Icons.favorite,
                                                                                                                      //     press: () {},
                                                                                                                      //   ),
                                                                                                                      // )
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                            Container(
                                                                                                              // height: size.height * 0.19,
                                                                                                              width: !isCollapsed ? size.width / 4 : size.width / 2.2,
                                                                                                              // color: Colors.black26,
                                                                                                              // padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
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
                                                                                                                  ImageChip(image_url: (snapshot.data[index].uploader_dpurl == '' || snapshot.data[index].uploader_dpurl == null) ? 'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png' : snapshot.data[index].uploader_dpurl, text: snapshot.data[index].uploader_channel_name == null || snapshot.data[index].uploader_channel_name == "" ? snapshot.data[index].uploaded_by : snapshot.data[index].uploader_channel_name),
                                                                                                                  Row(
                                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                    children: [
                                                                                                                      VideoInfoChip(
                                                                                                                        icon_data: Icons.remove_red_eye,
                                                                                                                        text: snapshot.data[index].views,
                                                                                                                      ),
                                                                                                                      VideoInfoChip(
                                                                                                                        icon_data: Icons.access_time,
                                                                                                                        text: snapshot.data[index].upload_lapse,
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
                                                                                      ],
                                                                                    )
                                                                                  : Padding(
                                                                                      padding: const EdgeInsets.all(3.0),
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(8.0),
                                                                                        child: GestureDetector(
                                                                                            onTap: () {
                                                                                              dataManager.skipToVideo(index);
                                                                                              // videoSelected = true;
                                                                                              // onVideoTap(1, snapshot.data[index].url, snapshot.data[index].id);

                                                                                              // videoTitle = snapshot.data[index].title;
                                                                                              setState(() {});
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
                                                                                                                    // Align(
                                                                                                                    //   alignment: Alignment.bottomLeft,
                                                                                                                    //   child: ThumbNailIconButton(
                                                                                                                    //     icon_data: Icons.watch_later,
                                                                                                                    //     press: () {},
                                                                                                                    //   ),
                                                                                                                    // ),
                                                                                                                    // Align(
                                                                                                                    //   alignment: Alignment.bottomRight,
                                                                                                                    //   child: ThumbNailIconButton(
                                                                                                                    //     icon_data: Icons.favorite,
                                                                                                                    //     press: () {},
                                                                                                                    //   ),
                                                                                                                    // )
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                          Container(
                                                                                                            // height: size.height * 0.19,
                                                                                                            width: !isCollapsed ? size.width / 4 : size.width / 2.2,
                                                                                                            // color: Colors.black26,
                                                                                                            // padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
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
                                                                                                                ImageChip(image_url: (snapshot.data[index].uploader_dpurl == '' || snapshot.data[index].uploader_dpurl == null) ? 'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png' : snapshot.data[index].uploader_dpurl, text: snapshot.data[index].uploader_channel_name == null || snapshot.data[index].uploader_channel_name == "" ? snapshot.data[index].uploaded_by : snapshot.data[index].uploader_channel_name),
                                                                                                                Row(
                                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                  children: [
                                                                                                                    VideoInfoChip(
                                                                                                                      icon_data: Icons.remove_red_eye,
                                                                                                                      text: snapshot.data[index].views,
                                                                                                                    ),
                                                                                                                    VideoInfoChip(
                                                                                                                      icon_data: Icons.access_time,
                                                                                                                      text: snapshot.data[index].upload_lapse,
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
                                                                                    ),
                                                                            );
                                                                          }),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
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
                                      // Container(
                                      //   height: !isCollapsed
                                      //       ? size.height / 17
                                      //       : size.height / 13,
                                      //   width: size.width,
                                      //   child: Column(
                                      //     mainAxisSize: MainAxisSize.max,
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.center,
                                      //     children: [
                                      //       Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment
                                      //                   .spaceEvenly,
                                      //           mainAxisSize: MainAxisSize.max,
                                      //           children: [
                                      //             InkWell(
                                      //               onTap: () {
                                      //                 setState(() {
                                      //                   videoSelected = false;
                                      //                   _controller.pause();
                                      //                   topPage = false;
                                      //                   latestPage = false;
                                      //                   trendingPage = true;
                                      //                 });
                                      //               },
                                      //               child: Container(
                                      //                 // width: size.width * 0.25,
                                      //                 padding:
                                      //                     EdgeInsets.symmetric(
                                      //                         vertical: 5.0,
                                      //                         horizontal: 10.0),
                                      //                 decoration: BoxDecoration(
                                      //                   color: trendingPage
                                      //                       ? kActiveColor
                                      //                       : kPrimaryColor,
                                      //                   borderRadius:
                                      //                       BorderRadius
                                      //                           .circular(15.0),
                                      //                 ),
                                      //                 child: Row(
                                      //                   children: [
                                      //                     Icon(
                                      //                       FlutterIcons
                                      //                           .fire_alt_faw5s,
                                      //                       color: trendingPage
                                      //                           ? kBlack
                                      //                           : kActiveColor,
                                      //                       size: size.height *
                                      //                           0.025,
                                      //                     ),
                                      //                     SizedBox(
                                      //                       width: 6,
                                      //                     ),
                                      //                     Text(
                                      //                       "Trending",
                                      //                       style: TextStyle(
                                      //                           color: trendingPage
                                      //                               ? kBlack
                                      //                               : kActiveColor),
                                      //                     ),
                                      //                   ],
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //             InkWell(
                                      //               onTap: () {
                                      //                 setState(() {
                                      //                   videoSelected = false;
                                      //                   _controller.pause();
                                      //                   latestPage = false;
                                      //                   trendingPage = false;
                                      //                   topPage = true;
                                      //                 });
                                      //               },
                                      //               child: Container(
                                      //                 padding:
                                      //                     EdgeInsets.symmetric(
                                      //                         vertical: 5.0,
                                      //                         horizontal: 10.0),
                                      //                 decoration: BoxDecoration(
                                      //                   color: topPage
                                      //                       ? kActiveColor
                                      //                       : kPrimaryColor,
                                      //                   border: Border.all(
                                      //                       color: topPage
                                      //                           ? kBlack
                                      //                           : kActiveColor),
                                      //                   borderRadius:
                                      //                       BorderRadius
                                      //                           .circular(15.0),
                                      //                 ),
                                      //                 child: Row(
                                      //                   children: [
                                      //                     Icon(
                                      //                       FlutterIcons
                                      //                           .timeline_mco,
                                      //                       color: topPage
                                      //                           ? kBlack
                                      //                           : kActiveColor,
                                      //                       size: size.height *
                                      //                           0.025,
                                      //                     ),
                                      //                     SizedBox(
                                      //                       width: 6,
                                      //                     ),
                                      //                     Text(
                                      //                       "Top",
                                      //                       style: TextStyle(
                                      //                           color: topPage
                                      //                               ? kBlack
                                      //                               : kActiveColor),
                                      //                     ),
                                      //                   ],
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //             InkWell(
                                      //               onTap: () {
                                      //                 setState(() {
                                      //                   videoSelected = false;
                                      //                   _controller.pause();
                                      //                   trendingPage = false;
                                      //                   topPage = false;
                                      //                   latestPage = true;
                                      //                 });
                                      //               },
                                      //               child: Container(
                                      //                 padding:
                                      //                     EdgeInsets.symmetric(
                                      //                         vertical: 5.0,
                                      //                         horizontal: 10.0),
                                      //                 decoration: BoxDecoration(
                                      //                   color: latestPage
                                      //                       ? kActiveColor
                                      //                       : kPrimaryColor,
                                      //                   border: Border.all(
                                      //                       color: latestPage
                                      //                           ? kBlack
                                      //                           : kActiveColor),
                                      //                   borderRadius:
                                      //                       BorderRadius
                                      //                           .circular(15.0),
                                      //                 ),
                                      //                 child: Row(
                                      //                   children: [
                                      //                     Icon(
                                      //                       FlutterIcons
                                      //                           .time_slot_ent,
                                      //                       color: latestPage
                                      //                           ? kBlack
                                      //                           : kActiveColor,
                                      //                       size: size.height *
                                      //                           0.025,
                                      //                     ),
                                      //                     SizedBox(
                                      //                       width: 6,
                                      //                     ),
                                      //                     Text(
                                      //                       "Latest",
                                      //                       style: TextStyle(
                                      //                           color: latestPage
                                      //                               ? kBlack
                                      //                               : kActiveColor),
                                      //                     ),
                                      //                   ],
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //             SizedBox(
                                      //                 width: size.width / 4)
                                      //             // OutlinedButton(
                                      //             //   child: Icon(Icons.more_horiz),
                                      //             //   style: OutlinedButton.styleFrom(
                                      //             //     primary: kPrimaryLightColor,
                                      //             //     // side: BorderSide(
                                      //             //     //     width: 1, color: Colors.white),
                                      //             //     shape: CircleBorder(),
                                      //             //   ),
                                      //             //   onPressed: () {},
                                      //             // )
                                      //           ]),
                                      //     ],
                                      //   ),
                                      // ),
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

  Future<List<Video>> fetchVideos() async {
    return widget.videos;
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

  // void _changeCommenting() {
  //   _commenting = !_commenting;
  //   print('sending: ' + _commenting.toString());
  //   setState(() {});
  //   setState(() {
  //     _commenting = !_commenting;
  //   });
  // }

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

  String getLapse(stamp) {
    if (stamp == '') {
      return 'Just now';
    }
    DateTime dateTimeCreatedAt = DateTime.parse(stamp);
    DateTime dateTimeNow = DateTime.now();
    final days_lapse = dateTimeNow.difference(dateTimeCreatedAt).inDays;
    String lapse = "Today";
    if (days_lapse < 1) {
      String lapse = "Today";
    } else if (days_lapse == 1) {
      lapse = "yesterday";
    } else {
      lapse = days_lapse.toString() + " days ago";
    }
    return lapse;
  }

  bool findIfSubscribed(String id) {
    List<int> subscriptions = currentUser().subscribed_channels;

    bool subscribed = false;
    subscriptions.forEach((s) {
      if (s == int.parse(id)) {
        subscribed = true;
      }
    });
    print("ifSubscribed returning " + subscribed.toString());
    return subscribed;
  }

  bool findIfLiked(int id) {
    List<int> liked_videos = currentUser().liked_videos;

    bool liked = false;
    liked_videos.forEach((l) {
      if (l == id) {
        liked = true;
      }
    });
    print("ifLiked returning " + liked.toString());
    return liked;
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

import 'dart:io';
import 'dart:ui';
import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/controller/user_controller.dart';
import 'package:africanplug/main.dart';
import 'package:africanplug/models/location.dart';
import 'package:africanplug/models/user.dart';
import 'package:africanplug/models/video.dart';
import 'package:africanplug/player/upload_player.dart';
import 'package:africanplug/screens/login/components/validation.dart';
import 'package:africanplug/screens/login/login.dart';
import 'package:africanplug/widgets/app/appbar.dart';
import 'package:africanplug/widgets/button/main_upload_button.dart';
import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
import 'package:africanplug/widgets/chip/image_chip.dart';
import 'package:africanplug/widgets/input/text_input_field.dart';
import 'package:africanplug/widgets/loader/custom_loader.dart';
import 'package:africanplug/widgets/menu/main_menu.dart';
import 'package:africanplug/widgets/video/thumbnail_display.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:africanplug/widgets/video/video_tile_old.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key, required this.tab, required this.user_id})
      : super(key: key);

  final String tab;
  final int user_id;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
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

  /// SIZE
  late double _screenWidth;
  late double _screenHeight;
  double _blockSizeHorizontal = 0;
  double _blockSizeVertical = 0;

  late double textMultiplier;
  late double imageSizeMultiplier;
  late double heightMultiplier;
  late double widthMultiplier;
  bool isPortrait = true;
  bool isMobilePortrait = false;

  late String tab = widget.tab;
  late int user_id = widget.user_id;

  late String dp_url;

//update profile form
  String phoneStr = "000000000";

  final _updateProfileFormKey = new GlobalKey<FormState>();
  String? _password;
  String? _registerPhoneNo;
  String? _registerFirstName;
  String? _channelName;
  String? _FBName;
  String? _IGName;
  String? _FBUrl;
  String? _IGUrl;
  String? _registerLastName;
  String? _registerpassword;
  String? _passwordConfirmation;
  bool _showPasswordsError = false;
  User? channel;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  TextEditingController _registerFirstNameController =
      new TextEditingController();
  TextEditingController _channelNameController = new TextEditingController();
  TextEditingController _registerLastNameController =
      new TextEditingController();
  RangeValues _ageRangeValues = const RangeValues(defaultMinAge, defaultMaxAge);
  TextEditingController _registerPhoneNoController =
      new TextEditingController();
  TextEditingController _registerEmailController = new TextEditingController();
  TextEditingController _registerPasswordController =
      new TextEditingController();
  TextEditingController _registerPasswordConfirmationController =
      new TextEditingController();
//profile Image
  Widget _profileImageSection = Container();
  bool _uploadingImage = false;
  bool _updatingDetails = false;
  String _displayText = "";

  List<Video>? _channelVideos;
  User logged_in_user = currentUser();
  late bool isOwner;

  @override
  void initState() {
    isOwner = logged_in_user.id == widget.user_id ? true : false;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      UserController ctrl = UserController();
      ctrl.fetchChannelDetails(user_id).then((res) {
        setState(() {
          channel = res;
        });
        if (user_id != channel!.id) {
        } else {
          setState(() {
            // print("____________RES______________");
            // print(res.first_name);
            dp_url = res.dp_url;
            _channelName = res.channel_name;
            _displayText = res.channel_name == "" || res.channel_name == null
                ? res.first_name + " " + res.last_name
                : res.channel_name;
            _registerLastName = res.last_name;
            _registerFirstName = res.first_name;

            if (res.phone_no != null || res.phone_no == '') {
              phoneStr = res.phone_no.substring(res.phone_no.length - 9);
            }
            _registerPhoneNo = phoneStr;

            _profileImageSection = Container(
              height: 11 * heightMultiplier,
              width: 22 * widthMultiplier,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        dp_url,
                      ))),
            );
          });
        }
        ctrl.fetchChannelVideos(user_id).then((channel_videos) {
          if (mounted) {
            setState(() {
              _channelVideos = channel_videos;
            });
          }
        });
      });
    });

    _aController = AnimationController(duration: duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.85).animate(_aController);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_aController);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_aController);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait) {
      _screenWidth = size.width;
      _screenHeight = size.height;
      isPortrait = true;
      if (_screenWidth < 450) {
        isMobilePortrait = true;
      }
    } else {
      _screenWidth = size.width;
      _screenHeight = size.height;
      isPortrait = false;
      isMobilePortrait = false;
    }

    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    textMultiplier = _blockSizeVertical;
    imageSizeMultiplier = _blockSizeHorizontal;
    heightMultiplier = _blockSizeVertical;
    widthMultiplier = _blockSizeHorizontal;

    // setState(() {
    //   _profileImageSection = Container(
    //       height: 11 * heightMultiplier,
    //       width: 22 * widthMultiplier,
    //       child: CircularProgressIndicator(
    //         color: kActiveColor,
    //       ));
    // });

    final key = GlobalKey();
    String? current_page = ModalRoute.of(context)?.settings.name;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
                child: channel == null
                    ? customLoader(size: size, text: "Fetching details...")
                    : Padding(
                        padding: isCollapsed
                            ? const EdgeInsets.only(top: 0.0, bottom: 0.0)
                            : const EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: SafeArea(
                            child: Stack(
                          children: [
                            Scaffold(
                              resizeToAvoidBottomInset: false,
                              backgroundColor: kScaffoldColor,
                              body: Stack(
                                children: <Widget>[
                                  // Align(
                                  //   alignment: Alignment.topLeft,
                                  //   child:

                                  //   ),
                                  // ),
                                  Container(
                                    color: kScaffoldColor,
                                    height: height / 4,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 30.0,
                                          right: 30.0,
                                          top: height / 30),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              user_id == channel!.id
                                                  ? _uploadingImage
                                                      ? Container(
                                                          height: height / 10,
                                                          width: height / 10,
                                                          child:
                                                              Transform.scale(
                                                            scale: 0.5,
                                                            child: CircularProgressIndicator(
                                                                color:
                                                                    kActiveColor),
                                                          ),
                                                        )
                                                      : InkWell(
                                                          child: Stack(
                                                            children: [
                                                              _profileImageSection,
                                                              Positioned(
                                                                bottom: -10,
                                                                right: -10,
                                                                child:
                                                                    IconButton(
                                                                        onPressed:
                                                                            changeDisplayPicture,
                                                                        icon:
                                                                            Icon(
                                                                          FlutterIcons
                                                                              .edit_mdi,
                                                                          color:
                                                                              kActiveColor,
                                                                          size:
                                                                              30,
                                                                        )),
                                                              )
                                                            ],
                                                          ),
                                                          onTap:
                                                              changeDisplayPicture,
                                                        )
                                                  : Container(
                                                      height: height / 9,
                                                      width: height / 9,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: NetworkImage(
                                                                channel!.dp_url,
                                                              ))),
                                                    ),
                                              SizedBox(
                                                width: width / 15,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    _channelName == "" ||
                                                            _channelName == null
                                                        ? _displayText
                                                        : _channelName!,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: width / 17,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        1 * heightMultiplier,
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      InkWell(
                                                        onTap: _FBUrl == null ||
                                                                _FBUrl == ""
                                                            ? () {}
                                                            : () =>
                                                                launch(_FBUrl!),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Image.asset(
                                                              "assets/travel/fb.png",
                                                              height:
                                                                  width / 24,
                                                              width: width / 24,
                                                            ),
                                                            SizedBox(
                                                              width: 2 *
                                                                  widthMultiplier,
                                                            ),
                                                            Text(
                                                              channel == null ||
                                                                      channel!.fb_name ==
                                                                          null ||
                                                                      channel!.fb_name ==
                                                                          ""
                                                                  ? _FBName ==
                                                                              "" ||
                                                                          _FBName ==
                                                                              null
                                                                      ? "FB name"
                                                                      : _FBName!
                                                                  : channel!
                                                                      .fb_name!,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white60,
                                                                fontSize: 1.5 *
                                                                    textMultiplier,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width / 16,
                                                      ),
                                                      InkWell(
                                                        onTap: _IGUrl == null ||
                                                                _IGUrl == ""
                                                            ? () {}
                                                            : () =>
                                                                launch(_IGUrl!),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Image.asset(
                                                              "assets/travel/insta.png",
                                                              height:
                                                                  width / 24,
                                                              width: width / 24,
                                                            ),
                                                            SizedBox(
                                                              width: width / 24,
                                                            ),
                                                            Text(
                                                              channel == null ||
                                                                      channel!.instagram_name ==
                                                                          null ||
                                                                      channel!.instagram_name ==
                                                                          ""
                                                                  ? _IGName ==
                                                                              "" ||
                                                                          _IGName ==
                                                                              null
                                                                      ? "IG name"
                                                                      : _IGName!
                                                                  : channel!
                                                                      .instagram_name!,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white60,
                                                                fontSize: 1.5 *
                                                                    textMultiplier,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 3 * heightMultiplier,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  Text(
                                                    "0",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            3 * textMultiplier,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "Subscribers",
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize:
                                                          1.9 * textMultiplier,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Text(
                                                    _channelVideos == null
                                                        ? "0"
                                                        : _channelVideos!.length
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            3 * textMultiplier,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "Videos",
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize:
                                                          1.9 * textMultiplier,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              InkWell(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.white60),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      "UPLOAD VIDEO",
                                                      style: TextStyle(
                                                          color: Colors.white60,
                                                          fontSize: 1.8 *
                                                              textMultiplier),
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context, "/upload");
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Container(
                                  //   // color: kRed,
                                  //   // height: 30 * heightMultiplier,
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.all(8.0),
                                  //     child: Icon(
                                  //       FlutterIcons.navigate_before_mdi,
                                  //       color: kWhite,
                                  //       size: 30,
                                  //     ),
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 25 * heightMultiplier),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20.0),
                                            topLeft: Radius.circular(20.0),
                                          )),
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              child: Container(
                                                // width: size.width,
                                                height: height / 22,
                                                child: ListView(
                                                    // mainAxisAlignment:
                                                    //     MainAxisAlignment.spaceEvenly,
                                                    // mainAxisSize: MainAxisSize.max,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    children: [
                                                      tabOption(
                                                          'profile',
                                                          FlutterIcons.edit_mdi,
                                                          size),
                                                      tabOption(
                                                          'videos',
                                                          FlutterIcons
                                                              .video_faw5s,
                                                          size),
                                                      tabOption('favourites',
                                                          Icons.favorite, size),
                                                      tabOption(
                                                          'watch later',
                                                          Icons.watch_later,
                                                          size),
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
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: height / 1.55,
                                            child: SingleChildScrollView(
                                              child: tab == 'profile'
                                                  ? updateProfileTab(size)
                                                  : tab == 'videos'
                                                      ? channelVideosTab(size)
                                                      : tab == 'watch later'
                                                          ? SizedBox()
                                                          : tab == 'favourites'
                                                              ? SizedBox()
                                                              : SizedBox(
                                                                  child: Text(
                                                                      'Tab not found'),
                                                                ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
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

  Column favouritesTab() {
    return Column(
      children: [
        // Padding(
        //   padding: EdgeInsets.only(
        //       left: 20.0,
        //       top: 3 * heightMultiplier),
        //   child: Text(
        //     "$tab",
        //     style: TextStyle(
        //         color: Colors.black,
        //         fontWeight: FontWeight.bold,
        //         fontSize:
        //             2.2 * textMultiplier),
        //   ),
        // ),
        // SizedBox(
        //   height: 3 * heightMultiplier,
        // ),
        Container(
          height: 37 * heightMultiplier,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _myAlbumCard(
                  "assets/travel/travelfive.png",
                  "assets/travel/traveltwo.png",
                  "assets/travel/travelsix.png",
                  "assets/travel/travelthree.png",
                  "+178",
                  "Best Trip"),
              _myAlbumCard(
                  "assets/travel/travelsix.png",
                  "assets/travel/travelthree.png",
                  "assets/travel/travelfour.png",
                  "assets/travel/travelfive.png",
                  "+18",
                  "Hill Lake Tourism"),
              _myAlbumCard(
                  "assets/travel/travelfive.png",
                  "assets/travel/travelsix.png",
                  "assets/travel/traveltwo.png",
                  "assets/travel/travelone.png",
                  "+1288",
                  "The Grand Canyon"),
              SizedBox(
                width: 10 * widthMultiplier,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 3 * heightMultiplier,
        ),
        Padding(
          padding: EdgeInsets.only(left: 30.0, right: 30.0),
          child: Row(
            children: <Widget>[
              Text(
                "Favourite places",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 2.2 * textMultiplier),
              ),
              Spacer(),
              Text(
                "View All",
                style: TextStyle(
                    color: Colors.grey, fontSize: 1.7 * textMultiplier),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 3 * heightMultiplier,
        ),
        Container(
          height: 20 * heightMultiplier,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _favoriteCard("assets/travel/travelfive.png"),
              _favoriteCard("assets/travel/travelthree.png"),
              _favoriteCard("assets/travel/travelfive.png"),
              SizedBox(
                width: 10 * widthMultiplier,
              )
            ],
          ),
        ),
        SizedBox(
          height: 3 * heightMultiplier,
        )
      ],
    );
  }

  Container channelVideosTab(Size size) {
    return Container(
      child: _channelVideos == null
          ? Text('No videos found')
          : _channelVideos!.length == 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(child: Text("No videos uploaded")),
                )
              : FutureBuilder(
                  future: _fetchChannelVideos(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return SingleChildScrollView(
                        child: Column(children: [
                          Container(
                            height: size.height / 1.58,
                            child: ListView.builder(
                                itemCount: snapshot.data.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        margin: const EdgeInsets.all(0.0),
                                        padding: const EdgeInsets.all(0.0),
                                        child: Material(
                                          type: MaterialType.card,
                                          shadowColor:
                                              Theme.of(context).shadowColor,
                                          color: Colors.grey.shade900,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0))),
                                          borderOnForeground: true,
                                          clipBehavior: Clip.none,
                                          child: ListTileTheme(
                                            contentPadding: EdgeInsets.all(0),
                                            dense: true,
                                            // selectedColor: Colors.grey.shade900,
                                            // tileColor: Colors.grey.shade900,
                                            // selectedColor: Colors.grey.shade900,
                                            // horizontalTitleGap: -150.0,
                                            minLeadingWidth: 0,
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
                                                  backgroundColor:
                                                      Colors.grey.shade900),
                                              child: ListTile(
                                                // title: SizedBox(),
                                                // backgroundColor: Colors.grey.shade900,
                                                title: Transform.translate(
                                                  offset: Offset(0, 0.0),
                                                  child: Container(
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width: 2500,
                                                          height:
                                                              size.height / 6,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 5,
                                                                      right: 5),
                                                              width: size.width,
                                                              height: 200,
                                                              child: Stack(
                                                                children: [
                                                                  ColorFiltered(
                                                                    colorFilter:
                                                                        ColorFilter
                                                                            .mode(
                                                                      Colors
                                                                          .black26,
                                                                      BlendMode
                                                                          .darken,
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              size.width * 0.42,
                                                                          height:
                                                                              size.height / 5,
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(numCurveRadius),
                                                                              image: DecorationImage(image: NetworkImage(snapshot.data[index].thumbnail_url == null ? "https://redmoonrecord.co.uk/tech/wp-content/uploads/2019/11/YouTube-thumbnail-size-guide-best-practices-top-examples.png" : snapshot.data[index].thumbnail_url), fit: BoxFit.fill),
                                                                            ),
                                                                            alignment:
                                                                                Alignment.center,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Container(
                                                                        width: size.width *
                                                                            0.43,
                                                                        height:
                                                                            size.height /
                                                                                6,
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.bottomCenter,
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                size.width * 0.07,
                                                                            child:
                                                                                Stack(
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
                                                                      Expanded(
                                                                        child:
                                                                            Container(
                                                                          // height: size.height * 0.19,
                                                                          width: !isCollapsed
                                                                              ? size.width / 4
                                                                              : size.width / 2.5,
                                                                          // color: Colors.black26,
                                                                          // padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                snapshot.data[index].title,
                                                                                style: TextStyle(color: kWhite, fontSize: 18, fontWeight: FontWeight.w300),
                                                                                textAlign: TextAlign.left,
                                                                              ),
                                                                              // SizedBox(
                                                                              //   height: size.height * 0.01,
                                                                              // ),
                                                                              // ImageChip(
                                                                              //     image_url: (snapshot.data[index].uploader_dpurl == '' || snapshot.data[index].uploader_dpurl == null)
                                                                              //         ? 'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png'
                                                                              //         : snapshot.data[index].uploader_dpurl,
                                                                              //     text: snapshot.data[index].uploaded_by),
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
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (context) => AlertDialog(
                                                                                      // title: Text('Result'),
                                                                                      content: Text('Delete ' + snapshot.data[index].title + ' video?'),
                                                                                      actions: [
                                                                                        ElevatedButton(
                                                                                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepOrangeAccent[700])),
                                                                                            onPressed: () async {
                                                                                              UserController ctrl = UserController();
                                                                                              bool? deleted = await ctrl.deleteVideo(snapshot.data[index].id);
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
                                                                                                  message: "Video deleted",
                                                                                                  duration: Duration(seconds: 3),
                                                                                                )..show(context);
                                                                                              }
                                                                                            },
                                                                                            child: Text('Yes')),
                                                                                        ElevatedButton(
                                                                                            onPressed: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            child: Text('No'))
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: Container(
                                                                                  width: size.width / 1.8,
                                                                                  child: Align(
                                                                                    alignment: Alignment.bottomRight,
                                                                                    child: Container(
                                                                                      width: size.width / 5,
                                                                                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.deepOrangeAccent[700],
                                                                                        borderRadius: BorderRadius.circular(15.0),
                                                                                      ),
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Icon(
                                                                                            FlutterIcons.cancel_mco,
                                                                                            color: kWhite,
                                                                                            size: size.height * 0.025,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 6,
                                                                                          ),
                                                                                          Text(
                                                                                            "Delete",
                                                                                            style: TextStyle(color: kWhite),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // tilePadding: EdgeInsets.zero,
                                                trailing: SizedBox(width: 0.0),
                                                // children: <Widget>[
                                                //   Padding(
                                                //     padding: const EdgeInsets.all(8.0),
                                                //     child: Row(
                                                //       children: <Widget>[
                                                //         Text("Herzlich Willkommen"),
                                                //         Spacer(),
                                                //         Icon(Icons.check),
                                                //       ],
                                                //     ),
                                                //   ),
                                                //   Padding(
                                                //     padding: const EdgeInsets.all(8.0),
                                                //     child: Row(
                                                //       children: <Widget>[
                                                //         Text("Das Kursmenu"),
                                                //         Spacer(),
                                                //         Icon(Icons.check),
                                                //       ],
                                                //     ),
                                                //   )
                                                // ],
                                              ),
                                            ),
                                          ),
                                        )),
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
    );
  }

  Container updateProfileTab(Size size) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Form(
        key: _updateProfileFormKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          children: [
            TextInputField(
                value: _channelName,
                lightlayout: true,
                placeholder: "Set Channel Name",
                icondata: FlutterIcons.tv_fea,
                iconsize: 25,
                keyboardtype: TextInputType.text,
                onChanged: (value) {
                  _channelName = value;
                  setState(() {});
                  print(_channelName);
                },
                onSaved: (value) {
                  _channelName = value;
                  setState(() {});
                }),
            SizedBox(
              height: 15.0,
            ),

            Row(
              children: [
                Container(
                  width: size.width / 2.2,
                  child: TextInputField(
                      value: channel!.fb_name,
                      singleLine: true,
                      lightlayout: true,
                      placeholder: "FB Name",
                      placeholderSize: 16,
                      icondata: FlutterIcons.facebook_faw,
                      iconsize: 22,
                      keyboardtype: TextInputType.text,
                      onChanged: (value) {
                        _FBName = value;
                      },
                      onSaved: (value) {
                        _FBName = value;
                      }),
                ),
                SizedBox(width: 19),
                Container(
                  width: size.width / 2.2,
                  child: TextInputField(
                      value: channel!.fb_url,
                      lightlayout: true,
                      singleLine: true,
                      placeholder: "Profile URL",
                      placeholderSize: 16,
                      icondata: FlutterIcons.facebook_faw,
                      iconsize: 22,
                      keyboardtype: TextInputType.text,
                      onChanged: (value) {
                        _FBUrl = value;
                      },
                      onSaved: (value) {
                        _FBUrl = value;
                      }),
                ),
              ],
            ),
            SizedBox(
              height: 15.0,
            ),

            Row(
              children: [
                Container(
                  width: size.width / 2.2,
                  child: TextInputField(
                      value: channel!.instagram_name,
                      lightlayout: true,
                      singleLine: true,
                      placeholder: "IG Name",
                      placeholderSize: 16,
                      icondata: FlutterIcons.instagram_faw,
                      iconsize: 22,
                      keyboardtype: TextInputType.text,
                      onChanged: (value) {
                        _IGName = value;
                      },
                      onSaved: (value) {
                        _IGName = value;
                      }),
                ),
                SizedBox(width: 19),
                Container(
                  width: size.width / 2.2,
                  child: TextInputField(
                      value: channel!.instagram_url,
                      lightlayout: true,
                      singleLine: true,
                      placeholder: "IG URL",
                      placeholderSize: 16,
                      icondata: FlutterIcons.instagram_faw,
                      iconsize: 22,
                      keyboardtype: TextInputType.text,
                      onChanged: (value) {
                        _IGUrl = value;
                      },
                      onSaved: (value) {
                        _IGUrl = value;
                      }),
                ),
              ],
            ),
            SizedBox(
              height: 15.0,
            ),

            TextInputField(
                value: _registerFirstName,
                lightlayout: true,
                placeholder: txtFirstName,
                icondata: Icons.person,
                keyboardtype: TextInputType.text,
                inputValidator: validateRegisterFirstName,
                onChanged: (value) {
                  _registerFirstName = value;
                },
                onSaved: (value) {
                  _registerFirstName = value;
                }),
            SizedBox(
              height: 15.0,
            ),
            TextInputField(
                value: _registerLastName,
                lightlayout: true,
                placeholder: txtLastName,
                icondata: Icons.person,
                keyboardtype: TextInputType.text,
                inputValidator: validateRegisterLastName,
                onChanged: (value) {
                  _registerLastName = value;
                },
                onSaved: (value) {
                  _registerLastName = value;
                }),
            SizedBox(
              height: 15.0,
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.phone_android_outlined,
                          color: kPrimaryColor,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text("Phone Number",
                            style:
                                TextStyle(fontSize: 19, color: kPrimaryColor)),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 8.0, right: 8.0),
                      child: IntlPhoneField(
                        countryCodeTextColor: kPrimaryColor,
                        dropDownArrowColor: kPrimaryColor,
                        autoValidate: false,
                        validator: validateRegisterPhone,
                        initialValue: phoneStr,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor),
                        decoration: InputDecoration(
                          // labelText: 'Phone Number',
                          // border: OutlineInputBorder(
                          //     // borderSide: BorderSide(),
                          //     ),
                          // enabledBorder: OutlineInputBorder(
                          //   borderSide: BorderSide(
                          //       color: Palette.textColor1),
                          //   borderRadius: BorderRadius.all(
                          //       Radius.circular(10.0)),
                          // ),
                          // focusedBorder: OutlineInputBorder(
                          //   borderSide: BorderSide(
                          //       color: Palette.textColor1),
                          //   borderRadius: BorderRadius.all(
                          //       Radius.circular(10.0)),
                          // ),
                          // contentPadding: EdgeInsets.all(10),
                          hintText: '7 - - - - - - - -',
                          hintStyle:
                              TextStyle(fontSize: 18, color: kPrimaryColor),
                        ),
                        initialCountryCode: 'KE',
                        onChanged: (phone) {
                          setState(() {
                            _registerPhoneNo = phone.completeNumber;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // decoration: BoxDecoration(
              //     border:
              //         Border.all(color: Palette.textColor1),
              //     borderRadius: BorderRadius.circular(10)),
            ),

            // _showAgeError
            //     ? SizedBox()
            //     : Divider(
            //         thickness: 1.0,
            //         color: Palette.textColor1,
            //       ),
            SizedBox(
              height: 15.0,
            ),
            // TextInputField(
            //     lightlayout: true,
            //     obsuretext: true,
            //     placeholder: txtPassword,
            //     icondata: MaterialCommunityIcons.lock_outline,
            //     inputValidator: validatePassword,
            //     inputController: _registerPasswordController,
            //     onChanged: (value) {
            //       _registerPasswordConfirmationController.text = '';
            //       _passwordConfirmation = '';
            //       _registerpassword = value;
            //     },
            //     onSaved: (value) {
            //       _registerpassword = value;
            //     }),
            // SizedBox(
            //   height: 15.0,
            // ),
            // Container(
            //     child: Column(
            //       children: [
            //         TextInputField(
            //             enabled: (_registerpassword == null ||
            //                     _registerpassword!.isEmpty)
            //                 ? false
            //                 : true,
            //             lightlayout: true,
            //             obsuretext: true,
            //             placeholder: txtConfirmPassword,
            //             icondata: MaterialCommunityIcons.lock_outline,
            //             inputController:
            //                 _registerPasswordConfirmationController,
            //             onChanged: (value) {
            //               _passwordConfirmation = value;
            //               if (_passwordConfirmation == _registerpassword) {
            //                 _showPasswordsError = false;
            //               }
            //             },
            //             onSaved: (value) {
            //               _passwordConfirmation = value;
            //             }),
            //         _showPasswordsError
            //             ? Text(
            //                 'Password and Confirmation do not match',
            //                 style: TextStyle(color: Colors.redAccent),
            //               )
            //             : SizedBox()
            //       ],
            //     ),
            //     decoration: _showPasswordsError
            //         ? BoxDecoration(
            //             border: Border.all(width: 1, color: Colors.redAccent),
            //             borderRadius: BorderRadius.circular(15))
            //         : BoxDecoration()),
            // SizedBox(
            //   height: 30.0,
            // ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: _updatingDetails
                  ? Container(
                      height: 11 * heightMultiplier,
                      width: 22 * widthMultiplier,
                      child: Transform.scale(
                        scale: 0.5,
                        child: CircularProgressIndicator(
                            strokeWidth: 8.0, color: kActiveColor),
                      ),
                    )
                  : InkWell(
                      onTap: () async {
                        if (_updateProfileFormKey.currentState!.validate()) {
                          setState(() {
                            _updatingDetails = true;
                          });
                          if (_registerpassword != null &&
                              _passwordConfirmation != _registerpassword) {
                            _showPasswordsError = true;
                            setState(() {
                              _updatingDetails = false;
                            });
                          } else {
                            bool isOnline = await checkOnline();
                            if (!isOnline) {
                              setState(() {
                                _updatingDetails = false;
                              });
                              Flushbar(
                                icon: Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                ),
                                backgroundColor: Colors.redAccent,
                                title: "Error",
                                message: "No Internet",
                                duration: Duration(seconds: 3),
                              )..show(context);
                            } else {
                              Loc location = await currentLocation();

                              UserController ctrl = new UserController();

                              String? response = await ctrl.updateUserDetails(
                                  _channelName == null || _channelName == ""
                                      ? ""
                                      : _channelName!.toString(),
                                  _FBName == null || _FBName == ""
                                      ? ""
                                      : _FBName.toString(),
                                  _FBUrl == null || _FBUrl == "" ? "" : _FBUrl!,
                                  _IGName == null || _IGName == ""
                                      ? ""
                                      : _IGName.toString(),
                                  _IGUrl == null || _IGUrl == "" ? "" : _IGUrl!,
                                  _registerFirstName!,
                                  _registerLastName!,
                                  _password == null || _password == ""
                                      ? ""
                                      : _password!,
                                  _registerPhoneNo!,
                                  location);

                              if (response.toString() == 'success') {
                                setState(() {
                                  _updatingDetails = false;
                                });

                                ///update
                                var userDetails = appBox.get("user");
                                userDetails['channel_name'] = _channelName;
                                userDetails['fb_name'] = _FBName;
                                userDetails['fb_url'] = _FBUrl;
                                userDetails['instagram_name'] = _IGName;
                                userDetails['instagram_url'] = _IGUrl;
                                userDetails['first_name'] = _registerFirstName;
                                userDetails['last_name'] = _registerLastName;
                                userDetails['phone_no'] = _registerPhoneNo;
                                appBox.delete('user');
                                appBox.put('user', userDetails);

                                Flushbar(
                                  icon: Icon(
                                    Icons.check_circle_rounded,
                                    color: kPrimaryColor,
                                  ),
                                  backgroundColor: kPrimaryLightColor,
                                  title: "Success",
                                  message: "Details updated successfully",
                                  duration: Duration(seconds: 3),
                                )..show(context);
                              } else {
                                setState(() {
                                  _updatingDetails = false;
                                });
                                Flushbar(
                                  icon: Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  title: "Error",
                                  message: response.toString(),
                                  duration: Duration(seconds: 3),
                                )..show(context);
                              }
                            }
                          }
                        }
                      },
                      child: Container(
                        width: size.width * 0.28,
                        padding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        margin: const EdgeInsets.only(bottom: 4.0),
                        decoration: BoxDecoration(
                          color: kActiveColor,
                          border: Border.all(color: kActiveColor),
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 4.0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FlutterIcons.check_faw5s,
                              color: kBlack,
                              size: size.height * 0.025,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              "UPDATE",
                              style: TextStyle(color: kBlack),
                            ),
                          ],
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }

  Padding tabOption(String page, IconData iconData, Size size) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
        onTap: () {
          setState(() {
            tab = page;
          });
        },
        child: Container(
          // width: size.width * 0.25,

          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          margin: const EdgeInsets.only(bottom: 4.0),
          decoration: BoxDecoration(
            color: tab == page ? kActiveColor : kWhite,
            // border:
            //     Border.all(color: tab == page ? kActiveColor : kPrimaryColor),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: tab == page
                ? [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 4.0,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                iconData,
                color: tab == page ? kBlack : kPrimaryColor,
                size: size.height * 0.025,
              ),
              SizedBox(
                width: 6,
              ),
              Text(
                page,
                style: TextStyle(color: tab == page ? kBlack : kPrimaryColor),
              ),
            ],
          ),
        ),
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

  _myAlbumCard(String asset1, String asset2, String asset3, String asset4,
      String more, String name) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0),
      child: Container(
        height: 37 * heightMultiplier,
        width: 60 * widthMultiplier,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.grey, width: 0.2)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      asset1,
                      height: 27 * imageSizeMultiplier,
                      width: 27 * imageSizeMultiplier,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      asset2,
                      height: 27 * imageSizeMultiplier,
                      width: 27 * imageSizeMultiplier,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 1 * heightMultiplier,
              ),
              Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      asset3,
                      height: 27 * imageSizeMultiplier,
                      width: 27 * imageSizeMultiplier,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Spacer(),
                  Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          asset4,
                          height: 27 * imageSizeMultiplier,
                          width: 27 * imageSizeMultiplier,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        child: Container(
                          height: 27 * imageSizeMultiplier,
                          width: 27 * imageSizeMultiplier,
                          decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Center(
                            child: Text(
                              more,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 2.5 * textMultiplier,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0, top: 2 * heightMultiplier),
                child: Text(
                  name,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 2 * textMultiplier,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _favoriteCard(String s) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Image.asset(
          s,
          height: 20 * heightMultiplier,
          width: 70 * widthMultiplier,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void changeDisplayPicture() async {
    FilePickerResult? _thumbnailSelection =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (_thumbnailSelection != null) {
      PlatformFile file = _thumbnailSelection.files.first;

      String response =
          await uploadFileToS3(File(file.path!), "uploads/images/profile");

      if (response.substring(0, 5) == 'error') {
        setState(() {
          _uploadingImage = false;
        });
        Flushbar(
          icon: Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          backgroundColor: Colors.redAccent,
          title: "Error",
          message: response,
          duration: Duration(seconds: 3),
        )..show(context);
      } else {
        setState(() {
          dp_url = response;
          _uploadingImage = true;
        });

        Loc location = await currentLocation();
        UserController ctrl = new UserController();
        String? update_response = await ctrl.userUpdateDisplayPicture(
            response,
            location.ip,
            location.lat,
            location.lng,
            location.name,
            location.live);

        if (update_response.toString() == 'success') {
          var userDetails = appBox.get("user");
          userDetails['dp_url'] = response;
          appBox.delete('user');
          appBox.put('user', userDetails);
          setState(() {
            _profileImageSection = Container(
              height: 11 * heightMultiplier,
              width: 22 * widthMultiplier,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        response,
                      ))),
            );
            _uploadingImage = false;
          });
          Flushbar(
            icon: Icon(
              Icons.check_circle_rounded,
              color: kPrimaryColor,
            ),
            backgroundColor: kPrimaryLightColor,
            title: "Success",
            message: "Picture updated successfully",
            duration: Duration(seconds: 3),
          )..show(context);
        } else {
          setState(() {
            _uploadingImage = false;
          });
          Flushbar(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            backgroundColor: Colors.redAccent,
            title: "Error",
            message: update_response,
            duration: Duration(seconds: 3),
          )..show(context);
        }
      }
    } else {
      //Image not chosen

    }
  }

  void setUser(int userId) async {
    //   UserController ctrl = UserController();
    //   var res = await ctrl.fetchChannelDetails(userId);
    //   if (res == null) {
    //   } else {
    //     setState(() {
    //       user = res;
    //     });
    //     if (user_id != user.id) {
    //     } else {
    //       setState(() {
    //         dp_url = user.dp_url;
    //         _channelName = user.channel_name;
    //         _displayText = user.channel_name == "" || user.channel_name == null
    //             ? user.first_name + " " + user.last_name
    //             : user.channel_name;
    //         _registerLastName = user.last_name;
    //         _registerFirstName = user.first_name;

    //         if (user.phone_no != null || user.phone_no == '') {
    //           phoneStr = user.phone_no.substring(user.phone_no.length - 9);
    //         }
    //         _registerPhoneNo = phoneStr;
    //       });
    //     }
    //   }
    // }
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

  _fetchChannelVideos() async {
    return _channelVideos;
  }
}

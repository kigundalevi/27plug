import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/controller/add_topic_controller.dart';
import 'package:africanplug/controller/user_controller.dart';
import 'package:africanplug/models/location.dart';
import 'package:africanplug/models/tag.dart';
import 'package:africanplug/op/queries.dart';
import 'package:africanplug/player/upload_player.dart';
import 'package:africanplug/screens/login/login.dart';
import 'package:africanplug/screens/upload/validation.dart';
import 'package:africanplug/screens/videos/videos_screen.dart';
import 'package:africanplug/widgets/app/appbar.dart';
import 'package:africanplug/widgets/button/main_upload_button.dart';
import 'package:africanplug/widgets/button/rounded_button.dart';
import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
import 'package:africanplug/widgets/input/image_input.dart';
import 'package:africanplug/widgets/input/text_field_container.dart';
import 'package:africanplug/widgets/input/text_input_field.dart';
import 'package:africanplug/widgets/loader/custom_loader.dart';
import 'package:africanplug/widgets/menu/main_menu.dart';
import 'package:africanplug/widgets/video/thumbnail_display.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:africanplug/widgets/video/video_list_tile.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:aws_s3/aws_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:thumbnails/thumbnails.dart';
import 'package:video_player/video_player.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:path/path.dart' as Path;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({Key? key}) : super(key: key);

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage>
    with TickerProviderStateMixin {
  bool isCollapsed = true;
  bool collapseFromLeft = true;

  final Duration duration = const Duration(milliseconds: 300);
  late AnimationController _aController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _menuScaleAnimation;
  late Animation<Offset> _slideAnimation;

  final GlobalKey<FormState> _uploadFormKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late bool validate;
  late bool mediaerror;
  // late File _pickedVideo;
  late String pickedVideoUrl;
  String? _title;
  String? _description;
  String _selectedVideoTagsJson = 'No tags';
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // List<VideoTag> _selectedVideoTags = [];

  List<VideoTag> _tags = [];
  List<String> _selectedTags = [];
  late final List<VideoTag> _selectedVideoTags;

  TextEditingController _searchTextEditingController =
      new TextEditingController();

  String get _searchText => _searchTextEditingController.text.trim();

  final List<VideoTag> _tagsToSelect = [
    VideoTag(id: 1, name: 'Entertainment', description: ""),
    VideoTag(id: 2, name: 'Politics', description: ""),
    VideoTag(id: 3, name: 'Business', description: ""),
  ];
  late List selectedvideotags;
  late bool videotagerror;

  PlatformFile? selectedVideo;
  String? selectedVideoPath;
  late bool selectingVideo;
  late bool uploadingNewVideo;

  late bool uploadingNewThumbnail;

  late VideoPlayerController _controller;
  PlatformFile? _selectedThumbnail;
  String? _selectedThumbnailPath;

  bool _selectedVideoError = false;
  bool _selectedThumbnailError = false;
  bool tagging = false;

//S3 FILE UPLOADS
  File? selectedFile;
  SimpleS3 _simpleS3 = SimpleS3();
  bool isLoading = false;
  bool uploaded = false;

  late AwsS3 _awsS3;

  late String uploadedVideoUrl;
  late String uploadedVideoName;
  late String uploadedThumbnailUrl;
  late String uploadedThumbnailName;

  String s3UploadStatus = "Select video first";

  //PLAYAREA
  bool playArea = false;
  bool isPlaying = false;
  bool disposed = false;

  FadeAnimation imageFadeAnim =
      FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
  Widget controlIcon = SizedBox();
  Widget overLay = SizedBox();

  bool _paused = false;
  bool _overlayed = false;
  int currentDurationInSecond = 0;

  late String videoTitle;

  late VideoProgressIndicator progressIndicator;

  final _editNode = FocusNode();
  late ImageFormat _format = ImageFormat.JPEG;
  late int _quality = 50;
  late int _sizeH = 0;
  late int _sizeW = 0;
  late int _timeMs = 0;

  late GenThumbnailImage _futureImage;

  late String _tempDir;

  bool _generatingThumbnail = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
      ..initialize().then((_) {
        setState(() {});
        // _controller.play();
      });

    uploadedVideoUrl = "";
    uploadedThumbnailUrl = "";

    uploadedVideoName = "";
    uploadedThumbnailName = "";

    _aController = AnimationController(duration: duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.85).animate(_aController);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_aController);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_aController);

    validate = false;
    mediaerror = true;
    titleController = new TextEditingController();
    descriptionController = new TextEditingController();
    pickedVideoUrl = "";

    _searchTextEditingController.addListener(() => refreshState(() {}));
    selectedvideotags = [];
    videotagerror = true;
    selectingVideo = false;
    uploadingNewVideo = false;
    uploadingNewThumbnail = false;
    _selectedVideoTags = [];
  }

  @override
  void dispose() {
    selectedVideo = null;
    selectedvideotags.clear();

    _controller.setVolume(0);
    _controller.pause();
    _controller.dispose();
    disposed = true;
    _aController.dispose();

    super.dispose();
    _searchTextEditingController.dispose();
  }

  bool _loading = false;
  bool _autoValidate = false;
  bool _thumnailSelected = false;
  int videoDuration = 0;

  refreshState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  List<VideoTag> _filterSearchResultList() {
    if (_searchText.isEmpty) return _tagsToSelect;

    List<VideoTag> _tempList = [];
    for (int index = 0; index < _tagsToSelect.length; index++) {
      VideoTag videoTag = _tagsToSelect[index];
      if (videoTag.name
          .toLowerCase()
          .trim()
          .contains(_searchText.toLowerCase())) {
        _tempList.add(videoTag);
      }
    }

    return _tempList;
  }

  _addTags(VideoTag) async {
    if (!_tags.contains(VideoTag))
      setState(() {
        _tags.add(VideoTag);
      });
  }

  _removeTag(VideoTag) async {
    if (_tags.contains(VideoTag)) {
      setState(() {
        _tags.remove(VideoTag);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final key = GlobalKey();
    String? current_page = ModalRoute.of(context)?.settings.name;
    final height = MediaQuery.of(context).size.height;
    var inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: BorderRadius.all(
        Radius.circular(30.0),
      ),
    );
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
                      ? const EdgeInsets.only(bottom: 0.0)
                      : const EdgeInsets.only(bottom: 15.0),
                  child: SafeArea(
                    child: Stack(children: [
                      Scaffold(
                        backgroundColor: kScaffoldColor,
                        // appBar: appBar(size, () {
                        //   setState(() {
                        //     collapseFromLeft = true;
                        //     if (isCollapsed)
                        //       _aController.forward();
                        //     else
                        //       _aController.reverse();

                        //     isCollapsed = !isCollapsed;
                        //   });
                        // }, () {}, () {}),
                        body: Column(
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
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideosScreen(),
                                  ),
                                  (route) => false);
                            }, () {
                              // Navigator.pushNamed(context, "/loginRegister");
                            }),
                            selectedVideo != null
                                ? Column(
                                    children: [
                                      // SizedBox(
                                      //   height: 10,
                                      // ),
                                      Stack(
                                        alignment: AlignmentDirectional.topEnd,
                                        children: [
                                          Column(
                                            children: [
                                              // new NetworkPlayerLifeCycle(
                                              //     '$selectedVideoPath',
                                              //     selectedVideo!,
                                              //     (BuildContext context,
                                              //             VideoPlayerController
                                              //                 controller) =>
                                              //         AspectRatioVideo(
                                              //             controller,
                                              //             selectedVideo!,
                                              //             size)),

                                              playView(context),
                                              Container(
                                                  alignment: Alignment.topLeft,
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                      color: kScaffoldColor,
                                                      // borderRadius:
                                                      //     BorderRadius
                                                      //         .circular(15),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.3),
                                                            blurRadius: 15,
                                                            spreadRadius: 6),
                                                      ]),
                                                  child: Text(
                                                      selectedVideo!
                                                                  .name.length >
                                                              100
                                                          ? selectedVideo!.name
                                                              .replaceRange(
                                                                  100,
                                                                  selectedVideo!
                                                                      .name
                                                                      .length,
                                                                  '...')
                                                          : selectedVideo!.name,
                                                      style: TextStyle(
                                                          color: kActiveColor,
                                                          fontSize: 15)))
                                            ],
                                          ),
                                          InkWell(
                                            onTap: _uploadNewVideo,
                                            child: Material(
                                              elevation: 8.0,
                                              color: kPrimaryLightColor
                                                  .withOpacity(0.7),
                                              // borderRadius:
                                              //     BorderRadius.circular(10.0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .swap_horizontal_circle,
                                                      color: kPrimaryColor,
                                                    ),
                                                    Text(
                                                      "",
                                                      style: TextStyle(
                                                          color: kPrimaryColor),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          new Container(
                                            width: size.width,
                                            height: size.height / 3.5,
                                            decoration: BoxDecoration(
                                                color: kScaffoldColor,
                                                border: _selectedVideoError
                                                    ? Border.all(color: kRed)
                                                    : Border.all(width: 0.0)
                                                // image: new DecorationImage(
                                                //   image: new AssetImage(
                                                //       "assets/images/image_placeholder.png"),
                                                //   fit: BoxFit.cover,
                                                // ),
                                                // borderRadius: new BorderRadius.all(
                                                //     new Radius.circular(10.0)),
                                                ),
                                          ),
                                          _selectedVideoError
                                              ? Container(
                                                  color: kWhite,
                                                  width: size.width,
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      "Select a video to upload",
                                                      style: TextStyle(
                                                          color: kRed)),
                                                )
                                              : SizedBox()
                                        ],
                                      ),
                                      Center(
                                        child: selectingVideo
                                            ? CircularProgressIndicator(
                                                color: kActiveColor,
                                              )
                                            : TextButton.icon(
                                                style: TextButton.styleFrom(
                                                  textStyle: TextStyle(
                                                      color: Colors.blue),
                                                  backgroundColor: kActiveColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0),
                                                  ),
                                                ),
                                                icon: Icon(
                                                  FlutterIcons.attach_file_mdi,
                                                  color: kWhite,
                                                ),
                                                label: Text(
                                                  'Select video',
                                                  style:
                                                      TextStyle(color: kBlack),
                                                ),
                                                onPressed: _uploadNewVideo),
                                      ),
                                    ],
                                  ),
                            Container(
                              // height: height - (height / 7),
                              child: Flexible(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 700),
                                  curve: Curves.bounceInOut,
                                  height: size.height,
                                  padding: EdgeInsets.all(10),
                                  // width: MediaQuery.of(context).size.width - 40,
                                  // margin: EdgeInsets.only(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    // borderRadius: BorderRadius.only(
                                    //     bottomLeft:
                                    //         Radius.circular(numCurveRadius),
                                    //     bottomRight:
                                    //         Radius.circular(numCurveRadius)),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //       color:
                                    //           Colors.black.withOpacity(0.3),
                                    //       blurRadius: 15,
                                    //       spreadRadius: 5),
                                    // ]
                                  ),
                                  child: Form(
                                    key: _uploadFormKey,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // SizedBox(
                                          //   height: size.height / 12,
                                          // ),
                                          // Container(
                                          //   color: kBackgroundColor,
                                          //   child: Column(
                                          //     children: [
                                          //       StreamBuilder<dynamic>(
                                          //           stream: _simpleS3
                                          //               .getUploadPercentage,
                                          //           builder:
                                          //               (context, snapshot) {
                                          //             return new Text(
                                          //               snapshot.data != null
                                          //                   ? "Uploaded: ${snapshot.data}"
                                          //                   : "Simple S3",
                                          //             );
                                          //           }),
                                          //       Text(uploadedVideoUrl),
                                          //     ],
                                          //   ),
                                          // ),
                                          TextInputField(
                                              placeholder: "Video Title",
                                              icondata: FlutterIcons.play_faw5s,
                                              iconcolor: kPrimaryLightColor,
                                              iconsize: 20,
                                              keyboardtype: TextInputType.text,
                                              inputValidator:
                                                  validateVideoTitle,
                                              inputController: titleController,
                                              onChanged: (value) {
                                                _title = value;
                                              },
                                              onSaved: (value) {
                                                _title = value;
                                              }),
                                          TextInputField(
                                              placeholder: "Video Description",
                                              icondata: FlutterIcons.play_faw5s,
                                              iconcolor: kPrimaryLightColor,
                                              iconsize: 20,
                                              keyboardtype:
                                                  TextInputType.multiline,
                                              inputValidator:
                                                  validateVideoDescription,
                                              inputController:
                                                  descriptionController,
                                              onChanged: (value) {
                                                _description = value;
                                              },
                                              onSaved: (value) {
                                                _description = value;
                                              }),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              InkWell(
                                                  child: TextInputField(
                                                    placeholder:
                                                        _selectedThumbnail ==
                                                                null
                                                            ? "Select thumbnail (optional)"
                                                            : _selectedThumbnail!
                                                                .name,
                                                    icondata: FlutterIcons
                                                        .file_picture_o_faw,
                                                    iconcolor:
                                                        kPrimaryLightColor,
                                                    iconsize: 20,
                                                    enabled: false,
                                                  ),
                                                  onTap: isLoading
                                                      ? () {}
                                                      : _uploadNewThumbnail),
                                              _selectedThumbnailError
                                                  ? Container(
                                                      color: kWhite,
                                                      width: size.width,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                          "Select video thumbnail",
                                                          style: TextStyle(
                                                              color: kRed)))
                                                  : SizedBox()
                                            ],
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 12.0),
                                            padding: EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: kPrimaryColor
                                                        .withOpacity(0.4)),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            child: FlutterTagging<VideoTag>(
                                              initialItems: _selectedVideoTags,
                                              textFieldConfiguration:
                                                  TextFieldConfiguration(
                                                cursorColor: kPrimaryColor,
                                                decoration: InputDecoration(
                                                  // border: InputBorder.none,
                                                  labelStyle: TextStyle(
                                                      color: kPrimaryColor),

                                                  filled: true,
                                                  // fillColor: kPrimaryLightColor,
                                                  hintText: 'search tag',
                                                  labelText: 'Video tags',
                                                ),
                                              ),
                                              findSuggestions: findVideoTags,
                                              additionCallback: (value) {
                                                setState(() {
                                                  tagging = true;
                                                });
                                                if (value is String &&
                                                    value.length > 0) {
                                                  _selectedTags.add(value);
                                                }
                                                setState(() {
                                                  tagging = false;
                                                });

                                                return VideoTag(
                                                    id: 0,
                                                    name: value,
                                                    description: "");
                                              },
                                              onAdded: (videoTag) async {
                                                // api calls here, triggered when add to tag button is pressed
                                                setState(() {
                                                  tagging = true;
                                                });
                                                bool isOnline =
                                                    await checkOnline();
                                                if (!isOnline) {
                                                  Flushbar(
                                                    icon: Icon(
                                                      Icons.info_outline,
                                                      color: Colors.white,
                                                    ),
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    title: "Error",
                                                    message: "No Internet",
                                                    duration:
                                                        Duration(seconds: 2),
                                                  )..show(context);
                                                  tagging = false;
                                                  return VideoTag(
                                                      id: 0,
                                                      name: "",
                                                      description: "");
                                                } else {
                                                  Loc loc =
                                                      await currentLocation();
                                                  AddTopicController ctrl =
                                                      new AddTopicController();
                                                  var response =
                                                      await ctrl.authAddTopic(
                                                          videoTag.name,
                                                          currentUser().id,
                                                          loc);

                                                  if (response == null) {
                                                    Flushbar(
                                                      icon: Icon(
                                                        Icons.info_outline,
                                                        color: Colors.white,
                                                      ),
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      title: "Error",
                                                      message:
                                                          "Could not add tag, try again later",
                                                      duration:
                                                          Duration(seconds: 2),
                                                    )..show(context);
                                                    tagging = false;
                                                    return VideoTag(
                                                        id: 0,
                                                        name: "",
                                                        description: "");
                                                  } else {
                                                    tagging = false;
                                                    return response;
                                                  }
                                                }
                                              },
                                              configureChip: configureChip,
                                              configureSuggestion: (tag) {
                                                return SuggestionConfiguration(
                                                  splashColor: kActiveColor,
                                                  title: Text(tag.name),
                                                  // subtitle: Text(tag.id.toString()),
                                                  additionWidget: tagging
                                                      ? CircularProgressIndicator(
                                                          color: kActiveColor,
                                                        )
                                                      : Chip(
                                                          avatar: Icon(
                                                            Icons.add_circle,
                                                            color: Colors.white,
                                                          ),
                                                          label: Text(
                                                            'Add New Tag',
                                                            style: TextStyle(
                                                                color: kBlack),
                                                          ),
                                                          labelStyle: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                          backgroundColor:
                                                              kActiveColor,
                                                        ),
                                                );
                                              },
                                            ),
                                            // child: FlutterTagging<VideoTag>(
                                            //     initialItems:
                                            //         _selectedVideoTags,
                                            //     textFieldConfiguration:
                                            //         TextFieldConfiguration(
                                            //       decoration: InputDecoration(
                                            //         border: InputBorder.none,
                                            //         filled: true,
                                            //         fillColor: Colors.green
                                            //             .withAlpha(30),
                                            //         hintText: 'Search Tags',
                                            //         labelText: 'Select Tags',
                                            //       ),
                                            //     ),
                                            //     findSuggestions:
                                            //         TagSearchService
                                            //             .findVideoTags,
                                            //     additionCallback: (value) {
                                            //       return VideoTag(
                                            //           name: value,
                                            //           id: 0,
                                            //           description: "");
                                            //     },
                                            //     onAdded: (language) {
                                            //       // api calls here, triggered when add to tag button is pressed
                                            //       return language;
                                            //     },
                                            //     configureSuggestion: (tag) {
                                            //       return SuggestionConfiguration(
                                            //         title: Text(tag.name),
                                            //         additionWidget: Chip(
                                            //           avatar: Icon(
                                            //             Icons.add_circle,
                                            //             color: Colors.white,
                                            //           ),
                                            //           label:
                                            //               Text('Add New Tag'),
                                            //           labelStyle: TextStyle(
                                            //             color: Colors.white,
                                            //             fontSize: 14.0,
                                            //             fontWeight:
                                            //                 FontWeight.w300,
                                            //           ),
                                            //           backgroundColor:
                                            //               Colors.green,
                                            //         ),
                                            //       );
                                            //     },
                                            //     configureChip: (lang) {
                                            //       return ChipConfiguration(
                                            //         label: Text(lang.name),
                                            //         backgroundColor:
                                            //             Colors.green,
                                            //         labelStyle: TextStyle(
                                            //             color: Colors.white),
                                            //         deleteIconColor:
                                            //             Colors.white,
                                            //       );
                                            //     },
                                            //     onChanged: () {
                                            //       setState(() {});
                                            //     })
                                          ),
                                          SizedBox(height: size.height * 0.03),
                                          _generatingThumbnail
                                              ? customLoader(
                                                  size: size,
                                                  text:
                                                      "Generating thumbnail..")
                                              : isLoading
                                                  ? StreamBuilder<dynamic>(
                                                      stream: _awsS3
                                                          .getUploadStatus,
                                                      builder:
                                                          (context, snapshot) {
                                                        return new CircularPercentIndicator(
                                                          radius: 30.0,
                                                          lineWidth: 8.0,
                                                          animation: false,
                                                          percent: snapshot
                                                                      .data !=
                                                                  null
                                                              ? (snapshot.data /
                                                                          100) >
                                                                      1
                                                                  ? 1
                                                                  : (snapshot
                                                                          .data /
                                                                      100)
                                                              : 0.0,
                                                          center: new Text(
                                                            snapshot.data !=
                                                                    null
                                                                ? "${snapshot.data}%"
                                                                : "0.0%",
                                                            style: new TextStyle(
                                                                // fontWeight:
                                                                //     FontWeight.bold,
                                                                fontSize: 13.0),
                                                          ),
                                                          footer: new Text(
                                                            "Processing..",
                                                            style: new TextStyle(
                                                                color: kBlack,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 17.0),
                                                          ),
                                                          circularStrokeCap:
                                                              CircularStrokeCap
                                                                  .round,
                                                          progressColor:
                                                              kActiveColor,
                                                        );
                                                      })
                                                  : videoDuration > 300000
                                                      ? TextButton.icon(
                                                          style: TextButton
                                                              .styleFrom(
                                                            elevation: 8.0,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        14.0,
                                                                    vertical:
                                                                        8.0),
                                                            textStyle: TextStyle(
                                                                color:
                                                                    kPrimaryColor),
                                                            backgroundColor:
                                                                Colors.red
                                                                    .shade300,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          24.0),
                                                            ),
                                                          ),
                                                          icon: Icon(
                                                            FlutterIcons
                                                                .chat_processing_mco,
                                                            color:
                                                                kPrimaryColor,
                                                          ),
                                                          label: Text(
                                                            'Contact support for long videos',
                                                            style: TextStyle(
                                                                color:
                                                                    kPrimaryColor,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          onPressed:
                                                              () async {})
                                                      : (!_loading
                                                          ? uploadedVideoUrl ==
                                                                  ""
                                                              ? Text(
                                                                  s3UploadStatus)
                                                              : TextButton.icon(
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    elevation:
                                                                        8.0,
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            14.0,
                                                                        vertical:
                                                                            8.0),
                                                                    textStyle: TextStyle(
                                                                        color: Colors
                                                                            .blue),
                                                                    backgroundColor:
                                                                        kActiveColor,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              24.0),
                                                                    ),
                                                                  ),
                                                                  icon: Icon(
                                                                    FlutterIcons
                                                                        .plug_faw5s,
                                                                    color:
                                                                        kWhite,
                                                                  ),
                                                                  label: Text(
                                                                    'Upload',
                                                                    style: TextStyle(
                                                                        color:
                                                                            kBlack,
                                                                        fontSize:
                                                                            17,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    if (uploadedVideoUrl ==
                                                                        "") {
                                                                      setState(
                                                                          () {
                                                                        _selectedVideoError =
                                                                            true;
                                                                      });
                                                                      return;
                                                                    }
                                                                    if (selectedVideo ==
                                                                        null) {
                                                                      setState(
                                                                          () {
                                                                        _selectedVideoError =
                                                                            true;
                                                                      });
                                                                      return;
                                                                    }
                                                                    if (_selectedThumbnail ==
                                                                            null ||
                                                                        uploadedThumbnailUrl ==
                                                                            "") {
                                                                      // setState(() {
                                                                      //   _selectedThumbnailError =
                                                                      //       true;
                                                                      // });
                                                                      // return;

                                                                    }
                                                                    bool
                                                                        isOnline =
                                                                        await checkOnline();
                                                                    if (!isOnline) {
                                                                      Flushbar(
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .info_outline,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        backgroundColor:
                                                                            Colors.redAccent,
                                                                        title:
                                                                            "Error",
                                                                        message:
                                                                            "No Internet",
                                                                        duration:
                                                                            Duration(seconds: 3),
                                                                      )..show(
                                                                          context);
                                                                    } else {
                                                                      /// POST FUNCTIONALITY
                                                                      if (_uploadFormKey
                                                                          .currentState!
                                                                          .validate()) {
                                                                        setState(
                                                                            () {
                                                                          _loading =
                                                                              true;
                                                                        });
                                                                        Loc location =
                                                                            await currentLocation();
                                                                        UserController
                                                                            ctrl =
                                                                            new UserController();
                                                                        print(
                                                                            "uploading");
                                                                        String? upload_response = await ctrl.userUploadVideo(
                                                                            _selectedTags,
                                                                            uploadedVideoUrl,
                                                                            uploadedVideoName,
                                                                            uploadedThumbnailUrl,
                                                                            uploadedThumbnailName,
                                                                            _title!,
                                                                            _description!,
                                                                            videoDuration,
                                                                            location.ip,
                                                                            location.lat,
                                                                            location.lng,
                                                                            location.name,
                                                                            location.live);

                                                                        if (upload_response.toString() ==
                                                                            'success') {
                                                                          setState(
                                                                              () {
                                                                            _loading =
                                                                                false;
                                                                          });
                                                                          Flushbar(
                                                                            isDismissible:
                                                                                false,
                                                                            icon:
                                                                                Icon(
                                                                              Icons.check_circle_rounded,
                                                                              color: kPrimaryColor,
                                                                            ),
                                                                            backgroundColor:
                                                                                kPrimaryLightColor,
                                                                            title:
                                                                                "Success",
                                                                            message:
                                                                                "Video uploaded successfully",
                                                                            duration:
                                                                                Duration(seconds: 3),
                                                                          )..show(
                                                                              context);
                                                                          Navigator.pushAndRemoveUntil(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => VideosScreen(),
                                                                              ),
                                                                              (route) => false);
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            _loading =
                                                                                false;
                                                                          });
                                                                          Flushbar(
                                                                            icon:
                                                                                Icon(
                                                                              Icons.info_outline,
                                                                              color: Colors.white,
                                                                            ),
                                                                            backgroundColor:
                                                                                Colors.redAccent,
                                                                            title:
                                                                                "Error",
                                                                            message:
                                                                                upload_response.toString(),
                                                                            duration:
                                                                                Duration(seconds: 3),
                                                                          )..show(
                                                                              context);
                                                                        }
                                                                      }
                                                                    }
                                                                  })
                                                          : Center(
                                                              child: Column(
                                                                children: [
                                                                  CircularProgressIndicator(
                                                                    color:
                                                                        kActiveColor,
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        10.0,
                                                                  ),
                                                                  Text(
                                                                      "  Uploading..",
                                                                      style: TextStyle(
                                                                          color:
                                                                              kBlack,
                                                                          fontSize:
                                                                              17))
                                                                ],
                                                              ),
                                                            )),
                                          SizedBox(height: size.height * 0.05)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // appBar(size, () {
                      //   setState(() {
                      //     collapseFromLeft = true;
                      //     if (isCollapsed)
                      //       _aController.forward();
                      //     else
                      //       _aController.reverse();

                      //     isCollapsed = !isCollapsed;
                      //   });
                      // })
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ]));
  }

  Widget playView(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return Container(
        // margin: EdgeInsets.only(top: size.height / 12),
        height: 240,
        width: double.infinity,
        color: kBlack,
        child: Stack(
          children: [
            // Container(
            //     width: size.width,
            //     color: kRed,
            //     child: Center(
            //       child: Transform.scale(
            //         scale: getScale(),
            //         child: AspectRatio(
            //           aspectRatio: controller.value.aspectRatio,
            //           child: VideoPlayer(controller),
            //         ),
            //       ),
            //     )),
            GestureDetector(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      height: controller.value.size.height,
                      width: controller.value.size.width,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
                onTap: () {
                  if (!controller.value.isInitialized) {
                    return;
                  }
                  if (controller.value.isPlaying) {
                    controller.pause();
                    _paused = true;
                    setState(() {});
                    imageFadeAnim = FadeAnimation(
                        child: const Icon(Icons.pause, size: 100.0));

                    // controller.pause();
                    // controlIcon = ;
                    overLay = Container(
                      height: 240,
                      color: Colors.black38,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  videoTitle.length > 25
                                      ? videoTitle.replaceRange(
                                          25, videoTitle.length, '...')
                                      : videoTitle,
                                  style: TextStyle(color: kWhite, fontSize: 15),
                                ),
                                OutlinedButton(
                                  child: Icon(Icons.more_horiz),
                                  style: OutlinedButton.styleFrom(
                                    primary: kWhite,
                                    side: BorderSide(
                                        width: 0, color: Colors.black12),
                                    shape: CircleBorder(),
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ),
                            Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FlutterIcons.skip_previous_mdi,
                                    color: kWhite,
                                    size: 45.0,
                                  ),
                                  SizedBox(
                                    width: 30.0,
                                  ),
                                  _paused
                                      ? InkWell(
                                          child: Icon(FlutterIcons.play_faw5s,
                                              color: kWhite, size: 55.0),
                                          onTap: () {
                                            controlIcon = SizedBox();
                                            overLay = SizedBox();

                                            controller.play();
                                            _paused = false;
                                            setState(() {});
                                          },
                                        )
                                      : InkWell(
                                          child: Icon(FlutterIcons.pause_faw5s,
                                              size: 80.0),
                                          onTap: () {
                                            controlIcon = SizedBox();
                                            overLay = SizedBox();
                                            controller.pause();
                                            _paused = true;
                                            setState(() {});
                                          },
                                        ),
                                  SizedBox(
                                    width: 30.0,
                                  ),
                                  Icon(
                                    FlutterIcons.skip_next_mdi,
                                    color: kWhite,
                                    size: 45.0,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedTime(currentDurationInSecond) +
                                      ' / ' +
                                      formattedTime(
                                          controller.value.duration.inSeconds),
                                  style: TextStyle(
                                    color: kWhite, fontSize: 15,
                                    // color: kWhite,
                                    // fontSize: 15,
                                    // fontWeight: FontWeight.w700,
                                  ),
                                ),
                                OutlinedButton(
                                  child: Icon(FlutterIcons.fullscreen_mco),
                                  style: OutlinedButton.styleFrom(
                                    primary: kWhite,
                                    side: BorderSide(
                                        width: 0, color: Colors.black12),
                                    shape: CircleBorder(),
                                  ),
                                  onPressed: () {},
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    _paused = false;
                    overLay = SizedBox();

                    controller.play();
                    imageFadeAnim = FadeAnimation(
                        child:
                            const Icon(FlutterIcons.play_faw5s, size: 100.0));
                    setState(() {});
                  }
                }),
            Align(
              alignment: Alignment.bottomCenter,
              child: progressIndicator,
            ),
            Center(child: imageFadeAnim),
            Center(
                child: Material(
                    elevation: 8.0,
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(10.0),
                    child: controlIcon)),
            Center(
                child: controller.value.isBuffering
                    ? const CircularProgressIndicator(color: kPrimaryColor)
                    : null),
            overLay
          ],
        ),
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

  Widget uploadHeader() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(height: 10.0),
          Text(
            "Upload video",
            style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16.0),
          ),
          SizedBox(height: 5.0),
        ],
      );

  void _pickVideo() {}

  Widget _buildSuggestionWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_filterSearchResultList().length != _tags.length) Text('Suggestions'),
      Wrap(
        alignment: WrapAlignment.start,
        children: _filterSearchResultList()
            .where((videoTag) => !_tags.contains(videoTag))
            .map((videoTag) => tagChip(
                  videoTag: videoTag,
                  onTap: () => _addTags(videoTag),
                  action: 'Add',
                ))
            .toList(),
      ),
    ]);
  }

  _displayTagWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _filterSearchResultList().isNotEmpty
          ? _buildSuggestionWidget()
          : Text('No Labels added'),
    );
  }

  Widget tagChip({videoTag, onTap, action, added = false}) {
    return InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 5.0,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryLightColor,
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Text(
                  '${videoTag.name}',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: added
                  ? CircleAvatar(
                      backgroundColor: kPrimaryColor,
                      radius: 8.0,
                      child: Icon(
                        Icons.remove,
                        size: 10.0,
                        color: Colors.white,
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: kPrimaryColor,
                      radius: 8.0,
                      child: Icon(
                        Icons.add,
                        size: 10.0,
                        color: Colors.white,
                      ),
                    ),
            )
          ],
        ));
  }

  Widget _buildSearchFieldWidget() {
    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        top: 10.0,
        bottom: 10.0,
      ),
      margin: EdgeInsets.only(
        // left: 20.0,
        // right: 20.0,
        top: 5.0,
        bottom: 5.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
        border: Border.all(
          color: Colors.grey.shade500,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchTextEditingController,
              decoration: InputDecoration.collapsed(
                hintText: 'Search Tag',
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
              ),
              style: TextStyle(
                fontSize: 16.0,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          _searchText.isNotEmpty
              ? InkWell(
                  child: Icon(
                    Icons.clear,
                    color: Colors.grey.shade700,
                  ),
                  onTap: () => _searchTextEditingController.clear(),
                )
              : Icon(
                  Icons.search,
                  color: Colors.grey.shade700,
                ),
          Container(),
        ],
      ),
    );
  }

  Widget _tagsWidget() {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Video tags',
              style: TextStyle(
                fontSize: 15.0,
                color: kPrimaryColor,
              ),
            ),
            _tags.length > 0
                ? Column(children: [
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: _tags
                          .map((videoTag) => tagChip(
                                videoTag: videoTag,
                                onTap: () => _removeTag(videoTag),
                                action: 'Remove',
                              ))
                          .toSet()
                          .toList(),
                    ),
                  ])
                : Container(),
            _buildSearchFieldWidget(),
            _displayTagWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        color: kPrimaryColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.add,
            color: Colors.white,
            size: 15.0,
          ),
          Text(
            "Add New Tag",
            style: TextStyle(color: Colors.white, fontSize: 14.0),
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

  ChipConfiguration configureChip(VideoTag tag) {
    return ChipConfiguration(
        label: Text(
          tag.name,
          style: TextStyle(color: kPrimaryColor),
        ),
        backgroundColor: kPrimaryLightColor,
        deleteIconColor: kPrimaryColor);
  }

  Future<String?> _uploadVideoToS3(PlatformFile file) async {
    String? result;

    if (result == null) {
      s3UploadStatus = "Starting upload";

      try {
        setState(() {
          uploadingNewVideo = true;
        });
        File _file = File(file.path!);
        final _extension = Path.extension(_file.path);
        String fileName = Path.basenameWithoutExtension(_file.path) +
            "_" +
            DateTime.now().millisecondsSinceEpoch.toString() +
            _extension;

        // result = await _simpleS3.uploadFile(
        //   File(file.path!),
        //   kS3BucketName,
        //   kS3PoolID,
        //   AWSRegions.euWest3,
        //   debugLog: true,
        //   s3FolderPath: "uploads/videos",
        //   accessControl: S3AccessControl.publicRead,
        //   useTimeStamp: true,
        // );

        AwsS3 awsS3 = AwsS3(
            awsFolderPath: "uploads/videos",
            file: _file,
            fileNameWithExt: fileName,
            poolId: kS3PoolID,
            region: Regions.EU_WEST_3,
            bucketName: kS3BucketName);
        setState(() {
          _awsS3 = awsS3;
        });

        try {
          try {
            result = await awsS3.uploadFile;
            print(result);

            var appDocDir = await getApplicationDocumentsDirectory();
            final folderPath = appDocDir.path;
            setState(() {
              _generatingThumbnail = true;
            });
            String thumbnail = await Thumbnails.getThumbnail(
                thumbnailFolder: folderPath, 
                imageType: ThumbFormat
                    .PNG, //this image will store in created folderpath
                quality: 30);
            setState(() {
              _generatingThumbnail = false;
            });
            _uploadThumbnailToS3(File(thumbnail));
            // _image.image
            //     .resolve(ImageConfiguration())
            //     .addListener(ImageStreamListener((ImageInfo info, bool _) {
            //   completer.complete(ThumbnailResult(
            //     image: _image,
            //     dataSize: _imageDataSize,
            //     height: info.image.height,
            //     width: info.image.width,
            //   ));
            // }));

            setState(() {
              uploaded = true;
              uploadedVideoUrl = VIDEOS_ROOT_URL + result!;
              isLoading = false;
            });
          } on PlatformException {
            debugPrint("Result :'$result'.");
            s3UploadStatus = "Result :'$result'.";
            setState(() {
              uploadingNewVideo = false;
              isLoading = false;
            });
          }
        } on PlatformException catch (e) {
          debugPrint("Failed :'${e.message}'.");
          s3UploadStatus = "Failed :'${e.message}'.";
          setState(() {
            uploadingNewVideo = false;
            isLoading = false;
          });
        }
      } catch (e) {
        print('---VIDEO UPLOAD ERROR---');
        print(e);

        s3UploadStatus = "ERROR: " + e.toString();

        setState(() {
          uploadingNewVideo = false;
          isLoading = false;
        });
      }
    }
    return result;
  }

  Future<String?> _uploadThumbnailToS3(File file) async {
    String? result;

    if (result == null) {
      try {
        setState(() {
          uploadingNewThumbnail = true;
        });
        result = await _simpleS3.uploadFile(
          file,
          kS3BucketName,
          kS3PoolID,
          AWSRegions.euWest3,
          debugLog: true,
          s3FolderPath: "uploads/thumbnails",
          accessControl: S3AccessControl.publicRead,
          useTimeStamp: true,
        );

        setState(() {
          uploaded = true;
          uploadedThumbnailUrl = result!;
          isLoading = false;
        });
      } catch (e) {
        print(e);
        setState(() {
          uploadingNewThumbnail = false;
          isLoading = false;
        });
      }
    }
    return result;
  }

  void _uploadNewThumbnail() async {
    setState(() {
      _thumnailSelected = true;
    });
    FilePickerResult? _thumbnailSelection =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (_thumbnailSelection != null) {
      PlatformFile file = _thumbnailSelection.files.first;

      setState(() {
        _selectedThumbnailPath = file.path;
        _selectedThumbnail = _thumbnailSelection.files.first;
        uploadedThumbnailName = file.name;
      });

      _uploadThumbnailToS3(File(file.path!));
      _selectedThumbnailError = false;
    } else {
      setState(() {
        _selectedThumbnailError = true;
      });
      //TODO:Snackbarshoww error
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

  void _uploadNewVideo() async {
    bool isOnline = await checkOnline();
    if (!isOnline) {
      Flushbar(
        icon: Icon(
          Icons.info_outline,
          color: Colors.white,
        ),
        backgroundColor: Colors.redAccent,
        title: "Error",
        message: "No Internet",
        duration: Duration(seconds: 2),
      )..show(context);
    } else {
      setState(() {
        selectedVideo = null;
      });
      setState(() {
        // selectedVideo == null
        //     ? ""
        //     : selectedVideo = null;

        selectingVideo = true;
      });
      FilePickerResult? videoPicked =
          await FilePicker.platform.pickFiles(type: FileType.video);
      if (videoPicked != null) {
        PlatformFile file = videoPicked.files.first;

        // await controller.initialize();

        VideoPlayerController controller =
            new VideoPlayerController.network(file.path!);
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

              setState(() {
                playArea = true;
                isPlaying = true;
              });
            });
        });

        setState(() {
          selectedVideoPath = file.path;
          selectedVideo = videoPicked.files.first;
          videoDuration = controller.value.duration.inMilliseconds;
          selectingVideo = false;
        });

        // print("VIDEO DURATION " + videoDuration.toString());
        // String out = firstInput.replaceAll(".", "");
        // print(file.name);
        // print(file.bytes);
        // print(file.size);
        // print(file.extension);
        // print(file.path);

        if (videoDuration > 300000) {
          Flushbar(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            backgroundColor: Colors.redAccent,
            title: "Video too long",
            message: "Contact support for videos longer than 5 min",
            mainButton: TextButton.icon(
                style: TextButton.styleFrom(
                  elevation: 8.0,
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                  textStyle: TextStyle(color: kPrimaryColor),
                  backgroundColor: Colors.red.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
                icon: Icon(
                  FlutterIcons.chat_processing_mco,
                  color: kPrimaryColor,
                ),
                label: Text(
                  'Contact',
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () async {}),
            duration: Duration(seconds: 6),
          )..show(context);
        } else {
          setState(() {
            uploadedVideoName = file.name;
            uploadingNewVideo = true;
            isLoading = true;
          });
          _uploadVideoToS3(file);

//

          /////////
        }

        setState(() {});
      } else {
        setState(() {
          selectingVideo = false;
        });
        //TODO:Snackbarshoww error
      }
    }
  }
}

Future<List<VideoTag>> findVideoTags(String query) async {
  List<VideoTag> _allTags = [];

  GraphQLConfiguration graphQLConfig = new GraphQLConfiguration();
  // GraphQLClient _client = GraphQLClient(
  //   cache: GraphQLCache(store: HiveStore()),
  //   link: HttpLink("https://plug27.herokuapp.com/graphq"),
  // );
  // ;
  Queries queries = Queries();
  QueryResult result = await GraphQLClient(
    cache: GraphQLCache(),
    link: HttpLink("https://plug27.herokuapp.com/graphq"),
  ).query(QueryOptions(document: gql("""
    query{
          listTopic(sortField:"created_at",order:"desc"){
            id,
            name,
            description
          }
        }
""")));
  try {
    print(result);
    if (result.hasException) {
      print(result);
      try {
        OperationException? registerexception = result.exception;
        List<GraphQLError>? errors = registerexception?.graphqlErrors;
        String main_error = errors![0].message;
        return [];
      } catch (error) {
        return [];
      }
    } else {
      var tags = result.data?['listTopic'];
      tags.forEach((tag) {
        _allTags.add(VideoTag(
            id: int.parse(tag['id']),
            name: tag['name'],
            description: tag['description']));
      });

      return _allTags
          .where((tag) => tag.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  } catch (e) {
    print(e);
    return [];
  }
}

class TagSearchService {
  static Future<List<VideoTag>> findVideoTags(String query) async {
    List<VideoTag> _allTags = [];

    GraphQLConfiguration graphQLConfig = new GraphQLConfiguration();
    GraphQLClient _client = GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: HttpLink(REGISTER_URL),
    );
    ;
    Queries queries = Queries();
    print(_client.link);
    QueryResult result = await _client.query(QueryOptions(document: gql("""
    query{
          listTopic(sortField:"created_at",order:"desc"){
            id,
            name,
            description
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
          return [];
        } catch (error) {
          return [];
        }
      } else {
        var tags = result.data?['listTopic'];
        tags.forEach((tag) {
          _allTags.add(VideoTag(
              id: int.parse(tag['id']),
              name: tag['name'],
              description: tag['description']));
        });

        return _allTags
            .where(
                (tag) => tag.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
  // Future<List<VideoTag>> getVideoTagSuggestions(String query) async {
  //   List locations = await _getVideoTags();
  //   List<VideoTag> tagList = <VideoTag>[];
  //   // print("_______________________________________________________________________locations____________________________________________________________");
  //   // print(locations);
  //   for (var doc in locations) {
  //     tagList.add(VideoTag(id: 5, name: "Sports", description: ""));
  //   }
  //   // tagList.add({'name': "Flutter", 'value': 1});
  //   List<VideoTag> filteredTagList = <VideoTag>[];
  //   if (query.isNotEmpty) {
  //     filteredTagList.add(VideoTag(id: 6, name: "Technology", description: ""));
  //   }
  //   for (var tag in tagList) {
  //     if (tag.name.toLowerCase().contains(query)) {
  //       filteredTagList.add(tag);
  //     }
  //   }
  //   return filteredTagList;
  // }
}

class ThumbnailRequest {
  final String video;
  final String? thumbnailPath;
  final ImageFormat imageFormat;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;

  const ThumbnailRequest(
      {required this.video,
      this.thumbnailPath = null,
      required this.imageFormat,
      required this.maxHeight,
      required this.maxWidth,
      required this.timeMs,
      required this.quality});
}

class ThumbnailResult {
  final Image image;
  final int dataSize;
  final int height;
  final int width;
  const ThumbnailResult(
      {required this.image,
      required this.dataSize,
      required this.height,
      required this.width});
}

Future<ThumbnailResult> genThumbnail(ThumbnailRequest r) async {
  //WidgetsFlutterBinding.ensureInitialized();
  Uint8List? bytes;
  final Completer<ThumbnailResult> completer = Completer();
  if (r.thumbnailPath != null) {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: r.video,
        thumbnailPath: r.thumbnailPath,
        imageFormat: r.imageFormat,
        maxHeight: r.maxHeight,
        maxWidth: r.maxWidth,
        timeMs: r.timeMs,
        quality: r.quality);

    print("thumbnail file is located: $thumbnailPath");

    final file = File(thumbnailPath!);
    bytes = file.readAsBytesSync();
  } else {
    bytes = await VideoThumbnail.thumbnailData(
        video: r.video,
        imageFormat: r.imageFormat,
        maxHeight: r.maxHeight,
        maxWidth: r.maxWidth,
        timeMs: r.timeMs,
        quality: r.quality);
  }

  int _imageDataSize = bytes!.length;
  print("image size: $_imageDataSize");

  final _image = Image.memory(bytes);
  _image.image
      .resolve(ImageConfiguration())
      .addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(ThumbnailResult(
      image: _image,
      dataSize: _imageDataSize,
      height: info.image.height,
      width: info.image.width,
    ));
  }));
  return completer.future;
}

class GenThumbnailImage extends StatefulWidget {
  final ThumbnailRequest thumbnailRequest;

  const GenThumbnailImage({required Key key, required this.thumbnailRequest})
      : super(key: key);

  @override
  _GenThumbnailImageState createState() => _GenThumbnailImageState();
}

class _GenThumbnailImageState extends State<GenThumbnailImage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThumbnailResult>(
      future: genThumbnail(widget.thumbnailRequest),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final _image = snapshot.data.image;
          final _width = snapshot.data.width;
          final _height = snapshot.data.height;
          final _dataSize = snapshot.data.dataSize;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                    "Image ${widget.thumbnailRequest.thumbnailPath == null ? 'data size' : 'file size'}: $_dataSize, width:$_width, height:$_height"),
              ),
              Container(
                color: Colors.grey,
                height: 1.0,
              ),
              _image,
            ],
          );
        } else if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.red,
            child: Text(
              "Error:\n${snapshot.error.toString()}",
            ),
          );
        } else {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                    "Generating the thumbnail for: ${widget.thumbnailRequest.video}..."),
                SizedBox(
                  height: 10.0,
                ),
                CircularProgressIndicator(),
              ]);
        }
      },
    );
  }
}

class ImageInFile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

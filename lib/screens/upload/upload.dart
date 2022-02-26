import 'dart:io';
import 'dart:ui';
import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/controller/add_topic_controller.dart';
import 'package:africanplug/controller/upload_video_controller.dart';
import 'package:africanplug/models/location.dart';
import 'package:africanplug/models/tag.dart';
import 'package:africanplug/op/queries.dart';
import 'package:africanplug/player/upload_player.dart';
import 'package:africanplug/screens/login/login.dart';
import 'package:africanplug/screens/upload/validation.dart';
import 'package:africanplug/widgets/app/appbar.dart';
import 'package:africanplug/widgets/button/main_upload_button.dart';
import 'package:africanplug/widgets/button/rounded_button.dart';
import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
import 'package:africanplug/widgets/input/image_input.dart';
import 'package:africanplug/widgets/input/text_field_container.dart';
import 'package:africanplug/widgets/input/text_input_field.dart';
import 'package:africanplug/widgets/menu/main_menu.dart';
import 'package:africanplug/widgets/video/thumbnail_display.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:africanplug/widgets/video/video_tile.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:video_player/video_player.dart';

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

  late VideoPlayerController _controller;
  PlatformFile? _selectedThumbnail;
  String? _selectedThumbnailPath;

  bool _selectedVideoError = false;
  bool _selectedThumbnailError = false;
  @override
  void initState() {
    super.initState();

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

    _selectedVideoTags = [];
  }

  @override
  void dispose() {
    selectedvideotags.clear();
    super.dispose();
    _searchTextEditingController.dispose();
  }

  bool _loading = false;
  bool _autoValidate = false;
  bool _thumnailSelected = false;

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
        floatingActionButton:
            current_page != "/upload" ? MainUploadButton() : SizedBox(),
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
                borderRadius: BorderRadius.all(Radius.circular(20)),
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
                            appBar(
                                size,
                                () {
                                  setState(() {
                                    collapseFromLeft = true;
                                    if (isCollapsed)
                                      _aController.forward();
                                    else
                                      _aController.reverse();

                                    isCollapsed = !isCollapsed;
                                  });
                                },
                                () {},
                                () {
                                  Navigator.pushNamed(
                                      context, "/loginRegister");
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
                                              new NetworkPlayerLifeCycle(
                                                  '$selectedVideoPath',
                                                  selectedVideo!, // with the String dirPath I have error but if I use the same path but write like this  /data/user/0/com.XXXXX.flutter_video_test/app_flutter/Movies/2019-11-08.mp4 it's ok ... why ?
                                                  (BuildContext context,
                                                          VideoPlayerController
                                                              controller) =>
                                                      AspectRatioVideo(
                                                          controller,
                                                          selectedVideo!,
                                                          size)),
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
                                            onTap: () async {
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
                                                  await FilePicker.platform
                                                      .pickFiles(
                                                          type: FileType.video);
                                              if (videoPicked != null) {
                                                PlatformFile file =
                                                    videoPicked.files.first;

                                                setState(() {
                                                  selectedVideoPath = file.path;
                                                  selectedVideo =
                                                      videoPicked.files.first;
                                                });
                                                // String out = firstInput.replaceAll(".", "");
                                                // print(file.name);
                                                // print(file.bytes);
                                                // print(file.size);
                                                // print(file.extension);
                                                // print(file.path);
                                                setState(() {
                                                  selectingVideo = false;
                                                });
                                              } else {
                                                setState(() {
                                                  selectingVideo = false;
                                                });
                                                //TODO:Snackbarshoww error
                                              }
                                            },
                                            child: Material(
                                              elevation: 8.0,
                                              color: kPrimaryLightColor
                                                  .withOpacity(0.7),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
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
                                                onPressed: () async {
                                                  setState(() {
                                                    selectingVideo = true;
                                                  });
                                                  FilePickerResult?
                                                      videoPicked =
                                                      await FilePicker.platform
                                                          .pickFiles(
                                                              type: FileType
                                                                  .video);
                                                  if (videoPicked != null) {
                                                    PlatformFile file =
                                                        videoPicked.files.first;

                                                    setState(() {
                                                      selectedVideoPath =
                                                          file.path;
                                                      selectedVideo =
                                                          videoPicked
                                                              .files.first;
                                                    });
                                                    _selectedVideoError = false;
                                                    // print(file.name);
                                                    // print(file.bytes);
                                                    // print(file.size);
                                                    // print(file.extension);
                                                    // print(file.path);
                                                    setState(() {
                                                      selectingVideo = false;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _selectedVideoError =
                                                          true;
                                                      selectingVideo = false;
                                                    });
                                                    //TODO:Snackbarshoww error
                                                  }
                                                }),
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
                                    borderRadius: BorderRadius.only(
                                        bottomLeft:
                                            Radius.circular(numCurveRadius),
                                        bottomRight:
                                            Radius.circular(numCurveRadius)),
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
                                                            ? "Select thumbnail"
                                                            : _selectedThumbnail!
                                                                .name,
                                                    icondata: FlutterIcons
                                                        .file_picture_o_faw,
                                                    iconcolor:
                                                        kPrimaryLightColor,
                                                    iconsize: 20,
                                                    enabled: false,
                                                  ),
                                                  onTap: () async {
                                                    setState(() {
                                                      _thumnailSelected = true;
                                                    });
                                                    FilePickerResult?
                                                        _thumbnailSelection =
                                                        await FilePicker
                                                            .platform
                                                            .pickFiles(
                                                                type: FileType
                                                                    .image);
                                                    if (_thumbnailSelection !=
                                                        null) {
                                                      PlatformFile file =
                                                          _thumbnailSelection
                                                              .files.first;

                                                      setState(() {
                                                        _selectedThumbnailPath =
                                                            file.path;
                                                        _selectedThumbnail =
                                                            _thumbnailSelection
                                                                .files.first;
                                                      });
                                                      _selectedThumbnailError =
                                                          false;
                                                    } else {
                                                      setState(() {
                                                        _selectedThumbnailError =
                                                            true;
                                                      });
                                                      //TODO:Snackbarshoww error
                                                    }
                                                  }),
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
                                                if (value is String &&
                                                    value.length > 0) {
                                                  _selectedTags.add(value);
                                                }

                                                return VideoTag(
                                                    id: 0,
                                                    name: value,
                                                    description: "");
                                              },
                                              onAdded: (videoTag) async {
                                                // api calls here, triggered when add to tag button is pressed
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
                                                    return VideoTag(
                                                        id: 0,
                                                        name: "",
                                                        description: "");
                                                  } else {
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
                                                  additionWidget: Chip(
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
                                          !_loading
                                              ? TextButton.icon(
                                                  style: TextButton.styleFrom(
                                                    elevation: 8.0,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 14.0,
                                                            vertical: 8.0),
                                                    textStyle: TextStyle(
                                                        color: Colors.blue),
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
                                                    FlutterIcons.plug_faw5s,
                                                    color: kWhite,
                                                  ),
                                                  label: Text(
                                                    'Upload',
                                                    style: TextStyle(
                                                        color: kBlack,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  onPressed: () async {
                                                    if (selectedVideo == null) {
                                                      setState(() {
                                                        _selectedVideoError =
                                                            true;
                                                      });
                                                      return;
                                                    }
                                                    if (_selectedThumbnail ==
                                                        null) {
                                                      setState(() {
                                                        _selectedThumbnailError =
                                                            true;
                                                      });
                                                      return;
                                                    }
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
                                                        duration: Duration(
                                                            seconds: 3),
                                                      )..show(context);
                                                    } else {
                                                      /// POST FUNCTIONALITY
                                                      if (_uploadFormKey
                                                          .currentState!
                                                          .validate()) {
                                                        setState(() {
                                                          _loading = true;
                                                        });
                                                        Loc location =
                                                            await currentLocation();
                                                        UploadVideoController
                                                            ctrl =
                                                            new UploadVideoController();
                                                        print("uploading");
                                                        String?
                                                            upload_response =
                                                            await ctrl.userUploadVideo(
                                                                _selectedTags,
                                                                selectedVideo!,
                                                                _selectedThumbnail!,
                                                                _title!,
                                                                _description!,
                                                                location.ip,
                                                                location.lat,
                                                                location.lng,
                                                                location.name,
                                                                location.live);

                                                        if (upload_response
                                                                .toString() ==
                                                            'success') {
                                                          setState(() {
                                                            _loading = false;
                                                          });
                                                          Flushbar(
                                                            isDismissible:
                                                                false,
                                                            icon: Icon(
                                                              Icons
                                                                  .check_circle_rounded,
                                                              color:
                                                                  kPrimaryColor,
                                                            ),
                                                            backgroundColor:
                                                                kPrimaryLightColor,
                                                            title: "Success",
                                                            message:
                                                                "Video uploaded successfully",
                                                            duration: Duration(
                                                                seconds: 3),
                                                          )..show(context);
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pushNamed(
                                                              context, "/home");
                                                        } else {
                                                          setState(() {
                                                            _loading = false;
                                                          });
                                                          Flushbar(
                                                            icon: Icon(
                                                              Icons
                                                                  .info_outline,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            backgroundColor:
                                                                Colors
                                                                    .redAccent,
                                                            title: "Error",
                                                            message:
                                                                upload_response
                                                                    .toString(),
                                                            duration: Duration(
                                                                seconds: 3),
                                                          )..show(context);
                                                        }
                                                      }
                                                    }
                                                  })
                                              : Center(
                                                  child: Column(
                                                    children: [
                                                      CircularProgressIndicator(
                                                        color: kActiveColor,
                                                      ),
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      Text("  Uploading..",
                                                          style: TextStyle(
                                                              color: kBlack,
                                                              fontSize: 17))
                                                    ],
                                                  ),
                                                ),
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

  print("""
    query{
          listTopic(sortField:"created_at",order:"desc"){
            id,
            name,
            description
          }
        }
""");
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

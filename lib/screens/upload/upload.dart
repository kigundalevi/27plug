import 'dart:io';
import 'dart:ui';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/models/tag.dart';
import 'package:africanplug/player/upload_player.dart';
import 'package:africanplug/screens/login/login.dart';
import 'package:africanplug/widgets/app/appbar.dart';
import 'package:africanplug/widgets/button/main_upload_button.dart';
import 'package:africanplug/widgets/button/rounded_button.dart';
import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
import 'package:africanplug/widgets/input/text_field_container.dart';
import 'package:africanplug/widgets/menu/main_menu.dart';
import 'package:africanplug/widgets/video/thumbnail_display.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:africanplug/widgets/video/video_tile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
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

  List<VideoTag> _selectedVideoTags = [];

  List<VideoTag> _tags = [];

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
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextEditingController.dispose();
  }

  bool _loading = false;
  bool _autoValidate = false;

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
                // elevation: 8.0,
                color: kPrimaryLightColor,
                child: SafeArea(
                  child: Container(
                    color: kWhite,
                    child: Stack(children: [
                      SingleChildScrollView(
                        child: Form(
                          key: _uploadFormKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: size.height / 12,
                                ),
                                selectedVideo != null
                                    ? Stack(
                                        alignment: AlignmentDirectional.topEnd,
                                        children: [
                                          Column(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child:
                                                    new NetworkPlayerLifeCycle(
                                                        '$selectedVideoPath', // with the String dirPath I have error but if I use the same path but write like this  /data/user/0/com.XXXXX.flutter_video_test/app_flutter/Movies/2019-11-08.mp4 it's ok ... why ?
                                                        (BuildContext context,
                                                                VideoPlayerController
                                                                    controller) =>
                                                            AspectRatioVideo(
                                                                controller)),
                                              ),
                                              Text(selectedVideo!.name)
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
                                                print(file.name);
                                                print(file.bytes);
                                                print(file.size);
                                                print(file.extension);
                                                print(file.path);
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
                                      )
                                    : Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          new Container(
                                            width: size.width,
                                            height: size.height / 5,
                                            decoration: new BoxDecoration(
                                              color: Colors.grey.shade100,
                                              // image: new DecorationImage(
                                              //   image: new AssetImage(
                                              //       "assets/images/image_placeholder.png"),
                                              //   fit: BoxFit.cover,
                                              // ),
                                              borderRadius: new BorderRadius
                                                      .all(
                                                  new Radius.circular(10.0)),
                                            ),
                                          ),
                                          Center(
                                            child: selectingVideo
                                                ? CircularProgressIndicator(
                                                    color: kPrimaryColor,
                                                  )
                                                : InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        selectingVideo = true;
                                                      });
                                                      FilePickerResult?
                                                          videoPicked =
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                                  type: FileType
                                                                      .video);
                                                      if (videoPicked != null) {
                                                        PlatformFile file =
                                                            videoPicked
                                                                .files.first;

                                                        setState(() {
                                                          selectedVideoPath =
                                                              file.path;
                                                          selectedVideo =
                                                              videoPicked
                                                                  .files.first;
                                                        });

                                                        print(file.name);
                                                        print(file.bytes);
                                                        print(file.size);
                                                        print(file.extension);
                                                        print(file.path);
                                                        setState(() {
                                                          selectingVideo =
                                                              false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          selectingVideo =
                                                              false;
                                                        });
                                                        //TODO:Snackbarshoww error
                                                      }
                                                    },
                                                    child: Material(
                                                      elevation: 8.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          children: [
                                                            Icon(Icons
                                                                .video_call_outlined),
                                                            Text("Select Video")
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                SizedBox(height: size.height * 0.05),
                                TextFieldContainer(
                                  color: kPrimaryLightColor,
                                  child: TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    autofocus: false,
                                    controller: titleController,
                                    // validator: validateEmail,
                                    onChanged: (value) => _title = value,
                                    onSaved: (value) => _title = value,
                                    // style: _inputStyle,
                                    decoration: InputDecoration(
                                        fillColor: kPrimaryLightColor,
                                        // contentPadding:
                                        //     EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                        hintText: "Video Title",
                                        border: InputBorder.none),
                                  ),
                                ),
                                TextFieldContainer(
                                  color: kPrimaryLightColor,
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    obscureText: true,
                                    autofocus: false,
                                    controller: descriptionController,
                                    // validator: validatePassword,
                                    onChanged: (value) => _description = value,
                                    onSaved: (value) => _description = value,
                                    decoration: InputDecoration(
                                        hintText: 'Video Description',
                                        // icon: Icon(
                                        //   Icons.lock,
                                        //   color: kPrimaryColor,
                                        // ),
                                        // suffixIcon: Icon(
                                        //   Icons.visibility,
                                        //   color: kPrimaryColor,
                                        // ),
                                        border: InputBorder.none),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FlutterTagging<VideoTag>(
                                    initialItems: _tagsToSelect,
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                      decoration: InputDecoration(
                                        // border: InputBorder.none,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        filled: true,
                                        fillColor: kPrimaryLightColor,
                                        hintText: 'search tag',
                                        labelText: 'Video tags',
                                      ),
                                    ),
                                    findSuggestions:
                                        TagSearchService.findVideoTags,
                                    additionCallback: (value) {
                                      return VideoTag(
                                          id: 0, name: value, description: "");
                                    },
                                    onAdded: (videoTag) {
                                      // api calls here, triggered when add to tag button is pressed
                                      return videoTag;
                                    },
                                    configureChip: configureChip,
                                    configureSuggestion: (tag) {
                                      return SuggestionConfiguration(
                                        title: Text(tag.name),
                                        // subtitle: Text(tag.id.toString()),
                                        additionWidget: Chip(
                                          avatar: Icon(
                                            Icons.add_circle,
                                            color: Colors.white,
                                          ),
                                          label: Text('Add New Tag'),
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w300,
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: size.height * 0.03),
                                !_loading
                                    ? Material(
                                        elevation: 8.0,
                                        child: RoundedButton(
                                            text: "Upload", press: () async {}),
                                      )
                                    : CircularProgressIndicator(
                                        color: kPrimaryColor,
                                      ),
                                SizedBox(height: size.height * 0.05)
                              ],
                            ),
                          ),
                        ),
                      ),
                      appBar(size, () {
                        setState(() {
                          collapseFromLeft = true;
                          if (isCollapsed)
                            _aController.forward();
                          else
                            _aController.reverse();

                          isCollapsed = !isCollapsed;
                        });
                      })
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

class TagSearchService {
  var location_suggestions = [];

  static Future<List<VideoTag>> findVideoTags(String query) async {
    await Future.delayed(Duration(milliseconds: 500), null);
    final List<VideoTag> _allTags = [
      VideoTag(id: 1, name: 'Entertainment', description: ""),
      VideoTag(id: 2, name: 'Politics', description: ""),
      VideoTag(id: 3, name: 'Business', description: ""),
    ];
    return _allTags
        .where((lang) => lang.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
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

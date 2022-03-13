import 'dart:io';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/models/tag.dart';
import 'package:africanplug/widgets/app/appbar.dart';
import 'package:africanplug/widgets/button/main_upload_button.dart';
import 'package:africanplug/widgets/button/rounded_button.dart';
import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
import 'package:africanplug/widgets/input/text_field_container.dart';
import 'package:africanplug/widgets/menu/main_menu.dart';
import 'package:africanplug/widgets/video/thumbnail_display.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:africanplug/widgets/video/video_tile_old.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:video_player/video_player.dart';

class VideoPlayPause extends StatefulWidget {
  VideoPlayPause(this.controller, this.file);

  final VideoPlayerController controller;
  final PlatformFile file;

  @override
  State createState() {
    return _VideoPlayPauseState();
  }
}

class _VideoPlayPauseState extends State<VideoPlayPause> {
  late VoidCallback listener;
  int currentDurationInSecond = 0;

  FadeAnimation imageFadeAnim =
      FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
  Widget controlIcon = SizedBox();
  Widget overLay = SizedBox();

  VideoPlayerController get controller => widget.controller;
  PlatformFile get file => widget.file;
  VideoProgressIndicator? progressIndicator;
  bool _paused = false;
  bool _overlayed = false;
  _VideoPlayPauseState() {
    listener = () {
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
    controller.addListener(() => setState(() {
          currentDurationInSecond = controller.value.position.inSeconds;
        }));
    controller.setVolume(1.0);
    controller.play();
    progressIndicator = VideoProgressIndicator(
      controller,
      allowScrubbing: true,
      colors: VideoProgressColors(
        playedColor: Colors.red,
        bufferedColor: Colors.grey.shade400,
        backgroundColor: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      GestureDetector(
        child: VideoPlayer(controller),
        onTap: () {
          if (!controller.value.isInitialized) {
            return;
          }
          if (controller.value.isPlaying) {
            controller.pause();
            _paused = true;
            setState(() {});
            imageFadeAnim =
                FadeAnimation(child: const Icon(Icons.pause, size: 100.0));

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
                          file.name.length > 25
                              ? file.name
                                  .replaceRange(25, file.name.length, '...')
                              : file.name,
                          style: TextStyle(color: kWhite, fontSize: 15),
                        ),
                        OutlinedButton(
                          child: Icon(Icons.more_horiz),
                          style: OutlinedButton.styleFrom(
                            primary: kWhite,
                            side: BorderSide(width: 0, color: Colors.black12),
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
                            side: BorderSide(width: 0, color: Colors.black12),
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
                child: const Icon(FlutterIcons.play_faw5s, size: 100.0));
            setState(() {});
          }
        },
      ),
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
    ];

    return Stack(
      fit: StackFit.passthrough,
      children: children,
    );
  }

  @override
  void deactivate() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // controller.setVolume(0.0);
      // controller.removeListener(listener);
      // controller = null;
      // setState(() {
      //   controller = null;
      // });
      //controller.dispose();

      super.deactivate();
    });
  }

  @override
  void dispose() {
    // controller.setVolume(0.0);
    // controller.removeListener(listener);
    // controller.dispose();
    //super.deactivate();
    super.dispose();
  }
}

formattedTime(int secTime) {
  String getParsedTime(String time) {
    if (time.length <= 1) return "0$time";
    return time;
  }

  int min = secTime ~/ 60;
  int sec = secTime % 60;

  String parsedTime =
      getParsedTime(min.toString()) + ":" + getParsedTime(sec.toString());

  return parsedTime;
}

class FadeAnimation extends StatefulWidget {
  FadeAnimation(
      {required this.child, this.duration = const Duration(milliseconds: 500)});

  final Widget child;
  final Duration duration;

  @override
  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: widget.duration, vsync: this);
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return animationController.isAnimating
        ? Opacity(
            opacity: 1.0 - animationController.value,
            child: widget.child,
          )
        : Container();
  }
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller, this.file, this.size);

  final VideoPlayerController controller;
  PlatformFile file;
  Size size;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  PlatformFile get file => widget.file;
  Size get size => widget.size;
  bool initialized = false;

  late VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      if (initialized != controller.value.isInitialized) {
        initialized = controller.value.isInitialized;
        setState(() {});
      }
    };
    controller.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
          // child: AspectRatio(
          //   aspectRatio: (4 / 5),
          //   child: VideoPlayPause(controller, file),
          // ),
          child: FittedBox(
              fit: BoxFit.cover,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  height: controller.value.size.height,
                  width: controller.value.size.width,
                  child: VideoPlayPause(controller, file),
                ),
              )

              // SizedBox(
              //   // height: controller.value.size.height,
              //   // width: controller.value.size.width,
              //   height: size.height / 3.5,
              //   width: size.width,
              //   child: VideoPlayPause(controller, file),
              // ),

              ));
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    //controller.removeListener(listener);
    // controller.dispose();
    super.dispose();
  }
}

typedef Widget VideoWidgetBuilder(
    BuildContext context, VideoPlayerController controller);

abstract class PlayerLifeCycle extends StatefulWidget {
  PlayerLifeCycle(this.dataSource, this.file, this.childBuilder);

  final VideoWidgetBuilder childBuilder;
  final PlatformFile file;
  final String dataSource;
}

/// A widget connecting its life cycle to a [VideoPlayerController] using
/// a data source from the network.
class NetworkPlayerLifeCycle extends PlayerLifeCycle {
  NetworkPlayerLifeCycle(
      String dataSource, PlatformFile file, VideoWidgetBuilder childBuilder)
      : super(dataSource, file, childBuilder);

  @override
  _NetworkPlayerLifeCycleState createState() => _NetworkPlayerLifeCycleState();
}

/// A widget connecting its life cycle to a [VideoPlayerController] using
/// an asset as data source
class AssetPlayerLifeCycle extends PlayerLifeCycle {
  AssetPlayerLifeCycle(
      String dataSource, PlatformFile file, VideoWidgetBuilder childBuilder)
      : super(dataSource, file, childBuilder);

  @override
  _AssetPlayerLifeCycleState createState() => _AssetPlayerLifeCycleState();
}

class _AssetPlayerLifeCycleState extends State<AssetPlayerLifeCycle> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

abstract class _PlayerLifeCycleState extends State<PlayerLifeCycle> {
  late VideoPlayerController controller;

  @override

  /// Subclasses should implement [createVideoPlayerController], which is used
  /// by this method.
  void initState() {
    super.initState();
    controller = createVideoPlayerController();
    controller.addListener(() {
      if (controller.value.hasError) {
        print(controller.value.errorDescription);
      }
    });
    controller.initialize();
    controller.setLooping(true);
    controller.play();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.deactivate();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.childBuilder(context, controller);
  }

  VideoPlayerController createVideoPlayerController();
}

class _NetworkPlayerLifeCycleState extends _PlayerLifeCycleState {
  @override
  VideoPlayerController createVideoPlayerController() {
    return VideoPlayerController.network(widget.dataSource);
  }

  @override
  void dispose() {
    super.deactivate();
    // controller.dispose();
    super.dispose();
  }
}

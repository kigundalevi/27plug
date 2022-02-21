// import 'dart:io';
// import 'package:africanplug/config/config.dart';
// import 'package:africanplug/config/graphql_config.dart';
// import 'package:africanplug/models/tag.dart';
// import 'package:africanplug/widgets/app/appbar.dart';
// import 'package:africanplug/widgets/button/main_upload_button.dart';
// import 'package:africanplug/widgets/button/rounded_button.dart';
// import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
// import 'package:africanplug/widgets/input/text_field_container.dart';
// import 'package:africanplug/widgets/menu/main_menu.dart';
// import 'package:africanplug/widgets/video/thumbnail_display.dart';
// import 'package:africanplug/widgets/video/video_info_chip.dart';
// import 'package:africanplug/widgets/video/video_tile.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tagging/flutter_tagging.dart';
// import 'package:video_player/video_player.dart';

// class VideoPlayPause extends StatefulWidget {
//   VideoPlayPause(this.controller);

//   final VideoPlayerController controller;

//   @override
//   State createState() {
//     return _VideoPlayPauseState();
//   }
// }

// class _VideoPlayPauseState extends State<VideoPlayPause> {
//   late VoidCallback listener;

//   _VideoPlayPauseState() {
//     listener = () {
//       setState(() {});
//     };
//   }

//   FadeAnimation imageFadeAnim =
//       FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
//   Widget controlIcon = SizedBox();

//   VideoPlayerController get controller => widget.controller;
//   VideoProgressIndicator? progressIndicator;
//   @override
//   void initState() {
//     super.initState();
//     controller.addListener(listener);
//     controller.setVolume(1.0);
//     controller.play();
//     progressIndicator = VideoProgressIndicator(
//       controller,
//       allowScrubbing: true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> children = <Widget>[
//       GestureDetector(
//         child: VideoPlayer(controller),
//         onTap: () {
//           if (!controller.value.isInitialized) {
//             return;
//           }
//           if (controller.value.isPlaying) {
//             imageFadeAnim =
//                 FadeAnimation(child: const Icon(Icons.pause, size: 100.0));
//             controller.pause();
//             controlIcon = InkWell(
//               child: Icon(Icons.play_arrow, size: 80.0),
//               onTap: () {
//                 controlIcon = SizedBox();
//                 setState(() {});
//                 controller.play();
//               },
//             );
//             setState(() {});
//           } else {
//             controlIcon = SizedBox();
//             setState(() {});
//             imageFadeAnim =
//                 FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
//             controller.play();
//           }
//         },
//       ),
//       Align(
//         alignment: Alignment.bottomCenter,
//         child: progressIndicator,
//       ),
//       Center(child: imageFadeAnim),
//       Center(
//           child: Material(
//               elevation: 8.0,
//               color: Colors.white38,
//               borderRadius: BorderRadius.circular(10.0),
//               child: controlIcon)),
//       Center(
//           child: controller.value.isBuffering
//               ? const CircularProgressIndicator(color: kPrimaryColor)
//               : null),
//     ];

//     return Stack(
//       fit: StackFit.passthrough,
//       children: children,
//     );
//   }

//   @override
//   void deactivate() {
//     WidgetsBinding.instance?.addPostFrameCallback((_) {
//       // controller.setVolume(0.0);
//       // controller.removeListener(listener);
//       // controller = null;
//       // setState(() {
//       //   controller = null;
//       // });
//       //controller.dispose();

//       super.deactivate();
//     });
//   }

//   @override
//   void dispose() {
//     // controller.setVolume(0.0);
//     // controller.removeListener(listener);
//     // controller.dispose();
//     //super.deactivate();
//     super.dispose();
//   }
// }

// class FadeAnimation extends StatefulWidget {
//   FadeAnimation(
//       {required this.child, this.duration = const Duration(milliseconds: 500)});

//   final Widget child;
//   final Duration duration;

//   @override
//   _FadeAnimationState createState() => _FadeAnimationState();
// }

// class _FadeAnimationState extends State<FadeAnimation>
//     with SingleTickerProviderStateMixin {
//   late AnimationController animationController;

//   @override
//   void initState() {
//     super.initState();
//     animationController =
//         AnimationController(duration: widget.duration, vsync: this);
//     animationController.addListener(() {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//     animationController.forward(from: 0.0);
//   }

//   @override
//   void deactivate() {
//     animationController.stop();
//     super.deactivate();
//   }

//   @override
//   void didUpdateWidget(FadeAnimation oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.child != widget.child) {
//       animationController.forward(from: 0.0);
//     }
//   }

//   @override
//   void dispose() {
//     animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return animationController.isAnimating
//         ? Opacity(
//             opacity: 1.0 - animationController.value,
//             child: widget.child,
//           )
//         : Container();
//   }
// }

// class AspectRatioVideo extends StatefulWidget {
//   AspectRatioVideo(this.controller);

//   final VideoPlayerController controller;

//   @override
//   AspectRatioVideoState createState() => AspectRatioVideoState();
// }

// class AspectRatioVideoState extends State<AspectRatioVideo> {
//   VideoPlayerController get controller => widget.controller;
//   bool initialized = false;

//   late VoidCallback listener;

//   @override
//   void initState() {
//     super.initState();
//     listener = () {
//       if (!mounted) {
//         return;
//       }
//       if (initialized != controller.value.isInitialized) {
//         initialized = controller.value.isInitialized;
//         setState(() {});
//       }
//     };
//     controller.addListener(listener);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (initialized) {
//       return Center(
//         child: AspectRatio(
//           aspectRatio: controller.value.aspectRatio,
//           child: VideoPlayPause(controller),
//         ),
//       );
//     } else {
//       return Container();
//     }
//   }

//   @override
//   void dispose() {
//     //controller.removeListener(listener);
//     // controller.dispose();
//     super.dispose();
//     print("DISPOSED 1");
//   }
// }

// typedef Widget VideoWidgetBuilder(
//     BuildContext context, VideoPlayerController controller);

// abstract class PlayerLifeCycle extends StatefulWidget {
//   PlayerLifeCycle(this.dataSource, this.childBuilder);

//   final VideoWidgetBuilder childBuilder;
//   final String dataSource;
// }

// /// A widget connecting its life cycle to a [VideoPlayerController] using
// /// a data source from the network.
// class NetworkPlayerLifeCycle extends PlayerLifeCycle {
//   NetworkPlayerLifeCycle(String dataSource, VideoWidgetBuilder childBuilder)
//       : super(dataSource, childBuilder);

//   @override
//   _NetworkPlayerLifeCycleState createState() => _NetworkPlayerLifeCycleState();
// }

// /// A widget connecting its life cycle to a [VideoPlayerController] using
// /// an asset as data source
// class AssetPlayerLifeCycle extends PlayerLifeCycle {
//   AssetPlayerLifeCycle(String dataSource, VideoWidgetBuilder childBuilder)
//       : super(dataSource, childBuilder);

//   @override
//   _AssetPlayerLifeCycleState createState() => _AssetPlayerLifeCycleState();
// }

// class _AssetPlayerLifeCycleState extends State<AssetPlayerLifeCycle> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

// abstract class _PlayerLifeCycleState extends State<PlayerLifeCycle> {
//   late VideoPlayerController controller;

//   @override

//   /// Subclasses should implement [createVideoPlayerController], which is used
//   /// by this method.
//   void initState() {
//     super.initState();
//     controller = createVideoPlayerController();
//     controller.addListener(() {
//       if (controller.value.hasError) {
//         print(controller.value.errorDescription);
//       }
//     });
//     controller.initialize();
//     controller.setLooping(true);
//     controller.play();
//   }

//   @override
//   void deactivate() {
//     super.deactivate();
//   }

//   @override
//   void dispose() {
//     super.deactivate();
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.childBuilder(context, controller);
//   }

//   VideoPlayerController createVideoPlayerController();
// }

// class _NetworkPlayerLifeCycleState extends _PlayerLifeCycleState {
//   @override
//   VideoPlayerController createVideoPlayerController() {
//     return VideoPlayerController.network(widget.dataSource);
//   }

//   @override
//   void dispose() {
//     super.deactivate();
//     // controller.dispose();
//     super.dispose();
//   }
// }

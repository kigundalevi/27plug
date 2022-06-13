import 'package:africanplug/controller/custom_auto_hide_controls.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data_manager.dart';

class CustomOrientationControls extends StatelessWidget {
  const CustomOrientationControls(
      {Key? key, this.iconSize = 20, this.fontSize = 12, this.dataManager})
      : super(key: key);
  final double iconSize;
  final double fontSize;
  final CustomDataManager? dataManager;

  @override
  Widget build(BuildContext context) {
    FlickVideoManager flickVideoManager =
        Provider.of<FlickVideoManager>(context);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CustomFlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(color: Colors.black38),
            ),
          ),
        ),
        Positioned(
            top: 0,
            left: 0,
            child: CustomFlickAutoHideChild(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(dataManager!.currentVideo().title)))),
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: flickVideoManager.nextVideoAutoPlayTimer != null
                    ? FlickAutoPlayCircularProgress(
                        colors: FlickAutoPlayTimerProgressColors(
                          backgroundColor: Colors.white30,
                          color: Colors.red,
                        ),
                      )
                    : CustomFlickAutoHideChild(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  dataManager!.skipToPreviousVideo();
                                },
                                child: Icon(
                                  Icons.skip_previous,
                                  color: dataManager!.hasPreviousVideo()
                                      ? Colors.white
                                      : Colors.white38,
                                  size: 35,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FlickPlayToggle(size: 50),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  dataManager!.skipToNextVideo();
                                },
                                child: Icon(
                                  Icons.skip_next,
                                  color: dataManager!.hasNextVideo()
                                      ? Colors.white
                                      : Colors.white38,
                                  size: 35,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomFlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlickCurrentPosition(
                            fontSize: fontSize,
                          ),
                          Text(
                            ' / ',
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSize),
                          ),
                          FlickTotalDuration(
                            fontSize: fontSize,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      FlickFullScreenToggle(
                        size: iconSize,
                      ),
                    ],
                  ),
                  FlickVideoProgressBar(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      height: 5,
                      handleRadius: 5,
                      curveRadius: 50,
                      backgroundColor: Colors.white24,
                      bufferedColor: Colors.white38,
                      playedColor: Colors.red,
                      handleColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

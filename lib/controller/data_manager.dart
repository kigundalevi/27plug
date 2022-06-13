import 'dart:async';

import 'package:africanplug/config/config.dart';
import 'package:africanplug/controller/user_controller.dart';
import 'package:africanplug/models/video.dart';
import 'package:africanplug/screens/videos/tv.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomDataManager {
  CustomDataManager(
      {required this.context,
      required this.flickManager,
      required this.videos,
      required this.currentPlaying});
  int currentPlaying;
  final FlickManager flickManager;
  final List<Video> videos;
  BuildContext context;

  late Timer videoChangeTimer;
  Video currentVideo() {
    return videos[currentPlaying];
  }

  String getNextVideo() {
    currentPlaying++;
    String videoUrl = videos[currentPlaying].url.substring(0, 4) == 'http'
        ? videos[currentPlaying].url
        : VIDEOS_ROOT_URL + videos[currentPlaying].url;
    return videoUrl;
  }

  bool hasNextVideo() {
    return currentPlaying != videos.length - 1;
  }

  bool hasPreviousVideo() {
    return currentPlaying != 0;
  }

  skipToNextVideo([Duration? duration]) {
    if (hasNextVideo()) {
      saveView(videos[currentPlaying + 1].id);

      String videoUrl = videos[currentPlaying + 1].url.substring(0, 4) == 'http'
          ? videos[currentPlaying + 1].url
          : VIDEOS_ROOT_URL + videos[currentPlaying + 1].url;

      // flickManager.handleChangeVideo(VideoPlayerController.network(videoUrl),
      //     videoChangeDuration: duration);
      currentPlaying++;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TvScreen(videos: videos, activeIndex: currentPlaying)),
      );
    }
  }

  play() {
    saveView(videos[currentPlaying].id);

    String videoUrl = videos[currentPlaying].url.substring(0, 4) == 'http'
        ? videos[currentPlaying].url
        : VIDEOS_ROOT_URL + videos[currentPlaying].url;

    print("CURRENTLY PLAYING: " + videos[currentPlaying].url.substring(0, 4));

    flickManager.handleChangeVideo(VideoPlayerController.network(videoUrl));
    // Navigator.pop(context);
    //       Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) =>
    //           TvScreen(videos: videos, activeIndex: currentPlaying)),
    // );
    currentPlaying = currentPlaying;
  }

  skipToVideo(int index) {
    if (index < videos.length) {
      saveView(videos[index].id);

      String videoUrl = videos[index].url.substring(0, 4) == 'http'
          ? videos[index].url
          : VIDEOS_ROOT_URL + videos[index].url;

      // flickManager.handleChangeVideo(VideoPlayerController.network(videoUrl));
      currentPlaying = index;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TvScreen(videos: videos, activeIndex: currentPlaying)),
      );
    }
  }

  skipToPreviousVideo() {
    if (hasPreviousVideo()) {
      saveView(videos[currentPlaying].id);

      String videoUrl = videos[currentPlaying].url.substring(0, 4) == 'http'
          ? videos[currentPlaying].url
          : VIDEOS_ROOT_URL + videos[currentPlaying].url;

      // flickManager.handleChangeVideo(VideoPlayerController.network(videoUrl));
      currentPlaying--;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TvScreen(videos: videos, activeIndex: currentPlaying)),
      );
    }
  }

  cancelVideoAutoPlayTimer({required bool playNext}) {
    if (playNext != true) {
      currentPlaying--;
    }

    flickManager.flickVideoManager
        ?.cancelVideoAutoPlayTimer(playNext: playNext);
  }

  void saveView(int id) async {
    UserController ctrl = UserController();
    bool watched = await ctrl.addVideoView(videos[currentPlaying].id);
    if (!watched) {
      print("-------------ERROR SAVING VIEW--------------");
    }
  }
}

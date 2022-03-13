import 'dart:async';

import 'package:africanplug/controller/user_controller.dart';
import 'package:africanplug/models/video.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';

class CustomDataManager {
  CustomDataManager(
      {required this.flickManager,
      required this.videos,
      required this.currentPlaying});
  int currentPlaying;
  final FlickManager flickManager;
  final List<Video> videos;

  late Timer videoChangeTimer;
  Video currentVideo() {
    return videos[currentPlaying];
  }

  String getNextVideo() {
    currentPlaying++;
    return videos[currentPlaying].url;
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
      flickManager.handleChangeVideo(
          VideoPlayerController.network(videos[currentPlaying + 1].url),
          videoChangeDuration: duration);
      currentPlaying++;
    }
  }

  play() {
    saveView(videos[currentPlaying].id);
    flickManager.handleChangeVideo(
        VideoPlayerController.network(videos[currentPlaying].url));
  }

  skipToVideo(int index) {
    if (index < videos.length) {
      saveView(videos[index].id);
      flickManager
          .handleChangeVideo(VideoPlayerController.network(videos[index].url));
      currentPlaying = index;
    }
  }

  skipToPreviousVideo() {
    if (hasPreviousVideo()) {
      currentPlaying--;
      saveView(videos[currentPlaying].id);
      flickManager.handleChangeVideo(
          VideoPlayerController.network(videos[currentPlaying].url));
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

import 'package:africanplug/config/config.dart';
import 'package:africanplug/models/video.dart';
import 'package:africanplug/screens/videos/tv.dart';
import 'package:africanplug/widgets/chip/image_chip.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:flutter/material.dart';

class VideoListTile extends StatelessWidget {
  const VideoListTile({
    Key? key,
    required this.video,
    required this.playList,
    required this.playingIndex,
    required this.isCollapsed,
    required this.size,
  }) : super(key: key);

  final Video video;
  final List<Video> playList;
  final int playingIndex;
  final bool isCollapsed;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TvScreen(videos: playList, activeIndex: playingIndex)),
            );
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
                                borderRadius:
                                    BorderRadius.circular(numCurveRadius),
                                image: DecorationImage(
                                    image: NetworkImage(video.thumbnail_url ==
                                            null
                                        ? "https://redmoonrecord.co.uk/tech/wp-content/uploads/2019/11/YouTube-thumbnail-size-guide-best-practices-top-examples.png"
                                        : video.thumbnail_url),
                                    fit: BoxFit.fill),
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
                          width:
                              !isCollapsed ? size.width / 4 : size.width / 2.2,
                          // color: Colors.black26,
                          // padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                style: TextStyle(
                                    color: kWhite,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w300),
                                textAlign: TextAlign.left,
                              ),
                              // SizedBox(
                              //   height: size.height * 0.01,
                              // ),
                              ImageChip(
                                  image_url: (video.uploader_dpurl == '' ||
                                          video.uploader_dpurl == null)
                                      ? 'https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png'
                                      : video.uploader_dpurl,
                                  text: video.uploader_channel_name == null ||
                                          video.uploader_channel_name == ""
                                      ? video.uploaded_by
                                      : video.uploader_channel_name),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  VideoInfoChip(
                                    icon_data: Icons.remove_red_eye,
                                    text: video.views,
                                  ),
                                  VideoInfoChip(
                                    icon_data: Icons.access_time,
                                    text: video.upload_lapse,
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
    );
  }
}

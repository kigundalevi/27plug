import 'package:africanplug/config/config.dart';
import 'package:africanplug/widgets/chip/image_chip.dart';
import 'package:africanplug/widgets/video/thumbnail_display.dart';
import 'package:africanplug/widgets/video/video_info_chip.dart';
import 'package:flutter/material.dart';

class VideoTile extends StatelessWidget {
  final String thumbnail_url;
  final String title;
  final int channel_id;
  final String channel_name;
  final String channel_image_url;
  final String view_count;
  final String lapse;
  const VideoTile({
    Key? key,
    required this.thumbnail_url,
    required this.title,
    required this.channel_id,
    required this.channel_name,
    required this.channel_image_url,
    required this.view_count,
    required this.lapse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.17,
      width: size.width * 0.1,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              ThumbNailDisplay(
                thumbnail_url: thumbnail_url,
                watch_later_press: () {},
                favourite_press: () {},
              ),
              Container(
                height: size.height * 0.17,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: size.width * 0.44,
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 19),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    // SizedBox(
                    //   height: size.height * 0.01,
                    // ),
                    Row(
                      children: [
                        ImageChip(
                            image_url: channel_image_url, text: channel_name)
                      ],
                    ),
                    Container(
                      width: size.width * 0.47,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          VideoInfoChip(
                            icon_data: Icons.remove_red_eye,
                            text: view_count,
                          ),
                          VideoInfoChip(
                            icon_data: Icons.access_time,
                            text: lapse,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

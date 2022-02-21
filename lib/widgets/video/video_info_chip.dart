import 'package:africanplug/config/config.dart';
import 'package:flutter/material.dart';

class VideoInfoChip extends StatelessWidget {
  final IconData icon_data;
  final String text;
  const VideoInfoChip({
    Key? key,
    required this.icon_data,
    required this.text,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      // width: size.width * 0.25,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: kPrimaryLightColor,
        borderRadius: BorderRadius.all(Radius.circular(numCurveRadius)),
      ),
      child: Row(
        children: [
          Icon(
            icon_data,
            color: kPrimaryColor,
            size: size.height * 0.025,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            text,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

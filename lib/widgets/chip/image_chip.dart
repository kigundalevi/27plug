import 'package:africanplug/config/config.dart';
import 'package:flutter/material.dart';

class ImageChip extends StatelessWidget {
  const ImageChip(
      {Key? key,
      required this.image_url,
      required this.text,
      this.color = Colors.white})
      : super(key: key);

  final String image_url;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          // color: kPrimaryLightColor,
          borderRadius: BorderRadius.circular(50)),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: size.height * 0.007, horizontal: size.width * 0.01),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.height * 0.005),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17.0),
                child: Image.network(
                  image_url,
                  height: size.height * 0.03,
                ),
              ),
            ),
            Text(
              text,
              style: TextStyle(color: kLightTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

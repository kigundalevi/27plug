import 'package:africanplug/config/config.dart';
import 'package:africanplug/widgets/button/thumbnail_icon_button.dart';
import 'package:flutter/material.dart';

class ThumbNailDisplay extends StatelessWidget {
  final String thumbnail_url;
  final VoidCallback watch_later_press;
  final VoidCallback favourite_press;
  const ThumbNailDisplay({
    Key? key,
    required this.thumbnail_url,
    required this.watch_later_press,
    required this.favourite_press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.45,
      height: size.height * 0.147,
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(numCurveRadius),
            image: DecorationImage(
                image: AssetImage(thumbnail_url), fit: BoxFit.fill),
          ),
          alignment: Alignment.center,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black12,
            height: size.width * 0.07,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ThumbNailIconButton(
                    icon_data: Icons.watch_later,
                    press: watch_later_press,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ThumbNailIconButton(
                    icon_data: Icons.favorite,
                    press: favourite_press,
                  ),
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}

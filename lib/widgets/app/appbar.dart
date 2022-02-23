import 'package:africanplug/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

Container appBar(Size size, left_pressed, center_pressed, right_pressed) {
  return Container(
    color: Colors.transparent,
    height: size.height / 14,
    width: size.width,
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.menu,
            color: kWhite,
          ),
          onPressed: left_pressed,
        ),
        Center(
          child: InkWell(
            onTap: center_pressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FlutterIcons.plug_faw5s,
                  color: kActiveColor,
                  size: 25.0,
                ),
                Text("27Plug",
                    style: TextStyle(
                        color: kActiveColor,
                        fontSize: 19.0,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
        IconButton(
          icon: CircleAvatar(
            backgroundImage: AssetImage(
              'assets/images/brian.jpg',
            ),
            backgroundColor: Colors.black26,
            foregroundColor: Colors.black26,
          ),
          onPressed: right_pressed,
        )
      ],
    ),
  );
}

import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

Container appBar(Size size, left_pressed, center_pressed, right_pressed,
    [search_pressed]) {
  User user = currentUser();
  // print('-------DP URL-------');
  // print(user.dp_url);
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
            color: kPrimaryColor,
          ),
          onPressed: left_pressed,
        ),
        Center(
          child: Container(
            child: search_pressed == null
                ? InkWell(
                    onTap: center_pressed,
                    child: Text(txtAppName,
                        style: TextStyle(
                            color: kActiveColor,
                            fontSize: 19.0,
                            fontWeight: FontWeight.bold)),
                  )
                : Row(
                    children: [
                      SizedBox(width: size.width / 8.5),
                      InkWell(
                        onTap: center_pressed,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FlutterIcons.plug_faw5s,
                              color: kActiveColor,
                              size: 25.0,
                            ),
                            Text(txtAppName,
                                style: TextStyle(
                                    color: kActiveColor,
                                    fontSize: 19.0,
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        user.id != 1
            ? search_pressed == null
                ? IconButton(
                    icon: CircleAvatar(
                      backgroundImage: NetworkImage(
                        user.dp_url,
                      ),
                      backgroundColor: Colors.black26,
                      foregroundColor: Colors.black26,
                    ),
                    onPressed: right_pressed,
                  )
                : Row(
                    children: [
                      IconButton(
                        icon: RotatedBox(
                            quarterTurns: 1,
                            child: Icon(FlutterIcons.search_oct)),
                        onPressed: search_pressed,
                      ),
                      IconButton(
                        icon: CircleAvatar(
                          backgroundImage: NetworkImage(
                            user.dp_url,
                          ),
                          backgroundColor: Colors.black26,
                          foregroundColor: Colors.black26,
                        ),
                        onPressed: right_pressed,
                      ),
                    ],
                  )
            : search_pressed == null
                ? IconButton(
                    icon: Icon(
                      FlutterIcons.guest_zoc,
                      color: Colors.white70,
                      size: 23,
                    ),
                    onPressed: right_pressed,
                  )
                : Row(
                    children: [
                      IconButton(
                        icon: RotatedBox(
                            quarterTurns: 1,
                            child: Icon(FlutterIcons.search_oct)),
                        onPressed: search_pressed,
                      ),
                      IconButton(
                        icon: CircleAvatar(
                          backgroundImage: AssetImage("assets/images/user.png"),
                          backgroundColor: Colors.black26,
                          foregroundColor: Colors.black26,
                        ),
                        onPressed: right_pressed,
                      ),
                    ],
                  )
      ],
    ),
  );
}

import 'package:africanplug/config/config.dart';
import 'package:flutter/material.dart';

Container appBar(Size size, menu_pressed) {
  return Container(
    color: kPrimaryColor.withOpacity(0.979),
    height: size.height / 14,
    child: Container(
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(color: kPrimaryLightColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: menu_pressed,
            icon: Icon(Icons.menu),
            color: kPrimaryColor,
          ),
          Text(
            txtAppName,
            style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
            color: kPrimaryColor,
          )
        ],
      ),
    ),
  );
}

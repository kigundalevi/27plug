import 'package:africanplug/config/config.dart';
import 'package:flutter/material.dart';

class customLoader extends StatelessWidget {
  const customLoader({
    Key? key,
    required this.size,
    required this.text,
  }) : super(key: key);

  final Size size;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: size.height / 8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              height: size.width / 8,
              width: size.width / 8,
              child: const CircularProgressIndicator(
                color: kActiveColor,
              )),
          Text(
            text,
            style: TextStyle(color: kActiveColor),
          )
        ],
      ),
    ));
  }
}

import 'package:africanplug/config/config.dart';
import 'package:flutter/material.dart';

class ThumbNailIconButton extends StatelessWidget {
  final IconData icon_data;
  final bool active;
  final VoidCallback press;
  const ThumbNailIconButton({
    Key? key,
    this.active = false,
    required this.icon_data,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 20,
      padding: EdgeInsets.all(4.0),
      icon: Icon(
        icon_data,
        color: active ? kPrimaryColor : Colors.white.withOpacity(0.8),
      ),
      onPressed: press,
    );
  }
}

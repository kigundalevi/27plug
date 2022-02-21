import 'package:flutter/material.dart';

class LogoImage extends StatelessWidget {
  const LogoImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Image.asset(
      "assets/images/ap_logo.jpg",
      height: size.height * 0.2,
    );
  }
}

import 'package:africanplug/config/config.dart';
import 'package:flutter/material.dart';

class HasAccountCheck extends StatelessWidget {
  final bool login;
  final VoidCallback press;

  const HasAccountCheck({
    Key? key,
    this.login = true,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          login ? txtDontHaveAccount : txtHasAccount,
          style: TextStyle(color: kPrimaryColor),
        ),
        GestureDetector(
          onTap: press,
          child: Text(login ? txtSignUp : txtSignIn,
              style:
                  TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

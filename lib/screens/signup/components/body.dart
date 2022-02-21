import 'package:africanplug/config/config.dart';
import 'package:africanplug/screens/login/login.dart';
import 'package:africanplug/screens/signup/components/background.dart';
import 'package:africanplug/screens/signup/components/or_divider.dart';
import 'package:africanplug/screens/signup/components/social_icon.dart';
import 'package:africanplug/widgets/input/has_account_check.dart';
import 'package:africanplug/widgets/image/logo_image.dart';
import 'package:africanplug/widgets/button/rounded_button.dart';
import 'package:africanplug/widgets/input/rounded_input_field.dart';
import 'package:africanplug/widgets/input/rounded_password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignUpBody extends StatelessWidget {
  const SignUpBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SignUpBackground(
        child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            txtSignUp,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          LogoImage(),
          RoundedInputField(hintText: txtYourName, onChanged: (value) {}),
          RoundedInputField(hintText: txtYourEmail, onChanged: (value) {}),
          RoundedPasswordField(onChanged: (value) {}),
          RoundedPasswordField(text: txtConfirmPassword, onChanged: (value) {}),
          SizedBox(height: size.height * 0.03),
          RoundedButton(text: txtSignUp, press: () {}),
          SizedBox(height: size.height * 0.05),
          HasAccountCheck(
              login: false,
              press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return LoginScreen();
                }));
              }),
          // OrDivider(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     SocialIcon(
          //       iconSrc: "assets/icons/facebook.svg",
          //       press: () {},
          //     ),
          //     SocialIcon(
          //       iconSrc: "assets/icons/twitter.svg",
          //       press: () {},
          //     ),
          //     SocialIcon(
          //       iconSrc: "assets/icons/google-plus.svg",
          //       press: () {},
          //     ),
          //   ],
          // )
        ],
      ),
    ));
  }
}

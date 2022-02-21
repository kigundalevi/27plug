// import 'package:africanplug/config/config.dart';
// import 'package:africanplug/screens/login/login.dart';
// import 'package:africanplug/screens/signup/sign_up.dart';
// import 'package:africanplug/screens/videos/components/background.dart';
// import 'package:africanplug/widgets/image/logo_image.dart';
// import 'package:africanplug/widgets/button/rounded_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class Body extends StatelessWidget {
//   const Body({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Background(
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               txtIntro,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: size.height * 0.05),
//             LogoImage(),
//             SizedBox(height: size.height * 0.05),
//             RoundedButton(
//               text: txtLogin,
//               press: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) {
//                   return LoginScreen();
//                 }));
//               },
//             ),
//             SizedBox(height: size.height * 0.02),
//             RoundedButton(
//               text: txtSignUp,
//               color: kPrimaryLightColor,
//               textColor: Colors.black,
//               press: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) {
//                   return SignUpScreen();
//                 }));
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

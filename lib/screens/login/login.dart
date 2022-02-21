import 'package:africanplug/config/config.dart';
import 'package:africanplug/screens/login/components/background.dart';
import 'package:africanplug/screens/login/components/body.dart';
import 'package:africanplug/widgets/image/logo_image.dart';
import 'package:africanplug/widgets/input/rounded_input_field.dart';
import 'package:africanplug/widgets/input/text_field_container.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBody(),
    );
  }
}



// import 'package:africanplug/config/config.dart';
// import 'package:africanplug/controller/login_controller.dart';
// import 'package:africanplug/controller/register_controller.dart';
// import 'package:africanplug/screens/home/home.dart';
// import 'package:africanplug/screens/login/components/background.dart';
// import 'package:africanplug/screens/login/components/body.dart';
// import 'package:africanplug/widgets/image/logo_image.dart';
// import 'package:africanplug/widgets/input/rounded_input_field.dart';
// import 'package:africanplug/widgets/input/text_field_container.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_login/flutter_login.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//   Duration get loginTime => Duration(milliseconds: 2250);

//   Future<String?> _loginAuthUser(LoginData data) {
//     LoginController ctrl = new LoginController();
//     return ctrl.authLoginUser(data.name, data.password);
//   }

//   Future<String?> _signUpAuthUser(SignupData data) {
//     RegisterController ctrl = new RegisterController();
//     return ctrl.authRegisterUser('', '', '', '');
//   }

//   Future<String> _recoverPassword(String name) {
//     print('Name: $name');
//     return Future.delayed(loginTime).then((_) {
//       return 'email to be sent soon';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // body: LoginBody(),
//       body: FlutterLogin(
//         logo: Image.asset("assets/images/ap_logo.jpg").image,
//         onLogin: _loginAuthUser,
//         onSignup: _signUpAuthUser,
//         onSubmitAnimationCompleted: () {
//           Navigator.push(context,
//               MaterialPageRoute(builder: (BuildContext context) => AppHome()));
//         },
//         userValidator: LoginController.emailValidator,
//         passwordValidator: LoginController.passwordValidator,
//         showDebugButtons: false,
//         onRecoverPassword: _recoverPassword,
//         messages: LoginMessages(
//           userHint: 'Email',
//           passwordHint: 'Password',
//           confirmPasswordHint: 'Confirm Password',
//           loginButton: 'LOGIN',
//           signupButton: 'REGISTER',
//           goBackButton: 'Back',
//           forgotPasswordButton: 'Forgot Password',
//           confirmPasswordError: 'Confirm Password',
//           recoverPasswordDescription: 'Forgot Password',
//           recoverPasswordSuccess: 'Email to reset password sent',
//         ),
//         additionalSignupFields: [
//           UserFormField(
//               keyName: 'firstName',
//               displayName: 'FirstName',
//               icon: const Icon(Icons.person)),
//           UserFormField(
//               keyName: 'lastName',
//               displayName: 'LastName',
//               icon: const Icon(Icons.person)),
//         ],
//       ),
//     );
//   }
// }

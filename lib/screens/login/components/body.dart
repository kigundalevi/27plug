import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/controller/login_controller.dart';
import 'package:africanplug/models/location.dart';
import 'package:africanplug/screens/home/home.dart';
import 'package:africanplug/screens/login/components/background.dart';
import 'package:africanplug/screens/login/components/validation.dart';
import 'package:africanplug/screens/signup/sign_up.dart';
import 'package:africanplug/screens/videos/videos_screen.dart';
import 'package:africanplug/widgets/input/has_account_check.dart';
import 'package:africanplug/widgets/image/logo_image.dart';
import 'package:africanplug/widgets/button/rounded_button.dart';
import 'package:africanplug/widgets/input/rounded_input_field.dart';
import 'package:africanplug/widgets/input/rounded_password_field.dart';
import 'package:africanplug/widgets/input/text_field_container.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  final _formKey = new GlobalKey<FormState>();

  String? _email;
  String? _password;

  TextStyle _inputStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool _autoValidate = false;

  Future<String?> _loginUser(email, password, location) {
    LoginController ctrl = new LoginController();
    return ctrl.authLoginUser(email, password, location);
  }

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoginBackground(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                txtLogin,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.05),
              LogoImage(),
              TextFieldContainer(
                color: kPrimaryLightColor,
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  autofocus: false,
                  controller: _emailController,
                  validator: validateEmail,
                  onChanged: (value) => _email = value,
                  onSaved: (value) => _email = value,
                  // style: _inputStyle,
                  decoration: InputDecoration(
                      icon: Icon(
                        Icons.mail,
                        color: kPrimaryColor,
                      ),
                      fillColor: kPrimaryLightColor,
                      // contentPadding:
                      //     EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "Your Email",
                      border: InputBorder.none),
                ),
              ),
              TextFieldContainer(
                color: kPrimaryLightColor,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  autofocus: false,
                  controller: _passwordController,
                  validator: validatePassword,
                  onChanged: (value) => _password = value,
                  onSaved: (value) => _password = value,
                  decoration: InputDecoration(
                      hintText: 'Your Password',
                      icon: Icon(
                        Icons.lock,
                        color: kPrimaryColor,
                      ),
                      suffixIcon: Icon(
                        Icons.visibility,
                        color: kPrimaryColor,
                      ),
                      border: InputBorder.none),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              !_loading
                  ? RoundedButton(
                      text: txtLogin,
                      press: () async {
                        setState(() {
                          _loading = true;
                        });
                        if (_formKey.currentState!.validate()) {
                          Loc location = await currentLocation();
                          String? response =
                              await _loginUser(_email, _password, location);

                          if (response.toString() == 'success') {
                            // setState(() {
                            //   _loading = false;
                            // });
                            Flushbar(
                              icon: Icon(
                                Icons.check_circle_rounded,
                                color: kPrimaryColor,
                              ),
                              backgroundColor: kPrimaryLightColor,
                              title: "Success",
                              message: "Logged in successfully",
                              duration: Duration(seconds: 3),
                            )..show(context);
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/home");
                          } else {
                            setState(() {
                              _loading = false;
                            });
                            Flushbar(
                              icon: Icon(
                                Icons.info_outline,
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.redAccent,
                              title: "Error",
                              message: response.toString(),
                              duration: Duration(seconds: 3),
                            )..show(context);
                          }
                        } else {
                          setState(() {
                            _loading = false;
                          });
                          _autoValidate = true;
                        }
                      })
                  : CircularProgressIndicator(
                      color: kPrimaryColor,
                    ),
              SizedBox(height: size.height * 0.05),
              HasAccountCheck(press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SignUpScreen();
                }));
              }),
            ],
          ),
        ),
      ),
    );
  }
}

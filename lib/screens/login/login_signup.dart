import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/controller/login_controller.dart';
import 'package:africanplug/controller/register_controller.dart';
import 'package:africanplug/models/location.dart';
import 'package:africanplug/widgets/input/text_input_field.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:africanplug/screens/login/components/validation.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginSignupScreen extends StatefulWidget {
  final bool isLogin;
  const LoginSignupScreen({this.isLogin = false});
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isSignupScreen = true;
  bool isMale = true;
  bool isRememberMe = false;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  TextEditingController _registerFirstNameController =
      new TextEditingController();
  TextEditingController _registerLastNameController =
      new TextEditingController();
  RangeValues _ageRangeValues = const RangeValues(defaultMinAge, defaultMaxAge);
  TextEditingController _registerPhoneNoController =
      new TextEditingController();
  TextEditingController _registerEmailController = new TextEditingController();
  TextEditingController _registerPasswordController =
      new TextEditingController();
  TextEditingController _registerPasswordConfirmationController =
      new TextEditingController();

  final _formKey = new GlobalKey<FormState>();
  final _registerFormKey = new GlobalKey<FormState>();

  String? _email;
  String? _password;

  String? _registerFirstName;
  String? _registerLastName;
  String? _ageRange;
  String? _registerPhoneNo;
  String? _registerEmail;
  String? _registerpassword;
  String? _passwordConfirmation;
  int minAge = defaultMinAge.toInt();
  int maxAge = defaultMaxAge.toInt();

  TextStyle _inputStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool _autoValidate = false;
  bool _registerAutoValidate = false;

  Future<String?> _loginUser(email, password, Loc location) {
    LoginController ctrl = new LoginController();
    return ctrl.authLoginUser(email, password, location);
  }

  Future<String?> _registerUser(
      String _registerFirstName,
      String _registerLastName,
      bool isMale,
      int minAge,
      int maxAge,
      String _registerPhoneNo,
      String _registerEmail,
      String _registerpassword,
      Loc location) {
    RegisterController ctrl = new RegisterController();
    return ctrl.authRegisterUser(
        _registerFirstName,
        _registerLastName,
        isMale,
        minAge,
        maxAge,
        _registerPhoneNo,
        _registerEmail,
        _registerpassword,
        location);
  }

  bool _loading = false;
  bool _registering = false;
  bool _ageChanged = false;
  bool _showAgeError = false;
  bool _showPasswordsError = false;

  @override
  void initState() {
    super.initState();

    if (widget.isLogin) {
      isSignupScreen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/rev.gif"),
                      fit: BoxFit.fill)),
              child: Container(
                padding: EdgeInsets.only(top: 90, left: 20),
                color: kPrimaryColor.withOpacity(0.9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: "Welcome",
                          style: TextStyle(
                            fontSize: 25,
                            letterSpacing: 2,
                            color: kLightTextColor,
                          ),
                          children: [
                            TextSpan(
                              text: isSignupScreen
                                  ? " to ${txtAppName},"
                                  : " Back,",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: kLightTextColor,
                              ),
                            )
                          ]),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      isSignupScreen
                          ? "Sign up to Continue"
                          : "Sign in to Continue",
                      style: TextStyle(
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          // Trick to add the shadow for the submit button
          buildBottomHalfContainer(true),
          //Main Contianer for Login and Signup
          AnimatedPositioned(
            duration: Duration(milliseconds: 700),
            curve: Curves.bounceInOut,
            top: isSignupScreen ? 200 : 230,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 700),
              curve: Curves.bounceInOut,
              height: isSignupScreen ? 410 : 250,
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width - 40,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: kActiveColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5),
                  ]),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSignupScreen = false;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                "LOGIN",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: !isSignupScreen
                                        ? Palette.activeColor
                                        : kBlack.withOpacity(0.4)),
                              ),
                              if (!isSignupScreen)
                                Container(
                                  margin: EdgeInsets.only(top: 3),
                                  height: 3,
                                  width: 55,
                                  color: kActiveColor,
                                )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSignupScreen = true;
                            });
                          },
                          child: Column(
                            children: [
                              Text(
                                "SIGNUP",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSignupScreen
                                        ? Palette.activeColor
                                        : kBlack.withOpacity(0.4)),
                              ),
                              if (isSignupScreen)
                                Container(
                                  margin: EdgeInsets.only(top: 3),
                                  height: 3,
                                  width: 55,
                                  color: kActiveColor,
                                )
                            ],
                          ),
                        )
                      ],
                    ),
                    if (isSignupScreen)
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Form(
                          key: _registerFormKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              TextInputField(
                                  lightlayout: true,
                                  placeholder: txtFirstName,
                                  icondata: Icons.person,
                                  keyboardtype: TextInputType.text,
                                  inputValidator: validateRegisterFirstName,
                                  onChanged: (value) {
                                    _registerFirstName = value;
                                  },
                                  onSaved: (value) {
                                    _registerFirstName = value;
                                  }),
                              SizedBox(
                                height: 15.0,
                              ),
                              TextInputField(
                                  lightlayout: true,
                                  placeholder: txtLastName,
                                  icondata: Icons.person,
                                  keyboardtype: TextInputType.text,
                                  inputValidator: validateRegisterLastName,
                                  onChanged: (value) {
                                    _registerLastName = value;
                                  },
                                  onSaved: (value) {
                                    _registerLastName = value;
                                  }),
                              SizedBox(
                                height: 15.0,
                              ),
                              TextInputField(
                                  lightlayout: true,
                                  placeholder: txtYourEmail,
                                  icondata: Icons.mail,
                                  keyboardtype: TextInputType.text,
                                  inputValidator: validateRegisterEmail,
                                  onChanged: (value) {
                                    _registerEmail = value;
                                  },
                                  onSaved: (value) {
                                    _registerEmail = value;
                                  }),
                              SizedBox(
                                height: 15.0,
                              ),
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, top: 10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.phone_android_outlined,
                                            color: kPrimaryColor,
                                            size: 30,
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Text("Phone Number",
                                              style: TextStyle(
                                                  fontSize: 19,
                                                  color: kPrimaryColor)),
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            bottom: 8.0, right: 8.0),
                                        child: IntlPhoneField(
                                          countryCodeTextColor: kPrimaryColor,
                                          dropDownArrowColor: kPrimaryColor,
                                          autoValidate: false,
                                          validator: validateRegisterPhone,
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: kPrimaryColor),
                                          decoration: InputDecoration(
                                            // labelText: 'Phone Number',
                                            // border: OutlineInputBorder(
                                            //     // borderSide: BorderSide(),
                                            //     ),
                                            // enabledBorder: OutlineInputBorder(
                                            //   borderSide: BorderSide(
                                            //       color: Palette.textColor1),
                                            //   borderRadius: BorderRadius.all(
                                            //       Radius.circular(10.0)),
                                            // ),
                                            // focusedBorder: OutlineInputBorder(
                                            //   borderSide: BorderSide(
                                            //       color: Palette.textColor1),
                                            //   borderRadius: BorderRadius.all(
                                            //       Radius.circular(10.0)),
                                            // ),
                                            // contentPadding: EdgeInsets.all(10),
                                            hintText: '7 - - - - - - - -',
                                            hintStyle: TextStyle(
                                                fontSize: 18,
                                                color: kPrimaryColor),
                                          ),
                                          initialCountryCode: 'KE',
                                          onChanged: (phone) {
                                            setState(() {
                                              _registerPhoneNo =
                                                  phone.completeNumber;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // decoration: BoxDecoration(
                                //     border:
                                //         Border.all(color: Palette.textColor1),
                                //     borderRadius: BorderRadius.circular(10)),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Column(
                                children: [
                                  Container(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 10.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text("Age Range: ",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: kPrimaryColor)),
                                              Text("${minAge} to ${maxAge}",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: kPrimaryColor))
                                            ],
                                          ),
                                          RangeSlider(
                                            activeColor: kPrimaryColor,
                                            inactiveColor: kPrimaryLightColor,
                                            values: _ageRangeValues,
                                            max: 75,
                                            divisions: 75,
                                            labels: RangeLabels(
                                              _ageRangeValues.start
                                                  .round()
                                                  .toString(),
                                              _ageRangeValues.end
                                                  .round()
                                                  .toString(),
                                            ),
                                            onChanged: (RangeValues values) {
                                              setState(() {
                                                _ageChanged = true;
                                                _showAgeError = false;
                                                _ageRangeValues = values;
                                                minAge = values.start.toInt();
                                                maxAge = values.end.toInt();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        border: _showAgeError
                                            ? Border.all(
                                                color: Colors.redAccent)
                                            : Border.all(color: kWhite),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  _showAgeError
                                      ? Container(
                                          width: size.width,
                                          child: Text("Set your age range",
                                              style:
                                                  TextStyle(color: Colors.red)))
                                      : SizedBox()
                                ],
                              ),
                              // _showAgeError
                              //     ? SizedBox()
                              //     : Divider(
                              //         thickness: 1.0,
                              //         color: Palette.textColor1,
                              //       ),
                              SizedBox(
                                height: 15.0,
                              ),

                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, top: 10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            MaterialCommunityIcons
                                                .gender_male_female,
                                            color: kPrimaryColor,
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("Gender : ",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: kPrimaryColor)),
                                              Text(isMale ? "Male" : "Female",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: kPrimaryColor)),
                                            ],
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, bottom: 8.0),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isMale = true;
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    margin: EdgeInsets.only(
                                                        right: 8),
                                                    decoration: BoxDecoration(
                                                        color: isMale
                                                            ? kPrimaryColor
                                                            : kPrimaryLightColor,
                                                        // border: Border.all(
                                                        //     width: 1,
                                                        //     color: isMale
                                                        //         ? Colors
                                                        //             .transparent
                                                        //         : kPrimaryColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                    child: Icon(
                                                      MaterialCommunityIcons
                                                          .account_outline,
                                                      color: isMale
                                                          ? Colors.white
                                                          : Palette.iconColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Male",
                                                    style: TextStyle(
                                                        color: kPrimaryColor),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 30,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isMale = false;
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    margin: EdgeInsets.only(
                                                        right: 8),
                                                    decoration: BoxDecoration(
                                                        color: !isMale
                                                            ? kPrimaryColor
                                                            : kPrimaryLightColor,
                                                        // border: Border.all(
                                                        //     width: 1,
                                                        //     color: !isMale
                                                        //         ? Colors
                                                        //             .transparent
                                                        //         : kPrimaryColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                    child: Icon(
                                                      MaterialCommunityIcons
                                                          .account_outline,
                                                      color: isMale
                                                          ? Palette.iconColor
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Female",
                                                    style: TextStyle(
                                                        color: kPrimaryColor),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // decoration: BoxDecoration(
                                //     border:
                                //         Border.all(color: Palette.textColor1),
                                //     borderRadius: BorderRadius.circular(10)),
                              ),
                              // Divider(
                              //   thickness: 1.0,
                              //   color: Palette.textColor1,
                              // ),
                              SizedBox(
                                height: 15.0,
                              ),
                              TextInputField(
                                  lightlayout: true,
                                  obsuretext: true,
                                  placeholder: txtPassword,
                                  icondata: MaterialCommunityIcons.lock_outline,
                                  inputValidator: validatePassword,
                                  inputController: _registerPasswordController,
                                  onChanged: (value) {
                                    _registerPasswordConfirmationController
                                        .text = '';
                                    _passwordConfirmation = '';
                                    _registerpassword = value;
                                  },
                                  onSaved: (value) {
                                    _registerpassword = value;
                                  }),
                              SizedBox(
                                height: 15.0,
                              ),
                              Container(
                                  child: Column(
                                    children: [
                                      TextInputField(
                                          enabled: (_registerpassword == null ||
                                                  _registerpassword!.isEmpty)
                                              ? false
                                              : true,
                                          lightlayout: true,
                                          obsuretext: true,
                                          placeholder: txtConfirmPassword,
                                          icondata: MaterialCommunityIcons
                                              .lock_outline,
                                          inputController:
                                              _registerPasswordConfirmationController,
                                          onChanged: (value) {
                                            _passwordConfirmation = value;
                                            if (_passwordConfirmation ==
                                                _registerpassword) {
                                              _showPasswordsError = false;
                                            }
                                          },
                                          onSaved: (value) {
                                            _passwordConfirmation = value;
                                          }),
                                      _showPasswordsError
                                          ? Text(
                                              'Password and Confirmation do not match',
                                              style: TextStyle(
                                                  color: Colors.redAccent),
                                            )
                                          : SizedBox()
                                    ],
                                  ),
                                  decoration: _showPasswordsError
                                      ? BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: Colors.redAccent),
                                          borderRadius:
                                              BorderRadius.circular(15))
                                      : BoxDecoration()),
                              SizedBox(
                                height: 30.0,
                              ),
                              // Container(
                              //   width: 200,
                              //   margin: EdgeInsets.only(top: 20),
                              //   child: RichText(
                              //     textAlign: TextAlign.center,
                              //     text: TextSpan(
                              //         text:
                              //             "By pressing 'Submit' you agree to our ",
                              //         style:
                              //             TextStyle(color: Palette.textColor2),
                              //         children: [
                              //           TextSpan(
                              //             //recognizer: ,
                              //             text: "term & conditions",
                              //             style:
                              //                 TextStyle(color: kActiveColor),
                              //           ),
                              //         ]),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    if (!isSignupScreen)
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              //                         obscureText: false,
                              // keyboardType: TextInputType.emailAddress,
                              // autofocus: false,
                              // controller: _emailController,
                              // validator: validateEmail,
                              // onChanged: (value) => _email = value,
                              // onSaved: (value) => _email = value,
                              // decoration: InputDecoration(
                              //   prefixIcon: Icon(
                              //     Icons.mail_outline,
                              //     color: Palette.iconColor,
                              //   ),
                              //   enabledBorder: OutlineInputBorder(
                              //     borderSide: BorderSide(color: Palette.textColor1),
                              //     borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              //   ),
                              //   focusedBorder: OutlineInputBorder(
                              //     borderSide: BorderSide(color: Palette.textColor1),
                              //     borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              //   ),
                              //   contentPadding: EdgeInsets.all(10),
                              //   hintText: txtYourEmail,
                              //   hintStyle: TextStyle(fontSize: 14, color: Palette.textColor1),
                              // ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TextInputField(
                                    lightlayout: true,
                                    placeholder: txtYourEmail,
                                    icondata: Icons.mail_outline,
                                    keyboardtype: TextInputType.emailAddress,
                                    inputValidator: validateEmail,
                                    onChanged: (value) {
                                      _email = value;
                                    },
                                    onSaved: (value) {
                                      _email = value;
                                    }),
                              ),
                              TextInputField(
                                  lightlayout: true,
                                  obsuretext: true,
                                  placeholder: txtPassword,
                                  icondata: MaterialCommunityIcons.lock_outline,
                                  inputValidator: validatePassword,
                                  onChanged: (value) {
                                    _password = value;
                                  },
                                  onSaved: (value) {
                                    _password = value;
                                  }),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Row(
                              //       children: [
                              //         Checkbox(
                              //           value: isRememberMe,
                              //           activeColor: Palette.textColor2,
                              //           onChanged: (value) {
                              //             setState(() {
                              //               isRememberMe = !isRememberMe;
                              //             });
                              //           },
                              //         ),
                              //         Text("Remember me",
                              //             style: TextStyle(
                              //                 fontSize: 12,
                              //                 color: Palette.textColor1))
                              //       ],
                              //     ),
                              //     TextButton(
                              //       onPressed: () {},
                              //       child: Text("Forgot Password?",
                              //           style: TextStyle(
                              //               fontSize: 12,
                              //               color: Palette.textColor1)),
                              //     )
                              //   ],
                              // )
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
          // Trick to add the submit button

          AnimatedPositioned(
            duration: Duration(milliseconds: 700),
            curve: Curves.bounceInOut,
            top: isSignupScreen ? 565 : 430,
            right: 0,
            left: 0,
            child: Center(
              child: _loading
                  ? Container(
                      height: 90,
                      width: 90,
                      padding: EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(.3),
                        //     spreadRadius: 1.5,
                        //     blurRadius: 10,
                        //   )
                        // ]
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 5.0,
                        color: kActiveColor,
                      ),
                    )
                  : InkWell(
                      child: Container(
                        height: 90,
                        width: 90,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black.withOpacity(.3),
                          //     spreadRadius: 1.5,
                          //     blurRadius: 10,
                          //   )
                          // ]
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              color: kActiveColor,
                              // gradient: LinearGradient(
                              //     colors: [
                              //       kActiveColor.shade200,
                              //       Colors.red.shade400
                              //     ],
                              //     begin: Alignment.topLeft,
                              //     end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(.3),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1))
                              ]),
                          child: Icon(
                            FlutterIcons.plug_faw5s,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () async {
                        bool isOnline = await checkOnline();
                        if (!isOnline) {
                          Flushbar(
                            icon: Icon(
                              Icons.info_outline,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.redAccent,
                            title: "Error",
                            message: "No Internet",
                            duration: Duration(seconds: 3),
                          )..show(context);
                        } else {
                          setState(() {
                            _loading = true;
                          });
                          if (!isSignupScreen) {
                            /// LOGIN FUNCTIONALITY
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
                                Navigator.pushNamed(context, '/home');
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
                          } else {
                            // Register FUNCTIONALITY
                            if (!_ageChanged) {
                              _showAgeError = true;
                              setState(() {
                                _loading = false;
                              });
                              _registerAutoValidate = true;
                            } else {
                              if (_registerFormKey.currentState!.validate()) {
                                if (_registerpassword == null ||
                                    _passwordConfirmation == null ||
                                    _passwordConfirmation !=
                                        _registerpassword) {
                                  _showPasswordsError = true;
                                  setState(() {
                                    _loading = false;
                                  });
                                } else {
                                  Loc location = await currentLocation();
                                  String? response = await _registerUser(
                                      _registerFirstName.toString(),
                                      _registerLastName.toString(),
                                      isMale,
                                      minAge,
                                      maxAge,
                                      _registerPhoneNo.toString(),
                                      _registerEmail.toString(),
                                      _registerpassword.toString(),
                                      location);

                                  if (response.toString() == 'success') {
                                    // setState(() {
                                    //   _loading = false;
                                    // });
                                    Flushbar(
                                      isDismissible: false,
                                      icon: Icon(
                                        Icons.check_circle_rounded,
                                        color: kPrimaryColor,
                                      ),
                                      backgroundColor: kPrimaryLightColor,
                                      title: "Registered successfully",
                                      message: "logging in..",
                                      duration: Duration(seconds: 3),
                                    )..show(context);
                                    String? _loginResponse = await _loginUser(
                                        _registerEmail,
                                        _registerpassword,
                                        location);

                                    if (_loginResponse.toString() ==
                                        'success') {
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
                                      // Navigator.pop(context);
                                      // Navigator.pushNamed(context, "/home");
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, '/home');
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
                                }
                              } else {
                                setState(() {
                                  _loading = false;
                                });
                                _registerAutoValidate = true;
                              }
                            }
                          }
                        }
                      }),
            ),
          ),
          // Bottom buttons
          Positioned(
            top: MediaQuery.of(context).size.height - 100,
            right: 0,
            left: 0,
            child: Column(
              children: [
                // isSignupScreen ? SizedBox() : Text("Or Signin with"),
                SizedBox(height: 30.0),
                isSignupScreen
                    ? Container(
                        width: 200,
                        margin: EdgeInsets.only(top: 20),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: "By pressing 'Submit' you agree to our ",
                              style: TextStyle(color: Palette.textColor2),
                              children: [
                                TextSpan(
                                  //recognizer: ,
                                  text: "term & conditions",
                                  style: TextStyle(color: kActiveColor),
                                ),
                              ]),
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(height: 22.0),
                          Container(
                            // margin: EdgeInsets.only(right: 20, left: 20, top: 15),
                            color: kScaffoldColor,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // buildTextButton(MaterialCommunityIcons.facebook,
                                //     "Facebook", Palette.facebookColor),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: isRememberMe,
                                      activeColor: kPrimaryColor,
                                      onChanged: (value) {
                                        setState(() {
                                          isRememberMe = !isRememberMe;
                                        });
                                      },
                                    ),
                                    Text("Remember me",
                                        style:
                                            TextStyle(color: kLightTextColor))
                                  ],
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Row(
                                    children: [
                                      Text("Forgot password ?",
                                          style:
                                              TextStyle(color: kLightTextColor))
                                    ],
                                  ),
                                ),
                                // Column(
                                //   children: [
                                //     Text("Forgot password ?",
                                //         style:
                                //             TextStyle(color: Palette.textColor2)),
                                //     Text("Reset",
                                //         style: TextStyle(color: kActiveColor)),
                                //   ],
                                // )
                                // buildTextButton(MaterialCommunityIcons.google_plus,
                                //     "Google", Palette.googleColor),
                              ],
                            ),
                          ),
                        ],
                      )
              ],
            ),
          )
        ],
      ),
    );
  }

  Container buildSigninSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          buildTextField(Icons.mail_outline, "info@demouri.com", false, true),
          buildTextField(
              MaterialCommunityIcons.lock_outline, "**********", true, false),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isRememberMe,
                    activeColor: Palette.textColor2,
                    onChanged: (value) {
                      setState(() {
                        isRememberMe = !isRememberMe;
                      });
                    },
                  ),
                  Text("Remember me",
                      style: TextStyle(fontSize: 12, color: Palette.textColor1))
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text("Forgot Password?",
                    style: TextStyle(fontSize: 12, color: Palette.textColor1)),
              )
            ],
          )
        ],
      ),
    );
  }

  Container buildSignupSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          buildTextField(MaterialCommunityIcons.account_outline, "User Name",
              false, false),
          buildTextField(
              MaterialCommunityIcons.email_outline, "email", false, true),
          buildTextField(
              MaterialCommunityIcons.lock_outline, "password", true, false),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isMale = true;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            color: isMale
                                ? Palette.textColor2
                                : Colors.transparent,
                            border: Border.all(
                                width: 1,
                                color: isMale
                                    ? Colors.transparent
                                    : Palette.textColor1),
                            borderRadius: BorderRadius.circular(15)),
                        child: Icon(
                          MaterialCommunityIcons.account_outline,
                          color: isMale ? Colors.white : Palette.iconColor,
                        ),
                      ),
                      Text(
                        "Male",
                        style: TextStyle(color: Palette.textColor1),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isMale = false;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            color: isMale
                                ? Colors.transparent
                                : Palette.textColor2,
                            border: Border.all(
                                width: 1,
                                color: isMale
                                    ? Palette.textColor1
                                    : Colors.transparent),
                            borderRadius: BorderRadius.circular(15)),
                        child: Icon(
                          MaterialCommunityIcons.account_outline,
                          color: isMale ? Palette.iconColor : Colors.white,
                        ),
                      ),
                      Text(
                        "Female",
                        style: TextStyle(color: Palette.textColor1),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   width: 200,
          //   margin: EdgeInsets.only(top: 20),
          //   child: RichText(
          //     textAlign: TextAlign.center,
          //     text: TextSpan(
          //         text: "By pressing 'Submit' you agree to our ",
          //         style: TextStyle(color: Palette.textColor2),
          //         children: [
          //           TextSpan(
          //             //recognizer: ,
          //             text: "term & conditions",
          //             style: TextStyle(color: kActiveColor),
          //           ),
          //         ]),
          //   ),
          // ),
        ],
      ),
    );
  }

  TextButton buildTextButton(
      IconData icon, String title, Color backgroundColor) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
          side: BorderSide(width: 1, color: Colors.grey),
          minimumSize: Size(145, 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          primary: Colors.white,
          backgroundColor: backgroundColor),
      child: Row(
        children: [
          Icon(
            icon,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            title,
          )
        ],
      ),
    );
  }

  Widget buildBottomHalfContainer(bool showShadow) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 700),
      curve: Curves.bounceInOut,
      top: isSignupScreen ? 565 : 430,
      right: 0,
      left: 0,
      child: Center(
        child: Container(
          height: 90,
          width: 90,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                if (showShadow)
                  BoxShadow(
                    color: Colors.black.withOpacity(.3),
                    spreadRadius: 1.5,
                    blurRadius: 10,
                  )
              ]),
          child: !showShadow
              ? Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [kActiveColor, Colors.red.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(.3),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 1))
                      ]),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                )
              : Center(),
        ),
      ),
    );
  }

  Widget buildTextField(
      IconData icon, String hintText, bool isPassword, bool isEmail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Palette.iconColor,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Palette.textColor1),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Palette.textColor1),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          contentPadding: EdgeInsets.all(10),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: Palette.textColor1),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:flutter/cupertino.dart';

// BACKEND
// const BACKEND_URL = "https://plug-apis.herokuapp.com/graphql";
// const REGISTER_URL = "https://plug27.herokuapp.com/graphq";
// const BACKEND_URL = "https://plug27.herokuapp.com/graphql";
// const LOGIN_URL = "https://plug27.herokuapp.com/login";

const REGISTER_URL = "https://plug27.herokuapp.com/graphq";
const BACKEND_URL = "https://plug27.herokuapp.com/graphql";
const LOGIN_URL = "https://plug27.herokuapp.com/login";

// https://brianmutugi.pythonanywhere.com/graphql
// COLORS
// const kPrimaryColor = Color(0xFF11823B);
// const kPrimaryLightColor = Color(0xFFD0FAE4);
const kPrimaryColor = Color(0xFF040848);
const kPrimaryLightColor = Color(0xFFBB86FC);
const kBackgroundColor = Color(0xFFBB86FC);
const kLightTextColor = Color(0xFFD0FAE4);
const kNeutralColor = Color(0xFF215268);
const kBlack = Colors.black;
const kWhite = Colors.white;
const kRed = Colors.red;
const kActiveColor = Color(0xFF03DAC5);
const kScaffoldColor = Color(0xFF1b1e58);

// TEXT
const txtAppName = "27Plug";
const txtVersion = "1";
const txtIntro = "WELCOME TO 27 PLUG";
const txtLogin = "LOGIN";
const txtYourEmail = "Your Email";
const txtPassword = "Password";
const txtConfirmPassword = "Confirm Password";
const txtDontHaveAccount = "Don't have an Account ? ";
const txtHasAccount = "Already Have an Account ? ";
const txtSignUp = "Sign Up";
const txtSignIn = "Sign In";
const txtYourName = "Your Name";
const txtFirstName = "First Name";
const txtLastName = "Last Name";
const txtDefaultDpUrl =
    "https://www.pngitem.com/pimgs/m/421-4212617_person-placeholder-image-transparent-hd-png-download.png";
const defaultMinAge = 18.0;
const defaultMaxAge = 35.0;
const phoneNoPlaceHolder = "254---------";
const txtOR = "OR";

// NUMBERS
const numCurveRadius = 8.0;

// COLOR PALETTE
class Palette {
  static const Color iconColor = Color(0xFFB6C7D1);
  static const Color activeColor = Color(0xFF09126C);
  static const Color textColor1 = Color(0XFFA7BCC7);
  static const Color textColor2 = Color(0XFF9BB3C0);
  static const Color facebookColor = Color(0xFF3B5999);
  static const Color googleColor = Color(0xFFDE4B39);
  static const Color backgroundColor = Color(0xFFECF3F9);
}

/// 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 ///
/// git clone https://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@github.com/MutugiBrian/27Plug-Apis.git
///
/// S3 Credentials
///
/// s3_endpoint = 'https://27-plug-files.s3.eu-west-3.amazonaws.com/uploads/'
// s3_key_id = 'AKIA3KIAET77MPMN4WNZ'
// s3_secret = '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'
// s3_region_name = 'eu-west-3'

// s3_client = boto3.client('s3', region_name=s3_region_name, endpoint_url=s3_endpoint +
//                          'videos/', aws_access_key_id=s3_key_id, aws_secret_access_key=s3_secret)
// thumbnail_upload_output = s3_client.put_object(Body=thumbnail_file, Bucket='thumbnails', Key=secure_filename(
//     thumbnail_file.filename), ContentType=content_type)

// s3_client = boto3.client('s3', region_name=s3_region_name, endpoint_url=s3_endpoint,
//                          aws_access_key_id=s3_key_id, aws_secret_access_key=s3_secret)
// video_upload_output = s3_client.put_object(Body=video_file, Bucket='videos', Key=secure_filename(
//     video_file.filename), ContentType=content_type)
const kS3BucketName = "27-plug-files";
const kS3PoolID = "eu-west-3:b9ff5831-45ac-46b4-b0b2-c06a1c509ad4";
//const kS3Region = AWSRegions.euWest3;

class SizeConfig {
  late double _screenWidth;
  late double _screenHeight;
  double _blockSizeHorizontal = 0;
  double _blockSizeVertical = 0;

  late double textMultiplier;
  late double imageSizeMultiplier;
  late double heightMultiplier;
  late double widthMultiplier;
  bool isPortrait = true;
  bool isMobilePortrait = false;

  @override
  void initState(BoxConstraints constraints, Orientation orientation) {
    if (orientation == Orientation.portrait) {
      _screenWidth = constraints.maxWidth;
      _screenHeight = constraints.maxHeight;
      isPortrait = true;
      if (_screenWidth < 450) {
        isMobilePortrait = true;
      }
    } else {
      _screenWidth = constraints.maxHeight;
      _screenHeight = constraints.maxWidth;
      isPortrait = false;
      isMobilePortrait = false;
    }

    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    textMultiplier = _blockSizeVertical;
    imageSizeMultiplier = _blockSizeHorizontal;
    heightMultiplier = _blockSizeVertical;
    widthMultiplier = _blockSizeHorizontal;

    print(_blockSizeHorizontal);
    print(_blockSizeVertical);
  }
}

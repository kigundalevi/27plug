import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/screens/login/login_signup.dart';
import 'package:africanplug/screens/upload/upload.dart';
import 'package:africanplug/screens/videos/videos_screen.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Widget MainMenu(
    context, current_page, slideAnimation, menuScaleAnimation, size, userid) {
  print(current_page);
  return SlideTransition(
    position: slideAnimation,
    child: ScaleTransition(
      scale: menuScaleAnimation,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 50.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                          // margin: EdgeInsets.only(top: size.height / 11),
                          height: size.height / 12,
                          width: size.width / 6,
                          child: FittedBox(
                            child: new FloatingActionButton(
                              heroTag: "btn2",
                              elevation: 5.0,
                              backgroundColor: kWhite,
                              onPressed: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: new Container(
                                  width: size.height / 12,
                                  height: size.height / 12,
                                  decoration: new BoxDecoration(
                                    color: kPrimaryColor,
                                    image: new DecorationImage(
                                      //  https://pixinvent.com/materialize-material-design-admin-template/app-assets/images/user/12.jpg
                                      // https://media-exp1.licdn.com/dms/image/C5603AQGs80XgVG-nxg/profile-displayphoto-shrink_200_200/0?e=1586995200&v=beta&t=XQSVmNAVycY5cSWSkIWELb9NJ-Cwjx2smaH0nclMmpU
                                      image: new AssetImage(
                                          "assets/images/brian.jpg"),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: new BorderRadius.all(
                                        new Radius.circular(size.height / 3)),
                                    //  border: new Border.all(
                                    //        color: mainColor,
                                    //        width: 4.0,
                                    //  ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                      Container(
                        // color: kPrimaryColor,
                        margin: EdgeInsets.only(top: 12, left: 10),
                        height: size.height / 12,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Brian Mutugi",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "116 Subscribers",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Container(
                  //     margin: EdgeInsets.only(top: size.height / 6),
                  //     width: size.width / 1.8,
                  //     child: Material(
                  //       color: Colors.white,
                  //       elevation: 20.0,
                  //       shadowColor: Color(0x802196F3),
                  //       borderRadius: BorderRadius.circular(5.0),
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(4.0),
                  //         child: Column(
                  //           children: <Widget>[
                  //             Row(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: <Widget>[
                  //                 Align(
                  //                   alignment: Alignment.center,
                  //                   child: Text(
                  //                     "Jane Doe",
                  //                     style: TextStyle(
                  //                         fontSize: 18,
                  //                         fontWeight: FontWeight.bold),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             Row(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: <Widget>[
                  //                 Icon(
                  //                   Icons.star,
                  //                   color: Colors.purpleAccent,
                  //                   size: 18.0,
                  //                 ),
                  //                 Icon(
                  //                   Icons.star,
                  //                   color: Colors.purpleAccent,
                  //                   size: 18.0,
                  //                 ),
                  //                 Icon(
                  //                   Icons.star,
                  //                   color: Colors.purpleAccent,
                  //                   size: 18.0,
                  //                 ),
                  //                 Icon(
                  //                   Icons.star,
                  //                   color: Colors.purpleAccent,
                  //                   size: 18.0,
                  //                 ),
                  //                 Icon(
                  //                   Icons.star,
                  //                   color: Colors.purpleAccent,
                  //                   size: 18.0,
                  //                 ),
                  //                 Text(
                  //                   "5.0",
                  //                   style: TextStyle(color: Colors.black),
                  //                 ),
                  //               ],
                  //             ),
                  //             Row(
                  //               mainAxisSize: MainAxisSize.max,
                  //               mainAxisAlignment:
                  //                   MainAxisAlignment.spaceAround,
                  //               children: <Widget>[
                  //                 Icon(
                  //                   Icons.location_on,
                  //                   color: kPrimaryColor,
                  //                 ),
                  //                 Text("London, England"),
                  //               ],
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     )),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: size.width / 1.8,
                child: Divider(
                  color: Colors.black38,
                ),
              ),
              MenuOption(
                  context, size, Icons.dashboard, "Home", "home", current_page),
              Container(
                width: size.width / 1.8,
                child: Divider(
                  color: Colors.black38,
                ),
              ),
              MenuOption(context, size, Icons.video_call_outlined, "Upload",
                  "upload", current_page),
              Container(
                width: size.width / 1.8,
                child: Divider(
                  color: Colors.black38,
                ),
              ),
              Container(
                height: size.height / 20,
                child: FlatButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.video_library,
                      color: kPrimaryLightColor,
                      size: 22.0,
                    ),
                    label: Text(
                      "My Videos",
                      style: TextStyle(color: kPrimaryColor, fontSize: 15.0),
                    )),
              ),
              Container(
                width: size.width / 1.8,
                child: Divider(
                  color: Colors.black38,
                ),
              ),
              Container(
                height: size.height / 20,
                child: FlatButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.watch_later,
                      color: kPrimaryLightColor,
                      size: 22.0,
                    ),
                    label: Text(
                      "Watch Later",
                      style: TextStyle(color: kPrimaryColor, fontSize: 15.0),
                    )),
              ),
              Container(
                width: size.width / 1.8,
                child: Divider(
                  color: Colors.black38,
                ),
              ),
              Container(
                height: size.height / 20,
                child: FlatButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.favorite,
                      color: kPrimaryLightColor,
                      size: 22.0,
                    ),
                    label: Text(
                      "Favourites",
                      style: TextStyle(color: kPrimaryColor, fontSize: 15.0),
                    )),
              ),
              Container(
                width: size.width / 1.8,
                child: Divider(
                  color: Colors.black38,
                ),
              ),
              Container(
                height: size.height / 20,
                child: FlatButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.history,
                      color: kPrimaryLightColor,
                      size: 22.0,
                    ),
                    label: Text(
                      "History",
                      style: TextStyle(color: kPrimaryColor, fontSize: 15.0),
                    )),
              ),
              Container(
                width: size.width / 1.8,
                child: Divider(
                  color: Colors.black38,
                ),
              ),
              SizedBox(
                height: size.height / 5.1,
              ),
              Container(
                height: size.height / 20,
                child: FlatButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.settings,
                      color: kPrimaryLightColor,
                      size: 22.0,
                    ),
                    label: Text(
                      "Account Settings",
                      style: TextStyle(color: kPrimaryColor, fontSize: 15.0),
                    )),
              ),
              Container(
                width: size.width / 1.8,
                child: Divider(
                  color: Colors.black38,
                ),
              ),
              Container(
                height: size.height / 22,
                child: FlatButton.icon(
                    onPressed: () {
                      logout(context);
                    },
                    icon: Icon(
                      Icons.logout,
                      color: kPrimaryLightColor,
                      size: 26.0,
                    ),
                    label: Text(
                      "Log Out",
                      style: TextStyle(color: kPrimaryColor, fontSize: 15.0),
                    )),
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Container MenuOption(context, size, IconData icon, String text, String page,
    String currentPage) {
  return Container(
    decoration: BoxDecoration(
        color: currentPage == "/${page}" ? kPrimaryLightColor : Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8))),
    height: size.height / 20,
    width: size.width / 1.8,
    alignment: Alignment.topLeft,
    // width: size.width / 1.8,
    child: FlatButton.icon(
        // minWidth: size.width / 1.8,
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, "/${page}");
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) {
          //   return VideosScreen();
          // }));
        },
        icon: Icon(
          icon,
          color: currentPage == "/${page}" ? kPrimaryColor : kPrimaryLightColor,
          size: 22.0,
        ),
        label: Text(
          text,
          style: TextStyle(color: kPrimaryColor, fontSize: 15.0),
        )),
  );
}

void logout(context) {
  GraphQLConfiguration.removeToken();
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => LoginSignupScreen(isLogin: true)),
      ModalRoute.withName('/'));
}

import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:africanplug/landing.dart';
import 'package:africanplug/main.dart';
import 'package:africanplug/models/user.dart';
import 'package:africanplug/screens/login/login_signup.dart';
import 'package:africanplug/screens/upload/upload.dart';
import 'package:africanplug/screens/videos/videos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Widget MainMenu(
    context, current_page, slideAnimation, menuScaleAnimation, size) {
  User user = currentUser();
  return SlideTransition(
    position: slideAnimation,
    child: ScaleTransition(
      scale: menuScaleAnimation,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 50.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: user.id != 1
              ? Column(
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
                                            image:
                                                new NetworkImage(user.dp_url),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: new BorderRadius.all(
                                              new Radius.circular(
                                                  size.height / 3)),
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
                                    user.first_name + " " + user.last_name,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    user.user_type, //TODO:Put subscribers here
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                    MenuOption(context, size, Icons.dashboard, "Home", "home",
                        current_page),
                    Container(
                      width: size.width / 1.8,
                      child: Divider(
                        color: Colors.black38,
                      ),
                    ),
                    MenuOption(context, size, Icons.video_call_outlined,
                        "Upload", "upload", current_page),
                    Container(
                      width: size.width / 1.8,
                      child: Divider(
                        color: Colors.black38,
                      ),
                    ),
                    MenuOption(context, size, Icons.video_library, "My Videos",
                        "myvideos", current_page),
                    Container(
                      width: size.width / 1.8,
                      child: Divider(
                        color: Colors.black38,
                      ),
                    ),
                    // MenuOption(context, size, Icons.watch_later, "Watch Later",
                    //     "watchlater", current_page),
                    // Container(
                    //   width: size.width / 1.8,
                    //   child: Divider(
                    //     color: Colors.black38,
                    //   ),
                    // ),
                    // MenuOption(context, size, Icons.favorite, "Favourites",
                    //     "favourites", current_page),
                    // Container(
                    //   width: size.width / 1.8,
                    //   child: Divider(
                    //     color: Colors.black38,
                    //   ),
                    // ),
                    // MenuOption(context, size, Icons.history, "History",
                    //     "history", current_page),
                    // Container(
                    //   width: size.width / 1.8,
                    //   child: Divider(
                    //     color: Colors.black38,
                    //   ),
                    // ),
                    SizedBox(
                      height: size.height / 5.1,
                    ),
                    // MenuOption(context, size, Icons.help, "Contact Support",
                    //     "support", current_page),
                    // Container(
                    //   width: size.width / 1.8,
                    //   child: Divider(
                    //     color: Colors.black38,
                    //   ),
                    // ),
                    MenuButton(
                        context, size, Icons.logout, "Log Out", "support", () {
                      logout(context);
                    }),
                    Container(
                      width: size.width / 1.8,
                      child: Divider(
                        color: Colors.black38,
                      ),
                    ),
                    // MenuButton(
                    //     context,
                    //     size,
                    //     Icons.copyright,
                    //     DateTime.now().year.toString() + " 27Plug v1",
                    //     "copyright",
                    //     () {}),
                  ],
                )
              : Column(
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
                                                "assets/images/user.png"),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: new BorderRadius.all(
                                              new Radius.circular(
                                                  size.height / 3)),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Guest",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "@" + txtAppName.toLowerCase(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                    MenuOption(context, size, FlutterIcons.account_edit_mco,
                        "Register", "loginRegister", current_page),
                    Container(
                      width: size.width / 1.8,
                      child: Divider(
                        color: Colors.black38,
                      ),
                    ),
                    MenuOption(context, size, Icons.login, "Login",
                        "loginRegister", current_page),
                    Container(
                      width: size.width / 1.8,
                      child: Divider(
                        color: Colors.black38,
                      ),
                    ),
                    SizedBox(
                      height: size.height / 2.09,
                    ),
                    // MenuOption(context, size, Icons.help, "Contact Support",
                    //     "support", current_page),
                    // Container(
                    //   width: size.width / 1.8,
                    //   child: Divider(
                    //     color: Colors.black38,
                    //   ),
                    // ),
                    // MenuOption(context, size, Icons.info_outline, "About",
                    //     "about", current_page),
                    // Container(
                    //   width: size.width / 1.8,
                    //   child: Divider(
                    //     color: Colors.black38,
                    //   ),
                    // ),
                    MenuButton(
                        context,
                        size,
                        Icons.copyright,
                        txtAppName +
                            " v" +
                            txtVersion +
                            " " +
                            DateTime.now().year.toString(),
                        "App", () {
                      // logout(context);
                    })

                    // MenuButton(
                    //     context,
                    //     size,
                    //     Icons.copyright,
                    //     DateTime.now().year.toString() + " 27Plug v1",
                    //     "copyright",
                    //     () {}),
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
        color: currentPage == "/${page}" ? kPrimaryColor : kBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(8))),
    height: size.height / 20,
    width: size.width / 1.8,
    alignment: Alignment.topLeft,
    // width: size.width / 1.8,
    child: FlatButton.icon(
        // minWidth: size.width,
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
          color: currentPage == "/${page}" ? kActiveColor : kPrimaryColor,
          size: 22.0,
        ),
        label: Text(
          text,
          style: TextStyle(
              color: currentPage == "/${page}" ? kActiveColor : kPrimaryColor,
              fontSize: 15.0),
        )),
  );
}

Container MenuButton(
    context, size, IconData icon, String text, String currentPage, onClick) {
  return Container(
    decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(8))),
    height: size.height / 20,
    width: size.width / 1.8,
    alignment: Alignment.topLeft,
    // width: size.width / 1.8,
    child: FlatButton.icon(
        // minWidth: size.width / 1.8,
        onPressed: onClick,
        icon: Icon(
          icon,
          color: kPrimaryColor,
          size: 22.0,
        ),
        label: Text(
          text,
          style: TextStyle(color: kPrimaryColor, fontSize: 15.0),
        )),
  );
}

void logout(context) {
  appBox.delete('user');
  GraphQLConfiguration.removeToken();
  // Navigator.pop(context);
  // Navigator.pushNamed(context, '/landing');
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LandingScreen(),
      ),
      (route) => false);
}

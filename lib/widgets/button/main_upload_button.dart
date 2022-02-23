import 'package:africanplug/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class MainUploadButton extends StatelessWidget {
  const MainUploadButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(40)),
      child: Material(
        elevation: 8.0,
        color: Colors.black54,
        child: InkWell(
          child: Container(
            height: 80,
            width: 80,
            // margin: EdgeInsets.only(left: 3, top: 3, right: 5, bottom: 4),
            decoration: BoxDecoration(
                color: kActiveColor,
                borderRadius: BorderRadius.circular(52),
                boxShadow: [
                  BoxShadow(
                    // color: Colors.grey.shade50,
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset(
                      0, // horizontal, move right 10
                      4, // vertical, move down 10
                    ),
                  )
                ]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FlutterIcons.plug_faw5s,
                  color: kWhite,
                ),
                Text(
                  "Upload",
                  style: TextStyle(fontSize: 13, color: kBlack),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          // Container(
          //   height: size.height * 0.05,
          //   width: size.width * 0.09,
          //   child: Column(
          //     children: [
          //       Icon(Icons.video_call_outlined),
          //       Text(
          //         "Upload",
          //         style: TextStyle(fontSize: 10),
          //         textAlign: TextAlign.center,
          //       )
          //     ],
          //   ),
          // ),
          // style: ElevatedButton.styleFrom(
          //     elevation: 10.0,
          //     primary: Palette.facebookColor.withOpacity(1.0),
          //     padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20)),
          onTap: () {
            Navigator.pushNamed(context, "/upload");
          },
        ),
      ),
    );
  }
}

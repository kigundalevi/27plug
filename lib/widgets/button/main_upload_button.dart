import 'package:africanplug/config/config.dart';
import 'package:flutter/material.dart';

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
        child: ElevatedButton(
          child: Container(
            height: size.height * 0.05,
            width: size.width * 0.09,
            child: Column(
              children: [
                Icon(Icons.video_call_outlined),
                Text(
                  "Upload",
                  style: TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          style: ElevatedButton.styleFrom(
              primary: kPrimaryColor,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20)),
          onPressed: () {
            Navigator.pushNamed(context, "/upload");
          },
        ),
      ),
    );
  }
}

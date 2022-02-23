import 'package:africanplug/config/config.dart';
import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  final String placeholder;
  final IconData icondata;
  final double? iconsize;
  final Color? iconcolor;
  final bool enabled;
  final bool obsuretext;
  final TextEditingController? inputController;
  final String? Function(String?)? inputValidator;
  final Function(String?)? onChanged;
  final Function(String?)? onSaved;
  final TextInputType keyboardtype;
  final Color borderColor;
  const TextInputField({
    Key? key,
    required this.placeholder,
    required this.icondata,
    this.iconsize = 30,
    this.iconcolor = Palette.iconColor,
    this.obsuretext = false,
    this.inputController,
    this.inputValidator,
    this.onChanged,
    this.onSaved,
    this.keyboardtype = TextInputType.text,
    this.enabled = true,
    this.borderColor = Palette.textColor1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      obscureText: obsuretext,
      keyboardType: keyboardtype,
      minLines: 1,
      maxLines: 5,
      autofocus: false,
      controller: inputController,
      validator: inputValidator,
      onChanged: onChanged,
      onSaved: onSaved,
      cursorColor: kPrimaryColor,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icondata,
          color: iconcolor,
          size: iconsize,
        ),
        // enabledBorder: OutlineInputBorder(
        //   borderSide: BorderSide(color: borderColor),
        //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
        // ),
        // focusedBorder: OutlineInputBorder(
        //   borderSide: BorderSide(color: Palette.textColor1),
        //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
        // ),
        // contentPadding: EdgeInsets.all(0.0),
        hintText: placeholder,
        hintStyle: TextStyle(fontSize: 14, color: Palette.textColor1),
      ),
    );
  }
}

import 'package:africanplug/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class TextInputField extends StatefulWidget {
  final String placeholder;
  final IconData icondata;
  final double? iconsize;
  final bool lightlayout;
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
    this.lightlayout = false,
    this.inputController,
    this.inputValidator,
    this.onChanged,
    this.onSaved,
    this.keyboardtype = TextInputType.text,
    this.enabled = true,
    this.borderColor = Palette.textColor1,
  }) : super(key: key);

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  bool _inputObscured = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: !widget.lightlayout ? Palette.textColor1 : kPrimaryColor),
      enabled: widget.enabled,
      obscureText: widget.obsuretext ? _inputObscured : false,
      keyboardType: widget.keyboardtype,
      minLines: 1,
      maxLines: widget.obsuretext ? 1 : 5,
      autofocus: false,
      controller: widget.inputController,
      validator: widget.inputValidator,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      cursorColor: kPrimaryColor,
      decoration: InputDecoration(
        prefixIcon: Icon(
          widget.icondata,
          color: !widget.lightlayout ? widget.iconcolor : kPrimaryColor,
          size: widget.iconsize,
        ),
        suffixIcon: widget.obsuretext
            ? InkWell(
                child: Icon(
                  _inputObscured
                      ? FlutterIcons.eye_faw5s
                      : FlutterIcons.eye_slash_faw5s,
                  color: !widget.lightlayout ? widget.iconcolor : kPrimaryColor,
                  size: 20,
                ),
                onTap: () {
                  setState(() {
                    _inputObscured = !_inputObscured;
                  });
                },
              )
            : SizedBox(),
        // enabledBorder: OutlineInputBorder(
        //   borderSide: BorderSide(color: borderColor),
        //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
        // ),
        // focusedBorder: OutlineInputBorder(
        //   borderSide: BorderSide(color: Palette.textColor1),
        //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
        // ),
        // contentPadding: EdgeInsets.all(0.0),
        hintText: widget.placeholder,
        hintStyle: TextStyle(
            fontSize: 18,
            color: !widget.lightlayout ? Palette.textColor1 : kPrimaryColor),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLines;
  final bool? readOnly;
  final void Function()? onPressed;
  final String text;
  final Text hintLabel;
  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.maxLines,
      required this.hintLabel,
      this.readOnly,
        this.text='',
        this.onPressed
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      child: TextFormField(

        readOnly: readOnly ?? false,
        maxLines: maxLines ?? null,
        controller: controller,
        decoration: InputDecoration(
          label: hintLabel,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(46),
              topRight: Radius.circular(46),
              bottomLeft: Radius.circular(46),
              bottomRight: Radius.circular(46),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            // borderSide: BorderSide(color: Colors.blue, width: 0.4),
            borderSide: BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(46),
              topRight: Radius.circular(46),
              bottomLeft: Radius.circular(46),
              bottomRight: Radius.circular(46),
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hintText,
          hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              color: Colors.black,
              letterSpacing: -0.33,
              fontFamily: 'Montserrat'),
        ),
        validator: (v) {
          if (v!.isEmpty) {
            return "Enter the $hintText";
          }
          return null;
        },
      ),
    );
  }
}

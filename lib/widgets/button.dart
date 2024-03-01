import 'package:flutter/material.dart';
class Button extends StatelessWidget {
  Button({super.key,required this.onPressed,required this.icon,required this.text});
  Icon icon;
  String text;
  void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff102E44),
          minimumSize: Size.fromHeight(50)
      ),
      onPressed: onPressed, label: Text(text,style: TextStyle(
      color: Color.fromRGBO(255, 255, 255, 1),
      fontFamily: 'Montserrat',
      fontSize: 17,
    ),),icon:icon , );
  }
}

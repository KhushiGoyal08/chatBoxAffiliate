import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class ChatField extends StatelessWidget {
  ChatField({
    super.key,
    required this.controller,
    required this.hintText,
    
    required this.onPressed,
  });

  final TextEditingController controller;
  final String hintText;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Color(0xff102E44),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
        child: TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
          maxLines: null,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
              prefixIcon: IconButton(
                  onPressed: onPressed,
                  icon: Icon(
                    Icons.upload_file,
                    color: Colors.white,
                  )),
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }
}

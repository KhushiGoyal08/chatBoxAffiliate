import 'dart:io';

import 'package:flutter/material.dart';

class PreviewImagePage extends StatelessWidget {
  final String imagePath;

  const PreviewImagePage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(
                context,
              );
            },
            child: const Icon(
              Icons.cancel,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff102E44),
          onPressed: () {
            // Send the image when the FAB is pressed
            Navigator.pop(
                context, true); // Signal that the image should be sent
          },
          child: Icon(Icons.check),
        ),
      ),
    );
  }
}

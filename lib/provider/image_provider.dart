import 'dart:io';

import 'package:flutter/material.dart';

class ImageProviderClass with ChangeNotifier {
  File? _image;

  File? get image => _image;

  void setImage(File? image) {
    _image = image;
    notifyListeners();
  }
}
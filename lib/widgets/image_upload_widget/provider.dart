import 'dart:io';
import 'package:flutter/material.dart';

class ImageUploadProvider extends ChangeNotifier {
  final List<File> _selectedImages = [];
  List<File> get selectedImages => _selectedImages;

  void addImages(List<File> images) {
    _selectedImages.addAll(images);
    notifyListeners();
  }

  void removeImageAt(int index) {
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  void clearAll() {
    _selectedImages.clear();
    notifyListeners();
  }
}

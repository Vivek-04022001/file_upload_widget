import 'dart:io';
import 'package:flutter/material.dart';

class VideoUploadProvider extends ChangeNotifier {
  final List<File> _selectedVideos = [];
  List<File> get selectedVideos => _selectedVideos;

  void addVideos(List<File> videos) {
    _selectedVideos.addAll(videos);
    notifyListeners();
  }

  void removeVideoAt(int index) {
    _selectedVideos.removeAt(index);
    notifyListeners();
  }

  void clearAll() {
    _selectedVideos.clear();
    notifyListeners();
  }
}

import 'dart:io';
import 'package:flutter/material.dart';

class AudioUploadProvider extends ChangeNotifier {
  final List<File> _selectedAudios = [];
  List<File> get selectedAudios => _selectedAudios;

  void addAudios(List<File> audios) {
    _selectedAudios.addAll(audios);
    notifyListeners();
  }

  void removeAudioAt(int index) {
    _selectedAudios.removeAt(index);
    notifyListeners();
  }

  void clearAll() {
    _selectedAudios.clear();
    notifyListeners();
  }
}

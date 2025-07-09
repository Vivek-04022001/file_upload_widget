import 'dart:io';
import 'package:flutter/material.dart';

class DocumentUploadProvider extends ChangeNotifier {
  final List<File> _selectedDocs = [];
  List<File> get selectedDocs => _selectedDocs;

  void addDocs(List<File> docs) {
    _selectedDocs.addAll(docs);
    notifyListeners();
  }

  void removeDocAt(int index) {
    _selectedDocs.removeAt(index);
    notifyListeners();
  }

  void clearAll() {
    _selectedDocs.clear();
    notifyListeners();
  }
}

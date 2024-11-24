import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  String _selectedCategory = 'Korean_food';

  String get selectedCategory => _selectedCategory;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  List<String> _categories = [];
  String _selectedCategory = '';

  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;

  Future<void> fetchCategories() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('카테고리').get();
      _categories = querySnapshot.docs.map((doc) => doc.id).toList();

      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}

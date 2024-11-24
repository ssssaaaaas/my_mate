import 'package:cloud_firestore/cloud_firestore.dart';

enum Category {
  korean_food,
  Late_snack,
  Chinese,
  Japanese,
  Dessert,
  Western_food
}

class Product {
  const Product({
    required this.category,
    required this.id,
    required this.title,
    required this.price,
    required this.gender,
    required this.location,
  });

  final Category category;
  final int id;
  final String title;
  final int price;
  final String gender;
  final GeoPoint location;
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addMate({
    required String category,
    required String title,
    required String memo,
    required String gender,
    required int count,
    required GeoPoint location,
    required int currentCount,
  }) async {
    try {
      await _firestore.collection(category).add({
        'title': title,
        'memo': memo,
        'gender': gender,
        'count': count,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
        'currentCount': currentCount,
      });
      print('Document successfully added to $category collection!');
    } catch (e) {
      print('Failed to add document to $category: $e');
    }
  }
}

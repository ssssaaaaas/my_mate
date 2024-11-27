import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addMate({
    required String category,
    required String title,
    required String memo,
    required String gender,
    required String count,
    required GeoPoint location,
  }) async {
    try {
      await _firestore.collection(category).add({
        'title': title,
        'memo': memo,
        'gender': gender,
        'count': count,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Document successfully added to $category collection!');
    } catch (e) {
      print('Failed to add document to $category: $e');
    }
  }

  getCalendarEntry(String uid, DateTime date) {}

  deleteCalendarEntry(String uid, DateTime date) {}

  saveCalendarEntry(String uid, DateTime date, String text, String? s) {}
}

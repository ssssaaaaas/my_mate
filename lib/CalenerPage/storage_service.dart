import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<String> uploadImage(Uint8List imageData, String fileName) async {
    final ref = _storage.ref().child('diary_images').child(fileName);
    final uploadTask = ref.putData(imageData);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}

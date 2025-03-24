// services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage and return the download URL
  Future<String> uploadImage(File file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('product_images').child(fileName);
      await ref.putFile(file);
      String downloadURL = await ref.getDownloadURL(); // Retrieve download URL
      return downloadURL;
    } catch (e) {
      throw 'Error uploading image: $e';
    }
  }
}

// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('products');

  // CREATE
  Future<String> addProduct(Product product) async {
    try {
      DocumentReference docRef = await _productsRef.add(product.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Error adding product: $e';
    }
  }


  // READ (Stream of all products)
  Stream<List<Product>> getProductsStream() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // UPDATE
  Future<void> updateProduct(Product product) async {
    try {
      await _productsRef.doc(product.id).update(product.toMap());
    } catch (e) {
      throw 'Error updating product: $e';
    }
  }

  // DELETE
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsRef.doc(productId).delete();
    } catch (e) {
      throw 'Error deleting product: $e';
    }
  }
}

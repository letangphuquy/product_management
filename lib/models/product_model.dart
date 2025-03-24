// models/product_model.dart
class Product {
  final String id;
  final String name;
  final String type;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  // Convert Firestore document to ProductModel
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromMap(String docId, Map<String, dynamic> data) {
    return Product(
      id: docId,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

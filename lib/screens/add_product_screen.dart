// screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';
import '../widgets/product_image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  File? _image;

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  // Default image URL (replace this with a URL to a default image you want)
  //// Placeholder URL
  final String _defaultAssetImagePath = 'assets/default_product.png';

  Future<void> _addProduct() async {
    String imageUrl = ''; // Will be updated after checking image selection.
    if (_image != null) {
      try {
        imageUrl = await _storageService.uploadImage(_image!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
        return;
      }
    } else {
      // No image was picked: store an empty string so that the UI can use the default asset.
      imageUrl = '';
    }
    // Create product with temporary id
    final product = Product(
      id: '', // temporary; will be updated
      name: _nameController.text,
      type: _typeController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      imageUrl: imageUrl,
    );

    try {
      // Capture the new document id from Firestore
      final String docId = await _firestoreService.addProduct(product);
      // Update product with the actual id
      final updatedProduct = Product(
        id: docId,
        name: product.name,
        type: product.type,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: updatedProduct),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ProductImagePicker(
              image: _image,
              defaultAssetImagePath: _defaultAssetImagePath,
              onImagePicked: (pickedImage) {
                setState(() {
                  _image = pickedImage;
                });
              },
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Product Type'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Save Product'),
            ),
          ],
        ),
      ),
    );
  }
}

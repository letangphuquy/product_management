// screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';

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
  final String _defaultImageUrl =
      'https://cdn.pixabay.com/photo/2020/01/25/16/48/garden-4792880_960_720.jpg';  // Placeholder URL

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      setState(() {
        _image = File(xfile.path);
      });
    }
  }

  Future<void> _addProduct() async {
    // if (!_formKey.currentState!.validate()) return;

    String imageUrl = _defaultImageUrl;
    if (_image != null) {
      try {
        imageUrl = await _storageService.uploadImage(_image!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
        return;
      }
    }

    final product = Product(
      id: '', // Firestore auto-generates
      name: _nameController.text,
      type: _typeController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      imageUrl: imageUrl,
    );

    try {
      await _firestoreService.addProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
      // Navigate to the Product Detail Screen with the added product
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
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
            GestureDetector(
              onTap: _pickImage,
              child: _image == null
                  ? Container(
                      width: 100, height: 100, color: Colors.grey[300],
                      child: Image.network(_defaultImageUrl), // Show default image
                    )
                  : Image.file(_image!, width: 100, height: 100, fit: BoxFit.cover),
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

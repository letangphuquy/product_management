// screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';
import '../widgets/product_image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    String imageUrl = ''; // Will be updated after checking image selection.
    if (_image != null) {
      try {
        imageUrl = await _storageService.uploadImage(_image!);
      } catch (e) {
        if (!mounted) return ;
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
      if (!mounted) return ;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: updatedProduct),
        ),
      );
    } catch (e) {
// Don't use 'BuildContext's across async gaps.
// Try rewriting the code to not use the 'BuildContext', or guard the use with a 'mounted' check.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Product Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addProduct,
                      child: const Text('Save Product'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

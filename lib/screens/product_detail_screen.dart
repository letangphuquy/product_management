// screens/product_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _priceController;

  final FirestoreService _firestoreService = FirestoreService();

  File? _newImage;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product data
    _nameController = TextEditingController(text: widget.product.name);
    _typeController = TextEditingController(text: widget.product.type);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickNewImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      setState(() {
        _newImage = File(xfile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    String imageUrl = widget.product.imageUrl;
    // If a new image was selected, upload it
    if (_newImage != null) {
      try {
        imageUrl = await _storageService.uploadImage(_newImage!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading new image: $e')),
        );
        return;
      }
    }
    // Create an updated product, keeping the same id and imageUrl
    final updatedProduct = Product(
      id: widget.product.id,
      name: _nameController.text,
      type: _typeController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      imageUrl: imageUrl,
    );

    try {
      await _firestoreService.updateProduct(updatedProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.pop(context); // Return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display current or newly selected image
            _newImage != null
                ? Image.file(_newImage!, height: 150, fit: BoxFit.cover)
                : (widget.product.imageUrl.isNotEmpty
                    ? Image.network(widget.product.imageUrl,
                        height: 150, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 100)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickNewImage,
              child: const Text('Change Image'),
            ),
            const SizedBox(height: 20),
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
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

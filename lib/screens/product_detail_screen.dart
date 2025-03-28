// screens/product_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _priceController;

  final FirestoreService _firestoreService = FirestoreService();

  File? _newImage;
  static const String defaultAssetImagePath = 'assets/default_product.png';
  final StorageService _storageService = StorageService();

  late String _currentImageUrl;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product data
    _nameController = TextEditingController(text: widget.product.name);
    _typeController = TextEditingController(text: widget.product.type);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _currentImageUrl = widget.product.imageUrl; // initialize current image URL
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
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    String imageUrl = _currentImageUrl;
    // If a new image was selected, upload it
    if (_newImage != null) {
      try {
        imageUrl = await _storageService.uploadImage(_newImage!);
        // Delete the old image if it was uploaded (and not the default asset)
        if (widget.product.imageUrl.isNotEmpty &&
            widget.product.imageUrl.contains('product_images')) {
          await _storageService.deleteImage(widget.product.imageUrl);
        }
      } catch (e) {
        if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.pop(context); // Return to previous screen
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Decide which image to show: new image if picked, network image if available, otherwise the default asset.
    Widget imageWidget;
    if (_newImage != null) {
      imageWidget = Image.file(_newImage!, height: 150, fit: BoxFit.cover);
    } else if (_currentImageUrl.isNotEmpty) {
      imageWidget =
          Image.network(_currentImageUrl, height: 150, fit: BoxFit.cover);
    } else {
      imageWidget =
          Image.asset(defaultAssetImagePath, height: 150, fit: BoxFit.cover);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  imageWidget,
                  if ((_newImage != null) || _currentImageUrl.isNotEmpty)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _newImage = null;
                            _currentImageUrl = ''; // remove current image
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickNewImage,
                child: const Text('Change Image'),
              ),
              const SizedBox(height: 20),
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
                      onPressed: _saveChanges,
                      child: const Text('Save Changes'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Displaying the product's image if available
            product.imageUrl.isNotEmpty
                ? Image.network(product.imageUrl, height: 150, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 100),
            TextField(
              controller: TextEditingController(text: product.name),
              decoration: const InputDecoration(labelText: 'Product Name'),
              enabled: false, // Making it non-editable for now
            ),
            TextField(
              controller: TextEditingController(text: product.type),
              decoration: const InputDecoration(labelText: 'Product Type'),
              enabled: false, // Making it non-editable for now
            ),
            TextField(
              controller: TextEditingController(text: product.price.toString()),
              decoration: const InputDecoration(labelText: 'Price'),
              enabled: false, // Making it non-editable for now
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save any changes or navigate back
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

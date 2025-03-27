// screens/product_list_screen.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  static const String defaultAssetImagePath = 'assets/default_product.png';

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete '${product.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close the dialog
                _deleteProduct(product);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(Product product) {
    _firestoreService.deleteProduct(product).catchError((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading products'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: (product.imageUrl.isNotEmpty)
                    ? Image.network(product.imageUrl,
                        width: 50, height: 50, fit: BoxFit.cover)
                    : Image.asset(
                        defaultAssetImagePath,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                title: Text(product.name),
                subtitle: Text('Price: ${product.price}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(product),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

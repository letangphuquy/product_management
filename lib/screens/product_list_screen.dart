// screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'add_product_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

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
      body: ListView.builder(
        itemCount: 10,  // Dummy data count
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Product $index'),
            subtitle: Text('Product details here'),
            onTap: () {
              // Navigate to product detail/edit screen (to be implemented)
            },
          );
        },
      ),
    );
  }
}

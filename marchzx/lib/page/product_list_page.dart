import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final pb = PocketBase('http://127.0.0.1:8090');
  List<dynamic> products = [];
  bool loading = true;
  late final void Function() unsub;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    setupSubscription();
  }

  Future<void> setupSubscription() async {
    unsub = await pb.collection('product').subscribe("*", (e) {
      fetchProducts();
    });
  }

  Future<void> fetchProducts() async {
    // If you need admin auth, uncomment below
    await pb.admins.authWithPassword('mathat.po.65@ubu.ac.th', '19109980#Zx');
    final result = await pb.collection('product').getList(perPage: 100);
    setState(() {
      products = result.items;
      loading = false;
    });
  }

  Future<void> updateProduct(dynamic product) async {
    final nameController = TextEditingController(text: product.data['name']);
    final priceController = TextEditingController(text: product.data['price']?.toString() ?? '');
    final imageController = TextEditingController(text: product.data['imageUrl'] ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'name': nameController.text,
                'price': priceController.text,
                'imageUrl': imageController.text,
              }),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
    if (result != null &&
        result['name']!.isNotEmpty &&
        result['price']!.isNotEmpty &&
        result['imageUrl']!.isNotEmpty) {
      await pb.collection('product').update(product.id, body: {
        'name': result['name'],
        'price': result['price'],
        'imageUrl': result['imageUrl'],
      });
      // fetchProducts(); // Not needed, subscription will auto reload
    }
  }

  Future<void> deleteProduct(dynamic product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await pb.collection('product').delete(product.id);
      // fetchProducts(); // Not needed, subscription will auto reload
    }
  }

  @override
  void dispose() {
    unsub();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: Image.network(
                    product.data['imageUrl'] ?? '',
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 50),
                  ),
                  title: Text(product.data['name'] ?? ''),
                  subtitle: Text('\$${product.data['price'] ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => updateProduct(product),
                        tooltip: 'Update',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteProduct(product),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
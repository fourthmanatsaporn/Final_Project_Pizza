import 'package:flutter/material.dart' as flutter;
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'product_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> products = [];
  bool loading = true;

  // Mock data
  final List<String> topShops = [
    'Shop A',
    'Shop B',
    'Shop C',
    'Shop D',
  ];

  final List<Map<String, String>> popularReviews = [
    {'user': 'Alice', 'review': 'Great product! Fast delivery.'},
    {'user': 'Bob', 'review': 'Excellent quality, will buy again.'},
    {'user': 'Carol', 'review': 'Very satisfied with the service.'},
  ];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final pb = PocketBase('http://127.0.0.1:8090');
    // If your product collection requires auth, authenticate here
    await pb.admins.authWithPassword('mathat.po.65@ubu.ac.th', '19109980#Zx');
    final result = await pb.collection('product').getList(perPage: 100);
    setState(() {
      products = result.items;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-Commerce Landing'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Factory button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.factory),
                      label: const Text('ProductList'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductListPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Top Shops', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: topShops.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => Chip(
                        label: Text(topShops[index]),
                        backgroundColor: Colors.blue.shade50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Top Products', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        Widget imageWidget = flutter.Image.network(
                          product.data['imageUrl'] ?? '',
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, size: 80);
                          },
                        );
                        return SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              imageWidget,
                              const SizedBox(height: 8),
                              Text(product.data['name'] ?? '', overflow: TextOverflow.ellipsis),
                              Text('\$${product.data['price'] ?? ''}', style: const TextStyle(color: Colors.green)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Popular Reviews', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...popularReviews.map((review) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(child: Text(review['user']![0])),
                          title: Text(review['user']!),
                          subtitle: Text(review['review']!),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}
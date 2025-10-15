// 📂 lib/page/pizza_home_page.dart (โค้ดที่ตกแต่งใหม่ทั้งหมด)

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/pizza.dart';
import 'manage_pizza_page.dart';
import 'dart:ui'; // สำหรับ ImageFilter

class PizzaHomePage extends StatefulWidget {
  const PizzaHomePage({super.key});

  @override
  State<PizzaHomePage> createState() => _PizzaHomePageState();
}

class _PizzaHomePageState extends State<PizzaHomePage> {
  final pb = PocketBase('http://127.0.0.1:8090');
  late Future<List<Pizza>> _pizzasFuture;

  // --- State สำหรับการกรองข้อมูล ---
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _pizzasFuture = fetchPizzas();
  }

  Future<List<Pizza>> fetchPizzas() async {
    final records = await pb.collection('pizzas').getFullList(sort: '-rating');
    return records.map((record) => Pizza.fromRecord(record)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍕 Mamma Mia Pizza!',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Manage Menu',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManagePizzaPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<List<Pizza>>(
        future: _pizzasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching menu: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No pizzas on the menu right now."));
          }

          final allPizzas = snapshot.data!;
          
          // --- ส่วนตรรกะการกรองข้อมูล ---
          final filteredPizzas = allPizzas.where((pizza) {
            if (_selectedCategory == 'All') {
              return true;
            } else if (_selectedCategory == 'Meat') {
              return !pizza.isVegetarian;
            } else if (_selectedCategory == 'Veggie') {
              return pizza.isVegetarian;
            }
            return false;
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _pizzasFuture = fetchPizzas();
              });
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. แบนเนอร์โปรโมชั่น ---
                  PromotionBanner(pizza: allPizzas.first),
                  
                  // --- 2. ตัวเลือกหมวดหมู่ ---
                  CategorySelector(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),

                  // --- หัวข้อเมนู ---
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Choose Your Pizza',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // --- 3. Grid แสดงพิซซ่าที่กรองแล้ว ---
                  GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    // --- คำสั่งสำคัญเพื่อให้ GridView ทำงานใน SingleChildScrollView ได้ ---
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 0.7, // ปรับอัตราส่วนให้การ์ดสูงขึ้นเล็กน้อย
                    ),
                    itemCount: filteredPizzas.length,
                    itemBuilder: (context, index) {
                      return PizzaCard(pizza: filteredPizzas[index]);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


// ===============================================
//           วิดเจ็ตใหม่ที่สร้างเพิ่ม
// ===============================================

/// 1. วิดเจ็ตสำหรับแบนเนอร์โปรโมชั่น
class PromotionBanner extends StatelessWidget {
  const PromotionBanner({super.key, required this.pizza});
  final Pizza pizza;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.network(
              pizza.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // ไล่เฉดสีดำโปร่งแสงเพื่อให้ข้อความเด่นขึ้น
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PIZZA OF THE DAY',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    pizza.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2. วิดเจ็ตสำหรับตัวเลือกหมวดหมู่
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Meat', 'Veggie'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ChoiceChip(
            label: Text(category),
            selected: selectedCategory == category,
            onSelected: (_) => onCategorySelected(category),
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selectedCategory == category ? Colors.white : Colors.black,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
      ),
    );
  }
}

/// 3. การ์ดพิซซ่าที่ตกแต่งใหม่
class PizzaCard extends StatelessWidget {
  const PizzaCard({super.key, required this.pizza});
  final Pizza pizza;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          // ส่วนเนื้อหาหลัก
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  pizza.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.local_pizza_outlined,
                      size: 60,
                      color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pizza.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pizza.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '฿${pizza.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(pizza.rating.toString()),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // --- วิดเจ็ตที่วางซ้อนทับ ---
          // ปุ่ม Add to cart
          Positioned(
            bottom: 110, // ปรับตำแหน่งตามความเหมาะสม
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.add_shopping_cart, color: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  // TODO: Add to cart logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${pizza.name} added to cart!')),
                  );
                },
              ),
            ),
          ),
          // สัญลักษณ์มังสวิรัติ
          if (pizza.isVegetarian)
            Positioned(
              top: 8,
              left: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.eco, color: Colors.lightGreenAccent, size: 16),
                        SizedBox(width: 4),
                        Text('VEG', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
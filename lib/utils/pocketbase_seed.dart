// 📂 lib/utils/pocketbase_seed.dart (โค้ดที่แก้ไขแล้ว)

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:pocketbase/pocketbase.dart';
import 'package:faker/faker.dart';

const String UNSPLASH_ACCESS_KEY = 'trV6aVR8raZcmIjiTnLkRIPSh87eAYdlw9ljSDH5nAk';

// ✅ 1. สร้างฟังก์ชันใหม่สำหรับดึง "ชุดรูปภาพ" ที่ไม่ซ้ำกัน
Future<List<String>> _fetchUniquePizzaImageUrls(int count) async {
  // เพิ่มพารามิเตอร์ count=... เพื่อบอก API ว่าเราต้องการรูปภาพหลายใบ
  final url = Uri.parse(
      'https://api.unsplash.com/photos/random?query=pizza&orientation=squarish&count=$count&client_id=$UNSPLASH_ACCESS_KEY');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // แปลงข้อมูล JSON ที่เป็น List ให้อยู่ในรูปแบบ List<String> ของ URL รูปภาพ
      return data.map<String>((item) => item['urls']['regular'] as String).toList();
    } else {
      print("Error fetching from Unsplash: ${response.body}");
      return []; // ส่งค่า List ว่างกลับไปถ้าเกิด Error
    }
  } catch (e) {
    print("Exception when fetching from Unsplash: $e");
    return [];
  }
}


final List<Map<String, dynamic>> pizzaMenu = [
  {"name": "Margherita", "description": "Classic delight with fresh mozzarella, tomatoes, and basil.", "isVegetarian": true},
  {"name": "Pepperoni", "description": "A meat lover's favorite with spicy pepperoni slices.", "isVegetarian": false},
  {"name": "Hawaiian", "description": "Sweet and savory with pineapple, ham, and cheese.", "isVegetarian": false},
  {"name": "Veggie Supreme", "description": "Loaded with bell peppers, onions, olives, and mushrooms.", "isVegetarian": true},
  {"name": "Meat Lover's", "description": "Packed with pepperoni, sausage, bacon, and ham.", "isVegetarian": false},
  {"name": "BBQ Chicken", "description": "Tangy BBQ sauce, grilled chicken, and red onions.", "isVegetarian": false},
  {"name": "Four Cheese", "description": "A cheesy paradise with mozzarella, gorgonzola, parmesan, and asiago.", "isVegetarian": true},
];


Future<void> seedPizzas() async {
  final pb = PocketBase('http://127.0.0.1:8090');
  final faker = Faker();

  await pb.admins.authWithPassword('manatsaporn.ka.65@ubu.ac.th', 'Fourth14095');

  final result = await pb.collection('pizzas').getList(perPage: 1);
  if (result.totalItems > 0) {
    print('🍕 Pizzas collection is not empty. Seeding skipped.');
    return;
  }

  print('Fetching unique pizza images from Unsplash...');
  // ✅ 2. ดึงชุด URL รูปภาพมาก่อนเริ่ม Loop แค่ครั้งเดียว
  final imageUrls = await _fetchUniquePizzaImageUrls(pizzaMenu.length);

  // เตรียมรูปสำรองไว้เผื่อ API Unsplash ล่ม
  const fallbackImageUrl = "https://images.unsplash.com/photo-1590947132387-155cc02f3212?w=500";
  if (imageUrls.isEmpty) {
      print('⚠️ Could not fetch images from Unsplash, using fallback image.');
  }

  print('Seeding pizzas...');

  for (int i = 0; i < pizzaMenu.length; i++) {
    final pizzaData = pizzaMenu[i];
    
    // ✅ 3. เลือกว่าจะใช้รูปจาก Unsplash หรือรูปสำรอง
    final imageUrl = imageUrls.isNotEmpty ? imageUrls[i] : fallbackImageUrl;

    final body = <String, dynamic>{
      "name": pizzaData['name'],
      "description": pizzaData['description'],
      "isVegetarian": pizzaData['isVegetarian'],
      "imageUrl": imageUrl, // <-- ใช้ URL จาก List ที่ดึงมา
      "price": faker.randomGenerator.decimal(scale: 550, min: 250).toStringAsFixed(2),
      "rating": (Random().nextDouble() * (5.0 - 3.8) + 3.8).toStringAsFixed(1),
    };
    await pb.collection('pizzas').create(body: body);
    print('  - Created ${pizzaData['name']}');
  }

  print('Pizza seeding completed successfully!');
}
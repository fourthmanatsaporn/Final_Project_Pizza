// lib/models/pizza.dart
import 'package:pocketbase/pocketbase.dart';

class Pizza {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isVegetarian;
  final double rating;

  Pizza({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isVegetarian,
    required this.rating,
  });

  // Factory constructor สำหรับแปลงข้อมูลจาก PocketBase (RecordModel)
  // ให้กลายเป็น Object Pizza ที่เราใช้งานได้ง่ายๆ
  factory Pizza.fromRecord(RecordModel record) {
    final data = record.data;
    return Pizza(
      id: record.id,
      name: data['name'] ?? 'N/A',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      isVegetarian: data['isVegetarian'] ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
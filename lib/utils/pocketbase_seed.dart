import 'package:pocketbase/pocketbase.dart';
import 'package:faker/faker.dart';

Future<void> seedProducts() async {
  final pb = PocketBase('http://127.0.0.1:8090');

  // Authenticate as admin
  await pb.admins.authWithPassword('mathat.po.65@ubu.ac.th', '19109980#Zx');

  // ตรวจสอบว่ามีข้อมูลอยู่แล้วหรือยัง
  final result = await pb.collection('product').getList(perPage: 1);
  if (result.totalItems > 0) {
    print('Products already seeded!');
    return;
  }

  final faker = Faker();

  for (int i = 0; i < 100; i++) {
    await pb.collection('product').create(body: {
      'name': faker.food.restaurant(),
      'price': faker.randomGenerator.integer(500, min: 10).toString(),
      'imageUrl': 'https://picsum.photos/seed/$i/80/80',
    });
  }
  print('Seeded 100 products!');
}
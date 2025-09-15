import 'package:flutter/material.dart';
import 'utils/pocketbase_seed.dart';
import 'page/home.dart'; // เพิ่มบรรทัดนี้


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await seedProducts(); // <-- Add this line to seed products
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(), // เปลี่ยนตรงนี้
    );
  }
}


import 'package:flutter/material.dart';
import 'package:get/get.dart'; // นำเข้า GetX
import 'package:get_storage/get_storage.dart'; // นำเข้า GetStorage
import 'page/player.dart'; // นำเข้า PlayerSelectionPage

void main() async {
  // ทำการตั้งค่า GetStorage
  await GetStorage.init();  // การตั้งค่า GetStorage ต้องทำก่อนเรียกใช้งาน
  runApp(const MyApp());  // เรียกใช้งานแอปหลังจากตั้งค่าผ่าน GetStorage
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  // ใช้ GetMaterialApp แทน MaterialApp
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const PlayerSelectionPage(), // เริ่มหน้าแรก
    );
  }
}

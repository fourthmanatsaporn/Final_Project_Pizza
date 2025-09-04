import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ✅ Controller สำหรับ Pokemon Detail
class PokemonDetailController extends GetxController {
  final Rx<Map<String, dynamic>?> details = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = true.obs;
  
  late final String url;

  void initialize(String pokemonUrl) {
    url = pokemonUrl;
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      details.value = json.decode(response.body);
      isLoading.value = false;
    }
  }
}

class PokemonDetailPage extends StatelessWidget {
  final String id;
  final String name;
  final String image;
  final String url;

  const PokemonDetailPage({
    super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ ใช้ Get.put() และ initialize
    final controller = Get.put(PokemonDetailController(), tag: id);
    controller.initialize(url);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.deepPurple,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0), // ✅ ระยะเท่ากันทุกด้าน
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.deepPurple.shade200,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ รูปใหญ่
                      Image.network(
                        image,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),

                      // ✅ ชื่อ
                      Text(
                        name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ ข้อมูล
                      if (controller.details.value != null) ...[
                        Text("ID: $id",
                            style: const TextStyle(fontSize: 18)),
                        Text("Height: ${controller.details.value!["height"]}",
                            style: const TextStyle(fontSize: 18)),
                        Text("Weight: ${controller.details.value!["weight"]}",
                            style: const TextStyle(fontSize: 18)),
                        Text("Base Experience: ${controller.details.value!["base_experience"]}",
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
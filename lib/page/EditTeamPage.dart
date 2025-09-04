import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ✅ Controller สำหรับ EditTeamPage
class EditTeamController extends GetxController {
  final RxList<Map<String, String>> allPokemons = <Map<String, String>>[].obs;
  final RxSet<int> selected = <int>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = "".obs;

  void initializeCurrentPokemons(List<Map<String, String>> currentPokemons) {
    // mark current selections
    for (var p in currentPokemons) {
      selected.add(int.parse(p["image"]!.split("/").last.split(".").first));
    }
    fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    const url = "https://pokeapi.co/api/v2/pokemon?limit=1000";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data["results"];

      List<Map<String, String>> fetched = [];

      for (var i = 0; i < results.length; i++) {
        final pokemonData = results[i];
        final id = i + 1;
        fetched.add({
          "name": pokemonData["name"],
          "image":
              "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png"
        });
      }

      allPokemons.value = fetched;
      isLoading.value = false;
    }
  }

  void togglePokemonSelection(int index) {
    if (selected.contains(index + 1)) {
      selected.remove(index + 1);
    } else {
      if (selected.length < 3) {
        selected.add(index + 1);
      } else {
        Get.snackbar(
          "เตือน",
          "เลือกได้สูงสุด 3 ตัว",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // ✅ เพิ่ม method สำหรับล้างการเลือกทั้งหมด
  void resetSelection() {
    selected.clear();
    Get.snackbar(
      "แจ้งเตือน",
      "ล้างการเลือกแล้ว",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Map<String, String>> get filteredPokemons {
    return allPokemons
        .where((p) =>
            p["name"]!.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  List<Map<String, String>> getUpdatedTeam() {
    return selected.map((i) => allPokemons[i - 1]).toList();
  }

  void saveTeam() {
    if (selected.length != 3) {
      Get.snackbar(
        "เตือน",
        "ต้องเลือกให้ครบ 3 ตัวก่อน",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    final updated = getUpdatedTeam();
    Get.back(result: updated);
  }
}

class EditTeamPage extends StatelessWidget {
  final List<Map<String, String>> currentPokemons;

  const EditTeamPage({super.key, required this.currentPokemons});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditTeamController());
    controller.initializeCurrentPokemons(currentPokemons);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("แก้ไขทีม"),
        backgroundColor: Colors.deepPurple,
        actions: [
          Obx(() => IconButton(
            icon: const Icon(Icons.save),
            onPressed: controller.selected.length == 3 
                ? controller.saveTeam 
                : null,
          ))
        ],
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ กล่องแสดงโปเกมอนที่เลือก
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        "ทีมที่เลือก (${controller.selected.length}/3)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      )),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 80,
                        child: Obx(() => Row(
                          children: List.generate(3, (index) {
                            if (index < controller.selected.length) {
                              final selectedId = controller.selected.elementAt(index);
                              final pokemon = controller.allPokemons[selectedId - 1];
                              return Container(
                                width: 70,
                                height: 70,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  border: Border.all(color: Colors.green, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    pokemon["image"]!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                width: 70,
                                height: 70,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.grey.shade400,
                                  size: 30,
                                ),
                              );
                            }
                          }),
                        )),
                      ),
                    ],
                  ),
                ),

                // ✅ แถบแสดงจำนวนที่เลือกและปุ่มล้าง
                Container(
                  color: Colors.deepPurple.shade50,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                        "เลือกแล้ว: ${controller.selected.length}/3",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      )),
                      Obx(() => ElevatedButton.icon(
                        onPressed: controller.selected.isNotEmpty
                            ? controller.resetSelection
                            : null,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text("ล้างทั้งหมด"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      )),
                    ],
                  ),
                ),

                // ช่องค้นหา
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "ค้นหา Pokémon",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: controller.updateSearchQuery,
                  ),
                ),
                const Divider(height: 1, color: Colors.black26),

                Expanded(
                  child: Obx(() {
                    final filteredPokemons = controller.filteredPokemons;
                    
                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.7,
                      ),
                      itemCount: filteredPokemons.length,
                      itemBuilder: (context, index) {
                        final pokemon = filteredPokemons[index];
                        final realIndex = controller.allPokemons.indexOf(pokemon);
                        
                        return Obx(() {
                          final isSelected = controller.selected.contains(realIndex + 1);
                          
                          return GestureDetector(
                            onTap: () => controller.togglePokemonSelection(realIndex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                  width: isSelected ? 3 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      pokemon["image"]!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    pokemon["name"]!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.green
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
      ),
    );
  }
}
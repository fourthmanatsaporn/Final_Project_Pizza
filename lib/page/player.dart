import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'team_manager.dart';
import 'pokemon_detail.dart';

// ✅ Controller สำหรับจัดการ State ด้วย GetX
class PlayerSelectionController extends GetxController {
  final RxList<Map<String, String>> players = <Map<String, String>>[].obs;
  final RxSet<int> selectedPlayers = <int>{}.obs;
  final RxBool isLoading = true.obs;
  final RxBool isTeamMode = false.obs;
  final RxString searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
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
          "id": "$id",
          "name": pokemonData["name"],
          "url": pokemonData["url"],
          "image":
              "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png"
        });
      }

      players.value = fetched;
      isLoading.value = false;
    } else {
      isLoading.value = false;
    }
  }

  void toggleTeamMode() {
    isTeamMode.value = !isTeamMode.value;
    if (!isTeamMode.value) {
      selectedPlayers.clear();
    }
  }

  void exitTeamMode() {
    isTeamMode.value = false;
    selectedPlayers.clear();
    Get.snackbar(
      "แจ้งเตือน",
      "ออกจากโหมดเลือกทีมแล้ว",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void togglePlayerSelection(int index) {
    if (selectedPlayers.contains(index)) {
      selectedPlayers.remove(index);
    } else {
      if (selectedPlayers.length < 3) {
        selectedPlayers.add(index);
      } else {
        Get.snackbar(
          "เตือน",
          "เลือกได้สูงสุด 3 ตัว",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void resetSelection() {
    selectedPlayers.clear();
    Get.snackbar(
      "แจ้งเตือน",
      "ล้างทีมที่เลือกแล้ว",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void saveTeam() {
    if (selectedPlayers.length != 3) {
      Get.snackbar(
        "เตือน",
        "ต้องเลือกให้ครบ 3 ตัวก่อน",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final List<Map<String, String>> team = selectedPlayers.map((i) {
      return players[i];
    }).toList();

    Get.to(() => TeamManagerPage(newTeam: team));

    selectedPlayers.clear();
    isTeamMode.value = false;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Map<String, String>> get filteredPlayers {
    return players
        .where((p) =>
            p["name"]!.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }
}

class PlayerSelectionPage extends StatelessWidget {
  const PlayerSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ ใช้ Get.put() เพื่อสร้าง controller
    final controller = Get.put(PlayerSelectionController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isTeamMode.value ? "โหมดเลือกทีม" : "Pokémon List"
        )),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          // ปุ่มออกจากโหมดเลือกทีม
          Obx(() => controller.isTeamMode.value
              ? IconButton(
                  onPressed: controller.exitTeamMode,
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: "ออกจากโหมดเลือกทีม",
                )
              : const SizedBox.shrink()),
          
          // ปุ่มสร้างทีม / บันทึก
          Obx(() => TextButton(
            onPressed: () {
              if (controller.isTeamMode.value) {
                controller.saveTeam();
              } else {
                controller.isTeamMode.value = true;
              }
            },
            child: Text(
              controller.isTeamMode.value ? "บันทึก" : "สร้างทีม",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),

          // ปุ่มไปที่หน้าทีมที่มี (แสดงเป็นคำ)
          TextButton(
            onPressed: () {
              // ไปที่หน้าทีมที่มี (TeamManagerPage) โดยไม่ต้องตรวจสอบ
              final List<Map<String, String>> team = controller.selectedPlayers.map((i) {
                return controller.players[i];
              }).toList();
              Get.to(() => TeamManagerPage(newTeam: team));
            },
            child: const Text(
              "ทีมของฉัน",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ กล่องแสดงโปเกมอนที่เลือก (แสดงเฉพาะในโหมดเลือกทีม)
                Obx(() => controller.isTeamMode.value
                    ? Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ทีมที่เลือก (${controller.selectedPlayers.length}/3)",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 80,
                              child: Row(
                                children: List.generate(3, (index) {
                                  if (index < controller.selectedPlayers.length) {
                                    final selectedIndex = controller.selectedPlayers.elementAt(index);
                                    final pokemon = controller.players[selectedIndex];
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
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink()),

                // ✅ แถบแสดงจำนวนที่เลือกและปุ่มล้าง (แสดงเฉพาะในโหมดเลือกทีม)
                Obx(() => controller.isTeamMode.value
                    ? Container(
                        color: Colors.deepPurple.shade50,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "เลือกแล้ว: ${controller.selectedPlayers.length}/3",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade700,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: controller.selectedPlayers.isNotEmpty
                                  ? controller.resetSelection
                                  : null,
                              icon: const Icon(Icons.clear_all, size: 18),
                              label: const Text("ล้างทั้งหมด"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink()),

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
                    final filteredPlayers = controller.filteredPlayers;
                    
                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.7,
                      ),
                      itemCount: filteredPlayers.length,
                      itemBuilder: (context, index) {
                        final player = filteredPlayers[index];
                        final realIndex = controller.players.indexOf(player);
                        
                        return Obx(() {
                          final isSelected = controller.selectedPlayers.contains(realIndex);
                          
                          return GestureDetector(
                            onTap: () {
                              if (controller.isTeamMode.value) {
                                controller.togglePlayerSelection(realIndex);
                              } else {
                                Get.to(() => PokemonDetailPage(
                                  id: player["id"]!,
                                  name: player["name"]!,
                                  image: player["image"]!,
                                  url: player["url"]!,
                                ));
                              }
                            },
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
                                      player["image"]!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    player["name"]!,
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
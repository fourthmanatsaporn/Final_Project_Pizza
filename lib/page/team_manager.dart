import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myapp/page/EditTeamPage.dart';

// ✅ Controller สำหรับ Team Manager
class TeamManagerController extends GetxController {
  final box = GetStorage();
  final RxList teams = [].obs;

  void initializeWithNewTeam(List<Map<String, String>> newTeam) {
    teams.value = box.read("teams") ?? [];
    if (newTeam.isNotEmpty) {
      addTeam(newTeam);
    }
  }

  void addTeam(List<Map<String, String>> pokemons) {
    teams.add({
      "teamName": "New Team",
      "pokemons": pokemons,
    });
    box.write("teams", teams);
    teams.refresh();
  }

  void deleteTeam(int index) {
    teams.removeAt(index);
    box.write("teams", teams);
  }

  Future<void> editTeamName(int index) async {
    final controller = TextEditingController(text: teams[index]["teamName"]);
    final newName = await Get.dialog<String>(
      AlertDialog(
        title: const Text("แก้ไขชื่อทีม"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "ชื่อทีมใหม่"),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      teams[index]["teamName"] = newName;
      box.write("teams", teams);
      teams.refresh();
    }
  }

  Future<void> editPokemons(int index) async {
    final updatedPokemons = await Get.to(() => EditTeamPage(
      currentPokemons: List<Map<String, String>>.from(teams[index]["pokemons"]),
    ));

    if (updatedPokemons != null) {
      teams[index]["pokemons"] = updatedPokemons;
      box.write("teams", teams);
      teams.refresh();
    }
  }
}

class TeamManagerPage extends StatelessWidget {
  final List<Map<String, String>> newTeam;

  const TeamManagerPage({super.key, required this.newTeam});

  @override
  Widget build(BuildContext context) {
    // ใช้ Get.put() เพื่อสร้าง controller และสามารถใช้งานได้
    final controller = Get.put(TeamManagerController());
    controller.initializeWithNewTeam(newTeam);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ทีมของฉัน"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Obx(() => controller.teams.isEmpty
          ? const Center(child: Text("ยังไม่มีทีมที่บันทึกไว้"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: controller.teams.length,
              itemBuilder: (context, index) {
                final team = controller.teams[index];
                return Card(
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: (team["pokemons"] as List)
                          .map<Widget>((p) => Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Image.network(
                                  p["image"],
                                  width: 32,
                                  height: 32,
                                ),
                              ))
                          .toList(),
                    ),
                    title: Text(team["teamName"]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.pets, color: Colors.orange),
                          tooltip: "แก้ไขโปเกม่อน",
                          onPressed: () => controller.editPokemons(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => controller.editTeamName(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteTeam(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}

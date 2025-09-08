import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ✅ Controller สำหรับ Pokemon Detail แบบขยาย
class PokemonDetailController extends GetxController {
  final Rx<Map<String, dynamic>?> details = Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> speciesData = Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> evolutionChain = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = true.obs;
  final RxBool evolutionLoading = false.obs;
  final RxInt selectedTabIndex = 0.obs;
  
  late final String url;

  void initialize(String pokemonUrl) {
    url = pokemonUrl;
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      details.value = json.decode(response.body);
      
      // ดึงข้อมูล species เพิ่มเติม
      if (details.value!['species'] != null) {
        fetchSpeciesData(details.value!['species']['url']);
      }
      
      isLoading.value = false;
    }
  }

  Future<void> fetchSpeciesData(String speciesUrl) async {
    final response = await http.get(Uri.parse(speciesUrl));
    if (response.statusCode == 200) {
      speciesData.value = json.decode(response.body);
      // เรียก evolution chain เมื่อได้ species data แล้ว
      fetchEvolutionChain();
    }
  }

  Future<void> fetchEvolutionChain() async {
    if (speciesData.value == null) return;
    
    try {
      evolutionLoading.value = true;
      final evolutionUrl = speciesData.value!['evolution_chain']['url'];
      final response = await http.get(Uri.parse(evolutionUrl));
      
      if (response.statusCode == 200) {
        evolutionChain.value = json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching evolution chain: $e');
    } finally {
      evolutionLoading.value = false;
    }
  }

  // คำนวด Total Stats
  int getTotalStats() {
    if (details.value == null) return 0;
    int total = 0;
    for (var stat in details.value!['stats']) {
      total += stat['base_stat'] as int;
    }
    return total;
  }

  // หา Type Color
  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire': return Colors.red.shade400;
      case 'water': return Colors.blue.shade400;
      case 'grass': return Colors.green.shade400;
      case 'electric': return Colors.yellow.shade700;
      case 'psychic': return Colors.pink.shade400;
      case 'ice': return Colors.cyan.shade300;
      case 'dragon': return Colors.indigo.shade400;
      case 'dark': return Colors.grey.shade800;
      case 'fairy': return Colors.pink.shade200;
      case 'normal': return Colors.grey.shade400;
      case 'fighting': return Colors.orange.shade800;
      case 'flying': return Colors.indigo.shade200;
      case 'poison': return Colors.purple.shade400;
      case 'ground': return Colors.brown.shade400;
      case 'rock': return Colors.brown.shade600;
      case 'bug': return Colors.lightGreen.shade400;
      case 'ghost': return Colors.deepPurple.shade400;
      case 'steel': return Colors.blueGrey.shade400;
      default: return Colors.grey;
    }
  }

  // หา Stat Color
  Color getStatColor(int value) {
    if (value >= 100) return Colors.green.shade600;
    if (value >= 75) return Colors.lightGreen.shade600;
    if (value >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
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
    final controller = Get.put(PokemonDetailController(), tag: id);
    controller.initialize(url);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(name.toUpperCase()),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  // ส่วนหัวแสดงรูปและข้อมูลพื้นฐาน
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.deepPurple,
                          Colors.deepPurple.shade300,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // รูป Pokemon
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(20),
                          child: Image.network(
                            image,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, size: 100, color: Colors.white);
                            },
                          ),
                        ),
                        
                        // ID และ Types
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ID Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '#${id.padLeft(3, '0')}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Types
                              if (controller.details.value != null)
                                ...controller.details.value!['types'].map<Widget>((type) {
                                  final typeName = type['type']['name'];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: controller.getTypeColor(typeName),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      typeName.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Tab Bar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      labelColor: Colors.deepPurple,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.deepPurple,
                      tabs: const [
                        Tab(text: 'About'),
                        Tab(text: 'Stats'),
                        Tab(text: 'Moves'),
                        Tab(text: 'Evolution'),
                      ],
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      children: [
                        // About Tab
                        _buildAboutTab(controller),
                        
                        // Stats Tab
                        _buildStatsTab(controller),
                        
                        // Moves Tab
                        _buildMovesTab(controller),
                        
                        // Evolution Tab
                        _buildEvolutionTab(controller),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildAboutTab(PokemonDetailController controller) {
    if (controller.details.value == null) return const SizedBox();
    
    final details = controller.details.value!;
    final species = controller.speciesData.value;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              if (species != null) ...[
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _getEnglishFlavorText(species),
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const Divider(height: 30),
              ],
              
              // Physical Characteristics
              const Text(
                'Physical Characteristics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              
              _buildInfoRow('Height', '${details['height'] / 10} m'),
              _buildInfoRow('Weight', '${details['weight'] / 10} kg'),
              _buildInfoRow('Base Experience', '${details['base_experience']}'),
              
              if (species != null) ...[
                _buildInfoRow('Capture Rate', '${species['capture_rate']}'),
                _buildInfoRow('Base Happiness', '${species['base_happiness']}'),
                _buildInfoRow('Growth Rate', species['growth_rate']['name'].replaceAll('-', ' ')),
                _buildInfoRow('Habitat', species['habitat']?['name']?.replaceAll('-', ' ') ?? 'Unknown'),
              ],
              
              const Divider(height: 30),
              
              // Abilities
              const Text(
                'Abilities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: details['abilities'].map<Widget>((ability) {
                  return Chip(
                    label: Text(
                      ability['ability']['name'].replaceAll('-', ' '),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: ability['is_hidden'] 
                        ? Colors.orange.shade100 
                        : Colors.blue.shade100,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsTab(PokemonDetailController controller) {
    if (controller.details.value == null) return const SizedBox();
    
    final stats = controller.details.value!['stats'];
    final totalStats = controller.getTotalStats();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Base Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              ...stats.map<Widget>((stat) {
                final statName = _formatStatName(stat['stat']['name']);
                final baseStat = stat['base_stat'];
                final maxStat = 255;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              statName,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            '$baseStat',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: controller.getStatColor(baseStat),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: baseStat / maxStat,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            controller.getStatColor(baseStat),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              
              const Divider(height: 30),
              
              // Total Stats
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$totalStats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovesTab(PokemonDetailController controller) {
    if (controller.details.value == null) return const SizedBox();
    
    final moves = controller.details.value!['moves'] as List? ?? [];
    
    // จัดเรียง moves ตาม level with null safety
    final levelUpMoves = moves.where((move) {
      try {
        final versionGroupDetails = move['version_group_details'] as List? ?? [];
        return versionGroupDetails.any((detail) {
          final moveLearnMethod = detail?['move_learn_method'];
          return moveLearnMethod != null && moveLearnMethod['name'] == 'level-up';
        });
      } catch (e) {
        return false;
      }
    }).toList();
    
    levelUpMoves.sort((a, b) {
      try {
        final aVersionDetails = a['version_group_details'] as List? ?? [];
        final bVersionDetails = b['version_group_details'] as List? ?? [];
        
        final aDetail = aVersionDetails.firstWhere(
          (detail) {
            final moveLearnMethod = detail?['move_learn_method'];
            return moveLearnMethod != null && moveLearnMethod['name'] == 'level-up';
          },
          orElse: () => {'level_learned_at': 0},
        );
        
        final bDetail = bVersionDetails.firstWhere(
          (detail) {
            final moveLearnMethod = detail?['move_learn_method'];
            return moveLearnMethod != null && moveLearnMethod['name'] == 'level-up';
          },
          orElse: () => {'level_learned_at': 0},
        );
        
        final aLevel = aDetail['level_learned_at'] as int? ?? 0;
        final bLevel = bDetail['level_learned_at'] as int? ?? 0;
        
        return aLevel.compareTo(bLevel);
      } catch (e) {
        return 0;
      }
    });
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: levelUpMoves.length,
      itemBuilder: (context, index) {
        final move = levelUpMoves[index];
        
        try {
          final moveName = move['move']?['name']?.toString().replaceAll('-', ' ') ?? 'Unknown Move';
          final versionGroupDetails = move['version_group_details'] as List? ?? [];
          
          final levelDetail = versionGroupDetails.firstWhere(
            (detail) {
              final moveLearnMethod = detail?['move_learn_method'];
              return moveLearnMethod != null && moveLearnMethod['name'] == 'level-up';
            },
            orElse: () => {'level_learned_at': 0},
          );
          
          final level = levelDetail['level_learned_at'] as int? ?? 0;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  level == 0 ? '-' : '$level',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                moveName.split(' ').map((word) => 
                  word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
                ).join(' '),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text('Level ${level == 0 ? 'N/A' : level}'),
            ),
          );
        } catch (e) {
          // Fallback for any parsing errors
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                child: const Icon(Icons.error, size: 16),
              ),
              title: const Text('Error loading move'),
              subtitle: const Text('Unable to parse move data'),
            ),
          );
        }
      },
    );
  }

  Widget _buildEvolutionTab(PokemonDetailController controller) {
    return Obx(() {
      if (controller.evolutionLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.evolutionChain.value == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Loading evolution data...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      }
      
      final evolutionData = controller.evolutionChain.value!['chain'];
      List<Map<String, dynamic>> evolutionStages = [];
      
      // สร้าง list ของ evolution stages
      _buildEvolutionStages(evolutionData, evolutionStages);
      
      if (evolutionStages.length <= 1) {
        return const Center(
          child: Text(
            'This Pokémon does not evolve',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Evolution Chain',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            
            // แสดง evolution stages
            ...evolutionStages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final pokemonName = stage['species']['name'];
              final pokemonId = _extractPokemonId(stage['species']['url']);
              
              return Column(
                children: [
                  // Pokemon card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Pokemon image
                          Image.network(
                            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png',
                            height: 100,
                            width: 100,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.help_outline, size: 50),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          
                          // Pokemon name
                          Text(
                            pokemonName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '#${pokemonId.toString().padLeft(3, '0')}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Evolution requirements (แสดงระหว่าง stages)
                  if (index < evolutionStages.length - 1) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.deepPurple.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.deepPurple.shade400,
                            size: 30,
                          ),
                          Text(
                            _getEvolutionRequirements(evolutionStages[index + 1]),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  // Helper method เพื่อสร้าง evolution stages
  void _buildEvolutionStages(Map<String, dynamic> chainData, List<Map<String, dynamic>> stages) {
    stages.add(chainData);
    
    final evolvesTo = chainData['evolves_to'] as List? ?? [];
    for (final evolution in evolvesTo) {
      _buildEvolutionStages(evolution, stages);
    }
  }

  // Helper method เพื่อดึง Pokemon ID จาก species URL
  int _extractPokemonId(String speciesUrl) {
    try {
      final parts = speciesUrl.split('/');
      return int.parse(parts[parts.length - 2]);
    } catch (e) {
      return 1;
    }
  }

  // Helper method เพื่อแสดงเงื่อนไขการอีโวลูชั่น
  String _getEvolutionRequirements(Map<String, dynamic> evolutionData) {
    final evolutionDetails = evolutionData['evolution_details'] as List? ?? [];
    
    if (evolutionDetails.isEmpty) {
      return 'Evolution requirements unknown';
    }
    
    final details = evolutionDetails.first;
    List<String> requirements = [];
    
    // Level requirement
    if (details['min_level'] != null) {
      requirements.add('Level ${details['min_level']}');
    }
    
    // Item requirement
    if (details['item'] != null) {
      final itemName = details['item']['name'].toString().replaceAll('-', ' ');
      requirements.add('Use ${itemName}');
    }
    
    // Happiness requirement
    if (details['min_happiness'] != null) {
      requirements.add('Happiness ${details['min_happiness']}');
    }
    
    // Time of day requirement
    if (details['time_of_day'] != null && details['time_of_day'].toString().isNotEmpty) {
      requirements.add('${details['time_of_day']} time');
    }
    
    // Location requirement
    if (details['location'] != null) {
      final locationName = details['location']['name'].toString().replaceAll('-', ' ');
      requirements.add('At ${locationName}');
    }
    
    return requirements.isEmpty ? 'Special conditions required' : requirements.join('\n');
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatName(String name) {
    switch (name) {
      case 'hp': return 'HP';
      case 'attack': return 'Attack';
      case 'defense': return 'Defense';
      case 'special-attack': return 'Sp. Atk';
      case 'special-defense': return 'Sp. Def';
      case 'speed': return 'Speed';
      default: return name;
    }
  }

  String _getEnglishFlavorText(Map<String, dynamic> species) {
    try {
      final flavorTexts = species['flavor_text_entries'] as List? ?? [];
      if (flavorTexts.isEmpty) return 'No description available';
      
      final englishText = flavorTexts.firstWhere(
        (text) => text['language']['name'] == 'en',
        orElse: () => {'flavor_text': 'No description available'},
      );
      
      final text = englishText['flavor_text'] ?? 'No description available';
      return text.toString().replaceAll('\n', ' ').replaceAll('\f', ' ');
    } catch (e) {
      return 'No description available';
    }
  }
}
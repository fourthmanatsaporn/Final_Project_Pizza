// 📂 lib/page/manage_pizza_page.dart (โค้ดที่อัปเดตแล้ว)

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/pizza.dart'; // Import model ของเรา

class ManagePizzaPage extends StatefulWidget {
  const ManagePizzaPage({super.key});

  @override
  State<ManagePizzaPage> createState() => _ManagePizzaPageState();
}

class _ManagePizzaPageState extends State<ManagePizzaPage> {
  final pb = PocketBase('http://127.0.0.1:8090');
  late Future<List<Pizza>> _pizzasFuture;

  @override
  void initState() {
    super.initState();
    // ✅ Authenticate as admin once when the page loads
    // *** สำคัญ: ใส่ Email/Password Admin ของคุณที่นี่ ***
    pb.admins.authWithPassword('manatsaporn.ka.65@ubu.ac.th', 'Fourth14095');
    
    _fetchPizzas();
    
    // Realtime subscription: UI จะรีเฟรชอัตโนมัติเมื่อข้อมูลเปลี่ยน
    pb.collection('pizzas').subscribe('*', (e) {
      if (mounted) _fetchPizzas();
    });
  }

  void _fetchPizzas() {
    setState(() {
      _pizzasFuture = pb
          .collection('pizzas')
          .getFullList(sort: '-created')
          .then((records) => records.map((r) => Pizza.fromRecord(r)).toList());
    });
  }

  // ✅ ฟังก์ชันสำหรับ "เพิ่ม" และ "แก้ไข" ในที่เดียว
  Future<void> _showPizzaFormDialog({Pizza? pizza}) async {
    final isCreating = pizza == null;
    final formKey = GlobalKey<FormState>();

    // Controllers พร้อมกำหนดค่าเริ่มต้น (ถ้าเป็นการแก้ไข)
    final nameCtrl = TextEditingController(text: pizza?.name ?? '');
    final descCtrl = TextEditingController(text: pizza?.description ?? '');
    final priceCtrl = TextEditingController(text: pizza?.price.toString() ?? '');
    final ratingCtrl = TextEditingController(text: pizza?.rating.toString() ?? '');
    final imageUrlCtrl = TextEditingController(text: pizza?.imageUrl ?? '');
    bool isVegetarian = pizza?.isVegetarian ?? false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isCreating ? 'Add New Pizza' : 'Edit ${pizza.name}'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name'), validator: (val) => val!.isEmpty ? 'Required' : null),
                  TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                  TextFormField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number, validator: (val) => val!.isEmpty ? 'Required' : null),
                  TextFormField(controller: ratingCtrl, decoration: const InputDecoration(labelText: 'Rating (1-5)'), keyboardType: TextInputType.number, validator: (val) => val!.isEmpty ? 'Required' : null),
                  TextFormField(controller: imageUrlCtrl, decoration: const InputDecoration(labelText: 'Image URL'), validator: (val) => val!.isEmpty ? 'Required' : null),
                  StatefulBuilder(builder: (context, setDialogState) {
                    return SwitchListTile(
                      title: const Text('Vegetarian'),
                      value: isVegetarian,
                      onChanged: (val) => setDialogState(() => isVegetarian = val),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final body = <String, dynamic>{
                    'name': nameCtrl.text,
                    'description': descCtrl.text,
                    'price': double.tryParse(priceCtrl.text) ?? 0,
                    'rating': double.tryParse(ratingCtrl.text) ?? 0,
                    'imageUrl': imageUrlCtrl.text,
                    'isVegetarian': isVegetarian,
                  };

                  try {
                    if (isCreating) {
                      await pb.collection('pizzas').create(body: body);
                    } else {
                      await pb.collection('pizzas').update(pizza.id, body: body);
                    }
                    Navigator.of(context).pop(); // ปิด Dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pizza ${isCreating ? "created" : "updated"} successfully!')),
                    );
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text(isCreating ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  // ✅ ฟังก์ชันสำหรับ "ลบ" ข้อมูล
  Future<void> _deletePizza(Pizza pizza) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${pizza.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await pb.collection('pizzas').delete(pizza.id);
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${pizza.name} deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      // ✅ เพิ่มปุ่ม Floating Action Button สำหรับ "เพิ่ม"
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPizzaFormDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Pizza>>(
        future: _pizzasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final pizzas = snapshot.data ?? [];

          if (pizzas.isEmpty) {
            return const Center(child: Text("No pizzas found. Add one!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // เพิ่ม padding ด้านล่างไม่ให้ปุ่ม FAB บัง
            itemCount: pizzas.length,
            itemBuilder: (context, index) {
              final pizza = pizzas[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      pizza.imageUrl,
                      width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.local_pizza, size: 40),
                    ),
                  ),
                  title: Text(pizza.name),
                  subtitle: Text('฿${pizza.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (pizza.isVegetarian)
                        const Tooltip(
                          message: 'Vegetarian',
                          child: Icon(Icons.eco, color: Colors.green),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showPizzaFormDialog(pizza: pizza),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePizza(pizza),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
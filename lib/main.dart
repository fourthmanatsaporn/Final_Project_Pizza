
import 'package:flutter/material.dart';
import 'utils/pocketbase_seed.dart'; // สำหรับ seedPizzas()
import 'page/pizza_home_page.dart';  // สำหรับ PizzaHomePage()

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await seedPizzas(); // บรรทัดนี้จะทำงานได้แล้ว
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizza Shop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          primary: Colors.deepOrange,
          secondary: Colors.amber,
          background: const Color(0xFFFFF8E1),
        ),
        useMaterial3: true,
      ),
      home: PizzaHomePage(), // บรรทัดนี้จะทำงานได้แล้ว
    );
  }
}
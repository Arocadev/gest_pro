import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ObraControlApp());
}

class ObraControlApp extends StatelessWidget {
  const ObraControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ObraControl',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'obras_screen.dart';
import 'pagos_screen.dart';
import 'calendario_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final pages = const [
    ObrasScreen(),
    PagosScreen(),
    CalendarioScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work),
            label: 'Obras',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Pagos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
        ],
      ),
    );
  }
}
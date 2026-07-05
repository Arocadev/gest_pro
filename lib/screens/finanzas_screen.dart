import 'package:flutter/material.dart';

import 'cobros_screen.dart';
import 'pagos_screen.dart';

class FinanzasScreen extends StatelessWidget {
  const FinanzasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFF2F3F5),
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          toolbarHeight: 70,
          title: Image.asset('assets/logo.png', height: 90, fit: BoxFit.contain),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(42),
            child: Material(
              color: Colors.white,
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300, width: 0.5),
                    bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(child: Container(width: 1, color: Colors.grey.shade300)),
                    const TabBar(
                      dividerColor: Colors.transparent,
                      indicatorWeight: 3,
                      labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                      tabs: [Tab(text: 'Pagos'), Tab(text: 'Cobros')],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [PagosScreen(), CobrosScreen()],
        ),
      ),
    );
  }
}
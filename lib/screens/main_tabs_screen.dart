import 'package:flutter/material.dart';
import 'product_list.dart';
import 'navegador_google.dart'; // ou o nome correto do seu navegador

class MainTabsScreen extends StatefulWidget {
  @override
  _MainTabsScreenState createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _currentIndex = 0;

  final List<Widget> _telas = [
    ProductListScreen(),
    NavegadorGoogle(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _telas[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Produtos'),
          NavigationDestination(icon: Icon(Icons.image_search), label: 'Imagens'),
        ],
      ),
    );
  }
}

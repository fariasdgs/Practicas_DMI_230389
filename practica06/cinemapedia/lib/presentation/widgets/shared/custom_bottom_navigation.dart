import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatefulWidget {
  const CustomBottomNavigation({super.key});

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => setState(() => selectedIndex = index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_max), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.label_outline), label: 'Categorías'),
        NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
      ],
    );
  }
}

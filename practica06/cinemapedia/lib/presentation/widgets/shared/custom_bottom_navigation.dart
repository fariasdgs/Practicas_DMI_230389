import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends ConsumerWidget {
  final int currentIndex;

  const CustomBottomNavigation({super.key, required this.currentIndex});

  void onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        context.go('/home/0');
        break;

      case 1:
        context.go('/home/1');
        break;

      case 2:
        context.go('/home/2');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(movieCountryProvider);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (value) => onItemTapped(context, value),
      elevation: 0,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_max),
          label: country.text('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.label_outline),
          label: country.text('categories'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_outline),
          label: country.text('favorites'),
        ),
      ],
    );
  }
}

import 'package:cinemapedia/config/constants/movie_country.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CinemaDrawer extends ConsumerWidget {
  final int currentIndex;
  const CinemaDrawer({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(movieCountryProvider);
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 72,
                    semanticLabel: 'Logo Cinemapedia',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'CINEMAPEDIA',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('230389 · ${selected.flag} ${selected.name}'),
                ],
              ),
            ),
            for (var index = 0; index < 3; index++)
              ListTile(
                leading: Icon(
                  [
                    Icons.home_outlined,
                    Icons.category_outlined,
                    Icons.favorite_border,
                  ][index],
                ),
                title: Text(
                  selected.text(['home', 'categories', 'favorites'][index]),
                ),
                selected: currentIndex == index,
                onTap: () {
                  Navigator.of(context).pop();
                  if (currentIndex != index) context.go('/home/$index');
                },
              ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(selected.text('country')),
            ),
            for (final country in MovieCountry.values)
              ListTile(
                leading: Text(
                  country.flag,
                  style: const TextStyle(fontSize: 25),
                ),
                title: Text(country.name),
                subtitle: Text('${country.continent} · ${country.language}'),
                selected: country == selected,
                trailing: country == selected ? const Icon(Icons.check) : null,
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(movieCountryProvider.notifier).state = country;
                },
              ),
          ],
        ),
      ),
    );
  }
}

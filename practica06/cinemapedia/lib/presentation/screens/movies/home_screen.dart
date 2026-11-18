import 'package:flutter/material.dart';
import 'package:cinemapedia/presentation/widgets/shared/cinema_drawer.dart';

import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'package:cinemapedia/presentation/views/views.dart';

class HomeScreen extends StatelessWidget {
  static const name = 'home-screen';
  final int pageIndex;

  const HomeScreen({super.key, required this.pageIndex});

  List<Widget> get viewRoutes => <Widget>[
    HomeView(isActive: pageIndex == 0),
    const SizedBox(), // <--- categorias View
    const FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    final views = viewRoutes;
    return Scaffold(
      drawer: CinemaDrawer(currentIndex: pageIndex),
      body: IndexedStack(
        index: pageIndex,
        children: [
          for (var index = 0; index < views.length; index++)
            TickerMode(enabled: pageIndex == index, child: views[index]),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(currentIndex: pageIndex),
    );
  }
}

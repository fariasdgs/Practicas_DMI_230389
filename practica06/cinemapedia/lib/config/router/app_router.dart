import '../../presentation/notifications/notices_screen.dart';
import '../../presentation/notifications/notifications.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';

import 'package:cinemapedia/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/home/0',
  routes: [
    GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {
        final pageIndex = int.tryParse(state.pathParameters['page'] ?? '') ?? 0;

        return HomeScreen(
          key: const ValueKey('home-screen'),
          pageIndex: pageIndex.clamp(0, 2),
        );
      },
      routes: [
        GoRoute(
          path: 'movie/:id',
          name: MovieScreen.name,
          builder: (context, state) {
            final movieId = state.pathParameters['id'] ?? 'no-id';

            return MovieScreen(movieId: movieId);
          },
        ),
      ],
    ),

    GoRoute(
      path: '/notificaciones',
      builder: (_, state) => NoticesScreen(
        selected: state.extra is CinemaNotice
            ? state.extra as CinemaNotice
            : null,
      ),
    ),
    GoRoute(path: '/', redirect: (_, _) => '/home/0'),
  ],
);

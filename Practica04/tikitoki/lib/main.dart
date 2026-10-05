import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tikitoki/config/theme/app_theme.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';
import 'package:tikitoki/presentation/screen/discover/discover_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppSeason season;
  Timer? dateTimer;

  @override
  void initState() {
    super.initState();
    season = AppTheme.seasonFor(DateTime.now());
    WidgetsBinding.instance.addObserver(this);
    _scheduleDateCheck();
  }

  void _scheduleDateCheck() {
    dateTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    dateTimer = Timer(nextDay.difference(now), _refreshSeason);
  }

  void _refreshSeason() {
    if (!mounted) return;
    final nextSeason = AppTheme.seasonFor(DateTime.now());
    if (nextSeason != season) setState(() => season = nextSeason);
    _scheduleDateCheck();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshSeason();
  }

  @override
  void dispose() {
    dateTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => DiscoverProvider()..loadNextPage(),
        ),
      ],
      child: MaterialApp(
        title: 'TIKITOKI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().themeFor(season),
        home: DiscoverScreen(season: season),
      ),
    );
  }
}

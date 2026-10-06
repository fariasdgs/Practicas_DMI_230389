import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tikitoki/config/theme/app_theme.dart';
import 'package:tikitoki/presentation/providers/discover_provider.dart';
import 'package:tikitoki/presentation/screen/discover/discover_screen.dart';
import 'package:tikitoki/presentation/widgets/shared/brand_loading.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppSeason season;
  Timer? dateTimer;
  AudioPlayer? entrancePlayer;
  bool entranceFinished = false;

  @override
  void initState() {
    super.initState();
    season = AppTheme.seasonFor(DateTime.now());
    WidgetsBinding.instance.addObserver(this);
    _scheduleDateCheck();
    final sound = switch (season) {
      AppSeason.halloween => 'sounds/witches-laughing.mp3',
      AppSeason.christmas => 'sounds/ho-ho-ho-merry-christmas.mp3',
      AppSeason.tech => null,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_runEntrance(sound));
    });
  }

  Future<void> _runEntrance(String? sound) async {
    try {
      await Future.wait<void>([
        Future<void>.delayed(const Duration(milliseconds: 1400)),
        if (sound != null) _playEntranceSound(sound),
      ]);
    } catch (_) {
      // La entrada no debe bloquear el feed si falla el audio.
    } finally {
      if (mounted) setState(() => entranceFinished = true);
    }
  }

  Future<void> _playEntranceSound(String sound) async {
    final player = AudioPlayer();
    entrancePlayer = player;
    final completed = Completer<void>();
    final subscription = player.onPlayerComplete.listen((_) {
      if (!completed.isCompleted) completed.complete();
    });
    try {
      await player
          .play(AssetSource(sound))
          .timeout(const Duration(seconds: 10));
      await completed.future.timeout(const Duration(seconds: 20));
    } catch (_) {
      // Si el dispositivo bloquea el audio, permitir entrar al feed igualmente.
    } finally {
      await subscription.cancel();
      if (entrancePlayer == player) {
        entrancePlayer = null;
        await player.dispose();
      }
    }
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
    entrancePlayer?.dispose();
    entrancePlayer = null;
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
        home: Stack(
          fit: StackFit.expand,
          children: [
            DiscoverScreen(season: season, playbackEnabled: entranceFinished),
            IgnorePointer(
              ignoring: entranceFinished,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: entranceFinished
                    ? const SizedBox.shrink()
                    : SeasonEntrance(season: season),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

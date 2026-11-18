import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

class CinemaNotice {
  final String id;
  final String title;
  final String body;
  final int? movieId;

  const CinemaNotice(this.id, this.title, this.body, this.movieId);

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'movieId': movieId,
  };

  static CinemaNotice fromJson(Map<String, dynamic> data) => CinemaNotice(
    data['id'] as String,
    data['title'] as String,
    data['body'] as String,
    data['movieId'] as int?,
  );

  factory CinemaNotice.remote(RemoteMessage message) => CinemaNotice(
    message.messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
    message.notification?.title ??
        message.data['title']?.toString() ??
        'Cinemapedia',
    message.notification?.body ?? message.data['body']?.toString() ?? '',
    int.tryParse(message.data['movieId']?.toString() ?? ''),
  );
}

Future<FirebaseApp> _initializeFirebase() {
  final env = dotenv.env;
  return Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: env['FCM_API_KEY']!,
      appId: env['FCM_APP_ID']!,
      messagingSenderId: env['FCM_SENDER_ID']!,
      projectId: env['FCM_PROJECT_ID']!,
    ),
  );
}

@pragma('vm:entry-point')
Future<void> cinemaBackgroundMessage(RemoteMessage message) async {
  await dotenv.load(fileName: '.env', isOptional: true);
  await _initializeFirebase();
  // Notification payloads are presented by the OS in the background.
}

sealed class NoticeEvent {}

class NoticeReceived extends NoticeEvent {
  final CinemaNotice notice;
  NoticeReceived(this.notice);
}

class NoticesBloc extends Bloc<NoticeEvent, List<CinemaNotice>> {
  NoticesBloc() : super(const []) {
    on<NoticeReceived>(
      (event, emit) => emit([
        event.notice,
        ...state.where((notice) => notice.id != event.notice.id),
      ]),
    );
  }
}

class CinemaNotifications extends ChangeNotifier {
  final inbox = NoticesBloc();
  final _local = FlutterLocalNotificationsPlugin();
  final List<StreamSubscription<RemoteMessage>> _subscriptions = [];
  FirebaseMessaging? _messaging;
  CinemaNotice? initialNotice;
  bool available = false;
  bool get pushConfigured => _messaging != null;

  Future<void> initialize(void Function(CinemaNotice) onOpen) async {
    if (kIsWeb ||
        ![
          TargetPlatform.iOS,
          TargetPlatform.android,
        ].contains(defaultTargetPlatform)) {
      return;
    }
    void open(CinemaNotice notice) {
      if (inbox.isClosed) return;
      inbox.add(NoticeReceived(notice));
      onOpen(notice);
    }

    CinemaNotice? decode(String? payload) {
      if (payload == null) return null;
      try {
        return CinemaNotice.fromJson(
          jsonDecode(payload) as Map<String, dynamic>,
        );
      } catch (_) {
        return null;
      }
    }

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_cinemapedia'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final notice = decode(response.payload);
        if (notice != null) open(notice);
      },
    );
    if (inbox.isClosed) return;
    available = true;
    notifyListeners();
    final launch = await _local.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      initialNotice = decode(launch?.notificationResponse?.payload);
    }
    if (!dotenv.isInitialized ||
        ![
          'FCM_API_KEY',
          'FCM_APP_ID',
          'FCM_SENDER_ID',
          'FCM_PROJECT_ID',
        ].every((key) => dotenv.env[key]?.isNotEmpty ?? false)) {
      return;
    }
    await _initializeFirebase();
    if (inbox.isClosed) return;
    FirebaseMessaging.onBackgroundMessage(cinemaBackgroundMessage);
    final messaging = _messaging = FirebaseMessaging.instance;
    notifyListeners();
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen((message) {
        final notice = CinemaNotice.remote(message);
        inbox.add(NoticeReceived(notice));
        unawaited(_showForeground(notice));
      }),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => open(CinemaNotice.remote(message)),
      ),
    );
    final initial = await messaging.getInitialMessage();
    if (initial != null) initialNotice = CinemaNotice.remote(initial);
  }

  Future<void> _showForeground(CinemaNotice notice) async {
    try {
      await _show(notice);
    } catch (error) {
      debugPrint('No se pudo mostrar el aviso local: ${error.runtimeType}');
    }
  }

  Future<bool> requestPermission() async {
    final messaging = _messaging;
    if (messaging != null) {
      final settings = await messaging.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _local
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return await _local
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }

  Future<String?> token() async {
    final messaging = _messaging;
    if (messaging == null) return null;
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        await messaging.getAPNSToken() == null) {
      return null;
    }
    // Keep compatibility with the HTTP v1 device registration token.
    // ignore: deprecated_member_use
    return messaging.getToken();
  }

  Future<void> demo() async {
    if (!await requestPermission()) {
      throw StateError('Activa las notificaciones en Ajustes.');
    }
    final notice = CinemaNotice(
      DateTime.now().microsecondsSinceEpoch.toString(),
      'Cinemapedia',
      'Esta es una notificación de prueba.',
      null,
    );
    await _show(notice);
    inbox.add(NoticeReceived(notice));
  }

  Future<void> _show(CinemaNotice notice) => _local.show(
    id: notice.id.hashCode & 0x7fffffff,
    title: notice.title,
    body: notice.body,
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'cinema',
        'Cinemapedia',
        importance: Importance.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: jsonEncode(notice.toJson()),
  );

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(inbox.close());
    super.dispose();
  }
}

class NotificationScope extends StatefulWidget {
  final GoRouter router;
  final Widget child;
  const NotificationScope({
    super.key,
    required this.router,
    required this.child,
  });

  @override
  State<NotificationScope> createState() => _NotificationScopeState();
}

class _NotificationScopeState extends State<NotificationScope> {
  final service = CinemaNotifications();

  @override
  void initState() {
    super.initState();
    if (!dotenv.isInitialized) return;
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      await service.initialize(_open);
      if (!mounted) return;
      final notice = service.initialNotice;
      if (notice != null) {
        service.inbox.add(NoticeReceived(notice));
        _open(notice);
      }
    } catch (error) {
      debugPrint('Configuración de notificaciones: ${error.runtimeType}');
    }
  }

  void _open(CinemaNotice notice) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final movieId = notice.movieId;
      if (movieId != null && movieId > 0) {
        widget.router.push('/home/0/movie/$movieId');
      } else {
        widget.router.push('/notificaciones', extra: notice);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) => RepositoryProvider.value(
    value: service,
    child: BlocProvider.value(value: service.inbox, child: widget.child),
  );

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }
}

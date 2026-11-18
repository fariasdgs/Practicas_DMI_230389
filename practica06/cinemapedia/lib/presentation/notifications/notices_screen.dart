import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'notifications.dart';

class NoticesScreen extends StatelessWidget {
  final CinemaNotice? selected;
  const NoticesScreen({super.key, this.selected});

  @override
  Widget build(BuildContext context) {
    final service = context.read<CinemaNotifications>();
    Future<void> run(Future<void> Function() action) async {
      try {
        await action();
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se pudo activar la notificación. Revisa los permisos y la configuración.',
              ),
            ),
          );
        }
      }
    }

    return ListenableBuilder(
      listenable: service.changes,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Notificaciones')),
        body: BlocBuilder<NoticesBloc, List<CinemaNotice>>(
          builder: (context, notices) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (selected != null) ...[
                Text(
                  selected!.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(selected!.body),
                const Divider(),
              ],
              if (service.available)
                FilledButton(
                  onPressed: () => run(service.demo),
                  child: const Text('Probar notificación local'),
                ),
              if (service.pushConfigured)
                OutlinedButton(
                  onPressed: () => run(() async {
                    if (!await service.requestPermission()) {
                      throw StateError('Permiso denegado');
                    }
                    final token = await service.token();
                    if (token == null) {
                      throw StateError('Registro push pendiente');
                    }
                    await Clipboard.setData(ClipboardData(text: token));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Identificador de prueba copiado'),
                        ),
                      );
                    }
                  }),
                  child: const Text('Copiar identificador push de prueba'),
                ),
              if (!service.pushConfigured)
                const Text(
                  'Las notificaciones push requieren configurar Firebase.',
                ),
              if (notices.isEmpty)
                const ListTile(title: Text('Aún no hay notificaciones')),
              for (final notice in notices)
                ListTile(
                  title: Text(notice.title),
                  subtitle: Text(notice.body),
                  onTap: () {
                    final id = notice.movieId;
                    if (id != null && id > 0) {
                      context.push('/home/0/movie/$id');
                    } else {
                      context.push('/notificaciones', extra: notice);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

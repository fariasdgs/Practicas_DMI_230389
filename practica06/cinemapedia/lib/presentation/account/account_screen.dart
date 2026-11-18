import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_form.dart';
import 'account_session.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _registering = false;

  String _message(Object? error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      if (error.response == null) {
        return 'No se pudo conectar con el servidor de Cinemapedia.';
      }
    }
    return 'No se pudo completar la solicitud. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(accountSessionProvider);
    final user = session.asData?.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (user != null) ...[
              Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
              Text(user.email),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: ref.read(accountSessionProvider.notifier).logout,
                child: const Text('Cerrar sesión'),
              ),
            ] else ...[
              Text(
                _registering ? 'Crear cuenta' : 'Iniciar sesión',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (session.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _message(session.error),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              AccountForm(
                key: ValueKey(_registering),
                registering: _registering,
                busy: session.isLoading,
                onSubmit: (email, password, name) => ref
                    .read(accountSessionProvider.notifier)
                    .authenticate(email, password, _registering ? name : null),
              ),
              TextButton(
                onPressed: session.isLoading
                    ? null
                    : () {
                        ref.read(accountSessionProvider.notifier).logout();
                        setState(() => _registering = !_registering);
                      },
                child: Text(
                  _registering ? 'Ya tengo cuenta' : 'Quiero crear una cuenta',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

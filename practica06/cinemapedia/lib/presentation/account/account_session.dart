import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountSession {
  final String name;
  final String email;
  final String token;
  const AccountSession(this.name, this.email, this.token);
}

class AccountRepository {
  final Dio _client;
  AccountRepository(String apiUrl)
    : _client = Dio(
        BaseOptions(
          baseUrl: apiUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  Future<AccountSession> authenticate(
    String email,
    String password,
    String? name,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      name == null ? '/auth/login' : '/auth/register',
      data: {'email': email, 'password': password, 'name': ?name},
    );
    final data = response.data!;
    final token = data['token'] as String;
    final profile = await _client.get<Map<String, dynamic>>(
      '/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return AccountSession(
      profile.data!['name'] as String,
      profile.data!['email'] as String,
      token,
    );
  }
}

final accountRepositoryProvider = Provider(
  (ref) => AccountRepository(
    (dotenv.isInitialized ? dotenv.env['CINEMA_API_URL'] : null) ??
        'http://127.0.0.1:3000',
  ),
);

final accountSessionProvider =
    NotifierProvider<AccountNotifier, AsyncValue<AccountSession?>>(
      AccountNotifier.new,
    );

class AccountNotifier extends Notifier<AsyncValue<AccountSession?>> {
  @override
  AsyncValue<AccountSession?> build() => const AsyncData(null);

  Future<void> authenticate(String email, String password, String? name) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(accountRepositoryProvider)
          .authenticate(email, password, name),
    );
  }

  void logout() => state = const AsyncData(null);
}

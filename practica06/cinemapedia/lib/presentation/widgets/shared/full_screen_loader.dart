import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/config/constants/movie_country.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_country_provider.dart';

class FullScreenLoader extends ConsumerWidget {
  const FullScreenLoader({super.key});

  Stream<String> getLoadingMessages(MovieCountry country) {
    final messages = [
      'loadingMovies',
      'loadingPopcorn',
      'loadingPopular',
      'loadingCalling',
      'loadingAlmost',
      'loadingSlow',
    ].map(country.text).toList();

    return Stream.periodic(const Duration(milliseconds: 1200), (step) {
      return messages[step];
    }).take(messages.length);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(movieCountryProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(country.text('pleaseWait')),
          const SizedBox(height: 10),
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 10),

          StreamBuilder(
            stream: getLoadingMessages(country),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text(country.text('loading'));

              return Text(snapshot.data!);
            },
          ),
        ],
      ),
    );
  }
}

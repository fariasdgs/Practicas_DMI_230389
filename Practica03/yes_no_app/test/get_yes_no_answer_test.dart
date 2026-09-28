import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class SequenceRandom implements Random {
  int value = 0;

  @override
  int nextInt(int max) => value++ % max;
  @override
  bool nextBool() => throw UnimplementedError();
  @override
  double nextDouble() => throw UnimplementedError();
}

void main() {
  test(
    'Los 100 valores posibles dan 40 Sí, 40 No y 20 Tal Vez con su GIF',
    () async {
      final counts = <String, int>{};
      final client = MockClient((request) async {
        final forced = request.url.queryParameters['force']!;
        expect(request.url.host, 'yesno.wtf');
        expect(request.url.path, '/api');
        counts.update(forced, (count) => count + 1, ifAbsent: () => 1);
        return http.Response(
          jsonEncode({
            'answer': forced,
            'image': 'https://yesno.wtf/assets/$forced/test.gif',
          }),
          200,
        );
      });
      addTearDown(client.close);
      final helper = GetYesNoAnswer(random: SequenceRandom(), client: client);
      for (var i = 0; i < 100; i++) {
        final message = await helper.getAnswer();
        final answer = i < 40 ? 'yes' : (i < 80 ? 'no' : 'maybe');
        expect(
          message.text,
          {'yes': 'Sí', 'no': 'No', 'maybe': 'Tal Vez'}[answer],
        );
        expect(message.imageUrl, contains('/$answer/'));
        expect(message.fromWho, FromWho.hers);
      }
      expect(counts, {'yes': 40, 'no': 40, 'maybe': 20});
    },
  );

  test(
    'Rechaza una respuesta con GIF ausente o categoría incorrecta',
    () async {
      for (final data in [
        {'answer': 'yes'},
        {'answer': 'no', 'image': 'https://example.com/no.gif'},
      ]) {
        final client = MockClient(
          (_) async => http.Response(jsonEncode(data), 200),
        );
        addTearDown(client.close);
        final helper = GetYesNoAnswer(random: SequenceRandom(), client: client);
        await expectLater(helper.getAnswer(), throwsFormatException);
      }
    },
  );

  test('Propaga el error HTTP para que el provider avise al usuario', () async {
    final client = MockClient((_) async => http.Response('Unavailable', 503));
    addTearDown(client.close);
    await expectLater(
      GetYesNoAnswer(client: client).getAnswer(),
      throwsException,
    );
  });
}

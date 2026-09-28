import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:yes_no_app/domain/entities/message.dart';

class GetYesNoAnswer {
  final Random _random;
  final http.Client? client;

  GetYesNoAnswer({Random? random, this.client})
    : _random = random ?? Random();

  Future<Message> getAnswer() async {
    // 0–39: Sí (40%), 40–79: No (40%), 80–99: Tal Vez (20%).
    final value = _random.nextInt(100);
    final answer = value < 40 ? 'yes' : (value < 80 ? 'no' : 'maybe');
    final uri = Uri.https('yesno.wtf', '/api', {'force': answer});
    final response = await (client?.get(uri) ?? http.get(uri)).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener la respuesta');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final image = data['image'];
    if (data['answer'] != answer || image is! String || image.isEmpty) {
      throw const FormatException('La respuesta de la API no es válida');
    }

    final text = switch (answer) {
      'yes' => 'Sí',
      'no' => 'No',
      _ => 'Tal Vez',
    };
    return Message(text, image, FromWho.hers);
  }
}

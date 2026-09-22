import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yes_no_app/domain/entities/message.dart';

class GetYesNoAnswer {
  Future<Message> getAnswer() async {
    final response = await http
        .get(Uri.parse('https://yesno.wtf/api'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener la respuesta');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final text = switch (data['answer']) {
      'yes' => 'Sí',
      'no' => 'No',
      _ => 'Tal vez',
    };

    return Message(text, data['image'] as String?, FromWho.hers);
  }
}

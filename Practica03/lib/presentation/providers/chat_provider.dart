import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> message = [
    Message(Text: 'Hola', fromWho: FromWho.mine),
    Message(Text: '¿Ya regresaste del gimnsio?', fromWho: FromWho.mine),
  ];

  Future<void> sendMessage(String text) async {}
}

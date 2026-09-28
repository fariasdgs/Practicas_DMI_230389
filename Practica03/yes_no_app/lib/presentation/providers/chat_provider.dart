import 'package:flutter/material.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  final chatScrollController = ScrollController();
  final GetYesNoAnswer getYesNoAnswer;
  bool _disposed = false;

  ChatProvider({GetYesNoAnswer? getYesNoAnswer})
    : getYesNoAnswer = getYesNoAnswer ?? GetYesNoAnswer();

  List<Message> messageList = [
    Message('Hola amor!', null, FromWho.mine),
    Message('Ya regresaste del trabajo?', null, FromWho.mine),
  ];

  Future<void> sendMessage(String text) async {
    text = text.trim();
    if (text.isEmpty || _disposed) return;

    final newMessage = Message(text, null, FromWho.mine);
    messageList.add(newMessage);
    notifyListeners();
    moveScrollToBottom();

    if (text.endsWith('?')) {
      await herReply();
    }
  }

  Future<void> herReply() async {
    if (_disposed) return;
    Message herMessage;
    try {
      herMessage = await getYesNoAnswer.getAnswer();
    } catch (_) {
      herMessage = Message(
        'No pude obtener una respuesta. Intenta de nuevo.',
        null,
        FromWho.hers,
      );
    }
    if (_disposed) return;

    messageList.add(herMessage);
    notifyListeners();
    await moveScrollToBottom();
  }

  Future<void> moveScrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (_disposed || !chatScrollController.hasClients) return;

    await chatScrollController.animateTo(
      chatScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    chatScrollController.dispose();
    super.dispose();
  }
}

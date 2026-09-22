import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';

class FakeAnswer extends GetYesNoAnswer {
  bool fail = false;
  int calls = 0;

  @override
  Future<Message> getAnswer() async {
    calls++;
    if (fail) throw Exception('Sin conexión');
    return Message('Sí', 'https://example.com/yes.gif', FromWho.hers);
  }
}

void main() {
  test('Ignora mensajes vacíos y solo responde a preguntas', () async {
    final answer = FakeAnswer();
    final provider = ChatProvider(getYesNoAnswer: answer);
    addTearDown(provider.dispose);

    await provider.sendMessage('   ');
    expect(provider.messageList, hasLength(2));
    await provider.sendMessage('Hola');
    expect(provider.messageList.last.text, 'Hola');
    expect(answer.calls, 0);

    await provider.sendMessage('Vienes? ');
    expect(provider.messageList, hasLength(5));
    expect(provider.messageList[3].fromWho, FromWho.mine);
    expect(provider.messageList.last.fromWho, FromWho.hers);
    expect(provider.messageList.last.text, 'Sí');
    expect(answer.calls, 1);
  });

  test('Informa si falla la consulta de la respuesta', () async {
    final provider = ChatProvider(getYesNoAnswer: FakeAnswer()..fail = true);
    addTearDown(provider.dispose);

    await provider.sendMessage('Vienes?');
    expect(provider.messageList.last.text, contains('Intenta de nuevo'));
  });
}

import 'package:flutter/material.dart';

class MessageFieldBox extends StatefulWidget {
  final ValueChanged<String> onValue;

  const MessageFieldBox({super.key, required this.onValue});

  @override
  State<MessageFieldBox> createState() => _MessageFieldBoxState();
}

class _MessageFieldBoxState extends State<MessageFieldBox> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    widget.onValue(text);
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outlineInputBorder = UnderlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(40),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: _textController,
        focusNode: _focusNode,
        textInputAction: TextInputAction.send,
        onTapOutside: (_) => _focusNode.unfocus(),
        onFieldSubmitted: (_) => _sendMessage(),
        decoration: InputDecoration(
          hintText: 'End your message with a "?"',
          enabledBorder: outlineInputBorder,
          focusedBorder: outlineInputBorder,
          filled: true,
          suffixIcon: IconButton(
            tooltip: 'Enviar mensaje',
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_outlined),
          ),
        ),
      ),
    );
  }
}

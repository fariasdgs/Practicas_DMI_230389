import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';

/// Burbuja compartida: texto, GIF opcional y hora fija de envío.
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final mine = message.fromWho == FromWho.mine;
    final colors = Theme.of(context).colorScheme;
    final background = mine
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;
    final foreground = mine ? colors.onPrimaryContainer : colors.onSurface;
    final time = message.sentAt.toLocal();
    final hour =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                message.text,
                style: TextStyle(color: foreground, fontSize: 16),
              ),
              if (message.imageUrl != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    message.imageUrl!,
                    width: maxWidth - 20,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => SizedBox(
                      height: 80,
                      child: Center(
                        child: Text(
                          'No se pudo cargar el GIF',
                          style: TextStyle(color: foreground),
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                hour,
                textAlign: TextAlign.right,
                semanticsLabel: 'Enviado a las $hour',
                style: TextStyle(
                  fontSize: 11,
                  color: foreground.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

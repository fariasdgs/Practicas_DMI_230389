enum FromWho { mine, hers }

class Message {
  final String text;
  final String? imageUrl;
  final FromWho fromWho;

  final DateTime sentAt;

  Message(this.text, this.imageUrl, this.fromWho, {DateTime? sentAt})
    : sentAt = sentAt ?? DateTime.now();
}

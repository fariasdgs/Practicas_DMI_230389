enum FromWho { mine, hers }

class Message {
  final String text;
  final String? imageUrl;
  final FromWho fromWho;

  Message(this.text, this.imageUrl, this.fromWho);
}

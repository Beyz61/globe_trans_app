class Message {
  final String senderId;
  final String text;
  final bool isSent;
  final DateTime timestamp;
  final bool isRead;
  final String contactName;

  Message(this.text, this.isSent, this.timestamp,
      {this.isRead = false, required this.contactName, required this.senderId});
}

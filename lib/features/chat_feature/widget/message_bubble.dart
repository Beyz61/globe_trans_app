import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:globe_trans_app/features/shared/models/message.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSent;
    final dateFormat = DateFormat("HH:mm");

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: ChatBubble(
        clipper: ChatBubbleClipper1(
          type: isSent ? BubbleType.sendBubble : BubbleType.receiverBubble,
        ),
        alignment: isSent ? Alignment.topRight : Alignment.topLeft,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        backGroundColor:
            isSent ? const Color.fromARGB(255, 22, 174, 27) : Colors.white,
        child: Column(
          crossAxisAlignment:
              isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(color: isSent ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 5),
            Text(
              dateFormat.format(message.timestamp),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

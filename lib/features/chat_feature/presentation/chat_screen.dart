import 'package:flutter/material.dart';
import 'package:globe_trans_app/database_repository.dart';
import 'package:intl/intl.dart';

class Message {
  final String text;
  final bool isSent;
  final DateTime timestamp;

  Message(this.text, this.isSent, this.timestamp);
}

class Chat {
  final List<Message> messages;

  Chat(this.messages);
}

class ChatScreen extends StatefulWidget {
  final String contactName;

  const ChatScreen(
      {super.key,
      required this.contactName,
      required this.repository}); // Add required this.repository

  final DatabaseRepository repository;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> messages = [
    Message(
        "Hello, how are you?\n_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _\nWie geht e dir?",
        false,
        DateTime.now().subtract(const Duration(minutes: 5))),
    Message("Mir geht's gut, danke!", true,
        DateTime.now().subtract(const Duration(minutes: 4))),
    Message(
        "Do you have time today?\n_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _\nHast du heute Zeit?",
        false,
        DateTime.now().subtract(const Duration(minutes: 3))),
    Message("Ja, gerne! Lass uns treffen.", true,
        DateTime.now().subtract(const Duration(minutes: 2))),
  ];

  final TextEditingController _controller = TextEditingController();

  //void _sendMessage() async {
  //await Future.delayed(
  // const Duration(seconds: 3),
  //);

  //   if (_controller.text.isNotEmpty) {
  //     setState(() {
  //       messages.add(Message(_controller.text, true, DateTime.now()));
  //       _controller.clear();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: "SFProDisplay",
            fontWeight: FontWeight.w500,
            fontSize: 20),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage("assets/kontaktfoto.jpeg"),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Text(widget.contactName),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 54, 106, 76),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isSent = message.isSent;
    final dateFormat = DateFormat("HH:mm");

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSent ? const Color.fromARGB(255, 22, 174, 27) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isSent
                  ? const Color.fromARGB(255, 22, 174, 27)
                  : Colors.grey),
        ),
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

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Nachricht senden...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          IconButton(
              icon: const Icon(Icons.send, color: Colors.green),
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  await widget.repository.sendMessage(
                      Message(_controller.text, true, DateTime.now()));
                  setState(() {
                    messages
                        .add(Message(_controller.text, true, DateTime.now()));
                    _controller.clear();
                  });
                }
              }),
        ],
      ),
    );
  }
}

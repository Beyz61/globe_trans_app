import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globe_trans_app/features/shared/database_repository.dart';
import 'package:provider/provider.dart';

class Message {
  final String text;
  final bool isSent;
  final DateTime timestamp;
  final bool isRead; // Add this property

  Message(this.text, this.isSent, this.timestamp, {this.isRead = false});
}

class Chat {
  final List<Message> messages;

  Chat(this.messages);
}

class ChatScreen extends StatefulWidget {
  final String contactName;

  const ChatScreen({
    super.key,
    required this.contactName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> messages = [
    // Message(
    //     "Hello, how are you?\n_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _\nWie geht e dir?",
    //     false,
    //     DateTime.now().subtract(const Duration(minutes: 5))),
    // Message("Mir geht's gut, danke!", true,
    //     DateTime.now().subtract(const Duration(minutes: 4))),
    // Message(
    //     "Do you have time today?\n_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _\nHast du heute Zeit?",
    //     false,
    //     DateTime.now().subtract(const Duration(minutes: 3))),
    // Message("Ja, gerne! Lass uns treffen.", true,
    //     DateTime.now().subtract(const Duration(minutes: 2))),
  ];

  final TextEditingController _controller = TextEditingController();

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
            child: FutureBuilder(
              future: context.read<DatabaseRepository>().getAllMessages(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Nachrichten konnten nicht geladen werden."),
                  );
                } else if (!snapshot.hasData) {
                  return Center(
                      child: Platform.isAndroid
                          ? const CircularProgressIndicator()
                          : const CupertinoActivityIndicator());
                }
                return ListView.builder(
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final now = DateTime.now();
                      final chatStartDate =
                          messages.isNotEmpty ? messages.first.timestamp : now;
                      final isToday = now.day == chatStartDate.day &&
                          now.month == chatStartDate.month &&
                          now.year == chatStartDate.year;
                      final startDateText = isToday
                          ? "Heute"
                          : "${_getWeekday(chatStartDate.weekday)} ${chatStartDate.day}.${_getMonth(chatStartDate.month)}";
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            "Chat gestartet am $startDateText",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      );
                    }
                    final message = messages[index - 1];
                    return Align(
                      alignment: message.isSent
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: IntrinsicWidth(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width *
                                0.6, // Adjusted width
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: message.isSent
                                ? Colors.green
                                : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: message.isSent
                                  ? const Radius.circular(20)
                                  : Radius.zero,
                              bottomRight: message.isSent
                                  ? Radius.zero
                                  : const Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: message.isSent
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      color: message.isSent
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (message.isSent)
                                    Icon(
                                      message.isRead
                                          ? Icons.done_all
                                          : Icons.check,
                                      color: message.isRead
                                          ? Colors.blue
                                          : Colors.grey,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
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
                  setState(() {
                    messages.add(Message(_controller.text, true, DateTime.now(),
                        isRead: true)); // Set isRead to true for testing
                    _controller.clear();
                  });
                }
              }),
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    const weekdays = ["Mo.", "Di.", "Mi.", "Do.", "Fr.", "Sa.", "So."];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      "Jan.",
      "Feb.",
      "Mär.",
      "Apr.",
      "Mai",
      "Jun.",
      "Jul.",
      "Aug.",
      "Sep.",
      "Okt.",
      "Nov.",
      "Dez."
    ];
    return months[month - 1];
  }
}

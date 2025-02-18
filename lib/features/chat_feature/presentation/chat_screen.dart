import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globe_trans_app/features/shared/database_repository.dart';
import 'package:globe_trans_app/features/shared/models/message.dart';
import 'package:provider/provider.dart';

class Chat {
  final List<Message> messages;

  Chat(this.messages);
}

class ChatScreen extends StatefulWidget {
  final String contactName;
  final String contactPhone;

  const ChatScreen({
    super.key,
    required this.contactName,
    required this.contactPhone,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> messages = [];

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    await Provider.of<DatabaseRepository>(context, listen: false)
        .getMessagesForContact(widget.contactPhone)
        .then(
      (value) {
        value.listen((event) {
          setState(() {
            messages.clear();
            messages.addAll(event);
          });
        });
      },
    );
  }

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
                        final chatStartDate = messages.isNotEmpty
                            ? messages.first.timestamp
                            : now;
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
                      final isSender = message.senderId !=
                          (FirebaseAuth.instance.currentUser?.uid ?? "");

                      return Align(
                        alignment: isSender
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
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
                              color: isSender
                                  ? const Color.fromARGB(87, 34, 36, 36)
                                  : Colors.green,
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
                }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Nachricht senden...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                print(FirebaseAuth.instance.currentUser?.uid ?? "");

                if (_controller.text.isNotEmpty) {
                  final newMessage = Message(
                      _controller.text, true, DateTime.now(),
                      isRead: true,
                      contactName: widget.contactName,
                      senderId: FirebaseAuth.instance.currentUser?.uid ?? "");
                  setState(() {
                    messages.add(newMessage);
                  });
                  _controller.clear();
                  await context
                      .read<DatabaseRepository>()
                      .sendMessage(newMessage, widget.contactPhone);
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

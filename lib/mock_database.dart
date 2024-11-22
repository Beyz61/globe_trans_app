import 'package:globe_trans_app/database_repository.dart';
import 'package:globe_trans_app/features/chat_feature/presentation/chat_screen.dart';
import 'package:globe_trans_app/features/shared/name_repo.dart';

class MockDatabase implements DatabaseRepository {
  final List<Message> _messages = [];
  final List<Chat> _chats = [];

  // @override
  // Future<void> getMessage(Message message) async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   _messages.add(message);
  // }

  @override
  Future<void> sendMessage(Message message) async {
    await Future.delayed(
        const Duration(seconds: 3), () => _messages.add(message));
  }

  @override
  Future<void> deleteMessage(Message message) async {
    await Future.delayed(const Duration(seconds: 1));
    _messages.remove(message);
  }

  @override
  Future<void> updateMessage(
      Message message, String newContent, String newTimeStamp) async {
    final index = _messages.indexOf(message);
    if (index != -1) {
      _messages[index] =
          Message(newContent, message.isSent, DateTime.parse(newTimeStamp));
    }
  }

  @override
  Future<List<Message>> getAllMessages() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.unmodifiable(_messages);
  }

  @override
  Future<void> newGroupChat(List<Message> messages) async {
    await Future.delayed(const Duration(seconds: 1));
    _chats.add(Chat(messages));
  }

  @override
  Future<void> createChat(Message message, String receiver) async {
    await Future.delayed(const Duration(seconds: 1));
    _chats.add(Chat([message]));
  }

  @override
  Future<List<Chat>> getAllChats() async {
    await Future.delayed(const Duration(seconds: 1));
    return _chats;
  }

  // Kontakte
  @override
  Future<List<String>> getContactList() async {
    await Future.delayed(const Duration(seconds: 3));
    return names;
  }
}

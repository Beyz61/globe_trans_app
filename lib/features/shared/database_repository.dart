import 'package:globe_trans_app/features/adcontact_feature/presentation/class.contact.dart';
import 'package:globe_trans_app/features/chat_feature/presentation/chat_screen.dart'
    as chat;
import 'package:globe_trans_app/features/shared/models/message.dart'
    as shared; // Update import

abstract class DatabaseRepository {
  // Message

  // Wenn kein phone verification !!!
  Future<void> saveUserPhoneNumber(String phoneNumber);

  // Future<void> getMessage(Message message);

  // Sende Nachrichten
  Future<void> sendMessage(
      shared.Message message, String contactPhoneNumber) async {
    // Implementation to save the message to the database
    // Example:
    // await database.insert('messages', {
    //   'text': message.text,
    //   'isSent': message.isSent ? 1 : 0,
    //   'timestamp': message.timestamp.toIso8601String(),
    //   'isRead': message.isRead ? 1 : 0,
    //   'contactName': message.contactName,
    //   'senderId': message.senderId,
    //   'contactPhoneNumber': contactPhoneNumber,
    // });
  }

  Future<void> saveMessage(shared.Message message);

  // Löschen einer Nachricht
  Future<void> deleteMessage(shared.Message message);

  // Update einer Nachricht
  Future<void> updateMessage(
      shared.Message message, String newContent, String newTimeStamp);

  // Übersicht aller Nachrichten
  Future<List<shared.Message>> getAllMessages();

  // Hier kommt das ganze für Chat hin

  Future<void> newGroupChat(List<shared.Message> messages);

  // Neue chat erstellen
  Future<void> createChat(shared.Message message, String receiver);

  // Übersicht aller chats
  Future<List<chat.Chat>> getAllChats();

  // hinzufügen zu chats
  Future<void> addToChats(Contact contact);
  Future<void> removeFromChats(Contact contact);
  Future<List<Contact>> getChatContacts();

  // Kontakte
  Future<List<Contact>> getContactList();

  // Kontakte hinzufügen
  Future<void> addContact(String firstName, String lastName, String email,
      String phoneNumber, String image);
  notifyListeners();

  // Kontakte aktualisieren
  Future<void> updateContact(Contact contact, String firstName, String lastName,
      String email, String phoneNumber, String image);

  // Kontakte löschen
  Future<void> deleteContact(Contact contact);

  // Kontakte Speichern
  Future<void> saveContactList(List<Contact> contacts);

  // Kontakt Liste anzeigen

  Future<void> getContact(Contact contact);

  Future<List<shared.Message>> getMessagesForContact(String contactName) async {
    return [
      shared.Message("Hello, how are you?", false,
          DateTime.now().subtract(const Duration(minutes: 5)),
          contactName: contactName, senderId: 'sender1'),
      shared.Message("I'm good, thanks!", true,
          DateTime.now().subtract(const Duration(minutes: 4)),
          contactName: contactName, senderId: 'sender2'),
    ];
  }
}

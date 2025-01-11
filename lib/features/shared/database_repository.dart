import 'package:globe_trans_app/features/adcontact_feature/presentation/class.contact.dart';
import 'package:globe_trans_app/features/chat_feature/presentation/chat_screen.dart';

abstract class DatabaseRepository {
  // Message

  // Future<void> getMessage(Message message);

  // Sende Nachrichten
  Future<void> sendMessage(Message message);

  // Löschen einer Nachricht
  Future<void> deleteMessage(Message message);

  // Update einer Nachricht
  Future<void> updateMessage(
      Message message, String newContent, String newTimeStamp);

  // Übersicht aller Nachrichten
  Future<List<Message>> getAllMessages();

  // Hier kommt das ganze für Chat hin

  Future<void> newGroupChat(List<Message> messages);

  // Neue chat erstellen
  Future<void> createChat(Message message, String receiver);

  // Übersicht aller chats
  Future<List<Chat>> getAllChats();

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
}

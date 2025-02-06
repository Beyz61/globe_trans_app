import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:globe_trans_app/features/adcontact_feature/presentation/class.contact.dart';
import 'package:globe_trans_app/features/chat_feature/presentation/chat_screen.dart';
import 'package:globe_trans_app/features/shared/database_repository.dart';
import 'package:globe_trans_app/features/shared/models/message.dart';

class FirebaseDatabaseRepository implements DatabaseRepository {
  @override
  Future<List<Message>> getMessagesForContact(String contactPhoneNumber) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    final snapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("messages")
        .where("contactId", isEqualTo: contactPhoneNumber)
        .get();

    return snapshot.docs.map((doc) {
      return Message(
        doc["text"],
        doc["isSent"],
        DateTime.parse(doc["timestamp"]),
        senderId: doc["senderId"],
        contactName: doc["contactName"],
        isRead: doc["isRead"],
      );
    }).toList();
  }

  @override
  void notifyListeners() {
    // noch nicht implementiert
  }

  // Benutzer-Telefonnummer abrufen
  Future<String> getUserPhoneNumber() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final userDoc = await firestore.collection("users").doc(user.uid).get();
        return userDoc["phoneNumber"];
      } else {
        print("Kein authentifizierter Benutzer gefunden.");
        return '';
      }
    } catch (e) {
      print("Fehler beim Abrufen der Telefonnummer: $e");
      return '';
    }
  }

  // Benutzer-ID abrufen
  Future<String> getUserId() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        print("Kein authentifizierter Benutzer gefunden.");
        return '';
      }
    } catch (e) {
      print("Fehler beim Abrufen der Benutzer-ID: $e");
      return '';
    }
  }

  // Chat-Funktionen
  @override
  Future<void> createChat(Message message, String receiverPhoneNumber) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    String userPhoneNumber =
        await getUserPhoneNumber(); // Methode zum Abrufen der Telefonnummer des Benutzers
    final chatRef = firestore.collection("chats").doc();

    await chatRef.set({
      "participants": [userPhoneNumber, receiverPhoneNumber],
      "created_at": DateTime.now().toIso8601String(),
    });

    await chatRef.collection("messages").add({
      "text": message.text,
      "isSent": message.isSent,
      "timestamp": message.timestamp.toIso8601String(),
      "isRead": message.isRead,
      "sender": userId,
    });
  }

  @override
  Future<void> newGroupChat(List<Message> messages) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    final chatRef =
        firestore.collection("users").doc(userId).collection("chats").doc();

    for (var message in messages) {
      await chatRef.collection("messages").add({
        "text": message.text,
        "isSent": message.isSent,
        "timestamp": message.timestamp.toIso8601String(),
        "isRead": message.isRead,
      });
    }
  }

  @override
  Future<List<Chat>> getAllChats() async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    final snapshot = await firestore
        .collection("chats")
        .where("participants", arrayContains: userId)
        .get();

    List<Chat> chats = [];
    for (var doc in snapshot.docs) {
      final messagesSnapshot = await doc.reference.collection("messages").get();
      List<Message> messages = messagesSnapshot.docs.map((messageDoc) {
        return Message(
          messageDoc["text"],
          messageDoc["isSent"],
          DateTime.parse(messageDoc["timestamp"]),
          senderId: messageDoc["senderId"],
          contactName: messageDoc["contactName"],
          isRead: messageDoc["isRead"],
        );
      }).toList();
      chats.add(Chat(messages));
    }

    return chats;
  }

  @override
  Future<void> addToChats(Contact contact) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();

    await firestore
        .collection("users")
        .doc(userId)
        .collection("chat_contacts")
        .doc(contact.phoneNumber)
        .set({
      "contact_id": contact.phoneNumber,
      "added_at": DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removeFromChats(Contact contact) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();

    await firestore
        .collection("users")
        .doc(userId)
        .collection("chat_contacts")
        .doc(contact.phoneNumber)
        .delete();
  }

  @override
  Future<List<Contact>> getChatContacts() async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();

    // Hole zuerst die Chat-Kontakt-IDs
    final chatContactsSnapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("chat_contacts")
        .orderBy("added_at", descending: true)
        .get();

    // Hole dann die vollständigen Kontaktdaten
    List<Contact> chatContacts = [];
    for (var doc in chatContactsSnapshot.docs) {
      final contactId = doc["contact_id"];
      final contactSnapshot = await firestore
          .collection("users")
          .doc(userId)
          .collection("contacts")
          .where("phoneNumber", isEqualTo: contactId)
          .get();

      if (contactSnapshot.docs.isNotEmpty) {
        final contactData = contactSnapshot.docs.first;
        chatContacts.add(Contact(
          firstName: contactData["firstName"],
          lastName: contactData["lastName"],
          email: contactData["email"],
          phoneNumber: contactData["phoneNumber"],
          image: contactData["image"],
        ));
      }
    }

    return chatContacts;
  }

  // Nachrichten-Funktionen
  final List<Message> _messages = [];

  @override
  Future<void> sendMessage(Message message, String chatId) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    final chatRef = firestore
        .collection("chats")
        .doc(chatId); // Use the correct chat reference

    await chatRef.collection("messages").add({
      "text": message.text,
      "isSent": message.isSent,
      "timestamp": message.timestamp.toIso8601String(),
      "isRead": message.isRead,
      "sender": userId,
    });
  }

  @override
  Future<void> deleteMessage(Message message) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    final snapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("messages")
        .where("timestamp", isEqualTo: message.timestamp.toIso8601String())
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<void> updateMessage(
      Message message, String newContent, String newTimeStamp) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    final snapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("messages")
        .where("timestamp", isEqualTo: message.timestamp.toIso8601String())
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({
        "text": newContent,
        "timestamp": newTimeStamp,
      });
    }
  }

  @override
  Future<List<Message>> getAllMessages() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.unmodifiable(_messages);
  }

  // Kontakt-Funktionen
  @override
  Future<void> addContact(String firstName, String lastName, String email,
      String phoneNumber, String image) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    await firestore.collection("users").doc(userId).collection("contacts").add({
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phoneNumber": phoneNumber,
      "image": image,
    });
  }

  @override
  Future<void> deleteContact(Contact contact) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    final snapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("contacts")
        .where("phoneNumber", isEqualTo: contact.phoneNumber)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<void> updateContact(Contact contact, String firstName, String lastName,
      String email, String phoneNumber, String image) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    final snapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("contacts")
        .where("phoneNumber", isEqualTo: contact.phoneNumber)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phoneNumber": phoneNumber,
        "image": image,
      });
    }
  }

  @override
  Future<List<Contact>> getContactList() async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    final snapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("contacts")
        .get();
    return snapshot.docs
        .map((doc) => Contact(
              firstName: doc["firstName"],
              lastName: doc["lastName"],
              email: doc["email"],
              phoneNumber: doc["phoneNumber"],
              image: doc["image"],
            ))
        .toList();
  }

  @override
  Future<void> saveContactList(List<Contact> contacts) async {
    final firestore = FirebaseFirestore.instance;
    String userId = await getUserId();
    final batch = firestore.batch();

    for (var contact in contacts) {
      final docRef = firestore
          .collection("users")
          .doc(userId)
          .collection("contacts")
          .doc(contact.firstName);

      batch.set(docRef, {
        "name": contact.firstName,
        "email": contact.email,
        "phoneNumber": contact.phoneNumber,
        "image": contact.image,
      });
    }

    await batch.commit();
    // Muss noch implementiert werden
  }

  @override
  Future<Contact> getContact(Contact contact) async {
    return contact;
  }

  @override
  Future<void> saveMessage(Message message) async {
    // Muss noch implementiert werden
    return;
  }
}

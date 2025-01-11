import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:globe_trans_app/features/adcontact_feature/presentation/class.contact.dart';
import 'package:globe_trans_app/features/chat_feature/presentation/chat_screen.dart';
import 'package:globe_trans_app/features/shared/database_repository.dart';

class FirebaseDatabaseRepository implements DatabaseRepository {
  @override
  void notifyListeners() {
    // noch nicht implementiert
  }
  // Kontakt hinzufügen
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

  @override
  Future<void> createChat(Message message, String receiver) async {
    // Muss noch implementiert werden
  }

  // Kontakt löschen
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
  Future<void> deleteMessage(Message message) async {
    // Muss noch implementiert werden
  }

  @override
  Future<List<Chat>> getAllChats() async {
    // Muss noch implementiert werden
    throw UnimplementedError();
  }

  final List<Message> _messages = [];

  // Rufe alle Nachrichten ab
  @override
  Future<List<Message>> getAllMessages() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.unmodifiable(_messages);
  }

  @override
  Future<Contact> getContact(Contact contact) async {
    return contact;
  }

  // Rufe Kontaktliste ab
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
            image: doc["image"]))
        .toList();
  }

  @override
  Future<void> newGroupChat(List<Message> messages) async {
    // Muss noch implementiert werden
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

  // Rufe Chat-Kontakte ab
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
  Future<void> sendMessage(Message message) async {
    // Muss noch implementiert werden
  }

  @override
  Future<void> updateMessage(
      Message message, String newContent, String newTimeStamp) async {
    // Muss noch implementiert werden
    throw UnimplementedError();
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
}

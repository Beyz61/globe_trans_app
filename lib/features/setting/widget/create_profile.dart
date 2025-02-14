// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globe_trans_app/config/colors.dart';
import 'package:globe_trans_app/features/shared/database_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        DocumentSnapshot userDoc =
            await firestore.collection("users").doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            nameController.text = userDoc["name"] ?? '';
            emailController.text = userDoc["email"] ?? '';
            phoneController.text = userDoc["phoneNumber"] ?? '';
          });
        }
      } else {
        print("Kein authentifizierter Benutzer gefunden.");
      }
    } catch (e) {
      print("Fehler beim Laden des Profils: $e");
    }
  }

  Future<void> saveProfile() async {
    final String name = nameController.text;
    final String email = emailController.text;
    final String phone = phoneController.text;

    await context
        .read<DatabaseRepository>()
        .saveUserProfile(name, email, phone);

    // Speichern der Daten in SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name);
    await prefs.setString("email", email);
    await prefs.setString("phone", phone);

    // Zeigen Sie eine Snackbar an, um den Benutzer zu informieren, dass das Profil gespeichert wurde
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Profil gespeichert",
              style: TextStyle(color: Colors.green))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Profil anlegen"),
          backgroundColor: backgroundColor),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller:
                  nameController, //von Zeile 37 name = nameController.text
              decoration: const InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Colors.green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller:
                  emailController, //von Zeile 39 email = emailController.text
              decoration: const InputDecoration(
                labelText: "E-Mail",
                labelStyle: TextStyle(color: Colors.green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller:
                  phoneController, //von Zeile 41 phone = phoneController.text
              decoration: const InputDecoration(
                labelText: "Telefonnummer",
                labelStyle: TextStyle(color: Colors.green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed:
                    saveProfile, // Von Zeile 35 saveProfile zum Speichern der Daten
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Profil anlegen",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

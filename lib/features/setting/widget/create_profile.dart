// ignore_for_file: use_build_context_synchronously

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
  // mit initState() wird die Methode _loadProfile() aufgerufen, um die Daten aus den SharedPreferences zu laden
  void initState() {
    super.initState();
    _loadProfile();
  }

// _loadProfile() lädt die Daten aus den SharedPreferences und zeigt sie in den Textfeldern an
  Future<void> _loadProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString("name") ?? '';
      emailController.text = prefs.getString("email") ?? '';
      phoneController.text = prefs.getString("phone") ?? '';
    });
  }

// saveProfile() speichert die Daten in den SharedPreferences
  Future<void> saveProfile() async {
    final String name =
        nameController.text; // zum Speichern des Namens vom Textfeld
    final String email =
        emailController.text; // zum Speichern der E-Mail vom Textfeld
    final String phone =
        phoneController.text; // zum Speichern der Telefonnummer vom Textfeld

    await context.read<DatabaseRepository>().saveUserPhoneNumber(phone);

    // Speichern der Daten in SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name); // Speichern des Namens
    await prefs.setString("email", email); // Speichern der E-Mail
    await prefs.setString("phone", phone); // Speichern der Telefonnummer

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

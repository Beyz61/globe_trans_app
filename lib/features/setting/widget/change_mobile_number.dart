// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:globe_trans_app/config/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeMobileNumberScreen extends StatefulWidget {
  const ChangeMobileNumberScreen({super.key});

  @override
  _ChangeMobileNumberScreenState createState() =>
      _ChangeMobileNumberScreenState();
}

class _ChangeMobileNumberScreenState extends State<ChangeMobileNumberScreen> {
  final TextEditingController mobileNumberController = TextEditingController();

  @override
  // mit initState() wird die Methode _loadNumber() aufgerufen, um die Daten aus den SharedPreferences zu laden
  void initState() {
    super.initState();
    _loadNumber();
  }

// _loadProfile() lädt die Daten aus den SharedPreferences und zeigt sie in den Textfeldern an
  Future<void> _loadNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mobileNumberController.text = prefs.getString("number") ?? '';
    });
  }

// saveNumber() speichert die Daten in den SharedPreferences
  Future<void> saveNumber() async {
    final String number = mobileNumberController
        .text; // zum Speichern des Mobilnummer vom Textfeld

    // Speichern der Daten in SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("number", number); // Speichern des Mobilnummers

    // Zeigen Sie eine Snackbar an, um den Benutzer zu informieren, dass das MobilNummer gespeichert wurde
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Mobilnummer gespeichert",
              style: TextStyle(color: Colors.green))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Mobilenummer ändern"),
          backgroundColor: backgroundColor),
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: mobileNumberController,
              decoration: const InputDecoration(
                labelText: "Neue Mobilnummer",
                labelStyle: TextStyle(color: Colors.green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  saveNumber, // Von Zeile 35 saveProfile zum Speichern der Daten
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Mobilnummer ändern",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

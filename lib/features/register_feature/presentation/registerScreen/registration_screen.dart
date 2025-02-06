// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:globe_trans_app/config/colors.dart';
import 'package:globe_trans_app/features/contact_overview_feature/presentation/contact_overview.dart';
import 'package:globe_trans_app/features/register_feature/presentation/verificationScreen/verification_screen.dart';
import 'package:globe_trans_app/features/register_feature/repository/country_class.dart';
import 'package:globe_trans_app/features/register_feature/widgets/country_select.dart';
import 'package:globe_trans_app/features/register_feature/widgets/register_button.dart';
import 'package:globe_trans_app/features/shared/auth_repository.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String selectedCountry = "Germany"; // Standardland Deutschland
  String? selectedCountryCode; //Landesvorwahl
  bool syncContacts = false; // Schalter für Kontakte synchronisieren

  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCountryCode =
        countryCodes[selectedCountry]; // Standardvorwahl für Deutschland
  }

  void _onCountryChanged(String newCountry) {
    setState(() {
      // Aktualisiere die Anzeige des ausgewählten Landes und die Vorwahl des Landes
      selectedCountry = newCountry;
      selectedCountryCode = countryCodes[newCountry]; // Aktualisiere Vorwahl
    });
  }

  void _startVerification() async {
    // Validiere Telefonnummer
    final phoneNumber = phoneNumberController.text.trim();
    if (phoneNumber.isEmpty || selectedCountryCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Bitte geben Sie eine gültige Telefonnummer ein.")),
      );
      return;
    }

    final fullPhoneNumber = '$selectedCountryCode$phoneNumber';

    print("Code senden an $fullPhoneNumber");

    try {
      // Sende den Verifizierungscode
      context.read<AuthRepository>().sendVerificationCode(fullPhoneNumber);

      // Weiterleitung zur SMS-Code-Eingabeseite
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerificationScreen(
                  phoneNumber: phoneNumber,
                  countryCode: selectedCountryCode ??
                      "+49")) // Route zur Code-Eingabeseite

          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler bei der Verifizierung: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Your Phone",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Bitte wählen Sie Ihre Landesvorwahl und geben Sie Ihre Telefonnummer ein.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            CountrySelect(
              selectedCountry: selectedCountry,
              onCountryChanged: _onCountryChanged,
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(selectedCountryCode ?? "",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() {}),
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        // Eingabeformat für Telefonnummer
                        FilteringTextInputFormatter
                            .digitsOnly, // Nur Zahlen erlaubt
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Your phone number",
                        hintStyle: TextStyle(
                            fontSize: 16,
                            fontFamily: "SFProDisplay",
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sync Contacts", style: TextStyle(fontSize: 16)),
                Switch(
                  value: syncContacts,
                  activeColor: const Color.fromARGB(255, 22, 174, 27),
                  inactiveTrackColor: Colors.white,
                  onChanged: (bool newValue) {
                    setState(() {
                      syncContacts = newValue;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            RegisterButton(
              phoneNumber: phoneNumberController.text,
              countryCode: countryCodes[selectedCountry]!,
              onPressed: _startVerification,
            ),
            TextButton(
              onPressed: () {
                context.read<AuthRepository>().signInWithGoogle();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ContactView(),
                ));
              },
              child: const Text("Register with Google"),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:globe_trans_app/features/adcontact_feature/presentation/class.contact.dart';
import 'package:globe_trans_app/features/adcontact_feature/widgets/input_email_field.dart';
import 'package:globe_trans_app/features/adcontact_feature/widgets/language_dropdown.dart';
import 'package:globe_trans_app/features/adcontact_feature/widgets/text_name_field.dart';
import 'package:globe_trans_app/features/chat_feature/presentation/chat_screen.dart';
import 'package:globe_trans_app/features/shared/database_repository.dart';
import 'package:provider/provider.dart';

import '../../adcontact_feature/repository/country_flag.dart';

class ContactDetailScreen extends StatefulWidget {
  const ContactDetailScreen({super.key, required this.contact});
  final Contact contact;

  @override
  ContactDetailScreenState createState() => ContactDetailScreenState();
}

class ContactDetailScreenState extends State<ContactDetailScreen> {
  String selectedCountryCode = '+49';
  String selectedCountryName = 'Deutschland';
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.contact.firstName;
    _lastNameController.text = widget.contact.lastName;
    _emailController.text = widget.contact.email;

    if (widget.contact.phoneNumber.isNotEmpty) {
      final phoneComponents = widget.contact.phoneNumber.split(' ');
      if (phoneComponents.length > 1) {
        selectedCountryCode = phoneComponents[0];
        _phoneNumberController.text = phoneComponents[1];
        selectedCountryName =
            countryCodes[selectedCountryCode]?['name'] ?? 'Deutschland';
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte geben Sie Vor- und Nachnamen ein'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (_phoneNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte geben Sie eine Telefonnummer ein'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _saveContact() async {
    if (!_validateForm()) return;

    try {
      await context.read<DatabaseRepository>().addContact(
          _firstNameController.text,
          _lastNameController.text,
          _emailController.text,
          "$selectedCountryCode ${_phoneNumberController.text}",
          "image");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kontakt wurde erfolgreich gespeichert'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kontakt löschen'),
          content: Text(
            'Möchtest du ${widget.contact.firstName} ${widget.contact.lastName} wirklich löschen?',
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Löschen',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await context
                    .read<DatabaseRepository>()
                    .deleteContact(widget.contact);
                Navigator.of(context).pop(); // Dialog schließen
                Navigator.of(context).pop(); // Zurück zur Kontaktliste
              },
            ),
          ],
        );
      },
    );
  }

  void _startChat() async {
    await context.read<DatabaseRepository>().addToChats(widget.contact);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          contactName: "${widget.contact.firstName} ${widget.contact.lastName}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 205, 218, 220),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Kontakt Detail",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 205, 218, 220),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteDialog,
          ),
          GestureDetector(
            onTap: _saveContact,
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Center(
                child: Text(
                  "Speichern",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profilbereich
              Container(
                width: double.infinity,
                color: Colors.white.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${widget.contact.firstName}${widget.contact.lastName}',
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Aktionsbuttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.chat,
                          label: 'Chat',
                          onTap: _startChat,
                        ),
                        _buildActionButton(
                          icon: Icons.phone,
                          label: 'Anrufen',
                          onTap: () {
                            // TODO: Implementiere Anruf-Funktion Wer weiss wann das passieren wird
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.videocam,
                          label: 'Video',
                          onTap: () {
                            // TODO: Implementiere Video-Anruf Wer weiss wann das passieren wird
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Formularfelder
              Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                  children: [
                    TextNameField(
                      contact: widget.contact,
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              DropdownButton<String>(
                                value: selectedCountryCode,
                                items: countryCodes.keys.map((String code) {
                                  return DropdownMenuItem<String>(
                                    value: code,
                                    child: Row(
                                      children: [
                                        Text(countryCodes[code]!['flag']!),
                                        const SizedBox(width: 10),
                                        Text(
                                          code,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            fontFamily: "SFProDisplay",
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newCode) {
                                  setState(() {
                                    selectedCountryCode = newCode!;
                                    selectedCountryName =
                                        countryCodes[newCode]!['name']!;
                                  });
                                },
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  controller: _phoneNumberController,
                                  decoration: const InputDecoration(
                                    hintText: "Telefonnummer",
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "SFProDisplay",
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    InputEmailField(
                      text: "E-Mail",
                      controller: _emailController,
                    ),
                    const SizedBox(height: 30),
                    const LanguageDropdown(text: "Ausgangssprache"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:globe_trans_app/features/register_feature/widgets/verify_button.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen(
      {super.key, required this.phoneNumber, required this.countryCode});

  final String phoneNumber;
  final String countryCode;

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController phoneNumbercontroller = TextEditingController();

  final TextEditingController sms1 = TextEditingController();
  final TextEditingController sms2 = TextEditingController();
  final TextEditingController sms3 = TextEditingController();
  final TextEditingController sms4 = TextEditingController();
  final TextEditingController sms5 = TextEditingController();
  final TextEditingController sms6 = TextEditingController();

  String getFullSmsCode() {
    String smscode =
        sms1.text + sms2.text + sms3.text + sms4.text + sms5.text + sms6.text;
    print("SMS: $smscode");
    return smscode;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    phoneNumbercontroller.dispose();
    super.dispose();
  }

  void _resendVerificationCode(String phoneNumber) {
    /*context.read<DatabaseRepository>();
    (phoneNumber);*/
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification Code Gesendet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 205, 218, 220),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 205, 218, 220),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Enter Code",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Wir haben Ihnen eine SMS mit dem Code an ${widget.countryCode} ${widget.phoneNumber} gesendet.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCodeBox(sms1),
                buildCodeBox(sms2),
                buildCodeBox(sms3),
                buildCodeBox(sms4),
                buildCodeBox(sms5),
                buildCodeBox(sms6),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _resendVerificationCode("phoneNumber");
              },
              child: const Text(
                "Resend Code ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SubmitButtonWidget2.verifyButton(smsCode: getFullSmsCode()),
          ],
        ),
      ),
    );
  }

  Widget buildCodeBox(TextEditingController smsController) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: smsController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }
}

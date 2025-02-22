import 'package:flutter/material.dart';

class InputEmailField extends StatelessWidget {
  const InputEmailField({
    super.key,
    required this.text,
    required this.controller,
  });

  final String text;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 30,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white70,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: text,
              hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontFamily: "SFProDisplay",
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

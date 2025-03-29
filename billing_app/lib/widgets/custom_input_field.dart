import 'package:flutter/material.dart';

class customInput extends StatelessWidget {
  final TextEditingController storeNameController;

  const customInput({required this.storeNameController, required void Function(String value) onSubmitted});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: storeNameController,
      decoration: InputDecoration(
        hintText: 'Enter store name',
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}

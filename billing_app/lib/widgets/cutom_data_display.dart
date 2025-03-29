import 'package:flutter/material.dart';



class _customInput extends StatelessWidget {
  final TextEditingController storeNameController;
  final void Function(String) onSubmitted;

  const _customInput({
    required this.storeNameController,
    required this.onSubmitted,
  });

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
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}

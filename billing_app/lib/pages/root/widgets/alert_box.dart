import 'package:flutter/material.dart';

// Define a function to show the reusable alert box
void AlertBox(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Alert Title"),
        content: const Text("This is a reusable alert box."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              // Add your OK button logic here
            },
          ),
        ],
      );
    },
  );
}
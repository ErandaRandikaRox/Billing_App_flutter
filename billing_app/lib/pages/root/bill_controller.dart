import 'package:billing_app/pages/home/home_page.dart';
import 'package:billing_app/pages/profile/profile.dart';
import 'package:flutter/material.dart';
import 'bill_model.dart';

class BillController {
  final BillModel model;
  final BuildContext context;

  BillController(this.model, this.context);

  void addStore(String value) {
    model.addStore(value);
    if (value.trim().isEmpty) {
      _showSnackBar('Please enter a store name', isError: true);
    }
  }

  void onAddItems() {
    _showSnackBar('Add items button pressed');
  }

  void onSaveBill() {
    _showSnackBar('Bill Saved');
  }

  void navigateToPage(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
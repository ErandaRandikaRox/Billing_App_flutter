import 'package:billing_app/pages/home/home_page.dart';
import 'package:billing_app/pages/profile/profile.dart';
import 'package:billing_app/pages/root/root.dart';
import 'package:flutter/material.dart';
import 'root_model.dart';

class BillController {
  final BillModel model;
  final BuildContext context;

  BillController(this.model, this.context);

  void addStore(String name) {
    model.addStore(name);
  }

  void onAddItems() {
    // Placeholder: Implement logic to add items to goods or returns
    // Example: Show a dialog to input item details and update model
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Items functionality not implemented')),
    );
  }

  void onSaveBill() {
    // Placeholder: Implement logic to save bill data (e.g., to Firestore)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill saved successfully')),
    );
  }

  void navigateToPage(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const MakeRootPage();
        break;
      case 2:
        page = const ProfilePage();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void updateBillDetails({
    String? billAmount,
    String? discount,
    String? tax,
  }) {
    try {
      if (billAmount != null && billAmount.isNotEmpty) {
        model.setBillAmount(double.parse(billAmount));
      }
      if (discount != null && discount.isNotEmpty) {
        model.setDiscount(double.parse(discount));
      }
      if (tax != null && tax.isNotEmpty) {
        model.setTax(double.parse(tax));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid input: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
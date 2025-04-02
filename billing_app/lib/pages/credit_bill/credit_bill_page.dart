import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';

class CreditBillPage extends StatelessWidget {
  const CreditBillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Credit Bill Page",
        actions: [Icon(Icons.credit_card)],
        showDrawerIcons: true,
        showBackButton: false,
      ),
      drawer: CustomDrawer(),
    );
  }
}

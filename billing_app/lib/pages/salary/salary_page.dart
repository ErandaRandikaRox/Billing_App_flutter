import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';

class SalaryPage extends StatelessWidget {
  const SalaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Salary Page",
        actions: [],
        showDrawerIcons: false,
        showBackButton: true,
      ),
      drawer: CustomDrawer(),
    );
  }
}

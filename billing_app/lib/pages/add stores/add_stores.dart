import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';

class AddStores extends StatelessWidget {
  const AddStores({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Add Stores",
        actions: [Icon(Icons.add)],
        showDrawerIcons: true,
        showBackButton: false,
      ),
      drawer: CustomDrawer(),

      body: SingleChildScrollView(),
    );
  }
}

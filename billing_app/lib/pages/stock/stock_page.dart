import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Stock Page",
        actions: [Icon(Icons.shop)],
        showDrawerIcons: true,
      ),
      body: Center(child: Text("Stock Page")),
    );
  }
}

import 'package:flutter/material.dart';

class AlertBoxItemAdd extends StatefulWidget {
  const AlertBoxItemAdd({super.key});

  @override
  State<AlertBoxItemAdd> createState() => _AlertBoxItemAddState();
}

class _AlertBoxItemAddState extends State<AlertBoxItemAdd> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleAddItem() {
    String name = _nameController.text.trim();
    String quantity = _quantityController.text.trim();
    String price = _priceController.text.trim();

    // Example: Print to console
    print('Name: $name, Quantity: $quantity, Price: $price');

    Navigator.pop(context); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Item Name"),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: "Quantity"),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: "Price"),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 20),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _handleAddItem, child: const Text("Add")),
      ],
    );
  }
}

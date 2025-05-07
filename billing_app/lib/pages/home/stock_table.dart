import 'package:billing_app/services/data/goods_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StockTable extends StatelessWidget {
  const StockTable({Key? key}) : super(key: key);

  // Show dialog to edit stock item
  void _showEditDialog(BuildContext context, StockModel stock) {
    final goods = Provider.of<Goods>(context, listen: false);
    final nameController = TextEditingController(text: stock.productName);
    final quantityController = TextEditingController(
      text: stock.quantity.toString(),
    );
    final priceController = TextEditingController(
      text: stock.price.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Stock Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                    ),
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final updatedStock = StockModel(
                    int.parse(quantityController.text),
                    double.parse(priceController.text),
                    productName: nameController.text,
                  );
                  goods.updateStock(stock.productName, updatedStock);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goods = Provider.of<Goods>(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(
            label: Text(
              'Product Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Quantity',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Total Price',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows:
            goods.stocks.map((stock) {
              // Calculate total price for each item
              final totalPrice = stock.quantity * stock.price;

              return DataRow(
                cells: [
                  DataCell(Text(stock.productName)),
                  DataCell(Text(stock.quantity.toString())),
                  DataCell(Text('\$${stock.price.toStringAsFixed(2)}')),
                  DataCell(Text('\$${totalPrice.toStringAsFixed(2)}')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, stock),
                    ),
                  ),
                ],
              );
            }).toList(),
        dataRowHeight: 48,
        headingRowHeight: 56,
        columnSpacing: 24,
      ),
    );
  }
}

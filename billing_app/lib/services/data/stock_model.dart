import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:billing_app/services/data/goods_provider.dart';
import 'package:billing_app/services/data/firebaseStockService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StockTable extends StatelessWidget {
  final String section;

  const StockTable({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<Goods>(
          builder: (context, goods, child) {
            final filteredStocks = goods.stocks
                .where((stock) => stock.section == section)
                .toList();
            return Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                verticalInside: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.5), // Product ID
                1: FlexColumnWidth(2), // Product Name
                2: FlexColumnWidth(1), // Quantity
                3: FlexColumnWidth(1.5), // Price
                4: FixedColumnWidth(60), // Edit
              },
              children: [
                _buildHeaderRow(),
                ...filteredStocks.map(
                  (stock) => _buildDataRow(
                    context,
                    stock.productId,
                    stock.productName,
                    stock.quantity.toString(),
                    'Rs${stock.price.toStringAsFixed(2)}',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      children: const [
        _HeaderCell(text: 'ID'),
        _HeaderCell(text: 'Product'),
        _HeaderCell(text: 'Qty'),
        _HeaderCell(text: 'Price'),
        _HeaderCell(text: 'Edit'),
      ],
    );
  }

  TableRow _buildDataRow(
    BuildContext context,
    String productId,
    String productName,
    String quantity,
    String price,
  ) {
    return TableRow(
      children: [
        _DataCell(text: productId.length > 8 ? '${productId.substring(0, 8)}...' : productId),
        _DataCell(text: productName),
        _DataCell(text: quantity),
        _DataCell(text: price),
        _EditCell(productName: productName, section: section),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  const _DataCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _EditCell extends StatelessWidget {
  final String productName;
  final String section;

  const _EditCell({required this.productName, required this.section});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Center(
        child: IconButton(
          icon: Icon(Icons.edit, color: Colors.blue.shade600),
          onPressed: () {
            AlertBox(context, productName: productName, section: section);
          },
        ),
      ),
    );
  }
}

void AlertBox(BuildContext context, {required String productName, required String section}) {
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final FirebaseStockService _stockService = FirebaseStockService();

  // Prefill fields with current stock data
  final goods = Provider.of<Goods>(context, listen: false);
  final stock = goods.getStockByName(productName);
  if (stock != null) {
    quantityController.text = stock.quantity.toString();
    priceController.text = stock.price.toString();
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit $productName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: section == 'Return Section' ? 'Return Quantity' : 'Quantity',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: section == 'Return Section' ? 'Return Price (Rs)' : 'Price (Rs)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (quantityController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              try {
                int quantity = int.parse(quantityController.text);
                final price = double.parse(priceController.text);

                // Negate quantity for Return Section
                if (section == 'Return Section') {
                  quantity = -quantity;
                  // Validate return quantity doesn't exceed available stock
                  final totalGoods = goods.stocks
                      .where((s) => s.productName == productName && s.section == 'Goods Section')
                      .fold(0, (sum, s) => sum + s.quantity);
                  final totalReturns = goods.stocks
                      .where((s) => s.productName == productName && s.section == 'Return Section')
                      .fold(0, (sum, s) => sum + s.quantity);
                  if (quantity.abs() > totalGoods + totalReturns) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Return quantity exceeds available stock')),
                    );
                    return;
                  }
                }

                final updatedStock = StockModel(
                  quantity,
                  price,
                  productName: productName,
                  section: section,
                );

                // Use FirebaseAuth for username
                final username = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown User';
                // Use storeNameController from root.dart context if available
                final route = Provider.of<TextEditingController>(
                      context,
                      listen: false,
                    ).text.isNotEmpty
                    ? Provider.of<TextEditingController>(context, listen: false).text
                    : 'Unknown Route';
                // Hardcode vehicle or fetch from a reliable source
                const vehicle = 'Unknown Vehicle';
                final currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

                // Save to Firebase
                await _stockService.updateStockForTrip(
                  stock: updatedStock,
                  username: username,
                  date: currentDate,
                  route: route,
                  vehicle: vehicle,
                  section: section,
                );

                // Update local Goods provider
                goods.updateStock(productName, updatedStock);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stock updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
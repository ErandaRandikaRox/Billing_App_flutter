import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:billing_app/services/data/goods_provider.dart';
import 'package:billing_app/services/data/firebaseStockService.dart';
import 'package:billing_app/pages/home/home_model.dart';
import 'package:intl/intl.dart';

// StockTable widget to display stock data from Goods provider
class StockTable extends StatelessWidget {
  const StockTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Consumer<Goods>(
              builder: (context, goods, child) {
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
                    0: FlexColumnWidth(2), // Product column
                    1: FlexColumnWidth(1), // Quantity column
                    2: FlexColumnWidth(2), // Price column
                    3: FixedColumnWidth(60), // Edit column
                  },
                  children: [
                    // Header Row
                    _buildHeaderRow(),
                    // Data Rows from Goods provider
                    ...goods.stocks.map(
                      (stock) => _buildDataRow(
                        context,
                        stock.productName,
                        stock.quantity.toString(),
                        'Rs${stock.price.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await _saveStocksToTrip(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save to Trip'),
            ),
          ],
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
        _HeaderCell(text: 'Product'),
        _HeaderCell(text: 'Quty'),
        _HeaderCell(text: 'Price'),
        _HeaderCell(text: 'Edit'),
      ],
    );
  }

  TableRow _buildDataRow(
    BuildContext context,
    String product,
    String quantity,
    String price,
  ) {
    return TableRow(
      children: [
        _DataCell(text: product),
        _DataCell(text: quantity),
        _DataCell(text: price),
        _EditCell(productName: product),
      ],
    );
  }

  Future<void> _saveStocksToTrip(BuildContext context) async {
    final goods = Provider.of<Goods>(context, listen: false);
    final homeModel = Provider.of<HomeModel>(context, listen: false);
    final FirebaseStockService stockService = FirebaseStockService();

    if (goods.stocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stock items to save')),
      );
      return;
    }

    if (homeModel.username == null ||
        homeModel.selectedRoute == null ||
        homeModel.selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip details incomplete')),
      );
      return;
    }

    try {
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await stockService.saveStockDataForTrip(
        stockItems: goods.stocks,
        route: homeModel.selectedRoute!,
        vehicle: homeModel.selectedVehicle!,
        date: currentDate,
        username: homeModel.username!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stocks saved to trip successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving stocks: $e')),
      );
    }
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
        ),
      ),
    );
  }
}

class _EditCell extends StatelessWidget {
  final String productName;
  const _EditCell({required this.productName});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Center(
        child: IconButton(
          icon: Icon(Icons.edit, color: Colors.blue.shade600),
          onPressed: () {
            AlertBox(context, productName: productName);
          },
        ),
      ),
    );
  }
}

// AlertBox implementation with Firebase upload
void AlertBox(BuildContext context, {required String productName}) {
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
              decoration: const InputDecoration(labelText: 'Quantity (grams)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price (Rs/g)'),
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
                final quantity = int.parse(quantityController.text);
                final price = double.parse(priceController.text);
                final updatedStock = StockModel(
                  quantity,
                  price,
                  productName: productName,

                );

                // Get HomeModel for route, vehicle, and username
                final homeModel = Provider.of<HomeModel>(context, listen: false);
                if (homeModel.username == null ||
                    homeModel.selectedRoute == null ||
                    homeModel.selectedVehicle == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trip details incomplete')),
                  );
                  return;
                }

                // Convert current date to yyyy-MM-dd
                final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

                // Save to Firebase
                await _stockService.updateStockForTrip(
                  stock: updatedStock,
                  username: homeModel.username!,
                  date: currentDate,
                  route: homeModel.selectedRoute!,
                  vehicle: homeModel.selectedVehicle!,
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
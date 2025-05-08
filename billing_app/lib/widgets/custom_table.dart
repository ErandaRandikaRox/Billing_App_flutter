
import 'package:billing_app/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';

class CustomTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const CustomTable({super.key, this.data = const []});

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  late List<Map<String, dynamic>> tableData;

  @override
  void initState() {
    super.initState();
    // Initialize with provided data or default data
    tableData = widget.data.isNotEmpty
        ? List.from(widget.data)
        : [
            {'product': 'Product 1', 'quantity': '2', 'price': 'Rs10.00'},
            {'product': 'Product 2', 'quantity': '5', 'price': 'Rs15.00'},
            {'product': 'Product 3', 'quantity': '1', 'price': 'Rs20.00'},
            {'product': 'Product 1', 'quantity': '2', 'price': 'Rs10.00'},
            {'product': 'Product 2', 'quantity': '5', 'price': 'Rs15.00'},
            {'product': 'Product 3', 'quantity': '1', 'price': 'Rs20.00'},
          ];
  }

  void updateData(String product, String newQuantity, String newPrice) {
    setState(() {
      final index = tableData.indexWhere((item) => item['product'] == product);
      if (index != -1) {
        tableData[index] = {
          'product': product,
          'quantity': newQuantity,
          'price': newPrice,
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            verticalInside: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(2),
            3: FixedColumnWidth(60),
          },
          children: [
            _buildHeaderRow(),
            ...tableData.map((row) => _buildDataRow(
                  row['product'],
                  row['quantity'],
                  row['price'],
                )),
          ],
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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

  TableRow _buildDataRow(String product, String quantity, String price) {
    return TableRow(
      children: [
        _DataCell(text: product),
        _DataCell(text: quantity),
        _DataCell(text: price),
        _EditCell(
          product: product,
          onEdit: (newQuantity, newPrice) {
            updateData(product, newQuantity, newPrice);
          },
        ),
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ),
    );
  }
}

class _EditCell extends StatelessWidget {
  final String product;
  final Function(String, String) onEdit;

  const _EditCell({required this.product, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Center(
        child: IconButton(
          icon: Icon(
            Icons.edit,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            AlertBox(context, product: product, onEdit: onEdit);
          },
        ),
      ),
    );
  }
}

void AlertBox(
  BuildContext context, {
  required String product,
  required Function(String, String) onEdit,
}) {
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit $product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomInput(
              controller: quantityController,
              hintText: 'Quantity',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            CustomInput(
              controller: priceController,
              hintText: 'Price (Rs)',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () {
              if (quantityController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please fill all fields',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }
              try {
                final quantity = quantityController.text;
                final price = 'Rs${double.parse(priceController.text).toStringAsFixed(2)}';
                onEdit(quantity, price);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Updated successfully',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error: $e',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: Text(
              'Save',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      );
    },
  );
}

// Example usage:
class TableShowcaseScreen extends StatelessWidget {
  const TableShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Table Showcase')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomTable(
          data: [
            {'product': 'Product A', 'quantity': '3', 'price': 'Rs12.50'},
            {'product': 'Product B', 'quantity': '7', 'price': 'Rs18.75'},
          ],
        ),
      ),
    );
  }
}
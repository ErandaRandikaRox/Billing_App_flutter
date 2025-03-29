import 'package:billing_app/pages/root/widgets/alert_box.dart';
import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  const CustomTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
            verticalInside: BorderSide(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2), // Product column (Wider)
            1: FlexColumnWidth(1), // Quantity column (Reduced width)
            2: FlexColumnWidth(2), // Price column (Wider)
            3: FixedColumnWidth(60), // Edit column (Reduced width)
          },
          children: [
            // Header Row
            _buildHeaderRow(),
            // Data Rows
            _buildDataRow("Product 1", "2", "Rs10.00"),
            _buildDataRow("Product 2", "5", "Rs15.00"),
            _buildDataRow("Product 3", "1", "Rs20.00"),
            _buildDataRow("Product 1", "2", "Rs10.00"),
            _buildDataRow("Product 2", "5", "Rs15.00"),
            _buildDataRow("Product 3", "1", "Rs20.00"),
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

  TableRow _buildDataRow(String product, String quantity, String price) {
    return TableRow(
      children: [
        _DataCell(text: product),
        _DataCell(text: quantity),
        _DataCell(text: price),
        const _EditCell(),
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
        ),
      ),
    );
  }
}

class _EditCell extends StatelessWidget {
  const _EditCell();

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Center(
        child: IconButton(
          icon: Icon(Icons.edit, color: Colors.blue.shade600),
          onPressed: () {
            AlertBox(context);
          },
        ),
      ),
    );
  }
}

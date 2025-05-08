import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDataDisplay extends StatelessWidget {
  final String storeName;
  final double creditBill;

  const CustomDataDisplay({
    super.key,
    required this.storeName,
    required this.creditBill,
  });

  @override
  Widget build(BuildContext context) {
    // Format credit bill as currency
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs', decimalDigits: 2);
    final formattedCreditBill = currencyFormat.format(creditBill);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Theme.of(context).colorScheme.surface, // White in light, dark gray in dark
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Store Name:",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                Text(
                  storeName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Credit Bill:",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                Text(
                  formattedCreditBill,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Example usage:
class DataDisplayShowcaseScreen extends StatelessWidget {
  const DataDisplayShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Display Showcase')),
      body: Center(
        child: CustomDataDisplay(
          storeName: "Seepali Stores",
          creditBill: 100000.00,
        ),
      ),
    );
  }
}
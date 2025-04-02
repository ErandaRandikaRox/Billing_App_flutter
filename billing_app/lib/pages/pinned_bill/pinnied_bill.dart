import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';

class PinniedBill extends StatelessWidget {
  const PinniedBill({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample bill data - replace with your actual data
    final List<Map<String, dynamic>> pinnedBills = [
      {
        'storeName': 'Coffee Shop',
        'date': '01 Apr 2025',
        'amount': '\$24.50',
        'isPaid': true,
        'items': 3,
        'category': 'Food & Beverage',
        'icon': Icons.coffee,
      },
      {
        'storeName': 'Grocery Store',
        'date': '29 Mar 2025',
        'amount': '\$78.35',
        'isPaid': false,
        'items': 12,
        'category': 'Groceries',
        'icon': Icons.shopping_cart,
      },
      {
        'storeName': 'Electronics Shop',
        'date': '25 Mar 2025',
        'amount': '\$349.99',
        'isPaid': true,
        'items': 1,
        'category': 'Electronics',
        'icon': Icons.devices,
      },
      {
        'storeName': 'Pharmacy',
        'date': '22 Mar 2025',
        'amount': '\$32.75',
        'isPaid': false,
        'items': 4,
        'category': 'Healthcare',
        'icon': Icons.medical_services,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: "Pinned Bills",
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
        showDrawerIcons: false,
        showBackButton: true,
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          // Summary Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bills Summary",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.push_pin, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      context,
                      '4',
                      'Total Bills',
                      Icons.receipt_long,
                    ),
                    _buildSummaryItem(context, '2', 'Paid', Icons.check_circle),
                    _buildSummaryItem(
                      context,
                      '2',
                      'Unpaid',
                      Icons.pending_actions,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "\$485.59",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bills List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Bills",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text("View All")),
              ],
            ),
          ),

          // Bills List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pinnedBills.length,
              itemBuilder: (context, index) {
                final bill = pinnedBills[index];
                return _buildBillCard(context, bill);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBillCard(BuildContext context, Map<String, dynamic> bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    bill['isPaid']
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                bill['icon'],
                color: bill['isPaid'] ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              bill['storeName'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  bill['category'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  bill['date'],
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  bill['amount'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: bill['isPaid'] ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        bill['isPaid']
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bill['isPaid'] ? 'Paid' : 'Unpaid',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: bill['isPaid'] ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${bill['items']} items",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text("View"),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    if (!bill['isPaid'])
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text("Pay"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

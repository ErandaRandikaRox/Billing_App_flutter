import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';

class CreditBillPage extends StatelessWidget {
  const CreditBillPage({super.key});

  Widget _creditBillCard(String title, String amount) {
    return Card(
      color: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: ListTile(
        leading: Icon(Icons.credit_card, color: Colors.deepPurple),
        title: Text(title),
        subtitle: Text("Bill amount: $amount"),
        trailing: Icon(Icons.arrow_forward_ios),

        onTap: () {
          // Handle action if needed
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Credit Bill Page",
        actions: [Icon(Icons.credit_card)],
        showDrawerIcons: false,
        showBackButton: true,
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            _creditBillCard("Bomba kade", "1000"),
            SizedBox(height: 10),
            _creditBillCard("Lakmini Stores", "2000"),
            SizedBox(height: 10),
            _creditBillCard("Rathnayake Shop", "1500"),
            SizedBox(height: 10),
            _creditBillCard("New City Traders", "3000"),
            SizedBox(height: 10),
            _creditBillCard("Kamal Stores", "1800"),
          ],
        ),
      ),
    );
  }
}

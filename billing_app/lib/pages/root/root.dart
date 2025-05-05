import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:billing_app/widgets/custom_button.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:billing_app/widgets/custom_table.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'bill_controller.dart';
import 'bill_model.dart';

class MakeRootPage extends StatelessWidget {
  const MakeRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = BillModel();
    final controller = BillController(model, context);
    final storeNameController = TextEditingController();
    final billAmountController = TextEditingController();
    final discountController = TextEditingController();
    final taxController = TextEditingController();
    final netAmountController = TextEditingController();

    return _MakeRootView(
      model: model,
      controller: controller,
      storeNameController: storeNameController,
      billAmountController: billAmountController,
      discountController: discountController,
      taxController: taxController,
      netAmountController: netAmountController,
    );
  }
}

class _MakeRootView extends StatefulWidget {
  final BillModel model;
  final BillController controller;
  final TextEditingController storeNameController;
  final TextEditingController billAmountController;
  final TextEditingController discountController;
  final TextEditingController taxController;
  final TextEditingController netAmountController;

  const _MakeRootView({
    required this.model,
    required this.controller,
    required this.storeNameController,
    required this.billAmountController,
    required this.discountController,
    required this.taxController,
    required this.netAmountController,
  });

  @override
  _MakeRootViewState createState() => _MakeRootViewState();
}

class _MakeRootViewState extends State<_MakeRootView> {
  int _currentNavIndex = 1;

  @override
  void dispose() {
    widget.storeNameController.dispose();
    widget.billAmountController.dispose();
    widget.discountController.dispose();
    widget.taxController.dispose();
    widget.netAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: 'Make Bill',
        actions: [
          IconButton(
            icon: const Icon(Icons.push_pin_sharp, color: Colors.black),
            onPressed: widget.controller.onSaveBill,
          ),
        ],
        showDrawerIcons: true,
        showBackButton: false,
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStoreNameSection(),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "Goods Section",
                table: CustomTable(),
                onAddPressed: widget.controller.onAddItems,
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "Return Section",
                table: CustomTable(),
                onAddPressed: widget.controller.onAddItems,
              ),
              const SizedBox(height: 20),
              _buildBillDetailsCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStoreNameSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Store name",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: widget.storeNameController,
                decoration: InputDecoration(
                  hintText: "Enter store name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onSubmitted: (value) {
                  widget.controller.addStore(value);
                  setState(() {}); // Update UI to reflect new store
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget table,
    required VoidCallback onAddPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            table,
            const SizedBox(height: 16),
            CustomButton(
              text: "Add Items",
              icon: Icons.add,
              onPressed: onAddPressed,
              isGradient: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Bill Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              label: "Bill Amount",
              controller: widget.billAmountController,
              hintText: "Enter bill amount",
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: "Return",
              controller: widget.discountController,
              hintText: "Return data",
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: "Cash",
              controller: widget.taxController,
              hintText: "Cash",
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: "Credit",
              controller: widget.netAmountController,
              hintText: "Credit",
              isReadOnly: true,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: "Save Bill",
              icon: Icons.save,
              onPressed: widget.controller.onSaveBill,
              isGradient: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isReadOnly = false,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SalomonBottomBar(
            currentIndex: _currentNavIndex,
            onTap: (index) {
              setState(() {
                _currentNavIndex = index;
              });
              widget.controller.navigateToPage(index);
            },
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home_rounded),
                title: const Text("Home"),
                selectedColor: Colors.deepPurple,
                unselectedColor: Colors.grey[400],
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.add_circle_rounded),
                title: const Text("Add Bill"),
                selectedColor: Colors.deepPurple,
                unselectedColor: Colors.grey[400],
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.person_rounded),
                title: const Text("Profile"),
                selectedColor: Colors.deepPurple,
                unselectedColor: Colors.grey[400],
              ),
            ],
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          ),
        ),
      ),
    );
  }
}

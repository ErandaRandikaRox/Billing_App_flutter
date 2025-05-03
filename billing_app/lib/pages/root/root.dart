
import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:billing_app/widgets/custom_button.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:billing_app/widgets/custom_input_field.dart';
import 'package:billing_app/widgets/custom_table.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:billing_app/pages/home/home_page.dart';
import 'package:billing_app/pages/profile/profile.dart';

class MakeRootPage extends StatefulWidget {
  const MakeRootPage({super.key});

  @override
  State<MakeRootPage> createState() => _MakeRootPageState();
}

class _MakeRootPageState extends State<MakeRootPage> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _billAmountController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _netAmountController = TextEditingController();
  int _currentNavIndex = 1; // Track bottom navigation bar index (1 for Add Bill)

  List<String> stores = [];

  @override
  void dispose() {
    _storeNameController.dispose();
    _billAmountController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _netAmountController.dispose();
    super.dispose();
  }

  void _addStore(String value) {
    final storeName = value.trim();
    if (storeName.isNotEmpty) {
      setState(() {
        stores.add(storeName);
        _storeNameController.clear();
      });
    } else {
      _showSnackBar('Please enter a store name', isError: true);
    }
  }

  void _onAdd() {
    _showSnackBar('Add items button pressed');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
            onPressed: () => _showSnackBar('Bill Saved'),
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
              // Store Name Section
              _buildStoreNameSection(),
              const SizedBox(height: 20),
              // Goods Section
              _buildSectionCard(
                title: "Goods Section",
                table: CustomTable(),
                onAddPressed: _onAdd,
              ),
              const SizedBox(height: 20),
              // Return Section
              _buildSectionCard(
                title: "Return Section",
                table: CustomTable(),
                onAddPressed: _onAdd,
              ),
              const SizedBox(height: 20),
              // Bill Details Section
              _buildBillDetailsCard(),
              const SizedBox(height: 16), // Padding to avoid overlap
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                }
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
      ),
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
              child: customInput(
                storeNameController: _storeNameController,
                onSubmitted: _addStore,
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
              controller: _billAmountController,
              hintText: "Enter bill amount",
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: "Return",
              controller: _discountController,
              hintText: "Return data",
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: "Cash",
              controller: _taxController,
              hintText: "Cash",
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: "Creadit",
              controller: _netAmountController,
              hintText: "Creadit",
              isReadOnly: true,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: "Save Bill",
              icon: Icons.save,
              onPressed: () {},
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
}

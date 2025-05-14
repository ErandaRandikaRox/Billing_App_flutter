import 'package:billing_app/pages/add%20stores/add_stores.dart';
import 'package:billing_app/pages/root/widgets/product_search_bar.dart';
import 'package:billing_app/pages/root/widgets/store_search_bar.dart';
import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:billing_app/widgets/custom_button.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:billing_app/widgets/custom_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'root_controller.dart';
import 'root_model.dart';

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
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productQuantityController = TextEditingController();
  final TextEditingController _returnNameController = TextEditingController();
  final TextEditingController _returnPriceController = TextEditingController();
  final TextEditingController _returnQuantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.billAmountController.addListener(() {
      widget.controller.updateBillDetails(
        billAmount: widget.billAmountController.text,
      );
      widget.netAmountController.text = widget.model.netAmount.toStringAsFixed(2);
    });
    widget.discountController.addListener(() {
      widget.controller.updateBillDetails(
        discount: widget.discountController.text,
      );
      widget.netAmountController.text = widget.model.netAmount.toStringAsFixed(2);
    });
    widget.taxController.addListener(() {
      widget.controller.updateBillDetails(tax: widget.taxController.text);
      widget.netAmountController.text = widget.model.netAmount.toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
    widget.storeNameController.dispose();
    widget.billAmountController.dispose();
    widget.discountController.dispose();
    widget.taxController.dispose();
    widget.netAmountController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productQuantityController.dispose();
    _returnNameController.dispose();
    _returnPriceController.dispose();
    _returnQuantityController.dispose();
    super.dispose();
  }

  void _addStore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStores()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final String username = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown User';

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
        showBackButton: true,
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
                table: CustomTable(section: 'Goods Section'),
                onAddPressed: () => widget.controller.onAddItems(
                  productName: _productNameController.text,
                  productPrice: _productPriceController.text,
                  productQuantity: _productQuantityController.text,
                  section: 'Goods Section',
                ),
                isGoodsSection: true,
                currentDate: currentDate,
                username: username,
                section: 'Goods Section',
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: "Return Section",
                table: CustomTable(section: 'Return Section'),
                onAddPressed: () => widget.controller.onAddItems(
                  productName: _returnNameController.text,
                  productPrice: _returnPriceController.text,
                  productQuantity: _returnQuantityController.text,
                  section: 'Return Section',
                ),
                isGoodsSection: false,
                currentDate: currentDate,
                username: username,
                section: 'Return Section',
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Store Name",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            StoreSearchBar(
              controller: widget.storeNameController,
              onStoreSelected: (storeName) {
                widget.controller.addStore(storeName);
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: "Add Store",
                icon: Icons.add,
                onPressed: _addStore,
                isGradient: true,
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
    required bool isGoodsSection,
    required String currentDate,
    required String username,
    required String section,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            ProductSearchBar(
              controller: isGoodsSection ? _productNameController : _returnNameController,
              onProductSelected: (productName) {
                if (isGoodsSection) {
                  _productNameController.text = productName;
                } else {
                  _returnNameController.text = productName;
                }
                setState(() {});
              },
              date: currentDate,
              route: widget.storeNameController.text,
              username: username,
              section: section,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: isGoodsSection ? "Product Price" : "Return Price",
              controller: isGoodsSection ? _productPriceController : _returnPriceController,
              hintText: isGoodsSection ? "Enter product price" : "Enter return price",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: isGoodsSection ? "Product Quantity" : "Return Quantity",
              controller: isGoodsSection ? _productQuantityController : _returnQuantityController,
              hintText: isGoodsSection ? "Enter product quantity" : "Enter return quantity",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: "Add Items",
              icon: Icons.add,
              onPressed: onAddPressed,
              isGradient: true,
            ),
            const SizedBox(height: 16),
            table,
          ],
        ),
      ),
    );
  }

  Widget _buildBillDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: "Discount",
              controller: widget.discountController,
              hintText: "Enter discount",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: "Tax",
              controller: widget.taxController,
              hintText: "Enter tax",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              label: "Net Amount",
              controller: widget.netAmountController,
              hintText: "Net amount",
              isReadOnly: true,
              keyboardType: TextInputType.number,
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
    TextInputType keyboardType = TextInputType.text,
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
            keyboardType: keyboardType,
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
import 'package:billing_app/pages/home/home_controller.dart';
import 'package:billing_app/pages/home/stock_table.dart';
import 'package:billing_app/pages/profile/profile.dart';
import 'package:billing_app/pages/root/root.dart';
import 'package:billing_app/pages/setting/setting.dart';
import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:billing_app/widgets/drop_down.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.init().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Home",
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
        showDrawerIcons: true,
        showBackButton: false,
      ),
      drawer: const CustomDrawer(),
      body: _controller.model.isLoading
          ? _buildLoadingView()
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 20),
                      _buildSelectionSection(),
                      const SizedBox(height: 20),
                      _buildStockSection(),
                      const SizedBox(height: 20),
                      _buildControlButtons(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Processing...',
            style: TextStyle(fontSize: 16, color: Colors.blue.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue.shade800, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Welcome ${_controller.model.username ?? 'Loading...'}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey.shade600,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            if (_controller.model.currentTripId != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Active Trip in Progress',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue.shade800),
                const SizedBox(width: 8),
                Text(
                  'Trip Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: 'Route',
              hint: 'Select a route',
              value: _controller.model.selectedRoute,
              items: _controller.model.routes,
              enabled: _controller.model.currentTripId == null,
              onChanged: (value) {
                setState(() {
                  _controller.onRouteChanged(value);
                });
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: 'Vehicle',
              hint: 'Select a vehicle',
              value: _controller.model.selectedVehicle,
              items: _controller.model.vehicles,
              enabled: _controller.model.currentTripId == null,
              onChanged: (value) {
                setState(() {
                  _controller.onVehicleChanged(value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.blue.shade800),
                const SizedBox(width: 8),
                Text(
                  'Add New Stock',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller.productNameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.shopping_bag),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller.quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller.priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _controller.addStock(context),
                icon: const Icon(Icons.add_circle),
                label: const Text(
                  'Add Stock',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.blue.shade800),
                const SizedBox(width: 8),
                Text(
                  'Current Stock',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const StockTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _controller.model.currentTripId != null
                ? () {
                    _controller.endTrip(context).then((_) {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  }
                : null,
            icon: const Icon(Icons.stop),
            label: const Text('End Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
              disabledBackgroundColor: Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _controller.model.currentTripId == null
                ? () => _controller.startTrip(context)
                : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
              disabledBackgroundColor: Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MakeRootPage(),
                  ),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
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
    );
  }
}
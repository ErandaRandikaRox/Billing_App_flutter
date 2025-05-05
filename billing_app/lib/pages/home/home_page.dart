import 'package:billing_app/pages/home/stock_table.dart';
import 'package:billing_app/pages/home/widgets/drop_down_text.dart';
import 'package:billing_app/pages/home/widgets/get_the_username.dart';
import 'package:billing_app/pages/profile/profile.dart';
import 'package:billing_app/pages/root/root.dart';
import 'package:billing_app/pages/setting/setting.dart';
import 'package:billing_app/services/auth/auth_service.dart';
import 'package:billing_app/services/data/goods.dart';
import 'package:billing_app/services/data/stock.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:billing_app/widgets/drop_down.dart';
import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedRoute;
  String? _selectedVehicle;
  String? _username; // Store the fetched username
  int _currentNavIndex = 0; // Track bottom navigation bar index
  bool _isLoading = false; // Track loading state for async operations
  String? _currentTripId; // Store the current active trip ID

  // Services
  final AuthService _authService = AuthService();
  final FirebaseStockService _stockService = FirebaseStockService();

  // Lists for dropdowns
  final List<String> _routes = [
    "Raththota",
    "Alkaduwa",
    "Kaludawela",
    "Dabulla",
  ];

  final List<String> _vehicles = ["QK 6220", "QU 6220", "325-33234", "542159"];

  @override
  void initState() {
    super.initState();
    // Set current date by default
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    // Fetch username
    _fetchUsername();
    // Check for active trips
    _checkForActiveTrips();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _productNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Fetch username using get_the_username.dart
  Future<void> _fetchUsername() async {
    String username = await fetchUsername(_authService);
    if (mounted) {
      // Check if widget is still mounted
      setState(() {
        _username = username;
      });
    }
  }

  // Check if there are any active trips
  Future<void> _checkForActiveTrips() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final activeTrips = await _stockService.getActiveTrips();
      if (activeTrips.isNotEmpty) {
        setState(() {
          _currentTripId = activeTrips[0]['id'];
          // You can also populate route and vehicle from active trip
          _selectedRoute = activeTrips[0]['route'];
          _selectedVehicle = activeTrips[0]['vehicle'];
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error checking active trips: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add new stock item
  void _addStock() {
    final goods = Provider.of<Goods>(context, listen: false);
    if (_productNameController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _priceController.text.isNotEmpty) {
      final newStock = StockModel(
        int.parse(_quantityController.text),
        double.parse(_priceController.text),
        productName: _productNameController.text,
      );
      goods.addStock(newStock);
      _productNameController.clear();
      _quantityController.clear();
      _priceController.clear();
    }
  }

  // Start a new trip and save stock data to Firebase
  Future<void> _startTrip() async {
    final goods = Provider.of<Goods>(context, listen: false);

    // Validate required fields
    if (_selectedRoute == null || _selectedVehicle == null) {
      _showErrorSnackBar('Please select a route and vehicle');
      return;
    }

    if (goods.stocks.isEmpty) {
      _showErrorSnackBar('Please add at least one stock item');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Save trip data to Firebase
      await _stockService.saveStockDataForTrip(
        stockItems: goods.stocks,
        route: _selectedRoute!,
        vehicle: _selectedVehicle!,
      );

      // On success, navigate to root page
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showSuccessSnackBar('Trip started successfully');

        // Refresh active trips to get the new trip ID
        await _checkForActiveTrips();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MakeRootPage()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to start trip: $e');
    }
  }

  // End an active trip
  Future<void> _endTrip() async {
    if (_currentTripId == null) {
      _showErrorSnackBar('No active trip to end');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await _stockService.completeTrip(_currentTripId!);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentTripId = null;
        });
        _showSuccessSnackBar('Trip completed successfully');

        // Clear current stock list
        final goods = Provider.of<Goods>(context, listen: false);
        goods.clearStocks();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to end trip: $e');
    }
  }

  // Show success message
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
      body:
          _isLoading
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
                        const SizedBox(height: 16), // Padding to avoid overlap
                      ],
                    ),
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
      ),
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
                  'Welcome ${_username ?? 'Loading...'}!',
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            if (_currentTripId != null)
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
              value: _selectedRoute,
              items: _routes,
              enabled: _currentTripId == null, // Disable if trip is active
              onChanged: (value) {
                setState(() {
                  _selectedRoute = value;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: 'Vehicle',
              hint: 'Select a vehicle',
              value: _selectedVehicle,
              items: _vehicles,
              enabled: _currentTripId == null, // Disable if trip is active
              onChanged: (value) {
                setState(() {
                  _selectedVehicle = value;
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
              controller: _productNameController,
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
              controller: _quantityController,
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
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, // Makes button stretch to full width
              child: ElevatedButton.icon(
                onPressed: _addStock,
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
            onPressed: _currentTripId != null ? _endTrip : null,
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
            onPressed: _currentTripId == null ? _startTrip : null,
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
}

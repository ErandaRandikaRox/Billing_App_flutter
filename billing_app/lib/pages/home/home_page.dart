import 'package:billing_app/pages/home/widgets/drop_down_text.dart';
import 'package:billing_app/pages/root/root.dart';
import 'package:billing_app/pages/setting/setting.dart';
import 'package:billing_app/widgets/custom_drawer.dart';
import 'package:billing_app/widgets/drop_down.dart';
import 'package:billing_app/widgets/custom_table.dart';
import 'package:billing_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _dateController = TextEditingController();
  String? _selectedRoute;
  String? _selectedVehicle;

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
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: SafeArea(
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Welcome Charaka!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _dateController,
              labelText: 'Date',
              hintText: 'dd/mm/yyyy',
              prefixIcon: Icons.calendar_today,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(pickedDate);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: 'Route',
              hint: 'Select a route',
              value: _selectedRoute,
              items: _routes,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current Stock',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 16),
            const CustomTable(),
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
            onPressed: () {
              // TODO: Implement End Trip functionality
            },
            icon: const Icon(Icons.stop),
            label: const Text('End Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MakeRootPage()),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

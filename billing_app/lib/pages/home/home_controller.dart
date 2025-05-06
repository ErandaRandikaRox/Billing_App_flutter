import 'package:billing_app/pages/home/home_model.dart';
import 'package:billing_app/pages/home/widgets/get_the_username.dart' as get_the_username;
import 'package:billing_app/pages/root/root.dart';
import 'package:billing_app/services/auth/auth_service.dart';
import 'package:billing_app/services/data/goods.dart';
import 'package:billing_app/services/data/stock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure this import is in your pubspec.yaml

class HomeController {
  final HomeModel model = HomeModel();
  final AuthService authService = AuthService();
  final FirebaseStockService stockService = FirebaseStockService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  final TextEditingController dateController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  HomeController() {
    // Set up date controller with current date
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  void dispose() {
    dateController.dispose();
    productNameController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }

  // Fetch username
  Future<void> fetchUsername() async {
    try {
      String username = await get_the_username.fetchUsername(authService);
      model.setUsername(username);
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  // Check for active trips
  Future<void> checkForActiveTrips() async {
    try {
      model.setLoading(true);
      final activeTrips = await stockService.getActiveTrips();

      if (activeTrips.isNotEmpty) {
        model.setCurrentTripId(activeTrips[0]['id']);
        model.setRoute(activeTrips[0]['route']);
        model.setVehicle(activeTrips[0]['vehicle']);
      }
    } catch (e) {
      print('Error checking active trips: $e');
    } finally {
      model.setLoading(false);
    }
  }

  // Add new stock item
  void addStock(BuildContext context) {
    if (productNameController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      try {
        final newStock = StockModel(
          int.parse(quantityController.text),
          double.parse(priceController.text),
          productName: productNameController.text,
        );

        final goods = Provider.of<Goods>(context, listen: false);
        goods.addStock(newStock);

        // Clear input fields
        productNameController.clear();
        quantityController.clear();
        priceController.clear();
      } catch (e) {
        _showErrorSnackBar(context, 'Invalid input: $e');
      }
    } else {
      _showErrorSnackBar(context, 'Please fill all fields');
    }
  }

  // Start a new trip and store data in database
  Future<void> startTrip(BuildContext context) async {
    final goods = Provider.of<Goods>(context, listen: false);

    if (!model.canStartTrip(goods.stocks)) {
      _showErrorSnackBar(
        context,
        'Please select a route and vehicle, and add at least one stock item',
      );
      return;
    }

    try {
      model.setLoading(true);

      // Create trip document in Firestore
      final tripRef = _firestore.collection('trips').doc();
      final String tripId = tripRef.id;
      
      // Prepare trip data
      final tripData = {
        'id': tripId,
        'route': model.selectedRoute,
        'vehicle': model.selectedVehicle,
        'date': dateController.text,
        'username': model.username,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active', // To indicate this is an active trip
      };
      
      // Create batch write for better transaction handling
      final batch = _firestore.batch();
      
      // Add the trip document
      batch.set(tripRef, tripData);
      
      // Add each stock item as a separate document in a subcollection
      for (var stock in goods.stocks) {
        final stockDoc = tripRef.collection('stocks').doc();
        batch.set(stockDoc, {
          'productName': stock.productName,
          'quantity': stock.quantity,
          'price': stock.price,
          'totalValue': stock.quantity * stock.price,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      
      // Commit the batch write
      await batch.commit();
      
      // Set current trip ID in the model
      model.setCurrentTripId(tripId);
      
      // Show success message
      _showSuccessSnackBar(context, 'Trip started successfully');

      // Navigate to MakeRootPage after successful trip start
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MakeRootPage()),
      );

      return;
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to start trip: $e');
    } finally {
      model.setLoading(false);
    }
  }

  // End an active trip
  Future<void> endTrip(BuildContext context) async {
    if (model.currentTripId == null) {
      _showErrorSnackBar(context, 'No active trip to end');
      return;
    }

    try {
      model.setLoading(true);
      
      // Update the trip document to mark it as completed
      await _firestore.collection('trips').doc(model.currentTripId).update({
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
      });

      model.setCurrentTripId(null);
      _showSuccessSnackBar(context, 'Trip completed successfully');

      // Clear current stock list
      final goods = Provider.of<Goods>(context, listen: false);
      goods.clearStocks();
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to end trip: $e');
    } finally {
      model.setLoading(false);
    }
  }

  // Show success message
  void _showSuccessSnackBar(BuildContext context, String message) {
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
  void _showErrorSnackBar(BuildContext context, String message) {
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

  // Route change handler
  void onRouteChanged(String? value) {
    model.setRoute(value);
  }

  // Vehicle change handler
  void onVehicleChanged(String? value) {
    model.setVehicle(value);
  }

  // Initialize the controller
  Future<void> init() async {
    await fetchUsername();
    await checkForActiveTrips();
  }
}
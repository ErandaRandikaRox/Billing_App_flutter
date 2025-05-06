import 'package:billing_app/services/data/goods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseStockService {
  // Reference to top-level collections
  final CollectionReference _tripsCollection =
      FirebaseFirestore.instance.collection('trips');
  final CollectionReference _stocksCollection =
      FirebaseFirestore.instance.collection('stocks');

  /// Saves stock data for a new trip and returns the trip ID
  Future<String> saveStockDataForTrip({
    required List<StockModel> stockItems,
    required String route,
    required String vehicle,
    required String date,
    required String username,
  }) async {
    try {
      // Validate inputs
      if (stockItems.isEmpty) {
        throw Exception('Stock items list cannot be empty');
      }
      if (route.isEmpty) {
        throw Exception('Route cannot be empty');
      }
      if (vehicle.isEmpty) {
        throw Exception('Vehicle cannot be empty');
      }
      if (date.isEmpty) {
        throw Exception('Date cannot be empty');
      }
      if (username.isEmpty) {
        throw Exception('Username cannot be empty');
      }

      // Validate each stock item
      for (var item in stockItems) {
        if (item.productName.isEmpty) {
          throw Exception('Product name cannot be empty');
        }
        if (item.quantity <= 0) {
          throw Exception('Quantity must be greater than 0');
        }
        if (item.price <= 0) {
          throw Exception('Price must be greater than 0');
        }
      }

      print(
        'DEBUG: Saving trip data: route=$route, vehicle=$vehicle, date=$date, username=$username',
      );
      print('DEBUG: Stock items to save: ${stockItems.length} items');

      // Create a new trip document
      final tripDocRef = await _tripsCollection.add({
        'route': route,
        'vehicle': vehicle,
        'date': date,
        'startTime': FieldValue.serverTimestamp(),
        'endTime': null,
        'status': 'active',
        'createdBy': username,
        'totalItems': stockItems.length,
        'totalValue': stockItems.fold(
          0.0,
          (sum, item) => sum + (item.quantity * item.price),
        ),
      });

      print('DEBUG: Trip document created with ID: ${tripDocRef.id}');

      // Add stock items using batch
      final batch = FirebaseFirestore.instance.batch();
      int batchCount = 0;

      for (var stockItem in stockItems) {
        print('DEBUG: Processing stock item: ${stockItem.productName}');
        final newStockRef = _stocksCollection.doc();
        batch.set(newStockRef, {
          'tripId': tripDocRef.id,
          'productName': stockItem.productName,
          'quantity': stockItem.quantity,
          'price': stockItem.price,
          'totalPrice': stockItem.quantity * stockItem.price,
          'createdAt': FieldValue.serverTimestamp(),
          'sold': 0,
          'remaining': stockItem.quantity,
        });
        batchCount++;

        // Commit batch if nearing Firebase limit (500 operations)
        if (batchCount >= 400) {
          await batch.commit();
          print('DEBUG: Batch committed with $batchCount operations');
          batchCount = 0;
        }
      }

      // Commit any remaining operations
      if (batchCount > 0) {
        await batch.commit();
        print('DEBUG: Final batch committed with $batchCount operations');
      }

      // Verify the save
      final savedTrip = await _tripsCollection.doc(tripDocRef.id).get();
      if (!savedTrip.exists) {
        throw Exception('Trip document was not saved correctly');
      }
      print('DEBUG: Trip data verified in Firestore');

      final savedStocks = await _stocksCollection
          .where('tripId', isEqualTo: tripDocRef.id)
          .get();
      if (savedStocks.docs.length != stockItems.length) {
        throw Exception('Not all stock items were saved correctly');
      }
      print('DEBUG: Stock data verified in Firestore');

      return tripDocRef.id;
    } catch (e, stackTrace) {
      print('ERROR: Failed to save trip data: $e');
      print('ERROR: Stack trace: $stackTrace');
      throw Exception('Failed to save trip data: $e');
    }
  }

  /// Get all active trips
  Future<List<Map<String, dynamic>>> getActiveTrips() async {
    try {
      print('DEBUG: Fetching active trips');
      final QuerySnapshot snapshot =
          await _tripsCollection.where('status', isEqualTo: 'active').get();

      print('DEBUG: Found ${snapshot.docs.length} active trips');
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e, stackTrace) {
      print('ERROR: Error fetching active trips: $e');
      print('ERROR: Stack trace: $stackTrace');
      throw Exception('Failed to fetch active trips: $e');
    }
  }

  /// Complete a trip by updating its status and end time
  Future<void> completeTrip(String tripId) async {
    try {
      print('DEBUG: Completing trip: $tripId');
      await _tripsCollection.doc(tripId).update({
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
      });
      print('DEBUG: Trip $tripId completed successfully');
    } catch (e, stackTrace) {
      print('ERROR: Error completing trip: $e');
      print('ERROR: Stack trace: $stackTrace');
      throw Exception('Failed to complete trip: $e');
    }
  }

  /// Get all stock items for a specific trip
  Future<List<Map<String, dynamic>>> getStockItemsForTrip(String tripId) async {
    try {
      print('DEBUG: Fetching stock items for trip: $tripId');
      final QuerySnapshot snapshot =
          await _stocksCollection.where('tripId', isEqualTo: tripId).get();

      print('DEBUG: Found ${snapshot.docs.length} stock items');
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e, stackTrace) {
      print('ERROR: Error fetching stock items: $e');
      print('ERROR: Stack trace: $stackTrace');
      throw Exception('Failed to fetch stock items: $e');
    }
  }

  /// Update sold quantity for a stock item
  Future<void> updateStockSoldQuantity({
    required String stockId,
    required int soldQuantity,
  }) async {
    try {
      print('DEBUG: Updating stock: $stockId, sold: $soldQuantity');
      final stockDoc = await _stocksCollection.doc(stockId).get();
      if (!stockDoc.exists) {
        throw Exception('Stock item not found');
      }
      final stockData = stockDoc.data() as Map<String, dynamic>;

      final int currentQuantity = stockData['quantity'] ?? 0;
      final int newSold = soldQuantity;
      final int newRemaining = currentQuantity - newSold;

      if (newRemaining < 0) {
        throw Exception('Cannot sell more than available quantity');
      }

      await _stocksCollection.doc(stockId).update({
        'sold': newSold,
        'remaining': newRemaining,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('DEBUG: Stock $stockId updated: sold=$newSold, remaining=$newRemaining');
    } catch (e, stackTrace) {
      print('ERROR: Error updating stock sold quantity: $e');
      print('ERROR: Stack trace: $stackTrace');
      throw Exception('Failed to update stock: $e');
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billing_app/services/data/goods_provider.dart';

class FirebaseStockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save stock data for a new trip
  Future<String> saveStockDataForTrip({
    required List<StockModel> stockItems,
    required String route,
    required String vehicle,
    required String date,
    required String username,
  }) async {
    try {
      // Create a new trip document
      final tripRef = _firestore.collection('trips').doc();
      final String tripId = tripRef.id;

      // Prepare trip data
      final tripData = {
        'id': tripId,
        'route': route,
        'vehicle': vehicle,
        'date': date,
        'username': username,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active', // To indicate this is an active trip
      };

      // Create a batch write for atomicity
      final batch = _firestore.batch();

      // Add the main trip document
      batch.set(tripRef, tripData);

      // Add each stock item as a document in a subcollection
      for (var stock in stockItems) {
        final stockDoc = tripRef.collection('stocks').doc();
        batch.set(stockDoc, {
          'productName': stock.productName,
          'quantity': stock.quantity,
          'price': stock.price,
          'totalValue': stock.quantity * stock.price,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Commit the batch
      await batch.commit();

      print('Trip data saved successfully with ID: $tripId');
      return tripId;
    } catch (e) {
      print('Error saving trip data: $e');
      throw Exception('Failed to save trip data: $e');
    }
  }

  // Get active trips for the current user
  Future<List<Map<String, dynamic>>> getActiveTrips() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('trips')
              .where('status', isEqualTo: 'active')
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting active trips: $e');
      return [];
    }
  }

  // Mark a trip as completed
  Future<void> completeTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({
        'status': 'completed',
        'endTime': FieldValue.serverTimestamp(),
      });
      print('Trip marked as completed: $tripId');
    } catch (e) {
      print('Error completing trip: $e');
      throw Exception('Failed to complete trip: $e');
    }
  }

  // Get stock items for a specific trip
  Future<List<StockModel>> getStocksForTrip(String tripId) async {
    try {
      final stocksSnapshot =
          await _firestore
              .collection('trips')
              .doc(tripId)
              .collection('stocks')
              .get();

      return stocksSnapshot.docs.map((doc) {
        final data = doc.data();
        return StockModel(
          data['quantity'],
          data['price'],
          productName: data['productName'],
        );
      }).toList();
    } catch (e) {
      print('Error getting stocks for trip: $e');
      return [];
    }
  }

  // Get trip history
  Future<List<Map<String, dynamic>>> getTripHistory() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('trips')
              .orderBy('timestamp', descending: true)
              .limit(50) // Limit to prevent retrieving too much data
              .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting trip history: $e');
      return [];
    }
  }

  // Get trip details including stocks
  Future<Map<String, dynamic>?> getTripDetails(String tripId) async {
    try {
      final tripDoc = await _firestore.collection('trips').doc(tripId).get();

      if (!tripDoc.exists) {
        return null;
      }

      final tripData = tripDoc.data() as Map<String, dynamic>;

      // Get stocks for this trip
      final stocks = await getStocksForTrip(tripId);

      // Add stocks to trip data
      tripData['stocks'] =
          stocks
              .map(
                (stock) => {
                  'productName': stock.productName,
                  'quantity': stock.quantity,
                  'price': stock.price,
                  'totalValue': stock.quantity * stock.price,
                },
              )
              .toList();

      return tripData;
    } catch (e) {
      print('Error getting trip details: $e');
      return null;
    }
  }

  // Search products in stocks subcollection of trips
  Future<List<Map<String, dynamic>>> searchProducts(
    String query, {
    required String username,
    required String date,
  }) async {
    try {
      // Get trips for the user and date
      final tripsSnapshot =
          await _firestore
              .collection('trips')
              .where('username', isEqualTo: username)
              .where('date', isEqualTo: date)
              .where('status', isEqualTo: 'active')
              .get();

      final productNames = <String>{};
      final results = <Map<String, dynamic>>[];

      // Fetch stocks for each matching trip
      for (var tripDoc in tripsSnapshot.docs) {
        final stocksSnapshot =
            await tripDoc.reference
                .collection('stocks')
                .where('productName', isGreaterThanOrEqualTo: query)
                .where('productName', isLessThanOrEqualTo: '$query\uf8ff')
                .limit(10)
                .get();

        for (var stockDoc in stocksSnapshot.docs) {
          final data = stockDoc.data();
          if (productNames.add(data['productName'])) {
            results.add({'productName': data['productName']});
          }
        }
      }

      return results;
    } catch (e) {
      print('Error searching products: $e');
      throw Exception('Failed to search products: $e');
    }
  }
}

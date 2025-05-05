import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billing_app/services/data/goods.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseStockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save the current stock data when starting a trip
  Future<void> saveStockDataForTrip({
    required List<StockModel> stockItems, 
    required String route, 
    required String vehicle
  }) async {
    try {
      // Get current user ID
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Current date for organizing data
      final DateTime now = DateTime.now();
      final String dateId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final String tripId = now.millisecondsSinceEpoch.toString();

      // Create a new trip document
      await _firestore.collection('users').doc(userId).collection('trips').doc(tripId).set({
        'date': dateId,
        'timestamp': now,
        'route': route,
        'vehicle': vehicle,
        'status': 'active', // Can be 'active' or 'completed'
        'items': stockItems.map((item) => {
          'productName': item.productName,
          'quantity': item.quantity,
          'price': item.price,
          'totalPrice': item.quantity * item.price,
        }).toList(),
      });

      // Also store it in a daily collection for easy retrieval by date
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_records')
          .doc(dateId)
          .collection('trips')
          .doc(tripId)
          .set({
        'timestamp': now,
        'route': route,
        'vehicle': vehicle,
        'status': 'active',
        'items': stockItems.map((item) => {
          'productName': item.productName,
          'quantity': item.quantity,
          'price': item.price,
          'totalPrice': item.quantity * item.price,
        }).toList(),
      });
    } catch (e) {
      throw Exception('Failed to save trip data: $e');
    }
  }

  // Mark a trip as completed
  Future<void> completeTrip(String tripId) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get trip data first
      final tripDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
          .get();

      if (!tripDoc.exists) {
        throw Exception('Trip not found');
      }

      final tripData = tripDoc.data();
      final String dateId = tripData?['date'];

      // Update status in both collections
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
          .update({'status': 'completed'});

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_records')
          .doc(dateId)
          .collection('trips')
          .doc(tripId)
          .update({'status': 'completed'});
    } catch (e) {
      throw Exception('Failed to complete trip: $e');
    }
  }

  // Get all active trips
  Future<List<Map<String, dynamic>>> getActiveTrips() async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .where('status', isEqualTo: 'active')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get active trips: $e');
    }
  }

  // Get trips by date
  Future<List<Map<String, dynamic>>> getTripsByDate(DateTime date) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final String dateId = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_records')
          .doc(dateId)
          .collection('trips')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get trips by date: $e');
    }
  }
}
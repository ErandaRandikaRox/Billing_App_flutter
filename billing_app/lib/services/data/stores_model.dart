import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  // Get the collection of stores
  final CollectionReference stores =
      FirebaseFirestore.instance.collection('Stores');

  // Save store to the database
  Future<void> saveStoreToDatabase(
    String storeName,
    String storeCategory,
    String? storeAddress,
    String? contactNumber,
  ) async {
    try {
      await stores.add({
        
        'date': FieldValue.serverTimestamp(),
        'storeName': storeName,
        'storeCategory': storeCategory,
        'storeAddress': storeAddress ?? '',
        'contactNumber': contactNumber ?? '',
      });
    } catch (e) {
      throw Exception('Error saving store: $e');
    }
  }

  // Fetch recent stores (optional, for recent stores section)
  Future<List<Map<String, dynamic>>> getRecentStores({required int limit}) async {
    try {
      QuerySnapshot query = await stores
          .orderBy('date', descending: true)
          .limit(10)
          .get();
      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include document ID for editing/deleting
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Error fetching stores: $e');
    }
  }

  updateStore(store, String text, param2, String? s, String? t) {}

  deleteStore(String storeId) {}
}
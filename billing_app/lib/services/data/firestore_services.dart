import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  // Get the collection of stores
  final CollectionReference stores = FirebaseFirestore.instance.collection(
    'Stores',
  );

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

  // Fetch recent stores
  Future<List<Map<String, dynamic>>> getRecentStores({
    required int limit,
  }) async {
    try {
      QuerySnapshot query =
          await stores.orderBy('date', descending: true).limit(limit).get();
      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Error fetching stores: $e');
    }
  }

  // Search store names by keyword
  Future<List<Map<String, dynamic>>> searchStores(String keyword) async {
    try {
      if (keyword.isEmpty) return [];
      String searchKey = keyword.toLowerCase();
      QuerySnapshot query =
          await stores
              .orderBy('storeName')
              .startAt([searchKey])
              .endAt([searchKey + '\uf8ff'])
              .limit(10)
              .get();
      return query.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Error searching stores: $e');
    }
  }

  // Update store
  Future<void> updateStore(
    String storeId,
    String storeName,
    String storeCategory,
    String? storeAddress,
    String? contactNumber,
  ) async {
    try {
      await stores.doc(storeId).update({
        'storeName': storeName,
        'storeCategory': storeCategory,
        'storeAddress': storeAddress ?? '',
        'contactNumber': contactNumber ?? '',
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating store: $e');
    }
  }

  // Delete store
  Future<void> deleteStore(String storeId) async {
    try {
      await stores.doc(storeId).delete();
    } catch (e) {
      throw Exception('Error deleting store: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billing_app/services/data/goods_provider.dart'; // Adjust import based on your project structure

class FirebaseStockService {
  final FirebaseFirestore _firestore;

  // Cache for search results
  final Map<String, List<Map<String, dynamic>>> _searchCache = {};
  // TTL for cache in milliseconds (5 minutes)
  final int _cacheTTL = 300000;
  final Map<String, int> _cacheTimestamps = {};

  // Dependency injection for better testability
  FirebaseStockService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Save trip data with stocks and metadata as subcollections
  /// Returns the trip ID if successful
  Future<String> saveStockDataForTrip({
    required List<StockModel> stockItems,
    required String route,
    required String vehicle,
    required String date,
    required String username,
    required String section,
  }) async {
    try {
      // Input validation
      _validateTripInputs(stockItems, route, date, username);

      // Use a transaction for atomicity
      String tripId = await _firestore.runTransaction<String>(
        (transaction) async {
          // Find or create the trip document
          final tripQuery = await _firestore
              .collection('trips')
              .where('username', isEqualTo: username)
              .where('date', isEqualTo: date)
              .where('route', isEqualTo: route)
              .limit(1)
              .get();

          DocumentReference tripDoc;

          if (tripQuery.docs.isEmpty) {
            // Create new trip
            tripDoc = _firestore.collection('trips').doc();
            transaction.set(tripDoc, {
              'username': username,
              'date': date,
              'route': route,
              'vehicle': vehicle,
              'status': 'active',
              'createdAt': FieldValue.serverTimestamp(),
            });
          } else {
            tripDoc = tripQuery.docs.first.reference;
          }

          // Calculate trip totals
          double totalTripValue = 0;
          for (var stock in stockItems) {
            totalTripValue += stock.quantity * (stock.price ?? 0);
          }

          // Save metadata
          final metadataDoc = tripDoc.collection('metadata').doc('summary');
          transaction.set(
            metadataDoc,
            {
              'totalItems': stockItems.length,
              'totalValue': totalTripValue,
              'section': section,
              'lastUpdated': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );

          // Save stock items
          for (var stock in stockItems) {
            final stockDoc = tripDoc.collection('stocks').doc();
            transaction.set(stockDoc, {
              'productName': stock.productName,
              'productNameLowercase': stock.productName.toLowerCase(),
              'quantity': stock.quantity ?? 0,
              'price': stock.price ?? 0.0,
              'totalPrice': (stock.quantity ?? 0) * (stock.price ?? 0),
              'section': section,
              'createdAt': FieldValue.serverTimestamp(),
              'username': username, // Added to support collectionGroup query
            });
          }

          return tripDoc.id;
        },
        timeout: const Duration(seconds: 10),
      );

      // Clear search cache on successful save
      _invalidateSearchCache();

      print(
          'Trip and stock data saved with trip ID: $tripId, total value: ${_calculateTotalValue(stockItems)}');
      return tripId;
    } catch (e) {
      print('Error saving trip and stock data: $e');
      if (e is FirebaseException) {
        throw _handleFirebaseException(e, 'Failed to save trip and stock data');
      }
      throw Exception('Failed to save trip and stock data: $e');
    }
  }

  /// Enhanced search method with caching
  Future<List<Map<String, dynamic>>> searchProductsWithContext(
    String query,
    String date,
    String route,
    String username, {
    String? section,
  }) async {
    // Normalize the query to improve cache hits
    final normalizedQuery = query.toLowerCase().trim();

    // Create a cache key that includes all context parameters
    final cacheKey = '$normalizedQuery|$date|$route|$username|${section ?? ''}';

    // Check cache first
    if (_isValidCacheEntry(cacheKey)) {
      print('Cache hit for search: $cacheKey');
      return _searchCache[cacheKey]!;
    }

    try {
      print(
          'Searching with: username=$username, date=$date, route=$route, query=$normalizedQuery');

      // Track matching products with priority
      final Map<String, Map<String, dynamic>> productDetails = {};

      // Find the trip document
      final tripQuery = await _firestore
          .collection('trips')
          .where('username', isEqualTo: username)
          .where('date', isEqualTo: date)
          .where('route', isEqualTo: route)
          .limit(1)
          .get();

      if (tripQuery.docs.isEmpty) {
        print('No trip found for username: $username, date: $date, route: $route');
        // Fallback: Search across all trips for the username
        print('Falling back to search across all trips for username: $username');
        final recentStocks = await _firestore
            .collectionGroup('stocks')
            .where('username', isEqualTo: username)
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get();

        _processStockResults(productDetails, recentStocks, normalizedQuery, false, 3);
      } else {
        final tripDoc = tripQuery.docs.first;
        final tripId = tripDoc.id;
        print('Found trip with ID: $tripId, data: ${tripDoc.data()}');

        // Priority 1: Stocks for the current trip
        final currentStocks = await _firestore
            .collection('trips')
            .doc(tripId)
            .collection('stocks')
            .get();

        print('Stocks in current trip: ${currentStocks.docs.map((doc) => doc.data()).toList()}');
        _processStockResults(productDetails, currentStocks, normalizedQuery, true, 1);
      }

      // Priority 3: Recent stocks from other trips (limited result set)
      if (productDetails.length < 5) {
        final recentStocks = await _firestore
            .collectionGroup('stocks')
            .where('username', isEqualTo: username)
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get();

        _processStockResults(productDetails, recentStocks, normalizedQuery, false, 3);
      }

      // Sort results by priority
      final results = productDetails.values.toList();
      results.sort((a, b) => (a['priority'] as int).compareTo(b['priority']));

      // Cache the results
      _cacheSearchResults(cacheKey, results);

      print('Final search results: $results');
      return results;
    } catch (e) {
      print('Error searching products with context: $e');
      if (e is FirebaseException) {
        throw _handleFirebaseException(e, 'Failed to search products');
      }
      throw Exception('Failed to search products: $e');
    }
  }

  /// Get stock items for a specific trip with pagination
  Future<Map<String, dynamic>> getStocksForTrip(
    String date,
    String username, {
    String? route,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      // Find the trip first
      Query tripQuery = _firestore
          .collection('trips')
          .where('username', isEqualTo: username)
          .where('date', isEqualTo: date);

      if (route != null) {
        tripQuery = tripQuery.where('route', isEqualTo: route);
      }

      final tripSnapshot = await tripQuery.limit(1).get();

      if (tripSnapshot.docs.isEmpty) {
        return {
          'stocks': <StockModel>[],
          'metadata': null,
          'hasMore': false,
        };
      }

      final tripDoc = tripSnapshot.docs.first;

      // Get trip metadata
      final metadataDoc = await tripDoc.reference
          .collection('metadata')
          .doc('summary')
          .get();

      // Prepare stocks query with pagination
      Query stocksQuery = tripDoc.reference
          .collection('stocks')
          .orderBy('productName');

      if (lastDocument != null) {
        stocksQuery = stocksQuery.startAfterDocument(lastDocument);
      }

      stocksQuery = stocksQuery.limit(limit);

      // Get stocks
      final stocksSnapshot = await stocksQuery.get();

      // Convert to model objects
      final stocks = stocksSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StockModel(
          data['quantity'] as int? ?? 0,
          data['price'] as double? ?? 0.0,
          productName: data['productName'] as String? ?? '',
        );
      }).toList();

      return {
        'stocks': stocks,
        'metadata': metadataDoc.exists ? metadataDoc.data() : null,
        'hasMore': stocksSnapshot.docs.length == limit,
        'lastDocument': stocksSnapshot.docs.isNotEmpty ? stocksSnapshot.docs.last : null,
      };
    } catch (e) {
      print('Error getting stocks for trip: $e');
      if (e is FirebaseException) {
        // Log but don't throw - return empty results instead
        print('Firebase error: ${e.code} - ${e.message}');
        return {
          'stocks': <StockModel>[],
          'metadata': null,
          'hasMore': false,
        };
      }
      return {
        'stocks': <StockModel>[],
        'metadata': null,
        'hasMore': false,
      };
    }
  }

  /// Update or add a single stock item with optimistic updates
  Future<void> updateStockForTrip({
    required StockModel stock,
    required String username,
    required String date,
    required String route,
    required String vehicle,
    required String section,
  }) async {
    try {
      // Validate inputs
      if (stock.productName.isEmpty) {
        throw ArgumentError('Product name cannot be empty');
      }

      // Find the trip document
      final tripQuery = await _firestore
          .collection('trips')
          .where('username', isEqualTo: username)
          .where('date', isEqualTo: date)
          .where('route', isEqualTo: route)
          .limit(1)
          .get();

      if (tripQuery.docs.isEmpty) {
        throw Exception('No trip found for update');
      }

      final tripDoc = tripQuery.docs.first.reference;

      // Use transaction for atomicity
      await _firestore.runTransaction((transaction) async {
        // Look for existing stock item
        final stockSnapshot = await tripDoc
            .collection('stocks')
            .where('productName', isEqualTo: stock.productName)
            .where('section', isEqualTo: section)
            .limit(1)
            .get();

        // Calculate stock total price
        final totalPrice = (stock.quantity ?? 0) * (stock.price ?? 0);

        final metadataDoc = tripDoc.collection('metadata').doc('summary');

        if (stockSnapshot.docs.isNotEmpty) {
          // Update existing stock item
          final stockDoc = stockSnapshot.docs.first.reference;
          transaction.update(stockDoc, {
            'quantity': stock.quantity ?? 0,
            'price': stock.price ?? 0.0,
            'totalPrice': totalPrice,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          // Recalculate total value (inefficient but wxorks for now)
          final allStocksSnapshot = await tripDoc.collection('stocks').get();
          double newTotal = 0;
          for (var doc in allStocksSnapshot.docs) {
            final stockData = doc.data() as Map<String, dynamic>;
            newTotal += (stockData['quantity'] as int? ?? 0) * (stockData['price'] as double? ?? 0);
          }

          transaction.update(metadataDoc, {
            'totalValue': newTotal,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          // Create new stock item
          final stockDoc = tripDoc.collection('stocks').doc();
          transaction.set(stockDoc, {
            'productName': stock.productName,
            'productNameLowercase': stock.productName.toLowerCase(),
            'quantity': stock.quantity ?? 0,
            'price': stock.price ?? 0.0,
            'totalPrice': totalPrice,
            'section': section,
            'createdAt': FieldValue.serverTimestamp(),
            'username': username, // Added to support collectionGroup query
          });

          // Initialize metadata if it doesn’t exist
          final metadataSnapshot = await transaction.get(metadataDoc);
          if (!metadataSnapshot.exists) {
            transaction.set(metadataDoc, {
              'totalItems': 1,
              'totalValue': totalPrice,
              'section': section,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          } else {
            // Update metadata with new total
            final metadataData = metadataSnapshot.data() as Map<String, dynamic>;
            final currentTotal = (metadataData['totalValue'] as num? ?? 0).toDouble();
            final currentItems = (metadataData['totalItems'] as int? ?? 0);
            transaction.update(metadataDoc, {
              'totalItems': currentItems + 1,
              'totalValue': currentTotal + totalPrice,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        }
      });

      // Clear search cache after updates
      _invalidateSearchCache();

      print('Stock updated successfully for product: ${stock.productName}');
    } catch (e) {
      print('Error updating stock: $e');
      if (e is FirebaseException) {
        throw _handleFirebaseException(e, 'Failed to update stock');
      }
      throw Exception('Failed to update stock: $e');
    }
  }

  // PRIVATE HELPER METHODS

  /// Validate trip inputs and throw ArgumentError if invalid
  void _validateTripInputs(List<StockModel> stockItems, String route, String date, String username) {
    if (stockItems.isEmpty) {
      throw ArgumentError('No stock items provided for the trip');
    }
    if (date.isEmpty) {
      throw ArgumentError('Date is required');
    }
    if (route.isEmpty) {
      throw ArgumentError('Route is required');
    }
    if (username.isEmpty) {
      throw ArgumentError('Username is required');
    }
  }

  /// Calculate total value of stock items
  double _calculateTotalValue(List<StockModel> stockItems) {
    double total = 0;
    for (var stock in stockItems) {
      total += (stock.quantity ?? 0) * (stock.price ?? 0);
    }
    return total;
  }

  /// Process stock query results and add to productDetails map
  void _processStockResults(
    Map<String, Map<String, dynamic>> productDetails,
    QuerySnapshot<Map<String, dynamic>> snapshot,
    String query,
    bool isRecentUse,
    int priority,
  ) {
    for (var stockDoc in snapshot.docs) {
      final data = stockDoc.data();
      final productName = data['productName'] as String;
      final productNameLowercase = data['productNameLowercase'] as String? ?? productName.toLowerCase();

      if (productNameLowercase.contains(query)) {
        if (!productDetails.containsKey(productName) ||
            (productDetails[productName]!['priority'] as int) > priority) {
          productDetails[productName] = {
            'productId': stockDoc.id,
            'productName': productName,
            'price': data['price'] as double? ?? 0.0,
            'quantity': data['quantity'] as int? ?? 0,
            'recentUse': isRecentUse,
            'priority': priority,
            'section': data['section'] as String? ?? '',
            'totalPrice': data['totalPrice'] ?? ((data['quantity'] ?? 0) * (data['price'] ?? 0)),
          };
        }
      }
    }
  }

  /// Cache search results with timestamp
  void _cacheSearchResults(String cacheKey, List<Map<String, dynamic>> results) {
    _searchCache[cacheKey] = results;
    _cacheTimestamps[cacheKey] = DateTime.now().millisecondsSinceEpoch;

    // Clean up old cache entries if cache gets too big
    if (_searchCache.length > 100) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value < b.value ? a : b)
          .key;
      _searchCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }

  /// Check if cache entry is valid (exists and not expired)
  bool _isValidCacheEntry(String cacheKey) {
    if (!_searchCache.containsKey(cacheKey)) return false;

    final timestamp = _cacheTimestamps[cacheKey] ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp < _cacheTTL;
  }

  /// Invalidate entire search cache (call after writes)
  void _invalidateSearchCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
  }

  /// Handle Firebase exceptions with more specific error messages
  Exception _handleFirebaseException(FirebaseException e, String prefix) {
    switch (e.code) {
      case 'permission-denied':
        return Exception('$prefix: Permission denied');
      case 'unavailable':
        return Exception('$prefix: Service temporarily unavailable');
      case 'not-found':
        return Exception('$prefix: Requested data not found');
      case 'already-exists':
        return Exception('$prefix: Item already exists');
      case 'failed-precondition':
        return Exception('$prefix: Operation requires index');
      default:
        return Exception('$prefix: ${e.message}');
    }
  }
}
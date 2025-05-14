import 'dart:async';
import 'package:billing_app/services/data/firebaseStockService.dart';
import 'package:flutter/material.dart';

class ProductSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onProductSelected;
  final String date;
  final String route;
  final String username;
  final String section;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onProductSelected,
    required this.date,
    required this.route,
    required this.username,
    required this.section,
  });

  @override
  _ProductSearchBarState createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  final FirebaseStockService _stockService = FirebaseStockService();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;
  String? _errorMessage;

  void _searchProducts(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
          _errorMessage = null;
        });
        return;
      }
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final results = await _stockService.searchProductsWithContext(
          query,
          widget.date,
          widget.route,
          widget.username,
          section: widget.section,
        );
        print('Search results: $results');
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      } catch (e) {
        print('Search error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to load products: $e';
          if (e.toString().contains('failed-precondition')) {
            _errorMessage = 'Product search is temporarily unavailable. Please try again later.';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Input Field
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: InputBorder.none,
              prefixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                      onPressed: () {
                        widget.controller.clear();
                        setState(() {
                          _suggestions = [];
                          _errorMessage = null;
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
            ),
            onChanged: _searchProducts,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        // Error Message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        // Suggestion List (Facebook-style)
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final product = _suggestions[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple[100],
                    child: Text(
                      product['productName'][0].toUpperCase(),
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                  title: Text(
                    product['productName'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Qty: ${product['quantity'] ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          Text(
                            'Rs${(product['price'] ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        'Total: Rs${(product['totalPrice'] ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (product['section'] != null)
                        Text(
                          'Section: ${product['section']}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                    ],
                  ),
                  onTap: () {
                    widget.controller.text = product['productName'];
                    widget.onProductSelected(product['productName']);
                    setState(() {
                      _suggestions = [];
                      _errorMessage = null;
                    });
                  },
                  trailing: product['recentUse'] == true
                      ? const Icon(
                          Icons.history,
                          color: Colors.deepPurple,
                          size: 18,
                        )
                      : null,
                );
              },
            ),
          ),
        // No Results Message
        if (!_isLoading &&
            _suggestions.isEmpty &&
            widget.controller.text.isNotEmpty &&
            _errorMessage == null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'No products found. Try a different search or add a new product.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
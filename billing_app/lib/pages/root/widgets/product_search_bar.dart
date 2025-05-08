import 'dart:async';
import 'package:billing_app/services/data/firebaseStockService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onProductSelected;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onProductSelected,
  });

  @override
  _ProductSearchBarState createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  final FirebaseStockService _stockService = FirebaseStockService();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  void _searchProducts(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        setState(() {
          _suggestions = [];
        });
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          setState(() {
            _suggestions = [];
            _isLoading = false;
          });
          return;
        }
        final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final results = await _stockService.searchProducts(
          query,
          username: user.uid,
          date: currentDate,
        );
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
          ),
          onChanged: _searchProducts,
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (!_isLoading &&
            _suggestions.isEmpty &&
            widget.controller.text.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Please add the product',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        if (_suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
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
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final product = _suggestions[index];
                return ListTile(
                  title: Text(
                    product['productName'],
                    style: const TextStyle(color: Colors.black87),
                  ),
                  onTap: () {
                    widget.controller.text = product['productName'];
                    widget.onProductSelected(product['productName']);
                    setState(() {
                      _suggestions = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

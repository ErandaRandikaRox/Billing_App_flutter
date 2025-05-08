import 'package:billing_app/services/data/firebaseStockService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onProductSelected;
  final String route;
  final String vehicle;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onProductSelected,
    required this.route,
    required this.vehicle,
  });

  @override
  _ProductSearchBarState createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  final FirebaseStockService _stockService = FirebaseStockService();
  late Future<List<String>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProductNames();
  }

  Future<List<String>> _fetchProductNames() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }
      final userId = user.uid; // Use UID as username for filtering trips

      // Get active trips for the current user, route, and vehicle
      final trips = await _stockService.getActiveTrips();
      final userTrips = trips.where((trip) {
        return trip['username'] == userId &&
            trip['route'] == widget.route &&
            trip['vehicle'] == widget.vehicle;
      }).toList();

      // Fetch product names from stocks in matching trips
      final productNames = <String>{};
      for (var trip in userTrips) {
        final tripId = trip['id'] as String;
        final stocks = await _stockService.getStocksForTrip(tripId);
        for (var stock in stocks) {
          productNames.add(stock.productName);
        }
      }

      return productNames.toList();
    } catch (e) {
      print('Error fetching product names: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Error loading products');
        }
        final products = snapshot.data ?? [];

        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return products.where((String option) {
              return option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          onSelected: (String selection) {
            widget.controller.text = selection;
            widget.onProductSelected(selection);
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            fieldTextEditingController.text = widget.controller.text;
            return TextField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                hintText: 'Search products...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                widget.controller.text = value;
              },
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: Container(
                  width: MediaQuery.of(context).size.width - 32, // Match padding
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          onSelected(option);
                        },
                        child: ListTile(
                          title: Text(option),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
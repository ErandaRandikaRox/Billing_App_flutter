import 'dart:async';
import 'package:billing_app/services/data/firestore_services.dart';
import 'package:flutter/material.dart';


class StoreSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onStoreSelected;

  const StoreSearchBar({
    super.key,
    required this.controller,
    required this.onStoreSelected,
  });

  @override
  _StoreSearchBarState createState() => _StoreSearchBarState();
}

class _StoreSearchBarState extends State<StoreSearchBar> {
  final FirestoreServices _firestoreServices = FirestoreServices();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  void _searchStores(String query) {
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
        final results = await _firestoreServices.searchStores(query);
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
            hintText: "Search store name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
          ),
          onChanged: _searchStores,
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
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
                final store = _suggestions[index];
                return ListTile(
                  title: Text(
                    store['storeName'],
                    style: const TextStyle(color: Colors.black87),
                  ),
                  subtitle: Text(
                    store['storeCategory'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    widget.controller.text = store['storeName'];
                    widget.onStoreSelected(store['storeName']);
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
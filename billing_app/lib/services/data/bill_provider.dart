import 'package:flutter/material.dart';

// StockModel class as provided
class StockModel {
  final String productName;
  final int quantity;
  final double price;

  StockModel(this.quantity, this.price, {required this.productName});
}

// Goods class to manage a list of StockModel items
class Bill with ChangeNotifier {
  // List initialized with 6 provided items and 4 random spice items
  final List<StockModel> _list = [];

  List<StockModel> get stocks => _list;

  void addStock(StockModel stock) {
    _list.add(stock);
    notifyListeners();
  }

  // Update an existing stock item by productName
  void updateStock(String productName, StockModel updatedStock) {
    final index = _list.indexWhere((stock) => stock.productName == productName);
    if (index != -1) {
      _list[index] = updatedStock;
      notifyListeners();
    }
  }

  // Remove a stock item by productName
  void removeStock(String productName) {
    _list.removeWhere((stock) => stock.productName == productName);
    notifyListeners();
  }

  // Get a stock item by productName
  StockModel? getStockByName(String productName) {
    try {
      return _list.firstWhere((stock) => stock.productName == productName);
    } catch (e) {
      return null;
    }
  }

  // Clear all stocks
  void clearStocks() {
    _list.clear();
    notifyListeners();
  }
}

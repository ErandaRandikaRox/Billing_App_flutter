import 'package:flutter/foundation.dart';

class StockModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String section;

  StockModel(
    this.quantity,
    this.price, {
    required this.productName,
    this.productId = '',
    this.section = 'Goods Section',
  });
}

class Goods with ChangeNotifier {
  final List<StockModel> _list = [];

  List<StockModel> get stocks => _list;

  void addStock(StockModel stock) {
    _list.add(stock);
    notifyListeners();
  }

  void updateStock(String productName, StockModel updatedStock) {
    final index = _list.indexWhere(
      (stock) => stock.productName == productName && stock.section == updatedStock.section,
    );
    if (index != -1) {
      _list[index] = updatedStock;
    } else {
      _list.add(updatedStock);
    }
    notifyListeners();
  }

  void removeStock(String productName, {String? section}) {
    _list.removeWhere(
      (stock) => stock.productName == productName && (section == null || stock.section == section),
    );
    notifyListeners();
  }

  StockModel? getStockByName(String productName, {String? section}) {
    try {
      return _list.firstWhere(
        (stock) => stock.productName == productName && (section == null || stock.section == section),
      );
    } catch (e) {
      return null;
    }
  }

  void clearStocks() {
    _list.clear();
    notifyListeners();
  }
}
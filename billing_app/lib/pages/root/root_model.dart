class BillModel {
  String? storeName;
  List<Map<String, dynamic>> goods = [];
  List<Map<String, dynamic>> returns = [];
  double billAmount = 0.0;
  double discount = 0.0;
  double tax = 0.0;
  double netAmount = 0.0;

  void addStore(String name) {
    storeName = name;
  }

  void addGood(Map<String, dynamic> good) {
    goods.add(good);
    _updateBillAmount();
  }

  void addReturn(Map<String, dynamic> returnItem) {
    returns.add(returnItem);
    _updateBillAmount();
  }

  void setBillAmount(double amount) {
    billAmount = amount;
    _updateNetAmount();
  }

  void setDiscount(double amount) {
    discount = amount;
    _updateNetAmount();
  }

  void setTax(double amount) {
    tax = amount;
    _updateNetAmount();
  }

  void _updateBillAmount() {
    billAmount = goods.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));
    billAmount -= returns.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0.0));
    _updateNetAmount();
  }

  void _updateNetAmount() {
    netAmount = billAmount - discount + tax;
  }

  void clear() {
    storeName = null;
    goods.clear();
    returns.clear();
    billAmount = 0.0;
    discount = 0.0;
    tax = 0.0;
    netAmount = 0.0;
  }
}
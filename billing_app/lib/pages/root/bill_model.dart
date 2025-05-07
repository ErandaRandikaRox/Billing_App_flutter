class BillModel {
  List<String> stores = [];
  String? storeName;
  double? billAmount;
  double? discount;
  double? tax;
  double? netAmount;

  void addStore(String storeName) {
    if (storeName.trim().isNotEmpty) {
      stores.add(storeName.trim());
    }
  }

  void updateBillDetails({
    double? billAmount,
    double? discount,
    double? tax,
    double? netAmount,
  }) {
    this.billAmount = billAmount;
    this.discount = discount;
    this.tax = tax;
    this.netAmount = netAmount;
  }
}

import 'package:billing_app/services/data/goods.dart';


class HomeModel {
  String? selectedRoute;
  String? selectedVehicle;
  String? username;
  String? currentTripId;
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();

  // Lists for dropdowns
  final List<String> routes = [
    "Raththota",
    "Alkaduwa",
    "Kaludawela",
    "Dabulla",
  ];

  final List<String> vehicles = ["QK 6220", "QU 6220", "325-33234", "542159"];

  // Methods to update model state
  void setRoute(String? route) {
    selectedRoute = route;
  }

  void setVehicle(String? vehicle) {
    selectedVehicle = vehicle;
  }

  void setUsername(String name) {
    username = name;
  }

  void setLoading(bool loading) {
    isLoading = loading;
  }

  void setCurrentTripId(String? tripId) {
    currentTripId = tripId;
  }

  void setDate(DateTime date) {
    selectedDate = date;
  }

  // Validate trip requirements
  bool canStartTrip(List<StockModel> stocks) {
    return selectedRoute != null &&
        selectedVehicle != null &&
        stocks.isNotEmpty &&
        username != null;
  }
}

// Moved NewStockItem class to top level
class NewStockItem {
  String productName;
  int quantity;
  double price;

  NewStockItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  // Convert to StockModel
  StockModel toStockModel() {
    return StockModel(
      quantity,
      price,
      productName: productName,
    );
  }

  // Validate stock item
  bool isValid() {
    return productName.isNotEmpty && quantity > 0 && price > 0;
  }
}
// lib/models/menu_item.dart
class MenuItem {
  String name;
  String description;
  double price;
  List<String> dietaryRestrictions; // vegan, gluten-free, etc.

  MenuItem({required this.name, required this.description, required this.price, required this.dietaryRestrictions});
}

// lib/models/reservation.dart
class Reservation {
  String customerName;
  int numberOfPeople;
  DateTime dateTime;
  String? notes;

  Reservation({required this.customerName, required this.numberOfPeople, required this.dateTime, this.notes});
}

// lib/models/order.dart
class Order {
  List<MenuItem> items;
  String customerName;
  DateTime dateTime;
  double total;
  String? deliveryAddress;

  Order({required this.items, required this.customerName, required this.dateTime, required this.total, this.deliveryAddress});
}
// lib/models/feedback.dart
class Feedback {
  String customerName;
  String comment;
  int rating;

  Feedback({required this.customerName,required this.comment, required this.rating});
}
// lib/models/stock_item.dart
class StockItem {
  String name;
  int quantity;
  int lowThreshold;

  StockItem({required this.name, required this.quantity, required this.lowThreshold});
}


// lib/models/customer.dart
class Customer{
  String name;
  List<String> allergies;
  List<String> favoriteMeals;

  Customer({required this.name, required this.allergies, required this.favoriteMeals});
}
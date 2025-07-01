// screens/cart_manager.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:agrismart/model/product.dart';

class CartItemData {
  final Product product; // Store the Product object directly
  int quantity;

  CartItemData({required this.product, this.quantity = 1});

  // Add toJson and fromJson for SharedPreferences persistence
  Map<String, dynamic> toJson() {
    return {
      'product': product.toMap(), // Serialize the Product object
      'quantity': quantity,
    };
  }

  factory CartItemData.fromJson(Map<String, dynamic> json) {
    return CartItemData(
      product: Product.fromMap(json['product']), // Reconstruct Product object
      quantity: json['quantity'] as int,
    );
  }
}

class CartManager with ChangeNotifier {
  final List<CartItemData> _items = [];

  List<CartItemData> get items => _items;

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cartItems');
    if (cartJson != null) {
      final List<dynamic> decodedData = jsonDecode(cartJson);
      _items.clear();
      _items.addAll(decodedData.map((itemJson) => CartItemData.fromJson(itemJson)).toList());
      notifyListeners();
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encodedData = _items.map((item) => item.toJson()).toList();
    await prefs.setString('cartItems', jsonEncode(encodedData));
    debugPrint("Cart Saved");
  }

  // Change parameter type to Product
  void addItem(Product product, int quantity) {
    final existingItemIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity += quantity;
    } else {
      _items.add(CartItemData(product: product, quantity: quantity));
    }
    notifyListeners();
    saveCart(); // Save cart whenever items are added
  }

  void removeItem(String productId) { // Now takes product ID (UUID string)
    _items.removeWhere((item) => item.product.id == productId);
    saveCart();
    notifyListeners();
  }

  void updateItemQuantity(String productId, int newQuantity) { // Now takes product ID (UUID string)
    final itemIndex = _items.indexWhere((item) => item.product.id == productId);
    if (itemIndex != -1) {
      _items[itemIndex].quantity = newQuantity;
      notifyListeners();
      saveCart(); // Save cart after quantity update
    }
  }

  double getTotalPrice() {
    double total = 0.0;
    for (var item in _items) {
      // Access price directly from the Product object
      total += item.product.price * item.quantity;
    }
    return total;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    saveCart(); // Save the cleared cart
    debugPrint("Cart cleared!");
  }
}
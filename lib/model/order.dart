// model/order.dart
import 'package:agrismart/model/product.dart'; // Adjust path if needed

/// Represents a single item within an order, including details at the time of purchase.
class OrderItemData {
  final Product product; // The product associated with this order item
  final int quantity; // Quantity of the product ordered
  final double priceAtPurchase; // Price of the product at the time of purchase
  final String productNameAtPurchase; // Name of the product at the time of purchase

  OrderItemData({
    required this.product,
    required this.quantity,
    required this.priceAtPurchase,
    required this.productNameAtPurchase,
  });
}

/// Represents a complete customer order.
class Order {
  final String id; // UUID string
  final String? userId; // ID of the user who placed the order
  final List<OrderItemData> items; // List of items in this order
  final DateTime date; // Order creation date
  final String? status; // e.g., "Processing", "Delivered"
  final double? grandTotalAmount;
  final Map<String, dynamic>? deliveryAddress; // Store as a map

  Order({
    required this.id,
    this.userId,
    required this.items, // Now uses List<OrderItemData>
    required this.date,
    this.status,
    this.grandTotalAmount,
    this.deliveryAddress,
  });
}
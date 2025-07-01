// services/checkout_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:agrismart/screens/cart_manager.dart';
import 'package:agrismart/model/product.dart';

class CheckoutService {
  final supabase = Supabase.instance.client;
  final uuid = Uuid();

  Future<String?> createOrderFromCart(
      List<CartItemData> cartItems,
      String userId,
      Map<String, dynamic> deliveryAddress,
      // Add other parameters if needed: paymentMethod, etc.
      ) async {
    if (cartItems.isEmpty) {
      debugPrint("CheckoutService: Cart is empty.");
      return null;
    }

    final String orderId = uuid.v4(); // Dart-generated UUID for the order

    double grandTotal = 0;
    for (var cartItem in cartItems) {
      // Access price directly from the Product object
      grandTotal += cartItem.product.price * cartItem.quantity;
    }

    try {
      debugPrint("CheckoutService: Creating order ID: $orderId for user: $userId");

      final orderDataToInsert = {
        'id': orderId,
        'user_id': userId,
        'status': 'Processing', // Initial status
        'grand_total_amount': grandTotal,
        'delivery_address': deliveryAddress, // Must be JSONB compatible
      };

      await supabase.from('orders').insert(orderDataToInsert);
      debugPrint("CheckoutService: Order record inserted for ID: $orderId");

      List<Map<String, dynamic>> orderItemsToInsert = [];
      for (final cartItem in cartItems) {
        orderItemsToInsert.add({
          'order_id': orderId, // Link to the Orders table (UUID)
          'product_id': cartItem.product.id,
          'quantity': cartItem.quantity,
          'price_at_purchase': cartItem.product.price,
          'product_name_at_purchase': cartItem.product.name,
        });
      }

      if (orderItemsToInsert.isNotEmpty) {
        await supabase.from('order_items').insert(orderItemsToInsert);
        debugPrint("CheckoutService: Order items inserted for order: $orderId");
      }

      return orderId;
    } on PostgrestException catch (e, s) {
      debugPrint('CheckoutService: Postgrest Error creating order: ${e.message}');
      debugPrint('CheckoutService: Details: ${e.details}'); // Optional: log more details
      debugPrint('CheckoutService: Code: ${e.code}');      // Optional: log more details
      debugPrint('CheckoutService: Stacktrace (from catch block): $s'); // Log the captured stacktrace
      return null;
    } catch (error, stackTrace) {
      debugPrint('CheckoutService: Unexpected Error creating order: $error');
      debugPrint('CheckoutService: Stacktrace: $stackTrace');
      return null;
    }
  }
}
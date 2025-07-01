// screens/cart_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agrismart/screens/cart_manager.dart';
import 'package:agrismart/widgets/cart_item.dart';
import 'package:agrismart/services/checkout_service.dart';
import 'package:agrismart/model/order.dart';
import 'package:agrismart/model/product.dart';
import 'package:agrismart/screens/order_details_page.dart';
import 'package:agrismart/services/stripe_service.dart';
import 'package:agrismart/screens/orders_page.dart';
import 'package:agrismart/screens/home_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isProcessingCheckout = false;
  final StripeService _stripeService = StripeService();

  // Method to handle the checkout process
  Future<void> _proceedToCheckout() async {
    final cartManager = Provider.of<CartManager>(context, listen: false);
    if (cartManager.items.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    setState(() {
      _isProcessingCheckout = true;
    });

    final checkoutService = CheckoutService();
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to proceed.')),
      );
      setState(() {
        _isProcessingCheckout = false;
      });
      return;
    }

    final deliveryAddress = await _getDeliveryAddress(context);
    if (deliveryAddress == null) {
      // User cancelled or address not provided
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Order cancelled: Delivery address not provided.')),
      );
      setState(() {
        _isProcessingCheckout = false;
      });
      return;
    }

    try {
      // 1. Create the order in Supabase
      final String? orderId = await checkoutService.createOrderFromCart(
        cartManager.items,
        currentUser.id,
        deliveryAddress,
      );

      if (orderId != null && mounted) {
        final double grandTotal = cartManager.getTotalPrice();
        if (grandTotal <= 0) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Cannot proceed to payment: Invalid order total.')),
          );
          setState(() {
            _isProcessingCheckout = false;
          });
          return;
        }

        // --- Initiate Stripe Payment ---
        final paymentResult = await _stripeService.makePayment(
          context,
          amount: grandTotal,
          currency: 'SZL',
        );

        if (!mounted) return;

        if (paymentResult == true) {
          // Payment was successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed and paid successfully!')),
          );

          // Clear cart ONLY after successful order creation AND payment
          cartManager.clearCart();
          await cartManager.saveCart();

          // Navigate to OrdersPage (as per previous request, this is fine)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const OrdersPage(
                  userEmail:
                  ''), // Replace with actual user email if needed
            ),
          );
        } else {

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Payment failed or cancelled. Order placed but not paid.')),
          );

        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to place order. Please try again.')),
        );
      }
    } on PostgrestException catch (e, s) {
      debugPrint('Supabase error during checkout process in CartPage: ${e.message}');
      debugPrint('Stacktrace: $s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: ${e.message}')),
        );
      }
    } catch (e, s) {
      debugPrint('Unexpected error during checkout process in CartPage: $e');
      debugPrint('Stacktrace: $s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCheckout = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _getDeliveryAddress(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String? line1, line2, city, town, country;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Enter Delivery Address'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration:
                    const InputDecoration(labelText: 'Address Line 1*'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => line1 = value,
                  ),
                  TextFormField(
                    decoration:
                    const InputDecoration(labelText: 'Address Line 2 (Optional)'),
                    onSaved: (value) => line2 = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'City*'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => city = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Town*'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => town = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Country*'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
                    onSaved: (value) => country = value,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(null); // Return null if cancelled
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.of(dialogContext).pop({
                    'line1': line1,
                    'line2': line2,
                    'city': city,
                    'town': town,
                    'country': country,
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartManager = Provider.of<CartManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        // === START NEW CODE FOR BACK BUTTON ===
        leading: IconButton(
          icon: const Icon(IconlyLight.arrowLeft), // Or Icons.arrow_back
          onPressed: () {

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage(userEmail: '',)),
                  (Route<dynamic> route) => false, // Remove all routes
            );
          },
        ),
        // === END NEW CODE FOR BACK BUTTON ===
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.delete),
            onPressed: () {
              if (cartManager.items.isNotEmpty) {
                _showClearCartConfirmationDialog(context, cartManager);
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cart is already empty.')),
                );
              }
            },
          ),
        ],
      ),
      body: cartManager.items.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconlyLight.bag, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Your cart is empty!',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartManager.items.length,
              itemBuilder: (context, index) {
                final cartItem = cartManager.items[index];
                return CartItem(cartItem: cartItem);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'E${cartManager.getTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                    _isProcessingCheckout ? null : _proceedToCheckout,
                    icon: _isProcessingCheckout
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(IconlyBold.wallet),
                    label: Text(
                      _isProcessingCheckout
                          ? 'Processing...'
                          : 'Proceed to Checkout',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartConfirmationDialog(
      BuildContext context, CartManager cartManager) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text(
              'Are you sure you want to clear your cart? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear', style: TextStyle(color: Colors.white)),
              onPressed: () {
                cartManager.clearCart();
                cartManager.saveCart(); // Persist the cleared cart
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cart cleared successfully!')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
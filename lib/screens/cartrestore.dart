import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:agrismart/screens/cart_manager.dart';
import 'package:agrismart/widgets/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Consumer<CartManager>(
        builder: (context, cartManager, child) {
          // Get the list of cart items from the CartManager
          final List<CartItemData> allCartItems = cartManager.items;

          // Limit the list to a maximum of 10 items for display
          final List<CartItemData> displayedCartItems = allCartItems.take(10).toList();

          // Calculate the total price (still based on all items in CartManager)
          final total = cartManager.getTotalPrice().toStringAsFixed(2);

          if (displayedCartItems.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedCartItems.length, // Use the limited list length
                  itemBuilder: (context, index) {
                    final cartItem = displayedCartItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: CartItem(cartItem: cartItem),
                    );
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total (${allCartItems.length} items)"),
                    Text(
                      "\E$total",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      // Implement your checkout logic here
                      // This should likely process all items in cartManager.items
                    },
                    label: const Text("Proceed to Checkout"),
                    icon: const Icon(IconlyBold.arrowRight),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
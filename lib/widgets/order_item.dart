import 'package:agrismart/model/order.dart'; // Use the updated Order model
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import 'order_product.dart'; // This is now 'widgets/order_product.dart'

class OrderItem extends StatelessWidget {
  const OrderItem({
    super.key,
    required this.order,
    this.visibleProducts = 2,
    this.onTap, // Added onTap callback
  });

  final Order order;
  final int visibleProducts;
  final VoidCallback? onTap; // Callback for when the order item is tapped

  @override
  Widget build(BuildContext context) {
    final productsToShow = order.items.take(visibleProducts).toList();
    final theme = Theme.of(context);

    return GestureDetector( // Make the entire card tappable
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        elevation: 0.1,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "View Order here: #${order.id.substring(0, 8)}", // Shorten ID for display
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "(${order.items.length} Items)",
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "\E${order.grandTotalAmount?.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...List.generate(productsToShow.length, (index) {
                final orderItem = productsToShow[index]; // Get OrderItemData
                return OrderProduct(orderItem: orderItem); // Pass OrderItemData
              }),
              if (order.items.length > visibleProducts) const SizedBox(height: 10),
              if (order.items.length > visibleProducts)
                Center(
                    child: TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          isScrollControlled: true,
                          builder: (context) {
                            return Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.background,
                              ),
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(14),
                                itemCount: order.items.length,
                                itemBuilder: (context, index) {
                                  final orderItem = order.items[index];
                                  return OrderProduct(orderItem: orderItem); // Pass OrderItemData
                                },
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(IconlyBold.arrowRight),
                      label: const Text("View all"),
                    ))
            ],
          ),
        ),
      ),
    );
  }
}
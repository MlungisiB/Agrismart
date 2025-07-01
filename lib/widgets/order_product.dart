import 'package:agrismart/model/order.dart'; // Import OrderItemData
import 'package:flutter/material.dart';

import '../screens/order_details_page.dart';

class OrderProduct extends StatelessWidget {
  const OrderProduct({
    super.key,
    required this.orderItem,
  });

  final OrderItemData orderItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = orderItem.product; // Get the product from the OrderItemData

    return GestureDetector(
      onTap: () {

      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            width: 90,
            margin: const EdgeInsets.only(right: 10, bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                fit: BoxFit.cover,

                image: product.imageUrl.isNotEmpty
                    ? NetworkImage(product.imageUrl) as ImageProvider
                    : const AssetImage('assets/placeholder_image.png'),
              ),
            ),
            child: product.imageUrl.isEmpty
                ? const Center(child: Icon(Icons.broken_image, color: Colors.grey))
                : null,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderItem.productNameAtPurchase,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  product.description ?? 'No description available.',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\E${orderItem.priceAtPurchase.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Qty: ${orderItem.quantity}")
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
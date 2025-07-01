// import 'dart:async'; // Not needed here, can be removed
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:agrismart/screens/cart_manager.dart';
import 'package:agrismart/model/product.dart';

class CartItem extends StatelessWidget {
  // Now expecting CartItemData
  const CartItem({super.key, required this.cartItem});

  final CartItemData cartItem; // Accept a CartItemData object

  @override
  Widget build(BuildContext context) {
    // Access the CartManager
    final cartManager = Provider.of<CartManager>(context, listen: false);

    // **Access data directly from cartItem.product**
    final Product product = cartItem.product; // Get the Product object

    final String itemId = product.id;
    final String itemName = product.name;
    final String itemDescription = product.description ?? 'No description available.';
    final double itemSinglePrice = product.price;
    final String imageUrl = product.imageUrl;

    // Calculate the total price for this item based on quantity
    final double itemTotalPrice = itemSinglePrice * cartItem.quantity;
    final String displayPrice = '\E${itemTotalPrice.toStringAsFixed(2)}';

    return Dismissible(
      key: ValueKey(itemId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red,
        ),
        child: const Icon(
          IconlyLight.delete,
          color: Colors.white,
          size: 25,
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        final bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Remove from Cart"),
              content: Text("Are you sure you want to remove ${itemName} from your cart?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Remove"),
                ),
              ],
            );
          },
        );
        return confirm;
      },
      onDismissed: (direction) {
        cartManager.removeItem(itemId); // Pass the product ID
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${itemName} removed from cart"),
            // Optional undo logic here
          ),
        );
      },
      child: SizedBox(
        height: 125,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          elevation: 0.1,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  height: double.infinity,
                  width: 90,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(imageUrl),
                    )
                        : const DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/placeholder_image.png'),
                    ),
                  ),
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)
                      : null,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        itemDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            displayPrice,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            child: Row(
                              children: [

                                Text(
                                  "${cartItem.quantity}", // Display the actual quantity
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
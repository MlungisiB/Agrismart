import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrismart/screens/cart_manager.dart';
import 'package:provider/provider.dart';
import 'package:agrismart/model/product.dart'; // Import your Product model

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.itemData});
  final dynamic itemData; // Should contain 'phone' directly if not joining

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int quantity = 1;
  double itemBasePrice = 0.0;

  @override
  void initState() {
    super.initState();

    final dynamic price = widget.itemData['sellingprice'];
    if (price != null) {
      if (price is num) {
        itemBasePrice = price.toDouble();
      } else if (price is String) {
        itemBasePrice = double.tryParse(price) ?? 0.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_SZ', symbol: 'E');
    final DateFormat timestampFormatter = DateFormat('yyyy-MM-dd HH:mm');

    final String itemName = widget.itemData['name'] ?? 'No Name';
    final String itemDescription = widget.itemData['description'] ?? 'No description available.';
    final String imageUrl = widget.itemData['image_url'] ?? '';

    final double totalItemPrice = itemBasePrice * quantity;
    final String displayPrice = currencyFormat.format(totalItemPrice);

    String displayTimestamp = 'N/A';
    if (widget.itemData['created_at'] != null) {
      try {
        final DateTime createdAtDateTime = DateTime.parse(widget.itemData['created_at'] as String);
        displayTimestamp = timestampFormatter.format(createdAtDateTime);
      } catch (e) {
        print('DetailPage - Error parsing timestamp: ${widget.itemData['created_at']} - $e');
      }
    }

    final dynamic phoneValue = widget.itemData['phone'];
    String itemPhoneNumber = 'No phone';

    if (phoneValue != null) {
      if (phoneValue is int) {
        itemPhoneNumber = phoneValue.toString();
      } else if (phoneValue is String) {
        itemPhoneNumber = phoneValue;
      }
    }

    return Scaffold(
      backgroundColor: Colors.green,
      body: ListView(
        children: [
          const SizedBox(height: 20),
          header(),
          const SizedBox(height: 20),
          image(imageUrl),
          details(itemName, displayPrice, displayTimestamp, itemPhoneNumber, itemDescription),
        ],
      ),
    );
  }

  Container details(String name, String displayPrice, String displayTimestamp, String itemPhoneNumber, String description) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 34,
                      ),
                    ),
                    Text(
                      displayPrice,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    if (displayTimestamp != 'N/A' || itemPhoneNumber != 'No phone')
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (displayTimestamp != 'N/A')
                              Text(
                                displayTimestamp,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity -= 1;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$quantity',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              quantity += 1;
                            });
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (itemPhoneNumber != 'No phone')
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_outlined, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text(
                            itemPhoneNumber,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'About Item',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
          Material(
            color: Colors.green,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                final cartManager = Provider.of<CartManager>(context, listen: false);
                final Product productToAdd = Product.fromMap(widget.itemData);
                cartManager.addItem(productToAdd, quantity);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${productToAdd.name} added to cart!'), // Use productToAdd.name
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: const Text(
                  'Add to Cart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  SizedBox image(String imageUrl) {
    print('Detail Page Image URL: $imageUrl');

    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.green[300]!,
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
                borderRadius: BorderRadius.circular(250),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(250),
                child:
                imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 250,
                  height: 250,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading detail image: $error');
                    return const Icon(Icons.broken_image, size: 250);
                  },
                )
                    : const Icon(Icons.image_not_supported, size: 250),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Material(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            child: const BackButton(color: Colors.white),
          ),
          const Spacer(),
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const Material(
            /*color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    child: const Icon(Icons.favorite_border, color: Colors.white),
                  ),
                ),*/
          ),
        ],
      ),
    );
  }
}
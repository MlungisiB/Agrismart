// model/product.dart

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String? description;
  final String? category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description,
    this.category,
  });

  // Factory constructor for creating from a map (e.g., from Supabase)
  factory Product.fromMap(Map<String, dynamic> map) {
    double priceValue = 0.0;
    if (map.containsKey('price')) {
      priceValue = (map['price'] as num?)?.toDouble() ?? 0.0;
    } else if (map.containsKey('sellingprice')) {
      priceValue = (map['sellingprice'] as num?)?.toDouble() ?? 0.0;
    }

    return Product(
      id: map['product_id']?.toString() ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed Product',
      price: priceValue,
      imageUrl: map['image_url']?.toString() ?? '',
      description: map['description']?.toString(),
      category: map['product_type']?.toString() ?? map['category']?.toString(),
    );
  }

  // Add this toMap method for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl, // Use image_url for consistency with fromMap
      'description': description,
      'category': category,
    };
  }
}
import 'package:agrismart/screens/cart_page.dart';
import 'package:agrismart/screens/root_app.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:agrismart/screens/detail_screen.dart';
import 'package:agrismart/theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:agrismart/screens/sell_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class HomePage extends StatefulWidget {
  final String userEmail;
  const HomePage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of the different screens

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartPage(),
    const SellPage(),
    const RootApp(),
  ];

  void _changePage(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity! < 0) {
      _changePage(_selectedIndex + 1);
    } else if (details.primaryVelocity! > 0) {
      _changePage(_selectedIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightColorScheme.primary,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: FutureBuilder<TextStyle>(
                future: _loadCustomFont(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return Text(
                      'Agrismart',
                      style: snapshot.data,
                    );
                  } else {
                    // Fallback style
                    return const Text(
                      'Agrismart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                },
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'asset/flag.jpeg',
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: _onHorizontalDrag,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        color: lightColorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
            backgroundColor: lightColorScheme.primary,
            color: Colors.white,
            activeColor: Colors.black,
            tabBackgroundColor: Colors.white70,
            gap: 8,
            padding: const EdgeInsets.all(16),
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              _changePage(index);
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.shopping_cart,
                text: 'Cart',
              ),
              GButton(
                icon: Icons.currency_exchange,
                text: 'Sell Now',
              ),
              GButton(
                icon: Icons.group,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<TextStyle> _loadCustomFont() async {
    try {

      final fontData = await rootBundle.load('fonts/opensans-Bold.ttf');
      final fontLoader = FontLoader('OpenSans-Bold')..addFont(Future.value(fontData));
      await fontLoader.load();
      return const TextStyle(
        fontFamily: 'OpenSans-Bold',
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );
    } catch (e) {
      print('Error loading custom font: $e');
      // Fallback style if font loading fails
      return const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int indexCategory = 0;
  List<dynamic> _items = [];
  bool _isLoadingItems = true;

  final List<String> _categories = [
    'Fruits', 'Vegetables', 'Crops', 'Seeds', 'Animal products', 'Plant products'
  ];

  @override
  void initState() {
    super.initState();
    _fetchItems(indexCategory);
  }

  Future<void> _fetchItems(int categoryIndex) async {
    if (!mounted) return;
    setState(() {
      _isLoadingItems = true;
    });

    final supabase = Supabase.instance.client;
    final selectedCategory = _categories[categoryIndex];

    try {
      final response = await supabase
          .from('products')
          .select('*, user_id, profile:user_id(image_path, name)') // <-- MODIFIED HERE
          .eq('category', selectedCategory)
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _items = response;
        if (_items.isNotEmpty) {
          print('Raw fetched item data example: ${_items.first}');
          // Ensure 'profile' contains 'image_path' AND 'name' in the debug output
        }
      });

    } on PostgrestException catch (error) {
      print('Supabase error fetching items for category $selectedCategory: ${error.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load items: ${error.message}')),
        );
      }
      if (!mounted) return;
      setState(() { _items = []; });
    } catch (e) {
      print('Generic error fetching items from products table for category $selectedCategory: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load items: $e')),
        );
      }
      if (!mounted) return;
      setState(() { _items = []; });
    } finally {
      if (mounted) {
        setState(() { _isLoadingItems = false; });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 20),
        title(),
        const SizedBox(height: 20),
        categories(),
        const SizedBox(height: 20),
        _isLoadingItems
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
            ? Center(child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("No items found in this category.", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ))
            : gridFood(),
      ],
    );
  }

  Widget title() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore the market !',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 27,
            ),
          ),
        ],
      ),
    );
  }

  Widget categories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        itemCount: _categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                indexCategory = index;
              });
              _fetchItems(index);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(
                index == 0 ? 16 : 16,
                0,
                index == _categories.length - 1 ? 16 : 16,
                0,
              ),
              alignment: Alignment.center,
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 22,
                  color: indexCategory == index ? Colors.orange : Colors.green,
                  fontWeight: indexCategory == index ? FontWeight.bold : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget gridFood() {
    const String supabaseStorageBaseUrl = 'https://hqsttrggzulpizedagku.supabase.co/storage/v1/object/public/';
    const String profileImageBucketName = 'prof';

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

    return GridView.builder(
      itemCount: _items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 275,
      ),
      itemBuilder: (context, index) {
        final item = _items[index] as Map<String, dynamic>;

        final String imageUrl = item['image_path'] ?? '';
        final String itemName = item['name'] ?? 'No Name';
        final dynamic itemPrice = item['sellingprice'];
        final String displayPrice = itemPrice != null
            ? NumberFormat.currency(locale: 'en_SZ', symbol: 'E').format(itemPrice is String ? (double.tryParse(itemPrice) ?? 0.0) : (itemPrice as num).toDouble())
            : 'N/A';
        final String itemDescription = item['description'] ?? 'No description available.';

        String displayTimestamp = 'N/A';
        if (item['created_at'] != null) {
          try {
            final DateTime createdAtDateTime = DateTime.parse(item['created_at'] as String);
            displayTimestamp = formatter.format(createdAtDateTime);
          } catch (e) {
            // Error parsing timestamp
          }
        }

        String uploaderProfilePicUrl = '';
        String uploaderName = 'Anonymous'; // Default to Anonymous

        final profileData = item['profile']; // This is now expected to contain both image_path and name
        if (profileData != null && profileData is Map) {
          // Get profile picture URL
          if (profileData['image_path'] != null) {
            final String profilePathFromFile = profileData['image_path'] as String;
            if (profilePathFromFile.isNotEmpty) {
              uploaderProfilePicUrl = '$supabaseStorageBaseUrl$profileImageBucketName/$profilePathFromFile';
            }
          }
          // Get uploader name from profile
          if (profileData['name'] != null) {
            uploaderName = (profileData['name'] as String?)?.trim() ?? 'Anonymous';
            if (uploaderName.isEmpty) uploaderName = 'Anonymous';
          }
        }

        return GestureDetector(
          onTap: () {
            final Map<String, dynamic> itemDataForDetailPage = {
              'name': itemName,
              'sellingprice': itemPrice,
              'image_url': imageUrl,
              'description': itemDescription,
              'uploader_profile_pic_url': uploaderProfilePicUrl,
              'uploader_name': uploaderName,
              'created_at': item['created_at'],
              ...item, // Pass all other item data
            };
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return DetailPage(itemData: itemDataForDetailPage);
            }));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 5),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(120),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(120),
                              ),
                              child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                            );
                          },
                        )
                            : Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(120),
                          ),
                          child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        itemName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                      child: Text(
                        displayPrice,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                      child: Text(
                        displayTimestamp,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 35),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Material(
                    color: Colors.green,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('To Add to cart for $itemName (click image)')),
                        );
                      },
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  right: 45,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (uploaderProfilePicUrl.isNotEmpty)
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: NetworkImage(uploaderProfilePicUrl),
                          onBackgroundImageError: (exception, stackTrace) {
                            // Fallback for profile image error
                          },
                        )
                      else
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey[400],
                          child: const Icon(Icons.person, size: 16, color: Colors.white70),
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          uploaderName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}




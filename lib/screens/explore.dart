import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:agrismart/color.dart';
import 'package:agrismart/utilies/catogories.dart';
import 'package:agrismart/utilies/explorecart.dart';

// Define a data model for your items from Supabase
class ExploreItem {
  final String imageUrl;
  final String name;
  final String subname;
  final String userImageUrl;
  final String username;
  final double rating; // Assuming you might have a rating field

  ExploreItem({
    required this.imageUrl,
    required this.name,
    required this.subname,
    required this.userImageUrl,
    required this.username,
    required this.rating,
  });

  // Factory method to create an ExploreItem from Supabase data
  factory ExploreItem.fromJson(Map<String, dynamic> json) {
    return ExploreItem(
      imageUrl: json['image_url'] as String, // Adjust key names based on your Supabase table
      name: json['name'] as String,
      subname: json['subname'] as String,
      userImageUrl: json['user_image_url'] as String,
      username: json['username'] as String,
      rating: (json['rating'] as num).toDouble(), // Assuming rating is a number
    );
  }
}

class Explore extends StatefulWidget {
  const Explore({super.key});
  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  // List to store the fetched items
  List<ExploreItem> exploreItems = [];
  // Loading state
  bool isLoading = true;
  // Error state
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchExploreItems(); // Fetch data when the widget is initialized
  }

  Future<void> _fetchExploreItems() async {
    try {
      // Access the Supabase client
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('your_table_name')
          .select();

      final List<ExploreItem> fetchedItems = (response as List<dynamic>)
          .map((item) => ExploreItem.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        exploreItems = fetchedItems;
        isLoading = false;
      });

    } catch (e) {
      // Catch any errors that occurred during the Supabase operation
      setState(() {
        error = 'Error fetching data: ${e.toString()}';
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Explore",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                      color: textColor),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: SizedBox(
                        height: 45,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.8,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: inActiveColor,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    "Search",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: inActiveColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                  ? Center(child: Text('Error: $error'))
                  : ListView.builder(

                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exploreItems.length,
                itemBuilder: (context, index) {
                  final item = exploreItems[index];
                  return ExploreCart(
                    image: item.imageUrl,
                    // Pass data from the fetched item
                    name: item.name,
                    subname: item.subname,
                    userimage: item.userImageUrl,
                    // Pass data from the fetched item
                    username: item.username,
                    rating: item.rating, // Pass data from the fetched item
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
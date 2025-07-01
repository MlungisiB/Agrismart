// lib/screens/root_app.dart (or wherever your RootApp.dart is located)

// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

// Import your custom pages and services
import 'package:agrismart/profile/pages/edit_profile.dart';
import 'package:agrismart/screens/orders_page.dart';
import 'package:agrismart/screens/home_page.dart';
import 'package:agrismart/screens/notifications_page.dart';
import 'package:agrismart/screens/about_us_page.dart';

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  String? _profileImageUrl;
  String? _userName; // State variable to hold the user's name
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Renamed for clarity, fetching both image and name
  }

  Future<void> _loadProfileData() async {
    print('--- Start _loadProfileData ---');
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      print('[_loadProfileData] Error: User is not logged in.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final currentUserId = user.id; // Get the user's UUID from Supabase auth
    print('[_loadProfileData] Logged-in user ID: $currentUserId');

    try {
      // Fetch both 'image_path' and 'name' from the 'profile' table
      final response = await Supabase.instance.client
          .from('profile')
          .select('image_path, name') // Ensure these column names are exact in Supabase
          .eq('user_id', currentUserId) // Filter by user_id
          .maybeSingle(); // Use maybeSingle() for robust handling (returns null if no record)

      print('[_loadProfileData] Supabase query executed. Response: $response');

      if (response != null) {
        // Handle profile image URL
        String? imageUrl;
        if (response['image_path'] != null) {
          final String imagePath = response['image_path'] as String;
          imageUrl = Supabase.instance.client.storage
              .from('prof') // Double-check your bucket name 'prof'
              .getPublicUrl(imagePath);
          print('[_loadProfileData] Fetched image URL: $imageUrl');
        } else {
          print('[_loadProfileData] "image_path" is null in Supabase response.');
        }

        // Handle user name
        final String? fetchedName = response['name'] as String?;
        print('[_loadProfileData] Fetched name: $fetchedName');

        setState(() {
          _profileImageUrl = imageUrl;
          _userName = fetchedName;
          _isLoading = false;
        });
      } else {
        print('[_loadProfileData] No profile found for user ID: $currentUserId in Supabase.');
        setState(() {
          _profileImageUrl = null;
          _userName = null; // Set name to null if no profile is found
          _isLoading = false;
        });
      }

    } on PostgrestException catch (e) {
      print('[_loadProfileData] Supabase Postgrest Error: ${e.message}');
      setState(() {
        _profileImageUrl = null;
        _userName = null;
        _isLoading = false;
      });
    } catch (e) {
      print('[_loadProfileData] Unexpected Error: $e');
      setState(() {
        _profileImageUrl = null;
        _userName = null;
        _isLoading = false;
      });
    }
    print('--- End _loadProfileData ---');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text(
          "PROFILE",
          style: TextStyle(
            fontFamily: 'NimbusSanL',
            fontWeight: FontWeight.w700,
            fontSize: 27,
          ),
        ),
        centerTitle: true,
        // --- START: Back icon to HomePage ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Or IconlyLight.arrowLeft
          onPressed: () {
            // This navigates to the HomePage and clears all routes below it
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage(userEmail: '',)),
                  (Route<dynamic> route) => false,
            );
          },
        ),
        // --- END: Back icon to HomePage ---
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView(
        padding: const EdgeInsets.all(10),
        children: [
          // COLUMN THAT WILL CONTAIN THE PROFILE
          Column(
            children: [
              CircleAvatar(
                radius: 100,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!) as ImageProvider // Use NetworkImage for the URL
                    : const AssetImage("asset/user.jpg") as ImageProvider, // Fallback to default asset
              ),
              const SizedBox(height: 10),
              // --- START: Display User Name ---
              Text(
                _userName ?? "User Name", // Display fetched name, or "User Name" as fallback
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // --- END: Display User Name ---
              //const Text("Enter agriculturial field") // You might want to fetch this data dynamically as well
            ],
          ),
          const SizedBox(height: 25),
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  "Complete your profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(1, (index) {
              return Expanded(
                child: Container(
                  height: 7,
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: index == 0 ? Colors.green : Colors.orange,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final card = profileCompletionCards[index];
                return SizedBox(
                  width: 180,
                  child: Card(
                    shadowColor: Colors.orange,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Icon(
                            card.icon,
                            size: 30,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            card.title,
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              if (card.buttonText == "Continue") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfilePage(),
                                  ),
                                ).then((_) {
                                  // Refresh profile data when returning from EditProfilePage
                                  _loadProfileData();
                                });
                              }
                              if (card.buttonText == "Orders") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const OrdersPage(userEmail: '',),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(card.buttonText),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
              const Padding(padding: EdgeInsets.only(right: 5)),
              itemCount: profileCompletionCards.length,
            ),
          ),
          const SizedBox(height: 35),
          ...List.generate(
            customListTiles.length,
                (index) {
              final tile = customListTiles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  child: ListTile(
                    leading: Icon(tile.icon),
                    title: Text(tile.title),
                    trailing: const Icon(Icons.chevron_right),
                    // --- START: Clickable List Tiles ---
                    onTap: () {
                      if (tile.title == "Notifications") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsPage(),
                          ),
                        );
                      } else if (tile.title == "About us") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutUsPage(),
                          ),
                        );
                      }
                      // Add more conditions for other tiles if needed
                    },
                    // --- END: Clickable List Tiles ---
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class ProfileCompletionCard {
  final String title;
  final String buttonText;
  final IconData icon;
  ProfileCompletionCard({
    required this.title,
    required this.buttonText,
    required this.icon,
  });
}

List<ProfileCompletionCard> profileCompletionCards = [
  ProfileCompletionCard(
    title: "Set Your Profile Details",
    icon: CupertinoIcons.person_circle,
    buttonText: "Continue",
  ),
  ProfileCompletionCard(
    title: "View My Orders",
    icon: CupertinoIcons.doc,
    buttonText: "Orders",
  ),
];

class CustomListTile {
  final IconData icon;
  final String title;
  CustomListTile({
    required this.icon,
    required this.title,
  });
}

List<CustomListTile> customListTiles = [
  CustomListTile(
    title: "Notifications",
    icon: CupertinoIcons.bell,
  ),
  CustomListTile(
    icon: Icons.person, // Using generic Icons.person for About us
    title: "About us",
  ),
];
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:agrismart/model/food.dart';
import 'package:agrismart/screens/detail_screen.dart';

import '../theme/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState()=> _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  int indexCategory = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onTabChange: (index) {
              print(index);
            },
            tabs: const [
            GButton(
                icon: Icons.home,
                    text: 'Home',
            ),
            GButton(
                icon: Icons.shopping_cart,
                text: 'Buy Now',
            ),
            GButton(
                icon: Icons.currency_exchange,
                text: 'Sell Now',
            ),
            GButton(
                icon: Icons.settings,
                text: 'Settings',
            ),
          ],),

        ),
      ),

    );
  }


}

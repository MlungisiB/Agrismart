import 'package:agrismart/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class YourWidget extends StatelessWidget {
  const YourWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightColorScheme.primary,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0), // Add padding to the left
          child: FutureBuilder<TextStyle>(
            future: _loadCustomFont(), // Load the custom font
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Text(
                  'Agrismart',
                  style: snapshot.data, // Apply the loaded font
                );
              } else {
                return const Text(
                  'Agrismart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }
            },
          ),
        ),
        titleSpacing: 0,
      ),
      // ... rest of your Scaffold ...
    );
  }

  // Function to load the custom font
  Future<TextStyle> _loadCustomFont() async {
    try {
      // Load the font from assets
      final fontData = await rootBundle.load('fonts/opensans-Bold.ttf');

      // Register the font with the fontLoader
      final fontLoader = FontLoader('OpenSans-Bold')
        ..addFont(Future.value(fontData));
      await fontLoader.load();

      // Return the textStyle
      return const TextStyle(
        fontFamily: 'OpenSans-Bold',
        color: Colors.white,
        fontSize: 42,
        fontWeight: FontWeight.bold,
      );
    } catch (e) {
      // Handle error
      print('Error loading custom font: $e');
      return const TextStyle(
        color: Colors.white,
        fontSize: 42,
        fontWeight: FontWeight.bold,
      );
    }
  }
}
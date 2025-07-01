// lib/screens/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconlyLight.notification, size: 80, color: Colors.grey), // Using IconlyLight.notification
            SizedBox(height: 16),
            Text(
              'No new notifications yet!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Check back later for updates.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
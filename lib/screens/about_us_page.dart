// lib/screens/about_us_page.dart
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About AgriSmart'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to AgriSmart!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'AgriSmart is your premier platform dedicated to revolutionizing the way farmers connect with consumers. Our mission is to empower local farmers by providing a direct, efficient, and fair marketplace for their produce, while offering consumers fresh, high-quality agricultural products directly from the source.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Text(
              'Our Vision',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We envision a sustainable agricultural ecosystem where farmers thrive, local economies flourish, and consumers have easy access to nutritious, locally grown food. AgriSmart aims to bridge the gap between farm and fork, ensuring transparency and fairness for everyone involved.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Text(
              'What We Offer',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildFeatureTile(context, Icons.agriculture, 'Direct Farm-to-Consumer Sales', 'Eliminating middlemen to ensure better prices for farmers and fresher produce for you.'),
            _buildFeatureTile(context, Icons.delivery_dining_rounded, 'Efficient Logistics', 'Streamlined delivery options to get your orders to you quickly and reliably.'),
            _buildFeatureTile(context, Icons.shopping_basket, 'Wide Range of Products', 'From fresh fruits and vegetables to dairy and specialty items, find everything you need.'),
            _buildFeatureTile(context, Icons.support_agent, 'Dedicated Support', 'Our team is here to assist you with any queries or issues.'),
            const SizedBox(height: 20),
            Text(
              'Our Commitment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'AgriSmart is committed to supporting local communities and promoting sustainable farming practices. We believe in building strong relationships based on trust, quality, and mutual benefit.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            Text(
              'Contact Us',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Have questions or feedback? We\'d love to hear from you!\n\nEmail: agrismarties@gmail.com\nPhone: +268 7818 2282/ 7943 5715 \nAddress: Mbabane, Manzini, Eswatini',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                '© 2025 AgriSmart. All rights reserved.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build feature tiles
  Widget _buildFeatureTile(BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Colors.green[600]),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
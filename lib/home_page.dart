import 'package:flutter/material.dart';
import 'real_time_offer.dart';
import 'browse_digital_menu.dart';
import 'online_order.dart';
import 'table_reservation.dart';
import 'review_rating.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Dummy navigation function for placeholders
  void navigateTo(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to $feature...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodieGo'),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to FoodieGo 🍽️',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your all-in-one solution for food ordering, table reservations, and more!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Feature Cards
            _buildFeatureCard(
              context,
              icon: Icons.restaurant_menu,
              title: 'Browse Digital Menu',
              subtitle: 'View menus, images, dietary info',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BrowseDigitalMenu()),
                );
              },
            ),
            _buildFeatureCard(
              context,
              icon: Icons.shopping_cart,
              title: 'Order Online',
              subtitle: 'Customize your meal and pay easily',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OnlineOrder()),
                );
              },
            ),
            _buildFeatureCard(
              context,
              icon: Icons.table_restaurant,
              title: 'Table Reservation',
              subtitle: 'Reserve tables at your favorite spots',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TableReservationPage()),
                );
              },
            ),
            _buildFeatureCard(
              context,
              icon: Icons.local_offer,
              title: 'Real-Time Offers',
              subtitle: 'Grab discounts and flash deals',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RealTimeOfferPage()),
                );
              },
            ),
            _buildFeatureCard(
              context,
              icon: Icons.star_rate,
              title: 'Reviews & Ratings',
              subtitle: 'Read and write restaurant reviews',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReviewRatingPage()),
                );
              },
            ),
            // Loyalty Points card removed
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_login_offer.dart';

class RealTimeOfferPage extends StatelessWidget {
  const RealTimeOfferPage({super.key});

  void _navigateToAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminLoginOfferPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference offersRef =
    FirebaseFirestore.instance.collection('offers');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Offers'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Panel',
            onPressed: () => _navigateToAdmin(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: offersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final offers = snapshot.data?.docs ?? [];

          if (offers.isEmpty) {
            return const Center(child: Text('No offers available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              final data = offer.data() as Map<String, dynamic>;
              return Card(
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.local_offer,
                      color: Colors.deepOrange, size: 32),
                  title: Text(
                    data['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data['description'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

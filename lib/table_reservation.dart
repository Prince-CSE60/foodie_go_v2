import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'admin_login_table.dart';

class TableReservationPage extends StatefulWidget {
  const TableReservationPage({super.key});

  @override
  State<TableReservationPage> createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  String _searchQuery = '';

  String _formatDateTime(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return DateFormat('MMM dd, yyyy – hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Table Reservations'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminLoginTablePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // 📋 Reservation List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tableReservations')
                    .orderBy('datetime')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading reservations'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final reservations = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name']?.toString().toLowerCase() ?? '';
                    return name.contains(_searchQuery);
                  }).toList();

                  if (reservations.isEmpty) {
                    return const Center(child: Text('No matching reservations found.'));
                  }

                  return ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final data = reservations[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.event_seat, color: Colors.deepOrange),
                          title: Text('${data['name']} - ${data['people']} People'),
                          subtitle: Text(_formatDateTime(data['datetime'])),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_login_order.dart';

class OnlineOrder extends StatefulWidget {
  const OnlineOrder({super.key});

  @override
  _OnlineOrderState createState() => _OnlineOrderState();
}

class _OnlineOrderState extends State<OnlineOrder> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Panel',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminLoginOrder()),
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
              decoration: InputDecoration(
                labelText: 'Search by item name',
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

          // 🔁 Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('orders')
                  .orderBy('orderDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading orders'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final itemName = data['name']?.toString().toLowerCase() ?? '';
                  return itemName.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return Center(child: Text('No matching orders found'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data()! as Map<String, dynamic>;
                    final orderDate = (data['orderDate'] as Timestamp?)?.toDate();

                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          data['name'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['description'] != null)
                              Text(data['description']),
                            SizedBox(height: 5),
                            if (data['userName'] != null)
                              Text('Ordered by: ${data['userName']}'),
                            if (data['userAddress'] != null)
                              Text('Address: ${data['userAddress']}'),
                            SizedBox(height: 5),
                            if (orderDate != null)
                              Text(
                                'Ordered on: ${orderDate.toLocal().toString().split('.')[0]}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                          ],
                        ),
                        trailing: Text(
                          data['price'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrder extends StatefulWidget {
  const AdminOrder({super.key});

  @override
  _AdminOrderState createState() => _AdminOrderState();
}

class _AdminOrderState extends State<AdminOrder> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteOrder(String docId) async {
    try {
      await _firestore.collection('orders').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Order Panel'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text('No orders found'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
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
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Delete this order?'),
                          content: Text('Are you sure you want to delete this order?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                _deleteOrder(doc.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

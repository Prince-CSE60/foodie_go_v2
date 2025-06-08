import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_login.dart';

class BrowseDigitalMenu extends StatefulWidget {
  const BrowseDigitalMenu({super.key});

  @override
  _BrowseDigitalMenuState createState() => _BrowseDigitalMenuState();
}

class _BrowseDigitalMenuState extends State<BrowseDigitalMenu> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  Future<void> _showOrderDialog(BuildContext context, Map<String, dynamic> itemData) async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter your details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Confirm'),
              onPressed: () async {
                final userName = nameController.text.trim();
                final userAddress = addressController.text.trim();

                if (userName.isEmpty || userAddress.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter both name and address')),
                  );
                  return;
                }

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order is in process...')),
                );

                try {
                  await _firestore.collection('orders').add({
                    'name': itemData['name'],
                    'description': itemData['description'],
                    'price': itemData['price'],
                    'orderDate': FieldValue.serverTimestamp(),
                    'userName': userName,
                    'userAddress': userAddress,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${itemData['name']} ordered successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to place order: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onBuyPressed(BuildContext context, Map<String, dynamic> itemData) async {
    await _showOrderDialog(context, itemData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Menu'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            tooltip: 'Admin',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminLoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Updated Search Bar (same style as OnlineOrder)
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

          // 🔁 Menu Items List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('menuItems').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading menu'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(child: Text('No matching menu items'));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data()! as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          data['name'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(data['description'] ?? ''),
                        trailing: Wrap(
                          spacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              data['price'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              onPressed: () => _onBuyPressed(context, data),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              child: Text('Buy'),
                            ),
                          ],
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

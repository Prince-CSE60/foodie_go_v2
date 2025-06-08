import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditMenu extends StatefulWidget {
  const EditMenu({super.key});

  @override
  _EditMenuState createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers for new menu item (Add functionality)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Add new menu item to Firestore
  Future<void> _addMenuItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('menuItems').add({
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'price': _priceController.text.trim(),
        });
        _nameController.clear();
        _descController.clear();
        _priceController.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menu item added')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add item: $e')));
      }
    }
  }

  // Update existing menu item
  Future<void> _updateMenuItem(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('menuItems').doc(id).update(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menu item updated')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update item: $e')));
    }
  }

  // Delete menu item
  Future<void> _deleteMenuItem(String id) async {
    try {
      await _firestore.collection('menuItems').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menu item deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete item: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Show dialog to edit a menu item
  void _showEditDialog(DocumentSnapshot doc) {
    final editNameController = TextEditingController(text: doc['name']);
    final editDescController = TextEditingController(text: doc['description']);
    final editPriceController = TextEditingController(text: doc['price']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Menu Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: editNameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: editDescController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: editPriceController,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateMenuItem(doc.id, {
                  'name': editNameController.text.trim(),
                  'description': editDescController.text.trim(),
                  'price': editPriceController.text.trim(),
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Menu'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          // Form to add new menu item
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text('Add New Menu Item', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
                  ),
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    validator: (val) => val == null || val.isEmpty ? 'Enter price' : null,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addMenuItem,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                    child: Text('Add Item'),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Expanded(
            // Display list from Firestore
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
                if (docs.isEmpty) {
                  return Center(child: Text('No menu items found'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data()! as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.all(8),
                      elevation: 2,
                      child: ListTile(
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(data['description'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(data['price'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(doc),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMenuItem(doc.id),
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

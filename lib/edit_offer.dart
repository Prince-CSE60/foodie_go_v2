import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditOfferPage extends StatelessWidget {
  EditOfferPage({super.key});

  final CollectionReference offersRef =
  FirebaseFirestore.instance.collection('offers');

  Future<void> _showAddEditDialog(BuildContext context,
      {DocumentSnapshot? doc}) async {
    final titleController = TextEditingController(text: doc?.get('title') ?? '');
    final descController =
    TextEditingController(text: doc?.get('description') ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(doc == null ? 'Add New Offer' : 'Edit Offer'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) =>
                val == null || val.isEmpty ? 'Please enter title' : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (val) =>
                val == null || val.isEmpty ? 'Please enter description' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final data = {
                  'title': titleController.text.trim(),
                  'description': descController.text.trim(),
                };
                if (doc == null) {
                  // Add new document
                  await offersRef.add(data);
                } else {
                  // Update existing document
                  await offersRef.doc(doc.id).update(data);
                }
                Navigator.of(ctx).pop();
              }
            },
            child: Text(doc == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOffer(BuildContext context, DocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Offer'),
        content: const Text('Are you sure you want to delete this offer?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await offersRef.doc(doc.id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Offers'),
        backgroundColor: Colors.deepOrange,
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
            return const Center(child: Text('No offers available. Add some!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offerDoc = offers[index];
              final data = offerDoc.data() as Map<String, dynamic>;
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showAddEditDialog(context, doc: offerDoc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteOffer(context, offerDoc),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

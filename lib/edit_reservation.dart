import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditReservationPage extends StatefulWidget {
  const EditReservationPage({super.key});

  @override
  _EditReservationPageState createState() => _EditReservationPageState();
}

class _EditReservationPageState extends State<EditReservationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _peopleController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _editingDocId;

  String _formatDateTime(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return DateFormat('MMM dd, yyyy – hh:mm a').format(dt);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _peopleController.clear();
    _selectedDate = null;
    _selectedTime = null;
    _editingDocId = null;
  }

  Future<void> _saveReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    final reservationDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      if (_editingDocId == null) {
        await _firestore.collection('tableReservations').add({
          'name': _nameController.text.trim(),
          'people': int.parse(_peopleController.text.trim()),
          'datetime': reservationDateTime,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation added')),
        );
      } else {
        await _firestore.collection('tableReservations').doc(_editingDocId).update({
          'name': _nameController.text.trim(),
          'people': int.parse(_peopleController.text.trim()),
          'datetime': reservationDateTime,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation updated')),
        );
      }
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  void _startEditing(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      _editingDocId = doc.id;
      _nameController.text = data['name'];
      _peopleController.text = data['people'].toString();
      Timestamp ts = data['datetime'];
      DateTime dt = ts.toDate();
      _selectedDate = DateTime(dt.year, dt.month, dt.day);
      _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
    });
  }

  Future<void> _deleteReservation(String docId) async {
    try {
      await _firestore.collection('tableReservations').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation deleted')),
      );
      if (_editingDocId == docId) {
        _clearForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingDocId == null ? 'Add Reservation' : 'Edit Reservation'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
                  ),
                  TextFormField(
                    controller: _peopleController,
                    decoration: const InputDecoration(labelText: 'Number of People'),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter number of people';
                      if (int.tryParse(val) == null || int.parse(val) <= 0) return 'Enter valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_selectedDate == null
                            ? 'Select Date'
                            : 'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}'),
                      ),
                      ElevatedButton(
                        onPressed: _pickDate,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                        child: const Text('Pick Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_selectedTime == null
                            ? 'Select Time'
                            : 'Time: ${_selectedTime!.format(context)}'),
                      ),
                      ElevatedButton(
                        onPressed: _pickTime,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                        child: const Text('Pick Time'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saveReservation,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                        child: Text(_editingDocId == null ? 'Add' : 'Update'),
                      ),
                      const SizedBox(width: 20),
                      if (_editingDocId != null)
                        ElevatedButton(
                          onPressed: _clearForm,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          child: const Text('Cancel'),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
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

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text('No reservations found'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final ts = data['datetime'] as Timestamp;
                      final formattedDate = _formatDateTime(ts);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text('${data['name']} - ${data['people']} People'),
                          subtitle: Text(formattedDate),
                          isThreeLine: false,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.deepOrange),
                                onPressed: () => _startEditing(doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text('Are you sure you want to delete this reservation?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                            _deleteReservation(doc.id);
                                          },
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

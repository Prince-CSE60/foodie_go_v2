import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewRatingPage extends StatefulWidget {
  const ReviewRatingPage({super.key});

  @override
  State<ReviewRatingPage> createState() => _ReviewRatingPageState();
}

class _ReviewRatingPageState extends State<ReviewRatingPage> {
  final CollectionReference reviewsRef =
  FirebaseFirestore.instance.collection('reviews');

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  int _rating = 5; // default rating

  Future<void> _addReview() async {
    if (_formKey.currentState!.validate()) {
      await reviewsRef.add({
        'name': _nameController.text.trim(),
        'comment': _commentController.text.trim(),
        'rating': _rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _commentController.clear();
      setState(() {
        _rating = 5;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added successfully!')),
      );
    }
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildReviewItem(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final name = data['name'] ?? 'Anonymous';
    final comment = data['comment'] ?? '';
    final rating = data['rating'] ?? 0;
    Timestamp? ts = data['timestamp'];
    final date = ts != null
        ? DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStarRating(rating),
            const SizedBox(height: 4),
            Text(comment),
            if (date != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${date.toLocal()}'.split(' ')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        int starIndex = index + 1;
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = starIndex;
            });
          },
          icon: Icon(
            starIndex <= _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews & Ratings'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Form for adding review
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Your Review',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a review' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text('Your Rating:', style: TextStyle(fontSize: 16)),
                  _buildRatingSelector(),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: _addReview,
                    child: const Text('Submit Review'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Divider(),
            const SizedBox(height: 10),

            // List of reviews
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: reviewsRef.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final reviews = snapshot.data?.docs ?? [];

                  if (reviews.isEmpty) {
                    return const Center(child: Text('No reviews yet. Be the first!'));
                  }

                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      return _buildReviewItem(reviews[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

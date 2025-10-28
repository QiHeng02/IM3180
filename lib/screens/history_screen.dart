import 'package:flutter/material.dart';
import 'package:im3180/widgets/bottom_nav.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Color _statusColor(String freshness) {
    switch (freshness.toLowerCase()) {
      case 'fresh':
        return const Color(0xFF4CAF50);
      case 'moderate':
        return const Color(0xFFFFA726);
      case 'spoiled':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF90A4AE);
    }
  }

  String _emojiForFood(String? food) {
    final f = (food ?? '').toLowerCase();
    if (f.contains('apple')) return '🍎';
    if (f.contains('blueberry')) return '🫐';
    if (f.contains('chicken')) return '🍗';
    if (f.contains('tofu')) return '🥡';
    if (f.contains('banana')) return '🍌';
    if (f.contains('milk')) return '🥛';
    return '🍽️';
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _recommendationFor(String freshness) {
    switch (freshness.toLowerCase()) {
      case 'fresh':
        return 'recommended to consume';
      case 'moderate':
        return 'not recommended to consume';
      default:
        return 'not safe to consume';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFDF7),
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [LogoutButton()],
      ),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('Please sign in to view history'))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('scans')
                    .where('status', isEqualTo: 'complete')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final docs = (snapshot.data?.docs ?? [])
                    ..sort((a, b) {
                      final ta =
                          (a.data()['inferredAt'] ?? a.data()['createdAt']);
                      final tb =
                          (b.data()['inferredAt'] ?? b.data()['createdAt']);
                      if (ta == null || tb == null) return 0;
                      return (tb as Timestamp).compareTo(
                        ta as Timestamp,
                      ); // latest first
                    });
                  if (docs.isEmpty) {
                    return const Center(child: Text('No scans yet.'));
                  }

                  return Stack(
                    children: [
                      // Decorative food icons (kept)
                      const Positioned(
                        top: 5,
                        left: 8,
                        child: Text('🍃', style: TextStyle(fontSize: 28)),
                      ),
                      const Positioned(
                        top: 5,
                        right: 8,
                        child: Text('🥗', style: TextStyle(fontSize: 28)),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1, color: Color(0xFFE8F5E9)),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF66BB6A),
                                        Color(0xFF4CAF50),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.history,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Food History',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Real items
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                final data = doc.data();
                                final food =
                                    (data['selectedFood'] ?? data['food'] ?? '')
                                        as String;
                                final category =
                                    (data['selectedCategory'] ??
                                            data['category'] ??
                                            '')
                                        as String;
                                final ph = (data['phValue'] as num?)
                                    ?.toDouble();
                                final freshness =
                                    (data['freshness'] ?? 'unknown').toString();
                                final hours = data['hoursToConsume'];
                                final imageUrl = data['imageUrl'] as String?;
                                final storagePath =
                                    data['storagePath'] as String?;
                                final inferredAt =
                                    data['inferredAt']; // Timestamp?
                                final title = food.isNotEmpty
                                    ? _cap(food)
                                    : (category.isNotEmpty
                                          ? _cap(category)
                                          : 'Scan');
                                final statusColor = _statusColor(freshness);

                                final descParts = <String>[];
                                if (ph != null)
                                  descParts.add('pH ${ph.toStringAsFixed(1)}');
                                descParts.add(_cap(freshness));
                                if (hours is int) {
                                  descParts.add(_recommendationFor(freshness));
                                }
                                final description = descParts.join(' • ');

                                return _buildHistoryItem(
                                  emoji: _emojiForFood(food),
                                  title: title,
                                  status: _cap(freshness),
                                  description: description,
                                  statusColor: statusColor,
                                  imageUrl: imageUrl,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 1),
    );
  }

  // Removed onDelete
  Widget _buildHistoryItem({
    required String emoji,
    required String title,
    required String status,
    required String description,
    required Color statusColor,
    String? imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F5E9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: emoji or thumbnail
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl == null || imageUrl.isEmpty
                  ? Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // Title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          // trailing space preserved; delete button removed
        ],
      ),
    );
  }
}

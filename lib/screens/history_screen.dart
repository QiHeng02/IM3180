import 'package:flutter/material.dart';
import 'package:im3180/widgets/bottom_nav.dart';
import 'home.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFDF7),
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [LogoutButton()],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative food icons
            Positioned(
              top: 5,
              left: 8,
              child: Text(
                '🍃',
                style: TextStyle(fontSize: 28),
              ),
            ),
            
            Positioned(
              top: 5,
              right: 8,
              child: Text(
                '🥗',
                style: TextStyle(fontSize: 28),
              ),
            ),
            
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: Color(0xFFE8F5E9)),
                
                // Title section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
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

                // List of history items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildHistoryItem(
                        emoji: '🍎',
                        title: 'Organic Apples',
                        status: 'Fresh',
                        description: 'Fresh to eat. Consume in 14 days!',
                        statusColor: const Color(0xFF4CAF50),
                      ),
                      _buildHistoryItem(
                        emoji: '🍌',
                        title: 'Ripe Bananas',
                        status: 'Expiring Soon',
                        description: 'Fresh to eat. Consume in 3 days!',
                        statusColor: const Color(0xFFFFA726),
                      ),
                      _buildHistoryItem(
                        emoji: '🥕',
                        title: 'Baby Carrots',
                        status: 'Expired',
                        description: 'Expired 2 days ago.',
                        statusColor: const Color(0xFFEF5350),
                      ),
                      _buildHistoryItem(
                        emoji: '🥛',
                        title: 'Whole Milk',
                        status: 'Fresh',
                        description: 'Fresh to eat. Consume in 7 days!',
                        statusColor: const Color(0xFF4CAF50),
                      ),
                      _buildHistoryItem(
                        emoji: '🧀',
                        title: 'Cheddar Cheese',
                        status: 'Expiring Soon',
                        description: 'Fresh to eat. Consume in 5 days!',
                        statusColor: const Color(0xFFFFA726),
                      ),
                      _buildHistoryItem(
                        emoji: '🥚',
                        title: 'Farm Fresh Eggs',
                        status: 'Fresh',
                        description: 'Fresh to eat. Consume in 10 days!',
                        statusColor: const Color(0xFF4CAF50),
                      ),
                      _buildHistoryItem(
                        emoji: '🍊',
                        title: 'Orange Juice',
                        status: 'Fresh',
                        description: 'Fresh to eat. Consume in 21 days!',
                        statusColor: const Color(0xFF4CAF50),
                      ),
                      _buildHistoryItem(
                        emoji: '🍌',
                        title: 'Green Bananas',
                        status: 'Fresh',
                        description: 'Fresh to eat. Consume in 8 days!',
                        statusColor: const Color(0xFF4CAF50),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHistoryItem({
    required String emoji,
    required String title,
    required String status,
    required String description,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8F5E9),
          width: 1.5,
        ),
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
          // Emoji icon container
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
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
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

          // Delete button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                // Handle delete action
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFEF5350),
                size: 22,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}
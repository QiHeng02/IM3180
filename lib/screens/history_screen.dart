import 'package:flutter/material.dart';
import 'package:im3180/widgets/bottom_nav.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1),

            // List of history items
            Expanded(
              child: ListView(
                children: [
                  _buildHistoryItem(
                    title: 'Apple',
                    description: 'PH 5.3 - Fresh to eat. Consume in 14 days!',
                  ),
                  _buildHistoryItem(
                    title: 'Banana',
                    description: 'PH 15.0 - Fresh to eat. Consume in 100 days!',
                  ),
                  _buildHistoryItem(
                    title: 'List item',
                    description:
                        'Supporting line text lorem ipsum dolor sit amet, consectetur.',
                  ),
                  _buildHistoryItem(
                    title: 'List item',
                    description:
                        'Supporting line text lorem ipsum dolor sit amet, consectetur.',
                  ),
                  _buildHistoryItem(
                    title: 'List item',
                    description:
                        'Supporting line text lorem ipsum dolor sit amet, consectetur.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: AppBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        children: [
          // Purple icon container with abstract shapes
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2F6BFF), // Blue color
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ],
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),

          // Delete button
          IconButton(
            onPressed: () {
              // Handle delete action
            },
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.black,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

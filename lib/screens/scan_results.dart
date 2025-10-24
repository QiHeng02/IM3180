import 'package:flutter/material.dart';
import 'package:im3180/screens/home.dart';

class ScanResultsScreen extends StatelessWidget {
  final String imageUrl;
  final double phValue;
  final String freshness;
  final int hoursToConsume;

  // NEW optional fields from function
  final double? safePhMin;
  final double? safePhMax;
  final String? selectedFood;
  final bool? isInSafeRange;

  const ScanResultsScreen({
    super.key,
    required this.imageUrl,
    required this.phValue,
    required this.freshness,
    required this.hoursToConsume,
    this.safePhMin,
    this.safePhMax,
    this.selectedFood,
    this.isInSafeRange,
  });

  Color _getFreshnessColor() {
    switch (freshness.toLowerCase()) {
      case 'fresh':
        return const Color(0xFF4CAF50);
      case 'moderate':
        return const Color(0xFFFF9800);
      case 'spoiled':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  double _indicatorPosition() => phValue.clamp(0, 14) / 14.0;

  Widget _phScaleIndicator(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF0000),
                Color(0xFFFF6600),
                Color(0xFFFFCC00),
                Color(0xFF66FF00),
                Color(0xFF00FF66),
                Color(0xFF0066FF),
                Color(0xFF6600FF),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left:
                    _indicatorPosition() *
                        (MediaQuery.of(context).size.width - 80) -
                    10,
                top: 5,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _getFreshnessColor(), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("0"),
            Text("3.5"),
            Text("7"),
            Text("10.5"),
            Text("14"),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Scan Results'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 220,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'Image failed to load',
                      style: TextStyle(color: Colors.red),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'pH Value: ${phValue.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Freshness: $freshness',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getFreshnessColor(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Consume within: ${hoursToConsume > 0 ? '$hoursToConsume hours' : 'Not safe to consume'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            if (safePhMin != null && safePhMax != null) ...[
              Text(
                'Safe pH for ${selectedFood?.isNotEmpty == true ? selectedFood : "item"}: '
                '${safePhMin!.toStringAsFixed(1)} - ${safePhMax!.toStringAsFixed(1)}'
                '${isInSafeRange == null ? "" : (isInSafeRange! ? " (in range)" : " (out of range)")}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 30),
            _phScaleIndicator(context),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF007AFF), // blue background
                  foregroundColor: Colors.white, // white text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Scan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                // changed from OutlinedButton
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // red background
                  foregroundColor: Colors.white, // white text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // ensure white text
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
